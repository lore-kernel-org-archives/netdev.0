From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH] af_unix: fix entry locking in unix_dgram_recvmsg
Date: Wed, 02 Dec 2015 13:02:44 -0500 (EST)
Message-ID: <20151202.130244.140973474498435711.davem@davemloft.net>
References: <87h9k41pyq.fsf@doppelsaurus.mobileactivedefense.com>
	<871tb6nlue.fsf@doppelsaurus.mobileactivedefense.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: rweikusat@mobileactivedefense.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <871tb6nlue.fsf@doppelsaurus.mobileactivedefense.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Date: Tue, 01 Dec 2015 17:02:33 +0000

> Rainer Weikusat <rw@doppelsaurus.mobileactivedefense.com> writes:
> 
> [...]
> 
>> Insofar I understand the comment in this code block correctly,
>>
>>         err = mutex_lock_interruptible(&u->readlock);
>>         if (unlikely(err)) {
>>                 /* recvmsg() in non blocking mode is supposed to return -EAGAIN
>>                  * sk_rcvtimeo is not honored by mutex_lock_interruptible()
>>                  */
>>                 err = noblock ? -EAGAIN : -ERESTARTSYS;
>>                 goto out;
>>         }
>>
>> setting a receive timeout for an AF_UNIX datagram socket also doesn't
>> work as intended because of this: In case of n readers with the same
>> timeout, the nth reader will end up blocking n times the timeout.
> 
> Test program which confirms this. It starts four concurrent reads on the
> same socket with a receive timeout of 3s. This means the whole program
> should take a little more than 3s to execute as each read should time
> out at about the same time. But it takes 12s instead as the reads
> pile up on the readlock mutex and each then gets its own timeout once it
> could enter the receive loop.

I'm fine with your changes.

So with your patch, the "N * timeout" behavior, where N is the number
of queues reading threads, no longer occurs?  Do they all now properly
get released at the appropriate timeout?
