From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [RFC net-next] net: sched: do not acquire qdisc spinlock in
 qdisc/class stats dump
Date: Thu, 19 May 2016 22:23:59 -0700
Message-ID: <CAM_iQpVGjibj_bU2k_27O_PmzG1tqc6wHhg03yUe2RGzR++owA@mail.gmail.com>
References: <1463661320.18194.178.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAM_iQpUj9u4bgG+7Tc06z0_wSRhAWCVSz5KsydrhcmpoJf39tg@mail.gmail.com> <1463712330.18194.261.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	John Fastabend <john.fastabend@gmail.com>,
	Kevin Athey <kda@google.com>,
	Xiaotian Pei <xiaotian@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f193.google.com ([209.85.161.193]:32896 "EHLO
	mail-yw0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750851AbcETFYT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 May 2016 01:24:19 -0400
Received: by mail-yw0-f193.google.com with SMTP id y6so13405212ywe.0
        for <netdev@vger.kernel.org>; Thu, 19 May 2016 22:24:19 -0700 (PDT)
In-Reply-To: <1463712330.18194.261.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 19, 2016 at 7:45 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2016-05-19 at 18:50 -0700, Cong Wang wrote:
>> On Thu, May 19, 2016 at 5:35 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> >
>> > These stats are using u64 or u32 fields, so reading integral values
>> > should not prevent writers from doing concurrent updates if the kernel
>> > arch is a 64bit one.
>> >
>> > Being able to atomically fetch all counters like packets and bytes sent
>> > at the expense of interfering in fast path (queue and dequeue packets)
>> > is simply not worth the pain, as the values are generally stale after 1
>> > usec.
>>
>> I think one purpose of this lock is to make sure we have an atomic
>> snapshot of these counters as a whole. IOW, we may need another
>> lock rather than the qdisc root lock to guarantee this.
>
> Right, this was stated in the changelog.
>
> I played a bit at changing qdisc->__state to a seqcount.
>
> But this would add 2 additional smp_wmb() barriers.
>
> Not sure if any application would actually care if it reads
>
> Sent 22954160104777 bytes 1808585171 pkt (dropped 0, overlimits 0
> requeues 26021)
>
> Instead of
>
> Sent 22954160104777 bytes 1808585172 pkt (dropped 0, overlimits 0
> requeues 26021)
>
> ?

Sometimes I use bytes/pkts to valuate the average size of the packets.
;) It doesn't have to be that accurate but we don't know how inaccurate
it is without lock?
