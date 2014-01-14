From: David Laight <David.Laight@ACULAB.COM>
Subject: [PATCH] usbnet: Fix dma setup for fragmented packets that need a
 pad byte appended.
Date: Tue, 14 Jan 2014 11:16:02 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D45B28F@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:41564 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751580AbaANLSH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jan 2014 06:18:07 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 11668-06 for <netdev@vger.kernel.org>;
 Tue, 14 Jan 2014 11:18:05 +0000 (GMT)
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the usbnet code appends a byte to a fragmented packet (in order to avoid
sending a bulk data message that is a multiple of the USB message size) then
the scatter-gather list isn't initialised correctly.
This causes a later panic in usb_hcd_map_urb_for_dma().
Basically when the code tries to access the final sg fragment the sg function
returns NULL because the 'end of sg list' market is set in the previous one.

Bug introduced in commit 60e453a940ac678565b6641d65f8c18541bb9f28
(USBNET: fix handling padding packet) and needs applying to all
kernels that contain this change (including 3.12).

Fix from Bjorn Mork.

Signed-off-by: David Laight <david.laight@aculab.com>
---

I think it is ok that the sg table's last element is never assigned to when
the packet isn't padded.

 drivers/net/usb/usbnet.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index 8494bb5..aba04f5 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -1245,7 +1245,7 @@ static int build_dma_sg(const struct sk_buff *skb, struct urb *urb)
 		return -ENOMEM;
 
 	urb->num_sgs = num_sgs;
-	sg_init_table(urb->sg, urb->num_sgs);
+	sg_init_table(urb->sg, urb->num_sgs + 1);
 
 	sg_set_buf(&urb->sg[s++], skb->data, skb_headlen(skb));
 	total_len += skb_headlen(skb);
-- 
1.8.1.2
