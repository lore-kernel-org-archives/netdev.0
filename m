From: Shrijeet Mukherjee <shm@cumulusnetworks.com>
Subject: [RFC net-next 3/3] rcv path changes for vrf traffic
Date: Mon,  8 Jun 2015 11:35:34 -0700
Message-ID: <87eae7a7a03708bda5560a5ea43b0fcac705c80d.1433561681.git.shm@cumulusnetworks.com>
References: <cover.1433561681.git.shm@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, gospo@cumulusnetworks.com,
	jtoppins@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	Shrijeet Mukherjee <shm@cumulusnetworks.com>
To: hannes@stressinduktion.org, nicolas.dichtel@6wind.com,
	dsahern@gmail.com, ebiederm@xmission.com, hadi@mojatatu.com,
	davem@davemloft.net, stephen@networkplumber.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f180.google.com ([209.85.216.180]:36863 "EHLO
	mail-qc0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752812AbbFHSgB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jun 2015 14:36:01 -0400
Received: by qcxw10 with SMTP id w10so53983184qcx.3
        for <netdev@vger.kernel.org>; Mon, 08 Jun 2015 11:36:00 -0700 (PDT)
In-Reply-To: <cover.1433561681.git.shm@cumulusnetworks.com>
In-Reply-To: <cover.1433561681.git.shm@cumulusnetworks.com>
References: <cover.1433561681.git.shm@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shrijeet Mukherjee <shm@cumulusnetworks.com>

Incoming frames for IP protocol stacks need the IIF to be changed
from the actual interface to the VRF device. This allows the IIF
rule to be used to select tables (or do regular PBR)

This change selects the iif to be the VRF device if it exists and
the incoming iif is enslaved to the VRF device.

Since VRF aware sockets are always bound to the VRF device this
system allows return traffic to find the socket of origin.

changes are in the arp_rcv, icmp_rcv and ip_rcv paths

Question : I did not wrap the rcv modifications, in CONFIG_NET_VRF
as it would create code variations and the vrf_ptr check is there
I can make that whole thing modular.

Signed-off-by: Shrijeet Mukherjee <shm@cumulusnetworks.com>
---
 net/ipv4/fib_frontend.c |   14 +++++++++++---
 net/ipv4/fib_trie.c     |    7 +++++--
 net/ipv4/icmp.c         |    6 ++++++
 net/ipv4/route.c        |    3 ++-
 4 files changed, 24 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 9d4cef4..cf2d584 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -45,6 +45,7 @@
 #include <net/ip_fib.h>
 #include <net/rtnetlink.h>
 #include <net/xfrm.h>
+#include <net/vrf.h>
 
 #ifndef CONFIG_IP_MULTIPLE_TABLES
 
@@ -218,15 +219,18 @@ static inline unsigned int __inet_dev_addr_type(struct net *net,
 	struct fib_result	res;
 	unsigned int ret = RTN_BROADCAST;
 	struct fib_table *local_table;
+	int rt_table = RT_TABLE_LOCAL;
 
 	if (ipv4_is_zeronet(addr) || ipv4_is_lbcast(addr))
 		return RTN_BROADCAST;
 	if (ipv4_is_multicast(addr))
 		return RTN_MULTICAST;
 
-	rcu_read_lock();
+	if (dev && dev->vrf_ptr)
+		rt_table =  dev->vrf_ptr->tb_id;
 
-	local_table = fib_get_table(net, RT_TABLE_LOCAL);
+	rcu_read_lock();
+	local_table = fib_get_table(net, rt_table);
 	if (local_table) {
 		ret = RTN_UNICAST;
 		if (!fib_table_lookup(local_table, &fl4, &res, FIB_LOOKUP_NOREF)) {
@@ -309,7 +313,11 @@ static int __fib_validate_source(struct sk_buff *skb, __be32 src, __be32 dst,
 	bool dev_match;
 
 	fl4.flowi4_oif = 0;
-	fl4.flowi4_iif = oif ? : LOOPBACK_IFINDEX;
+	if (dev->vrf_ptr)
+		fl4.flowi4_iif = dev->vrf_ptr ?
+			dev->vrf_ptr->ifindex : dev->ifindex;
+	else
+		fl4.flowi4_iif = oif ? : LOOPBACK_IFINDEX;
 	fl4.daddr = src;
 	fl4.saddr = dst;
 	fl4.flowi4_tos = tos;
diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 97fa62d..515ff11 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -1409,8 +1409,11 @@ found:
 
 			if (nh->nh_flags & RTNH_F_DEAD)
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
index f5203fb..61b7da3 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -96,6 +96,7 @@
 #include <net/xfrm.h>
 #include <net/inet_common.h>
 #include <net/ip_fib.h>
+#include <net/vrf.h>
 
 /*
  *	Build xmit assembly blocks
@@ -420,6 +421,8 @@ static void icmp_reply(struct icmp_bxm *icmp_param, struct sk_buff *skb)
 			daddr = icmp_param->replyopts.opt.opt.faddr;
 	}
 	memset(&fl4, 0, sizeof(fl4));
+	if (skb->dev && skb->dev->vrf_ptr)
+		fl4.flowi4_oif = skb->dev->vrf_ptr->ifindex;
 	fl4.daddr = daddr;
 	fl4.saddr = saddr;
 	fl4.flowi4_mark = mark;
@@ -458,6 +461,9 @@ static struct rtable *icmp_route_lookup(struct net *net,
 	fl4->flowi4_proto = IPPROTO_ICMP;
 	fl4->fl4_icmp_type = type;
 	fl4->fl4_icmp_code = code;
+	if (skb_in->dev && skb_in->dev->vrf_ptr)
+		fl4->flowi4_oif =  skb_in->dev->vrf_ptr->ifindex;
+
 	security_skb_classify_flow(skb_in, flowi4_to_flowi(fl4));
 	rt = __ip_route_output_key(net, fl4);
 	if (IS_ERR(rt))
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index f605598..8c37720 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -109,6 +109,7 @@
 #include <linux/kmemleak.h>
 #endif
 #include <net/secure_seq.h>
+#include <net/vrf.h>
 
 #define RT_FL_TOS(oldflp4) \
 	((oldflp4)->flowi4_tos & (IPTOS_RT_MASK | RTO_ONLINK))
@@ -1710,7 +1711,7 @@ static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	 *	Now we are ready to route packet.
 	 */
 	fl4.flowi4_oif = 0;
-	fl4.flowi4_iif = dev->ifindex;
+	fl4.flowi4_iif = dev->vrf_ptr ? dev->vrf_ptr->ifindex : dev->ifindex;
 	fl4.flowi4_mark = skb->mark;
 	fl4.flowi4_tos = tos;
 	fl4.flowi4_scope = RT_SCOPE_UNIVERSE;
-- 
1.7.10.4
