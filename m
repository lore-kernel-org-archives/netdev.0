From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH net-next rfc 5/6] net-tc: convert tc_at to tc_at_ingress
Date: Wed, 4 Jan 2017 14:26:15 -0500
Message-ID: <CAF=yD-+x7zP2Z5Ctsn9-_uYz7sfdZMf4n414CE1-bzVQcN3nBA@mail.gmail.com>
References: <1482952410-50003-1-git-send-email-willemdebruijn.kernel@gmail.com>
 <1482952410-50003-6-git-send-email-willemdebruijn.kernel@gmail.com> <586D4A6F.7020009@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Florian Westphal <fw@strlen.de>, dborkman@iogearbox.net,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Willem de Bruijn <willemb@google.com>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f194.google.com ([209.85.217.194]:33171 "EHLO
        mail-ua0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1759103AbdADT1b (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Jan 2017 14:27:31 -0500
Received: by mail-ua0-f194.google.com with SMTP id d5so30384470uag.0
        for <netdev@vger.kernel.org>; Wed, 04 Jan 2017 11:26:56 -0800 (PST)
In-Reply-To: <586D4A6F.7020009@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
>> index ef53ede..be4e18d 100644
>> --- a/net/sched/sch_api.c
>> +++ b/net/sched/sch_api.c
>> @@ -1865,6 +1865,7 @@ int tc_classify(struct sk_buff *skb, const struct
>> tcf_proto *tp,
>>         const struct tcf_proto *old_tp = tp;
>>         int limit = 0;
>>
>> +       skb->tc_at_ingress = !!(tp && tp->q->flags & TCQ_F_INGRESS);
>
>
> I'd prefer if skb->tc_at_ingress is set directly to 0/1 in
> sch_handle_ingress()
> and __dev_queue_xmit() as we do right now, this would avoid above tests in
> fast
> path and it would also avoid to set the same thing in tc_classify() multiple
> times f.e. on egress path walking through multiple qdiscs. I don't see
> anything
> in layers above tc that would read it and expect an AT_STACK-like
> equivalent.
> skb_reset_tc() could thus still remain as you have above in fast-path like
> __netif_receive_skb_core().

I had been thinking about that. After submitting this I noticed that Florian's
patchset had an elegant solution to avoid the branch: set tc_at_ingress in
handle_ing before tc_classify and clear it on the return path.

Then we only set + clear it once on ingress regardless of the depth
of classifiers and do not touch it at all in other code.

https://patchwork.ozlabs.org/patch/472698/

What do you think of that approach?
