From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH net] net/sched: Fix use of wild pointer in mq_destroy()
 when qdisc_alloc fail
Date: Fri, 24 Oct 2014 13:52:00 -0700
Message-ID: <CAHA+R7PDxYeVuQZz=VSci8_7sZ9smb5c59ivOS=B6GemJwtcCg@mail.gmail.com>
References: <OF7A403C69.2C35464E-ON48257D7B.002E24AA-48257D7B.002F2A62@zte.com.cn>
	<544A913A.1060100@gmail.com>
	<CAHA+R7P+nGXc93e_-u5Bvmr5Ri8CCg9FAgc+R7fJT7mJ5sBFwQ@mail.gmail.com>
	<20141024191418.GA8842@acer.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: John Fastabend <john.fastabend@gmail.com>, wang.bo116@zte.com.cn,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, cui.yunfeng@zte.com.cn
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f181.google.com ([209.85.216.181]:56436 "EHLO
	mail-qc0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751397AbaJXUwB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Oct 2014 16:52:01 -0400
Received: by mail-qc0-f181.google.com with SMTP id r5so1379516qcx.40
        for <netdev@vger.kernel.org>; Fri, 24 Oct 2014 13:52:00 -0700 (PDT)
In-Reply-To: <20141024191418.GA8842@acer.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 24, 2014 at 12:14 PM, Patrick McHardy <kaber@trash.net> wrote:
> On Fri, Oct 24, 2014 at 11:13:56AM -0700, Cong Wang wrote:
>> On Fri, Oct 24, 2014 at 10:49 AM, John Fastabend
>> <john.fastabend@gmail.com> wrote:
>> >
>> > Patch looks fine, another way to fix this would be drop the
>> > mq_destroy() call in the error path. I'm not convinced one
>> > is any better than the other but maybe some other folks have
>> > opinions, it seems a bit wrong to call mq_destroy twice so in
>> > that sense it may be a bit nicer to drop the mq_destroy().
>>
>> Dropping mq_destroy() in error path is indeed better,
>> because upper layer does cleanup intentionally.
>> Look at what other qdisc's do. :)
>
> I would argue that the qdisc_destroy() call in qdisc_create_dflt()
> is wrong, it should instead free the qdisc and release the module
> reference manually as done in qdisc_create().
>
> qdisc_destroy() should only be called for fully initialized qdiscs.

Probably, but at least ->destroy() should be called, looking at
those calling qdisc_watchdog_init(), they are supposed to call
qdisc_watchdog_cancel() when >init() fails after that.

->destroy() is supposed to be able to clean up even partially
initialized qdisc's. So, for qdisc_create_dflt() we should probably
just call ->destroy().

Reading the code again, seems it is inconsistent with qdisc_create(),
where ->destroy() is skipped when ->init() fails. Hmm, we have
a bigger problem here.

I am working on a patch now. Thanks for pointing this out.
