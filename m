From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [RFC] cpualloc: improvements to per-cpu allocation
Date: Wed, 31 Dec 2008 17:27:49 -0600 (CST)
Message-ID: <Pine.LNX.4.64.0812311717050.22685@quilx.com>
References: <200812310938.09912.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	catalin.marinas@arm.com,
	Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nlpi025.sbcis.sbc.com ([207.115.36.54]:44165 "EHLO
	nlpi025.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751919AbYLaX2R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Dec 2008 18:28:17 -0500
In-Reply-To: <200812310938.09912.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 31 Dec 2008, Rusty Russell wrote:

> afterwards, with many more to come (eg. local_t is now more useful, if we sort
> the semantics of what it should look like).

Well I dont like local_t as you may have noticed. It limits us to an int.
I think its better to start out with the idea of the cmpxchg that applies
to any scalar. Focus on the operations instead of the use of types.


> commit b9b67f3c818b617bb47344a8574de8bcd5f6b294
> Author: Rusty Russell <rusty@rustcorp.com.au>
> Date:   Wed Dec 31 09:21:46 2008 +1030
>
>     alloc_percpu: Move SNMP and ip_rt_acct to big_percpu
>
>     If we look at percpu allocations to boot an x86/32 "allyesconfig"
>     kernel, we see the following:

Ok so a special allocator for big percpu that avoids the need to
dynamically resize percpu sections. But this still leaves the problem that
too many small allocations may overflow the percpu area.


> commit ba26c860d5d47896aee45ec5f13c0d7bd21a784a
> Author: Rusty Russell <rusty@rustcorp.com.au>
> Date:   Wed Dec 31 09:21:48 2008 +1030
>
>     alloc_percpu: make the per cpu reserve configurable and larger.
>
>     This is based on Christoph Lameter's "cpualloc: make the per cpu
>     reserve configurable" patch, and his "Increase default reserve percpu
>     area" patch.
>
>     Christoph did the hard work of figuring out what the number should be
>     (based on converting the slub allocator).  allyesconfig on x86-32 uses
>     7k before mounting root, so 10k seems reasonable.

This is only the requirement if the page allocator and slab allocator is
converted to use the percpu area. Additional users may require more space.

> commit a56f30e8a075e8ce15b4dff8e3fe0edb9baff7ea
> Author: Rusty Russell <rusty@rustcorp.com.au>
> Date:   Wed Dec 31 09:21:53 2008 +1030
>
>     alloc_percpu: remove per_cpu__ prefix.
>
>     Now that the return from alloc_percpu is compatible with the address
>     of per-cpu vars, it makes sense to hand around the address of per-cpu
>     variables.  To make this sane, we remove the per_cpu__ prefix we used
>     created to stop people accidentally using these vars directly.

Doesnt that move limit how the percpu area can be handled by the arch? If
it becomes a requirement that a percpu address is like any other global
variable then the zero based approach no longer works and with that we may
create x86_64 issues for pda conversion.
