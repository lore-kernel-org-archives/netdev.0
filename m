From: Timo Teras <timo.teras@iki.fi>
Subject: via-velocity skb_over_panic
Date: Fri, 13 Nov 2015 18:49:47 +0200
Message-ID: <20151113184947.09d57da5@vostro>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f176.google.com ([209.85.217.176]:34005 "EHLO
	mail-lb0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932444AbbKMQty (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Nov 2015 11:49:54 -0500
Received: by lbbcs9 with SMTP id cs9so57053677lbb.1
        for <netdev@vger.kernel.org>; Fri, 13 Nov 2015 08:49:52 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I recently saw via-velocity skb_over_panic() on one of my locations.
The panic happened with two separate hardware devices, so it appears to
be network related, not broken hardware.

I did not get the actual over_panic printk, as I got only screen shot
of them monitor. But the visible part of call trace says:
 <IRQ>
 skb_put
 velocity_poll
 net_rx_action
 __do_softirq
 irq_exit
 common_interrupt
 <EOI>

The was recurring every few hours, so I patched via-velocity with the
following after looking the code a bit:

--- a/drivers/net/ethernet/via/via-velocity.c
+++ b/drivers/net/ethernet/via/via-velocity.c
@@ -2060,6 +2060,11 @@ static int velocity_receive_frame(struct velocity_info *vptr, int idx)
 		stats->rx_length_errors++;
 		return -EINVAL;
 	}
+	if (pkt_len < 4 || pkt_len > vptr->rx.buf_sz) {
+		VELOCITY_PRT(MSG_LEVEL_VERBOSE, KERN_ERR " %s : the received frame size %d is inconsistent.\n", vptr->netdev->name, pkt_len);
+		stats->rx_length_errors++;
+		return -EINVAL;
+	}
 
 	if (rd->rdesc0.RSR & RSR_MAR)
 		stats->multicast++;

This seems to have fixed the panics. And I do see one of the NIC's
ethtool report's in_range_length_errors increasing once in a while. For
some reason I don't see the above debug message though, so I'm not sure
on what pkt_len triggers it.

In any case, the cade a bit later on does unconditionally:
	skb_put(skb, pkt_len - 4);

So it's possible that some bad packets make the NIC return unexpected
packet sizes, and the current code can panic on it.

Any suggestions for better fix?

Thanks,
Timo
