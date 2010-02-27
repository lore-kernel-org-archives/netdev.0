From: Jeff Garzik <jeff@garzik.org>
Subject: [PATCH] ethtool: do not set some flags, if others failed
Date: Sat, 27 Feb 2010 02:43:38 -0500
Message-ID: <20100227074338.GA17322@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:52445 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S967832Ab0B0Hni (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 27 Feb 2010 02:43:38 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


NETIF_F_NTUPLE flag setting introduced a bug:  non-ntuple flags
like LRO may be successfully set, before ioctl(2) returns failure
to userspace.

The set-flags operation should be all-or-none, rather than leaving
things in an inconsistent state prior to reporting failure to
userspace.

Signed-off-by: Jeff Garzik <jgarzik@redhat.com>
---
 net/core/ethtool.c |   10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 31b1edd..0f2f821 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -135,21 +135,23 @@ u32 ethtool_op_get_flags(struct net_device *dev)
 int ethtool_op_set_flags(struct net_device *dev, u32 data)
 {
 	const struct ethtool_ops *ops = dev->ethtool_ops;
+	unsigned long features = dev->features;
 
 	if (data & ETH_FLAG_LRO)
-		dev->features |= NETIF_F_LRO;
+		features |= NETIF_F_LRO;
 	else
-		dev->features &= ~NETIF_F_LRO;
+		features &= ~NETIF_F_LRO;
 
 	if (data & ETH_FLAG_NTUPLE) {
 		if (!ops->set_rx_ntuple)
 			return -EOPNOTSUPP;
-		dev->features |= NETIF_F_NTUPLE;
+		features |= NETIF_F_NTUPLE;
 	} else {
 		/* safe to clear regardless */
-		dev->features &= ~NETIF_F_NTUPLE;
+		features &= ~NETIF_F_NTUPLE;
 	}
 
+	dev->features = features;
 	return 0;
 }
 
