From: Dan Williams <dcbw@redhat.com>
Subject: R[PATCH 2.6.10-rc1 8/15] wireless/orinoco: Refactor spinlocks so
	we don't necessarily have to disable interrupts
Date: Tue, 26 Oct 2004 15:04:32 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1098817472.3663.66.camel@dcbw.boston.redhat.com>
References: <1098814320.3663.24.camel@dcbw.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jgarzik@redhat.com, hermes@gibson.dropbear.id.au
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <1098814320.3663.24.camel@dcbw.boston.redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Update in-kernel orinoco wireless drivers to upstream CVS.
None of this is original code by Dan Williams, simply a
broken down patch set split-out from upstream orinoco CVS.

o Refactor spinlocks so we don't necessarily have to disable interrupts

Signed-off-by: Dan Williams <dcbw@redhat.com>

--- a/drivers/net/wireless/orinoco.h.8-orinoco-spinlock	2004-10-26 10:44:41.445687264 -0400
+++ b/drivers/net/wireless/orinoco.h	2004-10-26 10:45:39.296892544 -0400
@@ -71,6 +71,8 @@
 	u16 channel_mask;
 	int broken_disableport;
 
+	unsigned int irq_no_disable:1;
+
 	/* Configuration paramaters */
 	u32 iw_mode;
 	int prefer_port3;
@@ -129,11 +131,17 @@
 extern inline int orinoco_lock(struct orinoco_private *priv,
 			       unsigned long *flags)
 {
-	spin_lock_irqsave(&priv->lock, *flags);
+	if (priv->irq_no_disable)
+		spin_lock_bh(&priv->lock);
+	else
+		spin_lock_irqsave(&priv->lock, *flags);
 	if (priv->hw_unavailable) {
-		printk(KERN_DEBUG "orinoco_lock() called with hw_unavailable (dev=%p)\n",
+		DEBUG(1, "orinoco_lock() called with hw_unavailable (dev=%p)\n",
 		       priv->ndev);
-		spin_unlock_irqrestore(&priv->lock, *flags);
+		if (priv->irq_no_disable)
+			spin_unlock_bh(&priv->lock);
+		else
+			spin_unlock_irqrestore(&priv->lock, *flags);
 		return -EBUSY;
 	}
 	return 0;
@@ -142,7 +150,27 @@
 extern inline void orinoco_unlock(struct orinoco_private *priv,
 				  unsigned long *flags)
 {
-	spin_unlock_irqrestore(&priv->lock, *flags);
+	if (priv->irq_no_disable)
+		spin_unlock_bh(&priv->lock);
+	else
+		spin_unlock_irqrestore(&priv->lock, *flags);
+}
+
+extern inline void orinoco_spin_lock(struct orinoco_private *priv)
+{
+	if (priv->irq_no_disable)
+		spin_lock_bh(&priv->lock);
+	else
+		spin_lock_irq(&priv->lock);
 }
 
+extern inline void orinoco_spin_unlock(struct orinoco_private *priv)
+{
+	if (priv->irq_no_disable)
+		spin_unlock_bh(&priv->lock);
+	else
+		spin_unlock_irq(&priv->lock);
+}
+
+
 #endif /* _ORINOCO_H */
--- a/drivers/net/wireless/orinoco.c.8-orinoco-spinlock	2004-10-26 10:44:41.444687416 -0400
+++ b/drivers/net/wireless/orinoco.c	2004-10-26 10:45:39.301891784 -0400
@@ -699,13 +699,13 @@
 	/* We mustn't use orinoco_lock() here, because we need to be
 	   able to close the interface even if hw_unavailable is set
 	   (e.g. as we're released after a PC Card removal) */
-	spin_lock_irq(&priv->lock);
+	orinoco_spin_lock(priv);
 
 	priv->open = 0;
 
 	err = __orinoco_down(dev);
 
-	spin_unlock_irq(&priv->lock);
+	orinoco_spin_unlock(priv);
 
 	return err;
 }
@@ -1966,7 +1966,7 @@
 		return;
 	}
 
-	spin_lock_irq(&priv->lock); /* This has to be called from user context */
+	orinoco_spin_lock(priv); /* This has to be called from user context */
 
 	priv->hw_unavailable--;
 
@@ -1981,7 +1981,7 @@
 			dev->trans_start = jiffies;
 	}
 
-	spin_unlock_irq(&priv->lock);
+	orinoco_spin_unlock(priv);
 
 	return;
 }
@@ -2404,9 +2404,9 @@
 
 	/* Make the hardware available, as long as it hasn't been
 	 * removed elsewhere (e.g. by PCMCIA hot unplug) */
-	spin_lock_irq(&priv->lock);
+	orinoco_spin_lock(priv);
 	priv->hw_unavailable--;
-	spin_unlock_irq(&priv->lock);
+	orinoco_spin_unlock(priv);
 
 	printk(KERN_DEBUG "%s: ready\n", dev->name);
 
--- ./orinoco_cs.c.8-orinoco-spinlock	2004-10-26 10:44:41.440688024 -0400
+++ ./orinoco_cs.c	2004-10-26 10:45:39.303891480 -0400
@@ -513,12 +513,12 @@
 	case CS_EVENT_CARD_REMOVAL:
 		link->state &= ~DEV_PRESENT;
 		if (link->state & DEV_CONFIG) {
-			orinoco_lock(priv, &flags);
+			unsigned long flags;
 
+			spin_lock_irqsave(&priv->lock, flags);
 			netif_device_detach(dev);
 			priv->hw_unavailable++;
-
-			orinoco_unlock(priv, &flags);
+			spin_unlock_irqrestore(&priv->lock, flags);
 		}
 		break;
 
