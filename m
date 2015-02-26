From: Eyal Birger <eyal.birger@gmail.com>
Subject: Re: [PATCH net-next 7/7] net: move skb->dropcount to skb->cb[]
Date: Thu, 26 Feb 2015 12:48:14 +0200
Message-ID: <CAHsH6Gs5JwRXgWGuC4fKaqPU3yb219z1q1K-cvn5Z6qjFOgo8A@mail.gmail.com>
References: <1424916612-744-1-git-send-email-eyal.birger@gmail.com>
	<1424916612-744-8-git-send-email-eyal.birger@gmail.com>
	<20150226104909.1f2c882d@halley>
	<CAHsH6GvEmkOZU=VngK9-yn_2ajNX2YU1aJ=qfuHby3=58r4dKw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Willem de Bruijn <willemb@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Marcel Holtmann <marcel@holtmann.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f176.google.com ([209.85.160.176]:32915 "EHLO
	mail-yk0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753676AbbBZKsR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2015 05:48:17 -0500
Received: by ykr79 with SMTP id 79so3683082ykr.0
        for <netdev@vger.kernel.org>; Thu, 26 Feb 2015 02:48:15 -0800 (PST)
In-Reply-To: <CAHsH6GvEmkOZU=VngK9-yn_2ajNX2YU1aJ=qfuHby3=58r4dKw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 26, 2015 at 12:17 PM, Eyal Birger <eyal.birger@gmail.com> wrote:
> On Thu, Feb 26, 2015 at 10:49 AM, Shmulik Ladkani
> <shmulik.ladkani@gmail.com> wrote:
>> On Thu, 26 Feb 2015 04:10:12 +0200 Eyal Birger <eyal.birger@gmail.com> wrote:
>>> diff --git a/include/net/sock.h b/include/net/sock.h
>>> index d462f5e..8807586 100644
>>> --- a/include/net/sock.h
>>> +++ b/include/net/sock.h
>>> @@ -2078,12 +2078,26 @@ static inline int sock_intr_errno(long timeo)
>>>       return timeo == MAX_SCHEDULE_TIMEOUT ? -ERESTARTSYS : -EINTR;
>>>  }
>>>
>>> +struct sock_skb_cb {
>>> +     u32 dropcount;
>>> +};
>>> +
>>> +/* Store sock_skb_cb at the end of skb->cb[] so protocol families
>>> + * using skb->cb[] would keep using it directly and utilize its
>>> + * alignement guarantee.
>>> + */
>>> +#define SOCK_SKB_CB_OFFSET ((FIELD_SIZEOF(struct sk_buff, cb) - \
>>> +                         sizeof(struct sock_skb_cb)))
>>> +
>>> +#define SOCK_SKB_CB(__skb) ((struct sock_skb_cb *)((__skb)->cb + \
>>> +                         SOCK_SKB_CB_OFFSET))
>>> +
>>>  #define sock_skb_cb_check_size(size) \
>>> -     BUILD_BUG_ON((size) > FIELD_SIZEOF(struct sk_buff, cb))
>>> +     BUILD_BUG_ON((size) > SOCK_SKB_CB_OFFSET)
>>>
>>
>> You didn't take care of aligning the 'sock_skb_cb'.
>> (Althogh in practive, dropcount is 4 and cb[] is 48 so you're golden).
>>
>> How about:
>>
>> struct sock_skb_cb {
>>         /* protocol families specifc CBs */
>>         u8 reserved[__SOCK_SKB_CB_OFFSET];
>>         struct __sock_skb_cb x;                 // name me better!
>> };
>>
>> Where '__SOCK_SKB_CB_OFFSET' and '__sock_skb_cb' are as follows:
>>
>> struct __sock_skb_cb {  // name me better!
>>         u32 dropcount;
>> };
>>
>> #define __SOCK_SKB_CB_OFFSET_UNALIGNED \
>>         (FIELD_SIZEOF(struct sk_buff, cb) - sizeof(struct __sock_skb_cb))
>>
>> #define __SOCK_SKB_CB_OFFSET \
>>         (__SOCK_SKB_CB_OFFSET_UNALIGNED - \
>>          (__SOCK_SKB_CB_OFFSET_UNALIGNED % __alignof__(struct __sock_skb_cb)))
>>
>> This also takes care for alignement of '__sock_skb_cb x' within the CB.
>>
>> Then,
>>
>> #define sock_skb_cb_check_size(size) \
>>         BUILD_BUG_ON((size) > FIELD_SIZEOF(struct sock_skb_cb, reserved))
>>
>
> Agreed. Will add to v2.

After giving it some additional thought and research, I don't think
this is necessary.

The sizeof operator on struct sock_skb_cb would give a padded result
which would take care of the structure alignment.

This is under the assumption that skb->cb[] size is of a proper multiple (which
I think is rather safe).

Objections?
Eyal.
