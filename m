From: David Brownell <david-b@pacbell.net>
Subject: [patch 2.6.27-rc5] net/usb/pegasus.c -- avoid hundreds of diagnostics
Date: Tue, 2 Sep 2008 11:34:24 -0700
Message-ID: <200809021134.24562.david-b@pacbell.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>
To: Network development list <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp119.sbc.mail.sp1.yahoo.com ([69.147.64.92]:24038 "HELO
	smtp119.sbc.mail.sp1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754019AbYIBSe1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Sep 2008 14:34:27 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Brownell <dbrownell@users.sourceforge.net>

Make the "pegasus" driver scream less loudly in the face of
problems as it initializes, avoiding hundreds of messages:

 - ratelimit some key error messages
 - avoid some spurious diagnostics caused by strange codeflow

And fix one instance of goofy indentation.

Signed-off-by: David Brownell <dbrownell@users.sourceforge.net>

--- a/drivers/net/usb/pegasus.c
+++ b/drivers/net/usb/pegasus.c
@@ -117,7 +117,7 @@ static void ctrl_callback(struct urb *urb)
 	case -ENOENT:
 		break;
 	default:
-		if (netif_msg_drv(pegasus))
+		if (netif_msg_drv(pegasus) && printk_ratelimit())
 			dev_dbg(&pegasus->intf->dev, "%s, status %d\n",
 				__FUNCTION__, urb->status);
 	}
@@ -166,7 +166,7 @@ static int get_registers(pegasus_t * pegasus, __u16 indx, __u16 size,
 		set_current_state(TASK_RUNNING);
 		if (ret == -ENODEV)
 			netif_device_detach(pegasus->net);
-		if (netif_msg_drv(pegasus))
+		if (netif_msg_drv(pegasus) && printk_ratelimit())
 			dev_err(&pegasus->intf->dev, "%s, status %d\n",
 					__FUNCTION__, ret);
 		goto out;
@@ -275,7 +275,7 @@ static int set_register(pegasus_t * pegasus, __u16 indx, __u8 data)
 	if ((ret = usb_submit_urb(pegasus->ctrl_urb, GFP_ATOMIC))) {
 		if (ret == -ENODEV)
 			netif_device_detach(pegasus->net);
-		if (netif_msg_drv(pegasus))
+		if (netif_msg_drv(pegasus) && printk_ratelimit())
 			dev_err(&pegasus->intf->dev, "%s, status %d\n",
 					__FUNCTION__, ret);
 		goto out;
@@ -1209,8 +1209,7 @@ static void pegasus_set_multicast(struct net_device *net)
 		pegasus->eth_regs[EthCtrl2] |= RX_PROMISCUOUS;
 		if (netif_msg_link(pegasus))
 			pr_info("%s: Promiscuous mode enabled.\n", net->name);
-	} else if (net->mc_count ||
-		   (net->flags & IFF_ALLMULTI)) {
+	} else if (net->mc_count || (net->flags & IFF_ALLMULTI)) {
 		pegasus->eth_regs[EthCtrl0] |= RX_MULTICAST;
 		pegasus->eth_regs[EthCtrl2] &= ~RX_PROMISCUOUS;
 		if (netif_msg_link(pegasus))
@@ -1220,6 +1219,8 @@ static void pegasus_set_multicast(struct net_device *net)
 		pegasus->eth_regs[EthCtrl2] &= ~RX_PROMISCUOUS;
 	}
 
+	pegasus->ctrl_urb->status = 0;
+
 	pegasus->flags |= ETH_REGS_CHANGE;
 	ctrl_callback(pegasus->ctrl_urb);
 }
