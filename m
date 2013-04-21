From: Willem de Bruijn <willemb@google.com>
Subject: Re: [PATCH net-next v2] packet: tx timestamping on tpacket ring
Date: Sat, 20 Apr 2013 22:34:09 -0400
Message-ID: <CA+FuTSdcXhdG_YRF5gU6xp_-a-zOEf6i_rtJVHUpCGBBTNKMHA@mail.gmail.com>
References: <CA+FuTSdGdhgpRARbv9zFnDESzCQBzT=DS-WgGZRWBLBvhN_sNg@mail.gmail.com>
 <1366408317-16432-1-git-send-email-willemb@google.com> <20130420164359.GA10333@netboy>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Paul Chavent <paul.chavent@onera.fr>,
	daniel.borkmann@tik.ee.ethz.ch
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f172.google.com ([209.85.223.172]:48657 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751403Ab3DUCek (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Apr 2013 22:34:40 -0400
Received: by mail-ie0-f172.google.com with SMTP id c12so2029232ieb.31
        for <netdev@vger.kernel.org>; Sat, 20 Apr 2013 19:34:40 -0700 (PDT)
In-Reply-To: <20130420164359.GA10333@netboy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Apr 20, 2013 at 12:43 PM, Richard Cochran
<richardcochran@gmail.com> wrote:
> On Fri, Apr 19, 2013 at 05:51:57PM -0400, Willem de Bruijn wrote:
>
>> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
>> index 898cf5c..af9185d 100644
>> --- a/net/core/skbuff.c
>> +++ b/net/core/skbuff.c
>> @@ -3327,12 +3327,8 @@ void skb_tstamp_tx(struct sk_buff *orig_skb,
>>       if (!sk)
>>               return;
>>
>> -     skb = skb_clone(orig_skb, GFP_ATOMIC);
>> -     if (!skb)
>> -             return;
>> -
>>       if (hwtstamps) {
>> -             *skb_hwtstamps(skb) =
>> +             *skb_hwtstamps(orig_skb) =
>>                       *hwtstamps;
>
> And how does *hwtstamps get into the clone?

The struct is part of skb_shared_info, which is stored immediately
after skb->end in the region shared by all clones.

>
>>       } else {
>>               /*
>> @@ -3340,9 +3336,13 @@ void skb_tstamp_tx(struct sk_buff *orig_skb,
>>                * so keep the shared tx_flags and only
>>                * store software time stamp
>>                */
>> -             skb->tstamp = ktime_get_real();
>> +             orig_skb->tstamp = ktime_get_real();
>>       }
>>
>> +     skb = skb_clone(orig_skb, GFP_ATOMIC);
>> +     if (!skb)
>> +             return;
>> +
>>       serr = SKB_EXT_ERR(skb);
>>       memset(serr, 0, sizeof(*serr));
>>       serr->ee.ee_errno = ENOMSG;
>
> Thanks,
> Richard
