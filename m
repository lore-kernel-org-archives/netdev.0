From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 05/16] net: Use VRF device index for lookups on TX
Date: Mon, 27 Jul 2015 12:30:58 -0600
Message-ID: <1438021869-49186-6-git-send-email-dsa@cumulusnetworks.com>
References: <1438021869-49186-1-git-send-email-dsa@cumulusnetworks.com>
Cc: shm@cumulusnetworks.com, roopa@cumulusnetworks.com,
	gospo@cumulusnetworks.com, jtoppins@cumulusnetworks.com,
	nikolay@cumulusnetworks.com, ddutt@cumulusnetworks.com,
	hannes@stressinduktion.org, nicolas.dichtel@6wind.com,
	stephen@networkplumber.org, hadi@mojatatu.com,
	ebiederm@xmission.com, davem@davemloft.net, svaidya@brocade.com,
	mingo@kernel.org, luto@amacapital.net,
	David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f169.google.com ([209.85.213.169]:33646 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753813AbbG0Sc7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2015 14:32:59 -0400
Received: by igbpg9 with SMTP id pg9so104320082igb.0
        for <netdev@vger.kernel.org>; Mon, 27 Jul 2015 11:32:58 -0700 (PDT)
In-Reply-To: <1438021869-49186-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As with ingress use the index of VRF master device for route lookups on
egress. However, the oif should only be used to direct the lookups to a
specific table. Routes in the table are not based on the VRF device but
rather interfaces that are part of the VRF so do not consider the oif for
lookups within the table. The FLOWI_FLAG_VRFSRC is used to control this
latter part.

Signed-off-by: Shrijeet Mukherjee <shm@cumulusnetworks.com>
Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 include/net/flow.h  | 1 +
 include/net/route.h | 3 +++
 net/ipv4/fib_trie.c | 7 +++++--
 net/ipv4/icmp.c     | 4 ++++
 net/ipv4/route.c    | 3 +++
 5 files changed, 16 insertions(+), 2 deletions(-)

diff --git a/include/net/flow.h b/include/net/flow.h
index 3098ae33a178..f305588fc162 100644
--- a/include/net/flow.h
+++ b/include/net/flow.h
@@ -33,6 +33,7 @@ struct flowi_common {
 	__u8	flowic_flags;
 #define FLOWI_FLAG_ANYSRC		0x01
 #define FLOWI_FLAG_KNOWN_NH		0x02
+#define FLOWI_FLAG_VRFSRC		0x04
 	__u32	flowic_secid;
 	struct flowi_tunnel flowic_tun_key;
 };
diff --git a/include/net/route.h b/include/net/route.h
index cec7a2a055c8..54f97eea0fb2 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -254,6 +254,9 @@ static inline void ip_route_connect_init(struct flowi4 *fl4, __be32 dst, __be32
 	if (inet_sk(sk)->transparent)
 		flow_flags |= FLOWI_FLAG_ANYSRC;
 
+	if (netif_index_is_vrf(sock_net(sk), oif))
+		flow_flags |= FLOWI_FLAG_VRFSRC;
+
 	flowi4_init_output(fl4, oif, sk->sk_mark, tos, RT_SCOPE_UNIVERSE,
 			   protocol, flow_flags, dst, src, dport, sport);
 }
diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index ac2d828c6daa..7da901c56e35 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -1421,8 +1421,11 @@ int fib_table_lookup(struct fib_table *tb, const struct flowi4 *flp,
 			    nh->nh_flags & RTNH_F_LINKDOWN &&
 			    !(fib_flags & FIB_LOOKUP_IGNORE_LINKSTATE))
 				continue;
-			if (flp->flowi4_oif && flp->flowi4_oif != nh->nh_oif)
-				continue;
+			if (!(flp->flowi4_flags & FLOWI_FLAG_VRFSRC)) {
+				if (flp->flowi4_oif &&
+				    flp->flowi4_oif != nh->nh_oif)
+					continue;
+			}
 
 			if (!(fib_flags & FIB_LOOKUP_NOREF))
 				atomic_inc(&fi->fib_clntref);
diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index c0556f1e4bf0..d2d142b775b8 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -96,6 +96,7 @@
 #include <net/xfrm.h>
 #include <net/inet_common.h>
 #include <net/ip_fib.h>
+#include <net/vrf.h>
 
 /*
  *	Build xmit assembly blocks
@@ -425,6 +426,7 @@ static void icmp_reply(struct icmp_bxm *icmp_param, struct sk_buff *skb)
 	fl4.flowi4_mark = mark;
 	fl4.flowi4_tos = RT_TOS(ip_hdr(skb)->tos);
 	fl4.flowi4_proto = IPPROTO_ICMP;
+	fl4.flowi4_oif = vrf_master_dev_ifindex(skb->dev) ? : skb->dev->ifindex;
 	security_skb_classify_flow(skb, flowi4_to_flowi(&fl4));
 	rt = ip_route_output_key(net, &fl4);
 	if (IS_ERR(rt))
@@ -458,6 +460,8 @@ static struct rtable *icmp_route_lookup(struct net *net,
 	fl4->flowi4_proto = IPPROTO_ICMP;
 	fl4->fl4_icmp_type = type;
 	fl4->fl4_icmp_code = code;
+	fl4->flowi4_oif = vrf_master_dev_ifindex(skb_in->dev) ? : skb_in->dev->ifindex;
+
 	security_skb_classify_flow(skb_in, flowi4_to_flowi(fl4));
 	rt = __ip_route_output_key(net, fl4);
 	if (IS_ERR(rt))
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index ba74c83c05be..8119896e1159 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2093,6 +2093,9 @@ struct rtable *__ip_route_output_key(struct net *net, struct flowi4 *fl4)
 		if (!dev_out)
 			goto out;
 
+		if (netif_is_vrf(dev_out))
+			fl4->flowi4_flags |= FLOWI_FLAG_VRFSRC;
+
 		/* RACE: Check return value of inet_select_addr instead. */
 		if (!(dev_out->flags & IFF_UP) || !__in_dev_get_rcu(dev_out)) {
 			rth = ERR_PTR(-ENETUNREACH);
-- 
2.3.2 (Apple Git-55)
