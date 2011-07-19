From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: [PATCH net-next]vhost: fix condition check for # of
 outstanding dma buffers
Date: Tue, 19 Jul 2011 13:56:25 -0700
Message-ID: <1311108985.8573.30.camel@localhost.localdomain>
References: <1311100678.8573.16.camel@localhost.localdomain>
	 <20110719190945.GB8667@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	jasowang@redhat.com
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:49802 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751924Ab1GSU4d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jul 2011 16:56:33 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e33.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p6JKmnDG011621
	for <netdev@vger.kernel.org>; Tue, 19 Jul 2011 14:48:49 -0600
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id p6JKuRkD189388
	for <netdev@vger.kernel.org>; Tue, 19 Jul 2011 14:56:28 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p6JKuR89013967
	for <netdev@vger.kernel.org>; Tue, 19 Jul 2011 14:56:27 -0600
In-Reply-To: <20110719190945.GB8667@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-07-19 at 22:09 +0300, Michael S. Tsirkin wrote:
> On Tue, Jul 19, 2011 at 11:37:58AM -0700, Shirley Ma wrote:
> > Signed-off-by: Shirley Ma <xma@us.ibm.com>
> > ---
> > 
> >  drivers/vhost/net.c |    6 ++++--
> >  1 files changed, 4 insertions(+), 2 deletions(-)
> > 
> > diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
> > index 70ac604..83cb738 100644
> > --- a/drivers/vhost/net.c
> > +++ b/drivers/vhost/net.c
> > @@ -189,8 +189,10 @@ static void handle_tx(struct vhost_net *net)
> >                               break;
> >                       }
> >                       /* If more outstanding DMAs, queue the work */
> > -                     if (unlikely(vq->upend_idx - vq->done_idx >
> > -                                  VHOST_MAX_PEND)) {
> > +                     if (unlikely((vq->upend_idx - vq->done_idx >
> > +                                     VHOST_MAX_PEND) ||
> > +                                  (vq->upend_idx - vq->done_idx >
> > +                                      VHOST_MAX_PEND -
> UIO_MAXIOV))) {
> 
> Could you please explain why this makes sense please?
> VHOST_MAX_PEND is 128 UIO_MAXIOV is 1024 so
> the result is negative?

I thought it is equal to:

if (vq->upend_idx > vq->done_idx) 
	check vq->upend_idx - vq->done_idx > VHOST_MAX_PEND
if (vq->upend_idx < vq->done_idx)
	check vq->upend_idx + UIO_MAXIOV - vq->done_idx > VHOST_MAX_PEND
	

> I thought upend_idx - done_idx is exactly the number
> of buffers, so once we get too many we stop until
> one gets freed?

They are index, so in vhost zerocopy callback, we can get the idx right
away.

> 
> >                               tx_poll_start(net, sock);
> >                               set_bit(SOCK_ASYNC_NOSPACE,
> &sock->flags);
> >                               break;
> > 

