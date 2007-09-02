From: Satyam Sharma <satyam@infradead.org>
Subject: Re: 2.6.23-rc4-mm1 OOPS in forcedeth?
Date: Sun, 2 Sep 2007 15:25:00 +0530 (IST)
Message-ID: <alpine.LFD.0.999.0709021504550.22654@enigma.security.iitk.ac.in>
References: <20070831215822.26e1432b.akpm@linux-foundation.org>
 <20070901181352.GA4156@amd64.of.nowhere> <46D9B7EF.2050109@garzik.org>
 <alpine.LFD.0.999.0709020610590.20781@enigma.security.iitk.ac.in>
 <20070902061900.GA5595@amd64.of.nowhere>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Cc: Jeff Garzik <jeff@garzik.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: thunder7@xs4all.nl
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:41518 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755147AbXIBJmJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Sep 2007 05:42:09 -0400
In-Reply-To: <20070902061900.GA5595@amd64.of.nowhere>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Sun, 2 Sep 2007, thunder7@xs4all.nl wrote:
> 
> > > thunder7@xs4all.nl wrote:
> > > > 
> > > > On this machine (Athlon 64 X2 4600, 4 GiB memory, lots of disks),
> > > > 2.6.23-rc1-mm2 runs fine. 2.6.23-rc4-mm1 reproducably dies within seconds of
> > > > starting
> > > > a rsync session on another PC against this machine.
> > > > 
> > > > NULL pointer dereference
> > > > code:	nv_napi_poll+0x108
> > > > trace:	net_rx_action+0xab
> > > > 	__do_softirq+0x74
> > > > 	call_softirq+0x1c
> > > > 	do_softirq+0x3d
> > > > 	irq_exit+0x85
> > > > 	do_IRQ+0x85
> > > > 	ret_from_intr+0x0
> 
> There are 4 pictures of oopses here:
> 
> http://www.xs4all.nl/~thunder7/oops_2623rc4mm1_1.jpg
> http://www.xs4all.nl/~thunder7/oops_2623rc4mm1_2.jpg
> http://www.xs4all.nl/~thunder7/oops_2623rc4mm1_3.jpg
> http://www.xs4all.nl/~thunder7/oops_2623rc4mm1_4.jpg

OK, I've been pouring over forcedeth.c and the newly introduce NAPI code,
but didn't debug this yet, so I'll at least lay out the situation so that
somebody else who's more experienced @netdev can pick up from here with
minimal time wastage.

Here's what's happening (repeatedly, reproducibly) on Jurriaan's x64 box:

(1) The following NULL dereference oops:

    nv_rx_process_optimized(), inlined from nv_napi_poll(), found that
    "skb" i.e. np->get_rx_ctx->skb == NULL when trying to update
    skb->ip_summed.

(2) The following BUG in napi_complete():

    BUG_ON(!test_bit(NAPI_STATE_SCHED, &n->state));

    from the nv_napi_poll()->__netif_rx_complete()->napi_complete()
    callchain is triggering. IOW napi_complete() found that a NAPI
    poll wasn't/shouldn't have been scheduled at all (!)

The above two problems appear to be occurring independently, AFAICT.


Satyam
