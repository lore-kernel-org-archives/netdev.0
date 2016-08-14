From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH 2/2] net: sched: convert qdisc linked list to hashtable
Date: Sat, 13 Aug 2016 23:19:37 -0700
Message-ID: <CAM_iQpVD_+M7ehSxRRs6tRTfDWAzOp2hHLmSecguXq9YHYw5ag@mail.gmail.com>
References: <alpine.LNX.2.00.1608101049260.22028@cbobk.fhfr.pm>
 <alpine.LNX.2.00.1608101054320.22028@cbobk.fhfr.pm> <57ADC6AA.5070506@iogearbox.net>
 <alpine.LNX.2.00.1608121523020.22028@cbobk.fhfr.pm>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Phil Sutter <phil@nwl.cc>, David Miller <davem@davemloft.net>,
	LKML <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Jiri Kosina <jikos@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:36002 "EHLO
	mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752452AbcHNI1K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Aug 2016 04:27:10 -0400
In-Reply-To: <alpine.LNX.2.00.1608121523020.22028@cbobk.fhfr.pm>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 12, 2016 at 6:53 AM, Jiri Kosina <jikos@kernel.org> wrote:
> On Fri, 12 Aug 2016, Daniel Borkmann wrote:
>
>> This results in below panic. Tested reverting this patch and it fixes
>> the panic.
>>
>> Did you test this also with ingress or clsact qdisc (just try adding
>> it to lo dev for example) ?
>
> Hi Daniel,
>
> thanks for the report. Hmm, I am pretty sure clsact worked for me, but
> I'll recheck.
>
>> What happens is the following in qdisc_match_from_root():
>>
>> [  995.422187] XXX qdisc:ffff88025e4fc800 queue:ffff880262759000
>> dev:ffff880261cc2000 handle:ffff0000
>> [  995.422200] XXX qdisc:ffffffff81cf8100 queue:ffffffff81cf8240 dev:
>> (null) handle:ffff0000
>>
>> I believe this is due to dev_ingress_queue_create() assigning the
>> global noop_qdisc instance as qdisc_sleeping, which later qdisc_lookup()
>> uses for qdisc_match_from_root().
>>
>> But everything that uses things like noop_qdisc cannot work with the
>> new qdisc_match_from_root(), because qdisc_dev(root) will always trigger
>> NULL pointer dereference there. Reason is because the dev is always
>> NULL for noop, it's a singleton, see noop_qdisc and noop_netdev_queue
>> in sch_generic.c.
>>
>> Now how to fix it? Creating separate noop instances each time it's set
>> would be quite a waste of memory. Even fuglier would be to hack a static
>> net device struct into sch_generic.c and let noop_netdev_queue point there
>> to get to the hash table. Or we just not use qdisc_dev().
>
> How about we actually extend a little bit the TCQ_F_BUILTIN special case
> test in qdisc_match_from_root()?
>
> After the change, the only way how qdisc_dev() could be NULL should be a
> TCQ_F_BUILTIN case, right?
>
> I was thinking about something like the patch below (the reasong being
> that ->dev would be NULL only in cases of singletonish qdiscs) ...
> wouldn't that also fix the issue you're seeing? Have to think it through a
> little bit more ..

I think this is probably why we never show noop qdisc in dump. So I think
we should relax the singleton rule for noop_qdisc, to save some code
for noop_qdisc case and also for dumping noop_qdisc.

I will try to work on a patch tomorrow.
