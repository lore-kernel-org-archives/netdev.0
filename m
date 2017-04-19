From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next 1/2 v2] net sched actions: dump more than
 TCA_ACT_MAX_PRIO actions per batch
Date: Wed, 19 Apr 2017 07:02:31 -0400
Message-ID: <f830174b-239d-6ae6-29fe-12702de1df1e@mojatatu.com>
References: <1492564489-28854-1-git-send-email-jhs@emojatatu.com>
 <58F6EDA4.6090601@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        eric.dumazet@gmail.com, jiri@resnulli.us, xiyou.wangcong@gmail.com
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:35290 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1762544AbdDSLCe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Apr 2017 07:02:34 -0400
Received: by mail-io0-f195.google.com with SMTP id d203so2945368iof.2
        for <netdev@vger.kernel.org>; Wed, 19 Apr 2017 04:02:33 -0700 (PDT)
In-Reply-To: <58F6EDA4.6090601@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-04-19 12:55 AM, Roopa Prabhu wrote:
> On 4/18/17, 6:14 PM, Jamal Hadi Salim wrote:

>>
>> A new top level TLV space is introduced. An attribute
>> TCAA_ACT_FLAGS is used to carry the flags indicating the user
>> is capable of processing these large dumps. Older user space which
>> doesnt set this flag doesnt get the large (than 32) batches.
>> The kernel uses the TCAA_ACT_COUNT attribute to tell the user how many
>> actions are put in a single batch. As such user space app knows how long
>> to iterate (independent of the type of action being dumped)
>> instead of hardcoded maximum of 32.
> Is the count attribute really needed ?. user space knows how to iterate multiple
> attributes of the same type till the end of msg. eg. fdb dumps don't use count.
>

fdb dumping is different. One nlmsg contains one fdb entry.
So the boundary for checking for iproute2 is the nlmsg header.
So you wouldnt need such a counter.

OTOH, actions are packed, many per nlmsg:
I can put X or more policers in one nlmsg and batch many nlmsgs;
all constrained by the dump skb size.
Back in the day it was considered that a filter having more than
32 actions in its pipeline was probably enough. So in a dump, the
kernel would not send more than 32(TCA_ACT_MAX_PRIO) at a time.
This patch basically makes it fit as many as possible.

The other difference is there is only one type of fdb. There are
many types of actions - each with different sizes and different
optionally appearing entities. So if you are writing generic code
to print for example, you can play acrobatics in user space and
look at TLV lengths, deduce where the boundaries are for each type
and then for each type of action do speacial handling.
If the kernel tells you how many actions are packed then a major
change in iproute2 is:
-       for (i = 0; i < TCA_ACT_MAX_PRIO; i++) {
+       for (i = 0; i < tot_acts_from_kernel; i++) {

cheers,
jamal

PS: I think fdb is a good candidate for time filtering since
it keeps track of lastused time. You dont really have to change it to
be as  efficient as actions in terms of packing but it would
definetely improve status quo since you now have stats.
