From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH net] net: orphan frags on stand-alone ptype in dev_queue_xmit_nit
Date: Fri, 22 Sep 2017 19:15:24 -0400
Message-ID: <CAF=yD-KY=ymLh2P7RMb36yKqfnnhHZRMcV_PwAT7Tc9vKp1Gyg@mail.gmail.com>
References: <20170922225141.126435-1-willemb@google.com> <1506121446.29839.177.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Willem de Bruijn <willemb@google.com>,
        Network Development <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f65.google.com ([209.85.218.65]:38599 "EHLO
        mail-oi0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752015AbdIVXQF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 22 Sep 2017 19:16:05 -0400
Received: by mail-oi0-f65.google.com with SMTP id s145so273536oie.5
        for <netdev@vger.kernel.org>; Fri, 22 Sep 2017 16:16:05 -0700 (PDT)
In-Reply-To: <1506121446.29839.177.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 22, 2017 at 7:04 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Fri, 2017-09-22 at 18:51 -0400, Willem de Bruijn wrote:
>> Zerocopy skbs frags are copied when the skb is looped to a local sock.
>> Commit 1080e512d44d ("net: orphan frags on receive") introduced calls
>> to skb_orphan_frags to deliver_skb and __netif_receive_skb.
>>
>> With msg_zerocopy, these skbs can also exist in the tx path and thus
>> loop from dev_queue_xmit_nit. This already calls deliver_skb in its
>> loop. But it does not orphan before a separate pt_prev->func().
>>
>> Add the missing skb_orphan_frags_rx.
>>
>> Fixes: 1f8b977ab32d ("sock: enable MSG_ZEROCOPY")
>> Signed-off-by: Willem de Bruijn <willemb@google.com>
>> ---
>>  net/core/dev.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/net/core/dev.c b/net/core/dev.c
>> index 9a2254f9802f..3f5b26ff4f74 100644
>> --- a/net/core/dev.c
>> +++ b/net/core/dev.c
>> @@ -1948,7 +1948,7 @@ void dev_queue_xmit_nit(struct sk_buff *skb, struct net_device *dev)
>>               goto again;
>>       }
>>  out_unlock:
>> -     if (pt_prev)
>> +     if (pt_prev && !skb_orphan_frags_rx(skb2, GFP_ATOMIC))
>>               pt_prev->func(skb2, skb->dev, pt_prev, skb->dev);
>
> Don't you need to kfree_skb(skb2) in case of failure ?

Oh, yes, of course! :/ Will fix right away.
