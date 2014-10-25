From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH net] net/sched: Fix use of wild pointer in mq_destroy()
 when qdisc_alloc fail
Date: Sat, 25 Oct 2014 01:33:49 +0100
Message-ID: <20141025003348.GA11289@acer.localdomain>
References: <OF7A403C69.2C35464E-ON48257D7B.002E24AA-48257D7B.002F2A62@zte.com.cn>
 <544A913A.1060100@gmail.com>
 <CAHA+R7P+nGXc93e_-u5Bvmr5Ri8CCg9FAgc+R7fJT7mJ5sBFwQ@mail.gmail.com>
 <20141024191418.GA8842@acer.localdomain>
 <CAHA+R7PDxYeVuQZz=VSci8_7sZ9smb5c59ivOS=B6GemJwtcCg@mail.gmail.com>
 <20141024214511.GA10290@acer.localdomain>
 <CAHA+R7PxvW6umBJMxGk0h=ht4RhoDRcrxr5WSTEUBa80TxU5GQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: John Fastabend <john.fastabend@gmail.com>, wang.bo116@zte.com.cn,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, cui.yunfeng@zte.com.cn
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:42936 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932111AbaJYAdy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Oct 2014 20:33:54 -0400
Content-Disposition: inline
In-Reply-To: <CAHA+R7PxvW6umBJMxGk0h=ht4RhoDRcrxr5WSTEUBa80TxU5GQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 24, 2014 at 03:17:41PM -0700, Cong Wang wrote:
> On Fri, Oct 24, 2014 at 2:45 PM, Patrick McHardy <kaber@trash.net> wrote:
> >> >
> >> > I would argue that the qdisc_destroy() call in qdisc_create_dflt()
> >> > is wrong, it should instead free the qdisc and release the module
> >> > reference manually as done in qdisc_create().
> >> >
> >> > qdisc_destroy() should only be called for fully initialized qdiscs.
> >>
> >> Probably, but at least ->destroy() should be called, looking at
> >> those calling qdisc_watchdog_init(), they are supposed to call
> >> qdisc_watchdog_cancel() when >init() fails after that.
> >
> > In which cases does it actually fail after that? Usually this is
> > called once initialization is complete.
> 
> How about tbf_change() in tbf_init()? If tbf_change() fails,
> watchdog is still there if we don't call ->destroy(). Yes,
> I know the timer is started, the point is we do miss something
> clean up, even trivial.
> 
> tbf is not the only one who calls xxx_change() in xxx_init().

Then these are bugs. On failure we exit with the same state as we
entered, there's nothing new about that.

This in fact is *no* bug though since qdisc_watchdog_init() merely
initializes the timer and doesn't require cleanup.

> > Its simply symetrical, as everywhere else in the kernel. If a sub-init
> > funtion fails, it should clean up and return an error. We don't
> > destroy things we've never successfully initialized, they're supposed
> > to clean up after themselves.
> 
> Most (if not all) ->destroy() are able to clean partially initialized qdisc,
> I don't see why it  could be a problem here.
> 
> We don't have to keep with other kernel subsystem as long as it makes
> sense, net_sched subsystem is pretty much self-contained.

Its about having a sane API.
