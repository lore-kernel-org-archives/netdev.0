From: James Hogan <james@albanarts.com>
Subject: Re: [Bugme-new] [Bug 19992] New: b44 + CONFIG_DEBUG_SHIRQ (=y on fedora) fails to resume
Date: Tue, 12 Oct 2010 00:26:20 +0100
Message-ID: <201010120026.20746.james@albanarts.com>
References: <bug-19992-10286@https.bugzilla.kernel.org/> <20101011131539.bbb99afe.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org,
	Gary Zambrano <zambrano@broadcom.com>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:63470 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751108Ab0JKX00 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Oct 2010 19:26:26 -0400
Received: by wye20 with SMTP id 20so894605wye.19
        for <netdev@vger.kernel.org>; Mon, 11 Oct 2010 16:26:25 -0700 (PDT)
In-Reply-To: <20101011131539.bbb99afe.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 11 October 2010 21:15:39 Andrew Morton wrote:
> (switched to email.  Please respond via emailed reply-to-all, not via the
> bugzilla web interface).
> 
> On Sun, 10 Oct 2010 16:57:11 GMT
> 
> bugzilla-daemon@bugzilla.kernel.org wrote:
> > https://bugzilla.kernel.org/show_bug.cgi?id=19992
> > 
> >            Summary: b44 + CONFIG_DEBUG_SHIRQ (=y on fedora) fails to
> >            
> >                     resume
> >            
> >            Product: Drivers
> >            Version: 2.5
> >     
> >     Kernel Version: 2.6.36-rc7
> >     
> >           Platform: All
> >         
> >         OS/Version: Linux
> >         
> >               Tree: Mainline
> >             
> >             Status: NEW
> >           
> >           Severity: high
> >           Priority: P1
> >          
> >          Component: Network
> >         
> >         AssignedTo: drivers_network@kernel-bugs.osdl.org
> >         ReportedBy: james@albanarts.com
> >         Regression: Yes
> > 
> > b44 network driver causes system to hang on resume when
> > CONFIG_DEBUG_SHIRQ=y. I've done some TRACE_RESUME'ing and the following
> > happens:
> > * b44_resume() (drivers/net/b44.c) calls request_irq with IRQF_SHARED
> > (after freeing it in the suspend function)
> > * request_irq() (kernel/irq/manage.c) calls the interrupt handler
> > directly if IRQF_SHARED and CONFIG_DEBUG_SHIRQ=y. It says "It's a shared
> > IRQ -- the driver ought to be prepared for it to happen immediately, so
> > let's make sure...."
> > 
> > * b44_interrupt() gets as far as the first br32 and no further:
> >   istat = br32(bp, B44_ISTAT);
> > 
> > I presume it hasn't yet woken the device up so reading a register somehow
> > fails and hangs the system.
> > 
> > If I comment out the code in request_irq() to test the shared irq handler
> > all works fine.
> > 
> > I'm guessing either the b44 driver shouldn't be freeing/requesting irqs
> > in suspend/resume functions, or should be resetting the hardware first
> > so that the test handler call doesn't fail, but I don't know enough
> > about why it is freeing the irq across suspend to be confident fixing
> > it.
> > 
> > This has been like this for a while (2.6.34 at least). Suspend used to
> > work on fedora with this hardware so I think this is a regression. I'm
> > happy to test any patches.
> 
> Thanks.  Yup, if the driver/device isn't ready to accept an IRQ when
> request_irq() is called then there might be a problem should a real
> interrupt happen very shortly after request_irq() is called.
> 
> The code looks OK to me so perhaps it is indeed some weird hardware
> problem.  Maybe a little delay after the ssb_bus_powerup() is needed?

Thanks for the ideas. I tried a delay and it didn't work, but when I moved the 
request_irq after the spinlocked code which appears to reset the hardware, all 
was fine, which kind of makes sense.

See patch "b44: fix resume, request_irq after hw reset"

Cheers
James
