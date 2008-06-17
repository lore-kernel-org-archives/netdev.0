From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: netlink circular locking dependency
Date: Tue, 17 Jun 2008 03:45:54 +0200
Message-ID: <1213667154.21932.47.camel@violet.holtmann.net>
References: <20080616213417.GA14988@ami.dom.local>
	 <4856DF91.30606@trash.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jarek Poplawski <jarkao2@gmail.com>, netdev@vger.kernel.org,
	Ingo Molnar <mingo@elte.hu>, Thomas Graf <tgraf@suug.ch>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:32998 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752384AbYFQBmb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jun 2008 21:42:31 -0400
In-Reply-To: <4856DF91.30606@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Patrick,

> >> =======================================================
> >> [ INFO: possible circular locking dependency detected ]
> >> 2.6.26-rc2 #5
> >> -------------------------------------------------------
> >> hcid/4136 is trying to acquire lock:
> >>  (genl_mutex){--..}, at: [<c0000000002ace4c>] .ctrl_dumpfamily+0x74/0x174
> >>
> >> but task is already holding lock:
> >>  (nlk->cb_mutex){--..}, at: [<c0000000002a766c>] .netlink_dump+0x58/0x27c
> >>
> >> which lock already depends on the new lock.
> >>     
> > ...
> >
> > Hi,
> >
> > IMHO it looks like a real lockup threat. Probably it needs something
> > better, but for now here is my simplistic patch proposal for testing.
> >   
> So we have:
> 
> genl_rcv()            : take genl_mutex
> genl_rcv_msg()        : call netlink_dump_start() while holding genl_mutex
> netlink_dump_start(),
> netlink_dump()        : take nlk->cb_mutex
> ctrl_dumpfamily()     : try to detect this case and not take genl_mutex a
>                         second time
> 
> netlink_rcv()         : call netlink_dump
> netlink_dump          : take nlk->cb_mutex
> ctrl_dumpfamily()     : take genl_mutex
> 
> which is a real bug.
> 
> It seems the best fix is to use genl_mutex for the netlink cb_mutex,
> drop genl_mutex before calling netlink_dump_start and don't take it
> in ctrl_dumpfamily, relying completely on af_netlink.c for dump
> locking. Unfortunately this creates a race since the ops passed to
> netlink_dump_start are also protect by the mutex, so this patch
> is just for testing whether it fixes the warning.

I updated my test kernel to 2.6.26-rc6 and then applied your patch and
the lockdep warning goes away.

Regards

Marcel


