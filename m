From: Vishwanath Pai <vpai@akamai.com>
Subject: [PATCH net-next] net: display hw address of source machine during ipv6 DAD failure
Date: Mon, 30 Oct 2017 16:29:40 -0400
Message-ID: <1509395380-28057-1-git-send-email-vpai@akamai.com>
Cc: netdev@vger.kernel.org, ilubashe@akamai.com, pai.vishwain@gmail.com
To: yoshfuji@linux-ipv6.org, kuznet@ms2.inr.ac.ru, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00190b01.pphosted.com ([67.231.149.131]:37412 "EHLO
        mx0a-00190b01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751827AbdJ3UaO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Oct 2017 16:30:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch updates the error messages displayed in kernel log to include
hwaddress of the source machine that caused ipv6 duplicate address
detection failures.

Examples:

a) When we receive a NA packet from another machine advertising our
address:

ICMPv6: NA: 34:ab:cd:56:11:e8 advertised our address 2601::2bb4 on eth0!

b) When we detect DAD failure during address assignment to an interface:

IPv6: eth0: IPv6 duplicate address 2601::2b78 used by 34:ab:cd:56:11:e8
detected!

Suggested-by: Igor Lubashev <ilubashe@akamai.com>
Signed-off-by: Vishwanath Pai <vpai@akamai.com>
---
 include/net/addrconf.h | 2 +-
 net/ipv6/addrconf.c    | 6 +++---
 net/ipv6/ndisc.c       | 9 +++++----
 3 files changed, 9 insertions(+), 8 deletions(-)

diff --git a/include/net/addrconf.h b/include/net/addrconf.h
index 15b5ffd..2a616ea 100644
--- a/include/net/addrconf.h
+++ b/include/net/addrconf.h
@@ -208,7 +208,7 @@ bool inet6_mc_check(struct sock *sk, const struct in6_addr *mc_addr,
 void ipv6_mc_init_dev(struct inet6_dev *idev);
 void ipv6_mc_destroy_dev(struct inet6_dev *idev);
 int ipv6_mc_check_mld(struct sk_buff *skb, struct sk_buff **skb_trimmed);
-void addrconf_dad_failure(struct inet6_ifaddr *ifp);
+void addrconf_dad_failure(struct sk_buff *skb, struct inet6_ifaddr *ifp);
 
 bool ipv6_chk_mcast_addr(struct net_device *dev, const struct in6_addr *group,
 			 const struct in6_addr *src_addr);
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 5a8a102..cfa374c 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -1987,7 +1987,7 @@ static int addrconf_dad_end(struct inet6_ifaddr *ifp)
 	return err;
 }
 
-void addrconf_dad_failure(struct inet6_ifaddr *ifp)
+void addrconf_dad_failure(struct sk_buff *skb, struct inet6_ifaddr *ifp)
 {
 	struct inet6_dev *idev = ifp->idev;
 	struct net *net = dev_net(ifp->idev->dev);
@@ -1997,8 +1997,8 @@ void addrconf_dad_failure(struct inet6_ifaddr *ifp)
 		return;
 	}
 
-	net_info_ratelimited("%s: IPv6 duplicate address %pI6c detected!\n",
-			     ifp->idev->dev->name, &ifp->addr);
+	net_info_ratelimited("%s: IPv6 duplicate address %pI6c used by %pM detected!\n",
+			     ifp->idev->dev->name, &ifp->addr, eth_hdr(skb)->h_source);
 
 	spin_lock_bh(&ifp->lock);
 
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 266a530..9d6ea9d 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -46,6 +46,7 @@
 #endif
 
 #include <linux/if_addr.h>
+#include <linux/if_ether.h>
 #include <linux/if_arp.h>
 #include <linux/ipv6.h>
 #include <linux/icmpv6.h>
@@ -822,7 +823,7 @@ static void ndisc_recv_ns(struct sk_buff *skb)
 				 * who is doing DAD
 				 * so fail our DAD process
 				 */
-				addrconf_dad_failure(ifp);
+				addrconf_dad_failure(skb, ifp);
 				return;
 			} else {
 				/*
@@ -975,7 +976,7 @@ static void ndisc_recv_na(struct sk_buff *skb)
 	if (ifp) {
 		if (skb->pkt_type != PACKET_LOOPBACK
 		    && (ifp->flags & IFA_F_TENTATIVE)) {
-				addrconf_dad_failure(ifp);
+				addrconf_dad_failure(skb, ifp);
 				return;
 		}
 		/* What should we make now? The advertisement
@@ -989,8 +990,8 @@ static void ndisc_recv_na(struct sk_buff *skb)
 		 */
 		if (skb->pkt_type != PACKET_LOOPBACK)
 			ND_PRINTK(1, warn,
-				  "NA: someone advertises our address %pI6 on %s!\n",
-				  &ifp->addr, ifp->idev->dev->name);
+				  "NA: %pM advertised our address %pI6 on %s!\n",
+				  eth_hdr(skb)->h_source, &ifp->addr, ifp->idev->dev->name);
 		in6_ifa_put(ifp);
 		return;
 	}
-- 
1.9.1
