From: James Hughes <james.hughes@raspberrypi.org>
Subject: Re: [PATCH v2] smsc95xx: Use skb_cow_head to deal with cloned skbs
Date: Wed, 19 Apr 2017 10:40:18 +0100
Message-ID: <CAE_XsM+b3vXGPYT8j0iM_FsAux_3AtYaj+HdUaTy-3QU0eKomg@mail.gmail.com>
References: <20170418171706.21190-1-james.hughes@raspberrypi.org>
 <1492541921.10587.135.camel@edumazet-glaptop3.roam.corp.google.com>
 <9235D6609DB808459E95D78E17F2E43D40A477A5@CHN-SV-EXMX02.mchp-main.com>
 <1492555561.10587.147.camel@edumazet-glaptop3.roam.corp.google.com> <CAE_XsMJhCVU4eHtiO7gs3=mRvA9vN4kiuh2JhXf+F_YgVXcWhQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Woojung.Huh@microchip.com, netdev@vger.kernel.org,
        Steve Glendinning <steve.glendinning@shawell.net>,
        Microchip Linux Driver Support <UNGLinuxDriver@microchip.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx08-00252a01.pphosted.com ([91.207.212.211]:51962 "EHLO
        mx08-00252a01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1761817AbdDSJkV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Apr 2017 05:40:21 -0400
Received: from pps.filterd (m0102629.ppops.net [127.0.0.1])
        by mx08-00252a01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3J9aZ3L015993
        for <netdev@vger.kernel.org>; Wed, 19 Apr 2017 10:40:20 +0100
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
        by mx08-00252a01.pphosted.com with ESMTP id 29wqp2895k-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=OK)
        for <netdev@vger.kernel.org>; Wed, 19 Apr 2017 10:40:19 +0100
Received: by mail-wr0-f198.google.com with SMTP id c55so1843213wrc.22
        for <netdev@vger.kernel.org>; Wed, 19 Apr 2017 02:40:19 -0700 (PDT)
In-Reply-To: <CAE_XsMJhCVU4eHtiO7gs3=mRvA9vN4kiuh2JhXf+F_YgVXcWhQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 19 April 2017 at 09:33, James Hughes <james.hughes@raspberrypi.org> wrote:
> On 18 April 2017 at 23:46, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> On Tue, 2017-04-18 at 22:09 +0000, Woojung.Huh@microchip.com wrote:
>>> > > @@ -2067,13 +2067,9 @@ static struct sk_buff *smsc95xx_tx_fixup(struct
>>> > usbnet *dev,
>>> > >   /* We do not advertise SG, so skbs should be already linearized */
>>> > >   BUG_ON(skb_shinfo(skb)->nr_frags);
>>> > >
>>> > > - if (skb_headroom(skb) < overhead) {
>>> > > -         struct sk_buff *skb2 = skb_copy_expand(skb,
>>> > > -                 overhead, 0, flags);
>>> > > -         dev_kfree_skb_any(skb);
>>> > > -         skb = skb2;
>>> > > -         if (!skb)
>>> > > -                 return NULL;
>>> > > + /* Make writable and expand header space by overhead if required
>>> > */
>>> > > + if (skb_cow_head(skb, overhead)) {
>>> >
>>> > I believe you still need to
>>> >             dev_kfree_skb_any(skb);
>>> >
>>> I think caller of usbnet_start_xmit() takes care of free when return NULL.
>>
>> I do not think so. Here is the code in usbnet_start_xmit() :
>>
>> if (info->tx_fixup) {
>>    skb = info->tx_fixup (dev, skb, GFP_ATOMIC);
>>
>>    if (!skb) { // Note that skb is NULL now
>>
>>        if (info->flags & FLAG_MULTI_PACKET)
>>              goto not_drop;
>>         netif_dbg(dev, tx_err, dev->net, "can't tx_fixup skb\n");
>>         goto drop;
>>
>>
>> If you really think about it (even before double checking the code in
>> usbnet_start_xmit()), that would have been a very serious bug.
>>
>> Calling dev_kfree_skb_any(skb) in this fixup code, then later from
>> usbnet_start_xmit() would have been a double free, or use after free.
>>
>>
>
> So, I still need to return NULL (as per the code this is replacing) to
> indicate failure, but need to free the skb prior to return, as per
> fragment below.
>
> /* Make writable and expand header space by overhead if required */
> if (skb_cow_head(skb, overhead)) {
>    dev_kfree_skb_any(skb);
>    return NULL;
> }
>
> Once confirmed, I'll do a another patch.

Actually, having checked the code path, doing the free here does look
like the correct operation. Returning NULL indicates to the caller
that the call has failed, but also means the skb is not deallocated
later on. It's seems rather a clunky mechanism for the driver to have
to deallocate, but I guess that's 'just the way it is'.

I'll do another patch.
