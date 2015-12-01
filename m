From: Cong Wang <cwang@twopensource.com>
Subject: Re: size overflow in function qdisc_tree_decrease_qlen net/sched/sch_api.c
Date: Tue, 1 Dec 2015 10:43:00 -0800
Message-ID: <CAHA+R7NiYjhE5dY7HPkWuoTA5WMqF3zPyCFk5i3LYTUrYD7gYA@mail.gmail.com>
References: <20151201010005.GA23175@Fux-PC>
	<1448978807.25582.19.camel@edumazet-glaptop2.roam.corp.google.com>
	<1448979011.25582.21.camel@edumazet-glaptop2.roam.corp.google.com>
	<565DC716.22673.2DBA261B@pageexec.freemail.hu>
	<1448987660.2977.6.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: pageexec@freemail.hu, Daniele Fucini <dfucini@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	David Miller <davem@davemloft.net>, spender@grsecurity.net,
	re.emese@gmail.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f182.google.com ([209.85.160.182]:34846 "EHLO
	mail-yk0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754390AbbLASnB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2015 13:43:01 -0500
Received: by ykba77 with SMTP id a77so18272995ykb.2
        for <netdev@vger.kernel.org>; Tue, 01 Dec 2015 10:43:00 -0800 (PST)
In-Reply-To: <1448987660.2977.6.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 1, 2015 at 8:34 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Tue, 2015-12-01 at 17:13 +0100, PaX Team wrote:
>> On 1 Dec 2015 at 6:10, Eric Dumazet wrote:
>>
>> > On Tue, 2015-12-01 at 06:06 -0800, Eric Dumazet wrote:
>> > > On Tue, 2015-12-01 at 12:19 +0100, Daniele Fucini wrote:
>> > > > Thanks for the reply. Here's the output of `tc qdisc show`:
>> > > > https://gist.github.com/1847102c8fe08f63e9e7
>> >
>> > > Hmm... I do not think we ever took care of MQ in
>> > > qdisc_tree_decrease_qlen()
>> >
>> > This looks like a false positive, because MQ recomputes backlog/qlen at
>> > the time (stats) dumps are requested.
>> >
>> > I would say there is no bug.
>>
>> is it correct for sk_buff_head.qlen to underflow in general
>> or just in this particular sched code? (we can exclude overflow
>> checking for either case but obviously would like to retain as
>> much coverage as possible)
>
> We do not particularly care on the qlen value for MQ, although we simply
> should avoid doing anything.
>
> Otherwise we might report slightly wrong qlen values while doing "tc -s
> qdisc show" if the qdisc_tree_decrease_qlen() happens right after we
> computed the folded values in mq_dump()
>
> Please try the patch I sent. I am pretty sure it should be the right
> fix.
>

This smells hacky... Another way to fix this is to hold the qdisc tree
lock in mq_dump(), since it is not a hot path (comparing with
enqueue/dequeue)?
