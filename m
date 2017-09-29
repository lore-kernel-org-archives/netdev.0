From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [net-next PATCH 1/5] bpf: introduce new bpf cpu map type
 BPF_MAP_TYPE_CPUMAP
Date: Thu, 28 Sep 2017 20:21:47 -0700
Message-ID: <20170929032146.vs5v454wjs4niu4k@ast-mbp>
References: <150660339205.2808.7084136789768233829.stgit@firesoul>
 <150660342793.2808.10838498581615265043.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jakub.kicinski@netronome.com,
        "Michael S. Tsirkin" <mst@redhat.com>,
        Jason Wang <jasowang@redhat.com>, mchan@broadcom.com,
        John Fastabend <john.fastabend@gmail.com>,
        peter.waskiewicz.jr@intel.com,
        Daniel Borkmann <borkmann@iogearbox.net>,
        Andy Gospodarek <andy@greyhouse.net>,
        hannes@stressinduktion.org
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:38843 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750763AbdI2DVv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 28 Sep 2017 23:21:51 -0400
Received: by mail-pg0-f65.google.com with SMTP id y192so100403pgd.5
        for <netdev@vger.kernel.org>; Thu, 28 Sep 2017 20:21:51 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <150660342793.2808.10838498581615265043.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 28, 2017 at 02:57:08PM +0200, Jesper Dangaard Brouer wrote:
> The 'cpumap' is primary used as a backend map for XDP BPF helper
> call bpf_redirect_map() and XDP_REDIRECT action, like 'devmap'.
> 
> This patch implement the main part of the map.  It is not connected to
> the XDP redirect system yet, and no SKB allocation are done yet.
> 
> The main concern in this patch is to ensure the datapath can run
> without any locking.  This adds complexity to the setup and tear-down
> procedure, which assumptions are extra carefully documented in the
> code comments.
> 
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
> ---
>  include/linux/bpf_types.h      |    1 
>  include/uapi/linux/bpf.h       |    1 
>  kernel/bpf/Makefile            |    1 
>  kernel/bpf/cpumap.c            |  547 ++++++++++++++++++++++++++++++++++++++++
>  kernel/bpf/syscall.c           |    8 +
>  tools/include/uapi/linux/bpf.h |    1 
>  6 files changed, 558 insertions(+), 1 deletion(-)
>  create mode 100644 kernel/bpf/cpumap.c
> 
> diff --git a/include/linux/bpf_types.h b/include/linux/bpf_types.h
> index 6f1a567667b8..814c1081a4a9 100644
> --- a/include/linux/bpf_types.h
> +++ b/include/linux/bpf_types.h
> @@ -41,4 +41,5 @@ BPF_MAP_TYPE(BPF_MAP_TYPE_DEVMAP, dev_map_ops)
>  #ifdef CONFIG_STREAM_PARSER
>  BPF_MAP_TYPE(BPF_MAP_TYPE_SOCKMAP, sock_map_ops)
>  #endif
> +BPF_MAP_TYPE(BPF_MAP_TYPE_CPUMAP, cpu_map_ops)
>  #endif
> diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
> index e43491ac4823..f14e15702533 100644
> --- a/include/uapi/linux/bpf.h
> +++ b/include/uapi/linux/bpf.h
> @@ -111,6 +111,7 @@ enum bpf_map_type {
>  	BPF_MAP_TYPE_HASH_OF_MAPS,
>  	BPF_MAP_TYPE_DEVMAP,
>  	BPF_MAP_TYPE_SOCKMAP,
> +	BPF_MAP_TYPE_CPUMAP,
>  };
>  
>  enum bpf_prog_type {
> diff --git a/kernel/bpf/Makefile b/kernel/bpf/Makefile
> index 897daa005b23..dba0bd33a43c 100644
> --- a/kernel/bpf/Makefile
> +++ b/kernel/bpf/Makefile
> @@ -4,6 +4,7 @@ obj-$(CONFIG_BPF_SYSCALL) += syscall.o verifier.o inode.o helpers.o tnum.o
>  obj-$(CONFIG_BPF_SYSCALL) += hashtab.o arraymap.o percpu_freelist.o bpf_lru_list.o lpm_trie.o map_in_map.o
>  ifeq ($(CONFIG_NET),y)
>  obj-$(CONFIG_BPF_SYSCALL) += devmap.o
> +obj-$(CONFIG_BPF_SYSCALL) += cpumap.o
>  ifeq ($(CONFIG_STREAM_PARSER),y)
>  obj-$(CONFIG_BPF_SYSCALL) += sockmap.o
>  endif
> diff --git a/kernel/bpf/cpumap.c b/kernel/bpf/cpumap.c
> new file mode 100644
> index 000000000000..f0948af82e65
> --- /dev/null
> +++ b/kernel/bpf/cpumap.c
> @@ -0,0 +1,547 @@
> +/* bpf/cpumap.c
> + *
> + * Copyright (c) 2017 Jesper Dangaard Brouer, Red Hat Inc.
> + * Released under terms in GPL version 2.  See COPYING.
> + */
> +
> +/* The 'cpumap' is primary used as a backend map for XDP BPF helper
> + * call bpf_redirect_map() and XDP_REDIRECT action, like 'devmap'.
> + *
> + * Unlike devmap which redirect XDP frames out another NIC device,
> + * this map type redirect raw XDP frames to another CPU.  The remote
> + * CPU will do SKB-allocation and call the normal network stack.
> + *
> + * This is a scalability and isolation mechanism, that allow
> + * separating the early driver network XDP layer, from the rest of the
> + * netstack, and assigning dedicated CPUs for this stage.  This
> + * basically allows for 10G wirespeed pre-filtering via bpf.
> + */
> +#include <linux/bpf.h>
> +#include <linux/filter.h>
> +#include <linux/ptr_ring.h>
> +
> +#include <linux/sched.h>
> +#include <linux/workqueue.h>
> +#include <linux/kthread.h>
> +
> +/*
> + * General idea: XDP packets getting XDP redirected to another CPU,
> + * will maximum be stored/queued for one driver ->poll() call.  It is
> + * guaranteed that setting flush bit and flush operation happen on
> + * same CPU.  Thus, cpu_map_flush operation can deduct via this_cpu_ptr()
> + * which queue in bpf_cpu_map_entry contains packets.
> + */
> +
> +#define CPU_MAP_BULK_SIZE 8  /* 8 == one cacheline on 64-bit archs */
> +struct xdp_bulk_queue {
> +	void *q[CPU_MAP_BULK_SIZE];
> +	unsigned int count;
> +};
> +
> +/* Struct for every remote "destination" CPU in map */
> +struct bpf_cpu_map_entry {
> +	u32 cpu;    /* kthread CPU and map index */
> +	int map_id; /* Back reference to map */
> +	u32 qsize;  /* Redundant queue size for map lookup */
> +
> +	/* XDP can run multiple RX-ring queues, need __percpu enqueue store */
> +	struct xdp_bulk_queue __percpu *bulkq;
> +
> +	/* Queue with potential multi-producers, and single-consumer kthread */
> +	struct ptr_ring *queue;
> +	struct task_struct *kthread;
> +	struct work_struct kthread_stop_wq;
> +
> +	atomic_t refcnt; /* Control when this struct can be free'ed */
> +	struct rcu_head rcu;
> +};
> +
> +struct bpf_cpu_map {
> +	struct bpf_map map;
> +	/* Below members specific for map type */
> +	struct bpf_cpu_map_entry **cpu_map;
> +	unsigned long __percpu *flush_needed;
> +};
> +
> +static int bq_flush_to_queue(struct bpf_cpu_map_entry *rcpu,
> +			     struct xdp_bulk_queue *bq);
> +
> +static u64 cpu_map_bitmap_size(const union bpf_attr *attr)
> +{
> +	return BITS_TO_LONGS(attr->max_entries) * sizeof(unsigned long);
> +}
> +
> +static struct bpf_map *cpu_map_alloc(union bpf_attr *attr)
> +{
> +	struct bpf_cpu_map *cmap;
> +	u64 cost;
> +	int err;
> +
> +	/* check sanity of attributes */
> +	if (attr->max_entries == 0 || attr->key_size != 4 ||
> +	    attr->value_size != 4 || attr->map_flags & ~BPF_F_NUMA_NODE)
> +		return ERR_PTR(-EINVAL);
> +
> +	cmap = kzalloc(sizeof(*cmap), GFP_USER);
> +	if (!cmap)
> +		return ERR_PTR(-ENOMEM);
> +
> +	/* mandatory map attributes */
> +	cmap->map.map_type = attr->map_type;
> +	cmap->map.key_size = attr->key_size;
> +	cmap->map.value_size = attr->value_size;
> +	cmap->map.max_entries = attr->max_entries;
> +	cmap->map.map_flags = attr->map_flags;
> +	cmap->map.numa_node = bpf_map_attr_numa_node(attr);
> +
> +	/* make sure page count doesn't overflow */
> +	cost = (u64) cmap->map.max_entries * sizeof(struct bpf_cpu_map_entry *);
> +	cost += cpu_map_bitmap_size(attr) * num_possible_cpus();
> +	if (cost >= U32_MAX - PAGE_SIZE)
> +		goto free_cmap;
> +	cmap->map.pages = round_up(cost, PAGE_SIZE) >> PAGE_SHIFT;
> +
> +	/* if map size is larger than memlock limit, reject it early */
> +	err = bpf_map_precharge_memlock(cmap->map.pages);
> +	if (err)
> +		goto free_cmap;
> +
> +	/* A per cpu bitfield with a bit per possible CPU in map  */
> +	cmap->flush_needed = __alloc_percpu(cpu_map_bitmap_size(attr),
> +					    __alignof__(unsigned long));
> +	if (!cmap->flush_needed)
> +		goto free_cmap;
> +
> +	/* Alloc array for possible remote "destination" CPUs */
> +	cmap->cpu_map = bpf_map_area_alloc(cmap->map.max_entries *
> +					   sizeof(struct bpf_cpu_map_entry *),
> +					   cmap->map.numa_node);
> +	if (!cmap->cpu_map)
> +		goto free_cmap;
> +
> +	return &cmap->map;
> +free_cmap:
> +	free_percpu(cmap->flush_needed);
> +	kfree(cmap);
> +	return ERR_PTR(-ENOMEM);
> +}
> +
> +void __cpu_map_queue_destructor(void *ptr)
> +{
> +	/* For now, just catch this as an error */
> +	if (!ptr)
> +		return;
> +	pr_err("ERROR: %s() cpu_map queue was not empty\n", __func__);
> +	page_frag_free(ptr);
> +}
> +
> +static void put_cpu_map_entry(struct bpf_cpu_map_entry *rcpu)
> +{
> +	if (atomic_dec_and_test(&rcpu->refcnt)) {
> +		/* The queue should be empty at this point */
> +		ptr_ring_cleanup(rcpu->queue, __cpu_map_queue_destructor);
> +		kfree(rcpu->queue);
> +		kfree(rcpu);
> +	}
> +}
> +
> +static void get_cpu_map_entry(struct bpf_cpu_map_entry *rcpu)
> +{
> +	atomic_inc(&rcpu->refcnt);
> +}
> +
> +/* called from workqueue, to workaround syscall using preempt_disable */
> +static void cpu_map_kthread_stop(struct work_struct *work)
> +{
> +	struct bpf_cpu_map_entry *rcpu;
> +
> +	rcpu = container_of(work, struct bpf_cpu_map_entry, kthread_stop_wq);
> +	synchronize_rcu(); /* wait for flush in __cpu_map_entry_free() */
> +	kthread_stop(rcpu->kthread); /* calls put_cpu_map_entry */
> +}
> +
> +static int cpu_map_kthread_run(void *data)
> +{
> +	struct bpf_cpu_map_entry *rcpu = data;
> +
> +	set_current_state(TASK_INTERRUPTIBLE);
> +	while (!kthread_should_stop()) {
> +		struct xdp_pkt *xdp_pkt;
> +
> +		schedule();
> +		/* Do work */
> +		while ((xdp_pkt = ptr_ring_consume(rcpu->queue))) {
> +			/* For now just "refcnt-free" */
> +			page_frag_free(xdp_pkt);
> +		}
> +		__set_current_state(TASK_INTERRUPTIBLE);
> +	}
> +	put_cpu_map_entry(rcpu);
> +
> +	__set_current_state(TASK_RUNNING);
> +	return 0;
> +}
> +
> +struct bpf_cpu_map_entry *__cpu_map_entry_alloc(u32 qsize, u32 cpu, int map_id)
> +{
> +	gfp_t gfp = GFP_ATOMIC|__GFP_NOWARN;
> +	struct bpf_cpu_map_entry *rcpu;
> +	int numa, err;
> +
> +	/* Have map->numa_node, but choose node of redirect target CPU */
> +	numa = cpu_to_node(cpu);
> +
> +	rcpu = kzalloc_node(sizeof(*rcpu), gfp, numa);
> +	if (!rcpu)
> +		return NULL;
> +
> +	/* Alloc percpu bulkq */
> +	rcpu->bulkq = __alloc_percpu_gfp(sizeof(*rcpu->bulkq),
> +					 sizeof(void *), gfp);
> +	if (!rcpu->bulkq)
> +		goto fail;
> +
> +	/* Alloc queue */
> +	rcpu->queue = kzalloc_node(sizeof(*rcpu->queue), gfp, numa);
> +	if (!rcpu->queue)
> +		goto fail;
> +
> +	err = ptr_ring_init(rcpu->queue, qsize, gfp);
> +	if (err)
> +		goto fail;
> +	rcpu->qsize = qsize;
> +
> +	/* Setup kthread */
> +	rcpu->kthread = kthread_create_on_node(cpu_map_kthread_run, rcpu, numa,
> +					       "cpumap/%d/map:%d", cpu, map_id);
> +	if (IS_ERR(rcpu->kthread))
> +		goto fail;
> +
> +	/* Make sure kthread runs on a single CPU */
> +	kthread_bind(rcpu->kthread, cpu);

is there a check that max_entries <= num_possible_cpu ? I couldn't find it.
otherwise it will be binding to impossible cpu?

> +	wake_up_process(rcpu->kthread);

In general the whole thing looks like 'threaded NAPI' that Hannes was
proposing some time back. I liked it back then and I like it now.
I don't remember what were the objections back then.
Something scheduler related?
Adding Hannes.

Still curious about the questions I asked in the other thread
on what's causing it to be so much better than RPS
