From: Cong Wang <amwang@redhat.com>
Subject: Re: [v2 Patch 3/3] bonding: make bonding support netpoll
Date: Wed, 07 Apr 2010 10:32:10 +0800
Message-ID: <4BBBEEAA.1050100@redhat.com>
References: <20100405091605.4890.31181.sendpatchset@localhost.localdomain> <20100405091628.4890.30541.sendpatchset@localhost.localdomain> <20100405194356.GA10488@gospo.rdu.redhat.com> <4BBA9FDB.4040909@redhat.com> <4BBABAB8.4010401@redhat.com> <20100406144824.GB10488@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Matt Mackall <mpm@selenic.com>,
	netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	Andy Gospodarek <gospo@redhat.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Jeff Moyer <jmoyer@redhat.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	bonding-devel@lists.sourceforge.net,
	Jay Vosburgh <fubar@us.ibm.com>,
	David Miller <davem@davemloft.net>
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42159 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752242Ab0DGC2t (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Apr 2010 22:28:49 -0400
In-Reply-To: <20100406144824.GB10488@gospo.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andy Gospodarek wrote:
> On Tue, Apr 06, 2010 at 12:38:16PM +0800, Cong Wang wrote:
>> Cong Wang wrote:
>>> Before I try to reproduce it, could you please try to replace the  
>>> 'read_lock()'
>>> in slaves_support_netpoll() with 'read_lock_bh()'? (read_unlock() too)  
>>> Try if this helps.
>>>
>> Confirmed. Please use the attached patch instead, for your testing.
>>
>> Thanks!
>>
> 
> Moving those locks to bh-locks will not resolve this.  I tried that
> yesterday and tried your new patch today without success.  That warning
> is a WARN_ON_ONCE so you need to reboot to see that it is still a
> problem.  Simply unloading and loading the new module is not an accurate
> test.
> 
> Also, my system still hangs when removing the bonding module.  I do not
> think you intended to fix this with the patch, but wanted it to be clear
> to everyone on the list.


Actually I did reboot and then tested the module. I didn't get any warning.
I just tried again today, and no warnings at all.

For removing bonding module, you may need another fix of mine,
which is to fix a potential deadlock of workqueue. Try:

http://lkml.org/lkml/2010/4/1/58

> 
> You should also configure your kernel with a some of the lock debugging
> enabled.  I've been using the following:
> 
> CONFIG_DETECT_HUNG_TASK=y
> CONFIG_DEBUG_SPINLOCK=y
> CONFIG_DEBUG_MUTEXES=y
> CONFIG_DEBUG_LOCK_ALLOC=y
> CONFIG_PROVE_LOCKING=y
> CONFIG_LOCKDEP=y
> CONFIG_LOCK_STAT=y
> CONFIG_DEBUG_LOCKDEP=y


Sure, I always keep these.

> 
> Here is the output when I remove a slave from the bond.  My
> xmit_roundrobin patch from earlier (replacing read_lock with
> read_trylock) was applied.  It might be helpful for you when debugging
> these issues.


I don't apply your patch, just tested my patch.

> 
> Dead loop on virtual device bond0, fix it urgently!
> 

Please provide your bonding configuration and steps to reproduce it.

What I did is:

1. Load bonding module with "mode=0 miimon=100"
2. Enslave eth0 and active bond0
3. Load netconsole and send messages via bond0
4. Remove eth0 from bond0
5. Remove bonding module
6. Remove netconsole module

And no deadlocks, no warnings.

Thanks.
