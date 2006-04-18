From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [patch] Re: r8169 locks up in 2.6.16.5
Date: Wed, 19 Apr 2006 01:04:27 +0200
Message-ID: <20060418230427.GA4639@electric-eye.fr.zoreil.com>
References: <20060415204716.GA1755@jupiter.toms.net> <20060416005821.GA9821@electric-eye.fr.zoreil.com> <20060416134201.GA2681@jupiter.toms.net> <20060416144354.GA11433@electric-eye.fr.zoreil.com> <20060416172639.GA12243@jupiter.toms.net> <20060416195327.GA14173@electric-eye.fr.zoreil.com> <20060416225843.GA2274@jupiter.toms.net> <20060417230927.GA8893@electric-eye.fr.zoreil.com> <20060418004358.GA8967@jupiter.toms.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:45463 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S1750792AbWDRXFa
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Apr 2006 19:05:30 -0400
To: "Thomas A. Oehser" <tom@toms.net>
Content-Disposition: inline
In-Reply-To: <20060418004358.GA8967@jupiter.toms.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thomas A. Oehser <tom@toms.net> :
[...]
> It is actually about a 30GB transfer, it was just after the first
> 170Mb that it failed.  The command in question is just a simple
> "nc -l -p 12345|buffer|cpio -iumdB", and the sender may well be
> able to generate the data faster than the receiving disk can save
> it, as the sender is a raid-1 mirror and the receiver is a raid-5
> array, I would expect the raid-5 write penalty and the raid-1 read
> speed to make it have to block for most of the transfer.  It didn't
> take long to get that far- um, I think only 2 or 3 minutes before
> it locked up.

The r8169 offers 48 kb of Rx fifo. 170 Mb in 2~3 minutes is under 2 Mb/s.
Even if the traffic is very bursty, something seems to stall the PCI bus.
I'm a bit surprized.

Anyway, can you give the patch below a try and tell if it changes
something ? If so, an updated output of 'ethtool -S' would be welcome.

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 0ad3310..f9da390 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -256,10 +256,11 @@ enum RTL8169_register_content {
 	RxOK = 0x01,
 
 	/* RxStatusDesc */
-	RxRES = 0x00200000,
-	RxCRC = 0x00080000,
-	RxRUNT = 0x00100000,
-	RxRWT = 0x00400000,
+	RxFOVF	= (1 << 23),
+	RxRWT	= (1 << 22),
+	RxRES	= (1 << 21),
+	RxRUNT	= (1 << 20),
+	RxCRC	= (1 << 19),
 
 	/* ChipCmdBits */
 	CmdReset = 0x10,
@@ -2435,6 +2436,10 @@ rtl8169_rx_interrupt(struct net_device *
 				tp->stats.rx_length_errors++;
 			if (status & RxCRC)
 				tp->stats.rx_crc_errors++;
+			if (status & RxFOVF) {
+				rtl8169_schedule_work(dev, rtl8169_reset_task);
+				tp->stats.rx_fifo_errors++;
+			}
 			rtl8169_mark_to_asic(desc, tp->rx_buf_sz);
 		} else {
 			struct sk_buff *skb = tp->Rx_skbuff[entry];
