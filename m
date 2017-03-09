From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH net] net: Work around lockdep limitation in sockets
 that use sockets
Date: Wed, 08 Mar 2017 23:06:25 -0800 (PST)
Message-ID: <20170308.230625.719131946756053988.davem@davemloft.net>
References: <148881267372.2618.822975702493802450.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: dhowells@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <148881267372.2618.822975702493802450.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Howells <dhowells@redhat.com>
Date: Mon, 06 Mar 2017 15:04:44 +0000

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

I guess this is fine, but I think you can use one of the two "sk_padding"
bits in struct sock instead of making the structure larger.
