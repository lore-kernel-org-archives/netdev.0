From: Fan Du <fan.du@windriver.com>
Subject: Re: suspicious RCU usage in xfrm_net_init()
Date: Fri, 17 Aug 2012 10:03:18 +0800
Message-ID: <502DA666.3020703@windriver.com>
References: <20120816073724.GA10660@localhost> <502CBF23.4070805@windriver.com> <20120816151949.GA18681@localhost> <502D9938.2010908@windriver.com> <CAP=VYLqHW+NOS-gPgUkUpZh-Vim2jkmMT7NK+7uRbg730d=xHw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Fengguang Wu <fengguang.wu@intel.com>,
	Priyanka Jain <Priyanka.Jain@freescale.com>,
	<netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAP=VYLqHW+NOS-gPgUkUpZh-Vim2jkmMT7NK+7uRbg730d=xHw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 2012=E5=B9=B408=E6=9C=8817=E6=97=A5 09:34, Paul Gortmaker wrote:
> On Thu, Aug 16, 2012 at 9:07 PM, Fan Du<fan.du@windriver.com>  wrote:
>>
>>
>> On 2012=E5=B9=B408=E6=9C=8816=E6=97=A5 23:19, Fengguang Wu wrote:
>>>
>>> Hi Fan,
>>>
>>> On Thu, Aug 16, 2012 at 05:36:35PM +0800, Fan Du wrote:
>>>>
>>>>
>>>> Hi, Fengguang
>>>>
>>>> Could you please try the below patch, see if spewing still there?
>>>> thanks
>>>
>>>
>>> Yes, it worked, thank you very much!
>>>
>>
>> Hi, Dave
>>
>> Could you please pick up this patch?
>
> Please do not make extra work for maintainers by sending attachments,
> or requests for status/merge etc.  Your 1st patch had to be manually
> set to an RFC, and now you add another patch less than 24h later.
>
> Please see:
>
>    http://patchwork.ozlabs.org/patch/177934/
>    http://patchwork.ozlabs.org/patch/178132/
>
> Also, a patch should describe the problem it solves (i.e. the symptom
> the end user sees), and how the problem originated, and why the fix
> in the patch is the _right_ fix.  The worst description a commit log
> can have is one that just describes the C change in words, since
> most people can read C on their own.
>
> Here you add "_bh" in the code and then repeat exactly that in
> the commit log.  Your commit log does not tell me when it broke,
> or why it broke, or who had their use case broken.  Can you see
> why this is not acceptable?
>
> Please take the time to look at the traffic in netdev, and read
> the feedback given by maintainers on other patches, so that the
> common errors are understood by you, and not repeated.  It
> will be time well spent!
>

Rick Jones has already well informed me the etiquettes off the list,
which I just broken.

Anyway, thanks for your time writing those suggestions.

> Thanks,
> Paul.
> ---
>
>> thanks
>>
>>
>>
>>
>>> btw, your email client wraps long lines..
>>>
>> Oh, I will definitely fix this.
>> thanks feng guang for the testing :)
>>
>>
>>
>>> Thanks,
>>> Fengguang
>>>
>>>>    From a3f86ecc3ee16ff81d49416bbf791780422988b3 Mon Sep 17 00:00:=
00 2001
>>>> From: Fan Du<fan.du@windriver.com>
>>>> Date: Thu, 16 Aug 2012 17:31:25 +0800
>>>> Subject: [PATCH] Use rcu_dereference_bh to deference pointer
>>>> protected by rcu_read_lock_bh
>>>>
>>>> Signed-off-by: Fan Du<fan.du@windriver.com>
>>>> ---
>>>>    net/xfrm/xfrm_policy.c |    2 +-
>>>>    1 files changed, 1 insertions(+), 1 deletions(-)
>>>>
>>>> diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
>>>> index 5ad4d2c..75a9d6a 100644
>>>> --- a/net/xfrm/xfrm_policy.c
>>>> +++ b/net/xfrm/xfrm_policy.c
>>>> @@ -2501,7 +2501,7 @@ static void __net_init
>>>> xfrm_dst_ops_init(struct net *net)
>>>>          struct xfrm_policy_afinfo *afinfo;
>>>>
>>>>          rcu_read_lock_bh();
>>>> -       afinfo =3D rcu_dereference(xfrm_policy_afinfo[AF_INET]);
>>>> +       afinfo =3D rcu_dereference_bh(xfrm_policy_afinfo[AF_INET])=
;
>>>>          if (afinfo)
>>>>                  net->xfrm.xfrm4_dst_ops =3D *afinfo->dst_ops;
>>>>    #if IS_ENABLED(CONFIG_IPV6)
>>>> --
>>>> 1.7.1
>>>>
>>>>
>>>>
>>>>
>>>> On 2012=E5=B9=B408=E6=9C=8816=E6=97=A5 15:37, Fengguang Wu wrote:
>>>>>
>>>>> Hi Priyanka,
>>>>>
>>>>> The below warning shows up, probably related to this commit:
>>>>>
>>>>> 418a99ac6ad487dc9c42e6b0e85f941af56330f2 Replace rwlock on
>>>>> xfrm_policy_afinfo with rcu
>>>>>
>>>>> [    0.921216]
>>>>> [    0.921645] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>>>>> [    0.922766] [ INFO: suspicious RCU usage. ]
>>>>> [    0.923887] 3.5.0-01540-g1669891 #64 Not tainted
>>>>> [    0.925123] -------------------------------
>>>>> [    0.932860] /c/kernel-tests/src/tip/net/xfrm/xfrm_policy.c:250=
4
>>>>> suspicious rcu_dereference_check() usage!
>>>>> [    0.935361]
>>>>> [    0.935361] other info that might help us debug this:
>>>>> [    0.935361]
>>>>> [    0.937472]
>>>>> [    0.937472] rcu_scheduler_active =3D 1, debug_locks =3D 0
>>>>> [    0.939182] 2 locks held by swapper/1:
>>>>> [    0.940171]  #0:  (net_mutex){+.+.+.}, at: [<ffffffff814e1ad0>=
]
>>>>> register_pernet_subsys+0x21/0x57
>>>>> [    0.942705]  #1:  (rcu_read_lock_bh){......}, at:
>>>>> [<ffffffff822c7329>] xfrm_net_init+0x1e4/0x437
>>>>> [    0.951507]
>>>>> [    0.951507] stack backtrace:
>>>>> [    0.952660] Pid: 1, comm: swapper Not tainted 3.5.0-01540-g166=
9891
>>>>> #64
>>>>> [    0.954364] Call Trace:
>>>>> [    0.955074]  [<ffffffff8108b375>] lockdep_rcu_suspicious+0x174=
/0x187
>>>>> [    0.956736]  [<ffffffff822c7453>] xfrm_net_init+0x30e/0x437
>>>>> [    0.958205]  [<ffffffff822c7329>] ? xfrm_net_init+0x1e4/0x437
>>>>> [    0.959712]  [<ffffffff814e134a>] ops_init+0x1bb/0x1ff
>>>>> [    0.961067]  [<ffffffff810861f9>] ? trace_hardirqs_on+0x1b/0x2=
4
>>>>> [    0.962644]  [<ffffffff814e17cd>]
>>>>> register_pernet_operations.isra.5+0x9d/0xfe
>>>>> [    0.971376]  [<ffffffff814e1adf>] register_pernet_subsys+0x30/=
0x57
>>>>> [    0.972992]  [<ffffffff822c7130>] xfrm_init+0x17/0x2c
>>>>> [    0.974316]  [<ffffffff822c2f8c>] ip_rt_init+0x82/0xe7
>>>>> [    0.975668]  [<ffffffff822c31dc>] ip_init+0x10/0x25
>>>>> [    0.976952]  [<ffffffff822c3f77>] inet_init+0x235/0x360
>>>>> [    0.978352]  [<ffffffff822c3d42>] ? devinet_init+0xf2/0xf2
>>>>> [    0.979808]  [<ffffffff82283252>] do_one_initcall+0xb4/0x203
>>>>> [    0.981313]  [<ffffffff8228354a>] kernel_init+0x1a9/0x29a
>>>>> [    0.982732]  [<ffffffff822826d9>] ? loglevel+0x46/0x46
>>>>> [    0.990889]  [<ffffffff816d3d84>] kernel_thread_helper+0x4/0x1=
0
>>>>> [    0.992472]  [<ffffffff816d262c>] ? retint_restore_args+0x13/0=
x13
>>>>> [    0.994076]  [<ffffffff822833a1>] ? do_one_initcall+0x203/0x20=
3
>>>>> [    0.995636]  [<ffffffff816d3d80>] ? gs_change+0x13/0x13
>>>>> [    0.997197] TCP established hash table entries: 8192 (order: 5=
,
>>>>> 131072 bytes)
>>>>> [    1.000074] TCP bind hash table entries: 8192 (order: 7, 65536=
0
>>>>> bytes)
>>>>>
>>>>> Thanks,
>>>>> Fengguang
>>>>
>>>>
>>>> --
>>>>
>>>> Love each day!
>>>> --fan
>>>
>>>
>>
>> --
>>
>> Love each day!
>> --fan
>

--=20

Love each day!
--fan
