From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH] ipv6: Fix soft lockup for ipv6 network notifier.
Date: Wed, 6 Jul 2016 16:15:10 +0800
Message-ID: <577CBE0E.1050809@huawei.com>
References: <57761E04.8030202@huawei.com>
 <1467359847.11238.34.camel@edumazet-glaptop3.roam.corp.google.com>
 <5776258F.6080008@huawei.com>
 <1467361396.11238.35.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <luto@kernel.org>, <mingo@kernel.org>,
	<linux-kernel@vger.kernel.org>, Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Cong Wang <cwang@twopensource.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1467361396.11238.35.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2016/7/1 16:23, Eric Dumazet wrote:
> On Fri, 2016-07-01 at 16:10 +0800, Ding Tianhong wrote:
>> On 2016/7/1 15:57, Eric Dumazet wrote:
>>> On Fri, 2016-07-01 at 15:38 +0800, Ding Tianhong wrote:
>>> ...
>>>>  net/ipv6/addrconf.c | 6 ++++++
>>>>  1 file changed, 6 insertions(+)
>>>>
>>>> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
>>>> index f555f4f..e294a3d 100644
>>>> --- a/net/ipv6/addrconf.c
>>>> +++ b/net/ipv6/addrconf.c
>>>> @@ -3284,6 +3284,12 @@ restart:
>>>>  		spin_unlock_bh(&addrconf_hash_lock);
>>>>  	}
>>>> =20
>>>> +	/*
>>>> +	 * It is safe here to schedule out to avoid softlocking if preem=
pt
>>>> +	 * is disabled.
>>>> +	 */
>>>> +	cond_resched();
>>>> +
>>>>  	write_lock_bh(&idev->lock);
>>>> =20
>>>>  	addrconf_del_rs_timer(idev);
>>>
>>> Seeing you apparently cooked your patch against an old kernel (whic=
h
>>> one ?) ...
>>>
>>> I tried vanilla net-next kernel, and apparently I could not trigger=
 the
>>> softlockup you mentioned.
>>>
>>> Are you sure current kernel has a bug to begin with ?
>>>
>> have you disable the preempt? The problem will disappear if you enab=
le the preempt voluntary or preempt.
>> CONFIG_PREEMPT_NONE=3Dy
>> # CONFIG_PREEMPT_VOLUNTARY is not set
>> # CONFIG_PREEMPT is not set
>>
>> I test the 4.1 lts kernel and found this problem, and I didn't found=
 any patch to fix this from linux 4.1, but I will try to test in 4.7 ke=
rnel version.
>=20
> I usually do not have PREEMPT enabled in my kernels.
>=20
> $ grep PREEMPT .config
> CONFIG_PREEMPT_NOTIFIERS=3Dy
> CONFIG_PREEMPT_NONE=3Dy
> # CONFIG_PREEMPT_VOLUNTARY is not set
> # CONFIG_PREEMPT is not set
>=20
> Also the whole script is quite fast on latest kernels. I am guessing =
you
> are chasing an already fixed problem.
>=20
>=20
Hi Eric=EF=BC=9A

I had found out that the patch aaf92f(netfilter: conntrack: resched in =
nf_ct_iterate_cleanup) solve the problem,=20
this patch add cond_sched() in the nf_ct_iterate_cleanup() which will b=
e called in the net notifier chain every time,
and I revert this patch at kernel 4.7-rc4 , it will panic for soft lock=
up, so I am not sure whether our patch is need,
it looks like if I disable the CONFIG for netfilter that would register=
 the nf_ct_iterate_cleanup as notifier, the problem still be exist.

Thanks.
Ding=20






>=20
>=20
> .
>=20
