From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 6/13] bridge: Add core IGMP snooping support
Date: Sun, 14 Mar 2010 16:01:21 -0700
Message-ID: <20100314230121.GF6744@linux.vnet.ibm.com>
References: <20100228054012.GA7583@gondor.apana.org.au> <20100307031151.GA7546@linux.vnet.ibm.com> <201003081950.48384.arnd@arndb.de> <201003111949.52836.arnd@arndb.de>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@vyatta.com>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:59340 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934304Ab0CNXBX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 14 Mar 2010 19:01:23 -0400
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by e1.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id o2EMv38V025945
	for <netdev@vger.kernel.org>; Sun, 14 Mar 2010 18:57:03 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o2EN1MLk149110
	for <netdev@vger.kernel.org>; Sun, 14 Mar 2010 19:01:22 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o2EN1Mda017484
	for <netdev@vger.kernel.org>; Sun, 14 Mar 2010 19:01:22 -0400
Content-Disposition: inline
In-Reply-To: <201003111949.52836.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 11, 2010 at 07:49:52PM +0100, Arnd Bergmann wrote:
> Following up on the earlier discussion,
> 
> On Monday 08 March 2010, Arnd Bergmann wrote:
> > > Arnd, would it be reasonable to extend your RCU-sparse changes to have
> > > four different pointer namespaces, one for each flavor of RCU?  (RCU,
> > > RCU-bh, RCU-sched, and SRCU)?  Always a fan of making the computer do
> > > the auditing where reasonable.  ;-)
> > 
> > Yes, I guess that would be possible. I'd still leave out the rculist
> > from any annotations for now, as this would get even more complex then.
> > 
> > One consequence will be the need for new rcu_assign_pointer{,_bh,_sched}
> > macros that check the address space of the first argument, otherwise
> > you'd be able to stick anything in there, including non-__rcu pointers.
> 
> I've tested this out now, see the patch below. I needed to add a number
> of interfaces, but it still seems ok. Doing it for all the rculist
> functions most likely would be less so.
> 
> This is currently the head of my rcu-annotate branch of playground.git.
> Paul, before I split it up and merge this with the per-subsystem patches,
> can you tell me if this is what you had in mind?

This looks extremely nice!!!

I did note a few questions and a couple of minor change below, but the
API and definitions look quite good.

Search for empty lines to find them.  Summary:

o	srcu_assign_pointer() should be defined in include/linux/srcu.h.

o	SRCU_INIT_POINTER() should be defined in include/linux/srcu.h.

o	rcu_dereference_check_sched_domain() can now rely on
	rcu_dereference_sched_check() to do the srcu_read_lock_held()
	check, so no longer needed at this level.

o	kvm_create_vm() should be able to use a single "buses" local
	variable rather than an array of them.

Again, good stuff!!!  Thank you for taking this on!

> > > This could potentially catch the mismatched call_rcu()s, at least if the
> > > rcu_head could be labeled.
> > ...
> > #define rcu_exchange_call(ptr, new, member, func) \
> > ({ \
> >         typeof(new) old = rcu_exchange((ptr),(new)); \
> >         if (old) \
> >                 call_rcu(&(old)->member, (func));       \
> >         old; \
> > })
> 
> Unfortunately, this did not work out at all. Almost every user follows
> a slightly different pattern for call_rcu, so I did not find a way
> to match the call_rcu calls with the pointers. In particular, the functions
> calling call_rcu() sometimes no longer have access to the 'old' data,
> e.g. in case of synchronize_rcu.
> 
> My current take is that static annotations won't help us here.

Thank you for checking it out -- not every idea works out well in
practice, I guess.  ;-)

							Thanx, Paul

> 	Arnd
> 
> ---
> 
> rcu: split up __rcu annotations
>     
> This adds separate name spaces for the four distinct types of RCU
> that we use in the kernel, namely __rcu, __rcu_bh, __rcu_sched and
> __srcu.
>     
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> 
> ---
>  arch/x86/kvm/mmu.c         |    6 ++--
>  arch/x86/kvm/vmx.c         |    2 +-
>  drivers/net/macvlan.c      |    8 ++--
>  include/linux/compiler.h   |    6 ++++
>  include/linux/kvm_host.h   |    4 +-
>  include/linux/netdevice.h  |    2 +-
>  include/linux/rcupdate.h   |   68 +++++++++++++++++++++++++++++++++----------
>  include/linux/srcu.h       |    5 ++-
>  include/net/dst.h          |    4 +-
>  include/net/llc.h          |    3 +-
>  include/net/sock.h         |    2 +-
>  include/trace/events/kvm.h |    4 +-
>  kernel/cgroup.c            |   10 +++---
>  kernel/perf_event.c        |    8 ++--
>  kernel/sched.c             |    6 ++--
>  kernel/sched_fair.c        |    2 +-
>  lib/radix-tree.c           |    8 ++--
>  net/core/filter.c          |    4 +-
>  net/core/sock.c            |    6 ++--
>  net/decnet/dn_route.c      |    2 +-
>  net/ipv4/route.c           |   60 +++++++++++++++++++-------------------
>  net/ipv4/tcp.c             |    4 +-
>  net/llc/llc_core.c         |    6 ++--
>  net/llc/llc_input.c        |    2 +-
>  virt/kvm/iommu.c           |    4 +-
>  virt/kvm/kvm_main.c        |   56 +++++++++++++++++++-----------------
>  26 files changed, 171 insertions(+), 121 deletions(-)
> 
> diff --git a/arch/x86/kvm/mmu.c b/arch/x86/kvm/mmu.c
> index 741373e..45877ca 100644
> --- a/arch/x86/kvm/mmu.c
> +++ b/arch/x86/kvm/mmu.c
> @@ -793,7 +793,7 @@ static int kvm_handle_hva(struct kvm *kvm, unsigned long hva,
>  	int retval = 0;
>  	struct kvm_memslots *slots;
> 
> -	slots = rcu_dereference(kvm->memslots);
> +	slots = srcu_dereference(kvm->memslots, &kvm->srcu);
> 
>  	for (i = 0; i < slots->nmemslots; i++) {
>  		struct kvm_memory_slot *memslot = &slots->memslots[i];
> @@ -3007,7 +3007,7 @@ unsigned int kvm_mmu_calculate_mmu_pages(struct kvm *kvm)
>  	unsigned int  nr_pages = 0;
>  	struct kvm_memslots *slots;
> 
> -	slots = rcu_dereference(kvm->memslots);
> +	slots = srcu_dereference(kvm->memslots, &kvm->srcu);
>  	for (i = 0; i < slots->nmemslots; i++)
>  		nr_pages += slots->memslots[i].npages;
> 
> @@ -3282,7 +3282,7 @@ static int count_rmaps(struct kvm_vcpu *vcpu)
>  	int i, j, k, idx;
> 
>  	idx = srcu_read_lock(&kvm->srcu);
> -	slots = rcu_dereference(kvm->memslots);
> +	slots = srcu_dereference(kvm->memslots, &kvm->srcu);
>  	for (i = 0; i < KVM_MEMORY_SLOTS; ++i) {
>  		struct kvm_memory_slot *m = &slots->memslots[i];
>  		struct kvm_rmap_desc *d;
> diff --git a/arch/x86/kvm/vmx.c b/arch/x86/kvm/vmx.c
> index 0aec1f3..d0c82ed 100644
> --- a/arch/x86/kvm/vmx.c
> +++ b/arch/x86/kvm/vmx.c
> @@ -1513,7 +1513,7 @@ static gva_t rmode_tss_base(struct kvm *kvm)
>  		struct kvm_memslots *slots;
>  		gfn_t base_gfn;
> 
> -		slots = rcu_dereference(kvm->memslots);
> +		slots = srcu_dereference(kvm->memslots, &kvm->srcu);
>  		base_gfn = slots->memslots[0].base_gfn +
>  				 slots->memslots[0].npages - 3;
>  		return base_gfn << PAGE_SHIFT;
> diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
> index 95e1bcc..b958d5a 100644
> --- a/drivers/net/macvlan.c
> +++ b/drivers/net/macvlan.c
> @@ -531,15 +531,15 @@ static int macvlan_port_create(struct net_device *dev)
>  	INIT_LIST_HEAD(&port->vlans);
>  	for (i = 0; i < MACVLAN_HASH_SIZE; i++)
>  		INIT_HLIST_HEAD(&port->vlan_hash[i]);
> -	rcu_assign_pointer(dev->macvlan_port, port);
> +	rcu_assign_pointer_bh(dev->macvlan_port, port);
>  	return 0;
>  }
> 
>  static void macvlan_port_destroy(struct net_device *dev)
>  {
> -	struct macvlan_port *port = rcu_dereference_const(dev->macvlan_port);
> +	struct macvlan_port *port = rcu_dereference_bh_const(dev->macvlan_port);
> 
> -	rcu_assign_pointer(dev->macvlan_port, NULL);
> +	rcu_assign_pointer_bh(dev->macvlan_port, NULL);
>  	synchronize_rcu();
>  	kfree(port);
>  }
> @@ -624,7 +624,7 @@ int macvlan_common_newlink(struct net *src_net, struct net_device *dev,
>  		if (err < 0)
>  			return err;
>  	}
> -	port = rcu_dereference(lowerdev->macvlan_port);
> +	port = rcu_dereference_bh(lowerdev->macvlan_port);
> 
>  	vlan->lowerdev = lowerdev;
>  	vlan->dev      = dev;
> diff --git a/include/linux/compiler.h b/include/linux/compiler.h
> index 0ab21c2..d5756d4 100644
> --- a/include/linux/compiler.h
> +++ b/include/linux/compiler.h
> @@ -17,6 +17,9 @@
>  # define __cond_lock(x,c)	((c) ? ({ __acquire(x); 1; }) : 0)
>  # define __percpu	__attribute__((noderef, address_space(3)))
>  # define __rcu		__attribute__((noderef, address_space(4)))
> +# define __rcu_bh	__attribute__((noderef, address_space(5)))
> +# define __rcu_sched	__attribute__((noderef, address_space(6)))
> +# define __srcu		__attribute__((noderef, address_space(7)))
>  extern void __chk_user_ptr(const volatile void __user *);
>  extern void __chk_io_ptr(const volatile void __iomem *);
>  #else
> @@ -36,6 +39,9 @@ extern void __chk_io_ptr(const volatile void __iomem *);
>  # define __cond_lock(x,c) (c)
>  # define __percpu
>  # define __rcu
> +# define __rcu_bh
> +# define __rcu_sched
> +# define __srcu
>  #endif
> 
>  #ifdef __KERNEL__
> diff --git a/include/linux/kvm_host.h b/include/linux/kvm_host.h
> index 9eb0f9c..bad1787 100644
> --- a/include/linux/kvm_host.h
> +++ b/include/linux/kvm_host.h
> @@ -164,7 +164,7 @@ struct kvm {
>  	raw_spinlock_t requests_lock;
>  	struct mutex slots_lock;
>  	struct mm_struct *mm; /* userspace tied to this vm */
> -	struct kvm_memslots __rcu *memslots;
> +	struct kvm_memslots __srcu *memslots;
>  	struct srcu_struct srcu;
>  #ifdef CONFIG_KVM_APIC_ARCHITECTURE
>  	u32 bsp_vcpu_id;
> @@ -174,7 +174,7 @@ struct kvm {
>  	atomic_t online_vcpus;
>  	struct list_head vm_list;
>  	struct mutex lock;
> -	struct kvm_io_bus __rcu *buses[KVM_NR_BUSES];
> +	struct kvm_io_bus __srcu *buses[KVM_NR_BUSES];
>  #ifdef CONFIG_HAVE_KVM_EVENTFD
>  	struct {
>  		spinlock_t        lock;
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index fd7e8de..1b72188 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -949,7 +949,7 @@ struct net_device {
>  	/* bridge stuff */
>  	void __rcu		*br_port;
>  	/* macvlan */
> -	struct macvlan_port __rcu *macvlan_port;
> +	struct macvlan_port __rcu_bh *macvlan_port;
>  	/* GARP */
>  	struct garp_port __rcu	*garp_port;
> 
> diff --git a/include/linux/rcupdate.h b/include/linux/rcupdate.h
> index 03702cc..b4c6f39 100644
> --- a/include/linux/rcupdate.h
> +++ b/include/linux/rcupdate.h
> @@ -183,19 +183,33 @@ static inline int rcu_read_lock_sched_held(void)
>   * read-side critical section.  It is also possible to check for
>   * locks being held, for example, by using lockdep_is_held().
>   */
> -#define rcu_dereference_check(p, c) \
> +#define __rcu_dereference_check(p, c, space) \
>  	({ \
>  		if (debug_locks && !(c)) \
>  			lockdep_rcu_dereference(__FILE__, __LINE__); \
> -		rcu_dereference_raw(p); \
> +		__rcu_dereference_raw(p, space); \
>  	})
> 
> +
>  #else /* #ifdef CONFIG_PROVE_RCU */
> 
> -#define rcu_dereference_check(p, c)	rcu_dereference_raw(p)
> +#define __rcu_dereference_check(p, c, space)	\
> +	__rcu_dereference_raw(p, space)
> 
>  #endif /* #else #ifdef CONFIG_PROVE_RCU */
> 
> +#define rcu_dereference_check(p, c) \
> +	__rcu_dereference_check(p, c, __rcu)
> +
> +#define rcu_dereference_bh_check(p, c) \
> +	__rcu_dereference_check(p, rcu_read_lock_bh_held() || (c), __rcu_bh)
> +
> +#define rcu_dereference_sched_check(p, c) \
> +	__rcu_dereference_check(p, rcu_read_lock_sched_held() || (c), __rcu_sched)
> +
> +#define srcu_dereference_check(p, c) \
> +	__rcu_dereference_check(p, srcu_read_lock_held() || (c), __srcu)
> +
>  /**
>   * rcu_read_lock - mark the beginning of an RCU read-side critical section.
>   *
> @@ -341,13 +355,15 @@ static inline notrace void rcu_read_unlock_sched_notrace(void)
>   * exactly which pointers are protected by RCU and checks that
>   * the pointer is annotated as __rcu.
>   */
> -#define rcu_dereference_raw(p)  ({ \
> +#define __rcu_dereference_raw(p, space)  ({ \
>  				typeof(*p) *_________p1 = (typeof(*p)*__force )ACCESS_ONCE(p); \
> -				(void) (((typeof (*p) __rcu *)p) == p); \
> +				(void) (((typeof (*p) space *)p) == p); \
>  				smp_read_barrier_depends(); \
>  				((typeof(*p) __force __kernel *)(_________p1)); \
>  				})
> 
> +#define rcu_dereference_raw(p) __rcu_dereference_raw(p, __rcu)
> +
>  /**
>   * rcu_dereference_const - fetch an __rcu pointer outside of a
>   * read-side critical section.
> @@ -360,18 +376,22 @@ static inline notrace void rcu_read_unlock_sched_notrace(void)
>   * or in an RCU call.
>   */
> 
> -#define rcu_dereference_const(p)     ({ \
> -				(void) (((typeof (*p) __rcu *)p) == p); \
> +#define __rcu_dereference_const(p, space)     ({ \
> +				(void) (((typeof (*p) space *)p) == p); \
>  				((typeof(*p) __force __kernel *)(p)); \
>  				})
> 
> +#define rcu_dereference_const(p)  __rcu_dereference_const(p, __rcu)
> +#define rcu_dereference_bh_const(p)  __rcu_dereference_const(p, __rcu_bh)
> +#define rcu_dereference_sched_const(p)  __rcu_dereference_const(p, __rcu_sched)
> +
>  /**
>   * rcu_dereference - fetch an RCU-protected pointer, checking for RCU
>   *
>   * Makes rcu_dereference_check() do the dirty work.
>   */
>  #define rcu_dereference(p) \
> -	rcu_dereference_check(p, rcu_read_lock_held())
> +	__rcu_dereference_check(p, rcu_read_lock_held(), __rcu)
> 
>  /**
>   * rcu_dereference_bh - fetch an RCU-protected pointer, checking for RCU-bh
> @@ -379,7 +399,7 @@ static inline notrace void rcu_read_unlock_sched_notrace(void)
>   * Makes rcu_dereference_check() do the dirty work.
>   */
>  #define rcu_dereference_bh(p) \
> -		rcu_dereference_check(p, rcu_read_lock_bh_held())
> +	__rcu_dereference_check(p, rcu_read_lock_bh_held(), __rcu_bh)
> 
>  /**
>   * rcu_dereference_sched - fetch RCU-protected pointer, checking for RCU-sched
> @@ -387,7 +407,7 @@ static inline notrace void rcu_read_unlock_sched_notrace(void)
>   * Makes rcu_dereference_check() do the dirty work.
>   */
>  #define rcu_dereference_sched(p) \
> -		rcu_dereference_check(p, rcu_read_lock_sched_held())
> +	__rcu_dereference_check(p, rcu_read_lock_sched_held(), __rcu_sched)
> 
>  /**
>   * rcu_assign_pointer - assign (publicize) a pointer to a newly
> @@ -402,12 +422,12 @@ static inline notrace void rcu_read_unlock_sched_notrace(void)
>   * code.
>   */
> 
> -#define rcu_assign_pointer(p, v) \
> +#define __rcu_assign_pointer(p, v, space) \
>  	({ \
>  		if (!__builtin_constant_p(v) || \
>  		    ((v) != NULL)) \
>  			smp_wmb(); \
> -		(p) = (typeof(*v) __force __rcu *)(v); \
> +		(p) = (typeof(*v) __force space *)(v); \
>  	})
> 
>  /**
> @@ -415,10 +435,17 @@ static inline notrace void rcu_read_unlock_sched_notrace(void)
>   * without barriers.
>   * Using this is almost always a bug.
>   */
> -#define __rcu_assign_pointer(p, v) \
> -	({ \
> -		(p) = (typeof(*v) __force __rcu *)(v); \
> -	})
> +#define rcu_assign_pointer(p, v) \
> +	__rcu_assign_pointer(p, v, __rcu)
> +
> +#define rcu_assign_pointer_bh(p, v) \
> +	__rcu_assign_pointer(p, v, __rcu_bh)
> +
> +#define rcu_assign_pointer_sched(p, v) \
> +	__rcu_assign_pointer(p, v, __rcu_sched)
> +
> +#define srcu_assign_pointer(p, v) \
> +	__rcu_assign_pointer(p, v, __srcu)

For consistency, the definition of srcu_assign_pointer() should go into
include/linux/srcu.h.

>  /**
>   * RCU_INIT_POINTER - initialize an RCU protected member
> @@ -427,6 +454,15 @@ static inline notrace void rcu_read_unlock_sched_notrace(void)
>  #define RCU_INIT_POINTER(p, v) \
>  		p = (typeof(*v) __force __rcu *)(v)
> 
> +#define RCU_INIT_POINTER_BH(p, v) \
> +		p = (typeof(*v) __force __rcu_bh *)(v)
> +
> +#define RCU_INIT_POINTER_SCHED(p, v) \
> +		p = (typeof(*v) __force __rcu_sched *)(v)
> +
> +#define SRCU_INIT_POINTER(p, v) \
> +		p = (typeof(*v) __force __srcu *)(v)
> +

For consistency, the definition of SRCU_INIT_POINTER() should go into
include/linux/srcu.h.

>  /* Infrastructure to implement the synchronize_() primitives. */
> 
>  struct rcu_synchronize {
> diff --git a/include/linux/srcu.h b/include/linux/srcu.h
> index 4d5ecb2..feaf661 100644
> --- a/include/linux/srcu.h
> +++ b/include/linux/srcu.h
> @@ -111,7 +111,10 @@ static inline int srcu_read_lock_held(struct srcu_struct *sp)
>   * Makes rcu_dereference_check() do the dirty work.
>   */
>  #define srcu_dereference(p, sp) \
> -		rcu_dereference_check(p, srcu_read_lock_held(sp))
> +		__rcu_dereference_check(p, srcu_read_lock_held(sp), __srcu)
> +
> +#define srcu_dereference_const(p) \
> +		__rcu_dereference_const(p, __srcu)
> 
>  /**
>   * srcu_read_lock - register a new reader for an SRCU-protected structure.
> diff --git a/include/net/dst.h b/include/net/dst.h
> index 5f839aa..bbeaba2 100644
> --- a/include/net/dst.h
> +++ b/include/net/dst.h
> @@ -94,9 +94,9 @@ struct dst_entry {
>  	unsigned long		lastuse;
>  	union {
>  		struct dst_entry *next;
> -		struct rtable   __rcu *rt_next;
> +		struct rtable   __rcu_bh *rt_next;
>  		struct rt6_info   *rt6_next;
> -		struct dn_route  *dn_next;
> +		struct dn_route  __rcu_bh *dn_next;
>  	};
>  };
> 
> diff --git a/include/net/llc.h b/include/net/llc.h
> index 8299cb2..5700082 100644
> --- a/include/net/llc.h
> +++ b/include/net/llc.h
> @@ -59,7 +59,8 @@ struct llc_sap {
>  	int		 (* rcv_func)(struct sk_buff *skb,
>  				     struct net_device *dev,
>  				     struct packet_type *pt,
> -				     struct net_device *orig_dev) __rcu;
> +				     struct net_device *orig_dev)
> +							 __rcu_bh;
>  	struct llc_addr	 laddr;
>  	struct list_head node;
>  	spinlock_t sk_lock;
> diff --git a/include/net/sock.h b/include/net/sock.h
> index e07cd78..66d5e09 100644
> --- a/include/net/sock.h
> +++ b/include/net/sock.h
> @@ -290,7 +290,7 @@ struct sock {
>  	struct ucred		sk_peercred;
>  	long			sk_rcvtimeo;
>  	long			sk_sndtimeo;
> -	struct sk_filter __rcu	*sk_filter;
> +	struct sk_filter __rcu_bh *sk_filter;
>  	void			*sk_protinfo;
>  	struct timer_list	sk_timer;
>  	ktime_t			sk_stamp;
> diff --git a/kernel/cgroup.c b/kernel/cgroup.c
> index fc45694..db3e502 100644
> --- a/kernel/cgroup.c
> +++ b/kernel/cgroup.c
> @@ -1392,7 +1392,7 @@ static int cgroup_get_sb(struct file_system_type *fs_type,
>  		root_count++;
> 
>  		sb->s_root->d_fsdata = root_cgrp;
> -		__rcu_assign_pointer(root->top_cgroup.dentry, sb->s_root);
> +		rcu_assign_pointer(root->top_cgroup.dentry, sb->s_root);
> 
>  		/* Link the top cgroup in this hierarchy into all
>  		 * the css_set objects */
> @@ -3243,7 +3243,7 @@ int __init cgroup_init_early(void)
>  	css_set_count = 1;
>  	init_cgroup_root(&rootnode);
>  	root_count = 1;
> -	__rcu_assign_pointer(init_task.cgroups, &init_css_set);
> +	rcu_assign_pointer(init_task.cgroups, &init_css_set);
> 
>  	init_css_set_link.cg = &init_css_set;
>  	init_css_set_link.cgrp = dummytop;
> @@ -3551,7 +3551,7 @@ void cgroup_exit(struct task_struct *tsk, int run_callbacks)
>  	/* Reassign the task to the init_css_set. */
>  	task_lock(tsk);
>  	cg = rcu_dereference_const(tsk->cgroups);
> -	__rcu_assign_pointer(tsk->cgroups, &init_css_set);
> +	rcu_assign_pointer(tsk->cgroups, &init_css_set);
>  	task_unlock(tsk);
>  	if (cg)
>  		put_css_set_taskexit(cg);
> @@ -3959,8 +3959,8 @@ static int __init cgroup_subsys_init_idr(struct cgroup_subsys *ss)
>  		return PTR_ERR(newid);
> 
>  	newid->stack[0] = newid->id;
> -	__rcu_assign_pointer(newid->css, rootcss);
> -	__rcu_assign_pointer(rootcss->id, newid);
> +	rcu_assign_pointer(newid->css, rootcss);
> +	rcu_assign_pointer(rootcss->id, newid);
>  	return 0;
>  }
> 
> diff --git a/kernel/perf_event.c b/kernel/perf_event.c
> index ac8bcbd..e1b65b2 100644
> --- a/kernel/perf_event.c
> +++ b/kernel/perf_event.c
> @@ -1223,8 +1223,8 @@ void perf_event_task_sched_out(struct task_struct *task,
>  			 * XXX do we need a memory barrier of sorts
>  			 * wrt to rcu_dereference() of perf_event_ctxp
>  			 */
> -			__rcu_assign_pointer(task->perf_event_ctxp, next_ctx);
> -			__rcu_assign_pointer(next->perf_event_ctxp, ctx);
> +			rcu_assign_pointer(task->perf_event_ctxp, next_ctx);
> +			rcu_assign_pointer(next->perf_event_ctxp, ctx);
>  			ctx->task = next;
>  			next_ctx->task = task;
>  			do_switch = 0;
> @@ -5376,10 +5376,10 @@ int perf_event_init_task(struct task_struct *child)
>  		 */
>  		cloned_ctx = rcu_dereference(parent_ctx->parent_ctx);
>  		if (cloned_ctx) {
> -			__rcu_assign_pointer(child_ctx->parent_ctx, cloned_ctx);
> +			rcu_assign_pointer(child_ctx->parent_ctx, cloned_ctx);
>  			child_ctx->parent_gen = parent_ctx->parent_gen;
>  		} else {
> -			__rcu_assign_pointer(child_ctx->parent_ctx, parent_ctx);
> +			rcu_assign_pointer(child_ctx->parent_ctx, parent_ctx);
>  			child_ctx->parent_gen = parent_ctx->generation;
>  		}
>  		get_ctx(rcu_dereference_const(child_ctx->parent_ctx));
> diff --git a/kernel/sched.c b/kernel/sched.c
> index 05fd61e..83744d6 100644
> --- a/kernel/sched.c
> +++ b/kernel/sched.c
> @@ -528,7 +528,7 @@ struct rq {
> 
>  #ifdef CONFIG_SMP
>  	struct root_domain *rd;
> -	struct sched_domain __rcu *sd;
> +	struct sched_domain __rcu_sched *sd;
> 
>  	unsigned char idle_at_tick;
>  	/* For active balancing */
> @@ -603,7 +603,7 @@ static inline int cpu_of(struct rq *rq)
>  }
> 
>  #define rcu_dereference_check_sched_domain(p) \
> -	rcu_dereference_check((p), \
> +	rcu_dereference_sched_check((p), \
>  			      rcu_read_lock_sched_held() || \
>  			      lockdep_is_held(&sched_domains_mutex))

Given your definition, the "rcu_read_lock_sched_held() || \" should now
be able to be deleted, correct?

> 
> @@ -6323,7 +6323,7 @@ cpu_attach_domain(struct sched_domain *sd, struct root_domain *rd, int cpu)
>  	sched_domain_debug(sd, cpu);
> 
>  	rq_attach_root(rq, rd);
> -	rcu_assign_pointer(rq->sd, sd);
> +	rcu_assign_pointer_sched(rq->sd, sd);
>  }
> 
>  /* cpus with isolated domains */
> diff --git a/kernel/sched_fair.c b/kernel/sched_fair.c
> index 3e1fd96..5a5ea2c 100644
> --- a/kernel/sched_fair.c
> +++ b/kernel/sched_fair.c
> @@ -3476,7 +3476,7 @@ static void run_rebalance_domains(struct softirq_action *h)
> 
>  static inline int on_null_domain(int cpu)
>  {
> -	return !rcu_dereference(cpu_rq(cpu)->sd);
> +	return !rcu_dereference_sched(cpu_rq(cpu)->sd);
>  }
> 
>  /*
> diff --git a/lib/radix-tree.c b/lib/radix-tree.c
> index f6ae74c..4c6f149 100644
> --- a/lib/radix-tree.c
> +++ b/lib/radix-tree.c
> @@ -264,7 +264,7 @@ static int radix_tree_extend(struct radix_tree_root *root, unsigned long index)
>  			return -ENOMEM;
> 
>  		/* Increase the height.  */
> -		__rcu_assign_pointer(node->slots[0],
> +		rcu_assign_pointer(node->slots[0],
>  			radix_tree_indirect_to_ptr(rcu_dereference_const(root->rnode)));
> 
>  		/* Propagate the aggregated tag info into the new root */
> @@ -1090,7 +1090,7 @@ static inline void radix_tree_shrink(struct radix_tree_root *root)
>  		newptr = rcu_dereference_const(to_free->slots[0]);
>  		if (root->height > 1)
>  			newptr = radix_tree_ptr_to_indirect(newptr);
> -		__rcu_assign_pointer(root->rnode, newptr);
> +		rcu_assign_pointer(root->rnode, newptr);
>  		root->height--;
>  		radix_tree_node_free(to_free);
>  	}
> @@ -1125,7 +1125,7 @@ void *radix_tree_delete(struct radix_tree_root *root, unsigned long index)
>  	slot = rcu_dereference_const(root->rnode);
>  	if (height == 0) {
>  		root_tag_clear_all(root);
> -		__rcu_assign_pointer(root->rnode, NULL);
> +		rcu_assign_pointer(root->rnode, NULL);
>  		goto out;
>  	}
>  	slot = radix_tree_indirect_to_ptr(slot);
> @@ -1183,7 +1183,7 @@ void *radix_tree_delete(struct radix_tree_root *root, unsigned long index)
>  	}
>  	root_tag_clear_all(root);
>  	root->height = 0;
> -	__rcu_assign_pointer(root->rnode, NULL);
> +	rcu_assign_pointer(root->rnode, NULL);
>  	if (to_free)
>  		radix_tree_node_free(to_free);
> 
> diff --git a/net/core/filter.c b/net/core/filter.c
> index d38ef7f..b88675b 100644
> --- a/net/core/filter.c
> +++ b/net/core/filter.c
> @@ -522,7 +522,7 @@ int sk_attach_filter(struct sock_fprog *fprog, struct sock *sk)
> 
>  	rcu_read_lock_bh();
>  	old_fp = rcu_dereference_bh(sk->sk_filter);
> -	rcu_assign_pointer(sk->sk_filter, fp);
> +	rcu_assign_pointer_bh(sk->sk_filter, fp);
>  	rcu_read_unlock_bh();
> 
>  	if (old_fp)
> @@ -539,7 +539,7 @@ int sk_detach_filter(struct sock *sk)
>  	rcu_read_lock_bh();
>  	filter = rcu_dereference_bh(sk->sk_filter);
>  	if (filter) {
> -		rcu_assign_pointer(sk->sk_filter, NULL);
> +		rcu_assign_pointer_bh(sk->sk_filter, NULL);
>  		sk_filter_delayed_uncharge(sk, filter);
>  		ret = 0;
>  	}
> diff --git a/net/core/sock.c b/net/core/sock.c
> index 74242e2..8549387 100644
> --- a/net/core/sock.c
> +++ b/net/core/sock.c
> @@ -1073,11 +1073,11 @@ static void __sk_free(struct sock *sk)
>  	if (sk->sk_destruct)
>  		sk->sk_destruct(sk);
> 
> -	filter = rcu_dereference_check(sk->sk_filter,
> +	filter = rcu_dereference_bh_check(sk->sk_filter,
>  				       atomic_read(&sk->sk_wmem_alloc) == 0);
>  	if (filter) {
>  		sk_filter_uncharge(sk, filter);
> -		rcu_assign_pointer(sk->sk_filter, NULL);
> +		rcu_assign_pointer_bh(sk->sk_filter, NULL);
>  	}
> 
>  	sock_disable_timestamp(sk, SOCK_TIMESTAMP);
> @@ -1167,7 +1167,7 @@ struct sock *sk_clone(const struct sock *sk, const gfp_t priority)
>  		sock_reset_flag(newsk, SOCK_DONE);
>  		skb_queue_head_init(&newsk->sk_error_queue);
> 
> -		filter = rcu_dereference_const(newsk->sk_filter);
> +		filter = rcu_dereference_bh_const(newsk->sk_filter);
>  		if (filter != NULL)
>  			sk_filter_charge(newsk, filter);
> 
> diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
> index a7bf03c..22ec1d1 100644
> --- a/net/decnet/dn_route.c
> +++ b/net/decnet/dn_route.c
> @@ -92,7 +92,7 @@
> 
>  struct dn_rt_hash_bucket
>  {
> -	struct dn_route *chain;
> +	struct dn_route __rcu_bh *chain;
>  	spinlock_t lock;
>  };
> 
> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index 37bf0d9..99cef80 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -200,7 +200,7 @@ const __u8 ip_tos2prio[16] = {
>   */
> 
>  struct rt_hash_bucket {
> -	struct rtable __rcu *chain;
> +	struct rtable __rcu_bh *chain;
>  };
> 
>  #if defined(CONFIG_SMP) || defined(CONFIG_DEBUG_SPINLOCK) || \
> @@ -731,26 +731,26 @@ static void rt_do_flush(int process_context)
>  		spin_lock_bh(rt_hash_lock_addr(i));
>  #ifdef CONFIG_NET_NS
>  		{
> -		struct rtable __rcu ** prev;
> +		struct rtable __rcu_bh ** prev;
>  		struct rtable * p;
> 
> -		rth = rcu_dereference_const(rt_hash_table[i].chain);
> +		rth = rcu_dereference_bh(rt_hash_table[i].chain);
> 
>  		/* defer releasing the head of the list after spin_unlock */
> -		for (tail = rth; tail; tail = rcu_dereference_const(tail->u.dst.rt_next))
> +		for (tail = rth; tail; tail = rcu_dereference_bh(tail->u.dst.rt_next))
>  			if (!rt_is_expired(tail))
>  				break;
>  		if (rth != tail)
> -			__rcu_assign_pointer(rt_hash_table[i].chain, tail);
> +			rcu_assign_pointer_bh(rt_hash_table[i].chain, tail);
> 
>  		/* call rt_free on entries after the tail requiring flush */
>  		prev = &rt_hash_table[i].chain;
> -		for (p = rcu_dereference_const(*prev); p; p = next) {
> -			next = rcu_dereference_const(p->u.dst.rt_next);
> +		for (p = rcu_dereference_bh(*prev); p; p = next) {
> +			next = rcu_dereference_bh(p->u.dst.rt_next);
>  			if (!rt_is_expired(p)) {
>  				prev = &p->u.dst.rt_next;
>  			} else {
> -				__rcu_assign_pointer(*prev, next);
> +				rcu_assign_pointer_bh(*prev, next);
>  				rt_free(p);
>  			}
>  		}
> @@ -763,7 +763,7 @@ static void rt_do_flush(int process_context)
>  		spin_unlock_bh(rt_hash_lock_addr(i));
> 
>  		for (; rth != tail; rth = next) {
> -			next = rcu_dereference_const(rth->u.dst.rt_next);
> +			next = rcu_dereference_bh(rth->u.dst.rt_next);
>  			rt_free(rth);
>  		}
>  	}
> @@ -785,7 +785,7 @@ static void rt_check_expire(void)
>  	static unsigned int rover;
>  	unsigned int i = rover, goal;
>  	struct rtable *rth, *aux;
> -	struct rtable __rcu **rthp;
> +	struct rtable __rcu_bh **rthp;
>  	unsigned long samples = 0;
>  	unsigned long sum = 0, sum2 = 0;
>  	unsigned long delta;
> @@ -815,8 +815,8 @@ static void rt_check_expire(void)
>  			continue;
>  		length = 0;
>  		spin_lock_bh(rt_hash_lock_addr(i));
> -		while ((rth = rcu_dereference_const(*rthp)) != NULL) {
> -			prefetch(rcu_dereference_const(rth->u.dst.rt_next));
> +		while ((rth = rcu_dereference_bh(*rthp)) != NULL) {
> +			prefetch(rcu_dereference_bh(rth->u.dst.rt_next));
>  			if (rt_is_expired(rth)) {
>  				*rthp = rth->u.dst.rt_next;
>  				rt_free(rth);
> @@ -836,14 +836,14 @@ nofree:
>  					 * attributes don't unfairly skew
>  					 * the length computation
>  					 */
> -					for (aux = rcu_dereference_const(rt_hash_table[i].chain);;) {
> +					for (aux = rcu_dereference_bh(rt_hash_table[i].chain);;) {
>  						if (aux == rth) {
>  							length += ONE;
>  							break;
>  						}
>  						if (compare_hash_inputs(&aux->fl, &rth->fl))
>  							break;
> -						aux = rcu_dereference_const(aux->u.dst.rt_next);
> +						aux = rcu_dereference_bh(aux->u.dst.rt_next);
>  					}
>  					continue;
>  				}
> @@ -959,7 +959,7 @@ static int rt_garbage_collect(struct dst_ops *ops)
>  	static int rover;
>  	static int equilibrium;
>  	struct rtable *rth;
> -	struct rtable __rcu **rthp;
> +	struct rtable __rcu_bh **rthp;
>  	unsigned long now = jiffies;
>  	int goal;
> 
> @@ -1012,7 +1012,7 @@ static int rt_garbage_collect(struct dst_ops *ops)
>  			k = (k + 1) & rt_hash_mask;
>  			rthp = &rt_hash_table[k].chain;
>  			spin_lock_bh(rt_hash_lock_addr(k));
> -			while ((rth = rcu_dereference_const(*rthp)) != NULL) {
> +			while ((rth = rcu_dereference_bh(*rthp)) != NULL) {
>  				if (!rt_is_expired(rth) &&
>  					!rt_may_expire(rth, tmo, expire)) {
>  					tmo >>= 1;
> @@ -1079,10 +1079,10 @@ static int rt_intern_hash(unsigned hash, struct rtable *rt,
>  			  struct rtable **rp, struct sk_buff *skb)
>  {
>  	struct rtable	*rth;
> -	struct rtable __rcu **rthp;
> +	struct rtable __rcu_bh **rthp;
>  	unsigned long	now;
>  	struct rtable *cand;
> -	struct rtable __rcu **candp;
> +	struct rtable __rcu_bh **candp;
>  	u32 		min_score;
>  	int		chain_length;
>  	int attempts = !in_softirq();
> @@ -1129,7 +1129,7 @@ restart:
>  	rthp = &rt_hash_table[hash].chain;
> 
>  	spin_lock_bh(rt_hash_lock_addr(hash));
> -	while ((rth = rcu_dereference_const(*rthp)) != NULL) {
> +	while ((rth = rcu_dereference_bh(*rthp)) != NULL) {
>  		if (rt_is_expired(rth)) {
>  			*rthp = rth->u.dst.rt_next;
>  			rt_free(rth);
> @@ -1143,13 +1143,13 @@ restart:
>  			 * must be visible to another weakly ordered CPU before
>  			 * the insertion at the start of the hash chain.
>  			 */
> -			rcu_assign_pointer(rth->u.dst.rt_next,
> +			rcu_assign_pointer_bh(rth->u.dst.rt_next,
>  					   rt_hash_table[hash].chain);
>  			/*
>  			 * Since lookup is lockfree, the update writes
>  			 * must be ordered for consistency on SMP.
>  			 */
> -			rcu_assign_pointer(rt_hash_table[hash].chain, rth);
> +			rcu_assign_pointer_bh(rt_hash_table[hash].chain, rth);
> 
>  			dst_use(&rth->u.dst, now);
>  			spin_unlock_bh(rt_hash_lock_addr(hash));
> @@ -1252,7 +1252,7 @@ restart:
>  	 * previous writes to rt are comitted to memory
>  	 * before making rt visible to other CPUS.
>  	 */
> -	rcu_assign_pointer(rt_hash_table[hash].chain, rt);
> +	rcu_assign_pointer_bh(rt_hash_table[hash].chain, rt);
> 
>  	spin_unlock_bh(rt_hash_lock_addr(hash));
> 
> @@ -1325,13 +1325,13 @@ void __ip_select_ident(struct iphdr *iph, struct dst_entry *dst, int more)
> 
>  static void rt_del(unsigned hash, struct rtable *rt)
>  {
> -	struct rtable __rcu **rthp;
> +	struct rtable __rcu_bh **rthp;
>  	struct rtable *aux;
> 
>  	rthp = &rt_hash_table[hash].chain;
>  	spin_lock_bh(rt_hash_lock_addr(hash));
>  	ip_rt_put(rt);
> -	while ((aux = rcu_dereference_const(*rthp)) != NULL) {
> +	while ((aux = rcu_dereference_bh(*rthp)) != NULL) {
>  		if (aux == rt || rt_is_expired(aux)) {
>  			*rthp = aux->u.dst.rt_next;
>  			rt_free(aux);
> @@ -1348,7 +1348,7 @@ void ip_rt_redirect(__be32 old_gw, __be32 daddr, __be32 new_gw,
>  	int i, k;
>  	struct in_device *in_dev = in_dev_get(dev);
>  	struct rtable *rth;
> -	struct rtable __rcu **rthp;
> +	struct rtable __rcu_bh **rthp;
>  	__be32  skeys[2] = { saddr, 0 };
>  	int  ikeys[2] = { dev->ifindex, 0 };
>  	struct netevent_redirect netevent;
> @@ -1384,7 +1384,7 @@ void ip_rt_redirect(__be32 old_gw, __be32 daddr, __be32 new_gw,
>  			rthp=&rt_hash_table[hash].chain;
> 
>  			rcu_read_lock();
> -			while ((rth = rcu_dereference(*rthp)) != NULL) {
> +			while ((rth = rcu_dereference_bh(*rthp)) != NULL) {
>  				struct rtable *rt;
> 
>  				if (rth->fl.fl4_dst != daddr ||
> @@ -1646,8 +1646,8 @@ unsigned short ip_rt_frag_needed(struct net *net, struct iphdr *iph,
>  						rt_genid(net));
> 
>  			rcu_read_lock();
> -			for (rth = rcu_dereference(rt_hash_table[hash].chain); rth;
> -			     rth = rcu_dereference(rth->u.dst.rt_next)) {
> +			for (rth = rcu_dereference_bh(rt_hash_table[hash].chain); rth;
> +			     rth = rcu_dereference_bh(rth->u.dst.rt_next)) {
>  				unsigned short mtu = new_mtu;
> 
>  				if (rth->fl.fl4_dst != daddr ||
> @@ -2287,8 +2287,8 @@ int ip_route_input(struct sk_buff *skb, __be32 daddr, __be32 saddr,
>  	hash = rt_hash(daddr, saddr, iif, rt_genid(net));
> 
>  	rcu_read_lock();
> -	for (rth = rcu_dereference(rt_hash_table[hash].chain); rth;
> -	     rth = rcu_dereference(rth->u.dst.rt_next)) {
> +	for (rth = rcu_dereference_bh(rt_hash_table[hash].chain); rth;
> +	     rth = rcu_dereference_bh(rth->u.dst.rt_next)) {
>  		if (((rth->fl.fl4_dst ^ daddr) |
>  		     (rth->fl.fl4_src ^ saddr) |
>  		     (rth->fl.iif ^ iif) |
> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
> index d8ce05b..003d54f 100644
> --- a/net/ipv4/tcp.c
> +++ b/net/ipv4/tcp.c
> @@ -3252,9 +3252,9 @@ void __init tcp_init(void)
>  	memset(&tcp_secret_two.secrets[0], 0, sizeof(tcp_secret_two.secrets));
>  	tcp_secret_one.expires = jiffy; /* past due */
>  	tcp_secret_two.expires = jiffy; /* past due */
> -	__rcu_assign_pointer(tcp_secret_generating, &tcp_secret_one);
> +	rcu_assign_pointer(tcp_secret_generating, &tcp_secret_one);
>  	tcp_secret_primary = &tcp_secret_one;
> -	__rcu_assign_pointer(tcp_secret_retiring, &tcp_secret_two);
> +	rcu_assign_pointer(tcp_secret_retiring, &tcp_secret_two);
>  	tcp_secret_secondary = &tcp_secret_two;
>  }
> 
> diff --git a/net/llc/llc_core.c b/net/llc/llc_core.c
> index ed7f424..8696677 100644
> --- a/net/llc/llc_core.c
> +++ b/net/llc/llc_core.c
> @@ -50,7 +50,7 @@ static struct llc_sap *__llc_sap_find(unsigned char sap_value)
>  {
>  	struct llc_sap* sap;
> 
> -	list_for_each_entry(sap, &llc_sap_list, node)
> +	list_for_each_entry_rcu(sap, &llc_sap_list, node)
>  		if (sap->laddr.lsap == sap_value)
>  			goto out;
>  	sap = NULL;
> @@ -103,7 +103,7 @@ struct llc_sap *llc_sap_open(unsigned char lsap,
>  	if (!sap)
>  		goto out;
>  	sap->laddr.lsap = lsap;
> -	rcu_assign_pointer(sap->rcv_func, func);
> +	rcu_assign_pointer_bh(sap->rcv_func, func);
>  	list_add_tail_rcu(&sap->node, &llc_sap_list);
>  out:
>  	spin_unlock_bh(&llc_sap_list_lock);
> @@ -127,7 +127,7 @@ void llc_sap_close(struct llc_sap *sap)
>  	list_del_rcu(&sap->node);
>  	spin_unlock_bh(&llc_sap_list_lock);
> 
> -	synchronize_rcu();
> +	synchronize_rcu_bh();
> 
>  	kfree(sap);
>  }
> diff --git a/net/llc/llc_input.c b/net/llc/llc_input.c
> index 57ad974..b775530 100644
> --- a/net/llc/llc_input.c
> +++ b/net/llc/llc_input.c
> @@ -179,7 +179,7 @@ int llc_rcv(struct sk_buff *skb, struct net_device *dev,
>  	 * First the upper layer protocols that don't need the full
>  	 * LLC functionality
>  	 */
> -	rcv = rcu_dereference(sap->rcv_func);
> +	rcv = rcu_dereference_bh(sap->rcv_func);
>  	if (rcv) {
>  		struct sk_buff *cskb = skb_clone(skb, GFP_ATOMIC);
>  		if (cskb)
> diff --git a/virt/kvm/iommu.c b/virt/kvm/iommu.c
> index 80fd3ad..2ba7048 100644
> --- a/virt/kvm/iommu.c
> +++ b/virt/kvm/iommu.c
> @@ -78,7 +78,7 @@ static int kvm_iommu_map_memslots(struct kvm *kvm)
>  	int i, r = 0;
>  	struct kvm_memslots *slots;
> 
> -	slots = rcu_dereference(kvm->memslots);
> +	slots = srcu_dereference(kvm->memslots, &kvm->srcu);
> 
>  	for (i = 0; i < slots->nmemslots; i++) {
>  		r = kvm_iommu_map_pages(kvm, &slots->memslots[i]);
> @@ -217,7 +217,7 @@ static int kvm_iommu_unmap_memslots(struct kvm *kvm)
>  	int i;
>  	struct kvm_memslots *slots;
> 
> -	slots = rcu_dereference(kvm->memslots);
> +	slots = srcu_dereference(kvm->memslots, &kvm->srcu);
> 
>  	for (i = 0; i < slots->nmemslots; i++) {
>  		kvm_iommu_put_pages(kvm, slots->memslots[i].base_gfn,
> diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
> index 548f925..ae28c71 100644
> --- a/virt/kvm/kvm_main.c
> +++ b/virt/kvm/kvm_main.c
> @@ -372,6 +372,8 @@ static struct kvm *kvm_create_vm(void)
>  {
>  	int r = 0, i;
>  	struct kvm *kvm = kvm_arch_create_vm();
> +	struct kvm_io_bus *buses[KVM_NR_BUSES];
> +	struct kvm_memslots *memslots;

This one looks like more that simply an RCU change...

OK, I get it -- you are creating these temporaries in order to avoid
overflowing the line.  Never mind!!!  ;-)

>  	if (IS_ERR(kvm))
>  		goto out;
> @@ -386,14 +388,15 @@ static struct kvm *kvm_create_vm(void)
>  #endif
> 
>  	r = -ENOMEM;
> -	kvm->memslots = kzalloc(sizeof(struct kvm_memslots), GFP_KERNEL);
> +	memslots = kzalloc(sizeof(struct kvm_memslots), GFP_KERNEL);
> +	srcu_assign_pointer(kvm->memslots, memslots);
>  	if (!kvm->memslots)
>  		goto out_err;
>  	if (init_srcu_struct(&kvm->srcu))
>  		goto out_err;
>  	for (i = 0; i < KVM_NR_BUSES; i++) {
> -		kvm->buses[i] = kzalloc(sizeof(struct kvm_io_bus),
> -					GFP_KERNEL);
> +		buses[i] = kzalloc(sizeof(struct kvm_io_bus), GFP_KERNEL);
> +		srcu_assign_pointer(kvm->buses[i], buses[i]);

But why do you need an array for "buses" instead of only one variable?

>  		if (!kvm->buses[i]) {
>  			cleanup_srcu_struct(&kvm->srcu);
>  			goto out_err;
> @@ -428,8 +431,8 @@ out_err:
>  	hardware_disable_all();
>  out_err_nodisable:
>  	for (i = 0; i < KVM_NR_BUSES; i++)
> -		kfree(kvm->buses[i]);
> -	kfree(kvm->memslots);
> +		kfree(buses[i]);

OK, I see what you are trying to do.  But why not free all the non-NULL
ones from the kvm-> structure, and then use a single "buses" rather than
an array of them?  Perhaps running "i" down from whereever the earlier
loop left it, in case it is difficult to zero the underlying kvm->
structure?

Just trying to save a bit of stack space...

> +	kfree(memslots);
>  	kfree(kvm);
>  	return ERR_PTR(r);
>  }
> @@ -464,12 +467,12 @@ static void kvm_free_physmem_slot(struct kvm_memory_slot *free,
>  void kvm_free_physmem(struct kvm *kvm)
>  {
>  	int i;
> -	struct kvm_memslots *slots = kvm->memslots;
> +	struct kvm_memslots *slots = srcu_dereference_const(kvm->memslots);
> 
>  	for (i = 0; i < slots->nmemslots; ++i)
>  		kvm_free_physmem_slot(&slots->memslots[i], NULL);
> 
> -	kfree(kvm->memslots);
> +	kfree(slots);
>  }
> 
>  static void kvm_destroy_vm(struct kvm *kvm)
> @@ -483,7 +486,7 @@ static void kvm_destroy_vm(struct kvm *kvm)
>  	spin_unlock(&kvm_lock);
>  	kvm_free_irq_routing(kvm);
>  	for (i = 0; i < KVM_NR_BUSES; i++)
> -		kvm_io_bus_destroy(kvm->buses[i]);
> +		kvm_io_bus_destroy(srcu_dereference_const(kvm->buses[i]));
>  	kvm_coalesced_mmio_free(kvm);
>  #if defined(CONFIG_MMU_NOTIFIER) && defined(KVM_ARCH_WANT_MMU_NOTIFIER)
>  	mmu_notifier_unregister(&kvm->mmu_notifier, kvm->mm);
> @@ -552,7 +555,8 @@ int __kvm_set_memory_region(struct kvm *kvm,
>  	if (mem->guest_phys_addr + mem->memory_size < mem->guest_phys_addr)
>  		goto out;
> 
> -	memslot = &kvm->memslots->memslots[mem->slot];
> +	old_memslots = srcu_dereference(kvm->memslots, &kvm->srcu);
> +	memslot = &old_memslots->memslots[mem->slot];
>  	base_gfn = mem->guest_phys_addr >> PAGE_SHIFT;
>  	npages = mem->memory_size >> PAGE_SHIFT;
> 
> @@ -573,7 +577,7 @@ int __kvm_set_memory_region(struct kvm *kvm,
>  	/* Check for overlaps */
>  	r = -EEXIST;
>  	for (i = 0; i < KVM_MEMORY_SLOTS; ++i) {
> -		struct kvm_memory_slot *s = &kvm->memslots->memslots[i];
> +		struct kvm_memory_slot *s = &old_memslots->memslots[i];
> 
>  		if (s == memslot || !s->npages)
>  			continue;
> @@ -669,13 +673,13 @@ skip_lpage:
>  		slots = kzalloc(sizeof(struct kvm_memslots), GFP_KERNEL);
>  		if (!slots)
>  			goto out_free;
> -		memcpy(slots, kvm->memslots, sizeof(struct kvm_memslots));
> +		old_memslots = srcu_dereference_const(kvm->memslots);
> +		memcpy(slots, old_memslots, sizeof(struct kvm_memslots));
>  		if (mem->slot >= slots->nmemslots)
>  			slots->nmemslots = mem->slot + 1;
>  		slots->memslots[mem->slot].flags |= KVM_MEMSLOT_INVALID;
> 
> -		old_memslots = kvm->memslots;
> -		rcu_assign_pointer(kvm->memslots, slots);
> +		srcu_assign_pointer(kvm->memslots, slots);
>  		synchronize_srcu_expedited(&kvm->srcu);
>  		/* From this point no new shadow pages pointing to a deleted
>  		 * memslot will be created.
> @@ -705,7 +709,8 @@ skip_lpage:
>  	slots = kzalloc(sizeof(struct kvm_memslots), GFP_KERNEL);
>  	if (!slots)
>  		goto out_free;
> -	memcpy(slots, kvm->memslots, sizeof(struct kvm_memslots));
> +	old_memslots = srcu_dereference_const(kvm->memslots);
> +	memcpy(slots, old_memslots, sizeof(struct kvm_memslots));
>  	if (mem->slot >= slots->nmemslots)
>  		slots->nmemslots = mem->slot + 1;
> 
> @@ -718,8 +723,7 @@ skip_lpage:
>  	}
> 
>  	slots->memslots[mem->slot] = new;
> -	old_memslots = kvm->memslots;
> -	rcu_assign_pointer(kvm->memslots, slots);
> +	srcu_assign_pointer(kvm->memslots, slots);
>  	synchronize_srcu_expedited(&kvm->srcu);
> 
>  	kvm_arch_commit_memory_region(kvm, mem, old, user_alloc);
> @@ -775,7 +779,7 @@ int kvm_get_dirty_log(struct kvm *kvm,
>  	if (log->slot >= KVM_MEMORY_SLOTS)
>  		goto out;
> 
> -	memslot = &kvm->memslots->memslots[log->slot];
> +	memslot = &srcu_dereference(kvm->memslots, &kvm->srcu)->memslots[log->slot];
>  	r = -ENOENT;
>  	if (!memslot->dirty_bitmap)
>  		goto out;
> @@ -829,7 +833,7 @@ EXPORT_SYMBOL_GPL(kvm_is_error_hva);
>  struct kvm_memory_slot *gfn_to_memslot_unaliased(struct kvm *kvm, gfn_t gfn)
>  {
>  	int i;
> -	struct kvm_memslots *slots = rcu_dereference(kvm->memslots);
> +	struct kvm_memslots *slots = srcu_dereference(kvm->memslots, &kvm->srcu);
> 
>  	for (i = 0; i < slots->nmemslots; ++i) {
>  		struct kvm_memory_slot *memslot = &slots->memslots[i];
> @@ -851,7 +855,7 @@ struct kvm_memory_slot *gfn_to_memslot(struct kvm *kvm, gfn_t gfn)
>  int kvm_is_visible_gfn(struct kvm *kvm, gfn_t gfn)
>  {
>  	int i;
> -	struct kvm_memslots *slots = rcu_dereference(kvm->memslots);
> +	struct kvm_memslots *slots = srcu_dereference(kvm->memslots, &kvm->srcu);
> 
>  	gfn = unalias_gfn_instantiation(kvm, gfn);
>  	for (i = 0; i < KVM_MEMORY_SLOTS; ++i) {
> @@ -895,7 +899,7 @@ out:
>  int memslot_id(struct kvm *kvm, gfn_t gfn)
>  {
>  	int i;
> -	struct kvm_memslots *slots = rcu_dereference(kvm->memslots);
> +	struct kvm_memslots *slots = srcu_dereference(kvm->memslots, &kvm->srcu);
>  	struct kvm_memory_slot *memslot = NULL;
> 
>  	gfn = unalias_gfn(kvm, gfn);
> @@ -1984,7 +1988,7 @@ int kvm_io_bus_write(struct kvm *kvm, enum kvm_bus bus_idx, gpa_t addr,
>  		     int len, const void *val)
>  {
>  	int i;
> -	struct kvm_io_bus *bus = rcu_dereference(kvm->buses[bus_idx]);
> +	struct kvm_io_bus *bus = srcu_dereference(kvm->buses[bus_idx], &kvm->srcu);
>  	for (i = 0; i < bus->dev_count; i++)
>  		if (!kvm_iodevice_write(bus->devs[i], addr, len, val))
>  			return 0;
> @@ -1996,7 +2000,7 @@ int kvm_io_bus_read(struct kvm *kvm, enum kvm_bus bus_idx, gpa_t addr,
>  		    int len, void *val)
>  {
>  	int i;
> -	struct kvm_io_bus *bus = rcu_dereference(kvm->buses[bus_idx]);
> +	struct kvm_io_bus *bus = srcu_dereference(kvm->buses[bus_idx], &kvm->srcu);
> 
>  	for (i = 0; i < bus->dev_count; i++)
>  		if (!kvm_iodevice_read(bus->devs[i], addr, len, val))
> @@ -2010,7 +2014,7 @@ int kvm_io_bus_register_dev(struct kvm *kvm, enum kvm_bus bus_idx,
>  {
>  	struct kvm_io_bus *new_bus, *bus;
> 
> -	bus = kvm->buses[bus_idx];
> +	bus = srcu_dereference_const(kvm->buses[bus_idx]);
>  	if (bus->dev_count > NR_IOBUS_DEVS-1)
>  		return -ENOSPC;
> 
> @@ -2019,7 +2023,7 @@ int kvm_io_bus_register_dev(struct kvm *kvm, enum kvm_bus bus_idx,
>  		return -ENOMEM;
>  	memcpy(new_bus, bus, sizeof(struct kvm_io_bus));
>  	new_bus->devs[new_bus->dev_count++] = dev;
> -	rcu_assign_pointer(kvm->buses[bus_idx], new_bus);
> +	srcu_assign_pointer(kvm->buses[bus_idx], new_bus);
>  	synchronize_srcu_expedited(&kvm->srcu);
>  	kfree(bus);
> 
> @@ -2037,7 +2041,7 @@ int kvm_io_bus_unregister_dev(struct kvm *kvm, enum kvm_bus bus_idx,
>  	if (!new_bus)
>  		return -ENOMEM;
> 
> -	bus = kvm->buses[bus_idx];
> +	bus = srcu_dereference_const(kvm->buses[bus_idx]);
>  	memcpy(new_bus, bus, sizeof(struct kvm_io_bus));
> 
>  	r = -ENOENT;
> @@ -2053,7 +2057,7 @@ int kvm_io_bus_unregister_dev(struct kvm *kvm, enum kvm_bus bus_idx,
>  		return r;
>  	}
> 
> -	rcu_assign_pointer(kvm->buses[bus_idx], new_bus);
> +	srcu_assign_pointer(kvm->buses[bus_idx], new_bus);
>  	synchronize_srcu_expedited(&kvm->srcu);
>  	kfree(bus);
>  	return r;
> 
