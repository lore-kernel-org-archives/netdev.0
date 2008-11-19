From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH] netconsole: Disable softirqs in write_msg()
Date: Wed, 19 Nov 2008 11:14:41 +0100
Message-ID: <20081119101441.GB6184@elte.hu>
References: <87y6zwwy5c.fsf@tac.ki.iif.hu> <20081119084106.GA6699@ff.dom.local> <20081119093004.GD22309@elte.hu> <20081119.014222.193698982.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jarkao2@gmail.com, jeff@garzik.org, johannes@sipsolutions.net,
	wferi@niif.hu, netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:39315 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752709AbYKSKO4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Nov 2008 05:14:56 -0500
Content-Disposition: inline
In-Reply-To: <20081119.014222.193698982.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* David Miller <davem@davemloft.net> wrote:

> From: Ingo Molnar <mingo@elte.hu>
> Date: Wed, 19 Nov 2008 10:30:04 +0100
> 
> > * Jarek Poplawski <jarkao2@gmail.com> wrote:
> > 
> > > diff --git a/drivers/net/netconsole.c b/drivers/net/netconsole.c
> > > index d304d38..f6ecad8 100644
> > > --- a/drivers/net/netconsole.c
> > > +++ b/drivers/net/netconsole.c
> > > @@ -702,6 +702,8 @@ static void write_msg(struct console *con, const char *msg, unsigned int len)
> > >  	if (list_empty(&target_list))
> > >  		return;
> > >  
> > > +	/* Avoid enabling softirqs with hardirqs disabled */
> > > +	local_bh_disable();
> > >  	spin_lock_irqsave(&target_list_lock, flags);
> > >  	list_for_each_entry(nt, &target_list, list) {
> > >  		netconsole_target_get(nt);
> > > @@ -723,6 +725,7 @@ static void write_msg(struct console *con, const char *msg, unsigned int len)
> > >  		netconsole_target_put(nt);
> > >  	}
> > >  	spin_unlock_irqrestore(&target_list_lock, flags);
> > > +	local_bh_enable();
> > 
> > but netconsole can be triggered from printk - and printk can be called 
> > from hardirqs-off sections - so this doesnt really fix the bug. 
> > Netconsole should not do BH processing.
> 
> Well, it sort of "has to".  It calls the NAPI ->poll() method of the 
> driver to try and make forward progress with TX reclaim so it can 
> send new messages.
> 
> It is very careful not to recursively invoke into ->poll() and other 
> nasty situations.
> 
> Didn't you write some of this code Ingo a very long time ago? :-)))

it is causing problems, so i'd like to distance myself from that 
careless mistake of my youth! [ And once it starts working again i'd 
like to take credit for having started that brilliant piece of 
innovation. ]

> Anyways, I'll look more closely at this and the original report, 
> this never was a problem before.

Thanks! We strengthened/cleaned up the bh checks a tiny bit recently, 
maybe that caused this to pop up. It might explain some netconsole 
lockups perhaps? Or, the new warning might be bogus. It's a bit of a 
maze.

	Ingo
