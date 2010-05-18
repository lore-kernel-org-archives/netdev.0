From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next] ipv6: fix the bug of address check
Date: Mon, 17 May 2010 18:02:21 -0700
Message-ID: <20100517180221.3a90ffcf@nehalam>
References: <4BF1354A.3060003@cn.fujitsu.com>
	<20100517103134.06160257@nehalam>
	<4BF1E45D.5000409@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Shan Wei <shanwei@cn.fujitsu.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:43643 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752565Ab0ERBCZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 May 2010 21:02:25 -0400
In-Reply-To: <4BF1E45D.5000409@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The duplicate address check code got broken in the conversion
to hlist (2.6.35).  The earlier patch did not fix the case where
two addresses match same hash value. Use two exit paths,
rather than depending on state of loop variables (from macro).

Based on earlier fix by Shan Wei.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
Reviewed-by: Shan Wei <shanwei@cn.fujitsu.com>

--- a/net/ipv6/addrconf.c	2010-05-17 10:27:58.218628126 -0700
+++ b/net/ipv6/addrconf.c	2010-05-17 10:29:46.012198338 -0700
@@ -1274,7 +1274,7 @@ static int ipv6_count_addresses(struct i
 int ipv6_chk_addr(struct net *net, struct in6_addr *addr,
 		  struct net_device *dev, int strict)
 {
-	struct inet6_ifaddr *ifp = NULL;
+	struct inet6_ifaddr *ifp;
 	struct hlist_node *node;
 	unsigned int hash = ipv6_addr_hash(addr);
 
@@ -1283,15 +1283,16 @@ int ipv6_chk_addr(struct net *net, struc
 		if (!net_eq(dev_net(ifp->idev->dev), net))
 			continue;
 		if (ipv6_addr_equal(&ifp->addr, addr) &&
-		    !(ifp->flags&IFA_F_TENTATIVE)) {
-			if (dev == NULL || ifp->idev->dev == dev ||
-			    !(ifp->scope&(IFA_LINK|IFA_HOST) || strict))
-				break;
+		    !(ifp->flags&IFA_F_TENTATIVE) &&
+		    (dev == NULL || ifp->idev->dev == dev ||
+		     !(ifp->scope&(IFA_LINK|IFA_HOST) || strict))) {
+			rcu_read_unlock_bh();
+			return 1;
 		}
 	}
-	rcu_read_unlock_bh();
 
-	return ifp != NULL;
+	rcu_read_unlock_bh();
+	return 0;
 }
 EXPORT_SYMBOL(ipv6_chk_addr);
 
