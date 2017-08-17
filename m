From: Stefano Brivio <sbrivio@redhat.com>
Subject: Re: [PATCH] i40e{,vf}: Fix out-of-bound cpumask read in IRQ
 affinity handler
Date: Thu, 17 Aug 2017 03:01:09 +0200
Message-ID: <20170817030109.31580d73@elisabeth>
References: <ae9c9586f61e914dc1c6fe2e6ac1fb2bf07283bc.1502792828.git.sbrivio@redhat.com>
        <1502929524.32783.3.camel@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org,
        "David S . Miller" <davem@davemloft.net>,
        Alan Brady <alan.brady@intel.com>,
        Stefan Assmann <sassmann@redhat.com>,
        Juergen Gross <jgross@suse.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51396 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751588AbdHQBBQ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 16 Aug 2017 21:01:16 -0400
In-Reply-To: <1502929524.32783.3.camel@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jeff,

On Wed, 16 Aug 2017 17:25:24 -0700
Jeff Kirsher <jeffrey.t.kirsher@intel.com> wrote:

> On Tue, 2017-08-15 at 12:30 +0200, Stefano Brivio wrote:
> > The cpumask used in i40e{,vf}_irq_affinity_notify() is allocated
> > by irq_affinity_notify() with alloc_cpumask_var(), which doesn't
> > allocate NR_CPUS bits, but only nr_cpumask_bits bits. If we just
> > dereference it, we'll read way more than what is allocated, e.g.
> > 1024 bytes vs. 8 bytes allocated on x86_64 machine with 24 CPUs.
> > 
> > Use cpumask_copy() instead. A comprehensive explanation is given
> > in the comments about cpumask_var_t, in include/linux/cpumask.h.
> > 
> > KASAN reports:
> > [   25.242312] BUG: KASAN: slab-out-of-bounds in
> > i40e_irq_affinity_notify+0x30/0x50 [i40e] at addr ffff880462eea960
> > [   25.242315] Read of size 1024 by task kworker/2:1/170
> > [   25.242322] CPU: 2 PID: 170 Comm: kworker/2:1 Not tainted 4.11.0-
> > 22.el7a.x86_64 #1
> > [   25.242325] Hardware name: HP ProLiant DL380 Gen9, BIOS P89
> > 05/06/2015
> > [   25.242336] Workqueue: events irq_affinity_notify
> > [   25.242340] Call Trace:
> > [   25.242350]  dump_stack+0x63/0x8d
> > [   25.242358]  kasan_object_err+0x21/0x70
> > [   25.242364]  kasan_report+0x288/0x540
> > [   25.242397]  ? i40e_irq_affinity_notify+0x30/0x50 [i40e]
> > [   25.242403]  check_memory_region+0x13c/0x1a0
> > [   25.242408]  __asan_loadN+0xf/0x20
> > [   25.242440]  i40e_irq_affinity_notify+0x30/0x50 [i40e]
> > [   25.242446]  irq_affinity_notify+0x1b4/0x230
> > [   25.242452]  ? irq_set_affinity_notifier+0x130/0x130
> > [   25.242457]  ? kasan_slab_free+0x89/0xc0
> > [   25.242466]  process_one_work+0x32f/0x6f0
> > [   25.242472]  worker_thread+0x89/0x770
> > [   25.242481]  ? pci_mmcfg_check_reserved+0xc0/0xc0
> > [   25.242488]  kthread+0x18c/0x1e0
> > [   25.242493]  ? process_one_work+0x6f0/0x6f0
> > [   25.242499]  ? kthread_create_on_node+0xc0/0xc0
> > [   25.242506]  ret_from_fork+0x2c/0x40
> > [   25.242511] Object at ffff880462eea960, in cache kmalloc-8 size: 8
> > [   25.242513] Allocated:
> > [   25.242514] PID = 170
> > [   25.242522]  save_stack_trace+0x1b/0x20
> > [   25.242529]  save_stack+0x46/0xd0
> > [   25.242533]  kasan_kmalloc+0xad/0xe0
> > [   25.242537]  __kmalloc_node+0x12c/0x2b0
> > [   25.242542]  alloc_cpumask_var_node+0x3c/0x60
> > [   25.242546]  alloc_cpumask_var+0xe/0x10
> > [   25.242550]  irq_affinity_notify+0x94/0x230
> > [   25.242555]  process_one_work+0x32f/0x6f0
> > [   25.242559]  worker_thread+0x89/0x770
> > [   25.242564]  kthread+0x18c/0x1e0
> > [   25.242568]  ret_from_fork+0x2c/0x40
> > [   25.242569] Freed:
> > [   25.242570] PID = 0
> > [   25.242572] (stack is not available)
> > [   25.242573] Memory state around the buggy address:
> > [   25.242578]  ffff880462eea800: fc fc 00 fc fc 00 fc fc 00 fc fc 00
> > fc fc fb fc
> > [   25.242582]  ffff880462eea880: fc fb fc fc fb fc fc 00 fc fc 00 fc
> > fc 00 fc fc
> > [   25.242586] >ffff880462eea900: 00 fc fc 00 fc fc 00 fc fc fb fc fc
> > 00 fc fc fc
> > [  
> > 25.242588]                                                          
> > ^
> > [   25.242592]  ffff880462eea980: fc fc fc fc fc fc fc fc fc fc fc fc
> > fc fc fc fc
> > [   25.242596]  ffff880462eeaa00: fc fc fc fc fc fc fc fc fc fc fc fc
> > fc fc fc fc
> > [   25.242597]
> > ==================================================================
> > 
> > Fixes: 96db776a3682 ("i40e/i40evf: fix interrupt affinity bug")
> > Signed-off-by: Stefano Brivio <sbrivio@redhat.com>
> > ---
> > This should be considered for -stable, back to 4.10.
> > 
> >  drivers/net/ethernet/intel/i40e/i40e_main.c     | 2 +-
> >  drivers/net/ethernet/intel/i40evf/i40evf_main.c | 2 +-
> >  2 files changed, 2 insertions(+), 2 deletions(-)  
> 
> This is already resolved with a previous patch from Jacob Keller, see
> the following commit in my tree:
> 
> commit f15ac286b0d111499e0fec4b50c8c870ad3b4573
> Author: Jacob Keller <jacob.e.keller@intel.com>
> Date:   Wed Aug 16 17:12:00 2017 -0700

This doesn't look like a previous patch. Please note that I posted this
on Tuesday (and Juergen on Saturday, with v2 on Wednesday at 19:52
+0200).

Before posting, however, I checked patchwork at:

	https://patchwork.ozlabs.org/project/intel-wired-lan/list/

and also your git tree (listed in MAINTAINERS) at:

	git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-queue.git

but I couldn't find that commit. I also can't find it now. So I suppose
I'm looking for it in the wrong place. Can you please tell me which
tree or patchwork I should check before submitting patches for i40e, so
that I avoid further duplicate submissions next time?

A couple of notes about the commit message (as I can't find the commit
you mentioned):

>     i40e: use cpumask_copy instead of direct assignment

This should be for both i40e and i40evf.

>     According to the header file cpumask.h, we shouldn't be directly
> copying
>     a cpumask_t, since its a bitmap and might not be copied correctly.
> Lets
>     use the provided cpumask_copy() function instead.
>
>     Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>

A Fixes: tag would be useful here, please see my patch.

I think it would also be helpful to mention that this causes a (big)
out-of-bound read (again, see my patch or v2 from Juergen), and make it
clear that this should be queued for -stable.

Thanks,
