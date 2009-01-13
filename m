From: Alexey Klimov <klimov.linux@gmail.com>
Subject: [patch v2] net/usb: remove err() messages in few drivers
Date: Tue, 13 Jan 2009 03:08:42 +0300
Message-ID: <1231805322.12962.4.camel@tux.localhost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org
To: dbrownell@users.sourceforge.net, davem@davemloft.net,
	Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.186]:44913 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751902AbZAMAIu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2009 19:08:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove err-messages and place dev_err instead in catc.c, kaweth.c and
rtl8150.c.

Signed-off-by: Alexey Klimov <klimov.linux@gmail.com>

--
diff --git a/drivers/net/usb/catc.c b/drivers/net/usb/catc.c
index cb7acbb..bf1e881 100644
--- a/drivers/net/usb/catc.c
+++ b/drivers/net/usb/catc.c
@@ -339,14 +339,14 @@ static void catc_irq_done(struct urb *urb)
 		} else {
 			catc->rx_urb->dev = catc->usbdev;
 			if ((res = usb_submit_urb(catc->rx_urb, GFP_ATOMIC)) < 0) {
-				err("submit(rx_urb) status %d", res);
+				dev_err(&catc->usbdev->dev, "submit(rx_urb) status %d\n", res);
 			}
 		} 
 	}
 resubmit:
 	res = usb_submit_urb (urb, GFP_ATOMIC);
 	if (res)
-		err ("can't resubmit intr, %s-%s, status %d",
+		dev_err(&catc->usbdev->dev, "can't resubmit intr, %s-%s, status %d\n",
 				catc->usbdev->bus->bus_name,
 				catc->usbdev->devpath, res);
 }
@@ -367,7 +367,7 @@ static int catc_tx_run(struct catc *catc)
 	catc->tx_urb->dev = catc->usbdev;
 
 	if ((status = usb_submit_urb(catc->tx_urb, GFP_ATOMIC)) < 0)
-		err("submit(tx_urb), status %d", status);
+		dev_err(&catc->usbdev->dev, "submit(tx_urb), status %d\n", status);
 
 	catc->tx_idx = !catc->tx_idx;
 	catc->tx_ptr = 0;
@@ -496,7 +496,7 @@ static void catc_ctrl_run(struct catc *catc)
 		memcpy(catc->ctrl_buf, q->buf, q->len);
 
 	if ((status = usb_submit_urb(catc->ctrl_urb, GFP_KERNEL)))
-		err("submit(ctrl_urb) status %d", status);
+		dev_err(&usbdev->dev, "submit(ctrl_urb) status %d\n", status);
 }
 
 static void catc_ctrl_done(struct urb *urb)
@@ -555,7 +555,7 @@ static int catc_ctrl_async(struct catc *catc, u8 dir, u8 request, u16 value,
 	catc->ctrl_head = (catc->ctrl_head + 1) & (CTRL_QUEUE - 1);
 
 	if (catc->ctrl_head == catc->ctrl_tail) {
-		err("ctrl queue full");
+		dev_err(&catc->usbdev->dev, "ctrl queue full\n");
 		catc->ctrl_tail = (catc->ctrl_tail + 1) & (CTRL_QUEUE - 1);
 		retval = -1;
 	}
@@ -721,7 +721,7 @@ static int catc_open(struct net_device *netdev)
 
 	catc->irq_urb->dev = catc->usbdev;
 	if ((status = usb_submit_urb(catc->irq_urb, GFP_KERNEL)) < 0) {
-		err("submit(irq_urb) status %d", status);
+		dev_err(&netdev->dev, "submit(irq_urb) status %d\n", status);
 		return -1;
 	}
 
@@ -764,7 +764,7 @@ static int catc_probe(struct usb_interface *intf, const struct usb_device_id *id
 
 	if (usb_set_interface(usbdev,
 			intf->altsetting->desc.bInterfaceNumber, 1)) {
-                err("Can't set altsetting 1.");
+                dev_err(&intf->dev, "Can't set altsetting 1.\n");
 		return -EIO;
 	}
 
@@ -799,7 +799,7 @@ static int catc_probe(struct usb_interface *intf, const struct usb_device_id *id
 	catc->irq_urb = usb_alloc_urb(0, GFP_KERNEL);
 	if ((!catc->ctrl_urb) || (!catc->tx_urb) || 
 	    (!catc->rx_urb) || (!catc->irq_urb)) {
-		err("No free urbs available.");
+		dev_err(&intf->dev, "No free urbs available.\n");
 		usb_free_urb(catc->ctrl_urb);
 		usb_free_urb(catc->tx_urb);
 		usb_free_urb(catc->rx_urb);
diff --git a/drivers/net/usb/kaweth.c b/drivers/net/usb/kaweth.c
index 7cb10a0..454b745 100644
--- a/drivers/net/usb/kaweth.c
+++ b/drivers/net/usb/kaweth.c
@@ -397,12 +397,12 @@ static int kaweth_download_firmware(struct kaweth_device *kaweth,
 
 	ret = request_firmware(&fw, fwname, &kaweth->dev->dev);
 	if (ret) {
-		err("Firmware request failed\n");
+		dev_err(&kaweth->net->dev, "Firmware request failed\n");
 		return ret;
 	}
 
 	if (fw->size > KAWETH_FIRMWARE_BUF_SIZE) {
-		err("Firmware too big: %zu", fw->size);
+		dev_err(&kaweth->net->dev, "Firmware too big: %zu\n", fw->size);
 		return -ENOSPC;
 	}
 	data_len = fw->size;
@@ -506,7 +506,7 @@ static void kaweth_resubmit_int_urb(struct kaweth_device *kaweth, gfp_t mf)
 	}
 
 	if (status)
-		err ("can't resubmit intr, %s-%s, status %d",
+		dev_err(&kaweth->dev->dev, "can't resubmit intr, %s-%s, status %d\n",
 				kaweth->dev->bus->bus_name,
 				kaweth->dev->devpath, status);
 }
@@ -581,7 +581,7 @@ static int kaweth_resubmit_rx_urb(struct kaweth_device *kaweth,
 			kaweth->suspend_lowmem_rx = 1;
 			schedule_delayed_work(&kaweth->lowmem_work, HZ/4);
 		}
-		err("resubmitting rx_urb %d failed", result);
+		dev_err(&kaweth->dev->dev, "resubmitting rx_urb %d failed\n", result);
 	} else {
 		kaweth->suspend_lowmem_rx = 0;
 	}
@@ -623,7 +623,7 @@ static void kaweth_usb_receive(struct urb *urb)
 	spin_unlock(&kaweth->device_lock);
 
 	if(status && status != -EREMOTEIO && count != 1) {
-		err("%s RX status: %d count: %d packet_len: %d",
+		dev_err(&kaweth->net->dev, "%s RX status: %d count: %d packet_len: %d\n",
                            net->name,
 			   status,
 			   count,
@@ -634,9 +634,11 @@ static void kaweth_usb_receive(struct urb *urb)
 
 	if(kaweth->net && (count > 2)) {
 		if(pkt_len > (count - 2)) {
-			err("Packet length too long for USB frame (pkt_len: %x, count: %x)",pkt_len, count);
-			err("Packet len & 2047: %x", pkt_len & 2047);
-			err("Count 2: %x", count2);
+			dev_err(&kaweth->net->dev,
+				"Packet length too long for USB frame (pkt_len: %x, count: %x)\n",
+					pkt_len, count);
+			dev_err(&kaweth->net->dev, "Packet len & 2047: %x\n", pkt_len & 2047);
+			dev_err(&kaweth->net->dev, "Count 2: %x\n", count2);
 		        kaweth_resubmit_rx_urb(kaweth, GFP_ATOMIC);
                         return;
                 }
@@ -675,7 +677,7 @@ static int kaweth_open(struct net_device *net)
 
 	res = usb_autopm_get_interface(kaweth->intf);
 	if (res) {
-		err("Interface cannot be resumed.");
+		dev_err(&net->dev, "Interface cannot be resumed.\n");
 		return -EIO;
 	}
 	res = kaweth_resubmit_rx_urb(kaweth, GFP_KERNEL);
@@ -902,7 +904,7 @@ static void kaweth_async_set_rx_mode(struct kaweth_device *kaweth)
 				KAWETH_CONTROL_TIMEOUT);
 
 	if(result < 0) {
-		err("Failed to set Rx mode: %d", result);
+		dev_err(&kaweth->dev->dev, "Failed to set Rx mode: %d\n", result);
 	}
 	else {
 		dbg("Set Rx mode to %d", packet_filter_bitmap);
@@ -1038,7 +1040,7 @@ static int kaweth_probe(
 						      "kaweth/new_code.bin",
 						      100,
 						      2)) < 0) {
-			err("Error downloading firmware (%d)", result);
+			dev_err(&intf->dev, "Error downloading firmware (%d)\n", result);
 			goto err_fw;
 		}
 
@@ -1046,7 +1048,7 @@ static int kaweth_probe(
 						      "kaweth/new_code_fix.bin",
 						      100,
 						      3)) < 0) {
-			err("Error downloading firmware fix (%d)", result);
+			dev_err(&intf->dev, "Error downloading firmware fix (%d)\n", result);
 			goto err_fw;
 		}
 
@@ -1054,7 +1056,7 @@ static int kaweth_probe(
 						      "kaweth/trigger_code.bin",
 						      126,
 						      2)) < 0) {
-			err("Error downloading trigger code (%d)", result);
+			dev_err(&intf->dev, "Error downloading trigger code (%d)\n", result);
 			goto err_fw;
 
 		}
@@ -1063,13 +1065,13 @@ static int kaweth_probe(
 						      "kaweth/trigger_code_fix.bin",
 						      126,
 						      3)) < 0) {
-			err("Error downloading trigger code fix (%d)", result);
+			dev_err(&intf->dev, "Error downloading trigger code fix (%d)\n", result);
 			goto err_fw;
 		}
 
 
 		if ((result = kaweth_trigger_firmware(kaweth, 126)) < 0) {
-			err("Error triggering firmware (%d)", result);
+			dev_err(&intf->dev, "Error triggering firmware (%d)\n", result);
 			goto err_fw;
 		}
 
@@ -1084,7 +1086,7 @@ err_fw:
 	result = kaweth_read_configuration(kaweth);
 
 	if(result < 0) {
-		err("Error reading configuration (%d), no net device created", result);
+		dev_err(&intf->dev, "Error reading configuration (%d), no net device created\n", result);
 		goto err_free_netdev;
 	}
 
@@ -1102,7 +1104,7 @@ err_fw:
 	if(!memcmp(&kaweth->configuration.hw_addr,
                    &bcast_addr,
 		   sizeof(bcast_addr))) {
-		err("Firmware not functioning properly, no net device created");
+		dev_err(&intf->dev, "Firmware not functioning properly, no net device created\n");
 		goto err_free_netdev;
 	}
 
@@ -1112,7 +1114,7 @@ err_fw:
 	}
 
 	if(kaweth_set_sofs_wait(kaweth, KAWETH_SOFS_TO_WAIT) < 0) {
-		err("Error setting SOFS wait");
+		dev_err(&intf->dev, "Error setting SOFS wait\n");
 		goto err_free_netdev;
 	}
 
@@ -1122,7 +1124,7 @@ err_fw:
                                            KAWETH_PACKET_FILTER_MULTICAST);
 
 	if(result < 0) {
-		err("Error setting receive filter");
+		dev_err(&intf->dev, "Error setting receive filter\n");
 		goto err_free_netdev;
 	}
 
@@ -1174,7 +1176,7 @@ err_fw:
 
 	SET_NETDEV_DEV(netdev, &intf->dev);
 	if (register_netdev(netdev) != 0) {
-		err("Error registering netdev.");
+		dev_err(&intf->dev, "Error registering netdev.\n");
 		goto err_intfdata;
 	}
 
diff --git a/drivers/net/usb/rtl8150.c b/drivers/net/usb/rtl8150.c
index d8664bf..ae19675 100644
--- a/drivers/net/usb/rtl8150.c
+++ b/drivers/net/usb/rtl8150.c
@@ -247,7 +247,8 @@ static int async_set_registers(rtl8150_t * dev, u16 indx, u16 size)
 	if ((ret = usb_submit_urb(dev->ctrl_urb, GFP_ATOMIC))) {
 		if (ret == -ENODEV)
 			netif_device_detach(dev->netdev);
-		err("control request submission failed: %d", ret);
+		dev_err(&dev->udev->dev,
+			"control request submission failed: %d\n", ret);
 	} else
 		set_bit(RX_REG_SET, &dev->flags);
 
@@ -599,7 +600,8 @@ resubmit:
 	if (res == -ENODEV)
 		netif_device_detach(dev->netdev);
 	else if (res)
-		err ("can't resubmit intr, %s-%s/input0, status %d",
+		dev_err(&dev->udev->dev,
+			"can't resubmit intr, %s-%s/input0, status %d\n",
 				dev->udev->bus->bus_name,
 				dev->udev->devpath, res);
 }
@@ -906,7 +908,7 @@ static int rtl8150_probe(struct usb_interface *intf,
 
 	netdev = alloc_etherdev(sizeof(rtl8150_t));
 	if (!netdev) {
-		err("Out of memory");
+		dev_err(&intf->dev, "Out of memory\n");
 		return -ENOMEM;
 	}
 
@@ -936,11 +938,11 @@ static int rtl8150_probe(struct usb_interface *intf,
 	dev->intr_interval = 100;	/* 100ms */
 
 	if (!alloc_all_urbs(dev)) {
-		err("out of memory");
+		dev_err(&intf->dev, "out of memory\n");
 		goto out;
 	}
 	if (!rtl8150_reset(dev)) {
-		err("couldn't reset the device");
+		dev_err(&intf->dev, "couldn't reset the device\n");
 		goto out1;
 	}
 	fill_skb_pool(dev);
@@ -949,7 +951,7 @@ static int rtl8150_probe(struct usb_interface *intf,
 	usb_set_intfdata(intf, dev);
 	SET_NETDEV_DEV(netdev, &intf->dev);
 	if (register_netdev(netdev) != 0) {
-		err("couldn't register the device");
+		dev_err(&intf->dev, "couldn't register the device\n");
 		goto out2;
 	}
 


-- 
Best regards, Klimov Alexey

