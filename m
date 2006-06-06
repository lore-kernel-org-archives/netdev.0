From: Mitch Williams <mitch.a.williams@intel.com>
Subject: Re: [PATCH 1/2] e1000: fix netpoll with NAPI
Date: Tue, 06 Jun 2006 09:39:25 -0700
Message-ID: <1149611965.13635.19.camel@strongmad>
References: <20060605230917.12584.55755.stgit@gitlost.site>
	 <20060605231125.12584.17039.stgit@gitlost.site>
	 <20060606135217.GA21969@hmsreliant.homelinux.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Garzik, Jeff" <jgarzik@pobox.com>, netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>, jmoyer@redhat.com,
	mpm@selenic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:21254 "EHLO
	fmsmga101-1.fm.intel.com") by vger.kernel.org with ESMTP
	id S1750792AbWFFQmu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Jun 2006 12:42:50 -0400
To: Neil Horman <nhorman@tuxdriver.com>
In-Reply-To: <20060606135217.GA21969@hmsreliant.homelinux.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-06-06 at 09:52 -0400, Neil Horman wrote:
> I've been speaking about this fix with a Jeff Moyer, and we've come up with some
> concerns regarding its implementation.  Specifically the call to
> adapter->clean_rx in the case of the e1000 driver is rather a layering
> violation in the netpoll code, in the sense that the function pointed to by clean_rx
> is functionality that is nominally used by the dev->poll method.  In fact in
> this case, it would appear possible since dev->poll is called under the
> poll_lock, but dev->poll_controller is not, that is is possible to have cpus in
> a system executing in e1000_clean_rx_irq_[ps] at the same time leading to data
> corruption:
> 
> CPU0:
> netpoll_poll_dev
>  dev->poll_controller (e1000_netpoll)
>   adapter->clean_rx (e1000_clean_rx_irq)
> 
> CPU1:
> napi_poll
>  dev->poll (e1000_clean)
>   e1000_clean_rx_irq

Hmmm. You may have a point.  I don't think a spinlock is required, but
we do need to check if the poll is already scheduled on another CPU,
like netpoll does in poll_napi().

In practice, of course, we never see this.  The only netpoll client in
the kernel is netconsole, which doesn't do receives.  A few Major
Distros use netdump, which does do receives, but only after the system
has crashed.  In that case, all other CPUs are stopped anyway.

However, just for the sake of correctness (and paranoia), I'll whip up
another patch that does this check.

Jeff, please do not commit this patch.

-Mitch

NB:  The root of this problem is that e1000 uses a dummy netdev to
schedule NAPI polling.  Since netpoll doesn't know about the dummy
netdev, it checks the "real" e1000 netdev struct to see if it's
scheduled for polling.  Since this is never the case, netpoll fails when
e1000 is configured to use NAPI.  Hence, this patch.

Why is the dummy netdev in place?  To support multi-queue RX.  Our PCIe
adapters support this, but the kernel's not _quite_ ready yet.
Hopefully, the VJ net channel stuff will enable this feature.
