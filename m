From: James Hughes <james.hughes@raspberrypi.org>
Subject: Re: [PATCH] smsc95xx: Use skb_cow to deal with cloned skbs
Date: Tue, 18 Apr 2017 17:16:49 +0100
Message-ID: <CAE_XsMJZGPvENhCgyvuz48PyLk=T7L-tGoktzVBLPPYDP7oR8A@mail.gmail.com>
References: <20170418144857.7810-1-james.hughes@raspberrypi.org>
 <1492530711.10587.125.camel@edumazet-glaptop3.roam.corp.google.com> <20170418.115546.921863837348166438.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
        Steve Glendinning <steve.glendinning@shawell.net>,
        Microchip Linux Driver Support <UNGLinuxDriver@microchip.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx08-00252a01.pphosted.com ([91.207.212.211]:33869 "EHLO
        mx08-00252a01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751783AbdDRQQw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Apr 2017 12:16:52 -0400
Received: from pps.filterd (m0102629.ppops.net [127.0.0.1])
        by mx08-00252a01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3IGFvV4019654
        for <netdev@vger.kernel.org>; Tue, 18 Apr 2017 17:16:51 +0100
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
        by mx08-00252a01.pphosted.com with ESMTP id 29u80f9kma-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=OK)
        for <netdev@vger.kernel.org>; Tue, 18 Apr 2017 17:16:51 +0100
Received: by mail-wr0-f198.google.com with SMTP id n5so19349009wrb.7
        for <netdev@vger.kernel.org>; Tue, 18 Apr 2017 09:16:51 -0700 (PDT)
In-Reply-To: <20170418.115546.921863837348166438.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 18 April 2017 at 16:55, David Miller <davem@davemloft.net> wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Tue, 18 Apr 2017 08:51:51 -0700
>
>> On Tue, 2017-04-18 at 15:48 +0100, James Hughes wrote:
>>> The driver was failing to check that the SKB wasn't cloned
>>> before adding checksum data or adding header data.
>>> Replace existing handling to extend the buffer with
>>> skb_cow. Don't use skb_cow_head as the sw checksum
>>> code modifies the data portion.
>>>
>>> Signed-off-by: James Hughes <james.hughes@raspberrypi.org>
>>> ---
>>>  drivers/net/usb/smsc95xx.c | 10 +++-------
>>>  1 file changed, 3 insertions(+), 7 deletions(-)
>>>
>>> diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
>>> index df60c98..04f6397 100644
>>> --- a/drivers/net/usb/smsc95xx.c
>>> +++ b/drivers/net/usb/smsc95xx.c
>>> @@ -2067,13 +2067,9 @@ static struct sk_buff *smsc95xx_tx_fixup(struct usbnet *dev,
>>>      /* We do not advertise SG, so skbs should be already linearized */
>>>      BUG_ON(skb_shinfo(skb)->nr_frags);
>>>
>>> -    if (skb_headroom(skb) < overhead) {
>>> -            struct sk_buff *skb2 = skb_copy_expand(skb,
>>> -                    overhead, 0, flags);
>>> -            dev_kfree_skb_any(skb);
>>> -            skb = skb2;
>>> -            if (!skb)
>>> -                    return NULL;
>>> +    /* Make writable and expand space by overhead if required */
>>> +    if (skb_cow(skb, overhead)) {
>>> +            return NULL;
>>>      }
>>
>> Note that this patch will probably force a copy of all locally generated
>> TCP packets.
>>
>> For them skb_cloned(skb) is true.
>>
>> I do believe skb_cow_head() would be better, since TCP stack uses the
>> __skb_header_release() helper to tell lower stacks they can write the
>> header part, even on a clone.
>
> Agreed.

I'm happy to work it as you see fit - you know this code far better than I do.

Our reading of the code is that the software checksum path is
modifying the data rather than just adding a header. Based on the
description of skb_cow_head it therefore isn't appropriate. If that
isn't a concern in reality then skb_cow_head is fine and I'll make a
V2 patchset.
Or do we need to skb_cow if doing the software checksum, but
skb_cow_head normally? That can be done instead but requires a
slightly larger change.

The failure case we were seeing was with a bridged network using
SMSC9514 and a Broadcom wifi chip on Raspberry Pi 3. The bridge was
making an SKB clone of broadcasts for the two interfaces, and then
both drivers were adding headers without checking skb_cloned(skb)
first, hence trampling on each other. For small packets the SMSC95xx
driver will be computing the software checksum and writing it in to
the data, so the wifi driver will also be seeing it. For many drivers
that probably won't matter, but is that always true?

(Patches for the Broadcom wifi driver will be coming once we've worked
out the best way of fixing this - there is no error path easily
available if the skb_cow_head call fails).


James
