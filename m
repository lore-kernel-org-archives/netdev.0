From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH net-next] net: core: decouple ifalias get/set from rtnl
 lock
Date: Mon, 2 Oct 2017 11:22:57 +0200
Message-ID: <20171002092257.GA30423@breakpoint.cc>
References: <20170929112150.7424-1-fw@strlen.de>
 <20171001.224644.903150013683866978.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: fw@strlen.de, netdev@vger.kernel.org, edumazet@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:53398 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750903AbdJBJ0i (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 2 Oct 2017 05:26:38 -0400
Content-Disposition: inline
In-Reply-To: <20171001.224644.903150013683866978.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote:
> From: Florian Westphal <fw@strlen.de>
> Date: Fri, 29 Sep 2017 13:21:50 +0200
> 
> > @@ -1488,7 +1484,7 @@ static void netdev_release(struct device *d)
> >  
> >  	BUG_ON(dev->reg_state != NETREG_RELEASED);
> >  
> > -	kfree(dev->ifalias);
> > +	kfree(rcu_access_pointer(dev->ifalias));
> >  	netdev_freemem(dev);
> >  }
> >  
> 
> "kfree_rcu()" at least?
> 
> If the deal is that you don't need to do and RCU free because
> netdevice objects disappear synchronously, and you can therefore prove
> that no RCU based async access can occur to dev->ifalias, then you
> need to add a comment here.

Ok, I will add a comment.

netdev_release gets called via kobject_put() if this was last reference
to the device. At that point the device has already been removed from
all lists (and private destructor was invoked too).

Also, netdev_freemem frees the net_device memory immediately
so no other cpu is allowed to use dev at this point.
