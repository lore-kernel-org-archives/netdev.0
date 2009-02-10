From: Karsten Keil <kkeil@suse.de>
Subject: Re: [RFC] Suspicious bug in module refcounting
Date: Tue, 10 Feb 2009 04:42:50 +0100
Message-ID: <20090210034250.GA9938@pingi.kke.suse.de>
References: <20090203134721.GA11069@pingi.kke.suse.de> <200902041418.09630.rusty@rustcorp.com.au> <20090209151830.GC6018@dhcp35.suse.cz> <200902101345.08580.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michal Hocko <mhocko@suse.cz>,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org,
	richard kennedy <richard@rsk.demon.co.uk>,
	Dan Williams <dan.j.williams@intel.com>,
	Dmitry Torokhov <dmitry.torokhov@gmail.com>,
	Russell King <rmk+kernel@arm.linux.org.uk>,
	dwmw2@infradead.org, Scott Wood <scottwood@freescale.com>,
	netdev@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:39913 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752183AbZBJDmy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Feb 2009 22:42:54 -0500
Content-Disposition: inline
In-Reply-To: <200902101345.08580.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 10, 2009 at 01:45:07PM +1030, Rusty Russell wrote:
> On Tuesday 10 February 2009 01:48:31 Michal Hocko wrote:
> > Based on this change, would it make sense to update sys_accept to change
> > __module_get to try_module_get like in the following patch?
> 
> I don't think so:
> 
> >  	/*
> > -	 * We don't need try_module_get here, as the listening socket (sock)
> > -	 * has the protocol module (sock->ops->owner) held.
> > +	 * Socket's owner cannot be in unloading path because there
> > +	 * must be at least one listening reference
> >  	 */
> > -	__module_get(newsock->ops->owner);
> > +	if (unlikely(!try_module_get(newsock->ops->owner)))
> > +		BUG();
> 
> rmmod --wait can make try_module_get fail even if the reference count isn't
> zero.  But in this case, we should return an error from the accept call;
> presumably the admin really doesn't want us to keep using the module...
> 

I was thinking about this for a while too, but I did not find a valid
error value for this case, the current accept syscall API only allow few
error codes and I think we should not break this.
Maybe -ECONNABORTED  could be used but it doesn't fit 100% and applications
may interpret this in a wrong way.
If the admin decide to remove the module, he should also stop the services
needing this resource. In this case  the effect of __module_get(newsock->ops->owner);
is ok, if the service is still in use, the module will not be removed and
still does the expected work, if all sockets are closed the module refcount
will reach zero and the module will go away.

-- 
Karsten Keil
SuSE Labs
