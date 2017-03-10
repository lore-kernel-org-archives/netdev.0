From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: Work around lockdep limitation in sockets
 that use sockets
Date: Thu, 09 Mar 2017 18:25:04 -0800 (PST)
Message-ID: <20170309.182504.556453593217285552.davem@davemloft.net>
References: <148904694551.4893.14290556899372744780.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: dhowells@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <148904694551.4893.14290556899372744780.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Howells <dhowells@redhat.com>
Date: Thu, 09 Mar 2017 08:09:05 +0000

> Lockdep issues a circular dependency warning when AFS issues an operation
> through AF_RXRPC from a context in which the VFS/VM holds the mmap_sem.
> 
> The theory lockdep comes up with is as follows:
 ...
> However, lockdep's theory is wrong in this instance because it deals only
> with lock classes and not individual locks.  The AF_INET lock in (2) isn't
> really equivalent to the AF_INET lock in (3) as the former deals with a
> socket entirely internal to the kernel that never sees userspace.  This is
> a limitation in the design of lockdep.
> 
> Fix the general case by:
> 
>  (1) Double up all the locking keys used in sockets so that one set are
>      used if the socket is created by userspace and the other set is used
>      if the socket is created by the kernel.
> 
>  (2) Store the kern parameter passed to sk_alloc() in a variable in the
>      sock struct (sk_kern_sock).  This informs sock_lock_init(),
>      sock_init_data() and sk_clone_lock() as to the lock keys to be used.
> 
>      Note that the child created by sk_clone_lock() inherits the parent's
>      kern setting.
> 
>  (3) Add a 'kern' parameter to ->accept() that is analogous to the one
>      passed in to ->create() that distinguishes whether kernel_accept() or
>      sys_accept4() was the caller and can be passed to sk_alloc().
> 
>      Note that a lot of accept functions merely dequeue an already
>      allocated socket.  I haven't touched these as the new socket already
>      exists before we get the parameter.
> 
>      Note also that there are a couple of places where I've made the accepted
>      socket unconditionally kernel-based:
> 
> 	irda_accept()
> 	rds_rcp_accept_one()
> 	tcp_accept_from_sock()
> 
>      because they follow a sock_create_kern() and accept off of that.
> 
> Whilst creating this, I noticed that lustre and ocfs don't create sockets
> through sock_create_kern() and thus they aren't marked as for-kernel,
> though they appear to be internal.  I wonder if these should do that so
> that they use the new set of lock keys.
> 
> Signed-off-by: David Howells <dhowells@redhat.com>

Applied, thanks David.
