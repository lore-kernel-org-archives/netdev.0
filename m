From: Patrick McHardy <kaber@trash.net>
Subject: Re: netlink circular locking dependency
Date: Tue, 17 Jun 2008 15:19:33 +0200
Message-ID: <4857B9E5.3070102@trash.net>
References: <20080616213417.GA14988@ami.dom.local> <4856DF91.30606@trash.net> <1213667154.21932.47.camel@violet.holtmann.net> <4857B30B.8020809@trash.net> <20080617130910.GA4632@ff.dom.local> <20080617130825.GD20815@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	Marcel Holtmann <marcel@holtmann.org>, netdev@vger.kernel.org,
	Ingo Molnar <mingo@elte.hu>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:63989 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757001AbYFQNTi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2008 09:19:38 -0400
In-Reply-To: <20080617130825.GD20815@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thomas Graf wrote:
> * Jarek Poplawski <jarkao2@gmail.com> 2008-06-17 13:09
>> On Tue, Jun 17, 2008 at 02:50:19PM +0200, Patrick McHardy wrote:
>> ...
>>> Thanks for testing. Unfortunately the module unload races look
>>> more complicated to fix and I'm busy with other things, so it
>>> would great if someone else could fix this.
>> Patrick, I wonder if simply adding an additional mutex e.g.
>> genl_lock_table() around all the rest (after your patch) genl_locks
>> could be enough until some major rework. This should prevent any
>> new races and there are no lockups, I guess?
> 
> It would be wise to redo the locking alltogether while we're fixing
> this. Decouple message serialization from register/unregister
> operations would be a nice thing f.e.

Agreed.

> I'll have a look if none beats me to it.

While whoever is at this, there are a few similar races I
wanted to fix for a long time, but never got to it.

- the rtnl_register/rtnl_unregister function don't perform any
locking, so they might get called while unregistration is
in progress

- the individual ops are registered one at a time, which could
theoretically lead to some strange behaviour where a subset of
the ops can already be used, but others return EOPNOTSUPP

- netlink_dump_start usage in rtnetlink has the exact same
race as genetlink with my patch

For 1. and 2., it seems the best way would be to register the
entire set of ops (encapsulated in a struct) at once and hold
the rtnl_mutex during that. For 3., the fix would probably
identical to the genetlink fix.

