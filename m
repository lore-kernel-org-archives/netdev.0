From: "John A. Sullivan III" <jsullivan@opensourcedevel.com>
Subject: Re: SFQ on HFSC leaf does not seem to work
Date: Sat, 31 Dec 2011 17:17:21 -0500
Message-ID: <1325369841.4174.47.camel@denise.theartistscloset.com>
References: <1324620022.10184.100.camel@denise.theartistscloset.com>
	 <1324627808.10854.6.camel@edumazet-laptop>
	 <1324645986.10184.571.camel@denise.theartistscloset.com>
	 <1324647920.2223.14.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1324648822.2223.18.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1324651128.10184.586.camel@denise.theartistscloset.com>
	 <1324652361.2223.31.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1324654013.10184.597.camel@denise.theartistscloset.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.perfora.net ([74.208.4.195]:58928 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753251Ab1LaWR3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 31 Dec 2011 17:17:29 -0500
In-Reply-To: <1324654013.10184.597.camel@denise.theartistscloset.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-12-23 at 10:26 -0500, John A. Sullivan III wrote:
> <snip>> 
> > > tc filter add dev ifb0 parent 1:0 protocol ip prio 1 u32 ht 6:0 match
> > > tcp src 443 0x00ff flowid 1:10
> > 
> > why "src 443 0x00ff" ? It should be "src 443 0xffff"
> That's what I tried at first but nothing matched the filter.  I assumed
> it was because it objected to a value in the dst field so I masked it
> off and it worked.
> > 
> > > tc filter add dev ifb0 parent 1:0 protocol ip prio 1 u32 ht 6:0 match
> > > tcp dst 822 0xff00 flowid 1:30
> > 
> > same here : "dst 822 0xffff"
> Same as above.  No filter matches when using that mask.
> > 
<snip>
Oops! Must have not matched for some other reason - this is a clear
binary brain cramp! This now appears to be working:

tc filter add dev ifb0 parent 1:0 protocol ip prio 1 handle 6: u32 divisor 1
tc filter add dev ifb0 parent 1:0 protocol ip prio 1 u32 match ip protocol 6 0xff link 6: offset at 0 mask 0x0f00 shift 6 plus 0
tc filter add dev ifb0 parent 1:0 protocol ip prio 1 u32 ht 6:0 match tcp dst 822 0xffff at nexthdr+2 flowid 1:30
tc filter add dev ifb0 parent 1:0 protocol ip prio 1 u32 ht 6:0 match tcp src 822 0xffff at nexthdr+0 flowid 1:30
# Send packets <64 bytes (u16 0 0xffc0 at 2) with only the ACK flag set (match u8 16 0xff at nexthdr+13) to the low latency queue
tc filter add dev ifb0 parent 1:0 protocol ip prio 1 u32 ht 6:0 match u16 0 0xffc0 at 2 match u8 16 0xff at nexthdr+13 flowid 1:30
tc filter add dev ifb0 parent 1:0 protocol ip prio 1 u32 ht 6:0 match tcp src 443 0xffff at nexthdr+0 flowid 1:10

Thanks - John
