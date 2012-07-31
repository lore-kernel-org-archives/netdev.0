From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [PATCH v2] ipv4: percpu nh_rth_output cache
Date: Tue, 31 Jul 2012 13:10:41 -0700
Message-ID: <50183BC1.8090205@intel.com>
References: <1343749530.21269.336.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:43152 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756370Ab2GaUKm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 Jul 2012 16:10:42 -0400
In-Reply-To: <1343749530.21269.336.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/31/2012 08:45 AM, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> Input path is mostly run under RCU and doesnt touch dst refcnt
>
> But output path on forwarding or UDP workloads hits
> badly dst refcount, and we have lot of false sharing, for example
> in ipv4_mtu() when reading rt->rt_pmtu
>
> Using a percpu cache for nh_rth_output gives a nice performance
> increase at a small cost.
>
> 24 udpflood test on my 24 cpu machine (dummy0 output device)
> (each process sends 1.000.000 udp frames, 24 processes are started)
>
> before : 5.24 s
> after : 2.06 s
> For reference, time on linux-3.5 : 6.60 s
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---
> v2: use __this_cpu_ptr() and slighly better annotations to avoid
> ugly casts
>
> On top on previous "ipv4: Restore old dst_free() behavior" patch
>
> We probably can remove all paddings in struct dst_entry
>
I've done some quick testing and it looks like it has little to no
effect on routing performance in my system, but for UDP workloads it is
making a huge difference.  I just ran a simple test with 16 sessions of
netperf all sending UDP small packets.  Without your patch it runs at
just over 2.7Mpps, with your patch it is runs at over 10.5Mpps.

Tested-by: Alexander Duyck <alexander.h.duyck@intel.com>
