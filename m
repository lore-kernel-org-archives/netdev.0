From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next rfc 5/6] net-tc: convert tc_at to tc_at_ingress
Date: Wed, 04 Jan 2017 20:51:13 +0100
Message-ID: <586D5231.5080706@iogearbox.net>
References: <1482952410-50003-1-git-send-email-willemdebruijn.kernel@gmail.com> <1482952410-50003-6-git-send-email-willemdebruijn.kernel@gmail.com> <586D4A6F.7020009@iogearbox.net> <CAF=yD-+x7zP2Z5Ctsn9-_uYz7sfdZMf4n414CE1-bzVQcN3nBA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Network Development <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Florian Westphal <fw@strlen.de>, dborkman@iogearbox.net,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Willem de Bruijn <willemb@google.com>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:58037 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1761979AbdADTvR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Jan 2017 14:51:17 -0500
In-Reply-To: <CAF=yD-+x7zP2Z5Ctsn9-_uYz7sfdZMf4n414CE1-bzVQcN3nBA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/04/2017 08:26 PM, Willem de Bruijn wrote:
>>> diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
>>> index ef53ede..be4e18d 100644
>>> --- a/net/sched/sch_api.c
>>> +++ b/net/sched/sch_api.c
>>> @@ -1865,6 +1865,7 @@ int tc_classify(struct sk_buff *skb, const struct
>>> tcf_proto *tp,
>>>          const struct tcf_proto *old_tp = tp;
>>>          int limit = 0;
>>>
>>> +       skb->tc_at_ingress = !!(tp && tp->q->flags & TCQ_F_INGRESS);
>>
>> I'd prefer if skb->tc_at_ingress is set directly to 0/1 in
>> sch_handle_ingress()
>> and __dev_queue_xmit() as we do right now, this would avoid above tests in
>> fast
>> path and it would also avoid to set the same thing in tc_classify() multiple
>> times f.e. on egress path walking through multiple qdiscs. I don't see
>> anything
>> in layers above tc that would read it and expect an AT_STACK-like
>> equivalent.
>> skb_reset_tc() could thus still remain as you have above in fast-path like
>> __netif_receive_skb_core().
>
> I had been thinking about that. After submitting this I noticed that Florian's
> patchset had an elegant solution to avoid the branch: set tc_at_ingress in
> handle_ing before tc_classify and clear it on the return path.
>
> Then we only set + clear it once on ingress regardless of the depth
> of classifiers and do not touch it at all in other code.
>
> https://patchwork.ozlabs.org/patch/472698/
>
> What do you think of that approach?

I think this approach might not work, it would certainly change semantics
since right now *before* going into tc_classify() we always update skb->tc_verd's
"at" location. After the patch we'd set TC_AT_INGRESS in ingress and could
redirect within tc_classify() [and we'd skip that skb->tc_verd = 0 we have in
__netif_receive_skb_core() for these] to xmit from there where next call into
classifier from __dev_queue_xmit() call-site misses that we're not at ingress
anymore but already at egress, so it would do wrong pull/push of headers in
some cls, for example. I mentioned above that I think your skb_reset_tc() for
the __netif_receive_skb_core() fast-path could stay as you have it in that patch
as afaik there's no user that reads out this value in above layers, so if we
keep the "at" info always correct before going into tc_classify(), we should
be good.

Thanks,
Daniel
