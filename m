From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH RFC 05/11] skbuff: Extend gso_type to unsigned int.
Date: Fri, 23 Sep 2016 08:15:18 -0700
Message-ID: <CAKgT0UdBswycmfpomorMWXneh6=yDbfBbwqrYc9Qtk8zFcVtgw@mail.gmail.com>
References: <1474617228-26103-1-git-send-email-steffen.klassert@secunet.com>
 <1474617228-26103-6-git-send-email-steffen.klassert@secunet.com> <063D6719AE5E284EB5DD2968C1650D6DB0107FC2@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Sowmini Varadhan <sowmini.varadhan@oracle.com>,
        Ilan Tayari <ilant@mellanox.com>,
        Boris Pismenny <borisp@mellanox.com>,
        Ariel Levkovich <lariel@mellanox.com>,
        "Hay, Joshua A" <joshua.a.hay@intel.com>
To: David Laight <David.Laight@aculab.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:36081 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965332AbcIWPPU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Sep 2016 11:15:20 -0400
Received: by mail-io0-f196.google.com with SMTP id z135so7336767ioe.3
        for <netdev@vger.kernel.org>; Fri, 23 Sep 2016 08:15:19 -0700 (PDT)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DB0107FC2@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 23, 2016 at 6:19 AM, David Laight <David.Laight@aculab.com> wrote:
> From: Steffen Klassert
>> Sent: 23 September 2016 08:54
>> All available gso_type flags are currently in use,
>> so extend gso_type to be able to add further flags.
>>
>> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
>> ---
>>  include/linux/skbuff.h | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
>> index f21da42..c1fd854 100644
>> --- a/include/linux/skbuff.h
>> +++ b/include/linux/skbuff.h
>> @@ -417,7 +417,7 @@ struct skb_shared_info {
>>       unsigned short  gso_size;
>>       /* Warning: this field is not always filled in (UFO)! */
>>       unsigned short  gso_segs;
>> -     unsigned short  gso_type;
>> +     unsigned int    gso_type;
>>       struct sk_buff  *frag_list;
>>       struct skb_shared_hwtstamps hwtstamps;
>>       u32             tskey;
>
> That add a lot of padding.
> I'm not even sure DM will like this structure being extended.
> If ktime_t is 64 bit I think there is already some padding later on.

+1.  Just increasing the size is a bad idea as it will add a 6 byte
hole and push frag 0 outside the first cache line.

You may want to take a look at rearranging the structure a bit.  That
way you could eat into the 4 byte hole that is available on x86_64 so
that instead of shifting everything up by 8 bytes they can mostly stay
put with only a bit of rearranging.  This is one of those times a tool
like pahole comes in handy.

Also it occurs to me that one other thing you could look at is if you
were to move gso_type into the slot after dataref we might be able to
make use of the hole while also saving us some initialization time as
the change in size would push us from 32 to 36 which would likely
impact the memset operation by at least a 1 cycle increase.  If we
could make it so that we don't have to initialize the memory for
gso_type unless we are planning to set gso_size we can avoid the extra
overhead for that.  It would just be a matter of validating that
nothing reads gso_type unless gso_size is set and that gso_type is
always written to prior to setting gso_size to a non-zero value.

- Alex
