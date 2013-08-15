From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [patch] tun: signedness bug in tun_get_user()
Date: Thu, 15 Aug 2013 17:58:40 +0300
Message-ID: <20130815145840.GA8889@redhat.com>
References: <20130815125257.GA16932@elgon.mountain>
 <20130815140449.GA8064@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Jason Wang <jasowang@redhat.com>,
	Eric Dumazet <edumazet@google.com>,
	Neil Horman <nhorman@tuxdriver.com>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53292 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757038Ab3HOO5L (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Aug 2013 10:57:11 -0400
Content-Disposition: inline
In-Reply-To: <20130815140449.GA8064@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 15, 2013 at 05:04:49PM +0300, Michael S. Tsirkin wrote:
> On Thu, Aug 15, 2013 at 03:52:57PM +0300, Dan Carpenter wrote:
> > The recent fix d9bf5f1309 "tun: compare with 0 instead of total_len" is
> > not totally correct.  Because "len" and "sizeof()" are size_t type, that
> > means they are never less than zero.
> > 
> > Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> 
> Acked-by: Michael S. Tsirkin <mst@redhat.com>

Alternatively how about we revert the original patch?
This is not the only issue it introduced and it doesn't
actually fix any bugs.

> > 
> > diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> > index af987f0..7ed13cc 100644
> > --- a/drivers/net/tun.c
> > +++ b/drivers/net/tun.c
> > @@ -977,8 +977,9 @@ static ssize_t tun_get_user(struct tun_struct *tun, struct tun_file *tfile,
> >  	u32 rxhash;
> >  
> >  	if (!(tun->flags & TUN_NO_PI)) {
> > -		if ((len -= sizeof(pi)) < 0)
> > +		if (len < sizeof(pi))
> >  			return -EINVAL;
> > +		len -= sizeof(pi);
> >  
> >  		if (memcpy_fromiovecend((void *)&pi, iv, 0, sizeof(pi)))
> >  			return -EFAULT;
> > @@ -986,8 +987,9 @@ static ssize_t tun_get_user(struct tun_struct *tun, struct tun_file *tfile,
> >  	}
> >  
> >  	if (tun->flags & TUN_VNET_HDR) {
> > -		if ((len -= tun->vnet_hdr_sz) < 0)
> > +		if (len < tun->vnet_hdr_sz)
> >  			return -EINVAL;
> > +		len -= tun->vnet_hdr_sz;
> >  
> >  		if (memcpy_fromiovecend((void *)&gso, iv, offset, sizeof(gso)))
> >  			return -EFAULT;
