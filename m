From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH net] net/sched: Fix use of wild pointer in mq_destroy()
 when qdisc_alloc fail
Date: Sat, 25 Oct 2014 02:33:52 +0100
Message-ID: <20141025013352.GE11289@acer.localdomain>
References: <OF7A403C69.2C35464E-ON48257D7B.002E24AA-48257D7B.002F2A62@zte.com.cn>
 <544A913A.1060100@gmail.com>
 <CAHA+R7P+nGXc93e_-u5Bvmr5Ri8CCg9FAgc+R7fJT7mJ5sBFwQ@mail.gmail.com>
 <20141024191418.GA8842@acer.localdomain>
 <CAHA+R7PDxYeVuQZz=VSci8_7sZ9smb5c59ivOS=B6GemJwtcCg@mail.gmail.com>
 <20141024214511.GA10290@acer.localdomain>
 <CAHA+R7PxvW6umBJMxGk0h=ht4RhoDRcrxr5WSTEUBa80TxU5GQ@mail.gmail.com>
 <20141025003348.GA11289@acer.localdomain>
 <CAHA+R7MW-kP0uO2+00+pbx1y=LQynLWy9diznccY69+8nZ5mwQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: John Fastabend <john.fastabend@gmail.com>,
	Wang Bo <wang.bo116@zte.com.cn>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, cui.yunfeng@zte.com.cn
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:43287 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756014AbaJYBd6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Oct 2014 21:33:58 -0400
Content-Disposition: inline
In-Reply-To: <CAHA+R7MW-kP0uO2+00+pbx1y=LQynLWy9diznccY69+8nZ5mwQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 24, 2014 at 05:57:59PM -0700, Cong Wang wrote:
> On Fri, Oct 24, 2014 at 5:33 PM, Patrick McHardy <kaber@trash.net> wrote:
> >
> > Its about having a sane API.
> 
> I don't see why calling ->destroy() on failure is not sane in qdisc case.
> I never want to argue general case.

Because it makes things more complicated. You need to keep track of what
was actually initialized since you can't assume a consistent state in
->destroy() anymore. If ->init() fails, it knows where it failed,
->destroy() can't know that.

Look at htb_destroy() for an example. It starts with

	cancel_work_sync(&q->work);

Was that actually initialized and can be cancled? You don't know.
Next comes

	qdisc_watchdog_cancel(&q->watchdog);

Same here, if the error happened before it was initialized, crash.

These are just the first two lines. You get the problem.
