From: Ivan Vecera <ivecera@redhat.com>
Subject: RE: [PATCH] [v3][net][bna] Fix call trace when interrupts are
 disabled while sleeping function kzalloc is called
Date: Tue, 12 Jul 2011 14:42:36 +0200
Message-ID: <1310474556.28711.0.camel@ceranb.brq.redhat.com>
References: <1309287485-6077-1-git-send-email-shyam_iyer@dell.com>
	 <1310051634.4392.29.camel@ceranb.intra.cera.cz>
	 <DBFB1B45AF80394ABD1C807E9F28D157063779959F@BLRX7MCDC203.AMER.DELL.COM>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: shyam.iyer.t@gmail.com, netdev@vger.kernel.org, rmody@brocade.com,
	ddutt@brocade.com, huangj@brocade.com, davem@davemloft.net
To: Shyam_Iyer@Dell.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41774 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753012Ab1GLMmn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Jul 2011 08:42:43 -0400
In-Reply-To: <DBFB1B45AF80394ABD1C807E9F28D157063779959F@BLRX7MCDC203.AMER.DELL.COM>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-07-08 at 03:23 +0530, Shyam_Iyer@Dell.com wrote:
> 
> > -----Original Message-----
> > From: Ivan Vecera [mailto:ivecera@redhat.com]
> > Sent: Thursday, July 07, 2011 11:14 AM
> > To: Shyam Iyer
> > Cc: netdev@vger.kernel.org; rmody@brocade.com; ddutt@brocade.com;
> > huangj@brocade.com; davem@davemloft.net; Iyer, Shyam
> > Subject: Re: [PATCH] [v3][net][bna] Fix call trace when interrupts are
> > disabled while sleeping function kzalloc is called
> > 
> > Small note, the root of the problem was that non-atomic allocation was
> > requested with IRQs disabled. Your patch description does not contain
> > why were the IRQs disabled.
> > The function bnad_mbox_irq_alloc incorrectly uses 'flags' var for two
> > different things, 1) to save current CPU flags and 2) for request_irq
> > call.
> > First the spin_lock_irqsave disables the IRQs and saves _all_ CPU flags
> > (including one that enables/disables interrupts) to 'flags'. Then the
> > 'flags' is overwritten by 0 or 0x80 (IRQF_SHARED). Finally the
> > spin_unlock_irqrestore should restore saved flags, but these flags are
> > now either 0x00 or 0x80. The interrupt bit value in flags register on
> > x86 arch is 0x100.
> > This means that the interrupt bit is zero (IRQs disabled) after
> > spin_unlock_irqrestore so the request_irq function is called with
> > disabled interrupts.
> 
> That seems to make a lot more sense.. and that way I don't have to initialize the flags variable outside of the spin_lock_irqsave/restore bracket to preserve the irqs not being disabled when allocating in request_irq
> 
> Would the below patch make sense instead...? (Note that since davem has accepted the earlier one this is on top of the already committed patch)
> 
Yes, this is much cleaner...

