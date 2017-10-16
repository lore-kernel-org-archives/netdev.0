From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [net-next V8 PATCH 1/5] bpf: introduce new bpf cpu map type
 BPF_MAP_TYPE_CPUMAP
Date: Mon, 16 Oct 2017 14:49:53 -0700
Message-ID: <20171016214951.bia3esapu5o2niva@ast-mbp.dhcp.thefacebook.com>
References: <150814913767.1806.3470498528707259987.stgit@firesoul>
 <150814916887.1806.4443991765779135803.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jakub.kicinski@netronome.com,
        "Michael S. Tsirkin" <mst@redhat.com>, pavel.odintsov@gmail.com,
        Jason Wang <jasowang@redhat.com>, mchan@broadcom.com,
        John Fastabend <john.fastabend@gmail.com>,
        peter.waskiewicz.jr@intel.com, ast@fiberby.dk,
        Daniel Borkmann <borkmann@iogearbox.net>,
        Andy Gospodarek <andy@greyhouse.net>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:54164 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755014AbdJPVt5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2017 17:49:57 -0400
Received: by mail-pf0-f196.google.com with SMTP id t188so14274067pfd.10
        for <netdev@vger.kernel.org>; Mon, 16 Oct 2017 14:49:57 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <150814916887.1806.4443991765779135803.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 16, 2017 at 12:19:28PM +0200, Jesper Dangaard Brouer wrote:
> The 'cpumap' is primarily used as a backend map for XDP BPF helper
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
> V8:
>  - Nitpicking comments and gramma by Edward Cree
>  - Fix missing semi-colon introduced in V7 due to rebasing
>  - Move struct bpf_cpu_map_entry members cpu+map_id to tracepoint patch
> 
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
> ---
>  include/linux/bpf_types.h      |    1 
>  include/uapi/linux/bpf.h       |    1 
>  kernel/bpf/Makefile            |    1 
>  kernel/bpf/cpumap.c            |  560 ++++++++++++++++++++++++++++++++++++++++
>  kernel/bpf/syscall.c           |    8 +
>  kernel/bpf/verifier.c          |    5 
>  tools/include/uapi/linux/bpf.h |    1 
>  7 files changed, 576 insertions(+), 1 deletion(-)
>  create mode 100644 kernel/bpf/cpumap.c

Looks good to me
I like the idea of running networking stack from kthread
and hope adding GRO won't change the api. 
Acked-by: Alexei Starovoitov <ast@kernel.org>
