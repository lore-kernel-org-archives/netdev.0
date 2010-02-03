From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] sky2: Flow control frames recorded as dropped packets
Date: Wed, 3 Feb 2010 10:31:12 -0800
Message-ID: <20100203103112.091b1b14@nehalam>
References: <4B69AAA9.20505@majjas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Michael Breuer <mbreuer@majjas.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:38196 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752736Ab0BCSbm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2010 13:31:42 -0500
In-Reply-To: <4B69AAA9.20505@majjas.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks for your patch.  A more general solution would be to move the
rx_dropped up into sky2_receive.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/sky2.c	2010-02-03 09:10:27.863367226 -0800
+++ b/drivers/net/sky2.c	2010-02-03 09:17:01.602741445 -0800
@@ -2404,6 +2404,9 @@ okay:
 		skb = receive_copy(sky2, re, length);
 	else
 		skb = receive_new(sky2, re, length);
+
+	dev->stats.rx_dropped += (skb == NULL);
+
 resubmit:
 	sky2_rx_submit(sky2, re);
 
@@ -2515,11 +2518,10 @@ static int sky2_status_intr(struct sky2_
 		case OP_RXSTAT:
 			total_packets[port]++;
 			total_bytes[port] += length;
+
 			skb = sky2_receive(dev, length, status);
-			if (unlikely(!skb)) {
-				dev->stats.rx_dropped++;
+			if (!skb)
 				break;
-			}
 
 			/* This chip reports checksum status differently */
 			if (hw->flags & SKY2_HW_NEW_LE) {
