From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/24] make atomic_read() behave consistently on alpha
Date: Thu, 9 Aug 2007 07:32:55 -0700
Message-ID: <20070809143255.GA8424@linux.vnet.ibm.com>
References: <20070809132442.GA13042@shell.boston.redhat.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org,
	torvalds@linux-foundation.org, netdev@vger.kernel.org,
	akpm@linux-foundation.org, ak@suse.de, heiko.carstens@de.ibm.com,
	davem@davemloft.net, schwidefsky@de.ibm.com, wensong@linux-vs.org,
	horms@verge.net.au, wjiang@resilience.com, cfriesen@nortel.com,
	zlynx@acm.org, rpjday@mindspring.com, jesper.juhl@gmail.com
To: Chris Snook <csnook@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:36521 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S939883AbXHIOc6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Aug 2007 10:32:58 -0400
Content-Disposition: inline
In-Reply-To: <20070809132442.GA13042@shell.boston.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 09, 2007 at 09:24:42AM -0400, Chris Snook wrote:
> From: Chris Snook <csnook@redhat.com>
> 
> Purify volatile use for atomic[64]_t on alpha.

Why not the same access-once semantics for atomic_set() as
for atomic_read()?  As this patch stands, it might introduce
architecture-specific compiler-induced bugs due to the fact that
atomic_set() used to imply volatile behavior but no longer does.

See below for one approach to fixing this.

> Signed-off-by: Chris Snook <csnook@redhat.com>
> 
> --- linux-2.6.23-rc2-orig/include/asm-alpha/atomic.h	2007-07-08 19:32:17.000000000 -0400
> +++ linux-2.6.23-rc2/include/asm-alpha/atomic.h	2007-08-09 09:19:00.000000000 -0400
> @@ -14,18 +14,22 @@
> 
> 
>  /*
> - * Counter is volatile to make sure gcc doesn't try to be clever
> - * and move things around on us. We need to use _exactly_ the address
> - * the user gave us, not some alias that contains the same information.
> + * Make sure gcc doesn't try to be clever and move things around
> + * on us. We need to use _exactly_ the address the user gave us,
> + * not some alias that contains the same information.
>   */
> -typedef struct { volatile int counter; } atomic_t;
> -typedef struct { volatile long counter; } atomic64_t;
> +typedef struct { int counter; } atomic_t;
> +typedef struct { long counter; } atomic64_t;
> 
>  #define ATOMIC_INIT(i)		( (atomic_t) { (i) } )
>  #define ATOMIC64_INIT(i)	( (atomic64_t) { (i) } )
> 
> -#define atomic_read(v)		((v)->counter + 0)
> -#define atomic64_read(v)	((v)->counter + 0)
> +/*
> + * Casting to volatile here minimizes the need for barriers,
> + * without having to declare the type itself as volatile.
> + */
> +#define atomic_read(v)		(*(volatile int *)&(v)->counter + 0)
> +#define atomic64_read(v)	(*(volatile long *)&(v)->counter + 0)
> 
>  #define atomic_set(v,i)		((v)->counter = (i))
>  #define atomic64_set(v,i)	((v)->counter = (i))

How about:

#define atomic_set(v,i)		((*(volatile int *)&(v)->counter) = (i))
#define atomic64_set(v,i)	((*(volatile long *)&(v)->counter) = (i))

						Thanx, Paul

> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
