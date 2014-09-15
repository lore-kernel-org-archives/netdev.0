From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net-next 2/5] net_sched: fix memory leak in cls_tcindex
Date: Mon, 15 Sep 2014 15:15:34 -0700
Message-ID: <CAM_iQpVCJ9Hge4c3o-jzwWD+8cryoZFC49wHJH14-r9HYzzRVw@mail.gmail.com>
References: <1410815210-6693-1-git-send-email-xiyou.wangcong@gmail.com>
	<1410815210-6693-3-git-send-email-xiyou.wangcong@gmail.com>
	<54175D17.6030109@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	john fastabend <john.fastabend@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f41.google.com ([209.85.219.41]:45466 "EHLO
	mail-oa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932799AbaIOWPe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2014 18:15:34 -0400
Received: by mail-oa0-f41.google.com with SMTP id n16so3063767oag.14
        for <netdev@vger.kernel.org>; Mon, 15 Sep 2014 15:15:34 -0700 (PDT)
In-Reply-To: <54175D17.6030109@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 15, 2014 at 2:41 PM, John Fastabend
<john.r.fastabend@intel.com> wrote:
> On 09/15/2014 02:06 PM, Cong Wang wrote:
>> Fixes: commit 331b72922c5f58d48fd ("net: sched: RCU cls_tcindex")
>> Cc: John Fastabend <john.fastabend@gmail.com>
>> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
>> ---
>>  net/sched/cls_tcindex.c | 13 +++++++------
>>  1 file changed, 7 insertions(+), 6 deletions(-)
>>
>> diff --git a/net/sched/cls_tcindex.c b/net/sched/cls_tcindex.c
>> index a02ca72..16ec1ed 100644
>> --- a/net/sched/cls_tcindex.c
>> +++ b/net/sched/cls_tcindex.c
>> @@ -243,7 +243,7 @@ tcindex_set_parms(struct net *net, struct tcf_proto *tp, unsigned long base,
>>        */
>>       cp = kzalloc(sizeof(*cp), GFP_KERNEL);
>>       if (!cp)
>> -             return -ENOMEM;
>> +             goto errout;
>
> but you need to set 'err = -ENOMEM' then.

Yeah, I thought err is initialized to ENOMEM.

>
>>
>>       cp->mask = p->mask;
>>       cp->shift = p->shift;
>> @@ -257,6 +257,7 @@ tcindex_set_parms(struct net *net, struct tcf_proto *tp, unsigned long base,
>>                                     sizeof(*r) * cp->hash, GFP_KERNEL);
>>               if (!cp->perfect)
>>                       goto errout;
>> +             balloc = 1;
>
> Actually can we just get rid of the balloc here altogether and
> remove the checks in errout_alloc so that cp->perfect and cp->h
> are freed unconditionally? They should be NULL if they are not
> being used because of the kzalloc.
>

Hmm, but for cp->h which you don't duplicate if we free it we
free p->h too, which seems not expected. I think we probably
need to cp->h = kmemdup(p->h) as well.
