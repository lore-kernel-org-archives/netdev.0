From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][PPPOL2TP]: Fix SMP oops in pppol2tp driver
Date: Mon, 11 Feb 2008 21:30:48 -0800 (PST)
Message-ID: <20080211.213048.192442721.davem@davemloft.net>
References: <47B0C9F7.5040200@katalix.com>
	<20080211224924.GA2863@ami.dom.local>
	<47B0DD1E.5000608@katalix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, netdev@vger.kernel.org
To: jchapman@katalix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41282
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751184AbYBLFaR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Feb 2008 00:30:17 -0500
In-Reply-To: <47B0DD1E.5000608@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: James Chapman <jchapman@katalix.com>
Date: Mon, 11 Feb 2008 23:41:18 +0000

> Jarek Poplawski wrote:
> > On Mon, Feb 11, 2008 at 10:19:35PM +0000, James Chapman wrote:
> > ...
> >> Below is example output from lockdep. The oops is reproducible when  
> >> creating/deleting lots of sessions while passing data. The lock is being  
> >> acquired for read and write in softirq contexts.
> >>
> >> Is there a better way to fix this?
> >>
> >> =================================
> >> [ INFO: inconsistent lock state ]
> >> 2.6.24-core2 #1
> >> ---------------------------------
> >> inconsistent {in-softirq-R} -> {softirq-on-W} usage.
> >> openl2tpd/3215 [HC0[0]:SC0[0]:HE1:SE1] takes:
> >>   (&tunnel->hlist_lock){---?}, at: [<f8eea157>]
> >> pppol2tp_connect+0x517/0x6d0 [pppol2tp]
> >> {in-softirq-R} state was registered at:
> > 
> > IMHO, according to this, disabling bh should be enough. And if it's
> > like in this report: only read_lock is taken from softirqs, then this
> > should be necessary to change only all write_locks to write_lock_bh
> > (of course unless somewhere bhs are disabled already). Unless I miss
> > something?!
> 
> I thought so too. I tried _bh locks first and the problem still 
> occurred. Maybe I'll try it again in case I messed something up.

I agree with Jarek here, I look at all the code paths that take
->hlist_lock and all of them are in user context or software
interrupts.

Please get a lockdep trace with the change to _bh intead of
hw interrupt protection so we can find out what that doesn't
work.

Thanks!
