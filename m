From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: [PATCH net-next] bpf: fix numa_node validation
Date: Tue, 5 Sep 2017 15:30:21 -0700
Message-ID: <20170905223021.uclihvksjmunfikj@kafai-mba.dhcp.thefacebook.com>
References: <1504590062.15310.36.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Alexei Starovoitov <ast@fb.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:58651 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753074AbdIEWap (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 5 Sep 2017 18:30:45 -0400
Content-Disposition: inline
In-Reply-To: <1504590062.15310.36.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 04, 2017 at 10:41:02PM -0700, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> syzkaller reported crashes in bpf map creation or map update [1]
>
> Problem is that nr_node_ids is a signed integer,
> NUMA_NO_NODE is also an integer, so it is very tempting
> to declare numa_node as a signed integer.
>
> This means the typical test to validate a user provided value :
>
>         if (numa_node != NUMA_NO_NODE &&
>             (numa_node >= nr_node_ids ||
>              !node_online(numa_node)))
>
> must be written :
>
>         if (numa_node != NUMA_NO_NODE &&
>             ((unsigned int)numa_node >= nr_node_ids ||
Thanks for fixing it.

>              !node_online(numa_node)))
>
>
> [1]
> kernel BUG at mm/slab.c:3256!
> invalid opcode: 0000 [#1] SMP KASAN
> Dumping ftrace buffer:
>    (ftrace buffer empty)
> Modules linked in:
> CPU: 0 PID: 2946 Comm: syzkaller916108 Not tainted 4.13.0-rc7+ #35
> Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS Google 01/01/2011
> task: ffff8801d2bc60c0 task.stack: ffff8801c0c90000
> RIP: 0010:____cache_alloc_node+0x1d4/0x1e0 mm/slab.c:3292
> RSP: 0018:ffff8801c0c97638 EFLAGS: 00010096
> RAX: ffffffffffff8b7b RBX: 0000000001080220 RCX: 0000000000000000
> RDX: 00000000ffff8b7b RSI: 0000000001080220 RDI: ffff8801dac00040
> RBP: ffff8801c0c976c0 R08: 0000000000000000 R09: 0000000000000000
> R10: ffff8801c0c97620 R11: 0000000000000001 R12: ffff8801dac00040
> R13: ffff8801dac00040 R14: 0000000000000000 R15: 00000000ffff8b7b
> FS:  0000000002119940(0000) GS:ffff8801db200000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: 0000000020001fec CR3: 00000001d2980000 CR4: 00000000001406f0
> Call Trace:
>  __do_kmalloc_node mm/slab.c:3688 [inline]
>  __kmalloc_node+0x33/0x70 mm/slab.c:3696
>  kmalloc_node include/linux/slab.h:535 [inline]
>  alloc_htab_elem+0x2a8/0x480 kernel/bpf/hashtab.c:740
>  htab_map_update_elem+0x740/0xb80 kernel/bpf/hashtab.c:820
>  map_update_elem kernel/bpf/syscall.c:587 [inline]
>  SYSC_bpf kernel/bpf/syscall.c:1468 [inline]
>  SyS_bpf+0x20c5/0x4c40 kernel/bpf/syscall.c:1443
>  entry_SYSCALL_64_fastpath+0x1f/0xbe
> RIP: 0033:0x440409
> RSP: 002b:00007ffd1f1792b8 EFLAGS: 00000246 ORIG_RAX: 0000000000000141
> RAX: ffffffffffffffda RBX: 00000000004002c8 RCX: 0000000000440409
> RDX: 0000000000000020 RSI: 0000000020006000 RDI: 0000000000000002
> RBP: 0000000000000086 R08: 0000000000000000 R09: 0000000000000000
> R10: 0000000000000000 R11: 0000000000000246 R12: 0000000000401d70
> R13: 0000000000401e00 R14: 0000000000000000 R15: 0000000000000000
> Code: 83 c2 01 89 50 18 4c 03 70 08 e8 38 f4 ff ff 4d 85 f6 0f 85 3e ff ff ff 44 89 fe 4c 89 ef e8 94 fb ff ff 49 89 c6 e9 2b ff ff ff <0f> 0b 0f 0b 0f 0b 66 0f 1f 44 00 00 55 48 89 e5 41 57 41 56 41
> RIP: ____cache_alloc_node+0x1d4/0x1e0 mm/slab.c:3292 RSP: ffff8801c0c97638
> ---[ end trace d745f355da2e33ce ]---
> Kernel panic - not syncing: Fatal exception
>
> Fixes: 96eabe7a40aa ("bpf: Allow selecting numa node during map creation")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Martin KaFai Lau <kafai@fb.com>
> Cc: Alexei Starovoitov <ast@fb.com>
> Cc: Daniel Borkmann <daniel@iogearbox.net>
> ---
>  kernel/bpf/syscall.c |    3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
>
> diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
> index 021a05d9d80095303bdfed51ee85bd9067582774..70ad8e220343c7825c8e331f19c1f65c78fdb796 100644
> --- a/kernel/bpf/syscall.c
> +++ b/kernel/bpf/syscall.c
> @@ -323,7 +323,8 @@ static int map_create(union bpf_attr *attr)
>  		return -EINVAL;
>
>  	if (numa_node != NUMA_NO_NODE &&
> -	    (numa_node >= nr_node_ids || !node_online(numa_node)))
> +	    ((unsigned int)numa_node >= nr_node_ids ||
> +	     !node_online(numa_node)))
>  		return -EINVAL;
>
>  	/* find map type and init map: hashtable vs rbtree vs bloom vs ... */
>
>
