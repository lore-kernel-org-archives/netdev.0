From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [net-next-2.6 PATCH RFC] TCPCT part 1d: generate Responder
	Cookie
Date: Thu, 5 Nov 2009 06:59:33 -0800
Message-ID: <20091105145933.GA6770@linux.vnet.ibm.com>
References: <4AEAC763.4070200@gmail.com> <4AED86AD.6010906@gmail.com> <4AEDCD7C.2010403@gmail.com> <4AF0B0D2.4030905@gmail.com> <20091104214844.GA6714@linux.vnet.ibm.com> <4AF2C266.1010603@gmail.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Linux Kernel Developers <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: William Allen Simpson <william.allen.simpson@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756697AbZKEO7d@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4AF2C266.1010603@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 05, 2009 at 07:17:42AM -0500, William Allen Simpson wrote:
> Paul E. McKenney wrote:
>> On Tue, Nov 03, 2009 at 05:38:10PM -0500, William Allen Simpson wrote:
>>> Documentation/RCU/checklist.txt #7 says:
>>>
>>>   One exception to this rule: rcu_read_lock() and rcu_read_unlock()
>>>   may be substituted for rcu_read_lock_bh() and rcu_read_unlock_bh()
>>>   in cases where local bottom halves are already known to be
>>>   disabled, for example, in irq or softirq context.  Commenting
>>>   such cases is a must, of course!  And the jury is still out on
>>>   whether the increased speed is worth it.
>> I strongly suggest using the matching primitives unless you have a
>> really strong reason not to.
> Eric gave contrary advice.  But he also suggested (in an earlier message)
> clearing the secrets with a timer, which could be a separate context --
> although much later in time.
>
> As you suggest, I'll use the _bh suffix everywhere until every i is dotted
> and t is crossed.  Then, check for efficiency later after thorough
> analysis by experts such as yourself.
>
> This code will be hit on every SYN and SYNACK that has a cookie option.
> But it's just prior to a CPU intensive sha_transform -- in comparison,
> it's trivial.

Had Eric said that this code were performance-critical, where every
nanosecond mattered, that would certainly be good enough for me.
Eric has excellent knowledge of the networking code, certainly much
better than mine.  And 10Gb Ethernet is certainly a performance
challenge, and I don't expect 40Gb Ethernet to be any easier.

Of course, I would still argue that the use of rcu_read_lock() rather
than rcu_read_unlock() needs to be commented.  And if this sort of
substitution happens a lot, maybe we need a way for it to happen
automatically.

							Thanx, Paul

>>> +			rcu_assign_pointer(tcp_secret_generating,
>>> +					   tcp_secret_secondary);
>>> +			rcu_assign_pointer(tcp_secret_retiring,
>>> +					   tcp_secret_primary);
>>> +			spin_unlock_bh(&tcp_secret_locker);
>>> +			/* call_rcu() or synchronize_rcu() not needed. */
>> Would you be willing to say why?  Are you relying on a time delay for a
>> given item to pass through tcp_secret_secondary and tcp_secret_retiring
>> or some such?  If so, how do you know that this time delay will always
>> be long enough?
>> Or are you just shuffling the data structures around, without ever
>> freeing them?  If so, is it really OK for a given reader to keep a
>> reference to a given item through the full range of shuffling, especially
>> given that it might be accesssing this concurrently with the ->expires
>> assignments above?
>> Either way, could you please expand the comment to give at least some
>> hint to the poor guy reading your code?  ;-)
> Yes.  Just shuffling the pointers without ever freeing anything.  So,
> there's nothing for call_rcu() to do, and nothing else to synchronize
> (only the pointers).  This assumes that after _unlock_ any CPU cache
> with an old pointer->expires will hit the _lock_ code, and that will
> update *both* ->expires and the other array elements concurrently?
>
> One of the advantages of this scheme is the new secret is initialized
> while the old secret is still used, and the old secret can continue to
> be verified as old packets arrive.  (I originally designed this for
> Photuris [RFC-2522] circa 1995.)
>
> As described in the long header given, each array element goes through
> four (4) states.  This is handling the first state transition.  It will
> hit at least 2 more locks, pointer updates, and unlocks before reuse.
>
> Also, a great deal of time passes.  After being retired (and expired), it
> will be unused for approximately 5 minutes.
>
> All that's a bit long for a comment.
>
> +			/*
> +			 * The retiring data is never freed.  Instead, it is
> +			 * replaced after later pointer updates and a quiet
> +			 * time of approximately 5 minutes.  There is nothing
> +			 * for call_rcu() or synchronize_rcu() to handle.
> +			 */
>
> Clear enough?
