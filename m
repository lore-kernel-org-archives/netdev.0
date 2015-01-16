From: Alexander Aring <alex.aring@gmail.com>
Subject: fq_codel with 802.15.4 6LoWPAN fragmentation issue
Date: Fri, 16 Jan 2015 13:02:35 +0100
Message-ID: <20150116120232.GD10068@omega>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-wpan@vger.kernel.org, stephen@networkplumber.org,
	jukka.rissanen@linux.intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f169.google.com ([74.125.82.169]:55222 "EHLO
	mail-we0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754156AbbAPMCk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jan 2015 07:02:40 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

when using "fq_codel" as network scheduler, I noticed an issue with IEEE
802.15.4 6LoWPAN fragmentation. The issue is that high payloads IPv6
packets are dropped.

I detected the issue on the sending side which segments the 6LoWPAN
packet into several fragments.

In the IEEE 802.15.4 6LoWPAN fragmentation we have a 6LoWPAN interface
(MTU 1280) on top of an IEEE 802.15.4 interface (MTU 127). The 6LoWPAN
fragmentation algorithm creates in the "ndo_start_xmit" netdev_ops
callback function of the 6LoWPAN interface new sk_buffs for the
underlaying IEEE 802.15.4 interface (as skb->dev) and sends them via a
dev_queue_xmit.

IEEE 802.15.4 is a very slow connection and after each transmit there is
an "interframe spacing time" which depends on frequency setting. In my
testcase, that's about ~500 us for a payload above 18 bytes. This is
done by calling netif_stop_queue for the interface and start a timer
after each transmitted frame according to the interframe spacing time.
When the timer fires, it wakes the queue again by calling
netif_wake_queue.

Now: What I am noticed with fq_codel is that the code at [0] will drop
high payloaded IPv6 packets. Of course, if we have an IPv6 packet of
more than 1280 bytes payload we have a fragmentation (IPv6
fragmentation) over a fragmentation (802.15.4 6LoWPAN fragmentation).

When I increase the "params->interval" parameter I can send a "longer"
IPv6 packet depending how much I increase the "params->interval"
parameter.

I assume that the "params->interval" which defaults to MS2TIME(100) is
too small. I further assume that at the beginning of fragmentation the
interval measurement starts "vars->first_above_time = now +
params->interval;" (line 247 at [0]) and while sending several fragments
with the above mentioned interframe spacing time, the sending takes too
long and the skb will be dropped.

My questions are:

- What's the best way to deal with something like that?

- Is there a way to set the "params->interval" _per interface_? So I can
  change the default parameter to a suitable value in the "ndo_init"
  callback of the 6LoWPAN interface.

Thanks in advance.

- Alex

[0] http://lxr.free-electrons.com/source/include/net/codel.h#L248
