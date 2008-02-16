From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/2] remove rcu_assign_pointer(NULL) penalty with
 type/macro safety
Date: Fri, 15 Feb 2008 16:40:24 -0800
Message-ID: <20080215164024.7fd356fa.akpm@linux-foundation.org>
References: <20080213220024.GA30729@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, shemminger@vyatta.com,
	davem@davemloft.net, netdev@vger.kernel.org, dipankar@in.ibm.com,
	ego@in.ibm.com, herbert@gondor.apana.org.au
To: paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:37161 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752696AbYBPAld (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Feb 2008 19:41:33 -0500
In-Reply-To: <20080213220024.GA30729@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 13 Feb 2008 14:00:24 -0800
"Paul E. McKenney" <paulmck@linux.vnet.ibm.com> wrote:

> Hello!
> 
> This is an updated version of the patch posted last November:
> 
> 	http://archives.free.net.ph/message/20071201.003721.cd6ff17c.en.html
> 
> This new version permits arguments with side effects, for example:
> 
> 	rcu_assign_pointer(global_p, p++);
> 
> and also verifies that the arguments are pointers, while still avoiding
> the unnecessary memory barrier when assigning NULL to a pointer.
> This memory-barrier avoidance means that rcu_assign_pointer() is now only
> permitted for pointers (not array indexes), and so this version emits a
> compiler warning if the first argument is not a pointer.  I built a "make
> allyesconfig" version on an x86 system, and received no such warnings.
> If RCU is ever applied to array indexes, then the second patch in this
> series should be applied, and the resulting rcu_assign_index() be used.
> 
> Given the rather surprising history of subtlely broken implementations of
> rcu_assign_pointer(), I took the precaution of generating a full set of
> test cases and verified that memory barriers and compiler warnings were
> emitted when required.  I guess it is the simple things that get you...
> 
> Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> ---
> 
>  rcupdate.h |   16 ++++++++++++----
>  1 file changed, 12 insertions(+), 4 deletions(-)
> 
> diff -urpNa -X dontdiff linux-2.6.24/include/linux/rcupdate.h linux-2.6.24-rap/include/linux/rcupdate.h
> --- linux-2.6.24/include/linux/rcupdate.h	2008-01-24 14:58:37.000000000 -0800
> +++ linux-2.6.24-rap/include/linux/rcupdate.h	2008-02-13 13:36:47.000000000 -0800
> @@ -270,12 +270,20 @@ extern struct lockdep_map rcu_lock_map;
>   * structure after the pointer assignment.  More importantly, this
>   * call documents which pointers will be dereferenced by RCU read-side
>   * code.
> + *
> + * Throws a compiler warning for non-pointer arguments.
> + *
> + * Does not insert a memory barrier for a NULL pointer.
>   */
>  
> -#define rcu_assign_pointer(p, v)	({ \
> -						smp_wmb(); \
> -						(p) = (v); \
> -					})
> +#define rcu_assign_pointer(p, v)	\
> +	({ \
> +		typeof(*p) *_________p1 = (v); \
> +		\
> +		if (!__builtin_constant_p(v) || (_________p1 != NULL)) \
> +			smp_wmb(); \
> +		(p) = _________p1; \
> +	})
>  

umm...

net/netfilter/core.c: In function 'nf_register_afinfo':
net/netfilter/core.c:39: warning: initialization discards qualifiers from pointer target type
net/netfilter/nf_log.c: In function 'nf_log_register':
net/netfilter/nf_log.c:37: warning: initialization discards qualifiers from pointer target type
net/netfilter/nf_queue.c: In function 'nf_register_queue_handler':
net/netfilter/nf_queue.c:38: warning: initialization discards qualifiers from pointer target type


