From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net-next 2/2] net: exit busy loop when another process
 is runnable
Date: Wed, 03 Sep 2014 14:58:33 +0800
Message-ID: <5406BC19.9020009@redhat.com>
References: <1408608310-13579-1-git-send-email-jasowang@redhat.com> <1408608310-13579-2-git-send-email-jasowang@redhat.com> <1408683665.5648.69.camel@marge.simpson.net> <20140901093159.GB27892@worktop.ger.corp.intel.com> <20140901095219.GD21269@redhat.com> <20140901100434.GD27892@worktop.ger.corp.intel.com> <20140901101939.GA31157@worktop.ger.corp.intel.com> <5405419E.7020103@redhat.com> <20140902102410.GX27892@worktop.ger.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	Mike Galbraith <umgwanakikbuti@gmail.com>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Ingo Molnar <mingo@elte.hu>,
	Eliezer Tamir <eliezer.tamir@linux.intel.com>
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55301 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755121AbaICG7O (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Sep 2014 02:59:14 -0400
In-Reply-To: <20140902102410.GX27892@worktop.ger.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/02/2014 06:24 PM, Peter Zijlstra wrote:
> On Tue, Sep 02, 2014 at 12:03:42PM +0800, Jason Wang wrote:
>> > On 09/01/2014 06:19 PM, Peter Zijlstra wrote:
>>> > > OK I suppose that more or less makes sense, the contextual behaviour is
>>> > > of course tedious in that it makes behaviour less predictable. The
>>> > > 'other' tasks might not want to generate data and you then destroy
>>> > > throughput by not spinning.
>> > 
>> > The patch try to make sure:
>> > - the the performance of busy read was not worse than it was disabled in
>> > any cases.
>> > - the performance improvement of a single socket was not achieved by
>> > sacrificing the total performance (all other processes) of the system
>> >  
>> > If 'other' tasks are also CPU or I/O intensive jobs, we switch to do
>> > them so the total performance were kept or even increased, and the
>> > performance of current process were guaranteed not worse than when busy
>> > read was disabled (or even better since it may still do busy read
>> > sometimes when it was the only runnable process). If 'other' task are
>> > not intensive, they just do little work and sleep soon, then the busy
>> > read can still work in most of the time during the future reads, we may
>> > still get obvious improvements
> Not entirely true; the select/poll whatever will now block, which means
> we need a wakeup, which increases the latency immensely.

Not sure I get your meaning. This patch does not change the logic or
dynamic of select/poll since sock_poll() always call sk_busy_loop() with
noblock is true. This means sk_busy_loop() will only try ndo_busy_poll()
once whatever the result of other checks. The busy polling was done
through its caller in fact.
>>> > > I'm not entirely sure I see how its all supposed to work though; the
>>> > > various poll functions call sk_busy_poll() and do_select() also loops.
>>> > >
>>> > > The patch only kills the sk_busy_poll() loop, but then do_select() will
>>> > > still loop and not sleep, so how is this helping?
>> > 
>> > Yes, the patch only help for processes who did a blocking reads (busy
>> > read). For select(), maybe we can do the same thing but need more test
>> > and thoughts.
> What's the blocking read callgraph, how so we end up in sk_busy_poll() there?
>
> But that's another reason the patch is wrong.

The patch only try to improve the performance of busy read (and test
results shows impressive changes). It does not change anything for busy
poll. Considering there maybe two processes in one cpu, one is doing
busy read and one is doing busy polling. This patch may in fact help the
busy polling performance in this case.

It's good to discuss the ideas of busy poll together, but it was out of
the scope of this patch. We can try to do optimization on top.
