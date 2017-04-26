From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next v8 2/3] net sched actions: dump more than
 TCA_ACT_MAX_PRIO actions per batch
Date: Wed, 26 Apr 2017 07:48:29 -0400
Message-ID: <8f1a1b14-ad9b-7840-1fa6-04f2a2e4f55d@mojatatu.com>
References: <1493121247-11863-1-git-send-email-jhs@emojatatu.com>
 <1493121247-11863-3-git-send-email-jhs@emojatatu.com>
 <20170425121338.GC1867@nanopsycho.orion>
 <5e54edd8-3943-6f09-490f-ff04b83077f6@mojatatu.com>
 <20170425160445.GD1867@nanopsycho.orion>
 <4b7789f7-69e0-4764-7029-f6e15d6e7d69@mojatatu.com>
 <20170426061904.GB1867@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, xiyou.wangcong@gmail.com,
        eric.dumazet@gmail.com, netdev@vger.kernel.org,
        Simon Horman <simon.horman@netronome.com>,
        Benjamin LaHaise <bcrl@kvack.org>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:36706 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S2994178AbdDZLsi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2017 07:48:38 -0400
Received: by mail-it0-f66.google.com with SMTP id x188so156368itb.3
        for <netdev@vger.kernel.org>; Wed, 26 Apr 2017 04:48:38 -0700 (PDT)
In-Reply-To: <20170426061904.GB1867@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-04-26 02:19 AM, Jiri Pirko wrote:
> Tue, Apr 25, 2017 at 10:29:40PM CEST, jhs@mojatatu.com wrote:
>> On 17-04-25 12:04 PM, Jiri Pirko wrote:
[..]
>> That is expected behavior correct?
>>
>> 3 months down the road:
>> I add two flags - bit 1 and 2.
>> So now my valid_flags changes to bits 1, 2 and 0.
>>
>> The function above will now return true for bits 0-2 but
>> will reject if you set bit 3.
>>
>> That is expected behavior, correct?
>
> The same app compiled against new kernel with bits (0, 1, 2) will run with
> this kernel good. But if you run it with older kernel, the kernel (0)
> would refuse. Is that ok?
>


Dave said that is what has to be done.
To quote from the cover letter:

--------- START QUOTE -------------
changes since v6:
-----------------

1) DaveM:
New rules for netlink messages. From now on we are going to start
checking for bits that are not used and rejecting anything we dont
understand. In the future this is going to require major changes
to user space code (tc etc). This is just a start.

To quote, David:
"
  Again, bits you aren't using now, make sure userspace doesn't
    set them.  And if it does, reject.
"

---------- END QUOTE -----------

I am going to send the patches - if you dont like this then speak up and
David needs to be convinced.  This is UAPI - once patches are in it is
cast in stone and I dont mind a discussion to make sure we get it right.

> Jamal, note that I never suggested having more flags in a single attr.
> Therefore I suggested u8 to carry a single flag.
>

Jiri, thats our main difference unless I am misunderstanding you.

I believe you should squeeze as many as you can in one single attribute.
You believe you should have only one flag per attribute.

Aesthetically a u8 looks good. Performance wise it is bad when you
have many entries to deal with.


> You say that it has performance impact having 3 flag attrs in compare to
> one bit flag attr. Could you please provide some numbers?
>

I have experience with dealing with a massive amount of various dumps
and (batch) sets and it always boils down to one thing:
_how much data is exchanged between user and kernel_
3 flags encoded as bits in a u32 attribute cost 64 bits.
Encoded separately cost 3x that.

Believe me, it _does make a difference_ in performance.

My least favorite subsystem is bridge. The bridge code has
tons of flags in those entries that are sent to/from kernel as u8
attributes. It is painful.

For something more recent, lets look at this commit from Ben on Flower:
+       TCA_FLOWER_KEY_MPLS_TTL,        /* u8 - 8 bits */
+       TCA_FLOWER_KEY_MPLS_BOS,        /* u8 - 1 bit */
+       TCA_FLOWER_KEY_MPLS_TC,         /* u8 - 3 bits */
+       TCA_FLOWER_KEY_MPLS_LABEL,      /* be32 - 20 bits */

Yes, that looks pretty, but:
That would have fit in one attribute with a u32. Mask attributes would
be eliminated with a second 32 bit - all in the same singular
attribute.

Imagine if i have 1M flower entries. If you add up the mask the cost
of these things is about 3*2*64 bits more per entry compared to putting
the mpls info/mask in one attribute.
At 1M entries that is a few MBs of data being exchanged.

> I expect that you will not be able to show the difference. And if there
> is no difference in performance, your main argument goes away. And we
> can do this in a nice, clear, TLV fashion.
>

I love TLVs Jiri. But there is a difference between management and
control. The former cares more about humans the later needs to get shit
done faster. The extreme version of the later is using json. But you
try to get the json guy to do setting or dumping 1M entries and you
can take a long distance trip and come back and they are not done.

I want to use TLVs but plan for optimization/performance as well.

cheers,
jamal
