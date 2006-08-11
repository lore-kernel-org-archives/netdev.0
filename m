From: "Paul E. McKenney" <paulmck@us.ibm.com>
Subject: Re: [PATCH 4/5] net: socket family using RCU
Date: Thu, 10 Aug 2006 17:46:39 -0700
Message-ID: <20060811004639.GO1298@us.ibm.com>
References: <20060809183138.332023530@localhost.localdomain> <20060809183349.528294134@localhost.localdomain> <20060810183658.GA1771@us.ibm.com> <20060810132827.481e8a6b@localhost.localdomain>
Reply-To: paulmck@us.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	akpm@osdl.org, josht@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:32230 "EHLO e4.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S932389AbWHKAp5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Aug 2006 20:45:57 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e4.ny.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k7B0juCc018370
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Thu, 10 Aug 2006 20:45:56 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay02.pok.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id k7B0juvS290274
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 10 Aug 2006 20:45:56 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k7B0jtYM016181
	for <netdev@vger.kernel.org>; Thu, 10 Aug 2006 20:45:56 -0400
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20060810132827.481e8a6b@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 10, 2006 at 01:28:27PM -0700, Stephen Hemminger wrote:
> >
> >On Wed, Aug 09, 2006 at 11:31:42AM -0700, Stephen Hemminger wrote:
> >> Replace the gross custom locking done in socket code for net_family[]
> >> with simple RCU usage. Some reordering necessary to avoid sleep
> >> issues with sock_alloc.
> >
> >Definitely a good use of RCU from a read-intensive standpoint -- does
> >anyone other than Linux-kernel networking developers change the elements
> >of the net_family[] array except at boot and shutdown?  ;-)
> >
> >Some comments included below.  Looks good, but one question about
> >things like atalk_create() being able to sleep and a place or two
> >where a comment would be good.
> >
> 
> ...
> 
> >>  
> >> +	/*
> >> +	 *	Allocate the socket and allow the family to set things up. if
> >> +	 *	the protocol is 0, the family is instructed to select an appropriate
> >> +	 *	default.
> >> +	 */
> >> +	sock = sock_alloc();
> >> +	if (!sock) {
> >> +		printk(KERN_WARNING "socket: no more sockets\n");
> >> +		return -ENFILE;	/* Not exactly a match, but its the
> >> +				   closest posix thing */
> >> +	}
> >> +
> >> +	sock->type = type;
> >> +
> >>  #if defined(CONFIG_KMOD)
> >>  	/* Attempt to load a protocol module if the find failed.
> >>  	 *
> >> @@ -1166,70 +1138,59 @@
> >>  	 * requested real, full-featured networking support upon configuration.
> >>  	 * Otherwise module support will break!
> >>  	 */
> >> -	if (net_families[family] == NULL) {
> >> +	if (net_families[family] == NULL)
> >>  		request_module("net-pf-%d", family);
> >
> >OK, I'll bite...
> >
> >What happens if the module is not present?  Or is this what the
> >"Otherwise module support will break" comment is getting at?
> 
> request_module loads the module (and blocks). One would
> expect that the module loaded would set net_families[] via
> sock_register, so later reference would succeed. Comment is
> historical since intention was to make base socket code itself modular
> which never was done, and is probably a bad idea to even consider.
> 
> If module is not present, then net_families[] will still be NULL.

Got it!

> >Also, this reference to "net_families[family]" is done without
> >rcu_dereference() and without any clear update-side lock.  This
> >just happens to be OK, since we are only testing for NULL, but
> >should at least have a comment.
> 
> >> -	}
> >>  #endif
> >>  
> >> -	net_family_read_lock();
> >> -	if (net_families[family] == NULL) {
> >> -		err = -EAFNOSUPPORT;
> >> -		goto out;
> >> -	}
> >> -
> >> -/*
> >> - *	Allocate the socket and allow the family to set things up. if
> >> - *	the protocol is 0, the family is instructed to select an appropriate
> >> - *	default.
> >> - */
> >> -
> >> -	if (!(sock = sock_alloc())) {
> >> -		printk(KERN_WARNING "socket: no more sockets\n");
> >> -		err = -ENFILE;	/* Not exactly a match, but its the
> >> -				   closest posix thing */
> >> -		goto out;
> >> -	}
> >> -
> >> -	sock->type = type;
> >> +	rcu_read_lock();
> >> +	pf = rcu_dereference(net_families[family]);
> >
> >OK, so the elements of the net_families array are protected by RCU.
> >All references should either be under rcu_read_lock() and accessed
> >via rcu_dereference() or under the update-side lock, whatever that
> >might be.
> >
> 
> Yes, the net_family_lock

Good.

> >>  
> >> -/*
> >> +/**
> >> + *	sock_unregister - remove a protocol handler
> >> + *	@family: protocol family to remove
> >> + *
> >>   *	This function is called by a protocol handler that wants to
> >>   *	remove its address family, and have it unlinked from the
> >> - *	SOCKET module.
> >> + *	new socket creation.
> >> + *
> >> + *	If protocol handler is a module, then it can use module reference
> >> + *	counts to protect against new references. If protocol handler is not
> >> + *	a module then it needs to provide its own protection in
> >> + *	the ops->create routine.
> >>   */
> >> -
> >>  int sock_unregister(int family)
> >>  {
> >>  	if (family < 0 || family >= NPROTO)
> >> -		return -1;
> >> +		return -EINVAL;
> >>  
> >> -	net_family_write_lock();
> >> +	spin_lock(&net_family_lock);
> >>  	net_families[family] = NULL;
> >
> >And this one is covered by net_families_lock, so we are set, since this
> >is the last one.
> >
> >> -	net_family_write_unlock();
> >> +	spin_unlock(&net_family_lock);
> >> +
> >> +	synchronize_rcu();
> >
> >OK, and the caller is presumably going to free up whatever needs to be
> >freed.
> >
> >Or, if nothing need be freed, beyond this point, we know that all
> >non-sleeping code paths through any of the net_protocol_family
> >functions have completed.
> >
> >(So, are all of the functions non-sleeping, or do we care?  The
> >definition of net_protocol_family in include/linux/net.h doesn't say
> >that they need to be non-sleeping...)
> >
> >atalk_create() can potentially sleep in the following line of code:
> >
> >	sk = sk_alloc(PF_APPLETALK, GFP_KERNEL, &ddp_proto, 1);
> 
> The module reference counts are used to prevent that. Since
> appletalk module can't be unloaded until there are no more appletalk
> sockets open (ie ref count of appletalk module is zero). To prevent
> new references there is a call to try_module_get() before the
> net_families[family]->create() call. This happens inside
> rcu_read_lock.
> 
> >What prevents atalk_create() running concurrently with sock_unregister()?
> 
> Module ref counts. I didn't want to start ref counting the net_families
> because that would cause another atomic op, and would penalize the normal
> case of non-modular IPV4 (and non-moduler IPV6).

OK.

> >(One possible reason is that ->create is only called in __sock_create(),
> >and that there is something preventing sock_unregister() from being called
> >before __sock_create() returns -- but I must defer to people who understand
> >networking better than do I.)
> 
> That is why I added a comment to sock_unregister() describing how for the
> normal case of protocol as module, this is safe. But if protocol wants
> to call sock_unregister() other times it needs to do it's own ref counting.
> 
> There are a couple of calls to sock_unregister() from module init routines,
> but these are in benign error unwind cases. The code in these cases
> could be reorganized to do sock_register() last during initilization,
> but it hardly matters.

Fair enough!

							Thanx, Paul
