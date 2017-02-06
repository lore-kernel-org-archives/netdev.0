From: Petko Manolov <petkan@nucleusys.com>
Subject: Re: [PATCH net 1/4] pegasus: Use heap buffers for all register access
Date: Mon, 6 Feb 2017 14:51:09 +0200
Message-ID: <20170206125108.d5vdur5rlvrkpr5j@localhost>
References: <20170204165451.GU3442@decadent.org.uk>
 <20170204165603.GV3442@decadent.org.uk>
 <20170205003038.GB21184@kroah.com>
 <20170206081444.smcgjkmdepxoosb6@p310>
 <20170206082822.GA23451@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Hutchings <ben@decadent.org.uk>, netdev@vger.kernel.org,
        linux-usb@vger.kernel.org,
        Lisandro =?utf-8?Q?Dami=C3=A1n_Nicanor_P=C3=A9rez?= Meyer
        <lisandro@debian.org>
To: Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lan.nucleusys.com ([92.247.61.126]:54232 "EHLO
        zztop.nucleusys.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1750950AbdBFMvV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2017 07:51:21 -0500
Content-Disposition: inline
In-Reply-To: <20170206082822.GA23451@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-02-06 09:28:22, Greg KH wrote:
> On Mon, Feb 06, 2017 at 10:14:44AM +0200, Petko Manolov wrote:
> > On 17-02-05 01:30:39, Greg KH wrote:
> > > On Sat, Feb 04, 2017 at 04:56:03PM +0000, Ben Hutchings wrote:
> > > > Allocating USB buffers on the stack is not portable, and no longer works 
> > > > on x86_64 (with VMAP_STACK enabled as per default).
> > > 
> > > It's never worked on other platforms, so these should go to the stable 
> > > releases please.
> > 
> > As far as i know both drivers works fine on other platforms, though I only 
> > tested it on arm and mipsel. ;)
> 
> It all depends on the arm and mips platforms, the ones that can not DMA from 
> stack memory are the ones that would always fail here (since the 2.2 kernel 
> days).

Seems like most modern SOCs have decent DMA controllers.

> > Random thought: isn't it better to add the alloc/free code in 
> > usb_control_msg() and avoid code duplication all over the driver space?
> 
> A very long time ago we considered it, but realized that the majority of 
> drivers already had the memory dynamically allocated, so we just went with 
> this.  Perhaps we could revisit that if it turns out we were wrong, and would 
> simplify things.

A quick glance at usb_control_msg() users (looked only at .../net/usb and 
.../usb/serial) shows that most of them have the buffer allocated in stack.  
These transfers are relatively infrequent and quite small the performance hit 
caused by memcpy() should also be negligible.

I suspect getting the buffer allocation in usb_control_msg() will help with two 
things in the same time:

 - allocate in DMA-able memory;
 - code reduction;

On the bad side i've no idea who'll volunteer to go through all 
usb_control_msg() sites and perform the fix.  Seems like the right job for an 
intern to me. :D


cheers,
Petko
