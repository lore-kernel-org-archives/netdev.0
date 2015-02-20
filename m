From: Eyal Birger <eyal.birger@gmail.com>
Subject: Re: [PATCH net-next v2 2/3] net: use skb->priority for overloading
 skb->dropcount and skb->reserved_tailroom instead of skb->mark
Date: Fri, 20 Feb 2015 13:32:48 +0200
Message-ID: <CAHsH6Gv709dahHUGqXkb8CYxn+s0-4+1DGksoNfAgMksZYrt9w@mail.gmail.com>
References: <1423715535-884-1-git-send-email-eyal.birger@gmail.com>
	<1423715535-884-3-git-send-email-eyal.birger@gmail.com>
	<20150219.150500.834870317013347277.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	Shmulik Ladkani <shmulik.ladkani@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f46.google.com ([209.85.213.46]:34584 "EHLO
	mail-yh0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751805AbbBTLct (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Feb 2015 06:32:49 -0500
Received: by yhai57 with SMTP id i57so3097365yha.1
        for <netdev@vger.kernel.org>; Fri, 20 Feb 2015 03:32:48 -0800 (PST)
In-Reply-To: <20150219.150500.834870317013347277.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Thanks for the review.

On Thu, Feb 19, 2015 at 10:05 PM, David Miller <davem@davemloft.net> wrote:
> From: Eyal Birger <eyal.birger@gmail.com>
> Date: Thu, 12 Feb 2015 06:32:14 +0200
>
>> The purpose of overloading skb->priority is solely for retaining
>> struct sk_buff size; skb->priority is not used after the skb queued
>> to the socket and has the same guarentee of not being shared as
>> skb->mark.
>
> I don't think this analysis is accurate.
>
>> @@ -621,7 +621,7 @@ struct sk_buff {
>>                       __u16   csum_offset;
>>               };
>>       };
>> -     __u32                   priority;
>> +     __u32                   mark;
>>       int                     skb_iif;
>>       __u32                   hash;
>>       __be16                  vlan_proto;
>> @@ -636,7 +636,7 @@ struct sk_buff {
>>       __u32                   secmark;
>>  #endif
>>       union {
>> -             __u32           mark;
>> +             __u32           priority;
>>               __u32           dropcount;
>>               __u32           reserved_tailroom;
>>       };
>> --
>
> You are going to now write to dropcount in packet_rcv() and that will
> corrupt skb->priority.  If we got to packet_rcv() via
> dev_queue_xmit_nit() then that skb->priority value is actually going
> to be used by the packet schedulers for classification, flow
> scheduling, etc.

As you've mentioned below, this is not a new behavior introduced by
this patch, it was
true for skb->mark as well.

However, It seems the skb is cloned prior to setting dropcount and
other skb header
fields before it is enqueued in packet_rcv(). Would that not prevent
interference with
the transmit path?

> So I don't think this transformation is going to work properly.
>
> I'm also wondering if aliasing with skb->mark, which is what happens
> now, is legal too.

As mentioned, the case is similar for skb->mark.

Best regards,
Eyal.
