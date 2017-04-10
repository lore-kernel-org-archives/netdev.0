From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH v2 net-next RFC] Generic XDP
Date: Mon, 10 Apr 2017 12:57:23 -0400
Message-ID: <CAF=yD-LvwW4MLA8NeYzkfSu4ZXaZja7FH8EPm5KtrreOhNBCrw@mail.gmail.com>
References: <20170409.133528.660876505013192371.davem@davemloft.net> <20170410021807.GA17150@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        Network Development <netdev@vger.kernel.org>,
        xdp-newbies@vger.kernel.org
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f176.google.com ([209.85.220.176]:35355 "EHLO
        mail-qk0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932167AbdDJQ6E (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Apr 2017 12:58:04 -0400
In-Reply-To: <20170410021807.GA17150@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>  static int netif_receive_skb_internal(struct sk_buff *skb)
>>  {
>>       int ret;
>> @@ -4258,6 +4336,21 @@ static int netif_receive_skb_internal(struct sk_buff *skb)
>>
>>       rcu_read_lock();
>>
>> +     if (static_key_false(&generic_xdp_needed)) {
>> +             struct bpf_prog *xdp_prog = rcu_dereference(skb->dev->xdp_prog);
>> +
>> +             if (xdp_prog) {
>> +                     u32 act = netif_receive_generic_xdp(skb, xdp_prog);
>
> That's indeed the best attachment point in the stack.
> I was trying to see whether it can be lowered into something like
> dev_gro_receive(), but not everyone calls it.

It would be a helpful (follow-on) optimization for packets that do
pass through it. It allows skb recycling with napi_reuse_skb and can
be used to protect if a vulnerability in the gro stack pops up.

> Another option to put it into eth_type_trans() itself, then
> there are no problems with gro, l2 headers, and adjust_head,
> but changing all drivers is too much.
>
>> +
>> +                     if (act != XDP_PASS) {
>> +                             rcu_read_unlock();
>> +                             if (act == XDP_TX)
>> +                                     dev_queue_xmit(skb);
>
> It should be fine. For cls_bpf we do recursion check __bpf_tx_skb()
> but I forgot specific details. May be here it's fine as-is.
> Daniel, do we need recursion check here?

That limiter is for egress redirecting to egress, I believe. This
ingress to egress will go through netif_rx and a softirq if looping.

Another point on redirect is clearing skb state. queue_mapping and
sender_cpu will be dirty, but should be able to handle it. It seems
possible to attach to a virtual device, such as a tunnel. In that case
the packet may have gone through a complex receive path before
reaching the tunnel, including tc ingress, so even more skb fields may
be set (e.g., priority). The same holds for act_mirred or
__bpf_redirect, so I assume that this is safe.
