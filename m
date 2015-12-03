From: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Subject: Re: [RFC PATCH] af_unix: fix entry locking in unix_dgram_recvmsg
Date: Thu, 03 Dec 2015 21:24:17 +0000
Message-ID: <87zixrusxq.fsf@doppelsaurus.mobileactivedefense.com>
References: <87h9k41pyq.fsf@doppelsaurus.mobileactivedefense.com>
	<871tb6nlue.fsf@doppelsaurus.mobileactivedefense.com>
	<20151202.130244.140973474498435711.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rweikusat@mobileactivedefense.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151202.130244.140973474498435711.davem@davemloft.net> (David
	Miller's message of "Wed, 02 Dec 2015 13:02:44 -0500 (EST)")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> writes:
> From: Rainer Weikusat <rweikusat@mobileactivedefense.com>
>> Rainer Weikusat <rw@doppelsaurus.mobileactivedefense.com> writes:
>> 
>> [...]
>> 
>>> Insofar I understand the comment in this code block correctly,

[...]

>>>                 /* recvmsg() in non blocking mode is supposed to return -EAGAIN
>>>                  * sk_rcvtimeo is not honored by mutex_lock_interruptible()
>>>
>>> setting a receive timeout for an AF_UNIX datagram socket also doesn't
>>> work as intended because of this: In case of n readers with the same
>>> timeout, the nth reader will end up blocking n times the timeout.

[...]

> So with your patch, the "N * timeout" behavior, where N is the number
> of queues reading threads, no longer occurs?  Do they all now properly
> get released at the appropriate timeout?

As far as I can tell, yes. With the change, unix_dgram_recvmsg has a
read loop looking like this:

	last = NULL; /* not really necessary */
	timeo = sock_rcvtimeo(sk, flags & MSG_DONTWAIT);

	do {
		mutex_lock(&u->readlock);

		skip = sk_peek_offset(sk, flags);
		skb = __skb_try_recv_datagram(sk, flags, &peeked, &skip, &err,
					      &last);
		if (skb)
			break;

		mutex_unlock(&u->readlock);

		if (err != -EAGAIN)
			break;
	} while (timeo &&
		 !__skb_wait_for_more_packets(sk, &err, &timeo, last));

u->readlock is only used to enforce serialized access while running code
dealing with the peek offset. If there's currently nothing to receive,
the mutex is dropped. Afterwards, non-blocking readers return with
-EAGAIN and blocking readers go to sleep waiting for 'interesting
events' via __skb_wait_for_more_packets without stuffing the mutex into
a pocket and taking it with them: All non-blocking readers of a certain
socket end up going to sleep via schedule_timeout call in the wait
function, hence, each of them will be woken up once its timeout expires.
