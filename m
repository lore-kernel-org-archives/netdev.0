From: Andreas Mohr <andim2@users.sourceforge.net>
Subject: Re: [PATCH] Make e100 suspend handler support PCI cards lacking PM
	capability
Date: Fri, 19 Jun 2009 10:00:50 +0200
Message-ID: <20090619080050.GA20131@rhlx01.hs-esslingen.de>
References: <20081229102515.GA17171@rhlx01.hs-esslingen.de> <200906141606.29754.rjw@sisk.pl> <20090614164604.GA19746@rhlx01.hs-esslingen.de> <200906141909.46354.rjw@sisk.pl>
Reply-To: andi@lisas.de
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: andi@lisas.de, akpm@linux-foundation.org,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhlx01.hs-esslingen.de ([129.143.116.10]:39967 "EHLO
	rhlx01.hs-esslingen.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750884AbZFSIAs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jun 2009 04:00:48 -0400
Content-Disposition: inline
In-Reply-To: <200906141909.46354.rjw@sisk.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Sun, Jun 14, 2009 at 07:09:45PM +0200, Rafael J. Wysocki wrote:
> On Sunday 14 June 2009, Andreas Mohr wrote:
> > - why do we call netif_device_detach() _after_ doing hardware shutdown
> >   of the network controller? I'd guess this can cause huge issues?
> >   Someone told me he had rtnl lock issues upon S2D with e100
> >   (very similar to my rtnl issues during aborted .suspend),
> >   and that might possibly be the reason?
> 
> I think you're right, but I'm not a network driver expert.
> 
> Perhaps you can change the ordering and see if that fixes the rtnl issue
> (since you're able to reproduce it without my patch, that should be easy to
> verify).

Well, I just moved netif_device_detach() above netif_running() check,
but this didn't fix my network issues in case of a rejecting .suspend
handler: after resume when unloading e100, that hangs, and I get tons of
rtnl timeouts and locked rtnl mutex.
This is most likely because upon e100 unload, a backtrace showed that I
was hanging in e100_down -> msleep (somewhere at the very beginning of e100_down),
which is most definitely the inlined napi_disable() call there:

static inline void napi_disable(struct napi_struct *n)
{
        set_bit(NAPI_STATE_DISABLE, &n->state);
        while (test_and_set_bit(NAPI_STATE_SCHED, &n->state))
                msleep(1);
        clear_bit(NAPI_STATE_DISABLE, &n->state);
}

IOW the .suspend seems to keep NAPI layer active, yet due to .suspend failure
there's no .resume called, thus card is in an _inoperable_ state and
NAPI cannot be processed any further, thus napi_disable() on driver unload
locks up.


BTW, in include/linux/napi.h, shouldn't napi_disable() make use of
napi_synchronize() instead of C&P?
(simply move napi_synchronize() above napi_disable() and use it there)
Oh wait, there's the CONFIG_SMP complication:
napi_synchronize() is implemented for SMP only, whereas napi_disable()
checks the same thing _always_.
(or is it a BUG that napi_disable() does the same check for non-SMP,
too??)

Thanks,

Andreas Mohr
