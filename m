From: David Miller <davem@davemloft.net>
Subject: Re: [patch sungem] improved locking
Date: Tue, 28 Nov 2006 14:49:11 -0800 (PST)
Message-ID: <20061128.144911.55733883.davem@davemloft.net>
References: <5cac192f0611132328i52d6d615g28d8c493dc028621@mail.gmail.com>
	<20061113.234456.78492515.davem@davemloft.net>
	<5cac192f0611141354l3a4aa130ve741c9d6a7a49d0a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, benh@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60547
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1755309AbWK1WtE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Nov 2006 17:49:04 -0500
To: eric.lemoine@gmail.com
In-Reply-To: <5cac192f0611141354l3a4aa130ve741c9d6a7a49d0a@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Eric Lemoine" <eric.lemoine@gmail.com>
Date: Tue, 14 Nov 2006 22:54:40 +0100

> On 11/14/06, David Miller <davem@davemloft.net> wrote:
> > From: "Eric Lemoine" <eric.lemoine@gmail.com>
> > Date: Tue, 14 Nov 2006 08:28:42 +0100
> >
> > > because it makes it explicit that only bits 0 through 6 are taken into
> > > account when writing the IACK register.
> >
> > The phrase "bits 0 through 6" doesn't make any sense when bit 3 DOES
> > NOT EXIST in the hardware, it's reserved, it's not there, so including
> > it only confuses people and obfuscates the code.
> >
> > Please use the explicit bit mask composed of existing macros, which
> > not only makes sure that the mask has meaning, but it also makes sure
> > that reserved and non-existing bits are never referenced.
> 
> Patch attached.
> 
> Remember, the GEM_INTERRUPT_LOCKLESS isn't there to stay. It's
> currently there because I'm not sure the lockless implementation of
> gem_interrupt() will work with poll_net_controller.
> 
> Thanks,
> 
> Signed-off-by: Eric Lemoine <eric.lemoine@gmail.com>

This looks mostly fine.

I was thinking about the lockless stuff, and I wonder if there
is a clever way you can get it back down to one PIO on the
GREG_STAT register.

I think you'd need to have the ->poll() clear gp->status, then
do a smp_wb(), right before it re-enables interrupts.

Then in the interrupt handler, you need to find a way to safely
OR-in any unset bits in gp->status in a race-free manner.

