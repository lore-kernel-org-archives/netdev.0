From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 1/2 V2] kaweth: Fix locking to be SMP-safe
Date: Tue, 31 Mar 2009 13:45:49 -0500
Message-ID: <49d264dd.YwbXLw18YaD1tQqD%Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	oliver@neukum.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from hrndva-omtalb.mail.rr.com ([71.74.56.123]:37578 "EHLO
	hrndva-omtalb.mail.rr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763496AbZCaSp7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Mar 2009 14:45:59 -0400
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
