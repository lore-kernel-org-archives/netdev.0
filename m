From: Fan Du <fan.du@windriver.com>
Subject: Re: [PATCH net-next] xfrm: fix RCU bugs
Date: Mon, 20 Aug 2012 14:33:59 +0800
Message-ID: <5031DA57.1000904@windriver.com>
References: <1345372308.5158.54.camel@edumazet-glaptop>	 <5031BFB1.200@windriver.com> <1345440800.5158.239.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, <fengguang.wu@intel.com>,
	Priyanka Jain <Priyanka.Jain@freescale.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:49599 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754004Ab2HTGcs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Aug 2012 02:32:48 -0400
In-Reply-To: <1345440800.5158.239.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2012=E5=B9=B408=E6=9C=8820=E6=97=A5 13:33, Eric Dumazet wrote:
> On Mon, 2012-08-20 at 12:40 +0800, Fan Du wrote:
>> Hi Eric
>>
>> Please correct me if I'm wrong about below comments.
>>
>> On 2012=E5=B9=B408=E6=9C=8819=E6=97=A5 18:31, Eric Dumazet wrote:
>>> From: Eric Dumazet<edumazet@google.com>
>>>
>>> This patch reverts commit 56892261ed1a (xfrm: Use rcu_dereference_b=
h to
>>> deference pointer protected by rcu_read_lock_bh), and fixes bugs
>>> introduced in commit 418a99ac6ad ( Replace rwlock on xfrm_policy_af=
info
>>> with rcu )
>>>
>>> 1) We properly use RCU variant in this file, not a mix of RCU/RCU_B=
H
>>>
>>> 2) We must defer some writes after the synchronize_rcu() call or a =
reader
>>>    can crash dereferencing NULL pointer.
>>
>> Not exactly.
>>
>> net/ipv4/xfrm4_policy.c
>> static void __exit xfrm4_policy_fini(void)
>>     ->  xfrm_policy_unregister_afinfo
>>
>> IMHO, ip stack can never be compiled as module, so is xfrm4_policy_f=
ini
>> freed up after system bootup? which means xfrm4_policy_fini can neve=
r be
>> called.
>>
>> so an dereferencing NULL pointer by a reader could not happen.
>>
>
> Last famous words.
>
> Anyway xfrm_policy_unregister_afinfo() is also called from
> xfrm6_policy_fini(), and IPv6 is a module. The day we can rmmod it,
> we uncover this bug.
>
> RCU is complex (most people dont get it right, thats the truth),
> and we should make it rock solid, or I can guarantee you
> many patch attempts from future readers of this code.
>
> You wont tell them :
>
> "OK but dont worry we never call this function for real, why do you c=
are
> at all"
>
You are correct!

And one out of topic question:
The usage of xfrm_state_afinfo_lock/xfrm_km_lock is extremely
similar with xfrm_policy_afinfo_lock, except the former is not so
frequently read than that of the later.

Is it justified to convert RW xfrm_state_afinfo_lock/xfrm_km_lock into
RCU?


>>>
>>> 3) Now we use the xfrm_policy_afinfo_lock spinlock only from proces=
s
>>> context, we no longer need to block BH in xfrm_policy_register_afin=
fo()
>>> and xfrm_policy_unregister_afinfo()
>>>
>> I don't think it's related to what kinds of locks we are using.
>> we call xfrm_policy_register_afinfo in process context, but actually
>> what xfrm_policy_afinfo_lock protected can be used in soft irq conte=
xt.
>> that's why xx_bh is used in:
>
> You did an RCU conversion and obviously have little idea of what
> happened there.
>
> This _bh stuff was needed because _before_ RCU, an rwlock was used.
>
> And since read_lock() was used from BH handler, _all_ write_lock() ha=
d
> to use the write_lock_bh() variant to avoid a possible deadlock.
>
> But after RCU, this no longer is needed, as an rcu_read_lock() cannot
> block a writer anymore in the lock/unlock section.
>
> In fact, xfrm_policy_afinfo_lock could be replaced by a mutex. So _bh=
()
> is absolutely not needed anymore.
>
I indeed misunderstood the code a bit.
Your explanation is crystal clear, thanks :)

>
>

--=20

Love each day!
--fan
