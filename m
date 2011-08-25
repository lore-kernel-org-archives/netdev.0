From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC] per-containers tcp buffer limitation
Date: Wed, 24 Aug 2011 17:35:19 -0700
Message-ID: <m1k4a2qqew.fsf@fess.ebiederm.org>
References: <4E558137.5020900@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>,
	Linux Containers <containers@lists.osdl.org>,
	Pavel Emelyanov <xemul@parallels.com>
To: Glauber Costa <glommer@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:34393 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751197Ab1HYAfa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2011 20:35:30 -0400
In-Reply-To: <4E558137.5020900@parallels.com> (Glauber Costa's message of
	"Wed, 24 Aug 2011 19:54:47 -0300")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Glauber Costa <glommer@parallels.com> writes:

> Hello,
>
> This is a proof of concept of some code I have here to limit tcp send and
> receive buffers per-container (in our case). At this phase, I am more concerned
> in discussing my approach, so please curse my family no further than the 3rd
> generation.
>
> The problem we're trying to attack here, is that buffers can grow and fill
> non-reclaimable kernel memory. When doing containers, we can't afford having a
> malicious container pinning kernel memory at will, therefore exhausting all the
> others.
>
> So here a container will be seen in the host system as a group of tasks, grouped
> in a cgroup. This cgroup will have files allowing us to specify global
> per-cgroup limits on buffers. For that purpose, I created a new sockets cgroup -
> didn't really think any other one of the existing would do here.
>
> As for the network code per-se, I tried to keep the same code that deals with
> memory schedule as a basis and make it per-cgroup.
> You will notice that struct proto now take function pointers to values
> controlling memory pressure and will return per-cgroup data instead of global
> ones. So the current behavior is maintained: after the first threshold is hit,
> we enter memory pressure. After that, allocations are suppressed.
>
> Only tcp code was really touched here. udp had the pointers filled, but we're
> not really controlling anything. But the fact that this lives in generic code,
> makes it easier to do the same for other protocols in the future.
>
> For this patch specifically, I am not touching - just provisioning - 
> rmem and wmem specific knobs. I should also #ifdef a lot of this, but hey,
> remember: rfc...
>
> One drawback of this approach I found, is that cgroups does not really work well
> with modules. A lot of the network code is modularized, so this would have to be
> fixed somehow.
>
> Let me know what you think.

Can you implement this by making the existing network sysctls per
network namespace?

At a quick skim it looks to me like you can make the existing sysctls
per network namespace and solve the issues you are aiming at solving and
that should make the code much simpler, than your proof of concept code.

Any implementation of this needs to answer the question how much
overhead does this extra accounting add.  I don't have a clue how much
overhead you are adding but you are making structures larger and I
suspect adding at least another cache line miss, so I suspect your
changes will impact real world socket performance.

Eric


> diff --git a/include/linux/cgroup_subsys.h b/include/linux/cgroup_subsys.h
> index ac663c1..744eb2c 100644
> --- a/include/linux/cgroup_subsys.h
> +++ b/include/linux/cgroup_subsys.h
> @@ -53,6 +53,8 @@ SUBSYS(freezer)
>  SUBSYS(net_cls)
>  #endif
>  
> +SUBSYS(sockets)
> +
>  /* */
>  
>  #ifdef CONFIG_BLK_CGROUP
> diff --git a/include/net/sock.h b/include/net/sock.h
> index 8e4062f..aae468f 100644
> --- a/include/net/sock.h
> +++ b/include/net/sock.h
> @@ -63,6 +63,33 @@
>  #include <net/dst.h>
>  #include <net/checksum.h>
>  
> +#include <linux/cgroup.h>
> +
> +struct sockets_cgrp
> +{
> +	struct cgroup_subsys_state css;
> +	struct sockets_cgrp *parent;
> +	int tcp_memory_pressure;
> +	int tcp_max_memory;
> +	atomic_long_t tcp_memory_allocated;
> +	struct percpu_counter tcp_sockets_allocated;
> +	long tcp_prot_mem[3];
> +
> +	atomic_long_t udp_memory_allocated;
> +};
> +
> +static inline struct sockets_cgrp *cgroup_sk(struct cgroup *cgrp)
> +{
> +	return container_of(cgroup_subsys_state(cgrp, sockets_subsys_id),
> +		struct sockets_cgrp, css);
> +}
> +
> +static inline struct sockets_cgrp *task_sk(struct task_struct *tsk)
> +{
> +	return container_of(task_subsys_state(tsk, sockets_subsys_id),
> +		struct sockets_cgrp, css);
> +}
> +
>  /*
>   * This structure really needs to be cleaned up.
>   * Most of it is for TCP, and not used by any of
> @@ -339,6 +366,7 @@ struct sock {
>  #endif
>  	__u32			sk_mark;
>  	u32			sk_classid;
> +	struct sockets_cgrp	*sk_cgrp;
>  	void			(*sk_state_change)(struct sock *sk);
>  	void			(*sk_data_ready)(struct sock *sk, int bytes);
>  	void			(*sk_write_space)(struct sock *sk);
> @@ -785,19 +813,21 @@ struct proto {
>  #endif
>  
>  	/* Memory pressure */
> -	void			(*enter_memory_pressure)(struct sock *sk);
> -	atomic_long_t		*memory_allocated;	/* Current allocated memory. */
> -	struct percpu_counter	*sockets_allocated;	/* Current number of sockets. */
> +	void			(*enter_memory_pressure)(struct sockets_cgrp *sg);
> +	atomic_long_t		*(*memory_allocated)(struct sockets_cgrp *sg);	/* Current allocated memory. */
> +	struct percpu_counter	*(*sockets_allocated)(struct sockets_cgrp *sg);	/* Current number of sockets. */
> +
> +	int			(*init_cgroup)(struct cgroup *cgrp, struct cgroup_subsys *ss);
>  	/*
>  	 * Pressure flag: try to collapse.
>  	 * Technical note: it is used by multiple contexts non atomically.
>  	 * All the __sk_mem_schedule() is of this nature: accounting
>  	 * is strict, actions are advisory and have some latency.
>  	 */
> -	int			*memory_pressure;
> -	long			*sysctl_mem;
> -	int			*sysctl_wmem;
> -	int			*sysctl_rmem;
> +	int			*(*memory_pressure)(struct sockets_cgrp *sg);
> +	long			*(*prot_mem)(struct sockets_cgrp *sg);
> +	int			*(*prot_wmem)(struct sock *sk);
> +	int			*(*prot_rmem)(struct sock *sk);
>  	int			max_header;
>  	bool			no_autobind;
>  
> @@ -826,6 +856,20 @@ struct proto {
>  #endif
>  };
>  
> +#define sk_memory_pressure(prot, sg)				\
> +({								\
> +	int *__ret = NULL;  					\
> +	if (prot->memory_pressure)			\
> +		__ret = prot->memory_pressure(sg); 	\
> +	__ret; 							\
> +})
> +
> +#define sk_sockets_allocated(prot, sg) ({ struct percpu_counter *__p = prot->sockets_allocated(sg); __p; })
> +#define sk_prot_mem(prot, sg) ({ long *__mem = prot->prot_mem(sg); __mem; })
> +#define sk_prot_rmem(sk) ({ int *__mem = sk->sk_prot->prot_rmem(sk); __mem; })
> +#define sk_prot_wmem(sk) ({ int *__mem = sk->sk_prot->prot_wmem(sk); __mem; })
> +#define sk_memory_allocated(prot, sg) ({ atomic_long_t *__mem = prot->memory_allocated(sg); __mem; })
> +
>  extern int proto_register(struct proto *prot, int alloc_slab);
>  extern void proto_unregister(struct proto *prot);
>  
> @@ -1658,10 +1702,11 @@ struct sk_buff *sk_stream_alloc_skb(struct sock *sk, int size, gfp_t gfp);
>  static inline struct page *sk_stream_alloc_page(struct sock *sk)
>  {
>  	struct page *page = NULL;
> +	struct sockets_cgrp *sg = sk->sk_cgrp;
>  
>  	page = alloc_pages(sk->sk_allocation, 0);
>  	if (!page) {
> -		sk->sk_prot->enter_memory_pressure(sk);
> +		sk->sk_prot->enter_memory_pressure(sg);
>  		sk_stream_moderate_sndbuf(sk);
>  	}
>  	return page;
> diff --git a/include/net/tcp.h b/include/net/tcp.h
> index 149a415..64318ee 100644
> --- a/include/net/tcp.h
> +++ b/include/net/tcp.h
> @@ -255,7 +255,14 @@ extern int sysctl_tcp_thin_dupack;
>  
>  extern atomic_long_t tcp_memory_allocated;
>  extern struct percpu_counter tcp_sockets_allocated;
> -extern int tcp_memory_pressure;
> +
> +extern long *tcp_sysctl_mem(struct sockets_cgrp *sg);
> +struct percpu_counter *sockets_allocated_tcp(struct sockets_cgrp *sg);
> +int *memory_pressure_tcp(struct sockets_cgrp *sg);
> +int tcp_init_cgroup(struct cgroup *cgrp, struct cgroup_subsys *ss);
> +atomic_long_t *memory_allocated_tcp(struct sockets_cgrp *sg);
> +int *tcp_sysctl_wmem(struct sock *sk);
> +int *tcp_sysctl_rmem(struct sock *sk);
>  
>  /*
>   * The next routines deal with comparing 32 bit unsigned ints
> @@ -278,6 +285,9 @@ static inline bool tcp_too_many_orphans(struct sock *sk, int shift)
>  {
>  	struct percpu_counter *ocp = sk->sk_prot->orphan_count;
>  	int orphans = percpu_counter_read_positive(ocp);
> +	struct sockets_cgrp *sg = sk->sk_cgrp;
> +
> +	long *prot_mem = sk_prot_mem(sk->sk_prot, sg);
>  
>  	if (orphans << shift > sysctl_tcp_max_orphans) {
>  		orphans = percpu_counter_sum_positive(ocp);
> @@ -286,7 +296,7 @@ static inline bool tcp_too_many_orphans(struct sock *sk, int shift)
>  	}
>  
>  	if (sk->sk_wmem_queued > SOCK_MIN_SNDBUF &&
> -	    atomic_long_read(&tcp_memory_allocated) > sysctl_tcp_mem[2])
> +	    atomic_long_read(&tcp_memory_allocated) > prot_mem[2])
>  		return true;
>  	return false;
>  }
> @@ -999,7 +1009,7 @@ static inline void tcp_openreq_init(struct request_sock *req,
>  	ireq->loc_port = tcp_hdr(skb)->dest;
>  }
>  
> -extern void tcp_enter_memory_pressure(struct sock *sk);
> +extern void tcp_enter_memory_pressure(struct sockets_cgrp *sg);
>  
>  static inline int keepalive_intvl_when(const struct tcp_sock *tp)
>  {
> diff --git a/include/trace/events/sock.h b/include/trace/events/sock.h
> index 779abb9..52a2258 100644
> --- a/include/trace/events/sock.h
> +++ b/include/trace/events/sock.h
> @@ -31,34 +31,35 @@ TRACE_EVENT(sock_rcvqueue_full,
>  
>  TRACE_EVENT(sock_exceed_buf_limit,
>  
> -	TP_PROTO(struct sock *sk, struct proto *prot, long allocated),
> +	TP_PROTO(struct sock *sk, struct proto *prot, long allocated,
> +		 long *prot_mem, int *prot_rmem),
>  
> -	TP_ARGS(sk, prot, allocated),
> +	TP_ARGS(sk, prot, allocated, prot_mem, prot_rmem),
>  
>  	TP_STRUCT__entry(
>  		__array(char, name, 32)
> -		__field(long *, sysctl_mem)
> +		__field(long *, prot_mem)
>  		__field(long, allocated)
> -		__field(int, sysctl_rmem)
> +		__field(int, prot_rmem)
>  		__field(int, rmem_alloc)
>  	),
>  
>  	TP_fast_assign(
>  		strncpy(__entry->name, prot->name, 32);
> -		__entry->sysctl_mem = prot->sysctl_mem;
> +		__entry->prot_mem = prot_mem;
>  		__entry->allocated = allocated;
> -		__entry->sysctl_rmem = prot->sysctl_rmem[0];
> +		__entry->prot_rmem = prot_rmem[0];
>  		__entry->rmem_alloc = atomic_read(&sk->sk_rmem_alloc);
>  	),
>  
>  	TP_printk("proto:%s sysctl_mem=%ld,%ld,%ld allocated=%ld "
>  		"sysctl_rmem=%d rmem_alloc=%d",
>  		__entry->name,
> -		__entry->sysctl_mem[0],
> -		__entry->sysctl_mem[1],
> -		__entry->sysctl_mem[2],
> +		__entry->prot_mem[0],
> +		__entry->prot_mem[1],
> +		__entry->prot_mem[2],
>  		__entry->allocated,
> -		__entry->sysctl_rmem,
> +		__entry->prot_rmem,
>  		__entry->rmem_alloc)
>  );
>  
> diff --git a/net/core/sock.c b/net/core/sock.c
> index bc745d0..f38045a 100644
> --- a/net/core/sock.c
> +++ b/net/core/sock.c
> @@ -111,6 +111,7 @@
>  #include <linux/init.h>
>  #include <linux/highmem.h>
>  #include <linux/user_namespace.h>
> +#include <linux/cgroup.h>
>  
>  #include <asm/uaccess.h>
>  #include <asm/system.h>
> @@ -134,6 +135,55 @@
>  #include <net/tcp.h>
>  #endif
>  
> +static DEFINE_RWLOCK(proto_list_lock);
> +static LIST_HEAD(proto_list);
> +
> +static int sockets_populate(struct cgroup_subsys *ss, struct cgroup *cgrp)
> +{
> +	struct proto *proto;
> +	int ret = 0;
> +
> +	read_lock(&proto_list_lock);
> +	list_for_each_entry(proto, &proto_list, node) {
> +		if (proto->init_cgroup) {
> +			ret |= proto->init_cgroup(cgrp, ss);
> +		}
> +	}
> +	read_unlock(&proto_list_lock);
> +	
> +	return ret;
> +}
> +
> +static void
> +sockets_destroy(struct cgroup_subsys *ss, struct cgroup *cgrp)
> +{
> +	struct sockets_cgrp *sk = cgroup_sk(cgrp);
> +
> +	kfree(sk);
> +}
> +
> +static struct cgroup_subsys_state *sockets_create(
> +	struct cgroup_subsys *ss, struct cgroup *cgrp)
> +{
> +	struct sockets_cgrp *sk = kzalloc(sizeof(*sk), GFP_KERNEL);
> +
> +	if (!sk)
> +		return ERR_PTR(-ENOMEM);
> +
> +	if (cgrp->parent)
> +		sk->parent = cgroup_sk(cgrp->parent);
> +
> +	return &sk->css;
> +}
> +
> +struct cgroup_subsys sockets_subsys = {
> +	.name = "sockets",
> +	.create = sockets_create,
> +	.destroy = sockets_destroy,
> +	.populate = sockets_populate,
> +	.subsys_id = sockets_subsys_id,
> +};
> +
>  /*
>   * Each address family might have different locking rules, so we have
>   * one slock key per address family:
> @@ -1114,6 +1164,14 @@ void sock_update_classid(struct sock *sk)
>  		sk->sk_classid = classid;
>  }
>  EXPORT_SYMBOL(sock_update_classid);
> +
> +void sock_update_cgrp(struct sock *sk)
> +{
> +	rcu_read_lock(); 
> +	sk->sk_cgrp = task_sk(current);
> +	rcu_read_unlock();
> +}
> +
>  #endif
>  
>  /**
> @@ -1141,6 +1199,7 @@ struct sock *sk_alloc(struct net *net, int family, gfp_t priority,
>  		atomic_set(&sk->sk_wmem_alloc, 1);
>  
>  		sock_update_classid(sk);
> +		sock_update_cgrp(sk);
>  	}
>  
>  	return sk;
> @@ -1210,6 +1269,7 @@ EXPORT_SYMBOL(sk_release_kernel);
>  struct sock *sk_clone(const struct sock *sk, const gfp_t priority)
>  {
>  	struct sock *newsk;
> +	struct sockets_cgrp *sg = sk->sk_cgrp;
>  
>  	newsk = sk_prot_alloc(sk->sk_prot, priority, sk->sk_family);
>  	if (newsk != NULL) {
> @@ -1289,8 +1349,8 @@ struct sock *sk_clone(const struct sock *sk, const gfp_t priority)
>  		sk_set_socket(newsk, NULL);
>  		newsk->sk_wq = NULL;
>  
> -		if (newsk->sk_prot->sockets_allocated)
> -			percpu_counter_inc(newsk->sk_prot->sockets_allocated);
> +		if (sk_sockets_allocated(sk->sk_prot, sg))
> +			percpu_counter_inc(sk_sockets_allocated(sk->sk_prot, sg));
>  
>  		if (sock_flag(newsk, SOCK_TIMESTAMP) ||
>  		    sock_flag(newsk, SOCK_TIMESTAMPING_RX_SOFTWARE))
> @@ -1666,61 +1726,55 @@ int sk_wait_data(struct sock *sk, long *timeo)
>  }
>  EXPORT_SYMBOL(sk_wait_data);
>  
> -/**
> - *	__sk_mem_schedule - increase sk_forward_alloc and memory_allocated
> - *	@sk: socket
> - *	@size: memory size to allocate
> - *	@kind: allocation type
> - *
> - *	If kind is SK_MEM_SEND, it means wmem allocation. Otherwise it means
> - *	rmem allocation. This function assumes that protocols which have
> - *	memory_pressure use sk_wmem_queued as write buffer accounting.
> - */
> -int __sk_mem_schedule(struct sock *sk, int size, int kind)
> +int __sk_mem_schedule_cgrp(struct sock *sk, struct sockets_cgrp *sg,
> +			   int amt, int kind, int first)
>  {
>  	struct proto *prot = sk->sk_prot;
> -	int amt = sk_mem_pages(size);
>  	long allocated;
> +	long *prot_mem;
> +	int *memory_pressure;
>  
> -	sk->sk_forward_alloc += amt * SK_MEM_QUANTUM;
> -	allocated = atomic_long_add_return(amt, prot->memory_allocated);
> +	memory_pressure = sk_memory_pressure(prot, sg);
> +	prot_mem = sk_prot_mem(prot, sg);
> +
> +	allocated = atomic_long_add_return(amt, sk_memory_allocated(prot, sg));
>  
>  	/* Under limit. */
> -	if (allocated <= prot->sysctl_mem[0]) {
> -		if (prot->memory_pressure && *prot->memory_pressure)
> -			*prot->memory_pressure = 0;
> +	if (allocated <= prot_mem[0]) {
> +		if (memory_pressure && *memory_pressure)
> +			*memory_pressure = 0;
>  		return 1;
>  	}
>  
>  	/* Under pressure. */
> -	if (allocated > prot->sysctl_mem[1])
> +	if (allocated > prot_mem[1])
>  		if (prot->enter_memory_pressure)
> -			prot->enter_memory_pressure(sk);
> +			prot->enter_memory_pressure(sg);
>  
>  	/* Over hard limit. */
> -	if (allocated > prot->sysctl_mem[2])
> +	if (allocated > prot_mem[2])
>  		goto suppress_allocation;
>  
>  	/* guarantee minimum buffer size under pressure */
>  	if (kind == SK_MEM_RECV) {
> -		if (atomic_read(&sk->sk_rmem_alloc) < prot->sysctl_rmem[0])
> +		if (atomic_read(&sk->sk_rmem_alloc) < sk_prot_rmem(sk)[0])
>  			return 1;
>  	} else { /* SK_MEM_SEND */
>  		if (sk->sk_type == SOCK_STREAM) {
> -			if (sk->sk_wmem_queued < prot->sysctl_wmem[0])
> +			if (sk->sk_wmem_queued < sk_prot_wmem(sk)[0])
>  				return 1;
>  		} else if (atomic_read(&sk->sk_wmem_alloc) <
> -			   prot->sysctl_wmem[0])
> +			   sk_prot_wmem(sk)[0])
>  				return 1;
>  	}
>  
> -	if (prot->memory_pressure) {
> +	if (memory_pressure) {
>  		int alloc;
>  
> -		if (!*prot->memory_pressure)
> +		if (!*memory_pressure)
>  			return 1;
> -		alloc = percpu_counter_read_positive(prot->sockets_allocated);
> -		if (prot->sysctl_mem[2] > alloc *
> +		alloc = percpu_counter_read_positive(sk_sockets_allocated(prot, sg));
> +		if (prot_mem[2] > alloc *
>  		    sk_mem_pages(sk->sk_wmem_queued +
>  				 atomic_read(&sk->sk_rmem_alloc) +
>  				 sk->sk_forward_alloc))
> @@ -1728,6 +1782,44 @@ int __sk_mem_schedule(struct sock *sk, int size, int kind)
>  	}
>  
>  suppress_allocation:
> +	if (first)
> +		trace_sock_exceed_buf_limit(sk, prot, allocated,
> +					    prot_mem, sk_prot_rmem(sk));
> +	return 0;
> +}
> +
> +/**
> + *	__sk_mem_schedule - increase sk_forward_alloc and memory_allocated
> + *	@sk: socket
> + *	@size: memory size to allocate
> + *	@kind: allocation type
> + *
> + *	If kind is SK_MEM_SEND, it means wmem allocation. Otherwise it means
> + *	rmem allocation. This function assumes that protocols which have
> + *	memory_pressure use sk_wmem_queued as write buffer accounting.
> + */
> +int __sk_mem_schedule(struct sock *sk, int size, int kind)
> +{
> +	struct sockets_cgrp *sg;
> +	int amt = sk_mem_pages(size);
> +	int first = 1;
> +	int ret = 0;
> +	struct proto *prot = sk->sk_prot;
> +
> +	sk->sk_forward_alloc += amt * SK_MEM_QUANTUM;
> +
> +	for (sg = sk->sk_cgrp; sg != NULL; sg = sg->parent) {
> +		int r;
> +		r = __sk_mem_schedule_cgrp(sk, sg, amt, kind, first);
> +		if (first)
> +			ret = r;
> +		first = 0;
> +	} 
> +
> +	if (ret > 0)
> +		goto out;
> +
> +	/* Supress current allocation */
>  
>  	if (kind == SK_MEM_SEND && sk->sk_type == SOCK_STREAM) {
>  		sk_stream_moderate_sndbuf(sk);
> @@ -1739,12 +1831,15 @@ suppress_allocation:
>  			return 1;
>  	}
>  
> -	trace_sock_exceed_buf_limit(sk, prot, allocated);
> -
>  	/* Alas. Undo changes. */
>  	sk->sk_forward_alloc -= amt * SK_MEM_QUANTUM;
> -	atomic_long_sub(amt, prot->memory_allocated);
> -	return 0;
> +
> +	for (sg = sk->sk_cgrp; sg != NULL; sg = sg->parent) {
> +		atomic_long_sub(amt, sk_memory_allocated(prot, sg));
> +	}
> +out:
> +	return ret;
> +
>  }
>  EXPORT_SYMBOL(__sk_mem_schedule);
>  
> @@ -1755,14 +1850,16 @@ EXPORT_SYMBOL(__sk_mem_schedule);
>  void __sk_mem_reclaim(struct sock *sk)
>  {
>  	struct proto *prot = sk->sk_prot;
> +	struct sockets_cgrp *sg = sk->sk_cgrp;
> +	int *memory_pressure = sk_memory_pressure(prot, sg);
>  
>  	atomic_long_sub(sk->sk_forward_alloc >> SK_MEM_QUANTUM_SHIFT,
> -		   prot->memory_allocated);
> +		   sk_memory_allocated(prot, sg));
>  	sk->sk_forward_alloc &= SK_MEM_QUANTUM - 1;
>  
> -	if (prot->memory_pressure && *prot->memory_pressure &&
> -	    (atomic_long_read(prot->memory_allocated) < prot->sysctl_mem[0]))
> -		*prot->memory_pressure = 0;
> +	if (memory_pressure && *memory_pressure &&
> +	    (atomic_long_read(sk_memory_allocated(prot, sg)) < sk_prot_mem(prot, sg)[0]))
> +		*memory_pressure = 0;
>  }
>  EXPORT_SYMBOL(__sk_mem_reclaim);
>  
> @@ -2254,9 +2351,6 @@ void sk_common_release(struct sock *sk)
>  }
>  EXPORT_SYMBOL(sk_common_release);
>  
> -static DEFINE_RWLOCK(proto_list_lock);
> -static LIST_HEAD(proto_list);
> -
>  #ifdef CONFIG_PROC_FS
>  #define PROTO_INUSE_NR	64	/* should be enough for the first time */
>  struct prot_inuse {
> @@ -2481,13 +2575,15 @@ static char proto_method_implemented(const void *method)
>  
>  static void proto_seq_printf(struct seq_file *seq, struct proto *proto)
>  {
> +	struct sockets_cgrp *sg = task_sk(current);
> +
>  	seq_printf(seq, "%-9s %4u %6d  %6ld   %-3s %6u   %-3s  %-10s "
>  			"%2c %2c %2c %2c %2c %2c %2c %2c %2c %2c %2c %2c %2c %2c %2c %2c %2c %2c %2c\n",
>  		   proto->name,
>  		   proto->obj_size,
>  		   sock_prot_inuse_get(seq_file_net(seq), proto),
> -		   proto->memory_allocated != NULL ? atomic_long_read(proto->memory_allocated) : -1L,
> -		   proto->memory_pressure != NULL ? *proto->memory_pressure ? "yes" : "no" : "NI",
> +		   proto->memory_allocated != NULL ? atomic_long_read(sk_memory_allocated(proto, sg)) : -1L,
> +		   proto->memory_pressure != NULL ? *sk_memory_pressure(proto, sg) ? "yes" : "no" : "NI",
>  		   proto->max_header,
>  		   proto->slab == NULL ? "no" : "yes",
>  		   module_name(proto->owner),
> diff --git a/net/ipv4/proc.c b/net/ipv4/proc.c
> index b14ec7d..9b380be 100644
> --- a/net/ipv4/proc.c
> +++ b/net/ipv4/proc.c
> @@ -53,19 +53,21 @@ static int sockstat_seq_show(struct seq_file *seq, void *v)
>  	struct net *net = seq->private;
>  	int orphans, sockets;
>  
> +	struct sockets_cgrp *sg = task_sk(current);
> +
>  	local_bh_disable();
>  	orphans = percpu_counter_sum_positive(&tcp_orphan_count);
> -	sockets = percpu_counter_sum_positive(&tcp_sockets_allocated);
> +	sockets = percpu_counter_sum_positive(sk_sockets_allocated((&tcp_prot), sg));
>  	local_bh_enable();
>  
>  	socket_seq_show(seq);
>  	seq_printf(seq, "TCP: inuse %d orphan %d tw %d alloc %d mem %ld\n",
>  		   sock_prot_inuse_get(net, &tcp_prot), orphans,
>  		   tcp_death_row.tw_count, sockets,
> -		   atomic_long_read(&tcp_memory_allocated));
> +		   atomic_long_read(sk_memory_allocated((&tcp_prot), sg)));
>  	seq_printf(seq, "UDP: inuse %d mem %ld\n",
>  		   sock_prot_inuse_get(net, &udp_prot),
> -		   atomic_long_read(&udp_memory_allocated));
> +		   atomic_long_read(sk_memory_allocated((&udp_prot), sg)));
>  	seq_printf(seq, "UDPLITE: inuse %d\n",
>  		   sock_prot_inuse_get(net, &udplite_prot));
>  	seq_printf(seq, "RAW: inuse %d\n",
> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
> index 46febca..a4eb7ea 100644
> --- a/net/ipv4/tcp.c
> +++ b/net/ipv4/tcp.c
> @@ -293,6 +293,9 @@ EXPORT_SYMBOL(sysctl_tcp_wmem);
>  atomic_long_t tcp_memory_allocated;	/* Current allocated memory. */
>  EXPORT_SYMBOL(tcp_memory_allocated);
>  
> +int tcp_memory_pressure;
> +EXPORT_SYMBOL(tcp_memory_pressure);
> +
>  /*
>   * Current number of TCP sockets.
>   */
> @@ -314,18 +317,118 @@ struct tcp_splice_state {
>   * All the __sk_mem_schedule() is of this nature: accounting
>   * is strict, actions are advisory and have some latency.
>   */
> -int tcp_memory_pressure __read_mostly;
> -EXPORT_SYMBOL(tcp_memory_pressure);
> -
> -void tcp_enter_memory_pressure(struct sock *sk)
> +void tcp_enter_memory_pressure(struct sockets_cgrp *sg)
>  {
> -	if (!tcp_memory_pressure) {
> -		NET_INC_STATS(sock_net(sk), LINUX_MIB_TCPMEMORYPRESSURES);
> -		tcp_memory_pressure = 1;
> +	if (!sg->tcp_memory_pressure) {
> +// FIXME: how to grab net pointer from cgroup ? */
> +//		NET_INC_STATS(sock_net(sk), LINUX_MIB_TCPMEMORYPRESSURES);
>  	}
> +
> +	sg->tcp_memory_pressure = 1;
>  }
>  EXPORT_SYMBOL(tcp_enter_memory_pressure);
>  
> +long *tcp_sysctl_mem(struct sockets_cgrp *sg)
> +{
> +	return sg->tcp_prot_mem;
> +}
> +EXPORT_SYMBOL(tcp_sysctl_mem);
> +
> +int *tcp_sysctl_rmem(struct sock *sk)
> +{
> +	return sysctl_tcp_rmem;
> +}
> +EXPORT_SYMBOL(tcp_sysctl_rmem);
> +
> +int *tcp_sysctl_wmem(struct sock *sk)
> +{
> +	return sysctl_tcp_wmem;
> +}
> +EXPORT_SYMBOL(tcp_sysctl_wmem);
> +
> +atomic_long_t *memory_allocated_tcp(struct sockets_cgrp *sg)
> +{
> +	return &(sg->tcp_memory_allocated);
> +}
> +EXPORT_SYMBOL(memory_allocated_tcp);
> +
> +static int tcp_write_maxmem(struct cgroup *cgrp, struct cftype *cft, u64 val)
> +{
> +	struct sockets_cgrp *sg = cgroup_sk(cgrp);
> +
> +	if (!cgroup_lock_live_group(cgrp))
> +		return -ENODEV;
> +
> +	/* 
> +	 * We can't allow more memory than our parents. Since this
> +	 * will be tested for all calls, by induction, there is no need
> +	 * to test any parent other than our own
> +	 * */
> +	if (sg->parent && (val > sg->parent->tcp_max_memory))
> +		val = sg->parent->tcp_max_memory;
> +
> +	sg->tcp_max_memory = val;
> +
> +	sg->tcp_prot_mem[0] = val / 4 * 3;
> +	sg->tcp_prot_mem[1] = val;
> +	sg->tcp_prot_mem[2] = sg->tcp_prot_mem[0] * 2;
> +
> +        cgroup_unlock(); 
> +
> +	return 0;
> +}
> +
> +static u64 tcp_read_maxmem(struct cgroup *cgrp, struct cftype *cft)
> +{
> +	struct sockets_cgrp *sg = cgroup_sk(cgrp);
> +	u64 ret;
> +
> +	if (!cgroup_lock_live_group(cgrp))
> +		return -ENODEV;
> +	ret = sg->tcp_max_memory;
> +
> +	cgroup_unlock();
> +	return ret;
> +}
> +
> +static struct cftype tcp_files[] = {
> +	{
> +		.name = "tcp_maxmem",
> +		.write_u64 = tcp_write_maxmem,
> +		.read_u64 = tcp_read_maxmem,
> +	},
> +};
> +
> +int tcp_init_cgroup(struct cgroup *cgrp, struct cgroup_subsys *ss)
> +{
> +	struct sockets_cgrp *sg = cgroup_sk(cgrp);
> +	sg->tcp_memory_pressure = 0;
> +
> +	percpu_counter_init(&sg->tcp_sockets_allocated, 0);
> +	atomic_long_set(&sg->tcp_memory_allocated, 0);
> +
> +	sg->tcp_max_memory = sysctl_tcp_mem[1];
> +
> +	sg->tcp_prot_mem[0] = sysctl_tcp_mem[1] / 4 * 3;
> +	sg->tcp_prot_mem[1] = sysctl_tcp_mem[1];
> +	sg->tcp_prot_mem[2] = sg->tcp_prot_mem[0] * 2;
> +
> +	return cgroup_add_files(cgrp, ss, tcp_files, ARRAY_SIZE(tcp_files));
> +}
> +EXPORT_SYMBOL(tcp_init_cgroup);
> +
> +int *memory_pressure_tcp(struct sockets_cgrp *sg)
> +{
> +	return &sg->tcp_memory_pressure;
> +}
> +EXPORT_SYMBOL(memory_pressure_tcp);
> +
> +struct percpu_counter *sockets_allocated_tcp(struct sockets_cgrp *sg)
> +{
> +	return &sg->tcp_sockets_allocated;
> +}
> +EXPORT_SYMBOL(sockets_allocated_tcp);
> +
>  /* Convert seconds to retransmits based on initial and max timeout */
>  static u8 secs_to_retrans(int seconds, int timeout, int rto_max)
>  {
> @@ -710,7 +813,7 @@ struct sk_buff *sk_stream_alloc_skb(struct sock *sk, int size, gfp_t gfp)
>  		}
>  		__kfree_skb(skb);
>  	} else {
> -		sk->sk_prot->enter_memory_pressure(sk);
> +		sk->sk_prot->enter_memory_pressure(sk->sk_cgrp);
>  		sk_stream_moderate_sndbuf(sk);
>  	}
>  	return NULL;
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index ea0d218..38dac60 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -312,11 +312,12 @@ static int __tcp_grow_window(const struct sock *sk, const struct sk_buff *skb)
>  static void tcp_grow_window(struct sock *sk, struct sk_buff *skb)
>  {
>  	struct tcp_sock *tp = tcp_sk(sk);
> +	struct sockets_cgrp *sg = sk->sk_cgrp;
>  
>  	/* Check #1 */
>  	if (tp->rcv_ssthresh < tp->window_clamp &&
>  	    (int)tp->rcv_ssthresh < tcp_space(sk) &&
> -	    !tcp_memory_pressure) {
> +	    !sg->tcp_memory_pressure) {
>  		int incr;
>  
>  		/* Check #2. Increase window, if skb with such overhead
> @@ -393,15 +394,16 @@ static void tcp_clamp_window(struct sock *sk)
>  {
>  	struct tcp_sock *tp = tcp_sk(sk);
>  	struct inet_connection_sock *icsk = inet_csk(sk);
> +	struct sockets_cgrp *sg = sk->sk_cgrp;
>  
>  	icsk->icsk_ack.quick = 0;
>  
> -	if (sk->sk_rcvbuf < sysctl_tcp_rmem[2] &&
> +	if (sk->sk_rcvbuf < sk_prot_rmem(sk)[2] &&
>  	    !(sk->sk_userlocks & SOCK_RCVBUF_LOCK) &&
> -	    !tcp_memory_pressure &&
> -	    atomic_long_read(&tcp_memory_allocated) < sysctl_tcp_mem[0]) {
> +	    !sg->tcp_memory_pressure &&
> +	    atomic_long_read(&tcp_memory_allocated) < sk_prot_mem(sk->sk_prot, sg)[0]) {
>  		sk->sk_rcvbuf = min(atomic_read(&sk->sk_rmem_alloc),
> -				    sysctl_tcp_rmem[2]);
> +				    sk_prot_rmem(sk)[2]);
>  	}
>  	if (atomic_read(&sk->sk_rmem_alloc) > sk->sk_rcvbuf)
>  		tp->rcv_ssthresh = min(tp->window_clamp, 2U * tp->advmss);
> @@ -4799,6 +4801,7 @@ static int tcp_prune_ofo_queue(struct sock *sk)
>  static int tcp_prune_queue(struct sock *sk)
>  {
>  	struct tcp_sock *tp = tcp_sk(sk);
> +	struct sockets_cgrp *sg = sk->sk_cgrp;
>  
>  	SOCK_DEBUG(sk, "prune_queue: c=%x\n", tp->copied_seq);
>  
> @@ -4806,7 +4809,7 @@ static int tcp_prune_queue(struct sock *sk)
>  
>  	if (atomic_read(&sk->sk_rmem_alloc) >= sk->sk_rcvbuf)
>  		tcp_clamp_window(sk);
> -	else if (tcp_memory_pressure)
> +	else if (sg->tcp_memory_pressure)
>  		tp->rcv_ssthresh = min(tp->rcv_ssthresh, 4U * tp->advmss);
>  
>  	tcp_collapse_ofo_queue(sk);
> @@ -4864,6 +4867,7 @@ void tcp_cwnd_application_limited(struct sock *sk)
>  static int tcp_should_expand_sndbuf(struct sock *sk)
>  {
>  	struct tcp_sock *tp = tcp_sk(sk);
> +	struct sockets_cgrp *sg = sk->sk_cgrp;
>  
>  	/* If the user specified a specific send buffer setting, do
>  	 * not modify it.
> @@ -4872,11 +4876,11 @@ static int tcp_should_expand_sndbuf(struct sock *sk)
>  		return 0;
>  
>  	/* If we are under global TCP memory pressure, do not expand.  */
> -	if (tcp_memory_pressure)
> +	if (sg->tcp_memory_pressure)
>  		return 0;
>  
>  	/* If we are under soft global TCP memory pressure, do not expand.  */
> -	if (atomic_long_read(&tcp_memory_allocated) >= sysctl_tcp_mem[0])
> +	if (atomic_long_read(&tcp_memory_allocated) >= sk_prot_mem(sk->sk_prot, sg)[0])
>  		return 0;
>  
>  	/* If we filled the congestion window, do not expand.  */
> diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
> index 955b8e6..aa6b68c 100644
> --- a/net/ipv4/tcp_ipv4.c
> +++ b/net/ipv4/tcp_ipv4.c
> @@ -2597,13 +2597,14 @@ struct proto tcp_prot = {
>  	.unhash			= inet_unhash,
>  	.get_port		= inet_csk_get_port,
>  	.enter_memory_pressure	= tcp_enter_memory_pressure,
> -	.sockets_allocated	= &tcp_sockets_allocated,
> +	.memory_pressure	= memory_pressure_tcp,
> +	.sockets_allocated	= sockets_allocated_tcp,
>  	.orphan_count		= &tcp_orphan_count,
> -	.memory_allocated	= &tcp_memory_allocated,
> -	.memory_pressure	= &tcp_memory_pressure,
> -	.sysctl_mem		= sysctl_tcp_mem,
> -	.sysctl_wmem		= sysctl_tcp_wmem,
> -	.sysctl_rmem		= sysctl_tcp_rmem,
> +	.memory_allocated	= memory_allocated_tcp,
> +	.init_cgroup		= tcp_init_cgroup,
> +	.prot_mem		= tcp_sysctl_mem,
> +	.prot_wmem		= tcp_sysctl_wmem,
> +	.prot_rmem		= tcp_sysctl_rmem,
>  	.max_header		= MAX_TCP_HEADER,
>  	.obj_size		= sizeof(struct tcp_sock),
>  	.slab_flags		= SLAB_DESTROY_BY_RCU,
> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> index 882e0b0..24f975c 100644
> --- a/net/ipv4/tcp_output.c
> +++ b/net/ipv4/tcp_output.c
> @@ -1905,6 +1905,7 @@ u32 __tcp_select_window(struct sock *sk)
>  	int free_space = tcp_space(sk);
>  	int full_space = min_t(int, tp->window_clamp, tcp_full_space(sk));
>  	int window;
> +	struct sockets_cgrp *sg = sk->sk_cgrp;
>  
>  	if (mss > full_space)
>  		mss = full_space;
> @@ -1912,7 +1913,7 @@ u32 __tcp_select_window(struct sock *sk)
>  	if (free_space < (full_space >> 1)) {
>  		icsk->icsk_ack.quick = 0;
>  
> -		if (tcp_memory_pressure)
> +		if (sg->tcp_memory_pressure)
>  			tp->rcv_ssthresh = min(tp->rcv_ssthresh,
>  					       4U * tp->advmss);
>  
> diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
> index ecd44b0..a82e38a 100644
> --- a/net/ipv4/tcp_timer.c
> +++ b/net/ipv4/tcp_timer.c
> @@ -213,6 +213,9 @@ static void tcp_delack_timer(unsigned long data)
>  	struct sock *sk = (struct sock *)data;
>  	struct tcp_sock *tp = tcp_sk(sk);
>  	struct inet_connection_sock *icsk = inet_csk(sk);
> +	struct sockets_cgrp *sg;
> +
> +	sg = sk->sk_cgrp;
>  
>  	bh_lock_sock(sk);
>  	if (sock_owned_by_user(sk)) {
> @@ -261,7 +264,7 @@ static void tcp_delack_timer(unsigned long data)
>  	}
>  
>  out:
> -	if (tcp_memory_pressure)
> +	if (sg->tcp_memory_pressure)
>  		sk_mem_reclaim(sk);
>  out_unlock:
>  	bh_unlock_sock(sk);
> diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
> index 1b5a193..d5025bd 100644
> --- a/net/ipv4/udp.c
> +++ b/net/ipv4/udp.c
> @@ -120,9 +120,6 @@ EXPORT_SYMBOL(sysctl_udp_rmem_min);
>  int sysctl_udp_wmem_min __read_mostly;
>  EXPORT_SYMBOL(sysctl_udp_wmem_min);
>  
> -atomic_long_t udp_memory_allocated;
> -EXPORT_SYMBOL(udp_memory_allocated);
> -
>  #define MAX_UDP_PORTS 65536
>  #define PORTS_PER_CHAIN (MAX_UDP_PORTS / UDP_HTABLE_SIZE_MIN)
>  
> @@ -1918,6 +1915,29 @@ unsigned int udp_poll(struct file *file, struct socket *sock, poll_table *wait)
>  }
>  EXPORT_SYMBOL(udp_poll);
>  
> +atomic_long_t *memory_allocated_udp(struct sockets_cgrp *sg)
> +{
> +	return &sg->udp_memory_allocated;
> +}
> +EXPORT_SYMBOL(memory_allocated_udp);
> +
> +long *udp_sysctl_mem(struct sockets_cgrp *sg)
> +{
> +	return sysctl_udp_mem;
> +}
> +
> +int *udp_sysctl_rmem(struct sock *sk)
> +{
> +	return &sysctl_udp_rmem_min;
> +}
> +EXPORT_SYMBOL(udp_sysctl_rmem);
> +
> +int *udp_sysctl_wmem(struct sock *sk)
> +{
> +	return &sysctl_udp_wmem_min;
> +}
> +EXPORT_SYMBOL(udp_sysctl_wmem);
> +
>  struct proto udp_prot = {
>  	.name		   = "UDP",
>  	.owner		   = THIS_MODULE,
> @@ -1936,10 +1956,10 @@ struct proto udp_prot = {
>  	.unhash		   = udp_lib_unhash,
>  	.rehash		   = udp_v4_rehash,
>  	.get_port	   = udp_v4_get_port,
> -	.memory_allocated  = &udp_memory_allocated,
> -	.sysctl_mem	   = sysctl_udp_mem,
> -	.sysctl_wmem	   = &sysctl_udp_wmem_min,
> -	.sysctl_rmem	   = &sysctl_udp_rmem_min,
> +	.memory_allocated  = &memory_allocated_udp,
> +	.prot_mem	   = udp_sysctl_mem,
> +	.prot_wmem	   = udp_sysctl_wmem,
> +	.prot_rmem	   = udp_sysctl_rmem,
>  	.obj_size	   = sizeof(struct udp_sock),
>  	.slab_flags	   = SLAB_DESTROY_BY_RCU,
>  	.h.udp_table	   = &udp_table,
