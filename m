From: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Subject: Use after free in __dst_destroy_metrics_generic
Date: Thu, 07 Sep 2017 18:52:02 -0600
Message-ID: <1234e09b75197d43ed84bdb1b154b4b6@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, lorenzo@google.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:39154 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752966AbdIHAwD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 7 Sep 2017 20:52:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We are seeing a possible use after free in ip6_dst_destroy.

It appears as if memory of the __DST_METRICS_PTR(old) was freed in some 
path and allocated
to ion driver. ion driver has also freed it. Finally the memory is freed 
by the
fib gc and crashes since it is already deallocated.

Target is running an ARM64 Android based 4.9 kernel.
Issue was seen once on a regression rack (sorry, no reproducer).
Any pointers to debug this is highly appreciated.

[ 3489.470581] [<ffffff83c0a289c0>] object_err+0x4c/0x5c
[ 3489.470586] [<ffffff83c0a2b284>] free_debug_processing+0x2e0/0x398
[ 3489.470589] [<ffffff83c0a2b63c>] __slab_free+0x300/0x3e0
[ 3489.470593] [<ffffff83c0a2bfc8>] kfree+0x28c/0x290
[ 3489.470601] [<ffffff83c16b9580>] 
__dst_destroy_metrics_generic+0x6c/0x78
[ 3489.470609] [<ffffff83c17d3408>] ip6_dst_destroy+0xb0/0xb4
[ 3489.470612] [<ffffff83c16b9714>] dst_destroy+0x88/0x174
[ 3489.470616] [<ffffff83c17d7f64>] icmp6_dst_gc+0x90/0xc0
[ 3489.470621] [<ffffff83c17db52c>] fib6_gc_timer_cb+0x40/0xc0
[ 3489.470630] [<ffffff83c093aef4>] call_timer_fn+0x58/0x1d0
[ 3489.470635] [<ffffff83c093b198>] expire_timers+0x100/0x18c
[ 3489.470638] [<ffffff83c093b2bc>] run_timer_softirq+0x98/0x270
[ 3489.470642] [<ffffff83c0881a00>] __do_softirq+0x150/0x438
[ 3489.470649] [<ffffff83c08af59c>] irq_exit+0xe0/0x138

[ 3489.127227] 
=============================================================================
[ 3489.135489] BUG kmalloc-128 (Tainted: G        W  O   ): Object 
already free
[ 3489.142591] 
-----------------------------------------------------------------------------
[ 3489.142591]
[ 3489.152313] Disabling lock debugging due to kernel taint
[ 3489.157688] INFO: Allocated in alloc_largest_available+0x58/0x1f0 
age=17 cpu=4 pid=649
[ 3489.165667]  alloc_debug_processing+0x114/0x1a0
[ 3489.170233]  ___slab_alloc.constprop.72+0x654/0x690
[ 3489.175150]  __slab_alloc.isra.68.constprop.71+0x48/0x80
[ 3489.180505]  kmem_cache_alloc_trace+0x198/0x2c4
[ 3489.185073]  alloc_largest_available+0x58/0x1f0
[ 3489.189643]  ion_system_heap_allocate+0x1b0/0x6e8
[ 3489.194392]  __ion_alloc+0x180/0x988
[ 3489.198004]  ion_ioctl+0x26c/0x590
[ 3489.201437]  do_vfs_ioctl+0xcc/0x888
[ 3489.205037]  SyS_ioctl+0x90/0xa4
[ 3489.208298]  el0_svc_naked+0x24/0x28
[ 3489.211909] INFO: Freed in process_info+0x188/0x1bc age=21 cpu=4 
pid=649
[ 3489.218661]  free_debug_processing+0x180/0x398
[ 3489.223137]  __slab_free+0x300/0x3e0
[ 3489.226745]  kfree+0x28c/0x290
[ 3489.229827]  process_info+0x188/0x1bc
[ 3489.233526]  ion_system_heap_allocate+0x4b4/0x6e8
[ 3489.238266]  __ion_alloc+0x180/0x988
[ 3489.241875]  ion_ioctl+0x26c/0x590
[ 3489.245308]  do_vfs_ioctl+0xcc/0x888
[ 3489.248917]  SyS_ioctl+0x90/0xa4
[ 3489.252171]  el0_svc_naked+0x24/0x28

-- 
Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum, a 
Linux Foundation Collaborative Project
