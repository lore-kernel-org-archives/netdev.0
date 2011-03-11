From: David Miller <davem@davemloft.net>
Subject: [PATCH] ipv4: Remove redundant RCU locking in ip_check_mc().
Date: Thu, 10 Mar 2011 16:43:49 -0800 (PST)
Message-ID: <20110310.164349.246513447.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50553
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752732Ab1CKAnL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Mar 2011 19:43:11 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 8D03B24C08B
	for <netdev@vger.kernel.org>; Thu, 10 Mar 2011 16:43:49 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


All callers are under rcu_read_lock() protection already.

Rename to ip_check_mc_rcu() to make it even more clear.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/linux/igmp.h |    2 +-
 net/ipv4/igmp.c      |    5 ++---
 net/ipv4/route.c     |    8 ++++----
 3 files changed, 7 insertions(+), 8 deletions(-)

diff --git a/include/linux/igmp.h b/include/linux/igmp.h
index 74cfcff..82de336 100644
--- a/include/linux/igmp.h
+++ b/include/linux/igmp.h
@@ -217,7 +217,7 @@ struct ip_mc_list {
 #define IGMPV3_QQIC(value) IGMPV3_EXP(0x80, 4, 3, value)
 #define IGMPV3_MRC(value) IGMPV3_EXP(0x80, 4, 3, value)
 
-extern int ip_check_mc(struct in_device *dev, __be32 mc_addr, __be32 src_addr, u16 proto);
+extern int ip_check_mc_rcu(struct in_device *dev, __be32 mc_addr, __be32 src_addr, u16 proto);
 extern int igmp_rcv(struct sk_buff *);
 extern int ip_mc_join_group(struct sock *sk, struct ip_mreqn *imr);
 extern int ip_mc_leave_group(struct sock *sk, struct ip_mreqn *imr);
diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index 44ba906..12b65cc 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -2333,13 +2333,13 @@ void ip_mc_drop_socket(struct sock *sk)
 	rtnl_unlock();
 }
 
-int ip_check_mc(struct in_device *in_dev, __be32 mc_addr, __be32 src_addr, u16 proto)
+/* called with rcu_read_lock() */
+int ip_check_mc_rcu(struct in_device *in_dev, __be32 mc_addr, __be32 src_addr, u16 proto)
 {
 	struct ip_mc_list *im;
 	struct ip_sf_list *psf;
 	int rv = 0;
 
-	rcu_read_lock();
 	for_each_pmc_rcu(in_dev, im) {
 		if (im->multiaddr == mc_addr)
 			break;
@@ -2361,7 +2361,6 @@ int ip_check_mc(struct in_device *in_dev, __be32 mc_addr, __be32 src_addr, u16 p
 		} else
 			rv = 1; /* unspecified source; tentatively allow */
 	}
-	rcu_read_unlock();
 	return rv;
 }
 
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index ac32d8f..f6730d9 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2309,8 +2309,8 @@ skip_cache:
 		struct in_device *in_dev = __in_dev_get_rcu(dev);
 
 		if (in_dev) {
-			int our = ip_check_mc(in_dev, daddr, saddr,
-					      ip_hdr(skb)->protocol);
+			int our = ip_check_mc_rcu(in_dev, daddr, saddr,
+						  ip_hdr(skb)->protocol);
 			if (our
 #ifdef CONFIG_IP_MROUTE
 				||
@@ -2368,8 +2368,8 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
 		fi = NULL;
 	} else if (type == RTN_MULTICAST) {
 		flags |= RTCF_MULTICAST | RTCF_LOCAL;
-		if (!ip_check_mc(in_dev, oldflp->fl4_dst, oldflp->fl4_src,
-				 oldflp->proto))
+		if (!ip_check_mc_rcu(in_dev, oldflp->fl4_dst, oldflp->fl4_src,
+				     oldflp->proto))
 			flags &= ~RTCF_LOCAL;
 		/* If multicast route do not exist use
 		 * default one, but do not gateway in this case.
-- 
1.7.4.1

