From: Joe Perches <joe@perches.com>
Subject: [PATCH V2 net-next 2/2] drivers/net/usb: Use netif_<level> logging facilities
Date: Mon, 15 Feb 2010 00:25:12 -0800
Message-ID: <c9b38227b55aa3bb46728329bf5290063124f516.1266221693.git.joe@perches.com>
References: <20100212.123837.56526847.davem@davemloft.net>
Cc: David Brownell <david-b@pacbell.net>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	Tilman Schmidt <tilman@imap.cc>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1057 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755222Ab0BOIZP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Feb 2010 03:25:15 -0500
In-Reply-To: <20100212.123837.56526847.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert from:
	if (netif_msg_<foo>(priv))
		dev_<level>(dev...
to
	netif_<level>(priv, foo, dev...

Also convert a few:

	if (i < REG_TIMEOUT) {
		etc...
		return ret;
       }
to
	if (i >= REG_TIMEOUT)
		goto fail;
	etc...
	return ret;

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/usb/cdc_ether.c  |   18 ++--
 drivers/net/usb/net1080.c    |   96 +++++++++----------
 drivers/net/usb/pegasus.c    |  170 +++++++++++++++-------------------
 drivers/net/usb/rndis_host.c |   14 +--
 drivers/net/usb/smsc95xx.c   |   99 ++++++++------------
 drivers/net/usb/usbnet.c     |  208 ++++++++++++++++++-----------------------
 6 files changed, 264 insertions(+), 341 deletions(-)

diff --git a/drivers/net/usb/cdc_ether.c b/drivers/net/usb/cdc_ether.c
index 7e5a752..3486e8c 100644
--- a/drivers/net/usb/cdc_ether.c
+++ b/drivers/net/usb/cdc_ether.c
@@ -339,10 +339,10 @@ EXPORT_SYMBOL_GPL(usbnet_cdc_unbind);
 
 static void dumpspeed(struct usbnet *dev, __le32 *speeds)
 {
-	if (netif_msg_timer(dev))
-		netdev_info(dev->net, "link speeds: %u kbps up, %u kbps down\n",
-			    __le32_to_cpu(speeds[0]) / 1000,
-			    __le32_to_cpu(speeds[1]) / 1000);
+	netif_info(dev, timer, dev->net,
+		   "link speeds: %u kbps up, %u kbps down\n",
+		   __le32_to_cpu(speeds[0]) / 1000,
+		   __le32_to_cpu(speeds[1]) / 1000);
 }
 
 static void cdc_status(struct usbnet *dev, struct urb *urb)
@@ -361,18 +361,16 @@ static void cdc_status(struct usbnet *dev, struct urb *urb)
 	event = urb->transfer_buffer;
 	switch (event->bNotificationType) {
 	case USB_CDC_NOTIFY_NETWORK_CONNECTION:
-		if (netif_msg_timer(dev))
-			netdev_dbg(dev->net, "CDC: carrier %s\n",
-				   event->wValue ? "on" : "off");
+		netif_dbg(dev, timer, dev->net, "CDC: carrier %s\n",
+			  event->wValue ? "on" : "off");
 		if (event->wValue)
 			netif_carrier_on(dev->net);
 		else
 			netif_carrier_off(dev->net);
 		break;
 	case USB_CDC_NOTIFY_SPEED_CHANGE:	/* tx/rx rates */
-		if (netif_msg_timer(dev))
-			netdev_dbg(dev->net, "CDC: speed change (len %d)\n",
-				   urb->actual_length);
+		netif_dbg(dev, timer, dev->net, "CDC: speed change (len %d)\n",
+			  urb->actual_length);
 		if (urb->actual_length != (sizeof *event + 8))
 			set_bit(EVENT_STS_SPLIT, &dev->flags);
 		else
diff --git a/drivers/net/usb/net1080.c b/drivers/net/usb/net1080.c
index f699405..bdcad45 100644
--- a/drivers/net/usb/net1080.c
+++ b/drivers/net/usb/net1080.c
@@ -203,26 +203,23 @@ static void nc_dump_registers(struct usbnet *dev)
 
 static inline void nc_dump_usbctl(struct usbnet *dev, u16 usbctl)
 {
-	if (!netif_msg_link(dev))
-		return;
-	netdev_dbg(dev->net, "net1080 %s-%s usbctl 0x%x:%s%s%s%s%s;"
-		   " this%s%s;"
-		   " other%s%s; r/o 0x%x\n",
-		   dev->udev->bus->bus_name, dev->udev->devpath,
-		   usbctl,
-		   (usbctl & USBCTL_ENABLE_LANG) ? " lang" : "",
-		   (usbctl & USBCTL_ENABLE_MFGR) ? " mfgr" : "",
-		   (usbctl & USBCTL_ENABLE_PROD) ? " prod" : "",
-		   (usbctl & USBCTL_ENABLE_SERIAL) ? " serial" : "",
-		   (usbctl & USBCTL_ENABLE_DEFAULTS) ? " defaults" : "",
-
-		   (usbctl & USBCTL_FLUSH_THIS) ? " FLUSH" : "",
-		   (usbctl & USBCTL_DISCONN_THIS) ? " DIS" : "",
-
-		   (usbctl & USBCTL_FLUSH_OTHER) ? " FLUSH" : "",
-		   (usbctl & USBCTL_DISCONN_OTHER) ? " DIS" : "",
-
-		   usbctl & ~USBCTL_WRITABLE_MASK);
+	netif_dbg(dev, link, dev->net,
+		  "net1080 %s-%s usbctl 0x%x:%s%s%s%s%s; this%s%s; other%s%s; r/o 0x%x\n",
+		  dev->udev->bus->bus_name, dev->udev->devpath,
+		  usbctl,
+		  (usbctl & USBCTL_ENABLE_LANG) ? " lang" : "",
+		  (usbctl & USBCTL_ENABLE_MFGR) ? " mfgr" : "",
+		  (usbctl & USBCTL_ENABLE_PROD) ? " prod" : "",
+		  (usbctl & USBCTL_ENABLE_SERIAL) ? " serial" : "",
+		  (usbctl & USBCTL_ENABLE_DEFAULTS) ? " defaults" : "",
+
+		  (usbctl & USBCTL_FLUSH_THIS) ? " FLUSH" : "",
+		  (usbctl & USBCTL_DISCONN_THIS) ? " DIS" : "",
+
+		  (usbctl & USBCTL_FLUSH_OTHER) ? " FLUSH" : "",
+		  (usbctl & USBCTL_DISCONN_OTHER) ? " DIS" : "",
+
+		  usbctl & ~USBCTL_WRITABLE_MASK);
 }
 
 /*-------------------------------------------------------------------------*/
@@ -249,27 +246,26 @@ static inline void nc_dump_usbctl(struct usbnet *dev, u16 usbctl)
 
 static inline void nc_dump_status(struct usbnet *dev, u16 status)
 {
-	if (!netif_msg_link(dev))
-		return;
-	netdev_dbg(dev->net, "net1080 %s-%s status 0x%x: this (%c) PKT=%d%s%s%s; other PKT=%d%s%s%s; unspec 0x%x\n",
-		   dev->udev->bus->bus_name, dev->udev->devpath,
-		   status,
-
-		   // XXX the packet counts don't seem right
-		   // (1 at reset, not 0); maybe UNSPEC too
-
-		   (status & STATUS_PORT_A) ? 'A' : 'B',
-		   STATUS_PACKETS_THIS(status),
-		   (status & STATUS_CONN_THIS) ? " CON" : "",
-		   (status & STATUS_SUSPEND_THIS) ? " SUS" : "",
-		   (status & STATUS_MAILBOX_THIS) ? " MBOX" : "",
-
-		   STATUS_PACKETS_OTHER(status),
-		   (status & STATUS_CONN_OTHER) ? " CON" : "",
-		   (status & STATUS_SUSPEND_OTHER) ? " SUS" : "",
-		   (status & STATUS_MAILBOX_OTHER) ? " MBOX" : "",
-
-		   status & STATUS_UNSPEC_MASK);
+	netif_dbg(dev, link, dev->net,
+		  "net1080 %s-%s status 0x%x: this (%c) PKT=%d%s%s%s; other PKT=%d%s%s%s; unspec 0x%x\n",
+		  dev->udev->bus->bus_name, dev->udev->devpath,
+		  status,
+
+		  // XXX the packet counts don't seem right
+		  // (1 at reset, not 0); maybe UNSPEC too
+
+		  (status & STATUS_PORT_A) ? 'A' : 'B',
+		  STATUS_PACKETS_THIS(status),
+		  (status & STATUS_CONN_THIS) ? " CON" : "",
+		  (status & STATUS_SUSPEND_THIS) ? " SUS" : "",
+		  (status & STATUS_MAILBOX_THIS) ? " MBOX" : "",
+
+		  STATUS_PACKETS_OTHER(status),
+		  (status & STATUS_CONN_OTHER) ? " CON" : "",
+		  (status & STATUS_SUSPEND_OTHER) ? " SUS" : "",
+		  (status & STATUS_MAILBOX_OTHER) ? " MBOX" : "",
+
+		  status & STATUS_UNSPEC_MASK);
 }
 
 /*-------------------------------------------------------------------------*/
@@ -284,10 +280,9 @@ static inline void nc_dump_status(struct usbnet *dev, u16 status)
 
 static inline void nc_dump_ttl(struct usbnet *dev, u16 ttl)
 {
-	if (netif_msg_link(dev))
-		netdev_dbg(dev->net, "net1080 %s-%s ttl 0x%x this = %d, other = %d\n",
-			   dev->udev->bus->bus_name, dev->udev->devpath,
-			   ttl, TTL_THIS(ttl), TTL_OTHER(ttl));
+	netif_dbg(dev, link, dev->net, "net1080 %s-%s ttl 0x%x this = %d, other = %d\n",
+		  dev->udev->bus->bus_name, dev->udev->devpath,
+		  ttl, TTL_THIS(ttl), TTL_OTHER(ttl));
 }
 
 /*-------------------------------------------------------------------------*/
@@ -332,10 +327,9 @@ static int net1080_reset(struct usbnet *dev)
 			MK_TTL(NC_READ_TTL_MS, TTL_OTHER(ttl)) );
 	dbg("%s: assigned TTL, %d ms", dev->net->name, NC_READ_TTL_MS);
 
-	if (netif_msg_link(dev))
-		netdev_info(dev->net, "port %c, peer %sconnected\n",
-			    (status & STATUS_PORT_A) ? 'A' : 'B',
-			    (status & STATUS_CONN_OTHER) ? "" : "dis");
+	netif_info(dev, link, dev->net, "port %c, peer %sconnected\n",
+		   (status & STATUS_PORT_A) ? 'A' : 'B',
+		   (status & STATUS_CONN_OTHER) ? "" : "dis");
 	retval = 0;
 
 done:
@@ -412,8 +406,8 @@ static void nc_ensure_sync(struct usbnet *dev)
 			return;
 		}
 
-		if (netif_msg_rx_err(dev))
-			netdev_dbg(dev->net, "flush net1080; too many framing errors\n");
+		netif_dbg(dev, rx_err, dev->net,
+			  "flush net1080; too many framing errors\n");
 		dev->frame_errors = 0;
 	}
 }
diff --git a/drivers/net/usb/pegasus.c b/drivers/net/usb/pegasus.c
index 44ae8f6..4183877 100644
--- a/drivers/net/usb/pegasus.c
+++ b/drivers/net/usb/pegasus.c
@@ -132,9 +132,10 @@ static void ctrl_callback(struct urb *urb)
 	case -ENOENT:
 		break;
 	default:
-		if (netif_msg_drv(pegasus) && printk_ratelimit())
-			dev_dbg(&pegasus->intf->dev, "%s, status %d\n",
-				__func__, status);
+		if (net_ratelimit())
+			netif_dbg(pegasus, drv, pegasus->net,
+				  "%s, status %d\n", __func__, status);
+		break;
 	}
 	pegasus->flags &= ~ETH_REGS_CHANGED;
 	wake_up(&pegasus->ctrl_wait);
@@ -149,9 +150,8 @@ static int get_registers(pegasus_t * pegasus, __u16 indx, __u16 size,
 
 	buffer = kmalloc(size, GFP_KERNEL);
 	if (!buffer) {
-		if (netif_msg_drv(pegasus))
-			dev_warn(&pegasus->intf->dev, "out of memory in %s\n",
-					__func__);
+		netif_warn(pegasus, drv, pegasus->net,
+			   "out of memory in %s\n", __func__);
 		return -ENOMEM;
 	}
 	add_wait_queue(&pegasus->ctrl_wait, &wait);
@@ -181,9 +181,9 @@ static int get_registers(pegasus_t * pegasus, __u16 indx, __u16 size,
 		set_current_state(TASK_RUNNING);
 		if (ret == -ENODEV)
 			netif_device_detach(pegasus->net);
-		if (netif_msg_drv(pegasus) && printk_ratelimit())
-			dev_err(&pegasus->intf->dev, "%s, status %d\n",
-					__func__, ret);
+		if (net_ratelimit())
+			netif_err(pegasus, drv, pegasus->net,
+				  "%s, status %d\n", __func__, ret);
 		goto out;
 	}
 
@@ -205,9 +205,8 @@ static int set_registers(pegasus_t * pegasus, __u16 indx, __u16 size,
 
 	buffer = kmalloc(size, GFP_KERNEL);
 	if (!buffer) {
-		if (netif_msg_drv(pegasus))
-			dev_warn(&pegasus->intf->dev, "out of memory in %s\n",
-					__func__);
+		netif_warn(pegasus, drv, pegasus->net,
+			   "out of memory in %s\n", __func__);
 		return -ENOMEM;
 	}
 	memcpy(buffer, data, size);
@@ -237,9 +236,8 @@ static int set_registers(pegasus_t * pegasus, __u16 indx, __u16 size,
 	if ((ret = usb_submit_urb(pegasus->ctrl_urb, GFP_ATOMIC))) {
 		if (ret == -ENODEV)
 			netif_device_detach(pegasus->net);
-		if (netif_msg_drv(pegasus))
-			dev_err(&pegasus->intf->dev, "%s, status %d\n",
-					__func__, ret);
+		netif_err(pegasus, drv, pegasus->net,
+			  "%s, status %d\n", __func__, ret);
 		goto out;
 	}
 
@@ -259,9 +257,8 @@ static int set_register(pegasus_t * pegasus, __u16 indx, __u8 data)
 
 	tmp = kmalloc(1, GFP_KERNEL);
 	if (!tmp) {
-		if (netif_msg_drv(pegasus))
-			dev_warn(&pegasus->intf->dev, "out of memory in %s\n",
-					__func__);
+		netif_warn(pegasus, drv, pegasus->net,
+			   "out of memory in %s\n", __func__);
 		return -ENOMEM;
 	}
 	memcpy(tmp, &data, 1);
@@ -290,9 +287,9 @@ static int set_register(pegasus_t * pegasus, __u16 indx, __u8 data)
 	if ((ret = usb_submit_urb(pegasus->ctrl_urb, GFP_ATOMIC))) {
 		if (ret == -ENODEV)
 			netif_device_detach(pegasus->net);
-		if (netif_msg_drv(pegasus) && printk_ratelimit())
-			dev_err(&pegasus->intf->dev, "%s, status %d\n",
-					__func__, ret);
+		if (net_ratelimit())
+			netif_err(pegasus, drv, pegasus->net,
+				  "%s, status %d\n", __func__, ret);
 		goto out;
 	}
 
@@ -323,9 +320,8 @@ static int update_eth_regs_async(pegasus_t * pegasus)
 	if ((ret = usb_submit_urb(pegasus->ctrl_urb, GFP_ATOMIC))) {
 		if (ret == -ENODEV)
 			netif_device_detach(pegasus->net);
-		if (netif_msg_drv(pegasus))
-			dev_err(&pegasus->intf->dev, "%s, status %d\n",
-					__func__, ret);
+		netif_err(pegasus, drv, pegasus->net,
+			  "%s, status %d\n", __func__, ret);
 	}
 
 	return ret;
@@ -349,14 +345,16 @@ static int read_mii_word(pegasus_t * pegasus, __u8 phy, __u8 indx, __u16 * regd)
 		if (data[0] & PHY_DONE)
 			break;
 	}
-	if (i < REG_TIMEOUT) {
-		ret = get_registers(pegasus, PhyData, 2, &regdi);
-		*regd = le16_to_cpu(regdi);
-		return ret;
-	}
+
+	if (i >= REG_TIMEOUT)
+		goto fail;
+
+	ret = get_registers(pegasus, PhyData, 2, &regdi);
+	*regd = le16_to_cpu(regdi);
+	return ret;
+
 fail:
-	if (netif_msg_drv(pegasus))
-		dev_warn(&pegasus->intf->dev, "%s failed\n", __func__);
+	netif_warn(pegasus, drv, pegasus->net, "%s failed\n", __func__);
 
 	return ret;
 }
@@ -388,12 +386,14 @@ static int write_mii_word(pegasus_t * pegasus, __u8 phy, __u8 indx, __u16 regd)
 		if (data[0] & PHY_DONE)
 			break;
 	}
-	if (i < REG_TIMEOUT)
-		return ret;
+
+	if (i >= REG_TIMEOUT)
+		goto fail;
+
+	return ret;
 
 fail:
-	if (netif_msg_drv(pegasus))
-		dev_warn(&pegasus->intf->dev, "%s failed\n", __func__);
+	netif_warn(pegasus, drv, pegasus->net, "%s failed\n", __func__);
 	return -ETIMEDOUT;
 }
 
@@ -422,15 +422,15 @@ static int read_eprom_word(pegasus_t * pegasus, __u8 index, __u16 * retdata)
 		if (ret == -ESHUTDOWN)
 			goto fail;
 	}
-	if (i < REG_TIMEOUT) {
-		ret = get_registers(pegasus, EpromData, 2, &retdatai);
-		*retdata = le16_to_cpu(retdatai);
-		return ret;
-	}
+	if (i >= REG_TIMEOUT)
+		goto fail;
+
+	ret = get_registers(pegasus, EpromData, 2, &retdatai);
+	*retdata = le16_to_cpu(retdatai);
+	return ret;
 
 fail:
-	if (netif_msg_drv(pegasus))
-		dev_warn(&pegasus->intf->dev, "%s failed\n", __func__);
+	netif_warn(pegasus, drv, pegasus->net, "%s failed\n", __func__);
 	return -ETIMEDOUT;
 }
 
@@ -475,11 +475,13 @@ static int write_eprom_word(pegasus_t * pegasus, __u8 index, __u16 data)
 			break;
 	}
 	disable_eprom_write(pegasus);
-	if (i < REG_TIMEOUT)
-		return ret;
+	if (i >= REG_TIMEOUT)
+		goto fail;
+
+	return ret;
+
 fail:
-	if (netif_msg_drv(pegasus))
-		dev_warn(&pegasus->intf->dev, "%s failed\n", __func__);
+	netif_warn(pegasus, drv, pegasus->net, "%s failed\n", __func__);
 	return -ETIMEDOUT;
 }
 #endif				/* PEGASUS_WRITE_EEPROM */
@@ -642,25 +644,20 @@ static void read_bulk_callback(struct urb *urb)
 	case 0:
 		break;
 	case -ETIME:
-		if (netif_msg_rx_err(pegasus))
-			pr_debug("%s: reset MAC\n", net->name);
+		netif_dbg(pegasus, rx_err, net, "reset MAC\n");
 		pegasus->flags &= ~PEGASUS_RX_BUSY;
 		break;
 	case -EPIPE:		/* stall, or disconnect from TT */
 		/* FIXME schedule work to clear the halt */
-		if (netif_msg_rx_err(pegasus))
-			printk(KERN_WARNING "%s: no rx stall recovery\n",
-					net->name);
+		netif_warn(pegasus, rx_err, net, "no rx stall recovery\n");
 		return;
 	case -ENOENT:
 	case -ECONNRESET:
 	case -ESHUTDOWN:
-		if (netif_msg_ifdown(pegasus))
-			pr_debug("%s: rx unlink, %d\n", net->name, status);
+		netif_dbg(pegasus, ifdown, net, "rx unlink, %d\n", status);
 		return;
 	default:
-		if (netif_msg_rx_err(pegasus))
-			pr_debug("%s: RX status %d\n", net->name, status);
+		netif_dbg(pegasus, rx_err, net, "RX status %d\n", status);
 		goto goon;
 	}
 
@@ -669,9 +666,8 @@ static void read_bulk_callback(struct urb *urb)
 
 	rx_status = buf[count - 2];
 	if (rx_status & 0x1e) {
-		if (netif_msg_rx_err(pegasus))
-			pr_debug("%s: RX packet error %x\n",
-					net->name, rx_status);
+		netif_dbg(pegasus, rx_err, net,
+			  "RX packet error %x\n", rx_status);
 		pegasus->stats.rx_errors++;
 		if (rx_status & 0x06)	// long or runt
 			pegasus->stats.rx_length_errors++;
@@ -758,9 +754,7 @@ static void rx_fixup(unsigned long data)
 		pegasus->rx_skb = pull_skb(pegasus);
 	}
 	if (pegasus->rx_skb == NULL) {
-		if (netif_msg_rx_err(pegasus))
-			printk(KERN_WARNING "%s: low on memory\n",
-					pegasus->net->name);
+		netif_warn(pegasus, rx_err, pegasus->net, "low on memory\n");
 		tasklet_schedule(&pegasus->rx_tl);
 		goto done;
 	}
@@ -800,19 +794,15 @@ static void write_bulk_callback(struct urb *urb)
 	case -EPIPE:
 		/* FIXME schedule_work() to clear the tx halt */
 		netif_stop_queue(net);
-		if (netif_msg_tx_err(pegasus))
-			printk(KERN_WARNING "%s: no tx stall recovery\n",
-					net->name);
+		netif_warn(pegasus, tx_err, net, "no tx stall recovery\n");
 		return;
 	case -ENOENT:
 	case -ECONNRESET:
 	case -ESHUTDOWN:
-		if (netif_msg_ifdown(pegasus))
-			pr_debug("%s: tx unlink, %d\n", net->name, status);
+		netif_dbg(pegasus, ifdown, net, "tx unlink, %d\n", status);
 		return;
 	default:
-		if (netif_msg_tx_err(pegasus))
-			pr_info("%s: TX status %d\n", net->name, status);
+		netif_info(pegasus, tx_err, net, "TX status %d\n", status);
 		/* FALL THROUGH */
 	case 0:
 		break;
@@ -843,9 +833,7 @@ static void intr_callback(struct urb *urb)
 		/* some Pegasus-I products report LOTS of data
 		 * toggle errors... avoid log spamming
 		 */
-		if (netif_msg_timer(pegasus))
-			pr_debug("%s: intr status %d\n", net->name,
-					status);
+		netif_dbg(pegasus, timer, net, "intr status %d\n", status);
 	}
 
 	if (urb->actual_length >= 6) {
@@ -875,16 +863,15 @@ static void intr_callback(struct urb *urb)
 	res = usb_submit_urb(urb, GFP_ATOMIC);
 	if (res == -ENODEV)
 		netif_device_detach(pegasus->net);
-	if (res && netif_msg_timer(pegasus))
-		printk(KERN_ERR "%s: can't resubmit interrupt urb, %d\n",
-				net->name, res);
+	if (res)
+		netif_err(pegasus, timer, net,
+			  "can't resubmit interrupt urb, %d\n", res);
 }
 
 static void pegasus_tx_timeout(struct net_device *net)
 {
 	pegasus_t *pegasus = netdev_priv(net);
-	if (netif_msg_timer(pegasus))
-		printk(KERN_WARNING "%s: tx timeout\n", net->name);
+	netif_warn(pegasus, timer, net, "tx timeout\n");
 	usb_unlink_urb(pegasus->tx_urb);
 	pegasus->stats.tx_errors++;
 }
@@ -906,9 +893,7 @@ static netdev_tx_t pegasus_start_xmit(struct sk_buff *skb,
 			  pegasus->tx_buff, count,
 			  write_bulk_callback, pegasus);
 	if ((res = usb_submit_urb(pegasus->tx_urb, GFP_ATOMIC))) {
-		if (netif_msg_tx_err(pegasus))
-			printk(KERN_WARNING "%s: fail tx, %d\n",
-					net->name, res);
+		netif_warn(pegasus, tx_err, net, "fail tx, %d\n", res);
 		switch (res) {
 		case -EPIPE:		/* stall, or disconnect from TT */
 			/* cleanup should already have been scheduled */
@@ -952,10 +937,9 @@ static inline void get_interrupt_interval(pegasus_t * pegasus)
 	interval = data >> 8;
 	if (pegasus->usb->speed != USB_SPEED_HIGH) {
 		if (interval < 0x80) {
-			if (netif_msg_timer(pegasus))
-				dev_info(&pegasus->intf->dev, "intr interval "
-					"changed from %ums to %ums\n",
-					interval, 0x80);
+			netif_info(pegasus, timer, pegasus->net,
+				   "intr interval changed from %ums to %ums\n",
+				   interval, 0x80);
 			interval = 0x80;
 			data = (data & 0x00FF) | ((u16)interval << 8);
 #ifdef PEGASUS_WRITE_EEPROM
@@ -1046,8 +1030,7 @@ static int pegasus_open(struct net_device *net)
 	if ((res = usb_submit_urb(pegasus->rx_urb, GFP_KERNEL))) {
 		if (res == -ENODEV)
 			netif_device_detach(pegasus->net);
-		if (netif_msg_ifup(pegasus))
-			pr_debug("%s: failed rx_urb, %d", net->name, res);
+		netif_dbg(pegasus, ifup, net, "failed rx_urb, %d\n", res);
 		goto exit;
 	}
 
@@ -1058,15 +1041,13 @@ static int pegasus_open(struct net_device *net)
 	if ((res = usb_submit_urb(pegasus->intr_urb, GFP_KERNEL))) {
 		if (res == -ENODEV)
 			netif_device_detach(pegasus->net);
-		if (netif_msg_ifup(pegasus))
-			pr_debug("%s: failed intr_urb, %d\n", net->name, res);
+		netif_dbg(pegasus, ifup, net, "failed intr_urb, %d\n", res);
 		usb_kill_urb(pegasus->rx_urb);
 		goto exit;
 	}
 	if ((res = enable_net_traffic(net, pegasus->usb))) {
-		if (netif_msg_ifup(pegasus))
-			pr_debug("%s: can't enable_net_traffic() - %d\n",
-					net->name, res);
+		netif_dbg(pegasus, ifup, net,
+			  "can't enable_net_traffic() - %d\n", res);
 		res = -EIO;
 		usb_kill_urb(pegasus->rx_urb);
 		usb_kill_urb(pegasus->intr_urb);
@@ -1075,8 +1056,7 @@ static int pegasus_open(struct net_device *net)
 	}
 	set_carrier(net);
 	netif_start_queue(net);
-	if (netif_msg_ifup(pegasus))
-		pr_debug("%s: open\n", net->name);
+	netif_dbg(pegasus, ifup, net, "open\n");
 	res = 0;
 exit:
 	return res;
@@ -1230,13 +1210,11 @@ static void pegasus_set_multicast(struct net_device *net)
 
 	if (net->flags & IFF_PROMISC) {
 		pegasus->eth_regs[EthCtrl2] |= RX_PROMISCUOUS;
-		if (netif_msg_link(pegasus))
-			pr_info("%s: Promiscuous mode enabled.\n", net->name);
+		netif_info(pegasus, link, net, "Promiscuous mode enabled\n");
 	} else if (!netdev_mc_empty(net) || (net->flags & IFF_ALLMULTI)) {
 		pegasus->eth_regs[EthCtrl0] |= RX_MULTICAST;
 		pegasus->eth_regs[EthCtrl2] &= ~RX_PROMISCUOUS;
-		if (netif_msg_link(pegasus))
-			pr_debug("%s: set allmulti\n", net->name);
+		netif_dbg(pegasus, link, net, "set allmulti\n");
 	} else {
 		pegasus->eth_regs[EthCtrl0] &= ~RX_MULTICAST;
 		pegasus->eth_regs[EthCtrl2] &= ~RX_PROMISCUOUS;
diff --git a/drivers/net/usb/rndis_host.c b/drivers/net/usb/rndis_host.c
index f01f024..4ce331f 100644
--- a/drivers/net/usb/rndis_host.c
+++ b/drivers/net/usb/rndis_host.c
@@ -335,8 +335,8 @@ generic_rndis_bind(struct usbnet *dev, struct usb_interface *intf, int flags)
 
 	dev->maxpacket = usb_maxpacket(dev->udev, dev->out, 1);
 	if (dev->maxpacket == 0) {
-		if (netif_msg_probe(dev))
-			dev_dbg(&intf->dev, "dev->maxpacket can't be 0\n");
+		netif_dbg(dev, probe, dev->net,
+			  "dev->maxpacket can't be 0\n");
 		retval = -EINVAL;
 		goto fail_and_release;
 	}
@@ -394,17 +394,15 @@ generic_rndis_bind(struct usbnet *dev, struct usb_interface *intf, int flags)
 	}
 	if ((flags & FLAG_RNDIS_PHYM_WIRELESS) &&
 			*phym != RNDIS_PHYSICAL_MEDIUM_WIRELESS_LAN) {
-		if (netif_msg_probe(dev))
-			dev_dbg(&intf->dev, "driver requires wireless "
-				"physical medium, but device is not.\n");
+		netif_dbg(dev, probe, dev->net,
+			  "driver requires wireless physical medium, but device is not\n");
 		retval = -ENODEV;
 		goto halt_fail_and_release;
 	}
 	if ((flags & FLAG_RNDIS_PHYM_NOT_WIRELESS) &&
 			*phym == RNDIS_PHYSICAL_MEDIUM_WIRELESS_LAN) {
-		if (netif_msg_probe(dev))
-			dev_dbg(&intf->dev, "driver requires non-wireless "
-				"physical medium, but device is wireless.\n");
+		netif_dbg(dev, probe, dev->net,
+			  "driver requires non-wireless physical medium, but device is wireless.\n");
 		retval = -ENODEV;
 		goto halt_fail_and_release;
 	}
diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
index d4cbcef..1ada51e 100644
--- a/drivers/net/usb/smsc95xx.c
+++ b/drivers/net/usb/smsc95xx.c
@@ -376,13 +376,11 @@ static void smsc95xx_set_multicast(struct net_device *netdev)
 	spin_lock_irqsave(&pdata->mac_cr_lock, flags);
 
 	if (dev->net->flags & IFF_PROMISC) {
-		if (netif_msg_drv(dev))
-			netdev_dbg(dev->net, "promiscuous mode enabled\n");
+		netif_dbg(dev, drv, dev->net, "promiscuous mode enabled\n");
 		pdata->mac_cr |= MAC_CR_PRMS_;
 		pdata->mac_cr &= ~(MAC_CR_MCPAS_ | MAC_CR_HPFILT_);
 	} else if (dev->net->flags & IFF_ALLMULTI) {
-		if (netif_msg_drv(dev))
-			netdev_dbg(dev->net, "receive all multicast enabled\n");
+		netif_dbg(dev, drv, dev->net, "receive all multicast enabled\n");
 		pdata->mac_cr |= MAC_CR_MCPAS_;
 		pdata->mac_cr &= ~(MAC_CR_PRMS_ | MAC_CR_HPFILT_);
 	} else if (!netdev_mc_empty(dev->net)) {
@@ -410,12 +408,10 @@ static void smsc95xx_set_multicast(struct net_device *netdev)
 		if (count != ((u32) netdev_mc_count(dev->net)))
 			netdev_warn(dev->net, "mc_count != dev->mc_count\n");
 
-		if (netif_msg_drv(dev))
-			netdev_dbg(dev->net, "HASHH=0x%08X, HASHL=0x%08X\n",
+		netif_dbg(dev, drv, dev->net, "HASHH=0x%08X, HASHL=0x%08X\n",
 				   hash_hi, hash_lo);
 	} else {
-		if (netif_msg_drv(dev))
-			netdev_dbg(dev->net, "receive own packets only\n");
+		netif_dbg(dev, drv, dev->net, "receive own packets only\n");
 		pdata->mac_cr &=
 			~(MAC_CR_PRMS_ | MAC_CR_MCPAS_ | MAC_CR_HPFILT_);
 	}
@@ -452,13 +448,11 @@ static void smsc95xx_phy_update_flowcontrol(struct usbnet *dev, u8 duplex,
 		else
 			afc_cfg &= ~0xF;
 
-		if (netif_msg_link(dev))
-			netdev_dbg(dev->net, "rx pause %s, tx pause %s\n",
+		netif_dbg(dev, link, dev->net, "rx pause %s, tx pause %s\n",
 				   cap & FLOW_CTRL_RX ? "enabled" : "disabled",
 				   cap & FLOW_CTRL_TX ? "enabled" : "disabled");
 	} else {
-		if (netif_msg_link(dev))
-			netdev_dbg(dev->net, "half duplex\n");
+		netif_dbg(dev, link, dev->net, "half duplex\n");
 		flow = 0;
 		afc_cfg |= 0xF;
 	}
@@ -486,9 +480,8 @@ static int smsc95xx_link_reset(struct usbnet *dev)
 	lcladv = smsc95xx_mdio_read(dev->net, mii->phy_id, MII_ADVERTISE);
 	rmtadv = smsc95xx_mdio_read(dev->net, mii->phy_id, MII_LPA);
 
-	if (netif_msg_link(dev))
-		netdev_dbg(dev->net, "speed: %d duplex: %d lcladv: %04x rmtadv: %04x\n",
-			   ecmd.speed, ecmd.duplex, lcladv, rmtadv);
+	netif_dbg(dev, link, dev->net, "speed: %d duplex: %d lcladv: %04x rmtadv: %04x\n",
+		  ecmd.speed, ecmd.duplex, lcladv, rmtadv);
 
 	spin_lock_irqsave(&pdata->mac_cr_lock, flags);
 	if (ecmd.duplex != DUPLEX_FULL) {
@@ -520,8 +513,7 @@ static void smsc95xx_status(struct usbnet *dev, struct urb *urb)
 	memcpy(&intdata, urb->transfer_buffer, 4);
 	le32_to_cpus(&intdata);
 
-	if (netif_msg_link(dev))
-		netdev_dbg(dev->net, "intdata: 0x%08X\n", intdata);
+	netif_dbg(dev, link, dev->net, "intdata: 0x%08X\n", intdata);
 
 	if (intdata & INT_ENP_PHY_INT_)
 		usbnet_defer_kevent(dev, EVENT_LINK_RESET);
@@ -557,8 +549,7 @@ static int smsc95xx_set_csums(struct usbnet *dev)
 		return ret;
 	}
 
-	if (netif_msg_hw(dev))
-		netdev_dbg(dev->net, "COE_CR = 0x%08x\n", read_buf);
+	netif_dbg(dev, hw, dev->net, "COE_CR = 0x%08x\n", read_buf);
 	return 0;
 }
 
@@ -662,16 +653,14 @@ static void smsc95xx_init_mac_address(struct usbnet *dev)
 			dev->net->dev_addr) == 0) {
 		if (is_valid_ether_addr(dev->net->dev_addr)) {
 			/* eeprom values are valid so use them */
-			if (netif_msg_ifup(dev))
-				netdev_dbg(dev->net, "MAC address read from EEPROM\n");
+			netif_dbg(dev, ifup, dev->net, "MAC address read from EEPROM\n");
 			return;
 		}
 	}
 
 	/* no eeprom, or eeprom values are invalid. generate random MAC */
 	random_ether_addr(dev->net->dev_addr);
-	if (netif_msg_ifup(dev))
-		netdev_dbg(dev->net, "MAC address set to random_ether_addr\n");
+	netif_dbg(dev, ifup, dev->net, "MAC address set to random_ether_addr\n");
 }
 
 static int smsc95xx_set_mac_address(struct usbnet *dev)
@@ -750,8 +739,7 @@ static int smsc95xx_phy_initialize(struct usbnet *dev)
 		PHY_INT_MASK_DEFAULT_);
 	mii_nway_restart(&dev->mii);
 
-	if (netif_msg_ifup(dev))
-		netdev_dbg(dev->net, "phy initialised successfully\n");
+	netif_dbg(dev, ifup, dev->net, "phy initialised successfully\n");
 	return 0;
 }
 
@@ -762,8 +750,7 @@ static int smsc95xx_reset(struct usbnet *dev)
 	u32 read_buf, write_buf, burst_cap;
 	int ret = 0, timeout;
 
-	if (netif_msg_ifup(dev))
-		netdev_dbg(dev->net, "entering smsc95xx_reset\n");
+	netif_dbg(dev, ifup, dev->net, "entering smsc95xx_reset\n");
 
 	write_buf = HW_CFG_LRST_;
 	ret = smsc95xx_write_reg(dev, HW_CFG, write_buf);
@@ -818,8 +805,8 @@ static int smsc95xx_reset(struct usbnet *dev)
 	if (ret < 0)
 		return ret;
 
-	if (netif_msg_ifup(dev))
-		netdev_dbg(dev->net, "MAC Address: %pM\n", dev->net->dev_addr);
+	netif_dbg(dev, ifup, dev->net,
+		  "MAC Address: %pM\n", dev->net->dev_addr);
 
 	ret = smsc95xx_read_reg(dev, HW_CFG, &read_buf);
 	if (ret < 0) {
@@ -827,8 +814,8 @@ static int smsc95xx_reset(struct usbnet *dev)
 		return ret;
 	}
 
-	if (netif_msg_ifup(dev))
-		netdev_dbg(dev->net, "Read Value from HW_CFG : 0x%08x\n", read_buf);
+	netif_dbg(dev, ifup, dev->net,
+		  "Read Value from HW_CFG : 0x%08x\n", read_buf);
 
 	read_buf |= HW_CFG_BIR_;
 
@@ -844,9 +831,9 @@ static int smsc95xx_reset(struct usbnet *dev)
 		netdev_warn(dev->net, "Failed to read HW_CFG: %d\n", ret);
 		return ret;
 	}
-	if (netif_msg_ifup(dev))
-		netdev_dbg(dev->net, "Read Value from HW_CFG after writing HW_CFG_BIR_: 0x%08x\n",
-			   read_buf);
+	netif_dbg(dev, ifup, dev->net,
+		  "Read Value from HW_CFG after writing HW_CFG_BIR_: 0x%08x\n",
+		  read_buf);
 
 	if (!turbo_mode) {
 		burst_cap = 0;
@@ -859,8 +846,8 @@ static int smsc95xx_reset(struct usbnet *dev)
 		dev->rx_urb_size = DEFAULT_FS_BURST_CAP_SIZE;
 	}
 
-	if (netif_msg_ifup(dev))
-		netdev_dbg(dev->net, "rx_urb_size=%ld\n", (ulong)dev->rx_urb_size);
+	netif_dbg(dev, ifup, dev->net,
+		  "rx_urb_size=%ld\n", (ulong)dev->rx_urb_size);
 
 	ret = smsc95xx_write_reg(dev, BURST_CAP, burst_cap);
 	if (ret < 0) {
@@ -873,9 +860,9 @@ static int smsc95xx_reset(struct usbnet *dev)
 		netdev_warn(dev->net, "Failed to read BURST_CAP: %d\n", ret);
 		return ret;
 	}
-	if (netif_msg_ifup(dev))
-		netdev_dbg(dev->net, "Read Value from BURST_CAP after writing: 0x%08x\n",
-			   read_buf);
+	netif_dbg(dev, ifup, dev->net,
+		  "Read Value from BURST_CAP after writing: 0x%08x\n",
+		  read_buf);
 
 	read_buf = DEFAULT_BULK_IN_DELAY;
 	ret = smsc95xx_write_reg(dev, BULK_IN_DLY, read_buf);
@@ -889,17 +876,17 @@ static int smsc95xx_reset(struct usbnet *dev)
 		netdev_warn(dev->net, "Failed to read BULK_IN_DLY: %d\n", ret);
 		return ret;
 	}
-	if (netif_msg_ifup(dev))
-		netdev_dbg(dev->net, "Read Value from BULK_IN_DLY after writing: 0x%08x\n",
-			   read_buf);
+	netif_dbg(dev, ifup, dev->net,
+		  "Read Value from BULK_IN_DLY after writing: 0x%08x\n",
+		  read_buf);
 
 	ret = smsc95xx_read_reg(dev, HW_CFG, &read_buf);
 	if (ret < 0) {
 		netdev_warn(dev->net, "Failed to read HW_CFG: %d\n", ret);
 		return ret;
 	}
-	if (netif_msg_ifup(dev))
-		netdev_dbg(dev->net, "Read Value from HW_CFG: 0x%08x\n", read_buf);
+	netif_dbg(dev, ifup, dev->net,
+		  "Read Value from HW_CFG: 0x%08x\n", read_buf);
 
 	if (turbo_mode)
 		read_buf |= (HW_CFG_MEF_ | HW_CFG_BCE_);
@@ -921,9 +908,8 @@ static int smsc95xx_reset(struct usbnet *dev)
 		netdev_warn(dev->net, "Failed to read HW_CFG: %d\n", ret);
 		return ret;
 	}
-	if (netif_msg_ifup(dev))
-		netdev_dbg(dev->net, "Read Value from HW_CFG after writing: 0x%08x\n",
-			   read_buf);
+	netif_dbg(dev, ifup, dev->net,
+		  "Read Value from HW_CFG after writing: 0x%08x\n", read_buf);
 
 	write_buf = 0xFFFFFFFF;
 	ret = smsc95xx_write_reg(dev, INT_STS, write_buf);
@@ -938,8 +924,7 @@ static int smsc95xx_reset(struct usbnet *dev)
 		netdev_warn(dev->net, "Failed to read ID_REV: %d\n", ret);
 		return ret;
 	}
-	if (netif_msg_ifup(dev))
-		netdev_dbg(dev->net, "ID_REV = 0x%08x\n", read_buf);
+	netif_dbg(dev, ifup, dev->net, "ID_REV = 0x%08x\n", read_buf);
 
 	/* Configure GPIO pins as LED outputs */
 	write_buf = LED_GPIO_CFG_SPD_LED | LED_GPIO_CFG_LNK_LED |
@@ -1013,8 +998,7 @@ static int smsc95xx_reset(struct usbnet *dev)
 	smsc95xx_start_tx_path(dev);
 	smsc95xx_start_rx_path(dev);
 
-	if (netif_msg_ifup(dev))
-		netdev_dbg(dev->net, "smsc95xx_reset, return 0\n");
+	netif_dbg(dev, ifup, dev->net, "smsc95xx_reset, return 0\n");
 	return 0;
 }
 
@@ -1071,8 +1055,7 @@ static void smsc95xx_unbind(struct usbnet *dev, struct usb_interface *intf)
 {
 	struct smsc95xx_priv *pdata = (struct smsc95xx_priv *)(dev->data[0]);
 	if (pdata) {
-		if (netif_msg_ifdown(dev))
-			netdev_dbg(dev->net, "free pdata\n");
+		netif_dbg(dev, ifdown, dev->net, "free pdata\n");
 		kfree(pdata);
 		pdata = NULL;
 		dev->data[0] = 0;
@@ -1106,9 +1089,8 @@ static int smsc95xx_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
 		align_count = (4 - ((size + NET_IP_ALIGN) % 4)) % 4;
 
 		if (unlikely(header & RX_STS_ES_)) {
-			if (netif_msg_rx_err(dev))
-				netdev_dbg(dev->net, "Error header=0x%08x\n",
-					   header);
+			netif_dbg(dev, rx_err, dev->net,
+				  "Error header=0x%08x\n", header);
 			dev->net->stats.rx_errors++;
 			dev->net->stats.rx_dropped++;
 
@@ -1125,9 +1107,8 @@ static int smsc95xx_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
 		} else {
 			/* ETH_FRAME_LEN + 4(CRC) + 2(COE) + 4(Vlan) */
 			if (unlikely(size > (ETH_FRAME_LEN + 12))) {
-				if (netif_msg_rx_err(dev))
-					netdev_dbg(dev->net, "size err header=0x%08x\n",
-						   header);
+				netif_dbg(dev, rx_err, dev->net,
+					  "size err header=0x%08x\n", header);
 				return 0;
 			}
 
diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index 8e73293..17b6a62 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -242,13 +242,13 @@ void usbnet_skb_return (struct usbnet *dev, struct sk_buff *skb)
 	dev->net->stats.rx_packets++;
 	dev->net->stats.rx_bytes += skb->len;
 
-	if (netif_msg_rx_status (dev))
-		netdev_dbg(dev->net, "< rx, len %zu, type 0x%x\n",
-			   skb->len + sizeof (struct ethhdr), skb->protocol);
+	netif_dbg(dev, rx_status, dev->net, "< rx, len %zu, type 0x%x\n",
+		  skb->len + sizeof (struct ethhdr), skb->protocol);
 	memset (skb->cb, 0, sizeof (struct skb_data));
 	status = netif_rx (skb);
-	if (status != NET_RX_SUCCESS && netif_msg_rx_err (dev))
-		netdev_dbg(dev->net, "netif_rx status %d\n", status);
+	if (status != NET_RX_SUCCESS)
+		netif_dbg(dev, rx_err, dev->net,
+			  "netif_rx status %d\n", status);
 }
 EXPORT_SYMBOL_GPL(usbnet_skb_return);
 
@@ -332,8 +332,7 @@ static void rx_submit (struct usbnet *dev, struct urb *urb, gfp_t flags)
 	size_t			size = dev->rx_urb_size;
 
 	if ((skb = alloc_skb (size + NET_IP_ALIGN, flags)) == NULL) {
-		if (netif_msg_rx_err (dev))
-			netdev_dbg(dev->net, "no rx skb\n");
+		netif_dbg(dev, rx_err, dev->net, "no rx skb\n");
 		usbnet_defer_kevent (dev, EVENT_RX_MEMORY);
 		usb_free_urb (urb);
 		return;
@@ -363,21 +362,19 @@ static void rx_submit (struct usbnet *dev, struct urb *urb, gfp_t flags)
 			usbnet_defer_kevent (dev, EVENT_RX_MEMORY);
 			break;
 		case -ENODEV:
-			if (netif_msg_ifdown (dev))
-				netdev_dbg(dev->net, "device gone\n");
+			netif_dbg(dev, ifdown, dev->net, "device gone\n");
 			netif_device_detach (dev->net);
 			break;
 		default:
-			if (netif_msg_rx_err (dev))
-				netdev_dbg(dev->net, "rx submit, %d\n", retval);
+			netif_dbg(dev, rx_err, dev->net,
+				  "rx submit, %d\n", retval);
 			tasklet_schedule (&dev->bh);
 			break;
 		case 0:
 			__skb_queue_tail (&dev->rxq, skb);
 		}
 	} else {
-		if (netif_msg_ifdown (dev))
-			netdev_dbg(dev->net, "rx: stopped\n");
+		netif_dbg(dev, ifdown, dev->net, "rx: stopped\n");
 		retval = -ENOLINK;
 	}
 	spin_unlock_irqrestore (&dev->rxq.lock, lockflags);
@@ -400,8 +397,7 @@ static inline void rx_process (struct usbnet *dev, struct sk_buff *skb)
 	if (skb->len)
 		usbnet_skb_return (dev, skb);
 	else {
-		if (netif_msg_rx_err (dev))
-			netdev_dbg(dev->net, "drop\n");
+		netif_dbg(dev, rx_err, dev->net, "drop\n");
 error:
 		dev->net->stats.rx_errors++;
 		skb_queue_tail (&dev->done, skb);
@@ -428,8 +424,8 @@ static void rx_complete (struct urb *urb)
 			entry->state = rx_cleanup;
 			dev->net->stats.rx_errors++;
 			dev->net->stats.rx_length_errors++;
-			if (netif_msg_rx_err (dev))
-				netdev_dbg(dev->net, "rx length %d\n", skb->len);
+			netif_dbg(dev, rx_err, dev->net,
+				  "rx length %d\n", skb->len);
 		}
 		break;
 
@@ -446,8 +442,8 @@ static void rx_complete (struct urb *urb)
 	/* software-driven interface shutdown */
 	case -ECONNRESET:		/* async unlink */
 	case -ESHUTDOWN:		/* hardware gone */
-		if (netif_msg_ifdown (dev))
-			netdev_dbg(dev->net, "rx shutdown, code %d\n", urb_status);
+		netif_dbg(dev, ifdown, dev->net,
+			  "rx shutdown, code %d\n", urb_status);
 		goto block;
 
 	/* we get controller i/o faults during khubd disconnect() delays.
@@ -460,8 +456,8 @@ static void rx_complete (struct urb *urb)
 		dev->net->stats.rx_errors++;
 		if (!timer_pending (&dev->delay)) {
 			mod_timer (&dev->delay, jiffies + THROTTLE_JIFFIES);
-			if (netif_msg_link (dev))
-				netdev_dbg(dev->net, "rx throttle %d\n", urb_status);
+			netif_dbg(dev, link, dev->net,
+				  "rx throttle %d\n", urb_status);
 		}
 block:
 		entry->state = rx_cleanup;
@@ -477,8 +473,7 @@ block:
 	default:
 		entry->state = rx_cleanup;
 		dev->net->stats.rx_errors++;
-		if (netif_msg_rx_err (dev))
-			netdev_dbg(dev->net, "rx status %d\n", urb_status);
+		netif_dbg(dev, rx_err, dev->net, "rx status %d\n", urb_status);
 		break;
 	}
 
@@ -492,8 +487,7 @@ block:
 		}
 		usb_free_urb (urb);
 	}
-	if (netif_msg_rx_err (dev))
-		netdev_dbg(dev->net, "no read resubmitted\n");
+	netif_dbg(dev, rx_err, dev->net, "no read resubmitted\n");
 }
 
 static void intr_complete (struct urb *urb)
@@ -510,8 +504,8 @@ static void intr_complete (struct urb *urb)
 	/* software-driven interface shutdown */
 	case -ENOENT:		/* urb killed */
 	case -ESHUTDOWN:	/* hardware gone */
-		if (netif_msg_ifdown (dev))
-			netdev_dbg(dev->net, "intr shutdown, code %d\n", status);
+		netif_dbg(dev, ifdown, dev->net,
+			  "intr shutdown, code %d\n", status);
 		return;
 
 	/* NOTE:  not throttling like RX/TX, since this endpoint
@@ -527,8 +521,9 @@ static void intr_complete (struct urb *urb)
 
 	memset(urb->transfer_buffer, 0, urb->transfer_buffer_length);
 	status = usb_submit_urb (urb, GFP_ATOMIC);
-	if (status != 0 && netif_msg_timer (dev))
-		netdev_err(dev->net, "intr resubmit --> %d\n", status);
+	if (status != 0)
+		netif_err(dev, timer, dev->net,
+			  "intr resubmit --> %d\n", status);
 }
 
 /*-------------------------------------------------------------------------*/
@@ -536,8 +531,7 @@ void usbnet_pause_rx(struct usbnet *dev)
 {
 	set_bit(EVENT_RX_PAUSED, &dev->flags);
 
-	if (netif_msg_rx_status(dev))
-		netdev_dbg(dev->net, "paused rx queue enabled\n");
+	netif_dbg(dev, rx_status, dev->net, "paused rx queue enabled\n");
 }
 EXPORT_SYMBOL_GPL(usbnet_pause_rx);
 
@@ -555,9 +549,8 @@ void usbnet_resume_rx(struct usbnet *dev)
 
 	tasklet_schedule(&dev->bh);
 
-	if (netif_msg_rx_status(dev))
-		netdev_dbg(dev->net, "paused rx queue disabled, %d skbs requeued\n",
-			   num);
+	netif_dbg(dev, rx_status, dev->net,
+		  "paused rx queue disabled, %d skbs requeued\n", num);
 }
 EXPORT_SYMBOL_GPL(usbnet_resume_rx);
 
@@ -632,9 +625,8 @@ static void usbnet_terminate_urbs(struct usbnet *dev)
 		&& !skb_queue_empty(&dev->done)) {
 			schedule_timeout(UNLINK_TIMEOUT_MS);
 			set_current_state(TASK_UNINTERRUPTIBLE);
-			if (netif_msg_ifdown(dev))
-				netdev_dbg(dev->net, "waited for %d urb completions\n",
-					   temp);
+			netif_dbg(dev, ifdown, dev->net,
+				  "waited for %d urb completions\n", temp);
 	}
 	set_current_state(TASK_RUNNING);
 	dev->wait = NULL;
@@ -649,21 +641,21 @@ int usbnet_stop (struct net_device *net)
 
 	netif_stop_queue (net);
 
-	if (netif_msg_ifdown (dev))
-		netdev_info(dev->net, "stop stats: rx/tx %ld/%ld, errs %ld/%ld\n",
-			    net->stats.rx_packets, net->stats.tx_packets,
-			    net->stats.rx_errors, net->stats.tx_errors);
+	netif_info(dev, ifdown, dev->net,
+		   "stop stats: rx/tx %ld/%ld, errs %ld/%ld\n",
+		   net->stats.rx_packets, net->stats.tx_packets,
+		   net->stats.rx_errors, net->stats.tx_errors);
 
 	/* allow minidriver to stop correctly (wireless devices to turn off
 	 * radio etc) */
 	if (info->stop) {
 		retval = info->stop(dev);
-		if (retval < 0 && netif_msg_ifdown(dev))
-			netdev_info(dev->net,
-				    "stop fail (%d) usbnet usb-%s-%s, %s\n",
-				    retval,
-				    dev->udev->bus->bus_name, dev->udev->devpath,
-				    info->description);
+		if (retval < 0)
+			netif_info(dev, ifdown, dev->net,
+				   "stop fail (%d) usbnet usb-%s-%s, %s\n",
+				   retval,
+				   dev->udev->bus->bus_name, dev->udev->devpath,
+				   info->description);
 	}
 
 	if (!(info->flags & FLAG_AVOID_UNLINK_URBS))
@@ -702,32 +694,29 @@ int usbnet_open (struct net_device *net)
 	struct driver_info	*info = dev->driver_info;
 
 	if ((retval = usb_autopm_get_interface(dev->intf)) < 0) {
-		if (netif_msg_ifup (dev))
-			netdev_info(dev->net,
-				    "resumption fail (%d) usbnet usb-%s-%s, %s\n",
-				    retval,
-				    dev->udev->bus->bus_name,
-				    dev->udev->devpath,
-				    info->description);
+		netif_info(dev, ifup, dev->net,
+			   "resumption fail (%d) usbnet usb-%s-%s, %s\n",
+			   retval,
+			   dev->udev->bus->bus_name,
+			   dev->udev->devpath,
+			   info->description);
 		goto done_nopm;
 	}
 
 	// put into "known safe" state
 	if (info->reset && (retval = info->reset (dev)) < 0) {
-		if (netif_msg_ifup (dev))
-			netdev_info(dev->net,
-				    "open reset fail (%d) usbnet usb-%s-%s, %s\n",
-				    retval,
-				    dev->udev->bus->bus_name,
-				    dev->udev->devpath,
-				    info->description);
+		netif_info(dev, ifup, dev->net,
+			   "open reset fail (%d) usbnet usb-%s-%s, %s\n",
+			   retval,
+			   dev->udev->bus->bus_name,
+			   dev->udev->devpath,
+			   info->description);
 		goto done;
 	}
 
 	// insist peer be connected
 	if (info->check_connect && (retval = info->check_connect (dev)) < 0) {
-		if (netif_msg_ifup (dev))
-			netdev_dbg(dev->net, "can't open; %d\n", retval);
+		netif_dbg(dev, ifup, dev->net, "can't open; %d\n", retval);
 		goto done;
 	}
 
@@ -735,33 +724,23 @@ int usbnet_open (struct net_device *net)
 	if (dev->interrupt) {
 		retval = usb_submit_urb (dev->interrupt, GFP_KERNEL);
 		if (retval < 0) {
-			if (netif_msg_ifup (dev))
-				netdev_err(dev->net, "intr submit %d\n", retval);
+			netif_err(dev, ifup, dev->net,
+				  "intr submit %d\n", retval);
 			goto done;
 		}
 	}
 
 	netif_start_queue (net);
-	if (netif_msg_ifup (dev)) {
-		char	*framing;
-
-		if (dev->driver_info->flags & FLAG_FRAMING_NC)
-			framing = "NetChip";
-		else if (dev->driver_info->flags & FLAG_FRAMING_GL)
-			framing = "GeneSys";
-		else if (dev->driver_info->flags & FLAG_FRAMING_Z)
-			framing = "Zaurus";
-		else if (dev->driver_info->flags & FLAG_FRAMING_RN)
-			framing = "RNDIS";
-		else if (dev->driver_info->flags & FLAG_FRAMING_AX)
-			framing = "ASIX";
-		else
-			framing = "simple";
-
-		netdev_info(dev->net, "open: enable queueing (rx %d, tx %d) mtu %d %s framing\n",
-			    (int)RX_QLEN(dev), (int)TX_QLEN(dev),
-			    dev->net->mtu, framing);
-	}
+	netif_info(dev, ifup, dev->net,
+		   "open: enable queueing (rx %d, tx %d) mtu %d %s framing\n",
+		   (int)RX_QLEN(dev), (int)TX_QLEN(dev),
+		   dev->net->mtu,
+		   (dev->driver_info->flags & FLAG_FRAMING_NC) ? "NetChip" :
+		   (dev->driver_info->flags & FLAG_FRAMING_GL) ? "GeneSys" :
+		   (dev->driver_info->flags & FLAG_FRAMING_Z) ? "Zaurus" :
+		   (dev->driver_info->flags & FLAG_FRAMING_RN) ? "RNDIS" :
+		   (dev->driver_info->flags & FLAG_FRAMING_AX) ? "ASIX" :
+		   "simple");
 
 	// delay posting reads until we're fully open
 	tasklet_schedule (&dev->bh);
@@ -772,6 +751,7 @@ int usbnet_open (struct net_device *net)
 		usb_autopm_put_interface(dev->intf);
 	}
 	return retval;
+
 done:
 	usb_autopm_put_interface(dev->intf);
 done_nopm:
@@ -1015,16 +995,14 @@ static void tx_complete (struct urb *urb)
 			if (!timer_pending (&dev->delay)) {
 				mod_timer (&dev->delay,
 					jiffies + THROTTLE_JIFFIES);
-				if (netif_msg_link (dev))
-					netdev_dbg(dev->net, "tx throttle %d\n",
-						   urb->status);
+				netif_dbg(dev, link, dev->net,
+					  "tx throttle %d\n", urb->status);
 			}
 			netif_stop_queue (dev->net);
 			break;
 		default:
-			if (netif_msg_tx_err (dev))
-				netdev_dbg(dev->net, "tx err %d\n",
-					   entry->urb->status);
+			netif_dbg(dev, tx_err, dev->net,
+				  "tx err %d\n", entry->urb->status);
 			break;
 		}
 	}
@@ -1066,16 +1044,14 @@ netdev_tx_t usbnet_start_xmit (struct sk_buff *skb,
 	if (info->tx_fixup) {
 		skb = info->tx_fixup (dev, skb, GFP_ATOMIC);
 		if (!skb) {
-			if (netif_msg_tx_err (dev))
-				netdev_dbg(dev->net, "can't tx_fixup skb\n");
+			netif_dbg(dev, tx_err, dev->net, "can't tx_fixup skb\n");
 			goto drop;
 		}
 	}
 	length = skb->len;
 
 	if (!(urb = usb_alloc_urb (0, GFP_ATOMIC))) {
-		if (netif_msg_tx_err (dev))
-			netdev_dbg(dev->net, "no urb\n");
+		netif_dbg(dev, tx_err, dev->net, "no urb\n");
 		goto drop;
 	}
 
@@ -1128,8 +1104,8 @@ netdev_tx_t usbnet_start_xmit (struct sk_buff *skb,
 		break;
 	default:
 		usb_autopm_put_interface_async(dev->intf);
-		if (netif_msg_tx_err (dev))
-			netdev_dbg(dev->net, "tx: submit urb err %d\n", retval);
+		netif_dbg(dev, tx_err, dev->net,
+			  "tx: submit urb err %d\n", retval);
 		break;
 	case 0:
 		net->trans_start = jiffies;
@@ -1140,17 +1116,15 @@ netdev_tx_t usbnet_start_xmit (struct sk_buff *skb,
 	spin_unlock_irqrestore (&dev->txq.lock, flags);
 
 	if (retval) {
-		if (netif_msg_tx_err (dev))
-			netdev_dbg(dev->net, "drop, code %d\n", retval);
+		netif_dbg(dev, tx_err, dev->net, "drop, code %d\n", retval);
 drop:
 		dev->net->stats.tx_dropped++;
 		if (skb)
 			dev_kfree_skb_any (skb);
 		usb_free_urb (urb);
-	} else if (netif_msg_tx_queued (dev)) {
-		netdev_dbg(dev->net, "> tx, len %d, type 0x%x\n",
-			   length, skb->protocol);
-	}
+	} else
+		netif_dbg(dev, tx_queued, dev->net,
+			  "> tx, len %d, type 0x%x\n", length, skb->protocol);
 #ifdef CONFIG_PM
 deferred:
 #endif
@@ -1209,9 +1183,10 @@ static void usbnet_bh (unsigned long param)
 				if (urb != NULL)
 					rx_submit (dev, urb, GFP_ATOMIC);
 			}
-			if (temp != dev->rxq.qlen && netif_msg_link (dev))
-				netdev_dbg(dev->net, "rxqlen %d --> %d\n",
-					   temp, dev->rxq.qlen);
+			if (temp != dev->rxq.qlen)
+				netif_dbg(dev, link, dev->net,
+					  "rxqlen %d --> %d\n",
+					  temp, dev->rxq.qlen);
 			if (dev->rxq.qlen < qlen)
 				tasklet_schedule (&dev->bh);
 		}
@@ -1242,11 +1217,10 @@ void usbnet_disconnect (struct usb_interface *intf)
 
 	xdev = interface_to_usbdev (intf);
 
-	if (netif_msg_probe (dev))
-		netdev_info(dev->net, "unregister '%s' usb-%s-%s, %s\n",
-			    intf->dev.driver->name,
-			    xdev->bus->bus_name, xdev->devpath,
-			    dev->driver_info->description);
+	netif_info(dev, probe, dev->net, "unregister '%s' usb-%s-%s, %s\n",
+		   intf->dev.driver->name,
+		   xdev->bus->bus_name, xdev->devpath,
+		   dev->driver_info->description);
 
 	net = dev->net;
 	unregister_netdev (net);
@@ -1409,12 +1383,12 @@ usbnet_probe (struct usb_interface *udev, const struct usb_device_id *prod)
 	status = register_netdev (net);
 	if (status)
 		goto out3;
-	if (netif_msg_probe (dev))
-		netdev_info(dev->net, "register '%s' at usb-%s-%s, %s, %pM\n",
-			    udev->dev.driver->name,
-			    xdev->bus->bus_name, xdev->devpath,
-			    dev->driver_info->description,
-			    net->dev_addr);
+	netif_info(dev, probe, dev->net,
+		   "register '%s' at usb-%s-%s, %s, %pM\n",
+		   udev->dev.driver->name,
+		   xdev->bus->bus_name, xdev->devpath,
+		   dev->driver_info->description,
+		   net->dev_addr);
 
 	// ok, it's ready to go.
 	usb_set_intfdata (udev, dev);
-- 
1.7.0.14.g7e948

