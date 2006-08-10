From: "Paul E. McKenney" <paulmck@us.ibm.com>
Subject: Re: [PATCH 4/5] net: socket family using RCU
Date: Thu, 10 Aug 2006 11:36:58 -0700
Message-ID: <20060810183658.GA1771@us.ibm.com>
References: <20060809183138.332023530@localhost.localdomain> <20060809183349.528294134@localhost.localdomain>
Reply-To: paulmck@us.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	akpm@osdl.org, josht@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:13779 "EHLO e1.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S1030508AbWHJSgQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Aug 2006 14:36:16 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e1.ny.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k7AIaFhl013522
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Thu, 10 Aug 2006 14:36:16 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id k7AIaFa9276338
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 10 Aug 2006 14:36:15 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k7AIaE1c027789
	for <netdev@vger.kernel.org>; Thu, 10 Aug 2006 14:36:15 -0400
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20060809183349.528294134@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 09, 2006 at 11:31:42AM -0700, Stephen Hemminger wrote:
> Replace the gross custom locking done in socket code for net_family[]
> with simple RCU usage. Some reordering necessary to avoid sleep
> issues with sock_alloc.

Definitely a good use of RCU from a read-intensive standpoint -- does
anyone other than Linux-kernel networking developers change the elements
of the net_family[] array except at boot and shutdown?  ;-)

Some comments included below.  Looks good, but one question about
things like atalk_create() being able to sleep and a place or two
where a comment would be good.

							Thanx, Paul

> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
> 
> ---
>  net/socket.c |  171 +++++++++++++++++++++++++----------------------------------
>  1 file changed, 74 insertions(+), 97 deletions(-)
> 
> --- net-2.6.orig/net/socket.c	2006-08-09 11:19:08.000000000 -0700
> +++ net-2.6/net/socket.c	2006-08-09 11:19:22.000000000 -0700
> @@ -59,11 +59,11 @@
>   */
>  
>  #include <linux/mm.h>
> -#include <linux/smp_lock.h>
>  #include <linux/socket.h>
>  #include <linux/file.h>
>  #include <linux/net.h>
>  #include <linux/interrupt.h>
> +#include <linux/rcupdate.h>
>  #include <linux/netdevice.h>
>  #include <linux/proc_fs.h>
>  #include <linux/seq_file.h>
> @@ -146,51 +146,8 @@
>   *	The protocol list. Each protocol is registered in here.
>   */
>  
> -static struct net_proto_family *net_families[NPROTO];
> -
> -#if defined(CONFIG_SMP) || defined(CONFIG_PREEMPT)
> -static atomic_t net_family_lockct = ATOMIC_INIT(0);
>  static DEFINE_SPINLOCK(net_family_lock);
> -
> -/* The strategy is: modifications net_family vector are short, do not
> -   sleep and veeery rare, but read access should be free of any exclusive
> -   locks.
> - */
> -
> -static void net_family_write_lock(void)
> -{
> -	spin_lock(&net_family_lock);
> -	while (atomic_read(&net_family_lockct) != 0) {
> -		spin_unlock(&net_family_lock);
> -
> -		yield();
> -
> -		spin_lock(&net_family_lock);
> -	}
> -}
> -
> -static __inline__ void net_family_write_unlock(void)
> -{
> -	spin_unlock(&net_family_lock);
> -}
> -
> -static __inline__ void net_family_read_lock(void)
> -{
> -	atomic_inc(&net_family_lockct);
> -	spin_unlock_wait(&net_family_lock);
> -}
> -
> -static __inline__ void net_family_read_unlock(void)
> -{
> -	atomic_dec(&net_family_lockct);
> -}
> -
> -#else
> -#define net_family_write_lock() do { } while(0)
> -#define net_family_write_unlock() do { } while(0)
> -#define net_family_read_lock() do { } while(0)
> -#define net_family_read_unlock() do { } while(0)
> -#endif
> +static const struct net_proto_family *net_families[NPROTO];
>  
>  /*
>   *	Statistics counters of the socket lists
> @@ -1131,6 +1088,7 @@
>  {
>  	int err;
>  	struct socket *sock;
> +	const struct net_proto_family *pf;
>  
>  	/*
>  	 *      Check protocol is in range
> @@ -1159,6 +1117,20 @@
>  	if (err)
>  		return err;
>  
> +	/*
> +	 *	Allocate the socket and allow the family to set things up. if
> +	 *	the protocol is 0, the family is instructed to select an appropriate
> +	 *	default.
> +	 */
> +	sock = sock_alloc();
> +	if (!sock) {
> +		printk(KERN_WARNING "socket: no more sockets\n");
> +		return -ENFILE;	/* Not exactly a match, but its the
> +				   closest posix thing */
> +	}
> +
> +	sock->type = type;
> +
>  #if defined(CONFIG_KMOD)
>  	/* Attempt to load a protocol module if the find failed.
>  	 *
> @@ -1166,70 +1138,59 @@
>  	 * requested real, full-featured networking support upon configuration.
>  	 * Otherwise module support will break!
>  	 */
> -	if (net_families[family] == NULL) {
> +	if (net_families[family] == NULL)
>  		request_module("net-pf-%d", family);

OK, I'll bite...

What happens if the module is not present?  Or is this what the
"Otherwise module support will break" comment is getting at?

Also, this reference to "net_families[family]" is done without
rcu_dereference() and without any clear update-side lock.  This
just happens to be OK, since we are only testing for NULL, but
should at least have a comment.

> -	}
>  #endif
>  
> -	net_family_read_lock();
> -	if (net_families[family] == NULL) {
> -		err = -EAFNOSUPPORT;
> -		goto out;
> -	}
> -
> -/*
> - *	Allocate the socket and allow the family to set things up. if
> - *	the protocol is 0, the family is instructed to select an appropriate
> - *	default.
> - */
> -
> -	if (!(sock = sock_alloc())) {
> -		printk(KERN_WARNING "socket: no more sockets\n");
> -		err = -ENFILE;	/* Not exactly a match, but its the
> -				   closest posix thing */
> -		goto out;
> -	}
> -
> -	sock->type = type;
> +	rcu_read_lock();
> +	pf = rcu_dereference(net_families[family]);

OK, so the elements of the net_families array are protected by RCU.
All references should either be under rcu_read_lock() and accessed
via rcu_dereference() or under the update-side lock, whatever that
might be.

> +	err = -EAFNOSUPPORT;
> +	if (!pf)
> +		goto out_release;
>  
>  	/*
>  	 * We will call the ->create function, that possibly is in a loadable
>  	 * module, so we have to bump that loadable module refcnt first.
>  	 */
> -	err = -EAFNOSUPPORT;
> -	if (!try_module_get(net_families[family]->owner))
> +	if (!try_module_get(pf->owner))
>  		goto out_release;
>  
> -	if ((err = net_families[family]->create(sock, protocol)) < 0) {
> -		sock->ops = NULL;
> +	/* Now protected by module ref count */
> +	rcu_read_unlock();
> +
> +	err = pf->create(sock, protocol);
> +	if (err < 0)
>  		goto out_module_put;
> -	}
>  
>  	/*
>  	 * Now to bump the refcnt of the [loadable] module that owns this
>  	 * socket at sock_release time we decrement its refcnt.
>  	 */
> -	if (!try_module_get(sock->ops->owner)) {
> -		err = -EAGAIN;
> -		sock->ops = NULL;
> -		goto out_module_put;
> -	}
> +	if (!try_module_get(sock->ops->owner))
> +		goto out_module_busy;
> +
>  	/*
>  	 * Now that we're done with the ->create function, the [loadable]
>  	 * module can have its refcnt decremented
>  	 */
> -	module_put(net_families[family]->owner);
> +	module_put(pf->owner);
>  	*res = sock;
>  	security_socket_post_create(sock, family, type, protocol, kern);
>  
> -out:
> -	net_family_read_unlock();
> -	return err;
> +	return 0;
> +
> +out_module_busy:
> +	err = -EAGAIN;
>  out_module_put:
> -	module_put(net_families[family]->owner);
> -out_release:
> +	sock->ops = NULL;
> +	module_put(pf->owner);
> +out_sock_release:
>  	sock_release(sock);
> -	goto out;
> +	return err;
> +
> +out_release:
> +	rcu_read_unlock();
> +	goto out_sock_release;
>  }
>  
>  int sock_create(int family, int type, int protocol, struct socket **res)
> @@ -2100,12 +2061,15 @@
>  
>  #endif				/* __ARCH_WANT_SYS_SOCKETCALL */
>  
> -/*
> +/**
> + *	sock_register - add a socket protocol handler
> + *	@ops: description of protocol
> + *
>   *	This function is called by a protocol handler that wants to
>   *	advertise its address family, and have it linked into the
> - *	SOCKET module.
> + *	socket interface. The value ops->family coresponds to the
> + *	socket system call protocol family.
>   */
> -
>  int sock_register(struct net_proto_family *ops)
>  {
>  	int err;
> @@ -2115,31 +2079,44 @@
>  		       NPROTO);
>  		return -ENOBUFS;
>  	}
> -	net_family_write_lock();
> -	err = -EEXIST;
> -	if (net_families[ops->family] == NULL) {
> +
> +	spin_lock(&net_family_lock);
> +	if (net_families[ops->family])

OK, so the update-side lock is presumably net_family_lock.

> +		err = -EEXIST;
> +	else {
>  		net_families[ops->family] = ops;

This one is covered by the same net_families_lock, so OK.

>  		err = 0;
>  	}
> -	net_family_write_unlock();
> +	spin_unlock(&net_family_lock);
> +
>  	printk(KERN_INFO "NET: Registered protocol family %d\n", ops->family);
>  	return err;
>  }
>  
> -/*
> +/**
> + *	sock_unregister - remove a protocol handler
> + *	@family: protocol family to remove
> + *
>   *	This function is called by a protocol handler that wants to
>   *	remove its address family, and have it unlinked from the
> - *	SOCKET module.
> + *	new socket creation.
> + *
> + *	If protocol handler is a module, then it can use module reference
> + *	counts to protect against new references. If protocol handler is not
> + *	a module then it needs to provide its own protection in
> + *	the ops->create routine.
>   */
> -
>  int sock_unregister(int family)
>  {
>  	if (family < 0 || family >= NPROTO)
> -		return -1;
> +		return -EINVAL;
>  
> -	net_family_write_lock();
> +	spin_lock(&net_family_lock);
>  	net_families[family] = NULL;

And this one is covered by net_families_lock, so we are set, since this
is the last one.

> -	net_family_write_unlock();
> +	spin_unlock(&net_family_lock);
> +
> +	synchronize_rcu();

OK, and the caller is presumably going to free up whatever needs to be
freed.

Or, if nothing need be freed, beyond this point, we know that all
non-sleeping code paths through any of the net_protocol_family
functions have completed.

(So, are all of the functions non-sleeping, or do we care?  The
definition of net_protocol_family in include/linux/net.h doesn't say
that they need to be non-sleeping...)

atalk_create() can potentially sleep in the following line of code:

	sk = sk_alloc(PF_APPLETALK, GFP_KERNEL, &ddp_proto, 1);

What prevents atalk_create() running concurrently with sock_unregister()?
(One possible reason is that ->create is only called in __sock_create(),
and that there is something preventing sock_unregister() from being called
before __sock_create() returns -- but I must defer to people who understand
networking better than do I.)

> +
>  	printk(KERN_INFO "NET: Unregistered protocol family %d\n", family);
>  	return 0;
>  }
> 
> --
> 
