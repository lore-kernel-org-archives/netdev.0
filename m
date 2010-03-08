From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: Re: [PATCH 1/1] bnx2x: Tx barriers and locks
Date: Mon, 8 Mar 2010 16:38:30 +0100
Message-ID: <20100308153829.GA3427@dhcp-lab-161.englab.brq.redhat.com>
References: <20100302135555.GC2362@dhcp-lab-161.englab.brq.redhat.com> <C27F8246C663564A84BB7AB34397724218312F8FD4@IRVEXCHCCR01.corp.ad.broadcom.com> <20100302165946.GC6491@dhcp-lab-161.englab.brq.redhat.com> <1267550787.19491.109.camel@nseg_linux_HP1.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vladislav Zolotarov <vladz@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	Eilon Greenstein <eilong@broadcom.com>,
	Matthew Carlson <mcarlson@broadcom.com>
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:20168 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753412Ab0CHPlM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Mar 2010 10:41:12 -0500
Content-Disposition: inline
In-Reply-To: <1267550787.19491.109.camel@nseg_linux_HP1.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 02, 2010 at 09:26:27AM -0800, Michael Chan wrote:
> 
> On Tue, 2010-03-02 at 08:59 -0800, Stanislaw Gruszka wrote:
> > On Tue, Mar 02, 2010 at 08:18:44AM -0800, Michael Chan wrote:
> > > Stanislaw Gruszka wrote:
> > > 
> > > > On Tue, Mar 02, 2010 at 04:50:59AM -0800, Vladislav Zolotarov wrote:
> > > > > Stanislaw barrier() is not a memory barrier - it's a
> > > > compiler barrier. I don't think removing it from
> > > > bnx2x_tx_avail() will improve anything. If u think I'm wrong,
> > > > could u, pls., provide a specific example.
> > > >
> > > > Only improvement is removing confusing code, And comment like
> > > > "Tell compiler that prod and cons can change" is even more
> > > > confusing. If you think I'm wrong, just tell as why that
> > > > barrier is needed :)
> > > 
> > > The barrier (compiler barrier at least) is required in
> > > bnx2x_tx_avail().  The status block index can be updated by DMA and
> > > the compiler doesn't know it (because it is considered wrong to
> > 
> > If you are telling status block index you mean which variable ?
> 
> The fp-> fields which can be updated by NAPI poll based on new status
> block DMA.

So, we are talking about fp->tx_bd_prod and fp->tx_bd_cons.

> > > declare the status block as volatile).  Near the end of
> > > bnx2x_start_xmit() where we call bnx2x_tx_avail() twice.  It is
> > > possible that the compiler will optimize it and not look at the
> > > status block in memory the second time.

Still think barrier() in bnx2x_tx_avail is not necessary.

First of all, in what we have now in net-next-2.6 tree all fp->tx_bd_prod
modifications and bnx2x_tx_avail() function calls are done with
__netif_tx_lock taken, so we don't need any barriers for that. I'm omitting
here bnx2x_run_loopback() as this function is called when interface
is disabled, and bnx2x_stats_update() when output of bnx2x_tx_avail()
is printed in debug mode.

Regarding fp->tx_bd_cons: situation is a bit more complicated. It is modified
outside __netif_tx_lock protection and can happen in parallel with
bnx2x_start_xmit(). However barrier() in bnx2_tx_avail do not help when
fp->tx_bd_cons is modified on bnx2x_tx_int() on other cpu, since there
is no guarantees that registers/cache will be flushed on that cpu. Even
taking into account smp_wmb() after "fp->tx_bd_cons = bd_cons", as
smp_wmb() only guarantee preserve of ordering, not flushing registers/cache
in any particular time. For the same reason changing barrier() to smb_mb()
in bnx2x_tx_avail have no sense.

I plan to split my bnx2x patch into smaller peaces and post them. Small
patches perhaps will be more clean and You would not have objections
against :)

Stanislaw
