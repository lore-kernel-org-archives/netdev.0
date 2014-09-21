From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH net-next 2/3] udp: move logic out of udp[46]_ufo_send_check
Date: Sat, 20 Sep 2014 18:29:11 -0700
Message-ID: <CA+mtBx_f0yfOxDq_L96_bESGU2nG3PJSFwDEFDW7Ynt=6b+0Zw@mail.gmail.com>
References: <1411249950-6795-1-git-send-email-therbert@google.com>
	<1411249950-6795-3-git-send-email-therbert@google.com>
	<1411261954.26859.108.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f172.google.com ([209.85.223.172]:44767 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751307AbaIUB3M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Sep 2014 21:29:12 -0400
Received: by mail-ie0-f172.google.com with SMTP id rp18so3646095iec.17
        for <netdev@vger.kernel.org>; Sat, 20 Sep 2014 18:29:11 -0700 (PDT)
In-Reply-To: <1411261954.26859.108.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Sep 20, 2014 at 6:12 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Sat, 2014-09-20 at 14:52 -0700, Tom Herbert wrote:
>> In udp[46]_ufo_send_check the UDP checksum initialized to the pseudo
>> header checksum. We can move this logic into udp[46]_ufo_fragment.
>> After this change udp[64]_ufo_send_check is a no-op.
>>
>> Signed-off-by: Tom Herbert <therbert@google.com>
>> ---
>>  net/ipv4/udp_offload.c | 37 +++++++++++++++----------------------
>>  net/ipv6/udp_offload.c | 40 ++++++++++++++++++----------------------
>>  2 files changed, 33 insertions(+), 44 deletions(-)
>>
>> diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
>> index d7c43f7..2918cc9 100644
>> --- a/net/ipv4/udp_offload.c
>> +++ b/net/ipv4/udp_offload.c
>> @@ -27,23 +27,6 @@ struct udp_offload_priv {
>>
>>  static int udp4_ufo_send_check(struct sk_buff *skb)
>>  {
>> -     if (!pskb_may_pull(skb, sizeof(struct udphdr)))
>> -             return -EINVAL;
>> -
>> -     if (likely(!skb->encapsulation)) {
>> -             const struct iphdr *iph;
>> -             struct udphdr *uh;
>> -
>> -             iph = ip_hdr(skb);
>> -             uh = udp_hdr(skb);
>> -
>> -             uh->check = ~csum_tcpudp_magic(iph->saddr, iph->daddr, skb->len,
>> -                             IPPROTO_UDP, 0);
>> -             skb->csum_start = skb_transport_header(skb) - skb->head;
>> -             skb->csum_offset = offsetof(struct udphdr, check);
>> -             skb->ip_summed = CHECKSUM_PARTIAL;
>> -     }
>> -
>>       return 0;
>>  }
>>
>> @@ -128,8 +111,9 @@ static struct sk_buff *udp4_ufo_fragment(struct sk_buff *skb,
>>  {
>>       struct sk_buff *segs = ERR_PTR(-EINVAL);
>>       unsigned int mss;
>> -     int offset;
>>       __wsum csum;
>> +     struct udphdr *uh;
>> +     struct iphdr *iph;
>>
>>       if (skb->encapsulation &&
>>           (skb_shinfo(skb)->gso_type &
>> @@ -138,6 +122,9 @@ static struct sk_buff *udp4_ufo_fragment(struct sk_buff *skb,
>>               goto out;
>>       }
>>
>> +     if (!pskb_may_pull(skb, sizeof(struct udphdr)))
>> +             goto out;
>> +
>>       mss = skb_shinfo(skb)->gso_size;
>>       if (unlikely(skb->len <= mss))
>>               goto out;
>> @@ -165,10 +152,16 @@ static struct sk_buff *udp4_ufo_fragment(struct sk_buff *skb,
>>        * HW cannot do checksum of UDP packets sent as multiple
>>        * IP fragments.
>>        */
>> -     offset = skb_checksum_start_offset(skb);
>> -     csum = skb_checksum(skb, offset, skb->len - offset, 0);
>> -     offset += skb->csum_offset;
>> -     *(__sum16 *)(skb->data + offset) = csum_fold(csum);
>> +
>> +     uh = udp_hdr(skb);
>> +     iph = ip_hdr(skb);
>> +
>> +     uh->check = 0;
>> +     csum = skb_checksum(skb, 0, skb->len, 0);
>> +     uh->check = udp_v4_check(skb->len, iph->saddr, iph->daddr, csum);
>> +     if (uh->check == 0)
>> +             uh->check = CSUM_MANGLED_0;
>> +
>>       skb->ip_summed = CHECKSUM_NONE;
>
>
> Shouldn't it be changed to CHECKSUM_PARTIAL or something ?
>
> udp4_ufo_send_check() was able to fill CHECKSUM_PARTIAL,
> I fear I do not understand enough this part.

Right, I had tried that also. Didn't work, IIRC there was a crash
later on because csum_start wasn't initialized.


>
>
>
>
>
