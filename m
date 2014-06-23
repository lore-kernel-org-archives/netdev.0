From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH 5/5] udp: additional GRO support
Date: Mon, 23 Jun 2014 09:37:29 -0700
Message-ID: <CA+mtBx8b+Y3gZa0Z_9LONwAXFhCfXY1STj+kc_TtveCbAQAs2g@mail.gmail.com>
References: <alpine.DEB.2.02.1406201631360.11831@tomh.mtv.corp.google.com>
	<CAJZOPZKQNK6uMB_ObYeBkJ1h3ybOpPmsurKCEHCForTR3Sv6kg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f171.google.com ([209.85.223.171]:36795 "EHLO
	mail-ie0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754582AbaFWQha (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jun 2014 12:37:30 -0400
Received: by mail-ie0-f171.google.com with SMTP id x19so5974946ier.16
        for <netdev@vger.kernel.org>; Mon, 23 Jun 2014 09:37:29 -0700 (PDT)
In-Reply-To: <CAJZOPZKQNK6uMB_ObYeBkJ1h3ybOpPmsurKCEHCForTR3Sv6kg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jun 22, 2014 at 4:40 AM, Or Gerlitz <or.gerlitz@gmail.com> wrote:
> On Sat, Jun 21, 2014 at 2:38 AM, Tom Herbert <therbert@google.com> wrote:
>> Implement GRO for UDPv6. Add UDP checksum verification in gro_receive
>> for both UDP4 and UDP6 calling skb_gro_checksum_validate_zero_check.
>> Also, remove check for CHECKSUM_COMPLETE in udp_gro_receive, any
>> checksum type should be handled now.
>
>
> [...]
>
>> diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
>> index fb8e6ba..2ab9051 100644
>> --- a/net/ipv4/udp_offload.c
>> +++ b/net/ipv4/udp_offload.c
>
>> -static struct sk_buff **udp_gro_receive(struct sk_buff **head, struct sk_buff *skb)
>> +struct sk_buff **udp_gro_receive(struct sk_buff **head, struct sk_buff *skb,
>> +                                struct udphdr *uh)
>>  {
>>         struct udp_offload_priv *uo_priv;
>>         struct sk_buff *p, **pp = NULL;
>> -       struct udphdr *uh, *uh2;
>> -       unsigned int hlen, off;
>> +       struct udphdr *uh2;
>> +       unsigned int off = skb_gro_offset(skb);
>>         int flush = 1;
>>
>> -       if (NAPI_GRO_CB(skb)->udp_mark ||
>> -           (!skb->encapsulation && skb->ip_summed != CHECKSUM_COMPLETE))
>> +       if (NAPI_GRO_CB(skb)->udp_mark)
>>                 goto out;
>
> Before this change we were practically requiring SKBs to carry their
> ->encapsulation mark set but not any more.

This allows computing checksum in GRO. This uses the same technique
that GRE does with a checksum.

btw, udp_mark's effect is to disallow multiple levels of encap which
is orthogonal from csum handling. It looks like the only protocol
encapsulation where we disallow nested encap. I think we can either
remove this or maybe generalize it to limit number of protocol layers
we are willing to parse in GRO path.
