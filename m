From: Jarod Wilson <jarod@redhat.com>
Subject: Re: Minimum MTU Mess
Date: Wed, 7 Sep 2016 19:44:51 -0400
Message-ID: <20160907234451.GZ33916@redhat.com>
References: <20160902170742.GA17677@redhat.com>
 <20160906.165529.496766310703537877.davem@davemloft.net>
 <20160907195356.GX33916@redhat.com>
 <20160907133535.2cfac7bc@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f179.google.com ([209.85.161.179]:35522 "EHLO
        mail-yw0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751824AbcIGXoz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Sep 2016 19:44:55 -0400
Received: by mail-yw0-f179.google.com with SMTP id j1so18830975ywb.2
        for <netdev@vger.kernel.org>; Wed, 07 Sep 2016 16:44:54 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160907133535.2cfac7bc@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 07, 2016 at 01:35:35PM -0700, Stephen Hemminger wrote:
> On Wed, 7 Sep 2016 15:53:56 -0400
> Jarod Wilson <jarod@redhat.com> wrote:
> 
> > --- a/net/core/dev.c
> > +++ b/net/core/dev.c
> > @@ -6466,9 +6466,17 @@ int dev_set_mtu(struct net_device *dev, int new_mtu)
> >  	if (new_mtu == dev->mtu)
> >  		return 0;
> >  
> > -	/*	MTU must be positive.	 */
> > -	if (new_mtu < 0)
> > +	if (new_mtu < dev->min_mtu) {
> > +		netdev_err(dev, "Invalid MTU %d requested, hw min %d\n",
> > +			   new_mtu, dev->min_mtu);
> >  		return -EINVAL;
> > +	}
> > +
> > +	if (new_mtu > dev->max_mtu) {
> > +		netdev_err(dev, "Invalid MTU %d requested, hw max %d\n",
> > +			   new_mtu, dev->min_mtu);
> > +		return -EINVAL;
> > +	}
> >  
> 
> Maybe don't log something that can be triggered from a user program.
> Or at least rate limit it.

Yeah, I was a little bit on the fence on whether to log anything, make it
netdev_err, netdev_dbg, or what. Quite a few drivers have a netdev_err for
failed MTU changes, while others also have netdev_info spew for successful
MTU changes. Maybe a rate-limited netdev_err is the way to go here.

-- 
Jarod Wilson
jarod@redhat.com
