From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next-2.6 PATCH RFC] TCPCT part 1d: generate Responder	Cookie
Date: Thu, 05 Nov 2009 14:19:28 +0100
Message-ID: <4AF2D0E0.1040903@gmail.com>
References: <4AEAC763.4070200@gmail.com> <4AED86AD.6010906@gmail.com> <4AEDCD7C.2010403@gmail.com> <4AF0B0D2.4030905@gmail.com> <20091104214844.GA6714@linux.vnet.ibm.com> <4AF2C266.1010603@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: paulmck@linux.vnet.ibm.com,
	Linux Kernel Developers <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: William Allen Simpson <william.allen.simpson@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:33323 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756076AbZKENT0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Nov 2009 08:19:26 -0500
In-Reply-To: <4AF2C266.1010603@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

William Allen Simpson a =E9crit :
> Paul E. McKenney wrote:
>> On Tue, Nov 03, 2009 at 05:38:10PM -0500, William Allen Simpson wrot=
e:
>>> Documentation/RCU/checklist.txt #7 says:
>>>
>>>   One exception to this rule: rcu_read_lock() and rcu_read_unlock()
>>>   may be substituted for rcu_read_lock_bh() and rcu_read_unlock_bh(=
)
>>>   in cases where local bottom halves are already known to be
>>>   disabled, for example, in irq or softirq context.  Commenting
>>>   such cases is a must, of course!  And the jury is still out on
>>>   whether the increased speed is worth it.
>>
>> I strongly suggest using the matching primitives unless you have a
>> really strong reason not to.
>>
> Eric gave contrary advice.  But he also suggested (in an earlier mess=
age)
> clearing the secrets with a timer, which could be a separate context =
--
> although much later in time.
>=20
> As you suggest, I'll use the _bh suffix everywhere until every i is d=
otted
> and t is crossed.  Then, check for efficiency later after thorough
> analysis by experts such as yourself.
>=20
> This code will be hit on every SYN and SYNACK that has a cookie optio=
n.
> But it's just prior to a CPU intensive sha_transform -- in comparison=
,
> it's trivial.
>

I think you misunderstood my advice ;)

In the same function, you *cannot* use both variants like your last pat=
ch did :

		spin_lock(&tcp_secret_locker); =20

=2E..

		rcu_read_lock_bh();
		memcpy(&xvp->cookie_bakery[0],
		       &rcu_dereference(tcp_secret_generating)->secrets[0],
		       sizeof(tcp_secret_generating->secrets));
		rcu_read_unlock_bh();



Reasoning is :

If you need _bh() for the rcu_read_lock_bh(), thats because you know
soft irq can happen anytime (they are not masked).

Then you also need _bh for the spin_lock() call, or risk deadlock.

-> tcp_cookie_generator();
spin_lock();
-> interrupt  -> softirq -> SYN frame received -> tcp_cookie_generator(=
) -> spin_lock(); hang



Your choices are :
------------------

1) Caller took care of disabling softirqs (or is only called from softi=
rq handler),
then _bh suffixes are not necessary in tcp_cookie_generator().
 -> spin_lock() & rcu_read_lock();

2) You dont know what called you (process context or softirq context)
-> you MUST use _bh prefixes on spin_lock_bh() & rcu_read_lock_bh();


