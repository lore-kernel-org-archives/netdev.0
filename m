From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH 3/3] net: GSO encapsulation for IP packets
Date: Tue, 11 Feb 2014 12:45:06 -0800
Message-ID: <CA+mtBx_TEz8xo4wOZVLeVAJj6bjbWCr1dyx-f_Z7B9kCCxD7tw@mail.gmail.com>
References: <alpine.DEB.2.02.1402110928030.7010@tomh.mtv.corp.google.com>
	<CAADnVQ+PcO9-BGVE+ExFZt_sxhN1gDtiXtxMHPfHEX7wB3cWWg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f50.google.com ([209.85.212.50]:56011 "EHLO
	mail-vb0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754978AbaBKUpH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Feb 2014 15:45:07 -0500
Received: by mail-vb0-f50.google.com with SMTP id w8so6216359vbj.23
        for <netdev@vger.kernel.org>; Tue, 11 Feb 2014 12:45:06 -0800 (PST)
In-Reply-To: <CAADnVQ+PcO9-BGVE+ExFZt_sxhN1gDtiXtxMHPfHEX7wB3cWWg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 11, 2014 at 11:12 AM, Alexei Starovoitov
<alexei.starovoitov@gmail.com> wrote:
> On Tue, Feb 11, 2014 at 9:43 AM, Tom Herbert <therbert@google.com> wrote:
>> The UDP GSO code assume that only encapsulated packets are Ethernet
>> frames. This patch fixes that so that we can support IP protocol
>> encpasulation (GUE, GRE/UDP, etc.)
>>
>> We overload the inner_protocol field in the skb to store either the
>> Ethertype or the IP protocol (latter is indicated by ip_encapsulation
>> bit). As far as I can tell this should not adversely affect preexiting
>> uses for inner_protocol.
>>
>> Signed-off-by
>> +++ b/net/ipv4/udp.c
>> @@ -2497,7 +2497,17 @@ struct sk_buff *skb_udp_tunnel_segment(struct sk_buff *skb,
>>
>>         /* segment inner packet. */
>>         enc_features = skb->dev->hw_enc_features & netif_skb_features(skb);
>> -       segs = skb_mac_gso_segment(skb, enc_features);
>> +
>> +       if (skb->ip_encapsulation) {
>> +               const struct net_offload *ops;
>> +               ops = rcu_dereference(inet_offloads[skb->inner_protocol]);
>> +               if (likely(ops && ops->callbacks.gso_segment))
>> +                       segs = ops->callbacks.gso_segment(skb, enc_features);
>> +       } else {
>> +               skb->protocol = htons(ETH_P_TEB);
>
> duplicate assignment ? Do you want to remove line 2496 which did the same
> or proto=teb applies to ip_encap case as well?
>

Thanks for catching that!  I think the assignment at 2496 should be removed.

>> +               segs = skb_mac_gso_segment(skb, enc_features);
>> +       }
>> +
>>         if (!segs || IS_ERR(segs)) {
>>                 skb_gso_error_unwind(skb, protocol, tnl_hlen, mac_offset,
>>                                      mac_len);
>> --
>> 1.9.0.rc1.175.g0b1dcb5
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
