From: Daniel Drake <dsd@gentoo.org>
Subject: [PATCH] zd1211rw: zd_mac_rx isn't always called in IRQ context
Date: Fri,  1 Dec 2006 00:56:50 +0000 (GMT)
Message-ID: <20061201005650.D75607B409F@zog.reactivated.net>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtaout03-winn.ispmail.ntl.com ([81.103.221.49]:11367 "EHLO
	mtaout03-winn.ispmail.ntl.com") by vger.kernel.org with ESMTP
	id S1031663AbWLAA4o (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Nov 2006 19:56:44 -0500
To: linville@tuxdriver.com
Cc: kune@deine-taler.de
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

e.g.

usb 1-7: rx_urb_complete() *** first fragment ***
usb 1-7: rx_urb_complete() *** second fragment ***
drivers/net/wireless/zd1211rw/zd_mac.c:1063 ASSERT
(((current_thread_info()->preempt_count) & (((1UL << (12))-1) << ((0 +
8) + 8)))) VIOLATED!
 [<f0299448>] zd_mac_rx+0x3e7/0x47a [zd1211rw]
 [<f029badc>] rx_urb_complete+0x22d/0x24a [zd1211rw]
 [<b028a22f>] urb_destroy+0x0/0x5
 [<b01f0930>] kref_put+0x65/0x72
 [<b0288cdf>] usb_hcd_giveback_urb+0x28/0x57
 [<b02950c4>] qh_completions+0x296/0x2f6
 [<b0294b21>] ehci_urb_done+0x70/0x7a
 [<b0294ea1>] qh_completions+0x73/0x2f6
 [<b02951bc>] ehci_work+0x98/0x538

Remove the bogus assertion, and use dev_kfree_skb_any as pointed out by
Ulrich Kunitz.

Signed-off-by: Daniel Drake <dsd@gentoo.org>

Index: linux-2.6/drivers/net/wireless/zd1211rw/zd_mac.c
===================================================================
--- linux-2.6.orig/drivers/net/wireless/zd1211rw/zd_mac.c
+++ linux-2.6/drivers/net/wireless/zd1211rw/zd_mac.c
@@ -1059,10 +1059,8 @@ int zd_mac_rx(struct zd_mac *mac, const 
 	memcpy(skb_put(skb, length), buffer, length);
 
 	r = ieee80211_rx(ieee, skb, &stats);
-	if (!r) {
-		ZD_ASSERT(in_irq());
-		dev_kfree_skb_irq(skb);
-	}
+	if (!r)
+		dev_kfree_skb_any(skb);
 	return 0;
 }
 
