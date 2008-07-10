From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 4/6] via-velocity: add velocity_set_rxbufsize helper
Date: Fri, 11 Jul 2008 00:05:57 +0200
Message-ID: <20080710220557.GE29764@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	=?unknown-8bit?B?U8OpZ3VpZXIgUsOpZ2lz?= <rseguier@e-teleport.net>,
	akpm@linux-foundation.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:33945 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752173AbYGJWGm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2008 18:06:42 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It removes a dependancy from velocity_init_rd_ring to dev->mtu.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/via-velocity.c |   12 +++++++++---
 1 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
index e6301a8..52d4a5b 100644
--- a/drivers/net/via-velocity.c
+++ b/drivers/net/via-velocity.c
@@ -1207,6 +1207,11 @@ static int velocity_rx_refill(struct velocity_info *vptr)
 	return done;
 }
 
+static void velocity_set_rxbufsize(struct velocity_info *vptr, int mtu)
+{
+	vptr->rx_buf_sz = (mtu <= ETH_DATA_LEN) ? PKT_BUF_SZ : mtu + 32;
+}
+
 /**
  *	velocity_init_rd_ring	-	set up receive ring
  *	@vptr: velocity to configure
@@ -1217,11 +1222,8 @@ static int velocity_rx_refill(struct velocity_info *vptr)
 
 static int velocity_init_rd_ring(struct velocity_info *vptr)
 {
-	int mtu = vptr->dev->mtu;
 	int ret = -ENOMEM;
 
-	vptr->rx_buf_sz = (mtu <= ETH_DATA_LEN) ? PKT_BUF_SZ : mtu + 32;
-
 	vptr->rd_info = kcalloc(vptr->options.numrx,
 				sizeof(struct velocity_rd_info), GFP_KERNEL);
 	if (!vptr->rd_info)
@@ -1871,6 +1873,8 @@ static int velocity_open(struct net_device *dev)
 	struct velocity_info *vptr = netdev_priv(dev);
 	int ret;
 
+	velocity_set_rxbufsize(vptr, dev->mtu);
+
 	ret = velocity_init_rings(vptr);
 	if (ret < 0)
 		goto out;
@@ -1952,6 +1956,8 @@ static int velocity_change_mtu(struct net_device *dev, int new_mtu)
 
 		dev->mtu = new_mtu;
 
+		velocity_set_rxbufsize(vptr, new_mtu);
+
 		ret = velocity_init_rd_ring(vptr);
 		if (ret < 0)
 			goto out_unlock;
-- 
1.5.3.3
