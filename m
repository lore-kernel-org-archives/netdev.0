From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169: panic on 2.6.11
Date: Sat, 5 Mar 2005 01:37:35 +0100
Message-ID: <20050305003735.GE1148@electric-eye.fr.zoreil.com>
References: <20050304132804.270cf05b@dxpl.pdx.osdl.net> <20050304145317.772859da@dxpl.pdx.osdl.net> <20050304230214.GC1148@electric-eye.fr.zoreil.com> <200503041728.54026.jdmason@us.ibm.com> <20050304154903.7b7e0fb1@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jon Mason <jdmason@us.ibm.com>, netdev@oss.sgi.com
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20050304154903.7b7e0fb1@dxpl.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Stephen Hemminger <shemminger@osdl.org> :
[...]
> Added this and took out "too much work at interrupt message"

Ok (leaks but see below).

> And got this (before it died):
> 
> eth0: status=803ff0 opts=803ff0 opts2=0 addr=0:106ad012
                           ^^^^^^
3ff0 would be a ~16k packet. The high weight byte is
missing: the descriptor would be strictly somewhere between
the first descriptor and the last descriptor for the packet.

opts=80xxxx -> FIFO overflow (*bulb flashes*)

The code does not look pretty there.

Can you add something like the patch below on top of your
current patch (untested but you get the idea):

diff -puN drivers/net/r8169.c~r8169-480 drivers/net/r8169.c
--- linux-2.6.11/drivers/net/r8169.c~r8169-480	2005-03-05 00:16:58.575516900 +0100
+++ linux-2.6.11-fr/drivers/net/r8169.c	2005-03-05 01:32:20.122261946 +0100
@@ -240,6 +241,7 @@ enum RTL8169_register_content {
 	RxOK = 0x01,
 
 	/* RxStatusDesc */
+	RxOVF = 0x00800000,
 	RxRES = 0x00200000,
 	RxCRC = 0x00080000,
 	RxRUNT = 0x00100000,
@@ -2181,13 +2183,14 @@ rtl8169_rx_interrupt(struct net_device *
 
 		if (status & DescOwn)
 			break;
-		if (status & RxRES) {
+		if (status & (RxRES | RxOVF)) {
 			printk(KERN_INFO "%s: Rx ERROR!!!\n", dev->name);
 			tp->stats.rx_errors++;
 			if (status & (RxRWT | RxRUNT))
 				tp->stats.rx_length_errors++;
 			if (status & RxCRC)
 				tp->stats.rx_crc_errors++;
+			rtl8169_return_to_asic(tp->RxDescArray + entry, tp->rx_buf_sz);
 		} else {
 			struct RxDesc *desc = tp->RxDescArray + entry;
 			struct sk_buff *skb = tp->Rx_skbuff[entry];

_

/me goes to bed.

Out of curiosity it would be interesting to see how non-PREEMPT and NAPI behaves (the
rings are surely too small).

--
Ueimor
