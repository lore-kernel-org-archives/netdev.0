From: Sander Eikelenboom <linux@eikelenboom.it>
Subject: Re: 3.14-mw regression: rtl8169 WARNING: DMA-API: exceeded 7 overlapping mappings of pfn 55ebe
Date: Tue, 11 Feb 2014 20:56:17 +0100
Message-ID: <1434499348.20140211205617@eikelenboom.it>
References: <1859471893.20140126115521@eikelenboom.it> <20140127000305.GA14236@electric-eye.fr.zoreil.com> <CAA9_cme2hgJ=jCDkPh5n5RP8fiJE-dVwbFr-apKv1=mNGPHYZg@mail.gmail.com> <84816226.20140206123631@eikelenboom.it> <942972114.20140206140909@eikelenboom.it> <CAPcyv4g2EnCLFWfLfSDnjtwrid2tCq2k6wh-8sPYY06eJpM83A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Wei Liu <wei.liu2@citrix.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Dan Williams <dan.j.williams@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAPcyv4g2EnCLFWfLfSDnjtwrid2tCq2k6wh-8sPYY06eJpM83A@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dan,

FYI just tested and put Xen out of the equation (booting baremetal) and it still persists.

I tried something else .. don't know if it gives you anymore insights, but it's worth the try:

diff --git a/lib/dma-debug.c b/lib/dma-debug.c
index 2defd13..0fe5b75 100644
--- a/lib/dma-debug.c
+++ b/lib/dma-debug.c
@@ -474,11 +474,11 @@ static int active_pfn_set_overlap(unsigned long pfn, int overlap)
        return overlap;
 }

-static void active_pfn_inc_overlap(unsigned long pfn)
+static void active_pfn_inc_overlap(struct dma_debug_entry *ent)
 {
-       int overlap = active_pfn_read_overlap(pfn);
+       int overlap = active_pfn_read_overlap(ent->pfn);

-       overlap = active_pfn_set_overlap(pfn, ++overlap);
+       overlap = active_pfn_set_overlap(ent->pfn, ++overlap);

        /* If we overflowed the overlap counter then we're potentially
         * leaking dma-mappings.  Otherwise, if maps and unmaps are
@@ -486,15 +486,43 @@ static void active_pfn_inc_overlap(unsigned long pfn)
         * debug_dma_assert_idle() as the pfn may be marked idle
         * prematurely.
         */
+
        WARN_ONCE(overlap > ACTIVE_PFN_MAX_OVERLAP,
                  "DMA-API: exceeded %d overlapping mappings of pfn %lx\n",
-                 ACTIVE_PFN_MAX_OVERLAP, pfn);
+                 ACTIVE_PFN_MAX_OVERLAP, ent->pfn);
+
+       if(overlap > ACTIVE_PFN_MAX_OVERLAP){
+
+               dev_info(ent->dev, "DMA-API: exceeded %d overlapping mappings of pfn %lx .. start dump\n", ACTIVE_PFN_MAX_OVERLAP, ent->pfn);
+               int idx;
+
+               for (idx = 0; idx < HASH_SIZE; idx++) {
+                    struct hash_bucket *bucket = &dma_entry_hash[idx];
+                    struct dma_debug_entry *entry;
+                   unsigned long flags;
+
+                    list_for_each_entry(entry, &bucket->list, list) {
+                                       if (entry->pfn == ent->pfn) {
+                                           dev_info(entry->dev, "%s idx %d P=%Lx N=%lx D=%Lx L=%Lx %s %s\n",
+                                                type2name[entry->type], idx,
+                                                phys_addr(entry), entry->pfn,
+                                                entry->dev_addr, entry->size,
+                                                dir2name[entry->direction],
+                                               maperr2str[entry->map_err_type]);
+                                       }
+                    }
+               }
+               dev_info(ent->dev, "DMA-API: exceeded %d overlapping mappings of pfn %lx .. end of dump\n", ACTIVE_PFN_MAX_OVERLAP, ent->pfn);
+       }
 }


@@ -505,10 +533,10 @@ static int active_pfn_insert(struct dma_debug_entry *entry)

        spin_lock_irqsave(&radix_lock, flags);
        rc = radix_tree_insert(&dma_active_pfn, entry->pfn, entry);
-       if (rc == -EEXIST)
-               active_pfn_inc_overlap(entry->pfn);
+       if (rc == -EEXIST){
+               active_pfn_inc_overlap(entry);
+       }
        spin_unlock_irqrestore(&radix_lock, flags);
-
        return rc;
 }


This results in:
[   27.708678] r8169 0000:0a:00.0 eth1: link down
[   27.712102] r8169 0000:0a:00.0 eth1: link down
[   28.015340] r8169 0000:0b:00.0 eth0: link down
[   28.015368] r8169 0000:0b:00.0 eth0: link down
[   29.654844] r8169 0000:0b:00.0 eth0: link up
[   30.278542] r8169 0000:0a:00.0 eth1: link up
[   60.829503] EXT4-fs (dm-2): mounted filesystem with ordered data mode. Opts: barrier=1,errors=remount-ro
[   69.708979] EXT4-fs (dm-42): mounted filesystem with ordered data mode. Opts: barrier=1,errors=remount-ro
[   76.128678] EXT4-fs (dm-43): mounted filesystem with ordered data mode. Opts: barrier=1,errors=remount-ro
[   82.922836] EXT4-fs (dm-44): mounted filesystem with ordered data mode. Opts: barrier=1,errors=remount-ro
[   89.232889] EXT4-fs (dm-45): mounted filesystem with ordered data mode. Opts: barrier=1,errors=remount-ro
[   95.359859] EXT4-fs (dm-46): mounted filesystem with ordered data mode. Opts: barrier=1,errors=remount-ro
[  101.638559] EXT4-fs (sdb1): mounted filesystem with ordered data mode. Opts: barrier=1,errors=remount-ro
[  218.073407] ------------[ cut here ]------------
[  218.080983] WARNING: CPU: 5 PID: 0 at lib/dma-debug.c:492 add_dma_entry+0xf1/0x210()
[  218.088550] DMA-API: exceeded 7 overlapping mappings of pfn 3c421
[  218.095988] Modules linked in:
[  218.103270] CPU: 5 PID: 0 Comm: swapper/5 Tainted: G        W    3.14.0-rc2-20140211-pcireset-net-btrevert-xenblock-dmadebug5+ #1
[  218.110712] Hardware name: MSI MS-7640/890FXA-GD70 (MS-7640)  , BIOS V1.8B1 09/13/2010
[  218.118134]  0000000000000009 ffff88003fd437b8 ffffffff81b809c4 ffff88003e308000
[  218.125556]  ffff88003fd43808 ffff88003fd437f8 ffffffff810c985c 0000000000000000
[  218.132917]  00000000ffffffef 0000000000000036 ffff88003d9d3c00 0000000000000282
[  218.140154] Call Trace:
[  218.147193]  <IRQ>  [<ffffffff81b809c4>] dump_stack+0x46/0x58
[  218.154271]  [<ffffffff810c985c>] warn_slowpath_common+0x8c/0xc0
[  218.161293]  [<ffffffff810c9946>] warn_slowpath_fmt+0x46/0x50
[  218.168227]  [<ffffffff814f2cfa>] ? active_pfn_read_overlap+0x3a/0x70
[  218.175116]  [<ffffffff814f41d1>] add_dma_entry+0xf1/0x210
[  218.181865]  [<ffffffff814f4646>] debug_dma_map_page+0x126/0x150
[  218.188484]  [<ffffffff817aabeb>] rtl8169_start_xmit+0x21b/0xa20
[  218.195042]  [<ffffffff81a01877>] ? dev_queue_xmit_nit+0x1d7/0x260
[  218.201553]  [<ffffffff81a0188f>] ? dev_queue_xmit_nit+0x1ef/0x260
[  218.207965]  [<ffffffff81a016a5>] ? dev_queue_xmit_nit+0x5/0x260
[  218.214290]  [<ffffffff81a0661f>] dev_hard_start_xmit+0x37f/0x590
[  218.220481]  [<ffffffff81a26cae>] sch_direct_xmit+0xfe/0x280
[  218.226529]  [<ffffffff81a06a7f>] __dev_queue_xmit+0x24f/0x660
[  218.232521]  [<ffffffff81a06835>] ? __dev_queue_xmit+0x5/0x660
[  218.238439]  [<ffffffff81ab21b9>] ? ip_output+0x59/0xf0
[  218.244272]  [<ffffffff81a06eb0>] dev_queue_xmit+0x10/0x20
[  218.250043]  [<ffffffff81ab076b>] ip_finish_output+0x2cb/0x670
[  218.255682]  [<ffffffff81ab21b9>] ? ip_output+0x59/0xf0
[  218.261168]  [<ffffffff81ab21b9>] ip_output+0x59/0xf0
[  218.266559]  [<ffffffff81aad596>] ip_forward_finish+0x76/0x1a0
[  218.271883]  [<ffffffff81aad86b>] ip_forward+0x1ab/0x440
[  218.277148]  [<ffffffff81aab380>] ip_rcv_finish+0x150/0x660
[  218.282373]  [<ffffffff81aabe3b>] ip_rcv+0x22b/0x370
[  218.287436]  [<ffffffff81b09bc7>] ? packet_rcv_spkt+0x47/0x190
[  218.292372]  [<ffffffff81a03272>] __netif_receive_skb_core+0x722/0x8f0
[  218.297328]  [<ffffffff81a02c75>] ? __netif_receive_skb_core+0x125/0x8f0
[  218.302304]  [<ffffffff8112ce6e>] ? getnstimeofday+0xe/0x30
[  218.307296]  [<ffffffff819f42c5>] ? __netdev_alloc_frag+0x175/0x1b0
[  218.312166]  [<ffffffff81a03461>] __netif_receive_skb+0x21/0x70
[  218.316904]  [<ffffffff81a034d3>] netif_receive_skb_internal+0x23/0xf0
[  218.321596]  [<ffffffff81a04d2d>] napi_gro_receive+0x8d/0x100
[  218.326219]  [<ffffffff817a7bc3>] rtl8169_poll+0x2d3/0x680
[  218.330754]  [<ffffffff8112e366>] ? update_wall_time+0x356/0x690
[  218.335208]  [<ffffffff81a03a0a>] net_rx_action+0x18a/0x2c0
[  218.339595]  [<ffffffff810ce6f1>] ? __do_softirq+0xc1/0x300
[  218.343890]  [<ffffffff810ce767>] __do_softirq+0x137/0x300
[  218.348085]  [<ffffffff810cec9a>] irq_exit+0xaa/0xd0
[  218.352203]  [<ffffffff81b8e5a7>] do_IRQ+0x67/0x110
[  218.356225]  [<ffffffff81b8b772>] common_interrupt+0x72/0x72
[  218.360156]  <EOI>  [<ffffffff810536e6>] ? native_safe_halt+0x6/0x10
[  218.364087]  [<ffffffff81113a7d>] ? trace_hardirqs_on+0xd/0x10
[  218.367935]  [<ffffffff81020632>] default_idle+0x32/0xd0
[  218.371691]  [<ffffffff8102071e>] amd_e400_idle+0x4e/0x140
[  218.375360]  [<ffffffff81020f86>] arch_cpu_idle+0x36/0x40
[  218.378921]  [<ffffffff81120a01>] cpu_startup_entry+0xa1/0x2a0
[  218.382508]  [<ffffffff810473cf>] start_secondary+0x1af/0x210
[  218.386133] ---[ end trace 0e12f271209e2c18 ]---
[  218.389769] r8169 0000:0b:00.0: DMA-API: exceeded 7 overlapping mappings of pfn 3c421 .. start dump
[  218.393566] r8169 0000:0b:00.0: single idx 563 P=3c421100 N=3c421 D=c66100 L=36 DMA_TO_DEVICE dma map error checked
[  218.397379] r8169 0000:0b:00.0: single idx 563 P=3c4212c0 N=3c421 D=c672c0 L=36 DMA_TO_DEVICE dma map error checked
[  218.401094] r8169 0000:0b:00.0: single idx 564 P=3c421480 N=3c421 D=c68480 L=36 DMA_TO_DEVICE dma map error checked
[  218.404730] r8169 0000:0b:00.0: single idx 564 P=3c421640 N=3c421 D=c69640 L=36 DMA_TO_DEVICE dma map error checked
[  218.408310] r8169 0000:0b:00.0: single idx 565 P=3c421800 N=3c421 D=c6a800 L=36 DMA_TO_DEVICE dma map error checked
[  218.411762] r8169 0000:0b:00.0: single idx 565 P=3c4219c0 N=3c421 D=c6b9c0 L=36 DMA_TO_DEVICE dma map error checked
[  218.415075] r8169 0000:0b:00.0: single idx 566 P=3c421b80 N=3c421 D=c6cb80 L=9b DMA_TO_DEVICE dma map error checked
[  218.418305] r8169 0000:0b:00.0: single idx 566 P=3c421dc0 N=3c421 D=c6ddc0 L=36 DMA_TO_DEVICE dma map error checked
[  218.421502] r8169 0000:0b:00.0: single idx 567 P=3c421f80 N=3c421 D=c6ef80 L=36 DMA_TO_DEVICE dma map error not checked
[  218.424677] r8169 0000:0b:00.0: DMA-API: exceeded 7 overlapping mappings of pfn 3c421 .. end of dump
[  218.429050] r8169 0000:0b:00.0: DMA-API: exceeded 7 overlapping mappings of pfn 3c423 .. start dump
[  218.432225] r8169 0000:0b:00.0: single idx 571 P=3c423040 N=3c423 D=c76040 L=36 DMA_TO_DEVICE dma map error checked
[  218.435408] r8169 0000:0b:00.0: single idx 571 P=3c423200 N=3c423 D=c77200 L=36 DMA_TO_DEVICE dma map error checked
[  218.438578] r8169 0000:0b:00.0: single idx 572 P=3c4233c0 N=3c423 D=c783c0 L=36 DMA_TO_DEVICE dma map error checked
[  218.441695] r8169 0000:0b:00.0: single idx 572 P=3c423580 N=3c423 D=c79580 L=7b DMA_TO_DEVICE dma map error checked
[  218.444783] r8169 0000:0b:00.0: single idx 573 P=3c423780 N=3c423 D=c7a780 L=9b DMA_TO_DEVICE dma map error checked
[  218.447825] r8169 0000:0b:00.0: single idx 573 P=3c4239c0 N=3c423 D=c7b9c0 L=6b DMA_TO_DEVICE dma map error checked
[  218.450844] r8169 0000:0b:00.0: single idx 574 P=3c423bc0 N=3c423 D=c7cbc0 L=7b DMA_TO_DEVICE dma map error checked
[  218.453814] r8169 0000:0b:00.0: single idx 574 P=3c423dc0 N=3c423 D=c7ddc0 L=7b DMA_TO_DEVICE dma map error checked
[  218.456793] r8169 0000:0b:00.0: single idx 575 P=3c423fc0 N=3c423 D=c7efc0 L=7b DMA_TO_DEVICE dma map error not checked
[  218.459772] r8169 0000:0b:00.0: DMA-API: exceeded 7 overlapping mappings of pfn 3c423 .. end of dump
[  218.473504] r8169 0000:0b:00.0: DMA-API: exceeded 7 overlapping mappings of pfn 3c716 .. start dump
[  218.475662] r8169 0000:0b:00.0: single idx 586 P=3c7160c0 N=3c716 D=c940c0 L=36 DMA_TO_DEVICE dma map error checked
[  218.477874] r8169 0000:0b:00.0: single idx 586 P=3c716280 N=3c716 D=c95280 L=36 DMA_TO_DEVICE dma map error checked
[  218.480075] r8169 0000:0b:00.0: single idx 587 P=3c716440 N=3c716 D=c96440 L=36 DMA_TO_DEVICE dma map error checked
[  218.482245] r8169 0000:0b:00.0: single idx 587 P=3c716600 N=3c716 D=c97600 L=36 DMA_TO_DEVICE dma map error checked
[  218.484390] r8169 0000:0b:00.0: single idx 588 P=3c7167c0 N=3c716 D=c987c0 L=42 DMA_TO_DEVICE dma map error checked
[  218.486510] r8169 0000:0b:00.0: single idx 588 P=3c7169c0 N=3c716 D=c999c0 L=36 DMA_TO_DEVICE dma map error checked
[  218.488603] r8169 0000:0b:00.0: single idx 589 P=3c716b80 N=3c716 D=c9ab80 L=42 DMA_TO_DEVICE dma map error checked
[  218.490682] r8169 0000:0b:00.0: single idx 589 P=3c716d80 N=3c716 D=c9bd80 L=42 DMA_TO_DEVICE dma map error checked
[  218.492735] r8169 0000:0b:00.0: single idx 590 P=3c716f80 N=3c716 D=c9cf80 L=42 DMA_TO_DEVICE dma map error not checked
[  218.494788] r8169 0000:0b:00.0: DMA-API: exceeded 7 overlapping mappings of pfn 3c716 .. end of dump

--
Sander





Thursday, February 6, 2014, 3:26:09 PM, you wrote:

> On Thu, Feb 6, 2014 at 5:09 AM, Sander Eikelenboom <linux@eikelenboom.it> wrote:
>> Hmm ok that last message was false .. sorry for that .. it did happen again without r8169.use_dac=1, it just doesn't seem to happen all the time...
>>
>> Konrad / Wei, do you happen to know of any xen related change that went into 3.14 merge window that relates to dma / xen networking ?
>>
>> --
>> Sander
>>
>> complete stacktrace:
>>
>> [  342.710738] ------------[ cut here ]------------
>> [  342.726890] WARNING: CPU: 0 PID: 0 at lib/dma-debug.c:491 add_dma_entry+0x105/0x130()
>> [  342.743210] DMA-API: exceeded 7 overlapping mappings of pfn 40b00
>> [  342.759510] Modules linked in:
>> [  342.775557] CPU: 0 PID: 0 Comm: swapper/0 Not tainted 3.14.0-rc1-20140206-pcireset-net-btrevert+ #1
>> [  342.791706] Hardware name: MSI MS-7640/890FXA-GD70 (MS-7640)  , BIOS V1.8B1 09/13/2010
>> [  342.807627]  0000000000000009 ffff88005f603828 ffffffff81ad29fc ffffffff822134e0
>> [  342.823430]  ffff88005f603878 ffff88005f603868 ffffffff810bdf62 ffff880000000000
>> [  342.839081]  0000000000040b00 00000000ffffffef ffffffff822102e0 ffff8800592b9098
>> [  342.854572] Call Trace:
>> [  342.869748]  <IRQ>  [<ffffffff81ad29fc>] dump_stack+0x46/0x58
>> [  342.884915]  [<ffffffff810bdf62>] warn_slowpath_common+0x82/0xb0
>> [  342.899710]  [<ffffffff810be031>] warn_slowpath_fmt+0x41/0x50
>> [  342.914395]  [<ffffffff8147853a>] ? active_pfn_read_overlap+0x3a/0x70
>> [  342.929166]  [<ffffffff814792c5>] add_dma_entry+0x105/0x130
>> [  342.943733]  [<ffffffff814796c6>] debug_dma_map_page+0x126/0x150
>> [  342.957988]  [<ffffffff8171c8b6>] rtl8169_start_xmit+0x216/0xa20
>> [  342.972306]  [<ffffffff8195f08f>] ? dev_queue_xmit_nit+0x1ef/0x260
>> [  342.986523]  [<ffffffff8195eea0>] ? dev_loopback_xmit+0x1e0/0x1e0
>> [  343.000689]  [<ffffffff819631e6>] dev_hard_start_xmit+0x2e6/0x4a0
>> [  343.014466]  [<ffffffff81980f3e>] sch_direct_xmit+0xfe/0x280
>> [  343.028052]  [<ffffffff819635dc>] __dev_queue_xmit+0x23c/0x630
>> [  343.041338]  [<ffffffff819633a0>] ? dev_hard_start_xmit+0x4a0/0x4a0
>> [  343.054483]  [<ffffffff81a0a334>] ? ip_output+0x54/0xf0
>> [  343.067659]  [<ffffffff819639eb>] dev_queue_xmit+0xb/0x10
>> [  343.080804]  [<ffffffff81a0890b>] ip_finish_output+0x2cb/0x670
>> [  343.093746]  [<ffffffff81a0a334>] ? ip_output+0x54/0xf0
>> [  343.106391]  [<ffffffff81a0a334>] ip_output+0x54/0xf0
>> [  343.118683]  [<ffffffff81a05791>] ip_forward_finish+0x71/0x1a0
>> [  343.130901]  [<ffffffff81a05a63>] ip_forward+0x1a3/0x440
>> [  343.142829]  [<ffffffff810ffebb>] ? lock_is_held+0x8b/0xb0
>> [  343.154346]  [<ffffffff81a035c0>] ip_rcv_finish+0x150/0x660
>> [  343.165748]  [<ffffffff81a0406b>] ip_rcv+0x22b/0x370
>> [  343.176838]  [<ffffffff81a60972>] ? packet_rcv_spkt+0x42/0x190
>> [  343.187659]  [<ffffffff819609d2>] __netif_receive_skb_core+0x6d2/0x8a0
>> [  343.198209]  [<ffffffff81960414>] ? __netif_receive_skb_core+0x114/0x8a0
>> [  343.208819]  [<ffffffff81009010>] ? xen_clocksource_read+0x20/0x30
>> [  343.219471]  [<ffffffff81116e49>] ? getnstimeofday+0x9/0x30
>> [  343.229862]  [<ffffffff81960bbc>] __netif_receive_skb+0x1c/0x70
>> [  343.239953]  [<ffffffff81960c2e>] netif_receive_skb_internal+0x1e/0xf0
>> [  343.249908]  [<ffffffff81962110>] napi_gro_receive+0x70/0xa0
>> [  343.259509]  [<ffffffff817198a3>] rtl8169_poll+0x2d3/0x680
>> [  343.268982]  [<ffffffff81adcd2b>] ? _raw_spin_unlock_irq+0x2b/0x50
>> [  343.278091]  [<ffffffff819610d1>] net_rx_action+0x161/0x260
>> [  343.287056]  [<ffffffff810c28ec>] __do_softirq+0x12c/0x280
>> [  343.295756]  [<ffffffff810c2da2>] irq_exit+0xa2/0xd0
>> [  343.304235]  [<ffffffff814ffd5f>] xen_evtchn_do_upcall+0x2f/0x40
>> [  343.312387]  [<ffffffff81adf15e>] xen_do_hypervisor_callback+0x1e/0x30
>> [  343.320389]  <EOI>  [<ffffffff810013aa>] ? xen_hypercall_sched_op+0xa/0x20
>> [  343.328171]  [<ffffffff810013aa>] ? xen_hypercall_sched_op+0xa/0x20
>> [  343.335738]  [<ffffffff81008c70>] ? xen_safe_halt+0x10/0x20
>> [  343.343142]  [<ffffffff81018748>] ? default_idle+0x18/0x20
>> [  343.350202]  [<ffffffff81018f5e>] ? arch_cpu_idle+0x2e/0x40
>> [  343.356994]  [<ffffffff8110b551>] ? cpu_startup_entry+0x91/0x1e0
>> [  343.363658]  [<ffffffff81ac7d87>] ? rest_init+0xb7/0xc0
>> [  343.369924]  [<ffffffff81ac7cd0>] ? csum_partial_copy_generic+0x170/0x170
>> [  343.376057]  [<ffffffff8230ff1c>] ? start_kernel+0x409/0x416
>> [  343.381972]  [<ffffffff8230f912>] ? repair_env_string+0x5e/0x5e
>> [  343.387573]  [<ffffffff8230f5f8>] ? x86_64_start_reservations+0x2a/0x2c
>> [  343.393152]  [<ffffffff82312e28>] ? xen_start_kernel+0x586/0x588
>> [  343.398628] ---[ end trace 8379b598fb7ef5ee ]---
>>
>>
>>
>>
>>
>> Thursday, February 6, 2014, 12:36:31 PM, you wrote:
>>
>>> Hi Dan / Francois,
>>
>>> Didn't have time to test it before, but the patch doesn't seem to help.
>>> I'm still getting the "DMA-API: exceeded 7 overlapping mappings of pfn 55ebe",
>>> but i see now i forgot to mention i use r8169.use_dac=1 ...
>>
>>> Not using it seems to prevent the warning, but before 3.14 i have never seen this (with r8169.use_dac=1)

> If you are still hitting this with the patch:

>   59f2e7df574c dma-debug: fix overlap detection

> ...then I'm more inclined to think it is an actual positive report.

> If you don't mind I'll send some debug patches to narrow this down.
