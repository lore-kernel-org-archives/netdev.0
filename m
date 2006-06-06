From: Jeff Moyer <jmoyer@redhat.com>
Subject: Re: [PATCH 1/2] e1000: fix netpoll with NAPI
Date: Tue, 06 Jun 2006 13:29:23 -0400
Message-ID: <x498xoaw5u4.fsf@segfault.boston.redhat.com>
References: <20060605230917.12584.55755.stgit@gitlost.site>
	<20060605231125.12584.17039.stgit@gitlost.site>
	<20060606135217.GA21969@hmsreliant.homelinux.net>
	<1149611965.13635.19.camel@strongmad>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Neil Horman <nhorman@tuxdriver.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Garzik, Jeff" <jgarzik@pobox.com>, netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>, mpm@selenic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:26551 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S1750706AbWFFRas (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jun 2006 13:30:48 -0400
To: Mitch Williams <mitch.a.williams@intel.com>
In-Reply-To: <1149611965.13635.19.camel@strongmad> (Mitch Williams's message
 of "Tue, 06 Jun 2006 09:39:25 -0700")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

==> Regarding Re: [PATCH 1/2] e1000: fix netpoll with NAPI; Mitch Williams <mitch.a.williams@intel.com> adds:

mitch> On Tue, 2006-06-06 at 09:52 -0400, Neil Horman wrote:
>> I've been speaking about this fix with a Jeff Moyer, and we've come up with some
>> concerns regarding its implementation.  Specifically the call to
adapter-> clean_rx in the case of the e1000 driver is rather a layering
>> violation in the netpoll code, in the sense that the function pointed to by clean_rx
>> is functionality that is nominally used by the dev->poll method.  In fact in
>> this case, it would appear possible since dev->poll is called under the
>> poll_lock, but dev->poll_controller is not, that is is possible to have cpus in
>> a system executing in e1000_clean_rx_irq_[ps] at the same time leading to data
>> corruption:
>> 
>> CPU0:
>> netpoll_poll_dev
dev-> poll_controller (e1000_netpoll)
adapter-> clean_rx (e1000_clean_rx_irq)
>> 
>> CPU1:
>> napi_poll
dev-> poll (e1000_clean)
>> e1000_clean_rx_irq

mitch> Hmmm. You may have a point.  I don't think a spinlock is required, but
mitch> we do need to check if the poll is already scheduled on another CPU,
mitch> like netpoll does in poll_napi().

mitch> In practice, of course, we never see this.  The only netpoll client in
mitch> the kernel is netconsole, which doesn't do receives.  A few Major
mitch> Distros use netdump, which does do receives, but only after the system
mitch> has crashed.  In that case, all other CPUs are stopped anyway.

Don't forget about driver/net/kgdb_eth.c, which is in-tree, and does sends
and receives.

-Jeff
