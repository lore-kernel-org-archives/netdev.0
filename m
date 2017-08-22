From: "Keller, Jacob E" <jacob.e.keller@intel.com>
Subject: RE: [PATCH v2] i40e/i40evf: fix out-of-bounds read of cpumask
Date: Tue, 22 Aug 2017 21:15:43 +0000
Message-ID: <02874ECE860811409154E81DA85FBB5882A63065@ORSMSX115.amr.corp.intel.com>
References: <20170822210442.18006-1-jacob.e.keller@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "stable@vger.kernel.org#4.10+" <stable@vger.kernel.org#4.10+>
To: "Keller, Jacob E" <jacob.e.keller@intel.com>,
        Intel Wired LAN <intel-wired-lan@lists.osuosl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.43]:10118 "EHLO mga05.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751615AbdHVVPp (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 22 Aug 2017 17:15:45 -0400
In-Reply-To: <20170822210442.18006-1-jacob.e.keller@intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org] On
> Behalf Of Jacob Keller
> Sent: Tuesday, August 22, 2017 2:05 PM
> To: Intel Wired LAN <intel-wired-lan@lists.osuosl.org>
> Cc: netdev@vger.kernel.org; Keller, Jacob E <jacob.e.keller@intel.com>;
> stable@vger.kernel.org#4.10+
> Subject: [PATCH v2] i40e/i40evf: fix out-of-bounds read of cpumask
> 
> When responding to an affinity hint we directly copied a cpumask value,
> intsead of using cpumask_copy. According to cpumask.h this is not
> correct because cpumask_t is only guaranteed to have enough space for
> the number of CPUs in the system, and may not be as big as we expect.
> Thus a direct copy results in an out-of-bound read and potentially
> a crash if the pages are aligned just right. This will be easily
> detected on a kernel with KASAN enabled:
> 
> KASAN reports:
> [   25.242312] BUG: KASAN: slab-out-of-bounds in
> i40e_irq_affinity_notify+0x30/0x50 [i40e] at addr ffff880462eea960
> [   25.242315] Read of size 1024 by task kworker/2:1/170
> [   25.242322] CPU: 2 PID: 170 Comm: kworker/2:1 Not tainted 4.11.0-
> 22.el7a.x86_64 #1
> [   25.242325] Hardware name: HP ProLiant DL380 Gen9, BIOS P89 05/06/2015
> [   25.242336] Workqueue: events irq_affinity_notify
> [   25.242340] Call Trace:
> [   25.242350]  dump_stack+0x63/0x8d
> [   25.242358]  kasan_object_err+0x21/0x70
> [   25.242364]  kasan_report+0x288/0x540
> [   25.242397]  ? i40e_irq_affinity_notify+0x30/0x50 [i40e]
> [   25.242403]  check_memory_region+0x13c/0x1a0
> [   25.242408]  __asan_loadN+0xf/0x20
> [   25.242440]  i40e_irq_affinity_notify+0x30/0x50 [i40e]
> [   25.242446]  irq_affinity_notify+0x1b4/0x230
> [   25.242452]  ? irq_set_affinity_notifier+0x130/0x130
> [   25.242457]  ? kasan_slab_free+0x89/0xc0
> [   25.242466]  process_one_work+0x32f/0x6f0
> [   25.242472]  worker_thread+0x89/0x770
> [   25.242481]  ? pci_mmcfg_check_reserved+0xc0/0xc0
> [   25.242488]  kthread+0x18c/0x1e0
> [   25.242493]  ? process_one_work+0x6f0/0x6f0
> [   25.242499]  ? kthread_create_on_node+0xc0/0xc0
> [   25.242506]  ret_from_fork+0x2c/0x40
> [   25.242511] Object at ffff880462eea960, in cache kmalloc-8 size: 8
> [   25.242513] Allocated:
> [   25.242514] PID = 170
> [   25.242522]  save_stack_trace+0x1b/0x20
> [   25.242529]  save_stack+0x46/0xd0
> [   25.242533]  kasan_kmalloc+0xad/0xe0
> [   25.242537]  __kmalloc_node+0x12c/0x2b0
> [   25.242542]  alloc_cpumask_var_node+0x3c/0x60
> [   25.242546]  alloc_cpumask_var+0xe/0x10
> [   25.242550]  irq_affinity_notify+0x94/0x230
> [   25.242555]  process_one_work+0x32f/0x6f0
> [   25.242559]  worker_thread+0x89/0x770
> [   25.242564]  kthread+0x18c/0x1e0
> [   25.242568]  ret_from_fork+0x2c/0x40
> [   25.242569] Freed:
> [   25.242570] PID = 0
> [   25.242572] (stack is not available)
> [   25.242573] Memory state around the buggy address:
> [   25.242578]  ffff880462eea800: fc fc 00 fc fc 00 fc fc 00 fc fc 00 fc fc fb fc
> [   25.242582]  ffff880462eea880: fc fb fc fc fb fc fc 00 fc fc 00 fc fc 00 fc fc
> [   25.242586] >ffff880462eea900: 00 fc fc 00 fc fc 00 fc fc fb fc fc 00 fc fc fc
> [   25.242588]                                                           ^
> [   25.242592]  ffff880462eea980: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
> [   25.242596]  ffff880462eeaa00: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
> [   25.242597]
> ==================================================================
> 
> Fixes: 96db776a3682 ("i40e/i40evf: fix interrupt affinity bug", 2016-09-14)
> Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
> Cc: stable@vger.kernel.org # 4.10+
> ---
> This updates the commit message for the original fix, and indicates that
> it fixes a potential crash, as well as tagged the commit for stable and
> added a Fixes to indicate which commit this fixes.
> 

I should have noted, I changed the title to be more accurate as well, this is a v2 of https://patchwork.ozlabs.org/patch/787388/
