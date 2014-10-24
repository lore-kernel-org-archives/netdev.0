From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH net] net/sched: Fix use of wild pointer in mq_destroy()
 when qdisc_alloc fail
Date: Fri, 24 Oct 2014 22:45:12 +0100
Message-ID: <20141024214511.GA10290@acer.localdomain>
References: <OF7A403C69.2C35464E-ON48257D7B.002E24AA-48257D7B.002F2A62@zte.com.cn>
 <544A913A.1060100@gmail.com>
 <CAHA+R7P+nGXc93e_-u5Bvmr5Ri8CCg9FAgc+R7fJT7mJ5sBFwQ@mail.gmail.com>
 <20141024191418.GA8842@acer.localdomain>
 <CAHA+R7PDxYeVuQZz=VSci8_7sZ9smb5c59ivOS=B6GemJwtcCg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: John Fastabend <john.fastabend@gmail.com>, wang.bo116@zte.com.cn,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, cui.yunfeng@zte.com.cn
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:40497 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752524AbaJXVpR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Oct 2014 17:45:17 -0400
Content-Disposition: inline
In-Reply-To: <CAHA+R7PDxYeVuQZz=VSci8_7sZ9smb5c59ivOS=B6GemJwtcCg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 24, 2014 at 01:52:00PM -0700, Cong Wang wrote:
> On Fri, Oct 24, 2014 at 12:14 PM, Patrick McHardy <kaber@trash.net> wrote:
> > On Fri, Oct 24, 2014 at 11:13:56AM -0700, Cong Wang wrote:
> >> On Fri, Oct 24, 2014 at 10:49 AM, John Fastabend
> >> <john.fastabend@gmail.com> wrote:
> >> >
> >> > Patch looks fine, another way to fix this would be drop the
> >> > mq_destroy() call in the error path. I'm not convinced one
> >> > is any better than the other but maybe some other folks have
> >> > opinions, it seems a bit wrong to call mq_destroy twice so in
> >> > that sense it may be a bit nicer to drop the mq_destroy().
> >>
> >> Dropping mq_destroy() in error path is indeed better,
> >> because upper layer does cleanup intentionally.
> >> Look at what other qdisc's do. :)
> >
> > I would argue that the qdisc_destroy() call in qdisc_create_dflt()
> > is wrong, it should instead free the qdisc and release the module
> > reference manually as done in qdisc_create().
> >
> > qdisc_destroy() should only be called for fully initialized qdiscs.
> 
> Probably, but at least ->destroy() should be called, looking at
> those calling qdisc_watchdog_init(), they are supposed to call
> qdisc_watchdog_cancel() when >init() fails after that.

In which cases does it actually fail after that? Usually this is
called once initialization is complete.

> ->destroy() is supposed to be able to clean up even partially
> initialized qdisc's. So, for qdisc_create_dflt() we should probably
> just call ->destroy().

No, why do you think that? ->init() is supposed to clean up after
itself if it fails, both qdisc_destroy() and ->destroy are only
supposed to be called after ->init() succeeded.

Its simply symetrical, as everywhere else in the kernel. If a sub-init
funtion fails, it should clean up and return an error. We don't
destroy things we've never successfully initialized, they're supposed
to clean up after themselves.

> Reading the code again, seems it is inconsistent with qdisc_create(),
> where ->destroy() is skipped when ->init() fails. Hmm, we have
> a bigger problem here.
> 
> I am working on a patch now. Thanks for pointing this out.

No, that is not inconsistent, it is consistent with what we're doing
everywhere else in the kernel, what the qdisc layer has always done
and how qdiscs expect it.

Where are you seeing a problem now? Its a simple fix:
qdisc_create_dflt() should behave similar to qdisc_create().

If any ->init() functions than don't properly clean up on error, that's
an additional bug.
