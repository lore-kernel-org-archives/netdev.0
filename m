From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 1/2] net: Allow to create links with given ifindex
Date: Thu, 02 Aug 2012 04:09:39 -0700
Message-ID: <87wr1h35zg.fsf@xmission.com>
References: <50160EEF.6050406@parallels.com> <87pq7dh6b2.fsf@xmission.com>
	<87fw89h5zk.fsf@xmission.com> <50179F66.1000604@parallels.com>
	<878ve0dtw3.fsf@xmission.com>
	<1343903310.9299.184.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Pavel Emelyanov <xemul@parallels.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:34743 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750799Ab2HBLKI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Aug 2012 07:10:08 -0400
In-Reply-To: <1343903310.9299.184.camel@edumazet-glaptop> (Eric Dumazet's
	message of "Thu, 02 Aug 2012 12:28:30 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> writes:

> On Tue, 2012-07-31 at 04:58 -0700, Eric W. Biederman wrote:
>
>> Making lo the particularly interesting case.
>
>
> BTW, I noticed in my benchmarks, that once I remove the contention on
> dst refcnt (using a percpu cache of dsts), I have a strange performance
> cost accessing net->loopback_dev->ifindex in ip_route_output_key.
>
> Strange because I see no false sharing on this ifindex location for
> loopback device.
>
> So we probably can save some cycles adding a net->loopback_ifindex
> to remove one dereference.

I am going to let Pavel tackle the actual work because only migration
really cares and he is working on migration right now.

But assuming we merge the per network namespace ifindex counter we
can change net->loopback_dev->ifindex to LOOPBACK_IFINDEX and
define "#define LOOPBACK_IFINDEX 1"

Certainly that works in the initial network namespace today and might be
worth testing.

> If ifindex are per network space, I guess we'll need to change
> arp_hashfn() or else we'll use some slots more than others.

Darn.  I hate being right about there being a few places to fix
up.

ndisc_hashfn also has the same limitation.

Eric

> diff --git a/include/net/arp.h b/include/net/arp.h
> index 7f7df93..37aac58 100644
> --- a/include/net/arp.h
> +++ b/include/net/arp.h
> @@ -10,7 +10,7 @@ extern struct neigh_table arp_tbl;
>  
>  static inline u32 arp_hashfn(u32 key, const struct net_device *dev, u32 hash_rnd)
>  {
> -	u32 val = key ^ dev->ifindex;
> +	u32 val = key ^ (u32)(unsigned long)dev;
>  
>  	return val * hash_rnd;
>  }
