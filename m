From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCH 0/3] virtio/vringh: kill off ACCESS_ONCE()
Date: Fri, 25 Nov 2016 14:35:39 +0000
Message-ID: <20161125143538.GC28715@leverpostej>
References: <1479983114-17190-1-git-send-email-mark.rutland@arm.com>
 <20161124222357-mutt-send-email-mst@kernel.org>
 <20161125112203.GA26611@leverpostej>
 <32dfca07-59f3-b75a-3154-cf6b6c8538f0@de.ibm.com>
 <20161125122356.GB26611@leverpostej>
 <20161125124044.GN3092@twins.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christian Borntraeger <borntraeger@de.ibm.com>,
        "Michael S. Tsirkin" <mst@redhat.com>,
        linux-kernel@vger.kernel.org, dave@stgolabs.net, dbueso@suse.de,
        dvyukov@google.com, jasowang@redhat.com, kvm@vger.kernel.org,
        netdev@vger.kernel.org, paulmck@linux.vnet.ibm.com,
        virtualization@lists.linux-foundation.org,
        Linus Torvalds <torvalds@linux-foundation.org>
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from foss.arm.com ([217.140.101.70]:48028 "EHLO foss.arm.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754333AbcKYOgd (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 25 Nov 2016 09:36:33 -0500
Content-Disposition: inline
In-Reply-To: <20161125124044.GN3092@twins.programming.kicks-ass.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 25, 2016 at 01:40:44PM +0100, Peter Zijlstra wrote:
> On Fri, Nov 25, 2016 at 12:23:56PM +0000, Mark Rutland wrote:
> > Naming will be problematic; calling them ATOMIC_* makes tham sound like
> > they work on atomic_t. That and I have no idea how to ensure correct
> > usage tree-wide; I'm not sure if/how Coccinelle can help.
> > 
> > Peter, thoughts?
> 
> Something like so perhaps?

> /*
>  * Provide accessors for Single-Copy atomicy.
>  *
>  * That is, ensure that machine word sized loads/stores to naturally
>  * aligned variables are single instructions.

Minor nit: this sounds like we *only* support the machine word size,
whereas (excluding alpha IIRC) we can generally acccess power-of-two
sizes from byte up to that.

So perhaps:

	That is, ensure that loads/stores are made with single
	instructions, where the machine can perform a tear-free access
	of that size.

>  * By reason of not being able to use C11 atomic crud, use our beloved
>  * volatile qualifier. Since volatile tells the compiler the value can
>  * be changed behind its back, it must use Single-Copy atomic loads and
>  * stores to access them, otherwise it runs the risk of load/store
>  * tearing.
>  */
> 
> #define SINGLE_LOAD(x)						\
> {(								\
> 	compiletime_assert_atomic_type(typeof(x));		\
> 	WARN_SINGLE_COPY_ALIGNMENT(&(x));			\
> 	READ_ONCE(x);						\
> })
> 
> #define SINGLE_STORE(x, v)					\
> ({								\
> 	compiletime_assert_atomic_type(typeof(x));		\
> 	WARN_SINGLE_COPY_ALIGNMENT(&(x));			\
> 	WRITE_ONCE(x, v);					\
> })

Modulo your type comment, and mine above, this looks good to me.

Thanks,
Mark.
