From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH v2 net-next RFC] Generic XDP
Date: Mon, 10 Apr 2017 21:50:51 +0200
Message-ID: <58EBE21B.5000602@iogearbox.net>
References: <20170409.133528.660876505013192371.davem@davemloft.net> <20170410021807.GA17150@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xdp-newbies@vger.kernel.org
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:52184 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752155AbdDJTvA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Apr 2017 15:51:00 -0400
In-Reply-To: <20170410021807.GA17150@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/10/2017 04:18 AM, Alexei Starovoitov wrote:
[...]
>> +	xdp.data_end = xdp.data + hlen;
>> +	xdp.data_hard_start = xdp.data - skb_headroom(skb);
>> +	orig_data = xdp.data;
>> +	act = bpf_prog_run_xdp(xdp_prog, &xdp);
>> +
>> +	off = xdp.data - orig_data;
>> +	if (off)
>> +		__skb_push(skb, off);
>
> and restore l2 back somehow and get new skb->protocol ?
> if we simply do __skb_pull(skb, skb->mac_len); like
> we do with cls_bpf, it will not work correctly,
> since if the program did ip->ipip encap (like our balancer
> does and the test tools/testing/selftests/bpf/test_xdp.c)
> the skb metadata fields will be wrong.
> So we need to repeat eth_type_trans() here if (xdp.data != orig_data)

Yeah, agree. Also, when we have gso skb and rewrite/resize parts
of the packet, we would need to update gso related shinfo meta
data accordingly (f.e. a rewrite from v4/v6, rewrite of whole pkt
as icmp reply, etc)?

Also, what about encap/decap, should inner skb headers get
updated as well along with skb->encapsulation, etc? How do we
handle checksumming on this layer?

> In case of cls_bpf when we mess with skb sizes we always
> adjust skb metafields in helpers, so there it's fine
> and __skb_pull(skb, skb->mac_len); is enough.
> Here we need to be a bit more careful.

In cls_bpf I was looking into something generic and fast for
encap/decap like bpf_xdp_adjust_head() but for skbs. Problem is
that they can be received from ingress/egress and transmitted
further from cls_bpf to ingress/egress, so keeping skb meta data
correct and up to date without exposing skb (implementation)
details like header pointers to users is crucial, as otherwise
these can get messed up potentially affecting the rest of the
system. We restricted helpers in cls_bpf to avoid that. Perhaps
we could make easier assumptions when this generic callback is
known to be called out of a physical driver's rx path, but when
being skb already (as mentioned below by Alexei's thoughts) ...

>>   static int netif_receive_skb_internal(struct sk_buff *skb)
>>   {
>>   	int ret;
>> @@ -4258,6 +4336,21 @@ static int netif_receive_skb_internal(struct sk_buff *skb)
>>
>>   	rcu_read_lock();
>>
>> +	if (static_key_false(&generic_xdp_needed)) {
>> +		struct bpf_prog *xdp_prog = rcu_dereference(skb->dev->xdp_prog);
>> +
>> +		if (xdp_prog) {
>> +			u32 act = netif_receive_generic_xdp(skb, xdp_prog);
>
> That's indeed the best attachment point in the stack.
> I was trying to see whether it can be lowered into something like
> dev_gro_receive(), but not everyone calls it.
> Another option to put it into eth_type_trans() itself, then
> there are no problems with gro, l2 headers, and adjust_head,
> but changing all drivers is too much.
>
>> +
>> +			if (act != XDP_PASS) {
>> +				rcu_read_unlock();
>> +				if (act == XDP_TX)
>> +					dev_queue_xmit(skb);
>
> It should be fine. For cls_bpf we do recursion check __bpf_tx_skb()
> but I forgot specific details. May be here it's fine as-is.
> Daniel, do we need recursion check here?

Yeah, Willem is correct. That was for sch_handle_egress() to
sch_handle_egress() as that is otherwise not accounted by the
main xmit_recursion check we have in __dev_queue_xmit().

Thanks,
Daniel
