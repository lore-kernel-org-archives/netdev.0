From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: fq_codel with 802.15.4 6LoWPAN fragmentation issue
Date: Fri, 16 Jan 2015 04:57:51 -0800
Message-ID: <1421413071.11734.120.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20150116120232.GD10068@omega>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-wpan@vger.kernel.org,
	stephen@networkplumber.org, jukka.rissanen@linux.intel.com
To: Alexander Aring <alex.aring@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f169.google.com ([209.85.223.169]:33655 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751513AbbAPM5x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jan 2015 07:57:53 -0500
In-Reply-To: <20150116120232.GD10068@omega>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-01-16 at 13:02 +0100, Alexander Aring wrote:
> Hi,
> 
> when using "fq_codel" as network scheduler, I noticed an issue with IEEE
> 802.15.4 6LoWPAN fragmentation. The issue is that high payloads IPv6
> packets are dropped.
> 
> I detected the issue on the sending side which segments the 6LoWPAN
> packet into several fragments.
> 
> In the IEEE 802.15.4 6LoWPAN fragmentation we have a 6LoWPAN interface
> (MTU 1280) on top of an IEEE 802.15.4 interface (MTU 127). The 6LoWPAN
> fragmentation algorithm creates in the "ndo_start_xmit" netdev_ops
> callback function of the 6LoWPAN interface new sk_buffs for the
> underlaying IEEE 802.15.4 interface (as skb->dev) and sends them via a
> dev_queue_xmit.
> 
> IEEE 802.15.4 is a very slow connection and after each transmit there is
> an "interframe spacing time" which depends on frequency setting. In my
> testcase, that's about ~500 us for a payload above 18 bytes. This is
> done by calling netif_stop_queue for the interface and start a timer
> after each transmitted frame according to the interframe spacing time.
> When the timer fires, it wakes the queue again by calling
> netif_wake_queue.
> 
> Now: What I am noticed with fq_codel is that the code at [0] will drop
> high payloaded IPv6 packets. Of course, if we have an IPv6 packet of
> more than 1280 bytes payload we have a fragmentation (IPv6
> fragmentation) over a fragmentation (802.15.4 6LoWPAN fragmentation).
> 
> When I increase the "params->interval" parameter I can send a "longer"
> IPv6 packet depending how much I increase the "params->interval"
> parameter.
> 
> I assume that the "params->interval" which defaults to MS2TIME(100) is
> too small. I further assume that at the beginning of fragmentation the
> interval measurement starts "vars->first_above_time = now +
> params->interval;" (line 247 at [0]) and while sending several fragments
> with the above mentioned interframe spacing time, the sending takes too
> long and the skb will be dropped.
> 
> My questions are:
> 
> - What's the best way to deal with something like that?
> 
> - Is there a way to set the "params->interval" _per interface_? So I can
>   change the default parameter to a suitable value in the "ndo_init"
>   callback of the 6LoWPAN interface.
> 
> Thanks in advance.

Sure, fq_codel is a qdisc, each network device gets its own qdisc
hierarchy.

You can therefore set different parameter on your interface,

Very simple example :

tc qdisc dev lowpan0 root fq_codel interval XXX
