From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] atomic: add atomic_inc_not_zero_hint()
Date: Fri, 5 Nov 2010 10:20:38 -0700
Message-ID: <20101105102038.53e36f9e.akpm@linux-foundation.org>
References: <1288975980.2882.877.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Christoph Lameter <cl@linux-foundation.org>,
	Ingo Molnar <mingo@elte.hu>, Andi Kleen <andi@firstfloor.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Nick Piggin <npiggin@kernel.dk>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:41553 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754377Ab0KERVO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Nov 2010 13:21:14 -0400
In-Reply-To: <1288975980.2882.877.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 05 Nov 2010 17:53:00 +0100
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Andrew
> 
> atomic_inc_not_zero() / atomic_add_unless() ... are spreaded in many
> arch/xxx/include/asm/atomic.h, but they are generic.
> 
> Apparently there is no centralization of some common atomic features...
> 
> What do you think adding a new file so that we can move common
> definitions in it ?
> 
> Thanks
> 
> [PATCH] atomic: add atomic_inc_not_zero_hint()
> 
> Followup of perf tools session in Netfilter WorkShop 2010
> 
> In network stack we make high usage of atomic_inc_not_zero() in contexts
> we know the probable value of atomic before increment (2 for udp sockets
> for example)
> 
> Using a special version of atomic_inc_not_zero() giving this hint can
> help processor to use less bus transactions.
> 
> On x86 (MESI protocol) for example, this avoids entering Shared state,
> because "lock cmpxchg" issues an RFO (Read For Ownership)

It totally makes sense to add include/linu/atomic.h for common things. 
Perhaps there's already code in arch/*/include/asm/atomic.h which
should be hoisted up there.  But that can't reliably be done until a
million files have had their #includes switched :(

> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Christoph Lameter <cl@linux-foundation.org>
> Cc: Ingo Molnar <mingo@elte.hu>
> Cc: Andi Kleen <andi@firstfloor.org>
> Cc: Arnaldo Carvalho de Melo <acme@infradead.org>
> Cc: David Miller <davem@davemloft.net>
> Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
> Cc: Nick Piggin <npiggin@kernel.dk>
> ---
>  include/linux/atomic.h |   29 +++++++++++++++++++++++++++++
>  1 file changed, 29 insertions(+)
> 
> diff --git a/include/linux/atomic.h b/include/linux/atomic.h
> new file mode 100644
> index 0000000..c04327a
> --- /dev/null
> +++ b/include/linux/atomic.h
> @@ -0,0 +1,29 @@
> +#ifndef _LINUX_ATOMIC_H
> +#define _LINUX_ATOMIC_H
> +#include <asm/atomic.h>
> +
> +/**
> + * atomic_inc_not_zero_hint - increment if not null
> + * @v: pointer of type atomic_t
> + * @hint: probable value of the atomic before the increment
> + *
> + * This version of atomic_inc_not_zero() gives a hint of probable
> + * value of the atomic. This helps processor to not read the memory
> + * before doing the atomic read/modify/write cycle, lowering
> + * number of bus transactions on some arches.
> + * Note: hint MUST not be 0 !
> + */

It's quite unobvious *why* `hint' cannot be zero.  Can you please add
the reasoning to the comment?  Also, the local `hint' should be
referred to as "@hint" in a kerneldoc comment.

> +static inline int atomic_inc_not_zero_hint(atomic_t *v, int hint)
> +{
> +	int val, c = hint;
> +
> + 	do {
> +		val = atomic_cmpxchg(v, c, c + 1);
> +		if (val == c)
> +			return 1;
> +		c = val;
> +	} while (c);
> +
> +	return 0;
> +}

Should/could this have implemented a more general
atomic_add_not_zero_hint() and made atomic_inc_not_zero_hint() a
wrapper around that?

Also, it might make sense to add "#ifndef atomic_inc_not_zero_hint"
wrappers around this function so that the arch can implement an
overriding custom version.  And that becomes a general rule as more
functions are added to include/linux/atomic.h.
