From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: [PATCH net-next 3/5] ipv6: Stop /128 route from disappearing
 after pmtu update
Date: Sat, 2 May 2015 18:00:55 -0700
Message-ID: <20150503010055.GC2731450@devbig242.prn2.facebook.com>
References: <1430251387-2942539-1-git-send-email-kafai@fb.com>
 <1430251387-2942539-4-git-send-email-kafai@fb.com>
 <m2d22itxe2.wl@sfc.wide.ad.jp>
 <20150502232040.GB2731450@devbig242.prn2.facebook.com>
 <m2bni2tsv0.wl@sfc.wide.ad.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <hannes@stressinduktion.org>,
	<steffen.klassert@secunet.com>, <davem@davemloft.net>,
	<yangyingliang@huawei.com>, <shengyong1@huawei.com>,
	<Kernel-team@fb.com>
To: Hajime Tazaki <tazaki@sfc.wide.ad.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:23617 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750807AbbECBBn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 May 2015 21:01:43 -0400
Content-Disposition: inline
In-Reply-To: <m2bni2tsv0.wl@sfc.wide.ad.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, May 03, 2015 at 09:19:47AM +0900, Hajime Tazaki wrote:
> At Sat, 2 May 2015 16:20:40 -0700,
> Martin KaFai Lau wrote:
> > Can you provide a tcpdump at both ends?  Also, the output of
> > the 'ip -6 a' and 'ip -6 r show'.
>
> - tcpdump -vvv
> 09:00:00.200000 IP6 (hlim 255, next-header ICMPv6 (58) payload length: 16) fe80::200:ff:fe00:1 > ff02::2: [icmp6 sum ok] ICMP6, router solicitation, length 16
>           source link-address option (1), length 8 (1): 00:00:00:00:00:01
>             0x0000:  0000 0000 0001
> 09:00:00.401092 IP6 (hlim 255, next-header ICMPv6 (58) payload length: 16) fe80::200:ff:fe00:2 > ff02::2: [icmp6 sum ok] ICMP6, router solicitation, length 16
>           source link-address option (1), length 8 (1): 00:00:00:00:00:02
>             0x0000:  0000 0000 0002
> 09:00:01.000000 IP6 (hlim 64, next-header ICMPv6 (58) payload length: 1008) 2001:1::1 > 2001:1::2: [icmp6 sum ok] ICMP6, echo request, seq 1
> 09:00:02.000000 IP6 (hlim 64, next-header ICMPv6 (58) payload length: 1008) 2001:1::1 > 2001:1::2: [icmp6 sum ok] ICMP6, echo request, seq 2
> 09:00:03.000000 IP6 (hlim 64, next-header ICMPv6 (58) payload length: 1008) 2001:1::1 > 2001:1::2: [icmp6 sum ok] ICMP6, echo request, seq 3
> 09:00:04.000000 IP6 (hlim 64, next-header ICMPv6 (58) payload length: 1008) 2001:1::1 > 2001:1::2: [icmp6 sum ok] ICMP6, echo request, seq 4
> 09:00:04.200000 IP6 (hlim 255, next-header ICMPv6 (58) payload length: 16) fe80::200:ff:fe00:1 > ff02::2: [icmp6 sum ok] ICMP6, router solicitation, length 16
>           source link-address option (1), length 8 (1): 00:00:00:00:00:01
>             0x0000:  0000 0000 0001
> 09:00:04.401092 IP6 (hlim 255, next-header ICMPv6 (58) payload length: 16) fe80::200:ff:fe00:2 > ff02::2: [icmp6 sum ok] ICMP6, router solicitation, length 16
>           source link-address option (1), length 8 (1): 00:00:00:00:00:02            0x0000:  0000 0000 0002
Was it captured at the sender side?
Did the receiver (2001:1::2) get the echo request?

> (snip)
> 
> - 'ip -6 a' at the ping6 sender
> 7: sim0: <BROADCAST,MULTICAST,NOARP,UP,LOWER_UP> mtu 1500 qlen 1000
>     inet6 2001:1::1/64 scope global 
>        valid_lft forever preferred_lft forever
>     inet6 fe80::200:ff:fe00:1/64 scope link 
>        valid_lft forever preferred_lft forever
> 
> - 'ip -6 r show' at the ping6 sender
> 2001:1::/64 dev sim0  proto kernel  metric 256 
> fe80::/64 dev sim0  proto kernel  metric 256 
> 
hmm...It is weird.  It is a /64 route, so it should have
failed the (rt->dst.flags & DST_HOST) test anyway...

> # the results of ip command on receiver side are almost
>   similar.
> 
> I found that the test uses non-ARP interface between nodes:
> if I changed the interface to 'non-NOARP' NIC, the issue has
> gone away without the revert.
> 
> I'm using the following scenario: just FYI.
> 
> https://gist.github.com/thehajime/26be8606ddbb924f357c
> 
You meant without 'arp off'?  Can you grep those IP from 'ip -6 neigh'?

Can you try this patch just to confirm:

Thanks
--Martin

diff --git i/net/ipv6/route.c w/net/ipv6/route.c
index 3522711..c0ae180 100644
--- i/net/ipv6/route.c
+++ w/net/ipv6/route.c
@@ -920,7 +920,7 @@ redo_rt6_select:

 	if (!(rt->rt6i_flags & (RTF_NONEXTHOP | RTF_GATEWAY)))
 		nrt = rt6_alloc_cow(rt, &fl6->daddr, &fl6->saddr);
-	else if (!(rt->dst.flags & DST_HOST) || !(rt->dst.flags & RTF_LOCAL))
+	else if (!(rt->dst.flags & DST_HOST)))
 		nrt = rt6_alloc_clone(rt, &fl6->daddr);
 	else
 		goto out2;
