From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH] af_unix: fix entry locking in unix_dgram_recvmsg
Date: Thu, 03 Dec 2015 18:06:36 -0500 (EST)
Message-ID: <20151203.180636.1484783292398481186.davem@davemloft.net>
References: <871tb6nlue.fsf@doppelsaurus.mobileactivedefense.com>
	<20151202.130244.140973474498435711.davem@davemloft.net>
	<87zixrusxq.fsf@doppelsaurus.mobileactivedefense.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: rweikusat@mobileactivedefense.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87zixrusxq.fsf@doppelsaurus.mobileactivedefense.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Date: Thu, 03 Dec 2015 21:24:17 +0000

> David Miller <davem@davemloft.net> writes:
>> So with your patch, the "N * timeout" behavior, where N is the number
>> of queues reading threads, no longer occurs?  Do they all now properly
>> get released at the appropriate timeout?
> 
> As far as I can tell, yes. With the change, unix_dgram_recvmsg has a
> read loop looking like this:
> 
> 	last = NULL; /* not really necessary */
> 	timeo = sock_rcvtimeo(sk, flags & MSG_DONTWAIT);
> 
> 	do {
> 		mutex_lock(&u->readlock);
> 
> 		skip = sk_peek_offset(sk, flags);
> 		skb = __skb_try_recv_datagram(sk, flags, &peeked, &skip, &err,
> 					      &last);
> 		if (skb)
> 			break;
> 
> 		mutex_unlock(&u->readlock);
> 
> 		if (err != -EAGAIN)
> 			break;
> 	} while (timeo &&
> 		 !__skb_wait_for_more_packets(sk, &err, &timeo, last));
> 
> u->readlock is only used to enforce serialized access while running code
> dealing with the peek offset. If there's currently nothing to receive,
> the mutex is dropped. Afterwards, non-blocking readers return with
> -EAGAIN and blocking readers go to sleep waiting for 'interesting
> events' via __skb_wait_for_more_packets without stuffing the mutex into
> a pocket and taking it with them: All non-blocking readers of a certain
> socket end up going to sleep via schedule_timeout call in the wait
> function, hence, each of them will be woken up once its timeout expires.

Great, thanks for the info.  I think you should submit this patch
formally.
