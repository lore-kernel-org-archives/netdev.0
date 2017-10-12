From: Edward Cree <ecree@solarflare.com>
Subject: Re: [net-next V7 PATCH 1/5] bpf: introduce new bpf cpu map type
 BPF_MAP_TYPE_CPUMAP
Date: Thu, 12 Oct 2017 21:35:05 +0100
Message-ID: <de3a227a-da92-b905-11d0-ecc5a05f3bc0@solarflare.com>
References: <150781116384.9409.2491501775270038284.stgit@firesoul>
 <150781120970.9409.4248519763583438653.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <jakub.kicinski@netronome.com>,
        "Michael S. Tsirkin" <mst@redhat.com>, <pavel.odintsov@gmail.com>,
        Jason Wang <jasowang@redhat.com>, <mchan@broadcom.com>,
        John Fastabend <john.fastabend@gmail.com>,
        <peter.waskiewicz.jr@intel.com>, <ast@fiberby.dk>,
        Daniel Borkmann <borkmann@iogearbox.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Andy Gospodarek <andy@greyhouse.net>
To: Jesper Dangaard Brouer <brouer@redhat.com>,
        <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dispatch1-us1.ppe-hosted.com ([148.163.129.52]:37290 "EHLO
        dispatch1-us1.ppe-hosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752452AbdJLUfT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2017 16:35:19 -0400
In-Reply-To: <150781120970.9409.4248519763583438653.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/10/17 13:26, Jesper Dangaard Brouer wrote:
> The 'cpumap' is primary used as a backend map for XDP BPF helper
s/primary/primarily.
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
> V2:
>  - make sure array isn't larger than NR_CPUS
>  - make sure CPUs added is a valid possible CPU
>
> V3: fix nitpicks from Jakub Kicinski <kubakici@wp.pl>
>
> V5:
>  - Restrict map allocation to root / CAP_SYS_ADMIN
>  - WARN_ON_ONCE if queue is not empty on tear-down
>  - Return -EPERM on memlock limit instead of -ENOMEM
>  - Error code in __cpu_map_entry_alloc() also handle ptr_ring_cleanup()
>  - Moved cpu_map_enqueue() to next patch
>
> V6: all notice by Daniel Borkmann
>  - Fix err return code in cpu_map_alloc() introduced in V5
>  - Move cpu_possible() check after max_entries boundary check
>  - Forbid usage initially in check_map_func_compatibility()
>
> V7:
>  - Fix alloc error path spotted by Daniel Borkmann
>  - Did stress test adding+removing CPUs from the map concurrently
>  - Fixed refcnt issue on cpu_map_entry, kthread started too soon
>  - Make sure packets are flushed during tear-down, involved use of
>    rcu_barrier() and kthread_run only exit after queue is empty
>  - Fix alloc error path in __cpu_map_entry_alloc() for ptr_ring
>
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
> ---
>  include/linux/bpf_types.h      |    1 
>  include/uapi/linux/bpf.h       |    1 
>  kernel/bpf/Makefile            |    1 
>  kernel/bpf/cpumap.c            |  561 ++++++++++++++++++++++++++++++++++++++++
>  kernel/bpf/syscall.c           |    8 -
>  kernel/bpf/verifier.c          |    5 
>  tools/include/uapi/linux/bpf.h |    1 
>  7 files changed, 577 insertions(+), 1 deletion(-)
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
> index 6db9e1d679cd..4303fb6c3817 100644
> --- a/include/uapi/linux/bpf.h
> +++ b/include/uapi/linux/bpf.h
> @@ -112,6 +112,7 @@ enum bpf_map_type {
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
> index 000000000000..34db22afcca2
> --- /dev/null
> +++ b/kernel/bpf/cpumap.c
> @@ -0,0 +1,561 @@
> +/* bpf/cpumap.c
> + *
> + * Copyright (c) 2017 Jesper Dangaard Brouer, Red Hat Inc.
> + * Released under terms in GPL version 2.  See COPYING.
> + */
> +
> +/* The 'cpumap' is primary used as a backend map for XDP BPF helper
Again, s/primary/primarily.
> + * call bpf_redirect_map() and XDP_REDIRECT action, like 'devmap'.
> + *
> + * Unlike devmap which redirect XDP frames out another NIC device,
> + * this map type redirect raw XDP frames to another CPU.  The remote
Also I think both of these 'redirect' should be 'redirects', just a
 grammatical nit pick ;)
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
> +#include <linux/capability.h>
> +
> +/* General idea: XDP packets getting XDP redirected to another CPU,
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
I realise it's a bit late to say this on a v7, but it might be better to
 use a linked-list (list_heads) here instead of an array.  Then, the
 struct xdp_pkt you store in the packet headroom could contain the
 list_head, there's no arbitrary bulking limit, and the flush just has
 to link the newly-created elements into the receiving CPU's list.
Is there an obvious reason why this wouldn't work / can't perform as
 well, or should I try it and benchmark it?

-Ed
