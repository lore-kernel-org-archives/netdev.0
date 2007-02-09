From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: [PATCH] bcm43xx: Fix loss of association after resume
Date: Fri, 09 Feb 2007 10:18:03 -0600
Message-ID: <45cc9ebb.+9O/IXvs/C9RyFnk%Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
To: John Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/bcm43xx-dev>
List-Post: <mailto:bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

After a suspend/resume cycle, bcm43xx-softmac has lost its association with
the AP and requires manual intervention. This situation is fixed by making
one of softmac's internal routines public and calling it.

Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
---


Index: linux-2.6/drivers/net/wireless/bcm43xx/bcm43xx_main.c
===================================================================
--- linux-2.6.orig/drivers/net/wireless/bcm43xx/bcm43xx_main.c
+++ linux-2.6/drivers/net/wireless/bcm43xx/bcm43xx_main.c
@@ -4278,6 +4278,7 @@ static int bcm43xx_resume(struct pci_dev
 {
 	struct net_device *net_dev = pci_get_drvdata(pdev);
 	struct bcm43xx_private *bcm = bcm43xx_priv(net_dev);
+	struct ieee80211softmac_device *mac = ieee80211_priv(net_dev);
 	int err = 0;
 
 	dprintk(KERN_INFO PFX "Resuming...\n");
@@ -4299,6 +4300,9 @@ static int bcm43xx_resume(struct pci_dev
 	}
 	netif_device_attach(net_dev);
 
+	if (mac->associnfo.associated)
+		ieee80211softmac_try_reassoc(mac);
+
 	dprintk(KERN_INFO PFX "Device resumed.\n");
 
 	return 0;
Index: linux-2.6/include/net/ieee80211softmac.h
===================================================================
--- linux-2.6.orig/include/net/ieee80211softmac.h
+++ linux-2.6/include/net/ieee80211softmac.h
@@ -254,6 +254,7 @@ struct ieee80211softmac_device {
 };
 
 extern void ieee80211softmac_scan_finished(struct ieee80211softmac_device *sm);
+extern void ieee80211softmac_try_reassoc(struct ieee80211softmac_device *mac);
 
 static inline void * ieee80211softmac_priv(struct net_device *dev)
 {
Index: linux-2.6/net/ieee80211/softmac/ieee80211softmac_assoc.c
===================================================================
--- linux-2.6.orig/net/ieee80211/softmac/ieee80211softmac_assoc.c
+++ linux-2.6/net/ieee80211/softmac/ieee80211softmac_assoc.c
@@ -441,6 +441,7 @@ ieee80211softmac_try_reassoc(struct ieee
 	schedule_delayed_work(&mac->associnfo.work, 0);
 	spin_unlock_irqrestore(&mac->lock, flags);
 }
+EXPORT_SYMBOL_GPL(ieee80211softmac_try_reassoc);
 
 int
 ieee80211softmac_handle_disassoc(struct net_device * dev,
