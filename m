From: Ian Campbell <icampbell@arcom.com>
Subject: Re: "deadlock" between smc91x driver and link_watch
Date: Wed, 24 Nov 2004 09:58:16 +0000
Message-ID: <1101290297.10841.15.camel@icampbell-debian>
References: <1101230194.14370.12.camel@icampbell-debian>
	 <20041123153158.6f20a7d7.akpm@osdl.org>
	 <1101289309.10841.9.camel@icampbell-debian>
	 <20041124014650.47af8ae4.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Nicolas Pitre <nico@cam.org>, linux-kernel@vger.kernel.org,
	netdev@oss.sgi.com
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S262572AbUKXJ6d@vger.kernel.org>
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20041124014650.47af8ae4.akpm@osdl.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2004-11-24 at 01:46 -0800, Andrew Morton wrote:
> Ian Campbell <icampbell@arcom.com> wrote:
> >
> >  On Tue, 2004-11-23 at 15:31 -0800, Andrew Morton wrote:
> >  > One possible fix would be to remove that flush_scheduled_work() and to do
> >  > refcounting around smc_phy_configure(): dev_hold() when scheduling the work
> >  > (if schedule_work() returned true), dev_put() in the handler.
> > 
> >  Something like the following?
> 
> I think so.
> 
> >  +static void smc_phy_configure_wq(void *data)
> >  +{
> >  +	struct net_device *dev = data;
> >  +	dev_put(dev);
> >  +	smc_phy_configure(data);
> >  +}
> 
> You'd want to do the dev_put() after the smc_phy_configure() though.  It
> may still be a tiny bit racy against module unload.

Quite right. Fixed patch included.

Signed-off-by: Ian Campbell <icampbell@arcom.com>

Index: 2.6/drivers/net/smc91x.c
===================================================================
--- 2.6.orig/drivers/net/smc91x.c	2004-11-16 09:26:52.000000000 +0000
+++ 2.6/drivers/net/smc91x.c	2004-11-24 09:53:54.397248397 +0000
@@ -1158,6 +1158,20 @@
 }
 
 /*
+ * smc_phy_configure_wq
+ *
+ * The net_device is referenced when the work was scheduled to avoid
+ * the need for a flush_scheduled_work() in smc_close(). Drop the
+ * reference and then do the configuration.
+ */
+static void smc_phy_configure_wq(void *data)
+{
+	struct net_device *dev = data;
+	smc_phy_configure(data);
+	dev_put(dev);
+}
+
+/*
  * smc_phy_interrupt
  *
  * Purpose:  Handle interrupts relating to PHY register 18. This is
@@ -1350,10 +1364,13 @@
 	/*
 	 * Reconfiguring the PHY doesn't seem like a bad idea here, but
 	 * smc_phy_configure() calls msleep() which calls schedule_timeout()
-	 * which calls schedule().  Ence we use a work queue.
+	 * which calls schedule().  Hence we use a work queue.
 	 */
-	if (lp->phy_type != 0)
-		schedule_work(&lp->phy_configure);
+	if (lp->phy_type != 0) {
+		if (schedule_work(&lp->phy_configure)) {
+			dev_hold(dev);
+		}
+	}
 
 	/* We can accept TX packets again */
 	dev->trans_start = jiffies;
@@ -1536,10 +1553,8 @@
 	/* clear everything */
 	smc_shutdown(dev);
 
-	if (lp->phy_type != 0) {
-		flush_scheduled_work();
+	if (lp->phy_type != 0)
 		smc_phy_powerdown(dev, lp->mii.phy_id);
-	}
 
 	if (lp->pending_tx_skb) {
 		dev_kfree_skb(lp->pending_tx_skb);
@@ -1891,7 +1906,7 @@
 	dev->ethtool_ops = &smc_ethtool_ops;
 
 	tasklet_init(&lp->tx_task, smc_hardware_send_pkt, (unsigned long)dev);
-	INIT_WORK(&lp->phy_configure, smc_phy_configure, dev);
+	INIT_WORK(&lp->phy_configure, smc_phy_configure_wq, dev);
 	lp->mii.phy_id_mask = 0x1f;
 	lp->mii.reg_num_mask = 0x1f;
 	lp->mii.force_media = 0;


-- 
Ian Campbell, Senior Design Engineer
                                        Web: http://www.arcom.com
Arcom, Clifton Road,                    Direct: +44 (0)1223 403 465
Cambridge CB1 7EA, United Kingdom       Phone:  +44 (0)1223 411 200
