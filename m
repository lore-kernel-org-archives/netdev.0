From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next v8 2/3] net sched actions: dump more than
 TCA_ACT_MAX_PRIO actions per batch
Date: Wed, 26 Apr 2017 09:14:38 -0400
Message-ID: <10fe2c22-8e76-543e-dd24-ddce5813ab69@mojatatu.com>
References: <1493121247-11863-1-git-send-email-jhs@emojatatu.com>
 <1493121247-11863-3-git-send-email-jhs@emojatatu.com>
 <20170425121338.GC1867@nanopsycho.orion>
 <5e54edd8-3943-6f09-490f-ff04b83077f6@mojatatu.com>
 <20170425160445.GD1867@nanopsycho.orion>
 <4b7789f7-69e0-4764-7029-f6e15d6e7d69@mojatatu.com>
 <20170426061904.GB1867@nanopsycho.orion>
 <8f1a1b14-ad9b-7840-1fa6-04f2a2e4f55d@mojatatu.com>
 <20170426120851.GE1867@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, xiyou.wangcong@gmail.com,
        eric.dumazet@gmail.com, netdev@vger.kernel.org,
        Simon Horman <simon.horman@netronome.com>,
        Benjamin LaHaise <bcrl@kvack.org>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:33040 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S2993052AbdDZNOl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2017 09:14:41 -0400
Received: by mail-it0-f66.google.com with SMTP id z67so434411itb.0
        for <netdev@vger.kernel.org>; Wed, 26 Apr 2017 06:14:40 -0700 (PDT)
In-Reply-To: <20170426120851.GE1867@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-04-26 08:08 AM, Jiri Pirko wrote:
> Wed, Apr 26, 2017 at 01:48:29PM CEST, jhs@mojatatu.com wrote:
>> On 17-04-26 02:19 AM, Jiri Pirko wrote:
>>> Tue, Apr 25, 2017 at 10:29:40PM CEST, jhs@mojatatu.com wrote:
>>>> On 17-04-25 12:04 PM, Jiri Pirko wrote:

>> I have experience with dealing with a massive amount of various dumps
>> and (batch) sets and it always boils down to one thing:
>> _how much data is exchanged between user and kernel_
>> 3 flags encoded as bits in a u32 attribute cost 64 bits.
>> Encoded separately cost 3x that.
>>
>> Believe me, it _does make a difference_ in performance.
>>
>> My least favorite subsystem is bridge. The bridge code has
>> tons of flags in those entries that are sent to/from kernel as u8
>> attributes. It is painful.
>>
>> For something more recent, lets look at this commit from Ben on Flower:
>> +       TCA_FLOWER_KEY_MPLS_TTL,        /* u8 - 8 bits */
>> +       TCA_FLOWER_KEY_MPLS_BOS,        /* u8 - 1 bit */
>> +       TCA_FLOWER_KEY_MPLS_TC,         /* u8 - 3 bits */
>> +       TCA_FLOWER_KEY_MPLS_LABEL,      /* be32 - 20 bits */
>>
>> Yes, that looks pretty, but:
>> That would have fit in one attribute with a u32. Mask attributes would
>> be eliminated with a second 32 bit - all in the same singular
>> attribute.
>>
>> Imagine if i have 1M flower entries. If you add up the mask the cost
>> of these things is about 3*2*64 bits more per entry compared to putting
>> the mpls info/mask in one attribute.
>> At 1M entries that is a few MBs of data being exchanged.
>
> I can do the math :) Yet still, I would like to see the numbers :)
> Because I believe that is the only way to end this lenghty converstation
> once and forever...
>

Jiri, what are you arguing about if you have done the math? ;->
You want me to show you that getting or setting less data is good for
performance?
Look at the third patch: Why do i think it is necessary to send only
actions that have changed? Precisely to reduce the amount of data
being transported. The second patch - to reduce the amount of crossing
user space to kernel space (which is going to happen more with increased
data I have to transport between the user and the kernel).

Again: You are looking at this from a manageability point of view which
is useful but not the only input into a design. If i can squeeze more
data without killing usability - I am all for it. It just doesnt
compute that it is ok to use a flag per attribute because it looks
beautiful.

cheers,
jamal
