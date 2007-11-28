From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH] via-velocity: don't oops on MTU change (resend)
Date: Wed, 28 Nov 2007 14:20:16 -0800
Message-ID: <20071128142016.0eecbd2c@freepuppy.rosehill>
References: <20071114193844.0cab5c7d@freepuppy.rosehill>
	<20071115082600.GA2366@ff.dom.local>
	<20071115102005.0cf46f9a@freepuppy.rosehill>
	<473CD1F6.9030709@o2.pl>
	<cccedfc60711151842l4aafe0ffo220e84a5e37b6a82@mail.gmail.com>
	<20071115203508.4ad025f2@freepuppy.rosehill>
	<cccedfc60711281402m397a37d2mda83645211633202@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Jon Nelson" <jnelson@jamponi.net>,
	"Jarek Poplawski" <jarkao2@o2.pl>, netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:58014 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756944AbXK1WVy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Nov 2007 17:21:54 -0500
In-Reply-To: <cccedfc60711281402m397a37d2mda83645211633202@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The VIA veloicty driver needs the following to allow changing MTU when down.
The buffer size needs to be computed when device is brought up, not when
device is initialized.  This also fixes a bug where the buffer size was
computed differently on change_mtu versus initial setting.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

---
This is a properly formatted version of previously submitted patch.
Please apply for 2.6.24

--- a/drivers/net/via-velocity.c	2007-11-15 20:11:12.000000000 -0800
+++ b/drivers/net/via-velocity.c	2007-11-15 20:32:14.000000000 -0800
@@ -1242,6 +1242,9 @@ static int velocity_rx_refill(struct vel
 static int velocity_init_rd_ring(struct velocity_info *vptr)
 {
 	int ret;
+	int mtu = vptr->dev->mtu;
+
+	vptr->rx_buf_sz = (mtu <= ETH_DATA_LEN) ? PKT_BUF_SZ : mtu + 32;
 
 	vptr->rd_info = kcalloc(vptr->options.numrx,
 				sizeof(struct velocity_rd_info), GFP_KERNEL);
@@ -1898,8 +1901,6 @@ static int velocity_open(struct net_devi
 	struct velocity_info *vptr = netdev_priv(dev);
 	int ret;
 
-	vptr->rx_buf_sz = (dev->mtu <= 1504 ? PKT_BUF_SZ : dev->mtu + 32);
-
 	ret = velocity_init_rings(vptr);
 	if (ret < 0)
 		goto out;
@@ -1978,12 +1979,6 @@ static int velocity_change_mtu(struct ne
 		velocity_free_rd_ring(vptr);
 
 		dev->mtu = new_mtu;
-		if (new_mtu > 8192)
-			vptr->rx_buf_sz = 9 * 1024;
-		else if (new_mtu > 4096)
-			vptr->rx_buf_sz = 8192;
-		else
-			vptr->rx_buf_sz = 4 * 1024;
 
 		ret = velocity_init_rd_ring(vptr);
 		if (ret < 0)
