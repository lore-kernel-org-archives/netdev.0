From: Jeremy Eder <jeder@redhat.com>
Subject: Re: [RFC 1/2] pm: Introduce QoS requests per CPU
Date: Wed, 26 Mar 2014 13:36:37 -0400
Message-ID: <20140326173637.GB6656@jeder.rdu.redhat.com>
References: <1395753505-13180-1-git-send-email-amirv@mellanox.com>
 <1395753505-13180-2-git-send-email-amirv@mellanox.com>
 <2896374.SoOPVJXu9Q@vostro.rjw.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Amir Vadai <amirv@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>, linux-pm@vger.kernel.org,
	netdev@vger.kernel.org, Pavel Machek <pavel@ucw.cz>,
	Len Brown <len.brown@intel.com>, yuvali@mellanox.com,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>, idos@mellanox.com
To: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52367 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751906AbaCZRg5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Mar 2014 13:36:57 -0400
Content-Disposition: inline
In-Reply-To: <2896374.SoOPVJXu9Q@vostro.rjw.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 140325 19:44:53, Rafael J. Wysocki wrote:
> On Tuesday, March 25, 2014 03:18:24 PM Amir Vadai wrote:
> > Extend the current pm_qos_request API - to have pm_qos_request per core.
> > When a global request is added, it is added under the global plist.
> > When a core specific request is added, it is added to the core specific
> > list.
> > core number is saved in the request and later modify/delete operations
> > are using it to access the right list.
> > 
> > When a cpu specific request is added/removed/updated, the target value
> > of the specific core is recalculated to be the min/max (according to the
> > constrain type) value of all the global and the cpu specific
> > constraints.
> > 
> > If a global request is added/removed/updated, the target values of all
> > the cpu's are recalculated.
> > 
> > During initialization, before the cpu specific data structures are
> > allocated and initialized, only global target value is begin used.
> 
> I have to review this in detail (which rather won't be possible before
> the next week), but in principle I don't really like it, because it
> assumes that its users will know what's going to run on which CPU cores
> and I'm not sure where that knowledge is going to come from.

Hi guys,

I think busy_poll can accomplish the basic goals of this patch
set.  Stop drops due to c-state transition latency.  Get into more performant
c-states only on active cores with SO_BUSY_POLL or the sysctl.

Whether it's system-wide or per-cpu, cpu_dma_latency wastes power and
worse, it's a static thing.  We need adaptable power management for the
general case.  I guess that might look like power-aware scheduling, or wiring
menu.c to incorporate hints from drivers/userspace.

cpu_dma_latency reduces TDP headroom because non-active cores are in
unnecessarily high c-states, reduces the amount of turbo boost you can have,
and thus reduces performance of (i.e.) low-thread-count workloads.

busy_poll has another positive side-effect; it's even more granular (thus
more power friendly) than the percpu idea:  it will only affect cores that
have active sockets on them.  When the sockets aren't active, the core can
settle into a deep c-state, and possibly the socket can settle into a deeper
package c-state.  There's some data in the blog post that Jesper sent.

I also want to mention that this "class" of issue is not particularly
related to networking.
