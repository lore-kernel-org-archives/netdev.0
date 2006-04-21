From: "Andy Gospodarek" <andy@greyhouse.net>
Subject: Re: e1000_down and tx_timeout worker race cleaning the transmit buffers
Date: Fri, 21 Apr 2006 16:01:52 -0400
Message-ID: <bdfc5d6e0604211301k682b35d1r52a52cd3fec80ddc@mail.gmail.com>
References: <1145578214.3195.6.camel@rh4>
	 <E1FWlWa-0007hN-00@gondolin.me.apana.org.au>
	 <20060421024024.GA29644@gondor.apana.org.au>
	 <1145582676.3195.18.camel@rh4>
	 <20060421132758.GA26161@gospo.rdu.redhat.com>
	 <1145633287.3194.10.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "Herbert Xu" <herbert@gondor.apana.org.au>, shawvrana@gmail.com,
	netdev@vger.kernel.org, auke-jan.h.kok@intel.com,
	davem@davemloft.net, jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0102.google.com ([64.233.162.197]:41936 "EHLO
	nz-out-0102.google.com") by vger.kernel.org with ESMTP
	id S1751347AbWDUUBx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2006 16:01:53 -0400
Received: by nz-out-0102.google.com with SMTP id 40so481075nzk
        for <netdev@vger.kernel.org>; Fri, 21 Apr 2006 13:01:52 -0700 (PDT)
To: "Michael Chan" <mchan@broadcom.com>
In-Reply-To: <1145633287.3194.10.camel@rh4>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 4/21/06, Michael Chan <mchan@broadcom.com> wrote:
> On Fri, 2006-04-21 at 09:27 -0400, Andy Gospodarek wrote:
>
> >
> > Isn't the only possibility for a linkwatch deadlock when the
> > __LINK_STATE_LINKWATCH_PENDING but is set in dev->state?
>
> This device that you're about to close may be on the linkwatch list, or
> other devices may also be on the linkwatch list. As long as
> linkwatch_event is in front of your driver's task on the same workqueue,
> it will deadlock.

My thought was that you would only try and service the linkwatch queue
if the device you are closing has the __LINK_STATE_LINKWATCH_PENDING
bit set in that device's dev->state.    I agree there still could be
problems with ordering of events on the workqueue, so it may make
sense to use a separate workqueue for linkwatch events if we can't
come up with a more consistent way to call flush_scheduled_work across
all drivers.

I just hate to see extra resources used to solve problems that good
coding can solve (not that my suggestion is necessarily a 'good' one),
so I was trying to think of a way to resolve this without explicitly
adding another workqueue.


>
> >
> > Off the top of my head...
> >
> > Would it be interesting to change the calls for flush_scheduled_work()
> > to a new function net_flush_scheduled_work() with the intent on
> > eventually creating new a new work queue but temporarily just checking
> > to make sure there are no linkwatch events pending and if there are
> > allowing them to run first before calling flush_scheduled_work()?
> >
>
> Using the same workqueue and holding the rtnl_lock, I'm not sure how you
> can let linkwatch_event run first without deadlocking.
>
>

You wouldn't call linkwatch_event, you would call linkwatch_run_queue
(with special care taken to make sure you take the rtnl_lock if
needed).  See a similar example for calling linkwatch_run_queue in
netdev_wait_allrefs.
