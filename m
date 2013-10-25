From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: vxlan gso is broken by stackable gso_segment()
Date: Fri, 25 Oct 2013 15:41:47 -0700
Message-ID: <CAMEtUuxwi05oX0TqNdMbjy04MT=ZLemLXJQTTcAMrnWuhXLKdQ@mail.gmail.com>
References: <CAMEtUuzswOVA6UkPRjS-O=gOe9BLLJ5qaAG_eAd_fTqDJo8ofA@mail.gmail.com>
	<1382674000.7572.75.camel@edumazet-glaptop.roam.corp.google.com>
	<1382692140.7572.79.camel@edumazet-glaptop.roam.corp.google.com>
	<20131025.181809.348808013109842304.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: eric.dumazet@gmail.com, Eric Dumazet <edumazet@google.com>,
	stephen@networkplumber.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f50.google.com ([74.125.82.50]:54091 "EHLO
	mail-wg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753169Ab3JYWls (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Oct 2013 18:41:48 -0400
Received: by mail-wg0-f50.google.com with SMTP id n12so4477124wgh.29
        for <netdev@vger.kernel.org>; Fri, 25 Oct 2013 15:41:47 -0700 (PDT)
In-Reply-To: <20131025.181809.348808013109842304.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 25, 2013 at 3:18 PM, David Miller <davem@davemloft.net> wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Fri, 25 Oct 2013 02:09:00 -0700
>
>> @@ -1252,6 +1252,7 @@ static struct sk_buff *inet_gso_segment(struct sk_buff *skb,
>>       const struct net_offload *ops;
>>       unsigned int offset = 0;
>>       struct iphdr *iph;
>> +     bool udpfrag;
>>       bool tunnel;
>>       int proto;
>>       int nhoff;
>> @@ -1306,10 +1307,11 @@ static struct sk_buff *inet_gso_segment(struct sk_buff *skb,
>>       if (IS_ERR_OR_NULL(segs))
>>               goto out;
>>
>> +     udpfrag = !!skb->encapsulation && proto == IPPROTO_UDP;
>>       skb = segs;
>>       do {
>>               iph = (struct iphdr *)(skb_mac_header(skb) + nhoff);
>> -             if (!tunnel && proto == IPPROTO_UDP) {
>> +             if (udpfrag) {
>>                       iph->id = htons(id);
>>                       iph->frag_off = htons(offset >> 3);
>>                       if (skb->next != NULL)
>>
>
> The "tunnel" variable becomes unused once you do this, please remove it.

'bool tunnel' actually still used to indicate encap_level > 0

Eric's fix brings back performance for vxlan and gre keeps working. Thx!

net/core/skbuff.c:3474 skb_try_coalesce() warning, I mentioned before,
is unrelated.
I still see it with this patch. Running either gre or vxlan tunnels.
