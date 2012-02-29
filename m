From: "John A. Sullivan III" <jsullivan@opensourcedevel.com>
Subject: Re: tc filter hash table efficiency
Date: Tue, 28 Feb 2012 23:10:38 -0500
Message-ID: <1330488638.4671.103.camel@denise.theartistscloset.com>
References: <1330487718.4671.102.camel@denise.theartistscloset.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.perfora.net ([74.208.4.195]:55843 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965474Ab2B2EKl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Feb 2012 23:10:41 -0500
In-Reply-To: <1330487718.4671.102.camel@denise.theartistscloset.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The first two UDP lines should use a parent of 62:0 and not 20:0 -
copied from old documentation :(  I'll change it below - John

On Tue, 2012-02-28 at 22:55 -0500, John A. Sullivan III wrote:
> Hello, all.  Would it be correct to assume that tc filter hash tables
> are like iptables user defined chains and can be used to reduce the
> number of evaluations which must be made for each packet or is there
> significant additional overhead incurred by such hash tables?
> 
> We are finding this isn't working for us.
> 
> For example, we wanted to shape VoIP packets in ingress to our PBX from
> both VPN and direct Internet connections.  Since the ifb interface gets
> the packet before NAT, we must account for both the public and internal
> destination addresses.  We also need to match several possible port
> ranges to match any UDP ports over 4096 because of the way tc filter
> ranges are masked.  So we did the following:
> 
> # UDP
> tc filter replace dev ifb0 parent 62:0 protocol ip prio 2 handle 627:
> u32 divisor 1
> tc filter replace dev ifb0 parent 62:0 protocol ip prio 2 u32 match ip
> protocol 17 0xff link 627: offset at 0 mask 0x0f00 shift 6 plus 0
> 
> That is, we created a hash table for all UDP packets with an accurate
> pointer to the beginning of the UDP header.
> 
> 
> # VoIP - UDP packets to the VoIP network under 256 Bytes over port 1024
> tc filter replace dev ifb0 parent 62:0 protocol ip prio 2 handle 628:
> u32 divisor 1
> tc filter replace dev ifb0 parent 62:0 protocol ip prio 2 u32 ht 627:0
> match ip dst 172.x.x.0/24 match u16 0 0xffc0 at 2 link 628:
> tc filter replace dev ifb0 parent 62:0 protocol ip prio 2 u32 ht 627:0
> match ip dst 208.z.z.z match u16 0 0xffc0 at 2 link 628:
> 
> That is, we create another hash linked from the UDP hash table so we
> only have to evaluate the IP type once and dump all small packets
> destined for either the NAT or real address to that hash table
> 
> tc filter replace dev ifb0 parent 62:0 protocol ip prio 2 u32 ht 628:0
> match udp dst 32768 0x8000 at nexthdr+2 flowid 62:20
> tc filter replace dev ifb0 parent 62:0 protocol ip prio 2 u32 ht 628:0
> match udp dst 16384 0x4000 at nexthdr+2 flowid 62:20
> tc filter replace dev ifb0 parent 62:0 protocol ip prio 2 u32 ht 628:0
> match udp dst 8192 0x2000 at nexthdr+2 flowid 62:20
> tc filter replace dev ifb0 parent 62:0 protocol ip prio 2 u32 ht 628:0
> match udp dst 4096 0x1000 at nexthdr+2 flowid 62:20
> 
> And then create filters for the various port ranges.  We figured this
> way, we only had to evaluate the IP protocol once instead of two or
> three times; we only had to evaluate the destination address and packet
> size once instead of twice, and needed only four packet size rules
> instead of four for each IP address.
> 
> Is this a proper use of hash tables or have I really abused the concept?
> When we look at the filter stats, we see:
> 
>  tc -s filter show dev ifb0
> filter parent 62: protocol ip pref 1 u32
> filter parent 62: protocol ip pref 1 u32 fh 800: ht divisor 1
> filter parent 62: protocol ip pref 1 u32 fh 800::800 order 2048 key ht 800 bkt 0 flowid 62:50  (rule hit 37879 success 295)
>   match 00320000/00ff0000 at 8 (success 295 )
> filter parent 62: protocol ip pref 1 u32 fh 800::801 order 2049 key ht 800 bkt 0 flowid 62:40  (rule hit 37584 success 7866)
>   match d02e5d08/ffffffff at 16 (success 7868 )
>   match 00060000/00ff0000 at 8 (success 7866 )
> filter parent 62: protocol ip pref 2 u32
> filter parent 62: protocol ip pref 2 u32 fh 628: ht divisor 1
> filter parent 62: protocol ip pref 2 u32 fh 628::800 order 2048 key ht 628 bkt 0 flowid 62:20  (rule hit 35 success 0)
>   match 00008000/00008000 at nexthdr+0 (success 0 )
> filter parent 62: protocol ip pref 2 u32 fh 628::801 order 2049 key ht 628 bkt 0 flowid 62:20  (rule hit 35 success 0)
>   match 00004000/00004000 at nexthdr+0 (success 0 )
> filter parent 62: protocol ip pref 2 u32 fh 628::802 order 2050 key ht 628 bkt 0 flowid 62:20  (rule hit 35 success 0)
>   match 00002000/00002000 at nexthdr+0 (success 0 )
> filter parent 62: protocol ip pref 2 u32 fh 628::803 order 2051 key ht 628 bkt 0 flowid 62:20  (rule hit 35 success 33)
>   match 00001000/00001000 at nexthdr+0 (success 33 )
> filter parent 62: protocol ip pref 2 u32 fh 627: ht divisor 1
> filter parent 62: protocol ip pref 2 u32 fh 627::800 order 2048 key ht 627 bkt 0 link 628:  (rule hit 11617 success 0)
>   match axxxxe00/ffffff00 at 16 (success 4847 )
>   match 00000000/0000ffc0 at 0 (success 35 )
> filter parent 62: protocol ip pref 2 u32 fh 627::801 order 2049 key ht 627 bkt 0 link 628:  (rule hit 11584 success 0)
>   match d0yyyy0e/ffffffff at 16 (success 20 )
>   match 00000000/0000ffc0 at 0 (success 0 )
> 
> yet packet traces show oodles of 200 byte UDP packets on ports over
> 10000 destined for the PBX yet I see only a handful of packets flowing
> into class 62:20.
> 
> Thanks - John
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
