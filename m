From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [net-next V4 PATCH 1/5] bpf: introduce new bpf cpu map type
 BPF_MAP_TYPE_CPUMAP
Date: Fri, 6 Oct 2017 12:50:08 +0200
Message-ID: <20171006125008.676d5eaf@redhat.com>
References: <150711858281.9499.7767364427831352921.stgit@firesoul>
        <150711862505.9499.15042356194495111353.stgit@firesoul>
        <59D5FDFF.5040002@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jakub.kicinski@netronome.com,
        "Michael S. Tsirkin" <mst@redhat.com>, pavel.odintsov@gmail.com,
        Jason Wang <jasowang@redhat.com>, mchan@broadcom.com,
        John Fastabend <john.fastabend@gmail.com>,
        peter.waskiewicz.jr@intel.com,
        Daniel Borkmann <borkmann@iogearbox.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Andy Gospodarek <andy@greyhouse.net>, brouer@redhat.com,
        Tobias Klauser <tklauser@distanz.ch>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44432 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751511AbdJFKuT (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 6 Oct 2017 06:50:19 -0400
In-Reply-To: <59D5FDFF.5040002@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 05 Oct 2017 11:40:15 +0200
Daniel Borkmann <daniel@iogearbox.net> wrote:

> On 10/04/2017 02:03 PM, Jesper Dangaard Brouer wrote:
> [...]
> > +#define CPU_MAP_BULK_SIZE 8  /* 8 == one cacheline on 64-bit archs */
> > +struct xdp_bulk_queue {
> > +	void *q[CPU_MAP_BULK_SIZE];
> > +	unsigned int count;
> > +};
> > +
> > +/* Struct for every remote "destination" CPU in map */
> > +struct bpf_cpu_map_entry {
> > +	u32 cpu;    /* kthread CPU and map index */
> > +	int map_id; /* Back reference to map */  
> 
> map_id is not used here if I read it correctly? We should
> then remove it.

It is actually used in a later patch. Notice, there is no unused
members in the final patch.  I did consider adding back in the later
patch, but it was annoying to during the devel and split-up patch
phase, as it creates conflicts when I move between the different
patches, that need to modify this struct.  Thus, I choose to keep the
end-struct in this cpumap-base-patch.  If you insist, I can go though
the patch-stack and carefully introduce changes to the struct in steps?


> > +	u32 qsize;  /* Redundant queue size for map lookup */
> > +
> > +	/* XDP can run multiple RX-ring queues, need __percpu enqueue store */
> > +	struct xdp_bulk_queue __percpu *bulkq;
> > +
> > +	/* Queue with potential multi-producers, and single-consumer kthread */
> > +	struct ptr_ring *queue;
> > +	struct task_struct *kthread;
> > +	struct work_struct kthread_stop_wq;
> > +
> > +	atomic_t refcnt; /* Control when this struct can be free'ed */
> > +	struct rcu_head rcu;
> > +};
> > +
> > +struct bpf_cpu_map {
> > +	struct bpf_map map;
> > +	/* Below members specific for map type */
> > +	struct bpf_cpu_map_entry **cpu_map;
> > +	unsigned long __percpu *flush_needed;
> > +};
> > +
> > +static int bq_flush_to_queue(struct bpf_cpu_map_entry *rcpu,
> > +			     struct xdp_bulk_queue *bq);  
> 
> Could we avoid forward declaration?

This forward declaration helps me avoid mixing the enqueue code with
the bpf-map code.  I like that all the enqueue code is located after
the struct bpf_map_ops cpu_map_ops deceleration.  If you insist, I can
reorder the code?

 
> > +static u64 cpu_map_bitmap_size(const union bpf_attr *attr)
> > +{
> > +	return BITS_TO_LONGS(attr->max_entries) * sizeof(unsigned long);
> > +}
> > +
> > +static struct bpf_map *cpu_map_alloc(union bpf_attr *attr)
> > +{
> > +	struct bpf_cpu_map *cmap;
> > +	u64 cost;
> > +	int err;
> > +
> > +	/* check sanity of attributes */
> > +	if (attr->max_entries == 0 || attr->key_size != 4 ||
> > +	    attr->value_size != 4 || attr->map_flags & ~BPF_F_NUMA_NODE)
> > +		return ERR_PTR(-EINVAL);
> > +
> > +	cmap = kzalloc(sizeof(*cmap), GFP_USER);
> > +	if (!cmap)
> > +		return ERR_PTR(-ENOMEM);
> > +
> > +	/* mandatory map attributes */
> > +	cmap->map.map_type = attr->map_type;
> > +	cmap->map.key_size = attr->key_size;
> > +	cmap->map.value_size = attr->value_size;
> > +	cmap->map.max_entries = attr->max_entries;
> > +	cmap->map.map_flags = attr->map_flags;
> > +	cmap->map.numa_node = bpf_map_attr_numa_node(attr);
> > +
> > +	/* Pre-limit array size based on NR_CPUS, not final CPU check */
> > +	if (cmap->map.max_entries > NR_CPUS)
> > +		return ERR_PTR(-E2BIG);
> > +
> > +	/* make sure page count doesn't overflow */
> > +	cost = (u64) cmap->map.max_entries * sizeof(struct bpf_cpu_map_entry *);
> > +	cost += cpu_map_bitmap_size(attr) * num_possible_cpus();
> > +	if (cost >= U32_MAX - PAGE_SIZE)
> > +		goto free_cmap;
> > +	cmap->map.pages = round_up(cost, PAGE_SIZE) >> PAGE_SHIFT;
> > +
> > +	/* if map size is larger than memlock limit, reject it early */
> > +	err = bpf_map_precharge_memlock(cmap->map.pages);
> > +	if (err)
> > +		goto free_cmap;  
> 
> Given this is almost the same as devmap and touches user land reporting,
> we should probably go and do the same as in 582db7e0c4c2 ("bpf: devmap:
> pass on return value of bpf_map_precharge_memlock").

I guess we have to do this... even-though I absolutely HATE that this
will return -EPERM which user land will see as "Operation not permitted".

Even-though I know this, I got confused and spend several hours hunting
the wrong kind of error:
 https://github.com/netoptimizer/prototype-kernel/commit/cf4694792bf9807f48dc174a149ab0805133184a

Even the iovisor/BCC tool have a work-around for this ambiguous ABI
that we provide, and explicitly call their work-around a "hack":

https://github.com/iovisor/bcc/blob/2e20494f63a/src/cc/libbpf.c#L366-L373

 if (ret < 0 && errno == EPERM) {
    // When EPERM is returned, two reasons are possible:
    //  1. user has no permissions for bpf()
    //  2. user has insufficent rlimit for locked memory
    // Unfortunately, there is no api to inspect the current usage of locked
    // mem for the user, so an accurate calculation of how much memory to lock
    // for this new program is difficult to calculate. As a hack, bump the limit
    // to unlimited. If program load fails again, return the error.

 
> > +	/* A per cpu bitfield with a bit per possible CPU in map  */
> > +	cmap->flush_needed = __alloc_percpu(cpu_map_bitmap_size(attr),
> > +					    __alignof__(unsigned long));
> > +	if (!cmap->flush_needed)
> > +		goto free_cmap;
> > +
> > +	/* Alloc array for possible remote "destination" CPUs */
> > +	cmap->cpu_map = bpf_map_area_alloc(cmap->map.max_entries *
> > +					   sizeof(struct bpf_cpu_map_entry *),
> > +					   cmap->map.numa_node);
> > +	if (!cmap->cpu_map)
> > +		goto free_cmap;
> > +
> > +	return &cmap->map;
> > +free_cmap:
> > +	free_percpu(cmap->flush_needed);
> > +	kfree(cmap);
> > +	return ERR_PTR(-ENOMEM);
> > +}
> > +
> > +void __cpu_map_queue_destructor(void *ptr)
> > +{
> > +	/* For now, just catch this as an error */
> > +	if (!ptr)
> > +		return;
> > +	pr_err("ERROR: %s() cpu_map queue was not empty\n", __func__);  
> 
> Can you elaborate on this "for now" condition? Is this a race
> when kthread doesn't consume queue on thread exit, or should it
> be impossible to trigger (should it then be replaced with a
> 'if (WARN_ON_ONCE(ptr)) page_frag_free(ptr)' and a more elaborate
> comment)?

The "for now" is an old comment while developing and testing this.
In this final state of the patchset it _should_ not be possible to
trigger this situation.  I like your idea of replacing it with a
WARN_ON_ONCE.  (as it might be good to keep in some form, as it would
catch is someone changing the code which breaks the RCU+WQ+kthread
tear-down procedure).


> > +	page_frag_free(ptr);
> > +}
> > +
> > +static void put_cpu_map_entry(struct bpf_cpu_map_entry *rcpu)
> > +{
> > +	if (atomic_dec_and_test(&rcpu->refcnt)) {
> > +		/* The queue should be empty at this point */
> > +		ptr_ring_cleanup(rcpu->queue, __cpu_map_queue_destructor);
> > +		kfree(rcpu->queue);
> > +		kfree(rcpu);
> > +	}
> > +}
> > +
> > +static void get_cpu_map_entry(struct bpf_cpu_map_entry *rcpu)
> > +{
> > +	atomic_inc(&rcpu->refcnt);
> > +}
> > +
> > +/* called from workqueue, to workaround syscall using preempt_disable */
> > +static void cpu_map_kthread_stop(struct work_struct *work)
> > +{
> > +	struct bpf_cpu_map_entry *rcpu;
> > +
> > +	rcpu = container_of(work, struct bpf_cpu_map_entry, kthread_stop_wq);
> > +	synchronize_rcu(); /* wait for flush in __cpu_map_entry_free() */
> > +	kthread_stop(rcpu->kthread); /* calls put_cpu_map_entry */
> > +}
> > +
> > +static int cpu_map_kthread_run(void *data)
> > +{
> > +	struct bpf_cpu_map_entry *rcpu = data;
> > +
> > +	set_current_state(TASK_INTERRUPTIBLE);
> > +	while (!kthread_should_stop()) {
> > +		struct xdp_pkt *xdp_pkt;
> > +
> > +		schedule();
> > +		/* Do work */
> > +		while ((xdp_pkt = ptr_ring_consume(rcpu->queue))) {
> > +			/* For now just "refcnt-free" */
> > +			page_frag_free(xdp_pkt);
> > +		}
> > +		__set_current_state(TASK_INTERRUPTIBLE);
> > +	}
> > +	put_cpu_map_entry(rcpu);
> > +
> > +	__set_current_state(TASK_RUNNING);
> > +	return 0;
> > +}
> > +
> > +struct bpf_cpu_map_entry *__cpu_map_entry_alloc(u32 qsize, u32 cpu, int map_id)
> > +{
> > +	gfp_t gfp = GFP_ATOMIC|__GFP_NOWARN;
> > +	struct bpf_cpu_map_entry *rcpu;
> > +	int numa, err;
> > +
> > +	/* Have map->numa_node, but choose node of redirect target CPU */
> > +	numa = cpu_to_node(cpu);
> > +
> > +	rcpu = kzalloc_node(sizeof(*rcpu), gfp, numa);
> > +	if (!rcpu)
> > +		return NULL;
> > +
> > +	/* Alloc percpu bulkq */
> > +	rcpu->bulkq = __alloc_percpu_gfp(sizeof(*rcpu->bulkq),
> > +					 sizeof(void *), gfp);
> > +	if (!rcpu->bulkq)
> > +		goto fail;
> > +
> > +	/* Alloc queue */
> > +	rcpu->queue = kzalloc_node(sizeof(*rcpu->queue), gfp, numa);
> > +	if (!rcpu->queue)
> > +		goto fail;
> > +
> > +	err = ptr_ring_init(rcpu->queue, qsize, gfp);
> > +	if (err)
> > +		goto fail;
> > +	rcpu->qsize = qsize;
> > +
> > +	/* Setup kthread */
> > +	rcpu->kthread = kthread_create_on_node(cpu_map_kthread_run, rcpu, numa,
> > +					       "cpumap/%d/map:%d", cpu, map_id);
> > +	if (IS_ERR(rcpu->kthread))
> > +		goto fail;  
> 
> What about ptr_ring_cleanup() when we fail here?

Thanks for catching this ... added.

> > +
> > +	/* Make sure kthread runs on a single CPU */
> > +	kthread_bind(rcpu->kthread, cpu);
> > +	wake_up_process(rcpu->kthread);
> > +
> > +	get_cpu_map_entry(rcpu); /* 1-refcnt for being in cmap->cpu_map[] */
> > +	get_cpu_map_entry(rcpu); /* 1-refcnt for kthread */
> > +
> > +	return rcpu;
> > +
> > +fail:   /* Hint: free API detect NULL values */
> > +	free_percpu(rcpu->bulkq);
> > +	kfree(rcpu->queue);
> > +	kfree(rcpu);
> > +	return NULL;
> > +}
> > +
> > +void __cpu_map_entry_free(struct rcu_head *rcu)
> > +{
> > +	struct bpf_cpu_map_entry *rcpu;
> > +	int cpu;
> > +
> > +	/* This cpu_map_entry have been disconnected from map and one
> > +	 * RCU graze-period have elapsed.  Thus, XDP cannot queue any
> > +	 * new packets and cannot change/set flush_needed that can
> > +	 * find this entry.
> > +	 */
> > +	rcpu = container_of(rcu, struct bpf_cpu_map_entry, rcu);
> > +
> > +	/* Flush remaining packets in percpu bulkq */
> > +	for_each_online_cpu(cpu) {
> > +		struct xdp_bulk_queue *bq = per_cpu_ptr(rcpu->bulkq, cpu);
> > +
> > +		/* No concurrent bq_enqueue can run at this point */
> > +		bq_flush_to_queue(rcpu, bq);
> > +	}
> > +	free_percpu(rcpu->bulkq);
> > +	/* Cannot kthread_stop() here, last put free rcpu resources */
> > +	put_cpu_map_entry(rcpu);
> > +}
> > +
> > +/* After xchg pointer to bpf_cpu_map_entry, use the call_rcu() to
> > + * ensure any driver rcu critical sections have completed, but this
> > + * does not guarantee a flush has happened yet. Because driver side
> > + * rcu_read_lock/unlock only protects the running XDP program.  The
> > + * atomic xchg and NULL-ptr check in __cpu_map_flush() makes sure a
> > + * pending flush op doesn't fail.
> > + *
> > + * The bpf_cpu_map_entry is still used by the kthread, and there can
> > + * still be pending packets (in queue and percpu bulkq).  A refcnt
> > + * makes sure to last user (kthread_stop vs. call_rcu) free memory
> > + * resources.
> > + *
> > + * The rcu callback __cpu_map_entry_free flush remaining packets in
> > + * percpu bulkq to queue.  Due to caller map_delete_elem() disable
> > + * preemption, cannot call kthread_stop() to make sure queue is empty.
> > + * Instead a work_queue is started for stopping kthread,
> > + * cpu_map_kthread_stop, which waits for an RCU graze period before
> > + * stopping kthread, emptying the queue.
> > + */
> > +void __cpu_map_entry_replace(struct bpf_cpu_map *cmap,
> > +			     u32 key_cpu, struct bpf_cpu_map_entry *rcpu)
> > +{
> > +	struct bpf_cpu_map_entry *old_rcpu;
> > +
> > +	old_rcpu = xchg(&cmap->cpu_map[key_cpu], rcpu);
> > +	if (old_rcpu) {
> > +		call_rcu(&old_rcpu->rcu, __cpu_map_entry_free);
> > +		INIT_WORK(&old_rcpu->kthread_stop_wq, cpu_map_kthread_stop);
> > +		schedule_work(&old_rcpu->kthread_stop_wq);
> > +	}
> > +}
> > +
> > +int cpu_map_delete_elem(struct bpf_map *map, void *key)
> > +{
> > +	struct bpf_cpu_map *cmap = container_of(map, struct bpf_cpu_map, map);
> > +	u32 key_cpu = *(u32 *)key;
> > +
> > +	if (key_cpu >= map->max_entries)
> > +		return -EINVAL;
> > +
> > +	/* notice caller map_delete_elem() use preempt_disable() */
> > +	__cpu_map_entry_replace(cmap, key_cpu, NULL);
> > +	return 0;
> > +}
> > +
> > +int cpu_map_update_elem(struct bpf_map *map, void *key, void *value,
> > +				u64 map_flags)
> > +{
> > +	struct bpf_cpu_map *cmap = container_of(map, struct bpf_cpu_map, map);
> > +	struct bpf_cpu_map_entry *rcpu;
> > +
> > +	/* Array index key correspond to CPU number */
> > +	u32 key_cpu = *(u32 *)key;
> > +	/* Value is the queue size */
> > +	u32 qsize = *(u32 *)value;
> > +
> > +	/* Make sure CPU is a valid possible cpu */
> > +	if (!cpu_possible(key_cpu))
> > +		return -ENODEV;
> > +
> > +	if (unlikely(map_flags > BPF_EXIST))
> > +		return -EINVAL;
> > +	if (unlikely(key_cpu >= cmap->map.max_entries))
> > +		return -E2BIG;
> > +	if (unlikely(map_flags == BPF_NOEXIST))
> > +		return -EEXIST;
> > +	if (unlikely(qsize > 16384)) /* sanity limit on qsize */
> > +		return -EOVERFLOW;
> > +
> > +	if (qsize == 0) {
> > +		rcpu = NULL; /* Same as deleting */
> > +	} else {
> > +		/* Updating qsize cause re-allocation of bpf_cpu_map_entry */
> > +		rcpu = __cpu_map_entry_alloc(qsize, key_cpu, map->id);
> > +		if (!rcpu)
> > +			return -ENOMEM;
> > +	}
> > +	rcu_read_lock();
> > +	__cpu_map_entry_replace(cmap, key_cpu, rcpu);
> > +	rcu_read_unlock();
> > +	return 0;  
> 
> You need to update verifier such that this function cannot be called
> out of an BPF program,

In the example BPF program, I do a lookup into the map, but only to
verify that an entry exist (I don't look at the value).  I would like
to support such usage.


> otherwise it would be possible under full RCU
> read context, which is explicitly avoided here and also it would otherwise
> be allowed for other maps of different type as well, which needs to
> be avoided.

Sorry, I don't follow this.

 
> > +}
> > +
> > +void cpu_map_free(struct bpf_map *map)
> > +{
> > +	struct bpf_cpu_map *cmap = container_of(map, struct bpf_cpu_map, map);
> > +	int cpu;
> > +	u32 i;
> > +
> > +	/* At this point bpf_prog->aux->refcnt == 0 and this map->refcnt == 0,
> > +	 * so the bpf programs (can be more than one that used this map) were
> > +	 * disconnected from events. Wait for outstanding critical sections in
> > +	 * these programs to complete. The rcu critical section only guarantees
> > +	 * no further "XDP/bpf-side" reads against bpf_cpu_map->cpu_map.
> > +	 * It does __not__ ensure pending flush operations (if any) are
> > +	 * complete.
> > +	 */
> > +	synchronize_rcu();
> > +
> > +	/* To ensure all pending flush operations have completed wait for flush
> > +	 * bitmap to indicate all flush_needed bits to be zero on _all_ cpus.
> > +	 * Because the above synchronize_rcu() ensures the map is disconnected
> > +	 * from the program we can assume no new bits will be set.
> > +	 */
> > +	for_each_online_cpu(cpu) {
> > +		unsigned long *bitmap = per_cpu_ptr(cmap->flush_needed, cpu);
> > +
> > +		while (!bitmap_empty(bitmap, cmap->map.max_entries))
> > +			cond_resched();
> > +	}
> > +
> > +	/* For cpu_map the remote CPUs can still be using the entries
> > +	 * (struct bpf_cpu_map_entry).
> > +	 */
> > +	for (i = 0; i < cmap->map.max_entries; i++) {
> > +		struct bpf_cpu_map_entry *rcpu;
> > +
> > +		rcpu = READ_ONCE(cmap->cpu_map[i]);
> > +		if (!rcpu)
> > +			continue;
> > +
> > +		/* bq flush and cleanup happens after RCU graze-period */
> > +		__cpu_map_entry_replace(cmap, i, NULL); /* call_rcu */
> > +	}
> > +	free_percpu(cmap->flush_needed);
> > +	bpf_map_area_free(cmap->cpu_map);
> > +	kfree(cmap);
> > +}
> > +
> > +struct bpf_cpu_map_entry *__cpu_map_lookup_elem(struct bpf_map *map, u32 key)
> > +{
> > +	struct bpf_cpu_map *cmap = container_of(map, struct bpf_cpu_map, map);
> > +	struct bpf_cpu_map_entry *rcpu;
> > +
> > +	if (key >= map->max_entries)
> > +		return NULL;
> > +
> > +	rcpu = READ_ONCE(cmap->cpu_map[key]);
> > +	return rcpu;
> > +}
> > +
> > +static void *cpu_map_lookup_elem(struct bpf_map *map, void *key)
> > +{
> > +	struct bpf_cpu_map_entry *rcpu =
> > +		__cpu_map_lookup_elem(map, *(u32 *)key);
> > +
> > +	return rcpu ? &rcpu->qsize : NULL;  
> 
> The qsize doesn't seem used anywhere else besides here, but you
> probably should update verifier such that this cannot be called
> out of the BPF program, which could then mangle qsize value.

It is true that the BPF prog can modify this qsize value, but it's not
the authoritative value, so it doesn't really matter.

As I said above, I do want to do a lookup from a BPF program.  To allow
to BPF program to know, if an entry is valid, else it will blindly
send to a cpu destination.  Maybe bpf_prog's just have to use a
map-on-the-side to coordinate this(?), but then a sysadm modifying the
real cpumap will be invisible to the program.


Maybe we should just disable BPF-progs from reading this in the first
iteration?  It would allow for more advanced usage schemes later..

One crazy idea is to have the cpu_map_lookup_elem() return if any
packets are in-flight on this cpu-queue. (Making it easier to avoid OoO
packets, when switching target CPU, but it can also be implemented by
the BPF-programmer herself via maps, although via some extra atomic
cost).


> > +}
> > +
> > +static int cpu_map_get_next_key(struct bpf_map *map, void *key, void *next_key)
> > +{
> > +	struct bpf_cpu_map *cmap = container_of(map, struct bpf_cpu_map, map);
> > +	u32 index = key ? *(u32 *)key : U32_MAX;
> > +	u32 *next = next_key;
> > +
> > +	if (index >= cmap->map.max_entries) {
> > +		*next = 0;
> > +		return 0;
> > +	}
> > +
> > +	if (index == cmap->map.max_entries - 1)
> > +		return -ENOENT;
> > +	*next = index + 1;
> > +	return 0;
> > +}


I would have liked to have implemented next_key so it only returned the
next valid cpu_entry, and used it as a simple round-robin scheduler.
But AFAIK the next_key function is not allowed from bpf_prog's, right?


> > +
> > +const struct bpf_map_ops cpu_map_ops = {
> > +	.map_alloc		= cpu_map_alloc,
> > +	.map_free		= cpu_map_free,
> > +	.map_delete_elem	= cpu_map_delete_elem,
> > +	.map_update_elem	= cpu_map_update_elem,
> > +	.map_lookup_elem	= cpu_map_lookup_elem,
> > +	.map_get_next_key	= cpu_map_get_next_key,
> > +};
> > +
> > +static int bq_flush_to_queue(struct bpf_cpu_map_entry *rcpu,
> > +			     struct xdp_bulk_queue *bq)
> > +{
> > +	struct ptr_ring *q;
> > +	int i;
> > +
> > +	if (unlikely(!bq->count))
> > +		return 0;
> > +
> > +	q = rcpu->queue;
> > +	spin_lock(&q->producer_lock);
> > +
> > +	for (i = 0; i < bq->count; i++) {
> > +		void *xdp_pkt = bq->q[i];
> > +		int err;
> > +
> > +		err = __ptr_ring_produce(q, xdp_pkt);
> > +		if (err) {
> > +			/* Free xdp_pkt */
> > +			page_frag_free(xdp_pkt);
> > +		}
> > +	}
> > +	bq->count = 0;
> > +	spin_unlock(&q->producer_lock);
> > +
> > +	return 0;
> > +}
> > +
[...]


-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
