From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 3.14-mw regression: rtl8169 WARNING: DMA-API: exceeded 7
 overlapping mappings of pfn 55ebe
Date: Tue, 11 Feb 2014 13:28:52 -0800
Message-ID: <1392154132.6615.91.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1859471893.20140126115521@eikelenboom.it>
	 <20140127000305.GA14236@electric-eye.fr.zoreil.com>
	 <CAA9_cme2hgJ=jCDkPh5n5RP8fiJE-dVwbFr-apKv1=mNGPHYZg@mail.gmail.com>
	 <84816226.20140206123631@eikelenboom.it>
	 <942972114.20140206140909@eikelenboom.it>
	 <CAPcyv4g2EnCLFWfLfSDnjtwrid2tCq2k6wh-8sPYY06eJpM83A@mail.gmail.com>
	 <1434499348.20140211205617@eikelenboom.it>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Dan Williams <dan.j.williams@intel.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Wei Liu <wei.liu2@citrix.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Sander Eikelenboom <linux@eikelenboom.it>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1434499348.20140211205617@eikelenboom.it>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2014-02-11 at 20:56 +0100, Sander Eikelenboom wrote:
> Hi Dan,
> 
> FYI just tested and put Xen out of the equation (booting baremetal) and it still persists.
> 
> I tried something else .. don't know if it gives you anymore insights, but it's worth the try:
> 
> diff --git a/lib/dma-debug.c b/lib/dma-debug.c
> index 2defd13..0fe5b75 100644
> --- a/lib/dma-debug.c
> +++ b/lib/dma-debug.c
> @@ -474,11 +474,11 @@ static int active_pfn_set_overlap(unsigned long pfn, int overlap)
>         return overlap;
>  }
> 
> -static void active_pfn_inc_overlap(unsigned long pfn)
> +static void active_pfn_inc_overlap(struct dma_debug_entry *ent)
>  {
> -       int overlap = active_pfn_read_overlap(pfn);
> +       int overlap = active_pfn_read_overlap(ent->pfn);
> 
> -       overlap = active_pfn_set_overlap(pfn, ++overlap);
> +       overlap = active_pfn_set_overlap(ent->pfn, ++overlap);
> 
>         /* If we overflowed the overlap counter then we're potentially
>          * leaking dma-mappings.  Otherwise, if maps and unmaps are
> @@ -486,15 +486,43 @@ static void active_pfn_inc_overlap(unsigned long pfn)
>          * debug_dma_assert_idle() as the pfn may be marked idle
>          * prematurely.
>          */
> +
>         WARN_ONCE(overlap > ACTIVE_PFN_MAX_OVERLAP,
>                   "DMA-API: exceeded %d overlapping mappings of pfn %lx\n",
> -                 ACTIVE_PFN_MAX_OVERLAP, pfn);
> +                 ACTIVE_PFN_MAX_OVERLAP, ent->pfn);
> +
> +       if(overlap > ACTIVE_PFN_MAX_OVERLAP){
> +
> +               dev_info(ent->dev, "DMA-API: exceeded %d overlapping mappings of pfn %lx .. start dump\n", ACTIVE_PFN_MAX_OVERLAP, ent->pfn);
> +               int idx;
> +
> +               for (idx = 0; idx < HASH_SIZE; idx++) {
> +                    struct hash_bucket *bucket = &dma_entry_hash[idx];
> +                    struct dma_debug_entry *entry;
> +                   unsigned long flags;
> +
> +                    list_for_each_entry(entry, &bucket->list, list) {
> +                                       if (entry->pfn == ent->pfn) {
> +                                           dev_info(entry->dev, "%s idx %d P=%Lx N=%lx D=%Lx L=%Lx %s %s\n",
> +                                                type2name[entry->type], idx,
> +                                                phys_addr(entry), entry->pfn,
> +                                                entry->dev_addr, entry->size,
> +                                                dir2name[entry->direction],
> +                                               maperr2str[entry->map_err_type]);
> +                                       }
> +                    }
> +               }
> +               dev_info(ent->dev, "DMA-API: exceeded %d overlapping mappings of pfn %lx .. end of dump\n", ACTIVE_PFN_MAX_OVERLAP, ent->pfn);
> +       }
>  }
> 
> 
> @@ -505,10 +533,10 @@ static int active_pfn_insert(struct dma_debug_entry *entry)
> 
>         spin_lock_irqsave(&radix_lock, flags);
>         rc = radix_tree_insert(&dma_active_pfn, entry->pfn, entry);
> -       if (rc == -EEXIST)
> -               active_pfn_inc_overlap(entry->pfn);
> +       if (rc == -EEXIST){
> +               active_pfn_inc_overlap(entry);
> +       }
>         spin_unlock_irqrestore(&radix_lock, flags);
> -
>         return rc;
>  }
> 
> 
> This results in:
> [   27.708678] r8169 0000:0a:00.0 eth1: link down
> [   27.712102] r8169 0000:0a:00.0 eth1: link down
> [   28.015340] r8169 0000:0b:00.0 eth0: link down
> [   28.015368] r8169 0000:0b:00.0 eth0: link down
> [   29.654844] r8169 0000:0b:00.0 eth0: link up
> [   30.278542] r8169 0000:0a:00.0 eth1: link up
> [   60.829503] EXT4-fs (dm-2): mounted filesystem with ordered data mode. Opts: barrier=1,errors=remount-ro
> [   69.708979] EXT4-fs (dm-42): mounted filesystem with ordered data mode. Opts: barrier=1,errors=remount-ro
> [   76.128678] EXT4-fs (dm-43): mounted filesystem with ordered data mode. Opts: barrier=1,errors=remount-ro
> [   82.922836] EXT4-fs (dm-44): mounted filesystem with ordered data mode. Opts: barrier=1,errors=remount-ro
> [   89.232889] EXT4-fs (dm-45): mounted filesystem with ordered data mode. Opts: barrier=1,errors=remount-ro
> [   95.359859] EXT4-fs (dm-46): mounted filesystem with ordered data mode. Opts: barrier=1,errors=remount-ro
> [  101.638559] EXT4-fs (sdb1): mounted filesystem with ordered data mode. Opts: barrier=1,errors=remount-ro
> [  218.073407] ------------[ cut here ]------------
> [  218.080983] WARNING: CPU: 5 PID: 0 at lib/dma-debug.c:492 add_dma_entry+0xf1/0x210()
> [  218.088550] DMA-API: exceeded 7 overlapping mappings of pfn 3c421
> [  218.095988] Modules linked in:
> [  218.103270] CPU: 5 PID: 0 Comm: swapper/5 Tainted: G        W    3.14.0-rc2-20140211-pcireset-net-btrevert-xenblock-dmadebug5+ #1
> [  218.110712] Hardware name: MSI MS-7640/890FXA-GD70 (MS-7640)  , BIOS V1.8B1 09/13/2010
> [  218.118134]  0000000000000009 ffff88003fd437b8 ffffffff81b809c4 ffff88003e308000
> [  218.125556]  ffff88003fd43808 ffff88003fd437f8 ffffffff810c985c 0000000000000000
> [  218.132917]  00000000ffffffef 0000000000000036 ffff88003d9d3c00 0000000000000282
> [  218.140154] Call Trace:
> [  218.147193]  <IRQ>  [<ffffffff81b809c4>] dump_stack+0x46/0x58
> [  218.154271]  [<ffffffff810c985c>] warn_slowpath_common+0x8c/0xc0
> [  218.161293]  [<ffffffff810c9946>] warn_slowpath_fmt+0x46/0x50
> [  218.168227]  [<ffffffff814f2cfa>] ? active_pfn_read_overlap+0x3a/0x70
> [  218.175116]  [<ffffffff814f41d1>] add_dma_entry+0xf1/0x210
> [  218.181865]  [<ffffffff814f4646>] debug_dma_map_page+0x126/0x150
> [  218.188484]  [<ffffffff817aabeb>] rtl8169_start_xmit+0x21b/0xa20
> [  218.195042]  [<ffffffff81a01877>] ? dev_queue_xmit_nit+0x1d7/0x260
> [  218.201553]  [<ffffffff81a0188f>] ? dev_queue_xmit_nit+0x1ef/0x260
> [  218.207965]  [<ffffffff81a016a5>] ? dev_queue_xmit_nit+0x5/0x260
> [  218.214290]  [<ffffffff81a0661f>] dev_hard_start_xmit+0x37f/0x590
> [  218.220481]  [<ffffffff81a26cae>] sch_direct_xmit+0xfe/0x280
> [  218.226529]  [<ffffffff81a06a7f>] __dev_queue_xmit+0x24f/0x660
> [  218.232521]  [<ffffffff81a06835>] ? __dev_queue_xmit+0x5/0x660
> [  218.238439]  [<ffffffff81ab21b9>] ? ip_output+0x59/0xf0
> [  218.244272]  [<ffffffff81a06eb0>] dev_queue_xmit+0x10/0x20
> [  218.250043]  [<ffffffff81ab076b>] ip_finish_output+0x2cb/0x670
> [  218.255682]  [<ffffffff81ab21b9>] ? ip_output+0x59/0xf0
> [  218.261168]  [<ffffffff81ab21b9>] ip_output+0x59/0xf0
> [  218.266559]  [<ffffffff81aad596>] ip_forward_finish+0x76/0x1a0
> [  218.271883]  [<ffffffff81aad86b>] ip_forward+0x1ab/0x440
> [  218.277148]  [<ffffffff81aab380>] ip_rcv_finish+0x150/0x660
> [  218.282373]  [<ffffffff81aabe3b>] ip_rcv+0x22b/0x370
> [  218.287436]  [<ffffffff81b09bc7>] ? packet_rcv_spkt+0x47/0x190
> [  218.292372]  [<ffffffff81a03272>] __netif_receive_skb_core+0x722/0x8f0
> [  218.297328]  [<ffffffff81a02c75>] ? __netif_receive_skb_core+0x125/0x8f0
> [  218.302304]  [<ffffffff8112ce6e>] ? getnstimeofday+0xe/0x30
> [  218.307296]  [<ffffffff819f42c5>] ? __netdev_alloc_frag+0x175/0x1b0
> [  218.312166]  [<ffffffff81a03461>] __netif_receive_skb+0x21/0x70
> [  218.316904]  [<ffffffff81a034d3>] netif_receive_skb_internal+0x23/0xf0
> [  218.321596]  [<ffffffff81a04d2d>] napi_gro_receive+0x8d/0x100
> [  218.326219]  [<ffffffff817a7bc3>] rtl8169_poll+0x2d3/0x680
> [  218.330754]  [<ffffffff8112e366>] ? update_wall_time+0x356/0x690
> [  218.335208]  [<ffffffff81a03a0a>] net_rx_action+0x18a/0x2c0
> [  218.339595]  [<ffffffff810ce6f1>] ? __do_softirq+0xc1/0x300
> [  218.343890]  [<ffffffff810ce767>] __do_softirq+0x137/0x300
> [  218.348085]  [<ffffffff810cec9a>] irq_exit+0xaa/0xd0
> [  218.352203]  [<ffffffff81b8e5a7>] do_IRQ+0x67/0x110
> [  218.356225]  [<ffffffff81b8b772>] common_interrupt+0x72/0x72
> [  218.360156]  <EOI>  [<ffffffff810536e6>] ? native_safe_halt+0x6/0x10
> [  218.364087]  [<ffffffff81113a7d>] ? trace_hardirqs_on+0xd/0x10
> [  218.367935]  [<ffffffff81020632>] default_idle+0x32/0xd0
> [  218.371691]  [<ffffffff8102071e>] amd_e400_idle+0x4e/0x140
> [  218.375360]  [<ffffffff81020f86>] arch_cpu_idle+0x36/0x40
> [  218.378921]  [<ffffffff81120a01>] cpu_startup_entry+0xa1/0x2a0
> [  218.382508]  [<ffffffff810473cf>] start_secondary+0x1af/0x210
> [  218.386133] ---[ end trace 0e12f271209e2c18 ]---
> [  218.389769] r8169 0000:0b:00.0: DMA-API: exceeded 7 overlapping mappings of pfn 3c421 .. start dump
> [  218.393566] r8169 0000:0b:00.0: single idx 563 P=3c421100 N=3c421 D=c66100 L=36 DMA_TO_DEVICE dma map error checked
> [  218.397379] r8169 0000:0b:00.0: single idx 563 P=3c4212c0 N=3c421 D=c672c0 L=36 DMA_TO_DEVICE dma map error checked
> [  218.401094] r8169 0000:0b:00.0: single idx 564 P=3c421480 N=3c421 D=c68480 L=36 DMA_TO_DEVICE dma map error checked
> [  218.404730] r8169 0000:0b:00.0: single idx 564 P=3c421640 N=3c421 D=c69640 L=36 DMA_TO_DEVICE dma map error checked
> [  218.408310] r8169 0000:0b:00.0: single idx 565 P=3c421800 N=3c421 D=c6a800 L=36 DMA_TO_DEVICE dma map error checked
> [  218.411762] r8169 0000:0b:00.0: single idx 565 P=3c4219c0 N=3c421 D=c6b9c0 L=36 DMA_TO_DEVICE dma map error checked
> [  218.415075] r8169 0000:0b:00.0: single idx 566 P=3c421b80 N=3c421 D=c6cb80 L=9b DMA_TO_DEVICE dma map error checked
> [  218.418305] r8169 0000:0b:00.0: single idx 566 P=3c421dc0 N=3c421 D=c6ddc0 L=36 DMA_TO_DEVICE dma map error checked
> [  218.421502] r8169 0000:0b:00.0: single idx 567 P=3c421f80 N=3c421 D=c6ef80 L=36 DMA_TO_DEVICE dma map error not checked
> [  218.424677] r8169 0000:0b:00.0: DMA-API: exceeded 7 overlapping mappings of pfn 3c421 .. end of dump
> [  218.429050] r8169 0000:0b:00.0: DMA-API: exceeded 7 overlapping mappings of pfn 3c423 .. start dump
> [  218.432225] r8169 0000:0b:00.0: single idx 571 P=3c423040 N=3c423 D=c76040 L=36 DMA_TO_DEVICE dma map error checked
> [  218.435408] r8169 0000:0b:00.0: single idx 571 P=3c423200 N=3c423 D=c77200 L=36 DMA_TO_DEVICE dma map error checked
> [  218.438578] r8169 0000:0b:00.0: single idx 572 P=3c4233c0 N=3c423 D=c783c0 L=36 DMA_TO_DEVICE dma map error checked
> [  218.441695] r8169 0000:0b:00.0: single idx 572 P=3c423580 N=3c423 D=c79580 L=7b DMA_TO_DEVICE dma map error checked
> [  218.444783] r8169 0000:0b:00.0: single idx 573 P=3c423780 N=3c423 D=c7a780 L=9b DMA_TO_DEVICE dma map error checked
> [  218.447825] r8169 0000:0b:00.0: single idx 573 P=3c4239c0 N=3c423 D=c7b9c0 L=6b DMA_TO_DEVICE dma map error checked
> [  218.450844] r8169 0000:0b:00.0: single idx 574 P=3c423bc0 N=3c423 D=c7cbc0 L=7b DMA_TO_DEVICE dma map error checked
> [  218.453814] r8169 0000:0b:00.0: single idx 574 P=3c423dc0 N=3c423 D=c7ddc0 L=7b DMA_TO_DEVICE dma map error checked
> [  218.456793] r8169 0000:0b:00.0: single idx 575 P=3c423fc0 N=3c423 D=c7efc0 L=7b DMA_TO_DEVICE dma map error not checked
> [  218.459772] r8169 0000:0b:00.0: DMA-API: exceeded 7 overlapping mappings of pfn 3c423 .. end of dump
> [  218.473504] r8169 0000:0b:00.0: DMA-API: exceeded 7 overlapping mappings of pfn 3c716 .. start dump
> [  218.475662] r8169 0000:0b:00.0: single idx 586 P=3c7160c0 N=3c716 D=c940c0 L=36 DMA_TO_DEVICE dma map error checked
> [  218.477874] r8169 0000:0b:00.0: single idx 586 P=3c716280 N=3c716 D=c95280 L=36 DMA_TO_DEVICE dma map error checked
> [  218.480075] r8169 0000:0b:00.0: single idx 587 P=3c716440 N=3c716 D=c96440 L=36 DMA_TO_DEVICE dma map error checked
> [  218.482245] r8169 0000:0b:00.0: single idx 587 P=3c716600 N=3c716 D=c97600 L=36 DMA_TO_DEVICE dma map error checked
> [  218.484390] r8169 0000:0b:00.0: single idx 588 P=3c7167c0 N=3c716 D=c987c0 L=42 DMA_TO_DEVICE dma map error checked
> [  218.486510] r8169 0000:0b:00.0: single idx 588 P=3c7169c0 N=3c716 D=c999c0 L=36 DMA_TO_DEVICE dma map error checked
> [  218.488603] r8169 0000:0b:00.0: single idx 589 P=3c716b80 N=3c716 D=c9ab80 L=42 DMA_TO_DEVICE dma map error checked
> [  218.490682] r8169 0000:0b:00.0: single idx 589 P=3c716d80 N=3c716 D=c9bd80 L=42 DMA_TO_DEVICE dma map error checked
> [  218.492735] r8169 0000:0b:00.0: single idx 590 P=3c716f80 N=3c716 D=c9cf80 L=42 DMA_TO_DEVICE dma map error not checked
> [  218.494788] r8169 0000:0b:00.0: DMA-API: exceeded 7 overlapping mappings of pfn 3c716 .. end of dump
> 
> --
> Sander
> 


Incoming frames might be taken out of order-3 pages.

With regular Ethernet frames, this is 21 frames per order-3 pages.

ACTIVE_PFN_MAX_OVERLAP seems too small.

Alternative would be to user order-0 only pages if CONFIG_DMA_API_DEBUG
is set. Not sure if it works if PAGE_SIZE=66536 ....

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index f589c9af8cbf..1b9995adfd29 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1924,7 +1924,11 @@ static inline void __skb_queue_purge(struct sk_buff_head *list)
 		kfree_skb(skb);
 }
 
+#if defined(CONFIG_DMA_API_DEBUG)
+#define NETDEV_FRAG_PAGE_MAX_ORDER 0
+#else
 #define NETDEV_FRAG_PAGE_MAX_ORDER get_order(32768)
+#endif
 #define NETDEV_FRAG_PAGE_MAX_SIZE  (PAGE_SIZE << NETDEV_FRAG_PAGE_MAX_ORDER)
 #define NETDEV_PAGECNT_MAX_BIAS	   NETDEV_FRAG_PAGE_MAX_SIZE
 
