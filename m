From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 2/2] sysctl:  lockdep support for sysctl reference
 counting.
Date: Tue, 31 Mar 2009 10:17:28 +0200
Message-ID: <1238487448.28248.1805.camel@twins>
References: <49B91A7E.76E4.0078.0@novell.com>
	 <tip-6a09dfa870ba0ed21b1124539968a36b42660661@git.kernel.org>
	 <1236934491.5188.209.camel@laptop> <49BA33BE.76E4.0078.0@novell.com>
	 <1236937423.22914.3698.camel@twins> <20090313103828.GB31094@elte.hu>
	 <m1d4cd9n4k.fsf@fess.ebiederm.org> <20090320085205.GB16021@elte.hu>
	 <m14oxo8qis.fsf@fess.ebiederm.org> <20090320182404.GA31629@elte.hu>
	 <1237575134.4667.5.camel@laptop> <1237577688.4667.68.camel@laptop>
	 <m1iqm3xr2n.fsf_-_@fess.ebiederm.org> <m1eiwrxr05.fsf_-_@fess.ebiederm.org>
	 <m1ab7fxqxw.fsf_-_@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Ingo Molnar <mingo@elte.hu>, Jan Beulich <jbeulich@novell.com>,
	tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com,
	linux-kernel@vger.kernel.org, Gautham R Shenoy <ego@in.ibm.com>,
	Alexey Dobriyan <adobriyan@gmail.com>, netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:55051 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752597AbZCaIRX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Mar 2009 04:17:23 -0400
In-Reply-To: <m1ab7fxqxw.fsf_-_@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2009-03-21 at 00:42 -0700, Eric W. Biederman wrote:
> It is possible for get lock ordering deadlocks between locks
> and waiting for the sysctl used count to drop to zero.  We have
> recently observed one of these in the networking code.
> 
> So teach the sysctl code how to speak lockdep so the kernel
> can warn about these kinds of rare issues proactively.

It would be very good to extend this changelog with a more detailed
explanation of the deadlock in question.

Let me see if I got it right:

We're holding a lock, while waiting for the refcount to drop to 0.
Dropping that refcount is blocked on that lock.

Something like that?

> Signed-off-by: Eric Biederman <ebiederm@aristanetworks.com>
> ---
>  include/linux/sysctl.h |    4 ++
>  kernel/sysctl.c        |  108 ++++++++++++++++++++++++++++++++++++++---------
>  2 files changed, 91 insertions(+), 21 deletions(-)
> 
> diff --git a/include/linux/sysctl.h b/include/linux/sysctl.h
> index 39d471d..ec9b1dd 100644
> --- a/include/linux/sysctl.h
> +++ b/include/linux/sysctl.h
> @@ -28,6 +28,7 @@
>  #include <linux/kernel.h>
>  #include <linux/types.h>
>  #include <linux/compiler.h>
> +#include <linux/lockdep.h>
>  
>  struct file;
>  struct completion;
> @@ -1087,6 +1088,9 @@ struct ctl_table_header
>  	struct ctl_table *attached_by;
>  	struct ctl_table *attached_to;
>  	struct ctl_table_header *parent;
> +#ifdef CONFIG_PROVE_LOCKING
> +	struct lockdep_map dep_map;
> +#endif
>  };
>  
>  /* struct ctl_path describes where in the hierarchy a table is added */
> diff --git a/kernel/sysctl.c b/kernel/sysctl.c
> index c5ef44f..ea8cc39 100644
> --- a/kernel/sysctl.c
> +++ b/kernel/sysctl.c
> @@ -1454,12 +1454,63 @@ static struct ctl_table dev_table[] = {
>  
>  static DEFINE_SPINLOCK(sysctl_lock);
>  
> +#ifndef CONFIG_PROVE_LOCKING
> +
> +# define lock_sysctl() spin_lock(&sysctl_lock)
> +# define unlock_sysctl() spin_unlock(&sysctl_lock)
> +
> +static inline void table_acquire_use(struct ctl_table_header *hdr) { }
> +static inline void table_release_use(struct ctl_table_header *hdr) { }
> +static inline void table_acquire(struct ctl_table_header *hdr) { }
> +static inline void table_contended(struct ctl_table_header *hdr) { }
> +static inline void table_acquired(struct ctl_table_header *hdr) { }
> +static inline void table_release(struct ctl_table_header *hdr) { }
> +
> +#else	/* CONFIG_PROVE_LOCKING */
> +
> +#  define lock_sysctl() __raw_spin_lock(&sysctl_lock.raw_lock)
> +#  define unlock_sysctl() __raw_spin_unlock(&sysctl_lock.raw_lock)

Uhmm, Please explain that -- without a proper explanation this is a NAK.

> +static inline void table_acquire_use(struct ctl_table_header *hdr)
> +{
> +	lock_acquire(&hdr->dep_map, 0, 0, 1, 2, NULL, _RET_IP_);
> +	lock_acquired(&hdr->dep_map, _RET_IP_);
> +}
> +
> +static inline void table_release_use(struct ctl_table_header *hdr)
> +{
> +	lock_release(&hdr->dep_map, 0, _RET_IP_);
> +}
> +
> +static inline void table_acquire(struct ctl_table_header *hdr)
> +{
> +	lock_acquire(&hdr->dep_map, 0, 0, 0, 2, NULL, _RET_IP_);
> +}
> +
> +static inline void table_contended(struct ctl_table_header *hdr)
> +{
> +	lock_contended(&hdr->dep_map, _RET_IP_);
> +}
> +
> +static inline void table_acquired(struct ctl_table_header *hdr)
> +{
> +	lock_acquired(&hdr->dep_map, _RET_IP_);
> +}
> +
> +static inline void table_release(struct ctl_table_header *hdr)
> +{
> +	lock_release(&hdr->dep_map, 0, _RET_IP_);
> +}
> +
> +#endif /* CONFIG_PROVE_LOCKING */
> +
>  /* called under sysctl_lock */
>  static int use_table(struct ctl_table_header *p)
>  {
>  	if (unlikely(p->unregistering))
>  		return 0;
>  	p->used++;
> +	table_acquire_use(p);
>  	return 1;
>  }
>  
> @@ -1469,6 +1520,8 @@ static void unuse_table(struct ctl_table_header *p)
>  	if (!--p->used)
>  		if (unlikely(p->unregistering))
>  			complete(p->unregistering);
> +
> +	table_release_use(p);
>  }
>  
>  /* called under sysctl_lock, will reacquire if has to wait */
> @@ -1478,47 +1531,54 @@ static void start_unregistering(struct ctl_table_header *p)
>  	 * if p->used is 0, nobody will ever touch that entry again;
>  	 * we'll eliminate all paths to it before dropping sysctl_lock
>  	 */
> +	table_acquire(p);
>  	if (unlikely(p->used)) {
>  		struct completion wait;
> +		table_contended(p);
> +
>  		init_completion(&wait);
>  		p->unregistering = &wait;
> -		spin_unlock(&sysctl_lock);
> +		unlock_sysctl();
>  		wait_for_completion(&wait);
> -		spin_lock(&sysctl_lock);
> +		lock_sysctl();
>  	} else {
>  		/* anything non-NULL; we'll never dereference it */
>  		p->unregistering = ERR_PTR(-EINVAL);
>  	}
> +	table_acquired(p);
> +
>  	/*
>  	 * do not remove from the list until nobody holds it; walking the
>  	 * list in do_sysctl() relies on that.
>  	 */
>  	list_del_init(&p->ctl_entry);
> +
> +	table_release(p);
>  }
>  

> @@ -1951,7 +2011,13 @@ struct ctl_table_header *__register_sysctl_paths(
>  		return NULL;
>  	}
>  #endif
> -	spin_lock(&sysctl_lock);
> +#ifdef CONFIG_DEBUG_LOCK_ALLOC
> +	{
> +		static struct lock_class_key __key;
> +		lockdep_init_map(&header->dep_map, "sysctl_used", &__key, 0);
> +	}
> +#endif	

This means every sysctl thingy gets the same class, is that
intended/desired?

