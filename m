From: Alexey Klimov <klimov.linux@gmail.com>
Subject: [patch review 2/3] net/usb: kaweth.c - place dev_err instead of
 err()
Date: Sun, 11 Jan 2009 19:17:01 +0300
Message-ID: <1231690622.2050.106.camel@tux.localhost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Greg KH <greg@kroah.com>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org
To: dbrownell@users.sourceforge.net, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.174]:28809 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752495AbZAKQRL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Jan 2009 11:17:11 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

---
Remove err-messages and place dev_err there.

Signed-off-by: Alexey Klimov <klimov.linux@gmail.com>

--
diff --git a/drivers/net/usb/kaweth.c b/drivers/net/usb/kaweth.c
index 7cb10a0..0238b01 100644
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
+		dev_err(&urb->dev->dev, "%s RX status: %d count: %d packet_len: %d\n",
                            net->name,
 			   status,
 			   count,
@@ -634,9 +634,11 @@ static void kaweth_usb_receive(struct urb *urb)
 
 	if(kaweth->net && (count > 2)) {
 		if(pkt_len > (count - 2)) {
-			err("Packet length too long for USB frame (pkt_len: %x, count: %x)",pkt_len, count);
-			err("Packet len & 2047: %x", pkt_len & 2047);
-			err("Count 2: %x", count2);
+			dev_err(&urb->dev->dev,
+				"Packet length too long for USB frame (pkt_len: %x, count: %x)\n",
+					pkt_len, count);
+			dev_err(&urb->dev->dev, "Packet len & 2047: %x\n", pkt_len & 2047);
+			dev_err(&urb->dev->dev, "Count 2: %x\n", count2);
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
 


-- 
Best regards, Klimov Alexey

