From: Jan Oravec <jan.oravec@6com.sk>
Subject: Re: IPv6/sparc64: icmp port unreachable corruption
Date: Tue, 11 Nov 2003 23:26:11 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031111222611.GA1239@wsx.ksp.sk>
References: <20031109122844.GA14241@wsx.ksp.sk> <20031110214603.0057e365.davem@redhat.com>
Reply-To: Jan Oravec <jan.oravec@6com.sk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20031110214603.0057e365.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> > We do traceroute6 to 3ffe:80ee:3bd:0:a00:20ff:fec7:a192 (IP of that
> > sparc64). We get the following corrupted answer:
> > 
> > 13:17:47.191547 3ffe:80ee:3bd:0:a00:20ff:fec7:a192 > 3ffe:80ee:a:0:201:3ff:fed5:bd1e: [|icmp6] (len 72, hlim 62)
> > 0x0000   6000 0000 0048 3a3e 3ffe 80ee 03bd 0000        ....H:>?.......
> > 0x0010   0a00 20ff fec7 a192 3ffe 80ee 000a 0000        ........?.......
> > 0x0020   0201 03ff fed5 bd1e 0104 aa7c 0000 0000        ...........|....
> > 0x0030   0000 0064 0000 0000 0100 0000 0100 0000        ...d............
> > 0x0040   aaaa aaaa aaaa aaaa 9680 c00b c622 7fec        ............."..
> > 0x0050   aaaa aaaa aaaa aaaa 9680 c00b c622 7ffc        ............."..
> > 0x0060   aaaa aaaa 0000 0000 8a10 2000 04c2 8049        ...............I
> 
> What specifically about this packet makes you think it is corrupted?

The ICMP reply should contain the original packet.


> What compiler are you using to build 2.6.x kernels btw?  We could
> be looking at a miscompile here.

3.3.2


> The bus error you reported from running traceroute6 on the sparc64
> system is not that useful, can you use gdb or some other tool to
> figure out where inside of tcpdump6 the bus error is occuring?  Is is
> happening in the tcpdump6 program itself?  It is due to a failed system
> call?

I am running 64-bit-only userspace and there is no gdb/strace for sparc64
yet :(.


But I think I have found the problem:

icmpv6_send() can get skb where skb->nh.raw < skb->data, thus computed plen
(see icmp.c:382) is negative. When passed as unsigned int to __skb_pull, it
underflows and is interpreted as 0x100000000-something_small. In __skb_pull
we then increase skb->data by that number; because skb->data is 64-bit while
plen is 32-bit, we get pointer which is 0x100000000 higher than needed. On
32-bit platform that does not cause any troubles because it overflows again.

I do not know whether icmpv6_send() was meant to receive skb with ->data
pulled no more than nh.raw; in that case I suggest the following patch
(against test9-bk16):

--- linux/net/ipv6/udp.c.orig	2003-11-11 23:04:08.393138608 +0100
+++ linux/net/ipv6/udp.c	2003-11-11 23:07:20.964089789 +0100
@@ -677,6 +677,7 @@
 			goto discard;
 		UDP6_INC_STATS_BH(UdpNoPorts);
 
+		__skb_push(skb, skb->data - skb->nh.raw);
 		icmpv6_send(skb, ICMPV6_DEST_UNREACH, ICMPV6_PORT_UNREACH, 0, dev);
 
 		kfree_skb(skb);



I looked at the other icmpv6_send() calls; they seem to be OK (not 100%
sure).

Instead, if we want make icmpv6_send to work with any ->data, we could use this
patch:

--- linux/net/ipv6/icmp.c.orig	2003-10-25 20:43:17.000000000 +0200
+++ linux/net/ipv6/icmp.c	2003-11-11 23:23:09.661409756 +0100
@@ -380,7 +380,11 @@
 	}
 
 	plen = skb->nh.raw - skb->data;
-	__skb_pull(skb, plen);
+	if (plen < 0)
+		__skb_push(skb, -plen);
+	else
+		__skb_pull(skb, plen);
+
 	len = skb->len;
 	len = min_t(unsigned int, len, IPV6_MIN_MTU - sizeof(struct ipv6hdr) -sizeof(struct icmp6hdr));
 	if (len < 0) {
@@ -399,7 +403,10 @@
 		goto out_put;
 	}
 	err = icmpv6_push_pending_frames(sk, &fl, &tmp_hdr, len + sizeof(struct icmp6hdr));
-	__skb_push(skb, plen);
+	if (plen < 0)
+		__skb_pull(skb, -plen);
+	else
+		__skb_push(skb, plen);
 
 	if (type >= ICMPV6_DEST_UNREACH && type <= ICMPV6_PARAMPROB)
 		ICMP6_INC_STATS_OFFSET_BH(idev, Icmp6OutDestUnreachs, type - ICMPV6_DEST_UNREACH);


Jan
