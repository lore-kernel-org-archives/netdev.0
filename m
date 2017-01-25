From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: NAPI on USB network drivers
Date: Wed, 25 Jan 2017 06:13:11 -0800
Message-ID: <1485353591.5145.8.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1485336881.16604.2.camel@suse.com>
         <0835B3720019904CB8F7AA43166CEEB201A134A7@RTITMBSV06.realtek.com.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Oliver Neukum <oneukum@suse.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>
To: Hayes Wang <hayeswang@realtek.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:33840 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751866AbdAYONN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Jan 2017 09:13:13 -0500
In-Reply-To: <0835B3720019904CB8F7AA43166CEEB201A134A7@RTITMBSV06.realtek.com.tw>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-01-25 at 09:39 +0000, Hayes Wang wrote:
> Oliver Neukum [mailto:oneukum@suse.com]
> > Sent: Wednesday, January 25, 2017 5:35 PM
> [...]
> > looking at r8152 I noticed that it uses NAPI. I never considered
> > this for the generic USB networking code as you cannot disable
> > interrupts for USB. Is it still worth it? What are the benefits?
> 
> You could use napi_gro_receive() and it influences the performance.

You also could use napi_complete_done() instead of napi_complete(), as
it allows users to tune the performance vs latency for GRO.

Looking at this driver, I do not see any limitation on the number of
skbs that can be pushed into tp->rx_queue.

I wonder if this queue can end up consuming all memory of a host under
stress.

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index e1466b4d2b6c727148a884672bbd9593bf04b3ac..221df4a931b5c1073f1922d0fa0bbff158c73b7d 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -1840,7 +1840,10 @@ static int rx_bottom(struct r8152 *tp, int budget)
 				stats->rx_packets++;
 				stats->rx_bytes += pkt_len;
 			} else {
-				__skb_queue_tail(&tp->rx_queue, skb);
+				if (unlikely(skb_queue_len(&tp->rx_queue) >= 1000))
+					kfree_skb(skb);
+				else
+					__skb_queue_tail(&tp->rx_queue, skb);
 			}
 
 find_next_rx:
