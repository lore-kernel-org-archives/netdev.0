From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PATCH] Add IPv6 support to TCP SYN cookies
Date: Thu, 7 Feb 2008 10:24:15 +0300
Message-ID: <20080207072415.GA13782@2ka.mipt.ru>
References: <20080206091353.GA12927@2ka.mipt.ru> <47a9fb13.01538c0a.3b80.ffff9328@mx.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Andi Kleen <andi@firstfloor.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Glenn Griffin <ggriffin.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:45159 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754537AbYBGHY5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Feb 2008 02:24:57 -0500
Content-Disposition: inline
In-Reply-To: <47a9fb13.01538c0a.3b80.ffff9328@mx.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 06, 2008 at 10:30:24AM -0800, Glenn Griffin (ggriffin.kernel@gmail.com) wrote:
> > > +static u32 cookie_hash(struct in6_addr *saddr, struct in6_addr *daddr,
> > > +		       __be16 sport, __be16 dport, u32 count, int c)
> > > +{
> > > +	__u32 tmp[16 + 5 + SHA_WORKSPACE_WORDS];
> > 
> > This huge buffer should not be allocated on stack.
> 
> I can replace it will a kmalloc, but for my benefit what's the practical
> size we try and limit the stack to?  It seemed at first glance to me
> that 404 bytes plus the arguments, etc. was not such a large buffer for
> a non-recursive function.  Plus the alternative with a kmalloc requires

Well, maybe for connection establishment path it is not, but it is
absolutely the case in the sending and sometimes receiving pathes for 4k
stacks. The main problem is that bugs which happen because of stack
overflow are so much obscure, that it is virtually impossible to detect
where overflow happend. 'Debug stack overflow' somehow does not help to
detect it.

Usually there is about 1-1.5 kb of free stack for each process, so this
change will cut one third of the free stack, getting into account that
something can store ipv6 addresses on stack too, this can end up badly.

> propogating the possible error status back up to tcp_ipv6.c in the event
> we are unable to allocate enough memory, so it can simply drop the
> connection.  Not an impossible task by any means but it does
> significantly complicate things and I would like to know it's worth the
> effort.  Also would it be worth it to provide a supplemental patch for
> the ipv4 implementation as it allocates the same buffer?

One can reorganize syncookie support to work with request hash tables
too, so that we could allocate per hash-bucket space and use it as a
scratchpad for cookies.

> --Glenn

-- 
	Evgeniy Polyakov
