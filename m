From: Xin Long <lucien.xin@gmail.com>
Subject: Re: [PATCH net] net: sched: fix NULL pointer dereference when action
 calls some targets
Date: Thu, 17 Aug 2017 19:45:45 +1200
Message-ID: <CADvbK_cEqE-SN+NqRAukDcHD8nB6MW5cCYpbjKSMmF7hyYRJuA@mail.gmail.com>
References: <0fa9a53725dd661571461cf283ec88cf15f4b139.1501932907.git.lucien.xin@gmail.com>
 <CAM_iQpWcg0a46gJ6Qp3F1pqvvsaJYajmDC2uG_mi9Av_vkFo2w@mail.gmail.com>
 <CADvbK_fuuBrh+eOuhQU+SYs9uazH2TRP+KUmhxU=hNZ=EkOT=Q@mail.gmail.com>
 <CAM_iQpXbtHDxVjZ=DoTiLXHLQy6q=JVBa66EqSOy95ZbFg-wkQ@mail.gmail.com>
 <CADvbK_cCQY0McHiZFKSTjdGdAjhB6RBej5n=SH2=hsLYC=Xa7w@mail.gmail.com> <CAM_iQpVDQ3iZ-bRPNNPKtXPTRQXdTJFtzPcMn2SupZWy6O_cqw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: network dev <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        netfilter-devel@vger.kernel.org,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f194.google.com ([209.85.220.194]:33161 "EHLO
        mail-qk0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750926AbdHQHpr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Aug 2017 03:45:47 -0400
In-Reply-To: <CAM_iQpVDQ3iZ-bRPNNPKtXPTRQXdTJFtzPcMn2SupZWy6O_cqw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 17, 2017 at 5:57 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> On Wed, Aug 16, 2017 at 1:39 AM, Xin Long <lucien.xin@gmail.com> wrote:
>> On Wed, Aug 9, 2017 at 7:33 AM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
>>> On Mon, Aug 7, 2017 at 7:33 PM, Xin Long <lucien.xin@gmail.com> wrote:
>>>> On Tue, Aug 8, 2017 at 9:15 AM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
>>>>> This looks like a completely API burden?
>>>> netfilter xt targets are not really compatible with netsched action.
>>>> I've got to say, the patch is just a way to make checkentry return
>>>> false and avoid panic. like [1] said
>>>
>>> I don't doubt you fix a crash, I am thinking if we can
>>> "fix" the API instead of fixing the caller.
>> Hi, Cong,
>>
>> For now, I don't think it's possible to change APIs or  some of their targets
>> for the panic caused by action xt calling.
>>
>> The common way should be fixed in net_sched side.
>>
>> Given that the issue is very easy to triggered,
>> let's wait for netfilter's replies for another few days,
>> otherwise I will repost the fix, agree ?
>
> Yeah, no objections from me.
>
> By the way, do you know how other callers of this API
> use 'entryinfo'? Do they pass the address of the struct
> on stack too?
afaik, two places:
1. translate_table -> find_check_entry -> check_target -> xt_check_target
most iptables operations go there and .entryinfo is set in check_target
with struct ipt_entry *e, which is an iptable rule, so can't be NULL.
(as well as ip6table in netfilter/ip6_tables.c )

2. nft_target_init -> xt_check_target, where nft_target_set_tgchk_param
does the exact thing to set .entryinfo with a local varible union nft_entry e:
union nft_entry {
        struct ipt_entry e4;
        struct ip6t_entry e6;
        struct ebt_entry ebt;
        struct arpt_entry arp;
};

case 2 is actually what nft does to use xt targets, so net/sched
action should do
the same.
