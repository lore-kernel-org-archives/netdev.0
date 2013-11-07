From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next] inet: restore gso for vxlan
Date: Thu, 7 Nov 2013 15:27:10 -0800
Message-ID: <CAMEtUuwqmUhTgeKyodGKmOxhxe23=umnfc7nouhdVrqVNnk6zQ@mail.gmail.com>
References: <CAMEtUuzswOVA6UkPRjS-O=gOe9BLLJ5qaAG_eAd_fTqDJo8ofA@mail.gmail.com>
	<1382674000.7572.75.camel@edumazet-glaptop.roam.corp.google.com>
	<1382692140.7572.79.camel@edumazet-glaptop.roam.corp.google.com>
	<20131025.181809.348808013109842304.davem@davemloft.net>
	<CAMEtUuxwi05oX0TqNdMbjy04MT=ZLemLXJQTTcAMrnWuhXLKdQ@mail.gmail.com>
	<1382923096.13037.10.camel@edumazet-glaptop.roam.corp.google.com>
	<1383863586.9412.101.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f173.google.com ([74.125.82.173]:60729 "EHLO
	mail-we0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753085Ab3KGX1M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Nov 2013 18:27:12 -0500
Received: by mail-we0-f173.google.com with SMTP id u57so1226038wes.18
        for <netdev@vger.kernel.org>; Thu, 07 Nov 2013 15:27:10 -0800 (PST)
In-Reply-To: <1383863586.9412.101.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 7, 2013 at 2:33 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Sun, 2013-10-27 at 18:18 -0700, Eric Dumazet wrote:
>> From: Eric Dumazet <edumazet@google.com>
>>
>> Alexei reported a performance regression on vxlan, caused
>> by commit 3347c9602955 "ipv4: gso: make inet_gso_segment() stackable"
>>
>> GSO vxlan packets were not properly segmented, adding IP fragments
>> while they were not expected.
>>
>> Rename 'bool tunnel' to 'bool encap', and add a new boolean
>> to express the fact that UDP should be fragmented.
>> This fragmentation is triggered by skb->encapsulation being set.
>>
>> Remove a "skb->encapsulation = 1" added in above commit,
>> as its not needed, as frags inherit skb->frag from original
>> GSO skb.
>>
>> Reported-by: Alexei Starovoitov <ast@plumgrid.com>
>> Signed-off-by: Eric Dumazet <edumazet@google.com>
>> Tested-by: Alexei Starovoitov <ast@plumgrid.com>
>> ---
>>  net/ipv4/af_inet.c |   15 +++++++--------
>>  1 file changed, 7 insertions(+), 8 deletions(-)
>>
>> diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
>> index f4a159e705c0..09d78d4a3cff 100644
>> --- a/net/ipv4/af_inet.c
>> +++ b/net/ipv4/af_inet.c
>> @@ -1251,8 +1251,8 @@ static struct sk_buff *inet_gso_segment(struct sk_buff *skb,
>>       struct sk_buff *segs = ERR_PTR(-EINVAL);
>>       const struct net_offload *ops;
>>       unsigned int offset = 0;
>> +     bool udpfrag, encap;
>>       struct iphdr *iph;
>> -     bool tunnel;
>>       int proto;
>>       int nhoff;
>>       int ihl;
>> @@ -1290,8 +1290,8 @@ static struct sk_buff *inet_gso_segment(struct sk_buff *skb,
>>               goto out;
>>       __skb_pull(skb, ihl);
>>
>> -     tunnel = SKB_GSO_CB(skb)->encap_level > 0;
>> -     if (tunnel)
>> +     encap = SKB_GSO_CB(skb)->encap_level > 0;
>> +     if (encap)
>>               features = skb->dev->hw_enc_features & netif_skb_features(skb);
>>       SKB_GSO_CB(skb)->encap_level += ihl;
>>
>> @@ -1306,24 +1306,23 @@ static struct sk_buff *inet_gso_segment(struct sk_buff *skb,
>>       if (IS_ERR_OR_NULL(segs))
>>               goto out;
>>
>> +     udpfrag = !!skb->encapsulation && proto == IPPROTO_UDP;
>
> It seems I did an error here, shouldn't it be
>
>      udpfrag = !skb->encapsulation && proto == IPPROTO_UDP;
>
> instead ?

oops. yes.
the segs coming out of udp4_ufo_fragment() in case of udp_tunnel should not
be marked as ip frags.
ip frags are only for UFO.

Thank you for spotting it!

Alexei
