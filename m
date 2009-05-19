From: Brice Goglin <brice@myri.com>
Subject: [PATCH 1/2] myri10ge: allow LRO to be enabled via ethtool
Date: Tue, 19 May 2009 22:15:32 +0200
Message-ID: <4A131364.5050402@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Network Development list <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1852 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753443AbZESUPZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 May 2009 16:15:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow myri10ge LRO to be enabled/disabled via ethtool
(and by the stack for packet forwarding).

Signed-off-by: Brice Goglin <brice@myri.com>

--- net-next-2.6/drivers/net/myri10ge/myri10ge.c	2009-04-18 12:25:35.000000000 +0200
+++ linux-tmp/drivers/net/myri10ge/myri10ge.c	2009-05-19 22:02:12.000000000 +0200
@@ -1300,7 +1300,7 @@
 		remainder -= MYRI10GE_ALLOC_SIZE;
 	}
 
-	if (mgp->csum_flag && myri10ge_lro) {
+	if (dev->features & NETIF_F_LRO) {
 		rx_frags[0].page_offset += MXGEFW_PAD;
 		rx_frags[0].size -= MXGEFW_PAD;
 		len -= MXGEFW_PAD;
@@ -1716,12 +1716,17 @@
 static int myri10ge_set_rx_csum(struct net_device *netdev, u32 csum_enabled)
 {
 	struct myri10ge_priv *mgp = netdev_priv(netdev);
+	int err = 0;
 
 	if (csum_enabled)
 		mgp->csum_flag = MXGEFW_FLAGS_CKSUM;
-	else
+	else {
+		u32 flags = ethtool_op_get_flags(netdev);
+		err = ethtool_op_set_flags(netdev, (flags & ~ETH_FLAG_LRO));
 		mgp->csum_flag = 0;
-	return 0;
+
+	}
+	return err;
 }
 
 static int myri10ge_set_tso(struct net_device *netdev, u32 tso_enabled)
@@ -1904,7 +1909,9 @@
 	.get_sset_count = myri10ge_get_sset_count,
 	.get_ethtool_stats = myri10ge_get_ethtool_stats,
 	.set_msglevel = myri10ge_set_msglevel,
-	.get_msglevel = myri10ge_get_msglevel
+	.get_msglevel = myri10ge_get_msglevel,
+	.get_flags = ethtool_op_get_flags,
+	.set_flags = ethtool_op_set_flags
 };
 
 static int myri10ge_allocate_rings(struct myri10ge_slice_state *ss)
@@ -3910,6 +3917,8 @@
 
 	if (dac_enabled)
 		netdev->features |= NETIF_F_HIGHDMA;
+	if (myri10ge_lro)
+		netdev->features |= NETIF_F_LRO;
 
 	/* make sure we can get an irq, and that MSI can be
 	 * setup (if available).  Also ensure netdev->irq


