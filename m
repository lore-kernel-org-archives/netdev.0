From: Chris Lalancette <clalance@redhat.com>
Subject: [PATCH]: 8139cp: Don't blindly enable interrupts in cp_start_xmit
Date: Mon, 15 Jan 2007 11:40:09 -0500
Message-ID: <45ABAE69.4070105@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060302050304070601040204"
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:48636 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750981AbXAOQkO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Jan 2007 11:40:14 -0500
To: jgarzik@pobox.com, romieu@fr.zoreil.com
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------060302050304070601040204
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

(trying again, this time to the correct maintainer)

All,
     Similar to this commit:

http://kernel.org/git/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff;h=d15e9c4d9a75702b30e00cdf95c71c88e3f3f51e

It's not safe in cp_start_xmit to blindly call spin_lock_irq and then spin_unlock_irq, since it may very well be the case that cp_start_xmit was called with interrupts already disabled (I came across this bug in the context of netdump in RedHat kernels, but the same issue holds, for example, in netconsole).  Therefore, replace all instances of spin_lock_irq and spin_unlock_irq with spin_lock_irqsave and spin_unlock_irqrestore, respectively, in cp_start_xmit().  I tested this against a fully-virtualized Xen guest, which happens to use the 8139cp driver to talk to the emulated hardware.  I don't have a real piece of 8139cp hardware to test on, so someone else will have to do that.

Signed-off-by: Chris Lalancette <clalance@redhat.com>

--------------060302050304070601040204
Content-Type: text/x-patch;
 name="linux-2.6.20-rc3-8139cp-xmit-irq-save.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="linux-2.6.20-rc3-8139cp-xmit-irq-save.patch"

diff --git a/drivers/net/8139cp.c b/drivers/net/8139cp.c
index e2cb19b..6f93a76 100644
--- a/drivers/net/8139cp.c
+++ b/drivers/net/8139cp.c
@@ -765,17 +765,18 @@ static int cp_start_xmit (struct sk_buff *skb, struct net_device *dev)
 	struct cp_private *cp = netdev_priv(dev);
 	unsigned entry;
 	u32 eor, flags;
+	unsigned long intr_flags;
 #if CP_VLAN_TAG_USED
 	u32 vlan_tag = 0;
 #endif
 	int mss = 0;
 
-	spin_lock_irq(&cp->lock);
+	spin_lock_irqsave(&cp->lock, intr_flags);
 
 	/* This is a hard error, log it. */
 	if (TX_BUFFS_AVAIL(cp) <= (skb_shinfo(skb)->nr_frags + 1)) {
 		netif_stop_queue(dev);
-		spin_unlock_irq(&cp->lock);
+		spin_unlock_irqrestore(&cp->lock, intr_flags);
 		printk(KERN_ERR PFX "%s: BUG! Tx Ring full when queue awake!\n",
 		       dev->name);
 		return 1;
@@ -908,7 +909,7 @@ static int cp_start_xmit (struct sk_buff *skb, struct net_device *dev)
 	if (TX_BUFFS_AVAIL(cp) <= (MAX_SKB_FRAGS + 1))
 		netif_stop_queue(dev);
 
-	spin_unlock_irq(&cp->lock);
+	spin_unlock_irqrestore(&cp->lock, intr_flags);
 
 	cpw8(TxPoll, NormalTxPoll);
 	dev->trans_start = jiffies;



--------------060302050304070601040204--
