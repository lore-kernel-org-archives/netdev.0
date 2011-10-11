From: Michael Tokarev <mjt@tls.msk.ru>
Subject: Re: e100 + VLANs?
Date: Tue, 11 Oct 2011 15:59:06 +0400
Message-ID: <4E942F8A.90205@msgid.tls.msk.ru>
References: <4E90212D.8030009@msgid.tls.msk.ru>	<1318091046.5276.22.camel@edumazet-laptop>	<4E9097C0.2030307@gmail.com>	<20111010101954.GB2840382@jupiter.n2.diac24.net>	<4E9307CB.4050704@msgid.tls.msk.ru>	<1318259152.3227.0.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>	<20111010151343.GB3260852@jupiter.n2.diac24.net>	<4E932278.8010802@tls.msk.ru>	<4E941198.9000307@msgid.tls.msk.ru> <CAL4WiiphpyizVaNkvOdJp1+UK53TkGw9RXnC-vzH7fTNpBAAEA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Lamparter <equinox@diac24.net>, jeffrey.t.kirsher@intel.com,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from isrv.corpit.ru ([86.62.121.231]:48061 "EHLO isrv.corpit.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752957Ab1JKL7I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Oct 2011 07:59:08 -0400
In-Reply-To: <CAL4WiiphpyizVaNkvOdJp1+UK53TkGw9RXnC-vzH7fTNpBAAEA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

11.10.2011 15:25, Eric Dumazet wrote:
>> So, is that a hardware limitation?
> 
> Its a driver bug
> 
> This comes from fact that sizeof(struct rfd) = 16
> 
> and VLAN_ETH_FRAME_LEN is 1518
> 
> driver mixes VLAN_ETH_FRAME_LEN and 1500+4+sizeof(struct rfd)   (1520, not 1518)
> 
> It therefore misses 2 bytes for large frames (VLAN tagged)
> 
> Fix is to remove VLAN_ETH_FRAME_LEN references for good...
> 
> diff --git a/drivers/net/e100.c b/drivers/net/e100.c
> index c1352c6..3287d31 100644

Hmm.  This does not _exactly_ work.

I applied it on top of 2.6.32, patch applied but with some fuzz - I checked
manually and it appears to be ok.

Now, with this patch applied, I see on the e100 side:

00:1f:c6:ef:e5:1b > 00:90:27:30:6d:1c, ethertype 802.1Q (0x8100), length 1504: vlan 6, p 0, ethertype IPv4, truncated-ip - 1 bytes missing! (tos 0x0, ttl 64, id 0, offset 0, flags [DF], proto ICMP (1), length 1487)
    10.48.6.1 > 10.48.6.2: ICMP echo request, id 27613, seq 6, length 1467

when pinging it with -s 1459 (1487 total size).

I added extra +40 for RFD_BUF_LEN define and recompiled
(this resulted in RFD_BUF_LEN=1560, - I've added a printk
just to be sure).

Now I see the same effect as before the patch:  maximum
packet size that goes and can be seen on the e100 side
is 1468(1496) (ping), which results in this on e100 side:

15:54:44.830941 00:1f:c6:ef:e5:1b > 00:90:27:30:6d:1c, ethertype 802.1Q (0x8100), length 1514: vlan 6, p 0, ethertype IPv4, (tos 0x0, ttl 64, id 0, offset 0, flags [DF], proto ICMP (1), length 1496)
    10.48.6.1 > 10.48.6.2: ICMP echo request, id 28735, seq 4, length 1476
15:54:44.831025 00:90:27:30:6d:1c > 00:1f:c6:ef:e5:1b, ethertype 802.1Q (0x8100), length 1514: vlan 6, p 0, ethertype IPv4, (tos 0x0, ttl 64, id 12010, offset 0, flags [none], proto ICMP (1), length 1496)
    10.48.6.2 > 10.48.6.1: ICMP echo reply, id 28735, seq 4, length 1476

(and it works).  With -s 1469, no ICMP packets can be seen
on e100 side.

So it still may be the hardware... :)

Thank you!

/mjt
