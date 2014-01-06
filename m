From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net] r8152: add terminating newline
Date: Mon, 06 Jan 2014 10:42:41 -0800
Message-ID: <1389033761.2433.7.camel@joe-AO722>
References: <1388999999-9218-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
	linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org
To: Hayes Wang <hayeswang@realtek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1388999999-9218-1-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2014-01-06 at 17:19 +0800, Hayes Wang wrote:
> The netif_err() and netif_info() should have the terminating newline
> at the end of the message.

dev_<level> uses also need terminating newlines.

Perhaps it's a bit more comprehensive to convert the
pr_<level>_ratelimited uses to use net_ratelimit and
netdev_<level>.
---
 drivers/net/usb/r8152.c | 25 ++++++++++++++-----------
 1 file changed, 14 insertions(+), 11 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 13fabbb..8ae97a5 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -966,10 +966,12 @@ static void read_bulk_callback(struct urb *urb)
 	case -ENOENT:
 		return;	/* the urb is in unlink state */
 	case -ETIME:
-		pr_warn_ratelimited("may be reset is needed?..\n");
+		if (net_ratelimit())
+			netdev_warn(netdev, "maybe reset is needed?\n");
 		break;
 	default:
-		pr_warn_ratelimited("Rx status %d\n", status);
+		if (net_ratelimit())
+			netdev_warn(netdev, "Rx status %d\n", status);
 		break;
 	}
 
@@ -1002,7 +1004,8 @@ static void write_bulk_callback(struct urb *urb)
 
 	stats = rtl8152_get_stats(tp->netdev);
 	if (status) {
-		pr_warn_ratelimited("Tx status %d\n", status);
+		if (net_ratelimit())
+			netdev_warn(tp->netdev, "Tx status %d\n", status);
 		stats->tx_errors += agg->skb_num;
 	} else {
 		stats->tx_packets += agg->skb_num;
@@ -1079,7 +1082,7 @@ resubmit:
 		netif_device_detach(tp->netdev);
 	else if (res)
 		netif_err(tp, intr, tp->netdev,
-			"can't resubmit intr, status %d\n", res);
+			  "can't resubmit intr, status %d\n", res);
 }
 
 static inline void *rx_agg_align(void *data)
@@ -1490,7 +1493,7 @@ static void rtl8152_tx_timeout(struct net_device *netdev)
 	struct r8152 *tp = netdev_priv(netdev);
 	int i;
 
-	netif_warn(tp, tx_err, netdev, "Tx timeout.\n");
+	netif_warn(tp, tx_err, netdev, "Tx timeout\n");
 	for (i = 0; i < RTL8152_MAX_TX; i++)
 		usb_unlink_urb(tp->tx_info[i].urb);
 }
@@ -2284,8 +2287,8 @@ static int rtl8152_open(struct net_device *netdev)
 	if (res) {
 		if (res == -ENODEV)
 			netif_device_detach(tp->netdev);
-		netif_warn(tp, ifup, netdev,
-			"intr_urb submit failed: %d\n", res);
+		netif_warn(tp, ifup, netdev, "intr_urb submit failed: %d\n",
+			   res);
 		return res;
 	}
 
@@ -2751,7 +2754,7 @@ static int rtl8152_probe(struct usb_interface *intf,
 
 	netdev = alloc_etherdev(sizeof(struct r8152));
 	if (!netdev) {
-		dev_err(&intf->dev, "Out of memory");
+		dev_err(&intf->dev, "Out of memory\n");
 		return -ENOMEM;
 	}
 
@@ -2760,7 +2763,7 @@ static int rtl8152_probe(struct usb_interface *intf,
 	tp->msg_enable = 0x7FFF;
 
 	if (!rtl_ops_init(tp, id)) {
-		netif_err(tp, probe, netdev, "Unknown Device");
+		netif_err(tp, probe, netdev, "Unknown Device\n");
 		return -ENODEV;
 	}
 
@@ -2797,11 +2800,11 @@ static int rtl8152_probe(struct usb_interface *intf,
 
 	ret = register_netdev(netdev);
 	if (ret != 0) {
-		netif_err(tp, probe, netdev, "couldn't register the device");
+		netif_err(tp, probe, netdev, "couldn't register the device\n");
 		goto out1;
 	}
 
-	netif_info(tp, probe, netdev, "%s", DRIVER_VERSION);
+	netif_info(tp, probe, netdev, "%s\n", DRIVER_VERSION);
 
 	return 0;
 
