From: Patrick McHardy <kaber@trash.net>
Subject: Re: mutex WARNING while running ip from iproute2 package
Date: Thu, 24 Apr 2008 05:12:14 +0200
Message-ID: <480FFA8E.1040407@trash.net>
References: <200804201757.09938.denys@visp.net.lb> <20080423.194125.202757521.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: denys@visp.net.lb, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:55087 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751812AbYDXDMP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Apr 2008 23:12:15 -0400
In-Reply-To: <20080423.194125.202757521.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Denys Fedoryshchenko <denys@visp.net.lb>
> Date: Sun, 20 Apr 2008 17:57:09 +0300
> 
>> Just noticed warning while upgrading and loading 2.6.25.
>> Configuration a bit complicated, so it is difficult to tell which command trigger it.
>> If it is required, i can spend time and will try to find it.
>>
>> It is QEMU machine, non-smp.
> 
> Thanks for your report.
> 
> Patrick, it looks pretty simple, if you bring up a macvlan device using
> rtnetlink, we take the RTNL lock recursively via the call to
> dev_unicast_add() performed by the macvlan open method.
> 
> Can you have a look?

Sure. This seems to be the bogus ASSERT_RTNL warning caused
by mutex_trylock() while holding a spinlock. The warning
itself is harmless, since we're already holding the RTNL,
mutex_trylock won't succeed.

Herbert suggested to store address updates in atomic context
on a temporary list and do the actual update in process
context. This seems like a good idea to simplify the address
list locking, unfortunately I didn't manage to take care of
this yet. An alternative fix to silent the bogus warning would
be to use mutex_is_locked in ASSERT_RTNL, but Herbert didn't
like that idea.

