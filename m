From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: Soft lockup in tc_classify
Date: Tue, 20 Dec 2016 12:47:18 +0100
Message-ID: <58591A46.4060703@iogearbox.net>
References: <c1c394d3-3aea-52a8-89e3-be57d4d46b8e@mellanox.com> <7394f89e-e8a5-5fb2-ee04-63bf1c4ef6e7@mellanox.com> <584EA60B.80803@iogearbox.net> <CAJ3xEMjABmvAMs6h0EqBgPH8QDDwF_x0COx01MkEw2pa+fp7LA@mail.gmail.com> <CAM_iQpVJ_Y5bB-RP2S2tK7sPNo6Atwcz5Ud8sG6bwDOSnq4NnA@mail.gmail.com> <18a64d65-1241-6c72-8333-47b0ae933139@mellanox.com> <CAM_iQpXUQYvvXonEXe0czd4osL5YxZ+G5B-PUddautcHnGOtQw@mail.gmail.com> <5a985705-11e5-1575-a049-723accb97608@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Or Gerlitz <gerlitz.or@gmail.com>,
        Linux Netdev List <netdev@vger.kernel.org>,
        Roi Dayan <roid@mellanox.com>,
        David Miller <davem@davemloft.net>,
        Jiri Pirko <jiri@mellanox.com>,
        John Fastabend <john.fastabend@gmail.com>,
        Hadar Hen Zion <hadarh@mellanox.com>
To: Shahar Klein <shahark@mellanox.com>,
        Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:48224 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751967AbcLTLrW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Dec 2016 06:47:22 -0500
In-Reply-To: <5a985705-11e5-1575-a049-723accb97608@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Shahar,

On 12/20/2016 07:22 AM, Shahar Klein wrote:
> On 12/19/2016 7:58 PM, Cong Wang wrote:
>> On Mon, Dec 19, 2016 at 8:39 AM, Shahar Klein <shahark@mellanox.com> wrote:
>>> On 12/13/2016 12:51 AM, Cong Wang wrote:
>>>>
>>>> On Mon, Dec 12, 2016 at 1:18 PM, Or Gerlitz <gerlitz.or@gmail.com> wrote:
>>>>>
>>>>> On Mon, Dec 12, 2016 at 3:28 PM, Daniel Borkmann <daniel@iogearbox.net>
>>>>> wrote:
>>>>>
>>>>>> Note that there's still the RCU fix missing for the deletion race that
>>>>>> Cong will still send out, but you say that the only thing you do is to
>>>>>> add a single rule, but no other operation in involved during that test?
>>>>>
>>>>> What's missing to have the deletion race fixed? making a patch or
>>>>> testing to a patch which was sent?
>>>>
>>>> If you think it would help for this problem, here is my patch rebased
>>>> on the latest net-next.
>>>>
>>>> Again, I don't see how it could help this case yet, especially I don't
>>>> see how we could have a loop in this singly linked list.
>>>
>>> I've applied cong's patch and hit a different lockup(full log attached):
>>
>> Are you sure this is really different? For me, it is still inside the loop
>> in tc_classify(), with only a slightly different offset.
>>
>>>
>>> Daniel suggested I'll add a print:
>>>                 case RTM_DELTFILTER:
>>> -                   err = tp->ops->delete(tp, fh);
>>> +                 printk(KERN_ERR "DEBUGG:SK %s:%d\n", __func__, __LINE__);
>>> +                 err = tp->ops->delete(tp, fh, &last);
>>>                         if (err == 0) {
>>>
>>> and I couldn't see this print in the output.....
>>
>> Hmm, that is odd, if this never prints, then my patch should not make any
>> difference.
>>
>> There are still two other cases where we could change tp->next, so do you
>> mind to add two more printk's for debugging?
>>
>> Attached is the delta patch.
>>
>> Thanks!
>
> I've added a slightly different debug print:
> @@ -368,11 +375,12 @@ static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n)
>                  if (tp_created) {
>                          RCU_INIT_POINTER(tp->next, rtnl_dereference(*back));
>                          rcu_assign_pointer(*back, tp);
> +                 printk(KERN_ERR "DEBUGG:SK add/change filter by: %pf tp=%p tp->next=%p\n", tp->ops->get, tp, tp->next);
>                  }
>                  tfilter_notify(net, skb, n, tp, fh, RTM_NEWTFILTER, false);

I'm curious, could you be a bit more verbose why you didn't go with Cong's
debug patch?

In particular, why you removed the hunk from the condition 'n->nlmsg_type ==
RTM_DELTFILTER && t->tcm_handle == 0' where we delete the whole tp instance?

Is it because if you have that printk() there, then the issue doesn't trigger
for you anymore? Or any other reason?

How many CPUs does your test machine have, I suspect more than 1, right?

So iff RTM_DELTFILTER with tcm_handle of 0 really played a role in this, I'm
wondering whether there was a subtle deletion + add race where the newly added
filter on the other CPU still saw a stale pointer in the list. But just a wild
guess at this point.

Hmm, could you try this below to see whether the issue still appears?

Thanks,
Daniel

diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index 3fbba79..4eee1cb 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -317,7 +317,7 @@ static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n)
  		if (n->nlmsg_type == RTM_DELTFILTER && t->tcm_handle == 0) {
  			struct tcf_proto *next = rtnl_dereference(tp->next);

-			RCU_INIT_POINTER(*back, next);
+			rcu_assign_pointer(*back, next);

  			tfilter_notify(net, skb, n, tp, fh,
  				       RTM_DELTFILTER, false);


> full output attached:
>
> [  283.290271] Mirror/redirect action on
> [  283.305031] DEBUGG:SK add/change filter by: fl_get [cls_flower] tp=ffff9432d704df60 tp->next=          (null)
> [  283.322563] DEBUGG:SK add/change filter by: fl_get [cls_flower] tp=ffff9436e718d240 tp->next=          (null)
> [  283.359997] GACT probability on
> [  283.365923] DEBUGG:SK add/change filter by: fl_get [cls_flower] tp=ffff9436e718d3c0 tp->next=ffff9436e718d240
> [  283.378725] DEBUGG:SK add/change filter by: fl_get [cls_flower] tp=ffff9436e718d3c0 tp->next=ffff9436e718d3c0
> [  283.391310] DEBUGG:SK add/change filter by: fl_get [cls_flower] tp=ffff9436e718d3c0 tp->next=ffff9436e718d3c0
> [  283.403923] DEBUGG:SK add/change filter by: fl_get [cls_flower] tp=ffff9436e718d3c0 tp->next=ffff9436e718d3c0
> [  283.416542] DEBUGG:SK add/change filter by: fl_get [cls_flower] tp=ffff9436e718d3c0 tp->next=ffff9436e718d3c0
> [  308.538571] NMI watchdog: BUG: soft lockup - CPU#0 stuck for 23s! [swapper/0:0]
>
> Thanks
> Shahar
