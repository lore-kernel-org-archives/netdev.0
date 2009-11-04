From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [net-next-2.6 PATCH RFC] TCPCT part 1d: generate Responder
	Cookie
Date: Wed, 4 Nov 2009 13:48:44 -0800
Message-ID: <20091104214844.GA6714@linux.vnet.ibm.com>
References: <4AEAC763.4070200@gmail.com> <4AED86AD.6010906@gmail.com> <4AEDCD7C.2010403@gmail.com> <4AF0B0D2.4030905@gmail.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Linux Kernel Developers <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: William Allen Simpson <william.allen.simpson@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932963AbZKDVsm@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4AF0B0D2.4030905@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 03, 2009 at 05:38:10PM -0500, William Allen Simpson wrote:
> Eric Dumazet wrote:
>> This patch looks fine, but I dont see how this new function is used.
>> Some points :
>> 1) We are working hard to remove rwlocks from network stack, so please 
>> dont
>> add a new one. You probably can use a seqlock or RCU, or a server handling 
>> 10.000 connections request per second on many NIC will hit this rwlock.
> This is my attempt at using RCU, as seqlock didn't seem to apply (and is
> missing any Documentation.)
>
> After the discussion about context, one question that I have is the need
> for the _bh suffix?
>
> +		rcu_read_lock_bh();
> +		memcpy(&xvp->cookie_bakery[0],
> +		       &rcu_dereference(tcp_secret_generating)->secrets[0],
> +		       sizeof(tcp_secret_generating->secrets));
> +		rcu_read_unlock_bh();
>
>
> Documentation/RCU/checklist.txt #7 says:
>
>   One exception to this rule: rcu_read_lock() and rcu_read_unlock()
>   may be substituted for rcu_read_lock_bh() and rcu_read_unlock_bh()
>   in cases where local bottom halves are already known to be
>   disabled, for example, in irq or softirq context.  Commenting
>   such cases is a must, of course!  And the jury is still out on
>   whether the increased speed is worth it.

I strongly suggest using the matching primitives unless you have a
really strong reason not to.

> diff --git a/include/linux/cryptohash.h b/include/linux/cryptohash.h
> index c118b2a..ec78a4b 100644
> --- a/include/linux/cryptohash.h
> +++ b/include/linux/cryptohash.h

[ . . . ]

> +			if (unlikely(tcp_secret_primary->expires ==
> +				     tcp_secret_secondary->expires)) {
> +				struct timespec tv;
> +	
> +				getnstimeofday(&tv);
> +				secrets[COOKIE_DIGEST_WORDS+0] ^= (u32)tv.tv_nsec;
> +				tcp_secret_secondary->expires = jiffy
> +							      + TCP_SECRET_1MSL;
> +			} else {
> +				tcp_secret_secondary->expires = jiffy
> +							      + TCP_SECRET_LIFE;
> +				tcp_secret_primary->expires = jiffy
> +							    + TCP_SECRET_2MSL;
> +			}
> +			memcpy(&tcp_secret_secondary->secrets[0],
> +			       &secrets[0],
> +			       sizeof(secrets));
> +
> +			rcu_assign_pointer(tcp_secret_generating,
> +					   tcp_secret_secondary);
> +			rcu_assign_pointer(tcp_secret_retiring,
> +					   tcp_secret_primary);
> +			spin_unlock(&tcp_secret_locker);
> +			/* call_rcu() or synchronize_rcu() not needed. */

Would you be willing to say why?  Are you relying on a time delay for a
given item to pass through tcp_secret_secondary and tcp_secret_retiring
or some such?  If so, how do you know that this time delay will always
be long enough?

Or are you just shuffling the data structures around, without ever
freeing them?  If so, is it really OK for a given reader to keep a
reference to a given item through the full range of shuffling, especially
given that it might be accesssing this concurrently with the ->expires
assignments above?

Either way, could you please expand the comment to give at least some
hint to the poor guy reading your code?  ;-)

							Thanx, Paul
