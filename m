From: Thomas Graf <tgraf@suug.ch>
Subject: Re: skb_checksum_help
Date: Mon, 24 Jan 2005 01:32:41 +0100
Message-ID: <20050124003241.GJ23931@postel.suug.ch>
References: <41F432BD.3000300@davidcoulson.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: David Coulson <david@davidcoulson.net>
Content-Disposition: inline
In-Reply-To: <41F432BD.3000300@davidcoulson.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* David Coulson <41F432BD.3000300@davidcoulson.net> 2005-01-23 18:26
> I got this out of one of my boxes today - I'm not 100% sure what the 
> output is prior to the TSC error, but I figure they're probably 
> associated. I forgot to compile in CONFIG_RTC on this box (It's SMP 
> using a HT P4 CPU), so I'll stick a fresh kernel on it.
> 
> Anyway, hope the hex output makes sense to you :-)

I CC'ed netdev, this seems more serious than I thought.

Background: David noticed the assertion csum + 2 > offset being trigged
in skb_checksum_help. I sent him a patch converting it into a warning
printing offset, len, n.raw, tail, csum, features and the whole packet
as hexdump. He uses the acenic driver which is actually capable of doing
IP checksumming. (Patch enclosed at the end)

> <4>Losing too many ticks!
> TSC cannot be used as a timesource.
> Possible reasons for this are:
>   You're running with Speedstep,
>   You don't have DMA enabled for your hard disk (see hdparm),
>   Incorrect TSC synchronization on an SMP system (see dmesg).
> Falling back to a sane timesource now.

Not related.

> offset=345 len=379 n=e859c024 tail=e859c17d csum=0xf69c
> features: 0

features == 0, this looks very wrong, also explains why it
actually tries to do software checksumming even if your
card can do it in hardware.

> skb hdr corrupted!

not good, this explains why the checksum is wrong. skb->h.raw
is < skb->data.

Let's enable the brain network parser for your hex dumps.

> 00 d0 b7 a6 ba e3 00 02 e3 00 09 31 08 00

Ethernet header:
  From: 00:d0:b7:a6:ba:e3
  To:   00:02:e3:00:09:31
  Protocol: 0x0800 (IP)

> 45 00 01 6d b9 8d 00 b9 31 11 7b 08 d3 20 75 0b 0a 01 01 05

Version: 4
IHL: 5
DSCP: 00
Length: 365 bytes, so len=379 above is correct (365+14 ether)
ID: 0xb98d
Flags: 0
Fragment Offset: 185
TTL: 49 [0]
Protocol: 17 (UDP)
Checksum: 0x7b08
Source: 211.32.117.11 (korean ip)
Destination: 10.1.1.5

[0] The originator of this packet is likely a BSD based
UNIX box. It is unlikely that it dropped to 49 from 128
which I think is the base TTL windows uses. Only guessing
though.

The payload doesn't look special at a first glance
but align it correctly and you'll get:

> 00 01 00 01 00 01 51 80 00 04 d3 2b c5 6c c0 90
> 00 01 00 01 00 01 51 80 00 04 d3 2b c5 6d c0 90
> 00 01 00 01 00 01 51 80 00 04 d3 2b c5 68 c0 90
> 00 01 00 01 00 01 51 80 00 04 d3 2b c5 29 c0 90
> 00 01 00 01 00 01 51 80 00 04 d3 2b c5 0a c0 90
> 00 01 00 01 00 01 51 80 00 04 d3 2b c5 45 c0 90
> 00 01 00 01 00 01 51 80 00 04 d3 2b c5 50 c0 90
> 00 01 00 01 00 01 51 80 00 04 d3 2b c5 88 c0 90
> 00 01 00 01 00 01 51 80 00 04 d3 2b c5 84 c0 90
> 00 01 00 01 00 01 51 80 00 04 d3 2b c5 92 c0 90
> 00 01 00 01 00 01 51 80 00 04 d3 2b c5 9c c0 90
> 00 01 00 01 00 01 51 80 00 04 d3 2b c5 b6 c0 90
> 00 01 00 01 00 01 51 80 00 04 d3 2b c5 b7 c0 90
> 00 01 00 01 00 01 51 80 00 04 d3 2b c5 b8 c0 90
> 00 01 00 01 00 01 51 80 00 04 d3 2b c5 b9 c0 90
> 00 01 00 01 00 01 51 80 00 04 d3 2b c5 ba c0 90
> 00 01 00 01 00 01 51 80 00 04 d3 2b c5 7f c0 90
> 00 01 00 01 00 01 51 80 00 04 de e7 23 15 c0 90
> 00 01 00 01 00 01 51 80 00 04 de e7 23 17 c0 f2
> 00 01 00 01 00 01 51 80 00 04 d3 20 75 0a c1 08
> 00 01 00 01 00 01 51 80 00 04 d3 20 75 0b 00 00
> 29 10 00 00 00 00 00 00 00

It _could_ be nothing but still looks very suspicous.

Next fragment:

[ Same ethernet header ]
[ Same IP header except: ]

Length: 477
ID: 0xb525
Flags: 0
Fragment Offset: 185
Checksum: 0x7f01
Source: 211.32.117.12
Destination: 10.1.1.5

Same source incremented by 1.

> 00 01 00 01 00 01 51 80 00 04 d3 2b c5 b6 c0 7c
> 00 01 00 01 00 01 51 80 00 04 d3 2b c5 b7 c0 7c
> 00 01 00 01 00 01 51 80 00 04 d3 2b c5 b8 c0 7c
> 00 01 00 01 00 01 51 80 00 04 d3 2b c5 b9 c0 7c
> 00 01 00 01 00 01 51 80 00 04 d3 2b c5 ba c0 7c
> 00 01 00 01 00 01 51 80 00 04 d3 2b c5 7f c0 7c
> 00 01 00 01 00 01 51 80 00 04 de e7 23 15 c0 7c
> 00 01 00 01 00 01 51 80 00 04 de e7 23 17 c0 90
> 00 01 00 01 00 01 51 80 00 04 d3 2b c5 6e c0 90
> 00 01 00 01 00 01 51 80 00 04 d3 2b c5 2a c0 90
> 00 01 00 01 00 01 51 80 00 04 d3 2b c5 0b c0 90
> 00 01 00 01 00 01 51 80 00 04 d3 2b c5 46 c0 90
> 00 01 00 01 00 01 51 80 00 04 d3 2b c5 47 c0 90
> 00 01 00 01 00 01 51 80 00 04 d3 2b c5 48 c0 90
> 00 01 00 01 00 01 51 80 00 04 d3 2b c5 51 c0 90
> 00 01 00 01 00 01 51 80 00 04 d3 2b c5 89 c0 90
> 00 01 00 01 00 01 51 80 00 04 d3 2b c5 93 c0 90
> 00 01 00 01 00 01 51 80 00 04 d3 2b c5 9d c0 90
> 00 01 00 01 00 01 51 80 00 04 d3 2b c5 bb c0 90
> 00 01 00 01 00 01 51 80 00 04 d3 2b c5 bc c0 90
> 00 01 00 01 00 01 51 80 00 04 d3 2b c5 bd c0 90
> 00 01 00 01 00 01 51 80 00 04 d3 2b c5 be c0 90
> 00 01 00 01 00 01 51 80 00 04 d3 2b c5 bf c0 90
> 00 01 00 01 00 01 51 80 00 04 d3 2b c5 80 c0 90
> 00 01 00 01 00 01 51 80 00 04 de e7 23 18 c0 90
> 00 01 00 01 00 01 51 80 00 04 de e7 23 19 c0 f2
> 00 01 00 01 00 01 51 80 00 04 d3 20 75 0a c1 08
> 00 01 00 01 00 01 51 80 00 04 d3 20 75 0b 00 00
> 29 10 00 00 00 00 00 00 00

Very similiar again.

Next fragment:

Length: 477
ID: 0xb525
Flags: 0
Fragment Offset: 185
Checksum: 0x7f01
Source: 211.32.117.11
Destination: 10.1.15

Back to the first IP, same payload as first packet.

Without further inspection I'd guess this is just junk traffic of some
stupid tool trying to screw up ip stacks and it seems to be quite
sucessful. I'll try to investigate some more later on, there must be
some serious memory corruption happening.

--- linux-2.6.10-bk14.orig/net/core/dev.c	2005-01-13 10:56:33.000000000 +0100
+++ linux-2.6.10-bk14/net/core/dev.c	2005-01-15 23:38:03.000000000 +0100
@@ -1096,8 +1096,27 @@
 	offset = skb->tail - skb->h.raw;
 	if (offset <= 0)
 		BUG();
-	if (skb->csum + 2 > offset)
-		BUG();
+	if (skb->csum + 2 > offset) {
+		int l = 0;
+		u8 *p;
+
+		if (!skb_shinfo(skb)->nr_frags) {
+			for (p = skb->data; p < skb->tail; p++) {
+				printk("%02x ", *p);
+				if (++l == 20) {
+					printk("\n");
+					l = 0;
+				}
+			}
+		} else
+			printk("paged skb, not printing\n");
+		printk(KERN_CRIT "offset=%d len=%d n=%p tail=%p csum=0x%x\n",
+		    offset, skb->len, skb->h.raw, skb->tail, skb->csum);
+		printk(KERN_CRIT "features: %x\n", skb->dev->features);
+		if (skb->h.raw < skb->data || skb->h.raw > skb->data)
+			printk(KERN_CRIT "skb hdr corrupted!\n");
+		goto out;
+	}
 
 	*(u16*)(skb->h.raw + skb->csum) = csum_fold(csum);
 	skb->ip_summed = CHECKSUM_NONE;
