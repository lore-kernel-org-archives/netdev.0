From: David Ahern <dsa@cumulusnetworks.com>
Subject: [RFC net-next 10/11] net: Rename FLOWI_FLAG_VRFSRC to FLOWI_FLAG_L3MDEV_SRC
Date: Fri, 18 Sep 2015 10:06:24 -0700
Message-ID: <1442595985-7049-11-git-send-email-dsa@cumulusnetworks.com>
References: <1442595985-7049-1-git-send-email-dsa@cumulusnetworks.com>
Cc: shm@cumulusnetworks.com, roopa@cumulusnetworks.com,
	nikolay@cumulusnetworks.com, gospo@cumulusnetworks.com,
	David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:35477 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753779AbbIRRGv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Sep 2015 13:06:51 -0400
Received: by pacfv12 with SMTP id fv12so56837824pac.2
        for <netdev@vger.kernel.org>; Fri, 18 Sep 2015 10:06:50 -0700 (PDT)
In-Reply-To: <1442595985-7049-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 drivers/net/vrf.c   | 4 ++--
 include/net/flow.h  | 2 +-
 include/net/route.h | 2 +-
 net/ipv4/fib_trie.c | 2 +-
 net/ipv4/udp.c      | 2 +-
 5 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index a3d5bcabbc48..8fe7b0adaeb2 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -208,7 +208,7 @@ static netdev_tx_t vrf_process_v4_outbound(struct sk_buff *skb,
 		.flowi4_oif = vrf_dev->ifindex,
 		.flowi4_iif = LOOPBACK_IFINDEX,
 		.flowi4_tos = RT_TOS(ip4h->tos),
-		.flowi4_flags = FLOWI_FLAG_ANYSRC | FLOWI_FLAG_VRFSRC,
+		.flowi4_flags = FLOWI_FLAG_ANYSRC | FLOWI_FLAG_L3MDEV_SRC,
 		.daddr = ip4h->daddr,
 	};
 
@@ -544,7 +544,7 @@ static struct rtable *vrf_get_rtable(const struct net_device *dev,
 {
 	struct rtable *rth = NULL;
 
-	if (!(fl4->flowi4_flags & FLOWI_FLAG_VRFSRC)) {
+	if (!(fl4->flowi4_flags & FLOWI_FLAG_L3MDEV_SRC)) {
 		struct net_vrf *vrf = netdev_priv(dev);
 
 		rth = vrf->rth;
diff --git a/include/net/flow.h b/include/net/flow.h
index acd6a096250e..682a5d0dab39 100644
--- a/include/net/flow.h
+++ b/include/net/flow.h
@@ -34,7 +34,7 @@ struct flowi_common {
 	__u8	flowic_flags;
 #define FLOWI_FLAG_ANYSRC		0x01
 #define FLOWI_FLAG_KNOWN_NH		0x02
-#define FLOWI_FLAG_VRFSRC		0x04
+#define FLOWI_FLAG_L3MDEV_SRC		0x04
 	__u32	flowic_secid;
 	struct flowi_tunnel flowic_tun_key;
 };
diff --git a/include/net/route.h b/include/net/route.h
index aef6c9a38fcb..68353df7390a 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -258,7 +258,7 @@ static inline void ip_route_connect_init(struct flowi4 *fl4, __be32 dst, __be32
 		flow_flags |= FLOWI_FLAG_ANYSRC;
 
 	if (netif_index_is_l3_master(sock_net(sk), oif))
-		flow_flags |= FLOWI_FLAG_VRFSRC;
+		flow_flags |= FLOWI_FLAG_L3MDEV_SRC;
 
 	flowi4_init_output(fl4, oif, sk->sk_mark, tos, RT_SCOPE_UNIVERSE,
 			   protocol, flow_flags, dst, src, dport, sport);
diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 26d6ffb6d23c..bb62f977e671 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -1426,7 +1426,7 @@ int fib_table_lookup(struct fib_table *tb, const struct flowi4 *flp,
 			    nh->nh_flags & RTNH_F_LINKDOWN &&
 			    !(fib_flags & FIB_LOOKUP_IGNORE_LINKSTATE))
 				continue;
-			if (!(flp->flowi4_flags & FLOWI_FLAG_VRFSRC)) {
+			if (!(flp->flowi4_flags & FLOWI_FLAG_L3MDEV_SRC)) {
 				if (flp->flowi4_oif &&
 				    flp->flowi4_oif != nh->nh_oif)
 					continue;
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 225d849d611d..76b69a616ccd 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1024,7 +1024,7 @@ int udp_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 		if (netif_index_is_l3_master(net, ipc.oif)) {
 			flowi4_init_output(fl4, ipc.oif, sk->sk_mark, tos,
 					   RT_SCOPE_UNIVERSE, sk->sk_protocol,
-					   (flow_flags | FLOWI_FLAG_VRFSRC),
+					   (flow_flags | FLOWI_FLAG_L3MDEV_SRC),
 					   faddr, saddr, dport,
 					   inet->inet_sport);
 
-- 
1.9.1
