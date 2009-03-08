From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: IPv4/IPv6 sysctl unregistration deadlock
Date: Sat, 07 Mar 2009 19:36:53 -0800
Message-ID: <m1zlfwbs8a.fsf@fess.ebiederm.org>
References: <49AC5BC1.3030901@trash.net>
	<20090302.144725.223672439.davem@davemloft.net>
	<49AC65A4.6020908@trash.net>
	<20090303.004829.160372230.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, greearb@candelatech.com, shemminger@vyatta.com,
	herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:57709 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753581AbZCHDhE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Mar 2009 22:37:04 -0500
In-Reply-To: <20090303.004829.160372230.davem@davemloft.net> (David Miller's message of "Tue\, 03 Mar 2009 00\:48\:29 -0800 \(PST\)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

> From: Patrick McHardy <kaber@trash.net>
> Date: Tue, 03 Mar 2009 00:03:00 +0100
>
>> David Miller wrote:
>> > From: Patrick McHardy <kaber@trash.net>
>> > Date: Mon, 02 Mar 2009 23:20:49 +0100
>> > 
>> >> This looks like its working fine. Despite the non-desirable active
>> >> spinning, this seems like the best fix (actually much simpler than
>> >> I expected to be possible) at this time. If we just could avoid
>> >> the spinning when unnecessary, it would be perfect :)
>> > Could you give that "not actually in-progress" detection a shot?
>> > I don't like the spinning either.
>> 
>> I tried this morning, the problem is that its always the sysctl
>> handler which will run into the deadlock first, but there is no
>> reliable indication to avoid it other than that the RTNL is
>> already held. The problem is that the sysctl interface puts the
>> process holding the RTNL to sleep and allows a process requiring
>> it to run. Any different synchronization attempt will have the
>> same problem, it seems you simply can't hold any locks while
>> unregistering sysctls.
>
> Ok, I applied Stephen's patches then...

>From the further brainstorming department...

It appears we are using the wait for the completion
for two distinct purposes.

Waiting until it is safe to free storage.

Blocking module unregistration until the all of the
users of the code are gone.

I'm wondering if we could move the memory freeing.

And consolidate the waiting ultimately moving the
wait for completion into netdev_run_todo after
we drop the lock.

The reason I care is that it looks like to get hotplug
handling sane, I'm going to need to implement a generic
version of what sysfs, proc and sysctl are doing, and I
expect that generic version belongs in the vfs ultimately
giving us the capability to implement revoke.

So I am going to be revisiting how the code works, and if
I can come up with a cleaner solution to the networking
stack it would be a good time to implement it.

Eric
