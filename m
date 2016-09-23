From: Eric Nelson <eric@nelint.com>
Subject: Re: Alignment issues with freescale FEC driver
Date: Fri, 23 Sep 2016 10:33:29 -0700
Message-ID: <0fe7a310-2d2f-4fca-d698-85d66122d91c@nelint.com>
References: <troy.kisky@boundarydevices.com>
 <02afb707-65de-5101-a79b-355929c4e00b@nelint.com>
 <CANn89iLb+QJu+MYh859oAAjcLCsKRpBbzVf43yOdq+HJVtZDpQ@mail.gmail.com>
 <5ee28ee0-cf0c-bdab-1271-f17755365c13@nelint.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: "linux-arm-kernel@lists.infradead.org"
        <linux-arm-kernel@lists.infradead.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        rmk+kernel@arm.linux.org.uk, Fugang Duan <fugang.duan@nxp.com>,
        Troy Kisky <troy.kisky@boundarydevices.com>,
        Otavio Salvador <otavio@ossystems.com.br>,
        Simone <cjb.sw.nospam@gmail.com>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:33654 "EHLO
        mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758025AbcIWRdc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Sep 2016 13:33:32 -0400
Received: by mail-pa0-f43.google.com with SMTP id hm5so42194084pac.0
        for <netdev@vger.kernel.org>; Fri, 23 Sep 2016 10:33:31 -0700 (PDT)
In-Reply-To: <5ee28ee0-cf0c-bdab-1271-f17755365c13@nelint.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

On 09/23/2016 10:19 AM, Eric Nelson wrote:
> Thanks Eric,
> 
> On 09/23/2016 09:54 AM, Eric Dumazet wrote:
>> On Fri, Sep 23, 2016 at 9:43 AM, Eric Nelson <eric@nelint.com> wrote:
>>>
>>> Hello all,
>>>
>>> We're seeing alignment issues from the ethernet stack on an i.MX6UL board:
>>>
>>>
> 
> <snip>
> 
>>>
>>> - id = ntohl(*(__be32 *)&iph->id);
>>> - flush = (u16)((ntohl(*(__be32 *)iph) ^ skb_gro_len(skb)) | (id & ~IP_DF));
>>> - id >>= 16;
>>> + id = ntohs(*(__be16 *)&iph->id);
>>> + frag = ntohs(*(__be16 *)&iph->frag_off);
>>> + flush = (u16)((ntohl(*(__be32 *)iph) ^ skb_gro_len(skb)) | (frag &
>>> ~IP_DF));
>>>
>>> for (p = *head; p; p = p->next) {
>>> struct iphdr *iph2;
>>>
>>
>> This solves nothing, because a few lines after you'll have yet another
>> unaligned access :
>>
> 
> Oddly, it does prevent the vast majority (90%+) of the alignment errors.
> 
> I believe this is because the compiler is generating an ldm instruction
> when the ntohl() call is used, but I'm stumped about why these aren't
> generating faults:
> 
>> ((__force u32)iph->saddr ^ (__force u32)iph2->saddr) |
>> ((__force u32)iph->daddr ^ (__force u32)iph2->daddr)) {
>>
>> So you might have one less problematic access, out of hundreds of them
>> all over the places.
>>
>> Really the problem is that whole stack depends on the assumption that
>> IP headers are aligned on arches that care
>> (ie where NET_IP_ALIGN == 2)
>>
>> If your build does have NET_IP_ALIGN = 2 and you get a fault here, it
>> might be because of a buggy driver.
>>
> 
> NET_IP_ALIGN is set to 2.
> 
>> The other known case is some GRE encapsulations that break the
>> assumption, and this is discussed somewhere else.
>>
> I don't think that's the case.
> 
> # CONFIG_IPV6_GRE is not set
> 
> Hmm... Instrumenting the kernel, it seems that iphdr **is** aligned on
> a 4-byte boundary.
> 

No. That was wrong.

The iphdr is aligned at offsets of 14 from the ethernet frame, which itself
is longword aligned.

I mistakenly tested before the call to skb_gro_header_slow(), when
iph was NULL.

After putting a test in the right place, I'm seeing an address of
888a364e for the first un-aligned packet.

Since the hardware requires longword alignment for its' DMA transfers,
aligning the IP header will require a memcpy, right?

You hinted at a solution in this post:

http://www.spinics.net/lists/netdev/msg213166.html

Are you aware of another driver doing this that could be used as
a reference?

Please advise,


Eric
