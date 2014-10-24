From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH net] net/sched: Fix use of wild pointer in mq_destroy()
 when qdisc_alloc fail
Date: Fri, 24 Oct 2014 15:17:41 -0700
Message-ID: <CAHA+R7PxvW6umBJMxGk0h=ht4RhoDRcrxr5WSTEUBa80TxU5GQ@mail.gmail.com>
References: <OF7A403C69.2C35464E-ON48257D7B.002E24AA-48257D7B.002F2A62@zte.com.cn>
	<544A913A.1060100@gmail.com>
	<CAHA+R7P+nGXc93e_-u5Bvmr5Ri8CCg9FAgc+R7fJT7mJ5sBFwQ@mail.gmail.com>
	<20141024191418.GA8842@acer.localdomain>
	<CAHA+R7PDxYeVuQZz=VSci8_7sZ9smb5c59ivOS=B6GemJwtcCg@mail.gmail.com>
	<20141024214511.GA10290@acer.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: John Fastabend <john.fastabend@gmail.com>, wang.bo116@zte.com.cn,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, cui.yunfeng@zte.com.cn
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f170.google.com ([209.85.216.170]:39715 "EHLO
	mail-qc0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755189AbaJXWRn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Oct 2014 18:17:43 -0400
Received: by mail-qc0-f170.google.com with SMTP id l6so1501270qcy.29
        for <netdev@vger.kernel.org>; Fri, 24 Oct 2014 15:17:43 -0700 (PDT)
In-Reply-To: <20141024214511.GA10290@acer.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 24, 2014 at 2:45 PM, Patrick McHardy <kaber@trash.net> wrote:
> On Fri, Oct 24, 2014 at 01:52:00PM -0700, Cong Wang wrote:
>> On Fri, Oct 24, 2014 at 12:14 PM, Patrick McHardy <kaber@trash.net> wrote:
>> > On Fri, Oct 24, 2014 at 11:13:56AM -0700, Cong Wang wrote:
>> >> On Fri, Oct 24, 2014 at 10:49 AM, John Fastabend
>> >> <john.fastabend@gmail.com> wrote:
>> >> >
>> >> > Patch looks fine, another way to fix this would be drop the
>> >> > mq_destroy() call in the error path. I'm not convinced one
>> >> > is any better than the other but maybe some other folks have
>> >> > opinions, it seems a bit wrong to call mq_destroy twice so in
>> >> > that sense it may be a bit nicer to drop the mq_destroy().
>> >>
>> >> Dropping mq_destroy() in error path is indeed better,
>> >> because upper layer does cleanup intentionally.
>> >> Look at what other qdisc's do. :)
>> >
>> > I would argue that the qdisc_destroy() call in qdisc_create_dflt()
>> > is wrong, it should instead free the qdisc and release the module
>> > reference manually as done in qdisc_create().
>> >
>> > qdisc_destroy() should only be called for fully initialized qdiscs.
>>
>> Probably, but at least ->destroy() should be called, looking at
>> those calling qdisc_watchdog_init(), they are supposed to call
>> qdisc_watchdog_cancel() when >init() fails after that.
>
> In which cases does it actually fail after that? Usually this is
> called once initialization is complete.

How about tbf_change() in tbf_init()? If tbf_change() fails,
watchdog is still there if we don't call ->destroy(). Yes,
I know the timer is started, the point is we do miss something
clean up, even trivial.

tbf is not the only one who calls xxx_change() in xxx_init().

>
>> ->destroy() is supposed to be able to clean up even partially
>> initialized qdisc's. So, for qdisc_create_dflt() we should probably
>> just call ->destroy().
>
> No, why do you think that? ->init() is supposed to clean up after
> itself if it fails, both qdisc_destroy() and ->destroy are only
> supposed to be called after ->init() succeeded.


Why? This would end up with calling xxx_destroy() in every
failure path in ->init(). Moving it up to caller makes the code cleaner
and smaller.

>
> Its simply symetrical, as everywhere else in the kernel. If a sub-init
> funtion fails, it should clean up and return an error. We don't
> destroy things we've never successfully initialized, they're supposed
> to clean up after themselves.

Most (if not all) ->destroy() are able to clean partially initialized qdisc,
I don't see why it  could be a problem here.

We don't have to keep with other kernel subsystem as long as it makes
sense, net_sched subsystem is pretty much self-contained.
