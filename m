From: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Subject: [PATCH 48/58] net: usb: Convert timers to use timer_setup()
Date: Mon, 16 Oct 2017 17:29:32 -0700
Message-ID: <1508200182-104605-49-git-send-email-keescook@chromium.org>
References: <1508200182-104605-1-git-send-email-keescook@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
        Woojung Huh <woojung.huh-UWL1GkI3JZL3oGB3hsPCZA@public.gmane.org>,
        Microchip Linux Driver Support <UNGLinuxDriver-UWL1GkI3JZL3oGB3hsPCZA@public.gmane.org>,
        Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>,
        Philippe Reynes <tremyfr-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Jarod Wilson <jarod-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Arvind Yadav <arvind.yadav.cs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>,
        =?UTF-8?q?Stefan=20Br=C3=BCns?= <stefan.bruens-vA1bhqPz9FBZXbeN9DUtxg@public.gmane.org>,
        Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Greg Ungerer <gerg-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org>, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1508200182-104605-1-git-send-email-keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

In preparation for unconditionally passing the struct timer_list pointer to
all timer callbacks, switch to using the new timer_setup() and from_timer()
to pass the timer pointer explicitly.

Cc: Woojung Huh <woojung.huh-UWL1GkI3JZL3oGB3hsPCZA@public.gmane.org>
Cc: Microchip Linux Driver Support <UNGLinuxDriver-UWL1GkI3JZL3oGB3hsPCZA@public.gmane.org>
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Cc: Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>
Cc: Philippe Reynes <tremyfr-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Jarod Wilson <jarod-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Arvind Yadav <arvind.yadav.cs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: "Bjørn Mork" <bjorn-yOkvZcmFvRU@public.gmane.org>
Cc: "Stefan Brüns" <stefan.bruens-vA1bhqPz9FBZXbeN9DUtxg@public.gmane.org>
Cc: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Greg Ungerer <gerg-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org>
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Signed-off-by: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
---
 drivers/net/usb/catc.c       |  6 +++---
 drivers/net/usb/lan78xx.c    | 10 +++-------
 drivers/net/usb/sierra_net.c | 12 ++++--------
 3 files changed, 10 insertions(+), 18 deletions(-)

diff --git a/drivers/net/usb/catc.c b/drivers/net/usb/catc.c
index aeb62e17d19d..18d36dff97ea 100644
--- a/drivers/net/usb/catc.c
+++ b/drivers/net/usb/catc.c
@@ -611,9 +611,9 @@ static void catc_stats_done(struct catc *catc, struct ctrl_queue *q)
 	catc->stats_vals[index >> 1] = data;
 }
 
-static void catc_stats_timer(unsigned long data)
+static void catc_stats_timer(struct timer_list *t)
 {
-	struct catc *catc = (void *) data;
+	struct catc *catc = from_timer(catc, t, timer);
 	int i;
 
 	for (i = 0; i < 8; i++)
@@ -805,7 +805,7 @@ static int catc_probe(struct usb_interface *intf, const struct usb_device_id *id
 	spin_lock_init(&catc->tx_lock);
 	spin_lock_init(&catc->ctrl_lock);
 
-	setup_timer(&catc->timer, catc_stats_timer, (long)catc);
+	timer_setup(&catc->timer, catc_stats_timer, 0);
 
 	catc->ctrl_urb = usb_alloc_urb(0, GFP_KERNEL);
 	catc->tx_urb = usb_alloc_urb(0, GFP_KERNEL);
diff --git a/drivers/net/usb/lan78xx.c b/drivers/net/usb/lan78xx.c
index 0161f77641fa..94c7804903c4 100644
--- a/drivers/net/usb/lan78xx.c
+++ b/drivers/net/usb/lan78xx.c
@@ -3516,11 +3516,9 @@ static const struct net_device_ops lan78xx_netdev_ops = {
 	.ndo_vlan_rx_kill_vid	= lan78xx_vlan_rx_kill_vid,
 };
 
-static void lan78xx_stat_monitor(unsigned long param)
+static void lan78xx_stat_monitor(struct timer_list *t)
 {
-	struct lan78xx_net *dev;
-
-	dev = (struct lan78xx_net *)param;
+	struct lan78xx_net *dev = from_timer(dev, t, stat_monitor);
 
 	lan78xx_defer_kevent(dev, EVENT_STAT_UPDATE);
 }
@@ -3571,10 +3569,8 @@ static int lan78xx_probe(struct usb_interface *intf,
 	netdev->watchdog_timeo = TX_TIMEOUT_JIFFIES;
 	netdev->ethtool_ops = &lan78xx_ethtool_ops;
 
-	dev->stat_monitor.function = lan78xx_stat_monitor;
-	dev->stat_monitor.data = (unsigned long)dev;
 	dev->delta = 1;
-	init_timer(&dev->stat_monitor);
+	timer_setup(&dev->stat_monitor, lan78xx_stat_monitor, 0);
 
 	mutex_init(&dev->stats.access_lock);
 
diff --git a/drivers/net/usb/sierra_net.c b/drivers/net/usb/sierra_net.c
index 2110ab3513f0..c43087e06696 100644
--- a/drivers/net/usb/sierra_net.c
+++ b/drivers/net/usb/sierra_net.c
@@ -189,9 +189,6 @@ struct lsi_umts_dual {
 #define SIERRA_NET_LSI_UMTS_DS_STATUS_LEN \
 	(SIERRA_NET_LSI_UMTS_DS_LEN - SIERRA_NET_LSI_COMMON_LEN)
 
-/* Forward definitions */
-static void sierra_sync_timer(unsigned long syncdata);
-
 /* Our own net device operations structure */
 static const struct net_device_ops sierra_net_device_ops = {
 	.ndo_open               = usbnet_open,
@@ -475,8 +472,6 @@ static void sierra_net_dosync(struct usbnet *dev)
 			"Send SYNC failed, status %d\n", status);
 
 	/* Now, start a timer and make sure we get the Restart Indication */
-	priv->sync_timer.function = sierra_sync_timer;
-	priv->sync_timer.data = (unsigned long) dev;
 	priv->sync_timer.expires = jiffies + SIERRA_NET_SYNCDELAY;
 	add_timer(&priv->sync_timer);
 }
@@ -593,9 +588,10 @@ static void sierra_net_defer_kevent(struct usbnet *dev, int work)
 /*
  * Sync Retransmit Timer Handler. On expiry, kick the work queue
  */
-static void sierra_sync_timer(unsigned long syncdata)
+static void sierra_sync_timer(struct timer_list *t)
 {
-	struct usbnet *dev = (struct usbnet *)syncdata;
+	struct sierra_net_data *priv = from_timer(priv, t, sync_timer);
+	struct usbnet *dev = priv->usbnet;
 
 	dev_dbg(&dev->udev->dev, "%s", __func__);
 	/* Kick the tasklet */
@@ -752,7 +748,7 @@ static int sierra_net_bind(struct usbnet *dev, struct usb_interface *intf)
 	INIT_WORK(&priv->sierra_net_kevent, sierra_net_kevent);
 
 	/* Only need to do this once */
-	init_timer(&priv->sync_timer);
+	timer_setup(&priv->sync_timer, sierra_sync_timer, 0);
 
 	/* verify fw attributes */
 	status = sierra_net_get_fw_attr(dev, &fwattr);
-- 
2.7.4

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
