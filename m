From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 1/2] kaweth: Fix locking to be SMP-safe
Date: Sun, 29 Mar 2009 18:32:34 -0500
Message-ID: <49d00512.XAF19LdpY1dlK6+U%Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from hrndva-omtalb.mail.rr.com ([71.74.56.125]:53656 "EHLO
	hrndva-omtalb.mail.rr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751390AbZC2Xcn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Mar 2009 19:32:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On an SMP system, the following message is printed. The patch below gets
fixes the problem.

=================================
[ INFO: inconsistent lock state ]
2.6.29-Linus-05093-gc31f403 #57
---------------------------------
inconsistent {hardirq-on-W} -> {in-hardirq-W} usage.
bash/4105 [HC1[1]:SC0[0]:HE0:SE1] takes:
 (&kaweth->device_lock){+...}, at: [<ffffffffa01aa286>]
                 kaweth_usb_receive+0x77/0x1af [kaw eth]
{hardirq-on-W} state was registered at:
  [<ffffffff80260503>] __lock_acquire+0x753/0x1685
  [<ffffffff8026148a>] lock_acquire+0x55/0x71
  [<ffffffff80461ba6>] _spin_lock+0x31/0x3d
  [<ffffffffa01aaa0c>] kaweth_start_xmit+0x2b/0x1e1 [kaweth]
  [<ffffffff803eccd3>] dev_hard_start_xmit+0x22e/0x2ad
  [<ffffffff803fe120>] __qdisc_run+0xf2/0x203
  [<ffffffff803ed0cd>] dev_queue_xmit+0x263/0x39b
  [<ffffffffa03a47cb>] packet_sendmsg_spkt+0x1c4/0x20a [af_packet]
  [<ffffffff803de0c2>] sock_sendmsg+0xe4/0xfd
  [<ffffffff803dec8f>] sys_sendto+0xe4/0x10c
  [<ffffffff8020bccb>] system_call_fastpath+0x16/0x1b
  [<ffffffffffffffff>] 0xffffffffffffffff
irq event stamp: 1280
hardirqs last  enabled at (1279): [<ffffffff80461a71>]
                  _spin_unlock_irqrestore+0x44/0x4c
hardirqs last disabled at (1280): [<ffffffff8020bad7>]
                  save_args+0x67/0x70
softirqs last  enabled at (660): [<ffffffff8024192c>]
                  __do_softirq+0x14d/0x15d
softirqs last disabled at (651): [<ffffffff8020ce9c>]
                  call_softirq+0x1c/0x28

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---

Jeff,

As the listed authors of this driver have not touched it in several years,
I have taken the liberty of sending it to you as networking drivers maintainer.
I hope this is OK.

Larry
---

Index: wireless-testing/drivers/net/usb/kaweth.c
===================================================================
--- wireless-testing.orig/drivers/net/usb/kaweth.c
+++ wireless-testing/drivers/net/usb/kaweth.c
@@ -36,7 +36,6 @@
  * Run test procedures
  * Fix bugs from previous two steps
  * Snoop other OSs for any tricks we're not doing
- * SMP locking
  * Reduce arbitrary timeouts
  * Smart multicast support
  * Temporary MAC change support
@@ -529,6 +528,7 @@ static void int_callback(struct urb *u)
 		goto resubmit;
 	}
 
+	spin_lock(&kaweth->device_lock);
 	/* we check the link state to report changes */
 	if (kaweth->linkstate != (act_state = ( kaweth->intbuffer[STATE_OFFSET] | STATE_MASK) >> STATE_SHIFT)) {
 		if (act_state)
@@ -540,6 +540,7 @@ static void int_callback(struct urb *u)
 	}
 resubmit:
 	kaweth_resubmit_int_urb(kaweth, GFP_ATOMIC);
+	spin_unlock(&kaweth->device_lock);
 }
 
 static void kaweth_resubmit_tl(struct work_struct *work)
@@ -606,21 +607,19 @@ static void kaweth_usb_receive(struct ur
 	__u16 pkt_len = le16_to_cpup((__le16 *)kaweth->rx_buf);
 
 	struct sk_buff *skb;
+	unsigned long flags;
 
+	spin_lock_irqsave(&kaweth->device_lock, flags);
 	if(unlikely(status == -ECONNRESET || status == -ESHUTDOWN))
 	/* we are killed - set a flag and wake the disconnect handler */
 	{
 		kaweth->end = 1;
 		wake_up(&kaweth->term_wait);
-		return;
+		goto out;
 	}
 
-	spin_lock(&kaweth->device_lock);
-	if (IS_BLOCKED(kaweth->status)) {
-		spin_unlock(&kaweth->device_lock);
-		return;
-	}
-	spin_unlock(&kaweth->device_lock);
+	if (IS_BLOCKED(kaweth->status))
+		goto out;
 
 	if(status && status != -EREMOTEIO && count != 1) {
 		err("%s RX status: %d count: %d packet_len: %d",
@@ -629,7 +628,7 @@ static void kaweth_usb_receive(struct ur
 			   count,
 			   (int)pkt_len);
 		kaweth_resubmit_rx_urb(kaweth, GFP_ATOMIC);
-                return;
+		goto out;
 	}
 
 	if(kaweth->net && (count > 2)) {
@@ -638,12 +637,12 @@ static void kaweth_usb_receive(struct ur
 			err("Packet len & 2047: %x", pkt_len & 2047);
 			err("Count 2: %x", count2);
 		        kaweth_resubmit_rx_urb(kaweth, GFP_ATOMIC);
-                        return;
+			goto out;
                 }
 
 		if(!(skb = dev_alloc_skb(pkt_len+2))) {
 		        kaweth_resubmit_rx_urb(kaweth, GFP_ATOMIC);
-                        return;
+			goto out;
 		}
 
 		skb_reserve(skb, 2);    /* Align IP on 16 byte boundaries */
@@ -661,6 +660,8 @@ static void kaweth_usb_receive(struct ur
 	}
 
 	kaweth_resubmit_rx_urb(kaweth, GFP_ATOMIC);
+out:
+	spin_unlock_irqrestore(&kaweth->device_lock, flags);
 }
 
 /****************************************************************
@@ -778,12 +779,14 @@ static void kaweth_usb_transmit_complete
 	struct sk_buff *skb = kaweth->tx_skb;
 	int status = urb->status;
 
+	spin_lock(&kaweth->device_lock);
 	if (unlikely(status != 0))
 		if (status != -ENOENT)
 			dbg("%s: TX status %d.", kaweth->net->name, status);
 
 	netif_wake_queue(kaweth->net);
 	dev_kfree_skb_irq(skb);
+	spin_unlock(&kaweth->device_lock);
 }
 
 /****************************************************************
@@ -796,7 +799,7 @@ static int kaweth_start_xmit(struct sk_b
 
 	int res;
 
-	spin_lock(&kaweth->device_lock);
+	spin_lock_irq(&kaweth->device_lock);
 
 	kaweth_async_set_rx_mode(kaweth);
 	netif_stop_queue(net);
@@ -814,7 +817,7 @@ static int kaweth_start_xmit(struct sk_b
 		if (!copied_skb) {
 			kaweth->stats.tx_errors++;
 			netif_start_queue(net);
-			spin_unlock(&kaweth->device_lock);
+			spin_unlock_irq(&kaweth->device_lock);
 			return 0;
 		}
 	}
@@ -848,7 +851,7 @@ skip:
 		net->trans_start = jiffies;
 	}
 
-	spin_unlock(&kaweth->device_lock);
+	spin_unlock_irq(&kaweth->device_lock);
 
 	return 0;
 }
