From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH 1/2] e1000: fix netpoll with NAPI
Date: Tue, 6 Jun 2006 13:05:13 -0400
Message-ID: <20060606170513.GB21969@hmsreliant.homelinux.net>
References: <20060605230917.12584.55755.stgit@gitlost.site> <20060605231125.12584.17039.stgit@gitlost.site> <20060606135217.GA21969@hmsreliant.homelinux.net> <1149611965.13635.19.camel@strongmad>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Garzik, Jeff" <jgarzik@pobox.com>, netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>, jmoyer@redhat.com,
	mpm@selenic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([24.172.12.4]:11022 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S1750761AbWFFRFo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jun 2006 13:05:44 -0400
To: Mitch Williams <mitch.a.williams@intel.com>
Content-Disposition: inline
In-Reply-To: <1149611965.13635.19.camel@strongmad>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 06, 2006 at 09:39:25AM -0700, Mitch Williams wrote:
> On Tue, 2006-06-06 at 09:52 -0400, Neil Horman wrote:
> > I've been speaking about this fix with a Jeff Moyer, and we've come up with some
> > concerns regarding its implementation.  Specifically the call to
> > adapter->clean_rx in the case of the e1000 driver is rather a layering
> > violation in the netpoll code, in the sense that the function pointed to by clean_rx
> > is functionality that is nominally used by the dev->poll method.  In fact in
> > this case, it would appear possible since dev->poll is called under the
> > poll_lock, but dev->poll_controller is not, that is is possible to have cpus in
> > a system executing in e1000_clean_rx_irq_[ps] at the same time leading to data
> > corruption:
> > 
> > CPU0:
> > netpoll_poll_dev
> >  dev->poll_controller (e1000_netpoll)
> >   adapter->clean_rx (e1000_clean_rx_irq)
> > 
> > CPU1:
> > napi_poll
> >  dev->poll (e1000_clean)
> >   e1000_clean_rx_irq
> 
> Hmmm. You may have a point.  I don't think a spinlock is required, but
> we do need to check if the poll is already scheduled on another CPU,
> like netpoll does in poll_napi().
> 
> In practice, of course, we never see this.  The only netpoll client in
> the kernel is netconsole, which doesn't do receives.  A few Major
> Distros use netdump, which does do receives, but only after the system
> has crashed.  In that case, all other CPUs are stopped anyway.
> 
You are probably right, this is a rare case, if it ever happens at all, but I
think there is (at least as Jeff explained it to me) a corner case, where
netconsole on transmit, notes an exhaustion of tx descriptors, and in response
calls the poll controller method of the driver to clean up and make some of
those descriptors available:

printk
  release_console_sem
    call_console_drivers
      netconsole.c:write_msg
        netpoll_send_udp
          netpoll_send_skb

            if (netif_queue_stopped(np->dev)) <--- out of descriptors ?
                netpoll_poll(np);             <--- trigger a poll to clean up

If this is being done at the same time as a napi_poll on another cpu, we have a
real set of conditions under which a corruption can occur.

> However, just for the sake of correctness (and paranoia), I'll whip up
> another patch that does this check.
> 
Thanks for the quick feedback!

Regards
Neil

> Jeff, please do not commit this patch.
> 
> -Mitch
> 
> NB:  The root of this problem is that e1000 uses a dummy netdev to
> schedule NAPI polling.  Since netpoll doesn't know about the dummy
> netdev, it checks the "real" e1000 netdev struct to see if it's
> scheduled for polling.  Since this is never the case, netpoll fails when
> e1000 is configured to use NAPI.  Hence, this patch.
> 
> Why is the dummy netdev in place?  To support multi-queue RX.  Our PCIe
> adapters support this, but the kernel's not _quite_ ready yet.
> Hopefully, the VJ net channel stuff will enable this feature.
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
/***************************************************
 *Neil Horman
 *Software Engineer
 *gpg keyid: 1024D / 0x92A74FA1 - http://pgp.mit.edu
 ***************************************************/
