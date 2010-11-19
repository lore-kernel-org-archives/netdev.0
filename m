From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC][PATCH 0/5] RFS hardware acceleration (v2)
Date: Fri, 19 Nov 2010 19:19:46 +0000
Message-ID: <1290194386.2671.59.camel@bwh-desktop>
References: <1290192176.2671.38.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:27566 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756447Ab0KSTTt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Nov 2010 14:19:49 -0500
In-Reply-To: <1290192176.2671.38.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

So, some preliminary benchmark results.

Tom said he was using 200 concurrent netperf TCP_RR tests, so I've done
the same, using netperf 2.4.1 (a bit out of date, I know).

The test machines were a Dell R810 with 4 * Xeon E7520 1.87 GHz and a
Dell R900 with 4 * Xeon X7350 2.92 GHz (both quad-core processors, with
HT disabled, for a total of 16 cores).

The kernel was an x86-64 build of net-next-2.6 with NUMA and
PREEMPT_VOLUNTARY enabled.

The NICs were Solarstorm SFN5122F (dual-port SFP+) adapters connected
with a Direct Attach cable.

The sfc driver allocates 4 IRQs per port (and it doesn't seem to be
possible to allocate more on this hardware), which I pinned to the first
core of each package.

I tested with and without pinning of processes.  When pinning, I
assigned netperf and netserver processes to all 16 cores in rotation.

               Unpinned                 Pinned
        No RFS  Soft    Accel   No RFS  Soft    Accel
                RFS     RFS             RFS     RFS

Request size = 1, response size = 1, moderation = 60 us adaptive (default)

avg(Hz) 1759    3213    3633    2222    3523    3848
std.dev 189     76      265     703     2136    2120
lat(us) 568     311     275     450     284     260
scaled          0.55    0.88            0.63    0.92

Request size = 1, response size = 1, moderation = 20 us adaptive

avg(Hz) 1797    3616    3917    2458    3706    4125
std.dev 260     101     295     1098    1987    2186
lat(us) 556     277     255     407     270     242
scaled          0.50    0.92            0.66    0.90

Request size = 100, response size = 10000, moderation = 60 us adaptive

avg(Hz) 1658    2909    3230    2338    3003    3437
std.dev 149     144     221     993     856     1615
lat(us) 603     344     310     428     333     291
scaled          0.57    0.90            0.78    0.87

Request size = 100, response size = 10000, moderation = 20 us adaptive

avg(Hz) 3348    3110    3331    2470    3271    3487
std.dev 406     176     364     1110    1693    1817
lat(us) 299     322     300     405     306     287
scaled          1.08    0.93            0.76    0.94

So accelerated RFS gave a 6-13% improvement over software RFS in
transaction rate for these various cases.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

