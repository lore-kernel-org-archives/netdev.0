From: Pavel Roskin <proski@gnu.org>
Subject: [PATCH 3/5] orinoco: simplify locking, fix error handling in PCMCIA resume
Date: Mon, 01 May 2006 02:13:28 -0400
Message-ID: <20060501061328.13342.20411.stgit@dv.roinet.com>
References: <20060501061324.13342.58195.stgit@dv.roinet.com>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: 8bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from fencepost.gnu.org ([199.232.76.164]:57824 "EHLO
	fencepost.gnu.org") by vger.kernel.org with ESMTP id S1751277AbWEAGNa
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 May 2006 02:13:30 -0400
Received: from proski by fencepost.gnu.org with local (Exim 4.34)
	id 1FaRez-0007GD-FJ
	for netdev@vger.kernel.org; Mon, 01 May 2006 02:13:29 -0400
To: netdev@vger.kernel.org, linville@tuxdriver.com
In-Reply-To: <20060501061324.13342.58195.stgit@dv.roinet.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Roskin <proski@gnu.org>

Don't use flags in the spinlocks - the PCMCIA resume functions may not
be called under lock.  Don't ignore any errors.

Signed-off-by: Pavel Roskin <proski@gnu.org>
---

 drivers/net/wireless/orinoco_cs.c  |    7 +++----
 drivers/net/wireless/spectrum_cs.c |    7 +++----
 2 files changed, 6 insertions(+), 8 deletions(-)

diff --git a/drivers/net/wireless/orinoco_cs.c b/drivers/net/wireless/orinoco_cs.c
index 1c19c76..b2aec4d 100644
--- a/drivers/net/wireless/orinoco_cs.c
+++ b/drivers/net/wireless/orinoco_cs.c
@@ -415,7 +415,6 @@ static int orinoco_cs_resume(struct pcmc
 	struct orinoco_private *priv = netdev_priv(dev);
 	struct orinoco_pccard *card = priv->card;
 	int err = 0;
-	unsigned long flags;
 
 	if (! test_bit(0, &card->hard_reset_in_progress)) {
 		err = orinoco_reinit_firmware(dev);
@@ -425,7 +424,7 @@ static int orinoco_cs_resume(struct pcmc
 			return -EIO;
 		}
 
-		spin_lock_irqsave(&priv->lock, flags);
+		spin_lock(&priv->lock);
 
 		netif_device_attach(dev);
 		priv->hw_unavailable--;
@@ -437,10 +436,10 @@ static int orinoco_cs_resume(struct pcmc
 				       dev->name, err);
 		}
 
-		spin_unlock_irqrestore(&priv->lock, flags);
+		spin_unlock(&priv->lock);
 	}
 
-	return 0;
+	return err;
 }
 
 
diff --git a/drivers/net/wireless/spectrum_cs.c b/drivers/net/wireless/spectrum_cs.c
index e9172ee..7f9aa13 100644
--- a/drivers/net/wireless/spectrum_cs.c
+++ b/drivers/net/wireless/spectrum_cs.c
@@ -866,11 +866,10 @@ spectrum_cs_suspend(struct pcmcia_device
 {
 	struct net_device *dev = link->priv;
 	struct orinoco_private *priv = netdev_priv(dev);
-	unsigned long flags;
 	int err = 0;
 
 	/* Mark the device as stopped, to block IO until later */
-	spin_lock_irqsave(&priv->lock, flags);
+	spin_lock(&priv->lock);
 
 	err = __orinoco_down(dev);
 	if (err)
@@ -880,9 +879,9 @@ spectrum_cs_suspend(struct pcmcia_device
 	netif_device_detach(dev);
 	priv->hw_unavailable++;
 
-	spin_unlock_irqrestore(&priv->lock, flags);
+	spin_unlock(&priv->lock);
 
-	return 0;
+	return err;
 }
 
 static int

