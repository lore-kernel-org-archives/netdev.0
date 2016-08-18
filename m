From: Feng Gao <gfree.wind@gmail.com>
Subject: Re: [PATCH v2 1/1] ppp: Fix one deadlock issue of PPP when send frame
Date: Thu, 18 Aug 2016 08:58:31 +0800
Message-ID: <CA+6hz4qROeAKSgQJ-tf3qaDp5zBqssq4gV39wqyUT0ctp1DHcg@mail.gmail.com>
References: <1471347218-24472-1-git-send-email-fgao@ikuai8.com> <20160817174219.y4opmhj4u77m3ufq@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Gao Feng <fgao@ikuai8.com>, paulus@samba.org,
	linux-ppp@vger.kernel.org,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Guillaume Nault <g.nault@alphalink.fr>
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <20160817174219.y4opmhj4u77m3ufq@alphalink.fr>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

inline answer.

On Thu, Aug 18, 2016 at 1:42 AM, Guillaume Nault <g.nault@alphalink.fr> wrote:
> On Tue, Aug 16, 2016 at 07:33:38PM +0800, fgao@ikuai8.com wrote:
>> From: Gao Feng <fgao@ikuai8.com>
>>
>> PPP channel holds one spinlock before send frame. But the skb may
>> select the same PPP channel with wrong route policy. As a result,
>> the skb reaches the same channel path. It tries to get the same
>> spinlock which is held before. Bang, the deadlock comes out.
>>
> Unless I misunderstood the problem you're trying to solve, this patch
> doesn't really help: deadlock still occurs if the same IP is used for
> L2TP and PPP's peer address.
>

The deadlock happens because the same cpu try to hold the spinlock
which is already held before by itself.
Now the PPP_CHANNEL_LOCK_BH sets the lock owner after hold lock, then
when the same cpu
invokes PPP_CHANNEL_LOCK_BH again. The cl.owner equals current cpu id,
so it only increases
the lock_cnt without trying to hold the lock again.
So it avoids the deadlock.

>> Now add one lock owner to avoid it like xmit_lock_owner of
>> netdev_queue. Check the lock owner before try to get the spinlock.
>> If the current cpu is already the owner, needn't lock again. When
>> PPP channel holds the spinlock at the first time, it sets owner
>> with current CPU ID.
>>
> I think you should forbid lock recursion entirely, and drop the packet
> if the owner tries to re-acquire the channel lock. Otherwise you just
> move the deadlock down the stack (l2tp_xmit_skb() can't be called
> recursively).

The reason that fix it in ppp is that there are other layer on the ppp module.
We resolve it in ppp module, it could avoid all similar potential issues.

>
>> diff --git a/drivers/net/ppp/ppp_generic.c b/drivers/net/ppp/ppp_generic.c
>> index 70cfa06..6909ab1 100644
>> --- a/drivers/net/ppp/ppp_generic.c
>> +++ b/drivers/net/ppp/ppp_generic.c
>> @@ -162,6 +162,37 @@ struct ppp {
>>                        |SC_MULTILINK|SC_MP_SHORTSEQ|SC_MP_XSHORTSEQ \
>>                        |SC_COMP_TCP|SC_REJ_COMP_TCP|SC_MUST_COMP)
>>
>> +struct chennel_lock {
>             ^
> I guess you meant 'channel_lock'.

Yes. It is a typo. Thanks.

>
>> +     spinlock_t lock;
>> +     u32 owner;
> This field's default value is -1. So why not declaring it as 'int'?

OK. I will fix it.

Best Regards
Feng
