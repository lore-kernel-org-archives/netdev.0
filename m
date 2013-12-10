From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Fwd: UDP/IPv6 performance issue
Date: Tue, 10 Dec 2013 18:12:48 +0100
Message-ID: <20131210171248.GA23216@order.stressinduktion.org>
References: <CAGA2gK6rf8E7cCO=RwbdFAt2ucfxUbCjqhVoga9cnHrEKxcp9g@mail.gmail.com> <CAGA2gK5gfdaKeQWzT4Dd45AhavD4pYaCVyayf7Hd+q5pPUjfKQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev <netdev@vger.kernel.org>
To: ajay seshadri <seshajay@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:45724 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754813Ab3LJRMt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Dec 2013 12:12:49 -0500
Content-Disposition: inline
In-Reply-To: <CAGA2gK5gfdaKeQWzT4Dd45AhavD4pYaCVyayf7Hd+q5pPUjfKQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

On Tue, Dec 10, 2013 at 11:19:29AM -0500, ajay seshadri wrote:
> I have been testing network performance using my application and other
> third party tools like netperf on my systems that have 10G NIC Cards.
> It's a simple back to back setup with no switches in between.
> 
> I see about 15 to 20% performance degradation for UDP/IPv6 as compared
> to UDP/IPv4 for packets of size 1500.
> 
> On performing "perf top" analysis for ipv6 traffic, I identified the
> following functions as some hot functions:
> fib6_force_start_gc()

IPv6 Routing code is not as well optimized as the IPv4 one. But it is
strange to see fib6_force_start_gc() to be that high in perf top.

I guess you are sending the frames to distinct destinations each time? A
cached entry is created on each send in the fib and as soon as the maximum of
4096 is reached a gc is forced. This setting is tunable in
/proc/sys/net/ipv6/route/max_size.

> csum_partial_copy_generic()
> udp_v6_flush_pending_frames()
> dst_mtu()
> 
> csum_partial_copy_generic() shows up because my card doesn't support
> checksum offloading for ipv6 packets. In fact turning off rx / tx
> checksum offloading for ipv4 showed the same function in the "perf
> top" profile, but did not cause any performance degradation.
> 
> Now I am CPU bound on packets of size 1500 and I am not using GSO (for
> both IPv4 and IPv6). I tried twiddling with the route cache garbage
> collection timer values and tried to set the socket options to disable
> pmtu discovery and set the mtu for the socket, but it did not make any
> difference.

A cached entry will be inserted nontheless. If you don't hit the max_size
route entries limit I guess there could be a bug which triggers needless gc
invocation.

> I am wondering if this is a known performance issue or can I fine tune
> the system to match UDP / IPv4 performance with UDP / IPv6? As I am
> CPU bound, the functions I identified are using up CPU cycles that i
> could probably save.

Could you send me your send pattern so maybe I could try to reproduce it?

Greetings,

  Hannes
