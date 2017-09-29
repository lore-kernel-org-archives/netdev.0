From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [net-next V2 PATCH 1/5] bpf: introduce new bpf cpu map type
 BPF_MAP_TYPE_CPUMAP
Date: Fri, 29 Sep 2017 21:58:48 +0200
Message-ID: <20170929215848.46ca5257@redhat.com>
References: <150670281423.23765.8984643281418950330.stgit@firesoul>
        <150670285218.23765.2480801081343646072.stgit@firesoul>
        <20170929114154.4b5d5918@cakuba>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael S. Tsirkin" <mst@redhat.com>,
        Jason Wang <jasowang@redhat.com>, mchan@broadcom.com,
        John Fastabend <john.fastabend@gmail.com>,
        peter.waskiewicz.jr@intel.com,
        Daniel Borkmann <borkmann@iogearbox.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Andy Gospodarek <andy@greyhouse.net>, brouer@redhat.com
To: Jakub Kicinski <kubakici@wp.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52362 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752006AbdI2T65 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 29 Sep 2017 15:58:57 -0400
In-Reply-To: <20170929114154.4b5d5918@cakuba>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 29 Sep 2017 11:41:54 -0700
Jakub Kicinski <kubakici@wp.pl> wrote:

> On Fri, 29 Sep 2017 18:34:12 +0200, Jesper Dangaard Brouer wrote:
> > The 'cpumap' is primary used as a backend map for XDP BPF helper
> > call bpf_redirect_map() and XDP_REDIRECT action, like 'devmap'.
> > 
> > This patch implement the main part of the map.  It is not connected to
> > the XDP redirect system yet, and no SKB allocation are done yet.
> > 
> > The main concern in this patch is to ensure the datapath can run
> > without any locking.  This adds complexity to the setup and tear-down
> > procedure, which assumptions are extra carefully documented in the
> > code comments.
> > 
> > V2: make sure array isn't larger than num possible CPUs
> > 
> > Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>  
> 
> Few trivial nitpicks, hope you don't mind :)
> 
> > @@ -0,0 +1,555 @@
> > +/* bpf/cpumap.c
> > + *
> > + * Copyright (c) 2017 Jesper Dangaard Brouer, Red Hat Inc.
> > + * Released under terms in GPL version 2.  See COPYING.
> > + */
> > +
> > +/* The 'cpumap' is primary used as a backend map for XDP BPF helper
> > + * call bpf_redirect_map() and XDP_REDIRECT action, like 'devmap'.
> > + *
> > + * Unlike devmap which redirect XDP frames out another NIC device,
> > + * this map type redirect raw XDP frames to another CPU.  The remote
> > + * CPU will do SKB-allocation and call the normal network stack.
> > + *
> > + * This is a scalability and isolation mechanism, that allow
> > + * separating the early driver network XDP layer, from the rest of the
> > + * netstack, and assigning dedicated CPUs for this stage.  This
> > + * basically allows for 10G wirespeed pre-filtering via bpf.
> > + */
> > +#include <linux/bpf.h>
> > +#include <linux/filter.h>
> > +#include <linux/ptr_ring.h>
> > +
> > +#include <linux/sched.h>
> > +#include <linux/workqueue.h>
> > +#include <linux/kthread.h>
> > +
> > +/*
> > + * General idea: XDP packets getting XDP redirected to another CPU,
> > + * will maximum be stored/queued for one driver ->poll() call.  It is
> > + * guaranteed that setting flush bit and flush operation happen on
> > + * same CPU.  Thus, cpu_map_flush operation can deduct via this_cpu_ptr()
> > + * which queue in bpf_cpu_map_entry contains packets.
> > + */
> > +
> > +#define CPU_MAP_BULK_SIZE 8  /* 8 == one cacheline on 64-bit archs */
> > +struct xdp_bulk_queue {
> > +	void *q[CPU_MAP_BULK_SIZE];
> > +	unsigned int count;
> > +};  
> 
> Out of curiosity - would it make sense to make sure the entire struct
> fits into a cache line?  The comment seems to indicate that the array is
> sized to fit a cache line, but then there is also the count member...

Nope, it does not make sense to align the struct itself for a cacheline.
The idea is that when I bulk enqueue transfer (from this percpu mem)
into the shared queue (ptr_ring), then I dirty a cacheline, thus I
might as well fill up the cacheline.


> > +/*
> > + * After xchg pointer to bpf_cpu_map_entry, use the call_rcu() to  
> ...
> 
> There is a mix for networking and non-networking style comments in this
> file, is this intentional?

No
 
> > +const struct bpf_map_ops cpu_map_ops = {
> > +	.map_alloc		= cpu_map_alloc,
> > +	.map_free		= cpu_map_free,
> > +	.map_delete_elem	= cpu_map_delete_elem,
> > +	.map_update_elem	= cpu_map_update_elem,
> > +	.map_lookup_elem	= cpu_map_lookup_elem,
> > +	.map_get_next_key	= cpu_map_get_next_key,
> > +};
> > +
> > +  
> 
> Extra new line.

Sorry

> > +/* Runs under RCU-read-side, plus in softirq under NAPI protection.
> > + * Thus, safe percpu variable access.
> > + */
> > +static int bq_enqueue(struct bpf_cpu_map_entry *rcpu, struct xdp_pkt *xdp_pkt)
> > +{
> > +	struct xdp_bulk_queue *bq = this_cpu_ptr(rcpu->bulkq);
> > +
> > +	if (unlikely(bq->count == CPU_MAP_BULK_SIZE)) {
> > +		bq_flush_to_queue(rcpu, bq);
> > +	}  
> 
> Curly brackets not needed.

Sorry

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
