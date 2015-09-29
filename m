From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net] skbuff: Fix skb checksum partial check.
Date: Mon, 28 Sep 2015 20:13:04 -0700
Message-ID: <CALnjE+rmUgkzAxUDASQuFzywKZBeEv=EQgZMSN2CkbAH3dtJ9A@mail.gmail.com>
References: <1443486265-2246-1-git-send-email-pshelar@nicira.com>
	<CALx6S35z9BHcSDHso1ZyNa+5beZe=5tXSPNOYFkVEV80+k=Eqw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f170.google.com ([209.85.223.170]:32821 "EHLO
	mail-io0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932154AbbI2DNF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Sep 2015 23:13:05 -0400
Received: by iofh134 with SMTP id h134so197376049iof.0
        for <netdev@vger.kernel.org>; Mon, 28 Sep 2015 20:13:04 -0700 (PDT)
In-Reply-To: <CALx6S35z9BHcSDHso1ZyNa+5beZe=5tXSPNOYFkVEV80+k=Eqw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 28, 2015 at 5:46 PM, Tom Herbert <tom@herbertland.com> wrote:
> On Mon, Sep 28, 2015 at 5:24 PM, Pravin B Shelar <pshelar@nicira.com> wrote:
>> Earlier patch 6ae459bda tried to detect void ckecksum partial
>> skb by comparing pull length to checksum offset. But it does
>> not work for all cases since checksum-offset depends on
>> updates to skb->data.
>>
>> Following patch fixes it by validating checksum start offset
>> after skb-data pointer is updated. Negative value of checksum
>> offset start means there is no need to checksum.
>>
>> Fixes: 6ae459bda ("skbuff: Fix skb checksum flag on skb pull")
>> Reported-by: Andrew Vagin <avagin@odin.com>
>> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
>> ---
>> This and 6ae459bda patches needs to be backported to stable.
>> ---
>>  include/linux/skbuff.h |    2 +-
>>  net/core/skbuff.c      |    9 +++++----
>>  2 files changed, 6 insertions(+), 5 deletions(-)
>>
>> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
>> index 2b0a30a..4398411 100644
>> --- a/include/linux/skbuff.h
>> +++ b/include/linux/skbuff.h
>> @@ -2708,7 +2708,7 @@ static inline void skb_postpull_rcsum(struct sk_buff *skb,
>>         if (skb->ip_summed == CHECKSUM_COMPLETE)
>>                 skb->csum = csum_sub(skb->csum, csum_partial(start, len, 0));
>>         else if (skb->ip_summed == CHECKSUM_PARTIAL &&
>> -                skb_checksum_start_offset(skb) <= len)
>> +                skb_checksum_start_offset(skb) < 0)
>>                 skb->ip_summed = CHECKSUM_NONE;
>>  }
>>
>> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
>> index dad4dd3..fab4599 100644
>> --- a/net/core/skbuff.c
>> +++ b/net/core/skbuff.c
>> @@ -2958,11 +2958,12 @@ EXPORT_SYMBOL_GPL(skb_append_pagefrags);
>>   */
>>  unsigned char * skb_pull_rcsum(struct sk_buff *skb, unsigned int len)
>>  {
>> +       unsigned char *data = skb->data;
>> +
>>         BUG_ON(len > skb->len);
>> -       skb->len -= len;
>> -       BUG_ON(skb->len < skb->data_len);
>> -       skb_postpull_rcsum(skb, skb->data, len);
>> -       return skb->data += len;
>> +       __skb_pull(skb, len);
>> +       skb_postpull_rcsum(skb, data, len);
>> +       return skb->data;
>>  }
>
> Nice cleanup in skb_pull_rcsum, but does this affect other calls to
> skb_postpull_rcsum?
>

I checked all callers to skb_postpull_rcsum(). Basically there are two
type of caller. First case is pulling headers which is same as this
case, for example pull skb then call postpull_rcsum() to update csum.
Second case is where update checksum while poping a header, for
example pop vlan header. All these case works fine with the change.
