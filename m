From: Jerry Chu <hkchu@google.com>
Subject: Re: [PATCH v2 net-next] net-gro: Prepare GRO stack for the upcoming
 tunneling support
Date: Thu, 12 Dec 2013 11:45:29 +0800
Message-ID: <CAPshTCjrruFcoA3-0E4qjnaHYo6E42-Afh4irmzLQeu-AArMFg@mail.gmail.com>
References: <1386788641-16200-1-git-send-email-hkchu@google.com>
	<1386790638.30495.379.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Eric Dumazet <edumazet@google.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f180.google.com ([209.85.216.180]:63889 "EHLO
	mail-qc0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751857Ab3LLDpc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Dec 2013 22:45:32 -0500
Received: by mail-qc0-f180.google.com with SMTP id w7so5822410qcr.25
        for <netdev@vger.kernel.org>; Wed, 11 Dec 2013 19:45:30 -0800 (PST)
In-Reply-To: <1386790638.30495.379.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 12, 2013 at 3:37 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Wed, 2013-12-11 at 11:04 -0800, H.K. Jerry Chu wrote:
>
>> -int tcp_gro_complete(struct sk_buff *skb)
>> +int __tcp_gro_complete(struct sk_buff *skb, struct tcphdr *th)
>>  {
>> -     struct tcphdr *th = tcp_hdr(skb);
>> -
>> -     skb->csum_start = skb_transport_header(skb) - skb->head;
>> +     skb->csum_start = (unsigned char *)th - skb->head;
>>       skb->csum_offset = offsetof(struct tcphdr, check);
>>       skb->ip_summed = CHECKSUM_PARTIAL;
>>
>> @@ -251,6 +250,12 @@ int tcp_gro_complete(struct sk_buff *skb)
>>
>>       return 0;
>>  }
>> +EXPORT_SYMBOL(__tcp_gro_complete);
>> +
>> +int tcp_gro_complete(struct sk_buff *skb)
>> +{
>> +     return __tcp_gro_complete(skb,  tcp_hdr(skb));
>> +}
>
>
> I have no idea why you kept this change.
>
> As we said, the transport offset is set, so it looks like a lot of your
> changes can be removed to ease the review

Yes I know but you were the one who suggested not setting the
transport header a while back, and seemed to prefer avoiding the use
of saved headers in skb.

Then you discovered the transport header must be set by the GRO
stack. That leaves the question should I still try to avoid using headers
saved in skb in case you may attempt to get rid of all the header setting
in GRO completely in the future. I decided last night to use the new
way (nhoff). But obviously the other way (to simply use
skb_transport_header to the extent possible) can be easily done and
will avoid much of the code change too. I'll send out v3 soon.

>
> tcp_gro_receive() sets the transport header, so the xxx_complete()
> handlers can rely on it.
>
> The only part that you could keep is the following optim :
>
> - skb->csum_start = skb_transport_header(skb) - skb->head;
> + skb->csum_start = (unsigned char *)th - skb->head;
>
>
>
