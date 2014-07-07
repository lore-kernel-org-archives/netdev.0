From: Jim Baxter <jim_baxter@mentor.com>
Subject: [PATCH v2 3/3] usb: gadget: NCM: Stop RX TCP Bursts getting dropped.
Date: Mon, 7 Jul 2014 18:33:19 +0100
Message-ID: <1404754399-10360-4-git-send-email-jim_baxter@mentor.com>
References: <Jim Baxter <jim_baxter@mentor.com>
 <1404754399-10360-1-git-send-email-jim_baxter@mentor.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	<linux-usb@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Laight <David.Laight@ACULAB.COM>,
	<netdev@vger.kernel.org>
To: Felipe Balbi <balbi@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay1.mentorg.com ([192.94.38.131]:35207 "EHLO
	relay1.mentorg.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752342AbaGGRd6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jul 2014 13:33:58 -0400
In-Reply-To: <1404754399-10360-1-git-send-email-jim_baxter@mentor.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This fixes a problem with dropped packets over 16k CDC-NCM
when the connection is being heavily used.

The issue was that the extracted frames cloned from the
received frame were consuming more memory than necessary
resulting in the truesize being ~32KB instead of ~2KB, this
meant there was a high chance of reaching the sk_rcvbuf
limit.

Signed-off-by: Jim Baxter <jim_baxter@mentor.com>
Acked-by: Eric Dumazet <edumazet@google.com>
---

Updated the commit message to accurately describe the issue.

 drivers/usb/gadget/f_ncm.c |   15 ++++++++-------
 1 file changed, 8 insertions(+), 7 deletions(-)

diff --git a/drivers/usb/gadget/f_ncm.c b/drivers/usb/gadget/f_ncm.c
index 5452fb6..bcdc882 100644
--- a/drivers/usb/gadget/f_ncm.c
+++ b/drivers/usb/gadget/f_ncm.c
@@ -1229,16 +1229,17 @@ static int ncm_unwrap_ntb(struct gether *port,
 			index2 = get_ncm(&tmp, opts->dgram_item_len);
 			dg_len2 = get_ncm(&tmp, opts->dgram_item_len);
 
-			skb2 = skb_clone(skb, GFP_ATOMIC);
+			/*
+			 * Copy the data into a new skb.
+			 * This ensures the truesize is correct
+			 */
+			skb2 = netdev_alloc_skb_ip_align(ncm->netdev,
+							 dg_len - crc_len);
 			if (skb2 == NULL)
 				goto err;
+			memcpy(skb_put(skb2, dg_len - crc_len),
+			       skb->data + index, dg_len - crc_len);
 
-			if (!skb_pull(skb2, index)) {
-				ret = -EOVERFLOW;
-				goto err;
-			}
-
-			skb_trim(skb2, dg_len - crc_len);
 			skb_queue_tail(list, skb2);
 
 			ndp_len -= 2 * (opts->dgram_item_len * 2);
-- 
1.7.9.5
