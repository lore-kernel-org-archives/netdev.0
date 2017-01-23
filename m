From: Xiangning Yu <yuxiangning@gmail.com>
Subject: Re: Question about veth_xmit()
Date: Mon, 23 Jan 2017 11:29:07 -0800
Message-ID: <CAOwmpL3jqQRANpKLSEOsZ8MpNoPC8SAR=fUVTPwOuE2FRxop5A@mail.gmail.com>
References: <CAOwmpL3vg56ZqHaYVBy+9dJJ1=GCbgy-m8NY0JrNCV-Z42R_eg@mail.gmail.com>
 <1485198462.16328.208.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f176.google.com ([209.85.223.176]:36255 "EHLO
        mail-io0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750714AbdAWT3I (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2017 14:29:08 -0500
Received: by mail-io0-f176.google.com with SMTP id j13so117943957iod.3
        for <netdev@vger.kernel.org>; Mon, 23 Jan 2017 11:29:08 -0800 (PST)
In-Reply-To: <1485198462.16328.208.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 23, 2017 at 11:07 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Mon, 2017-01-23 at 10:46 -0800, Xiangning Yu wrote:
>> Hi netdev folks,
>>
>> It looks like we call dev_forward_skb() in veth_xmit(), which calls
>> netif_rx() eventually.
>>
>> While netif_rx() will enqueue the skb to the CPU RX backlog before the
>> actual processing takes place. So, this actually means a TX skb has to
>> wait some un-related RX skbs to finish. And this will happen twice for
>> a single ping, because the veth device always works as a pair?
>>
>> IMHO this might lead to some latency issue under certain workload,
>> can we change the call to dev_forward_skb() to something like this?
>>
>>         if (likely(__dev_forward_skb(rcv, skb) == NET_RX_SUCCESS)) {
>>                 local_bh_disable();
>>                 netif_receive_skb(skb);
>>                 local_bh_enable();
>>
>> Could you please shed some light on this change? And please feel free
>> to correct my if my understanding is wrong.
>
> How veth would have different latency requirement than loopback device ?
>

The traffic from those veth device will reach external network, and
normally those are RPC type traffic.

> Calling netif_receive_skb() is considered too dangerous here (or from
> any ndo_start_xmit()) because of possible kernel stack exhaustion.
>

I agree, stack space is a concern, especially if the traffic is
loopback-ed to another namespace.

Thanks,

- Xiangning

>
>
