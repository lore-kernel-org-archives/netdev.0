From: Jarod Wilson <jarod@redhat.com>
Subject: Re: Minimum MTU Mess
Date: Wed, 7 Sep 2016 19:43:06 -0400
Message-ID: <20160907234306.GY33916@redhat.com>
References: <20160902170742.GA17677@redhat.com>
 <20160906.165529.496766310703537877.davem@davemloft.net>
 <20160907195356.GX33916@redhat.com>
 <20160907203112.GA26445@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f173.google.com ([209.85.161.173]:34379 "EHLO
        mail-yw0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751098AbcIGXnK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Sep 2016 19:43:10 -0400
Received: by mail-yw0-f173.google.com with SMTP id g192so18976232ywh.1
        for <netdev@vger.kernel.org>; Wed, 07 Sep 2016 16:43:10 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160907203112.GA26445@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 07, 2016 at 10:31:12PM +0200, Andrew Lunn wrote:
> Hi Jarod
> 
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
> 
> I doubt you can make such a big change like this in one go. Can you
> really guarantee all interfaces, of what ever type, will have some
> value for dev->min_mtu and dev->max_mtu? What may fly is something
> more like:
> 
> > +	if (dev->max_mtu && new_mtu > dev->max_mtu) {
> > +		netdev_err(dev, "Invalid MTU %d requested, hw max %d\n",
> > +			   new_mtu, dev->min_mtu);
> > +		return -EINVAL;
> > +	}
> 
> Maybe in a few cycles you can add a WARN_ON(!dev->max_mtu), and a few
> cycles after that go with (new_mtu > dev->max_mtu).

My local tree actually has if (dev->max_mtu > 0 && new_mtu > dev->max_mtu)
since just after I'd sent my mail for exactly that reason, though looking
at alloc_netdev_mqs(), it does seem we're at least guaranteed the value
will be 0 if not otherwise initialized, so your version looks perfectly
fine, and in the min_mtu case, without any additional handling, things
behave exactly as they did before. This is definitely going to require a
few passes... (Working my way through every driver with an ndo_change_mtu
wired up right now to see just how crazy this might get).

-- 
Jarod Wilson
jarod@redhat.com
