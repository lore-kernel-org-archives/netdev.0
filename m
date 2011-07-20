From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: [PATCH net-next]vhost: fix condition check for # of
 outstanding dma buffers
Date: Wed, 20 Jul 2011 08:43:09 -0700
Message-ID: <1311176589.8573.33.camel@localhost.localdomain>
References: <1311100678.8573.16.camel@localhost.localdomain>
	 <20110719190945.GB8667@redhat.com>
	 <1311108985.8573.30.camel@localhost.localdomain>
	 <20110720102831.GA5164@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	jasowang@redhat.com
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:39085 "EHLO e5.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751712Ab1GTPnZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jul 2011 11:43:25 -0400
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by e5.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p6KFEIM3026122
	for <netdev@vger.kernel.org>; Wed, 20 Jul 2011 11:14:18 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p6KFhEeb108258
	for <netdev@vger.kernel.org>; Wed, 20 Jul 2011 11:43:14 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p6KBh1bl019297
	for <netdev@vger.kernel.org>; Wed, 20 Jul 2011 08:43:01 -0300
In-Reply-To: <20110720102831.GA5164@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-07-20 at 13:28 +0300, Michael S. Tsirkin wrote:
> On Tue, Jul 19, 2011 at 01:56:25PM -0700, Shirley Ma wrote:
> > On Tue, 2011-07-19 at 22:09 +0300, Michael S. Tsirkin wrote:
> > > On Tue, Jul 19, 2011 at 11:37:58AM -0700, Shirley Ma wrote:
> > > > Signed-off-by: Shirley Ma <xma@us.ibm.com>
> > > > ---
> > > > 
> > > >  drivers/vhost/net.c |    6 ++++--
> > > >  1 files changed, 4 insertions(+), 2 deletions(-)
> > > > 
> > > > diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
> > > > index 70ac604..83cb738 100644
> > > > --- a/drivers/vhost/net.c
> > > > +++ b/drivers/vhost/net.c
> > > > @@ -189,8 +189,10 @@ static void handle_tx(struct vhost_net
> *net)
> > > >                               break;
> > > >                       }
> > > >                       /* If more outstanding DMAs, queue the
> work */
> > > > -                     if (unlikely(vq->upend_idx - vq->done_idx
> >
> > > > -                                  VHOST_MAX_PEND)) {
> > > > +                     if (unlikely((vq->upend_idx - vq->done_idx
> >
> > > > +                                     VHOST_MAX_PEND) ||
> > > > +                                  (vq->upend_idx - vq->done_idx
> >
> > > > +                                      VHOST_MAX_PEND -
> > > UIO_MAXIOV))) {
> > > 
> > > Could you please explain why this makes sense please?
> > > VHOST_MAX_PEND is 128 UIO_MAXIOV is 1024 so
> > > the result is negative?
> > 
> > I thought it is equal to:
> > 
> > if (vq->upend_idx > vq->done_idx) 
> >       check vq->upend_idx - vq->done_idx > VHOST_MAX_PEND
> > if (vq->upend_idx < vq->done_idx)
> >       check vq->upend_idx + UIO_MAXIOV - vq->done_idx >
> VHOST_MAX_PEND
> >       
> 
> Check it out: upend_idx == done_idx == 0 does not satisfy the
> above conditions but does trigger in your code, right?

We don't hit upend_idx == done_idx == 0. Only upend_idx == done_idx ==
UIO_MAXIOV could happen if the lower device has issue and never DMA any
packets out.

> Better keep it simple. Maybe:
> 
>         if (unlikely(vq->upend_idx - vq->done_idx > VHOST_MAX_PEND) ||
>                 (unlikely(vq->upend_idx < vq->done_idx) &&
>                 unlikely(vq->upend_idx + UIO_MAXIOV - vq->done_idx >
>                          VHOST_MAX_PEND)))
> 
> ?
> 
> Also, please add commit log documenting what does the patch
> fix: something like:
>         'the test for # of outstanding buffers returned
>          incorrect results when due to wrap around,
>          upend_idx < done_idx'?

Sure, will modify it and resubmit.

> > > I thought upend_idx - done_idx is exactly the number
> > > of buffers, so once we get too many we stop until
> > > one gets freed?
> > 
> > They are index, so in vhost zerocopy callback, we can get the idx
> right
> > away.
> > 
> > > 
> > > >                               tx_poll_start(net, sock);
> > > >                               set_bit(SOCK_ASYNC_NOSPACE,
> > > &sock->flags);
> > > >                               break;
> > > > 

Thanks
Shirley

