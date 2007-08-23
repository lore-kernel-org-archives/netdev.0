From: Jan-Bernd Themann <ossthema@de.ibm.com>
Subject: Re: eHEA driver issues from net-2.6.24
Date: Thu, 23 Aug 2007 08:55:29 +0200
Message-ID: <200708230855.29961.ossthema@de.ibm.com>
References: <46CCB0B7.3030302@us.ibm.com> <20070822.150302.44981242.davem@davemloft.net> <46CCB696.7090703@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Andrew Theurer <habanero@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.de.ibm.com ([195.212.29.150]:32390 "EHLO
	mtagate1.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752450AbXHWH14 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2007 03:27:56 -0400
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate1.de.ibm.com (8.13.8/8.13.8) with ESMTP id l7N7Rsgg759876
	for <netdev@vger.kernel.org>; Thu, 23 Aug 2007 07:27:54 GMT
Received: from d12av01.megacenter.de.ibm.com (d12av01.megacenter.de.ibm.com [9.149.165.212])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l7N7RsNU2252918
	for <netdev@vger.kernel.org>; Thu, 23 Aug 2007 09:27:54 +0200
Received: from d12av01.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av01.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l7N7Rs8u024748
	for <netdev@vger.kernel.org>; Thu, 23 Aug 2007 09:27:54 +0200
In-Reply-To: <46CCB696.7090703@us.ibm.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 23 August 2007 00:20, Andrew Theurer wrote:
> David Miller wrote:
> > From: Andrew Theurer <habanero@us.ibm.com>
> > Date: Wed, 22 Aug 2007 16:55:03 -0500
> >
> > Thanks for finally getting to test this, I thought nobody
> > would test this until it got merged into 2.6.24 :-/
> >

Yes, sorry for the delay. 

> >   
> >> kernel BUG at include/linux/netdevice.h:318!
> >> enter ? for help
> >> [c00000000f613e40] c0000000003fe394 .net_rx_action+0x1b8/0x254
> >> [c00000000f613ef0] c000000000057b70 .__do_softirq+0xa8/0x164
> >> [c00000000f613f90] c000000000024438 .call_do_softirq+0x14/0x24
> >> [c000000b8ffbf9f0] c00000000000bd30 .do_softirq+0x68/0xac
> >> [c000000b8ffbfa80] c000000000057cc4 .irq_exit+0x54/0x6c
> >> [c000000b8ffbfb00] c00000000000c358 .do_IRQ+0x170/0x1ac
> >> [c000000b8ffbfb90] c000000000004780 hardware_interrupt_entry+0x18/0x98
> >> --- Exception: 501 (Hardware Interrupt) at c000000000010bdc 
> >> .cpu_idle+0x114/0x1e0
> >> [c000000b8ffbfe80] c000000000010bd0 .cpu_idle+0x108/0x1e0 (unreliable)
> >> [c000000b8ffbff00] c000000000026db0 .start_secondary+0x160/0x184
> >> [c000000b8ffbff90] c000000000008364 .start_secondary_prolog+0xc/0x10
> >>
> >> I'm a little confused if the port_napi_enable() is being called when the 
> >> device is initialized, but then again, this is all new to me (should it 
> >> be called in ehea_open?).  I see it called on some reset routines, but 
> >> not on the first initialization.
> >>     
> >
> > This is similar to the problem that Arnaldo hit a few minutes
> > ago in the VIA Rhine driver.
> >
> > You can't only make a napi_enable() call when there has been
> > a previous napi_disable().
> >
> > One way to fix this would be to forcefully napi_disable() on
> > all the per-port NAPI structs at the beginning of ehea_open(),
> > which should set things up to satisfy the pre-condition of the
> > napi_enable() calls.
> >   
> OK, Ill try this. 

Let me fix this. I'll try to get it done today.

> > You'll need to audit the entire driver to make sure this invariant
> > is held properly.
> >
> >   
> >> Also, on this code, in ehea_sense_port_attr()
> >>
> >> /* Number of default QPs */
> >>         if (use_mcs)
> >>                 port->num_def_qps = cb0->num_default_qps;
> >>         else
> >>                 port->num_def_qps = 1;
> >>                
> >>
> >> When using napi, since we have multi-queue napi support now, wouldn't we 
> >> want to use all the default qps instead of 1?
> >>     
> >
> > I don't know how this hardware works, you tell me :-)
> >   
> Heh, I don't know it well, either. Maybe Jan Bernd can chime in.

We'd like to keep the possibility to switch back to a single queue for now.
However, we could activate multi queue support as default now.
I'll include this in the patch.

> 
> Thanks for your help,
> 
> -Andrew
> 
> 
