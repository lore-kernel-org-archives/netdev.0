From: Dan Williams <dan.j.williams@intel.com>
Subject: Re: 3.14-mw regression: rtl8169 WARNING: DMA-API: exceeded 7
 overlapping mappings of pfn 55ebe
Date: Tue, 11 Feb 2014 18:07:10 -0800
Message-ID: <CAPcyv4juAS0ODRPKE-_wXYu5bixLnvsgs3jgo4vzWcatfnyVsw@mail.gmail.com>
References: <1859471893.20140126115521@eikelenboom.it>
	<20140127000305.GA14236@electric-eye.fr.zoreil.com>
	<CAA9_cme2hgJ=jCDkPh5n5RP8fiJE-dVwbFr-apKv1=mNGPHYZg@mail.gmail.com>
	<84816226.20140206123631@eikelenboom.it>
	<942972114.20140206140909@eikelenboom.it>
	<CAPcyv4g2EnCLFWfLfSDnjtwrid2tCq2k6wh-8sPYY06eJpM83A@mail.gmail.com>
	<1434499348.20140211205617@eikelenboom.it>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=20cf30223c1dcfa44d04f22c07e0
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Wei Liu <wei.liu2@citrix.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Dave Jones <davej@redhat.com>
To: Sander Eikelenboom <linux@eikelenboom.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f43.google.com ([209.85.214.43]:46730 "EHLO
	mail-bk0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751975AbaBLCHM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Feb 2014 21:07:12 -0500
Received: by mail-bk0-f43.google.com with SMTP id mx11so2487123bkb.30
        for <netdev@vger.kernel.org>; Tue, 11 Feb 2014 18:07:10 -0800 (PST)
In-Reply-To: <1434499348.20140211205617@eikelenboom.it>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--20cf30223c1dcfa44d04f22c07e0
Content-Type: text/plain; charset=ISO-8859-1

On Tue, Feb 11, 2014 at 11:56 AM, Sander Eikelenboom
<linux@eikelenboom.it> wrote:
> Hi Dan,
>
> FYI just tested and put Xen out of the equation (booting baremetal) and it still persists.
>
> I tried something else .. don't know if it gives you anymore insights, but it's worth the try:

This is great!  See below:

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

The overlap granularity is too large.  Multiple dma_map_single
mappings are allowed to a given page as long as they don't collide on
the same cache line.


Please try the attached patch to see if it fixes this issue.  Works ok for me.

--20cf30223c1dcfa44d04f22c07e0
Content-Type: text/x-patch; charset=US-ASCII; name="fix-dma-debug-overlap.patch"
Content-Disposition: attachment; filename="fix-dma-debug-overlap.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_hrjyk9340

ZG1hIGRlYnVnOiBhY2NvdW50IGZvciBjYWNoZWxpbmVzIGluIG92ZXJsYXAgdHJhY2tpbmcKCkZy
b206IERhbiBXaWxsaWFtcyA8ZGFuLmoud2lsbGlhbXNAaW50ZWwuY29tPgoKV2hpbGUgZGVidWdf
ZG1hX2Fzc2VydF9pZGxlKCkgY2hlY2tzIGlmIGEgZ2l2ZW4gKnBhZ2UqIGlzIGFjdGl2ZWx5CnVu
ZGVyZ29pbmcgZG1hIHRoZSB2YWxpZCBncmFudWxhcml0eSBvZiBhIGRtYSBtYXBwaW5nIGlzIGEg
KmNhY2hlbGluZSouClNhbmRlcidzIHRlc3Rpbmcgc2hvd3MgdGhhdCB0aGUgd2FybmluZyBtZXNz
YWdlICJETUEtQVBJOiBleGNlZWRlZCA3Cm92ZXJsYXBwaW5nIG1hcHBpbmdzIG9mIHBmbi4uLiIg
aXMgZmFsc2VseSB0cmlnZ2VyaW5nLiAgVGhlIHRlc3QgaXMKc2ltcGx5IG1hcHBpbmcgbXVsdGlw
bGUgY2FjaGVsaW5lcyBpbiBhIGdpdmVuIHBhZ2UuCgpVbHRpbWF0ZWx5IHdlIHdhbnQgb3Zlcmxh
cCB0cmFja2luZyB0byBiZSB2YWxpZCBhcyBpdCBpcyBhIHJlYWwgYXBpCnZpb2xhdGlvbiwgdG8g
dGhhdCBlbmQgd2UgbmVlZCB0byB0cmFjayBhY3RpdmUgbWFwcGluZ3MgYnkgY2FjaGVsaW5lcy4K
VG8gdGhpcyBlbmQsIHVwZGF0ZSB0aGUgYWN0aXZlIGRtYSB0cmFja2luZyB0byB1c2UgdGhlCnBh
Z2UtZnJhbWUtcmVsYXRpdmUgY2FjaGVsaW5lIG9mIHRoZSBtYXBwaW5nIGFzIHRoZSBrZXksIGFu
ZCB1cGRhdGUKZGVidWdfZG1hX2Fzc2VydF9pZGxlKCkgdG8gY2hlY2sgZm9yIGFsbCBwb3NzaWJs
ZSBtYXBwZWQgY2FjaGVsaW5lcyBmb3IKYSBnaXZlbiBwYWdlLgoKTm90ZSwgdGhlIHJhZGl4IGdh
bmcgbG9va3VwIGlzIHN1Ym9wdGltYWwuICBJdCB3b3VsZCBiZSBiZXN0IGlmIGl0CnN0b3BwZWQg
ZmV0Y2hpbmcgZW50cmllcyBvbmNlIHRoZSBzZWFyY2ggcGFzc2VkIGEgcGFnZSBib3VuZGFyeS4K
TmV2ZXJ0aGVsZXNzLCB0aGlzIGltcGxlbWVudGF0aW9uIGRvZXMgbm90IHBlcnR1cmIgdGhlIG9y
aWdpbmFsIG5ldF9kbWEKZmFpbGluZyBjYXNlLiAgVGhhdCBpcyB0byBzYXkgdGhlIGV4dHJhIG92
ZXJoZWFkIGRvZXMgbm90IHNob3cgdXAgaW4KdGVybXMgb2YgbWFraW5nIHRoZSBmYWlsaW5nIGNh
c2UgcGFzcyBkdWUgdG8gYSB0aW1pbmcgY2hhbmdlLgoKUmVwb3J0ZWQtYnk6IFNhbmRlciBFaWtl
bGVuYm9vbSA8bGludXhAZWlrZWxlbmJvb20uaXQ+ClJlcG9ydGVkLWJ5OiBEYXZlIEpvbmVzIDxk
YXZlakByZWRoYXQuY29tPgpDYzogS29ucmFkIFJ6ZXN6dXRlayBXaWxrIDxrb25yYWQud2lsa0Bv
cmFjbGUuY29tPgpDYzogRnJhbmNvaXMgUm9taWV1IDxyb21pZXVAZnIuem9yZWlsLmNvbT4KQ2M6
IEVyaWMgRHVtYXpldCA8ZXJpYy5kdW1hemV0QGdtYWlsLmNvbT4KQ2M6IFdlaSBMaXUgPHdlaS5s
aXUyQGNpdHJpeC5jb20+ClNpZ25lZC1vZmYtYnk6IERhbiBXaWxsaWFtcyA8ZGFuLmoud2lsbGlh
bXNAaW50ZWwuY29tPgotLS0KIGxpYi9kbWEtZGVidWcuYyB8ICAxMTIgKysrKysrKysrKysrKysr
KysrKysrKysrKysrKysrKysrLS0tLS0tLS0tLS0tLS0tLS0tLS0tLQogMSBmaWxlcyBjaGFuZ2Vk
LCA2NyBpbnNlcnRpb25zKCspLCA0NSBkZWxldGlvbnMoLSkKCmRpZmYgLS1naXQgYS9saWIvZG1h
LWRlYnVnLmMgYi9saWIvZG1hLWRlYnVnLmMKaW5kZXggMmRlZmQxMzA4YjA0Li40MmIxMjc0MDk0
MGIgMTAwNjQ0Ci0tLSBhL2xpYi9kbWEtZGVidWcuYworKysgYi9saWIvZG1hLWRlYnVnLmMKQEAg
LTQyNCwxMTEgKzQyNCwxMjEgQEAgdm9pZCBkZWJ1Z19kbWFfZHVtcF9tYXBwaW5ncyhzdHJ1Y3Qg
ZGV2aWNlICpkZXYpCiBFWFBPUlRfU1lNQk9MKGRlYnVnX2RtYV9kdW1wX21hcHBpbmdzKTsKIAog
LyoKLSAqIEZvciBlYWNoIHBhZ2UgbWFwcGVkIChpbml0aWFsIHBhZ2UgaW4gdGhlIGNhc2Ugb2YK
LSAqIGRtYV9hbGxvY19jb2hlcmVudC9kbWFfbWFwX3tzaW5nbGV8cGFnZX0sIG9yIGVhY2ggcGFn
ZSBpbiBhCi0gKiBzY2F0dGVybGlzdCkgaW5zZXJ0IGludG8gdGhpcyB0cmVlIHVzaW5nIHRoZSBw
Zm4gYXMgdGhlIGtleS4gQXQKKyAqIEZvciBlYWNoIG1hcHBpbmcgKGluaXRpYWwgY2FjaGVsaW5l
IGluIHRoZSBjYXNlIG9mCisgKiBkbWFfYWxsb2NfY29oZXJlbnQvZG1hX21hcF9wYWdlLCBpbml0
aWFsIGNhY2hlbGluZSBpbiBlYWNoIHBhZ2Ugb2YgYQorICogc2NhdHRlcmxpc3QsIG9yIHRoZSBj
YWNoZWxpbmUgc3BlY2lmaWVkIGluIGRtYV9tYXBfc2luZ2xlKSBpbnNlcnQKKyAqIGludG8gdGhp
cyB0cmVlIHVzaW5nIHRoZSBjYWNoZWxpbmUgYXMgdGhlIGtleS4gQXQKICAqIGRtYV91bm1hcF97
c2luZ2xlfHNnfHBhZ2V9IG9yIGRtYV9mcmVlX2NvaGVyZW50IGRlbGV0ZSB0aGUgZW50cnkuICBJ
ZgotICogdGhlIHBmbiBhbHJlYWR5IGV4aXN0cyBhdCBpbnNlcnRpb24gdGltZSBhZGQgYSB0YWcg
YXMgYSByZWZlcmVuY2UKKyAqIHRoZSBlbnRyeSBhbHJlYWR5IGV4aXN0cyBhdCBpbnNlcnRpb24g
dGltZSBhZGQgYSB0YWcgYXMgYSByZWZlcmVuY2UKICAqIGNvdW50IGZvciB0aGUgb3ZlcmxhcHBp
bmcgbWFwcGluZ3MuICBGb3Igbm93LCB0aGUgb3ZlcmxhcCB0cmFja2luZwotICoganVzdCBlbnN1
cmVzIHRoYXQgJ3VubWFwcycgYmFsYW5jZSAnbWFwcycgYmVmb3JlIG1hcmtpbmcgdGhlIHBmbgot
ICogaWRsZSwgYnV0IHdlIHNob3VsZCBhbHNvIGJlIGZsYWdnaW5nIG92ZXJsYXBzIGFzIGFuIEFQ
SSB2aW9sYXRpb24uCisgKiBqdXN0IGVuc3VyZXMgdGhhdCAndW5tYXBzJyBiYWxhbmNlICdtYXBz
JyBiZWZvcmUgbWFya2luZyB0aGUKKyAqIGNhY2hlbGluZSBpZGxlLCBidXQgd2Ugc2hvdWxkIGFs
c28gYmUgZmxhZ2dpbmcgb3ZlcmxhcHMgYXMgYW4gQVBJCisgKiB2aW9sYXRpb24uCiAgKgogICog
TWVtb3J5IHVzYWdlIGlzIG1vc3RseSBjb25zdHJhaW5lZCBieSB0aGUgbWF4aW11bSBudW1iZXIg
b2YgYXZhaWxhYmxlCiAgKiBkbWEtZGVidWcgZW50cmllcyBpbiB0aGF0IHdlIG5lZWQgYSBmcmVl
IGRtYV9kZWJ1Z19lbnRyeSBiZWZvcmUKLSAqIGluc2VydGluZyBpbnRvIHRoZSB0cmVlLiAgSW4g
dGhlIGNhc2Ugb2YgZG1hX21hcF97c2luZ2xlfHBhZ2V9IGFuZAotICogZG1hX2FsbG9jX2NvaGVy
ZW50IHRoZXJlIGlzIG9ubHkgb25lIGRtYV9kZWJ1Z19lbnRyeSBhbmQgb25lIHBmbiB0bwotICog
dHJhY2sgcGVyIGV2ZW50LiAgZG1hX21hcF9zZygpLCBvbiB0aGUgb3RoZXIgaGFuZCwKLSAqIGNv
bnN1bWVzIGEgc2luZ2xlIGRtYV9kZWJ1Z19lbnRyeSwgYnV0IGluc2VydHMgJ25lbnRzJyBlbnRy
aWVzIGludG8KLSAqIHRoZSB0cmVlLgorICogaW5zZXJ0aW5nIGludG8gdGhlIHRyZWUuICBJbiB0
aGUgY2FzZSBvZiBkbWFfbWFwX3BhZ2UgYW5kCisgKiBkbWFfYWxsb2NfY29oZXJlbnQgdGhlcmUg
aXMgb25seSBvbmUgZG1hX2RlYnVnX2VudHJ5IGFuZCBvbmUKKyAqIGRtYV9hY3RpdmVfY2FjaGVs
aW5lIGVudHJ5IHRvIHRyYWNrIHBlciBldmVudC4gIGRtYV9tYXBfc2coKSwgb24gdGhlCisgKiBv
dGhlciBoYW5kLCBjb25zdW1lcyBhIHNpbmdsZSBkbWFfZGVidWdfZW50cnksIGJ1dCBpbnNlcnRz
ICduZW50cycKKyAqIGVudHJpZXMgaW50byB0aGUgdHJlZS4KICAqCiAgKiBBdCBhbnkgdGltZSBk
ZWJ1Z19kbWFfYXNzZXJ0X2lkbGUoKSBjYW4gYmUgY2FsbGVkIHRvIHRyaWdnZXIgYQotICogd2Fy
bmluZyBpZiB0aGUgZ2l2ZW4gcGFnZSBpcyBpbiB0aGUgYWN0aXZlIHNldC4KKyAqIHdhcm5pbmcg
aWYgYW55IGNhY2hlbGluZXMgaW4gdGhlIGdpdmVuIHBhZ2UgYXJlIGluIHRoZSBhY3RpdmUgc2V0
LgogICovCi1zdGF0aWMgUkFESVhfVFJFRShkbWFfYWN0aXZlX3BmbiwgR0ZQX05PV0FJVCk7Citz
dGF0aWMgUkFESVhfVFJFRShkbWFfYWN0aXZlX2NhY2hlbGluZSwgR0ZQX05PV0FJVCk7CiBzdGF0
aWMgREVGSU5FX1NQSU5MT0NLKHJhZGl4X2xvY2spOwotI2RlZmluZSBBQ1RJVkVfUEZOX01BWF9P
VkVSTEFQICgoMSA8PCBSQURJWF9UUkVFX01BWF9UQUdTKSAtIDEpCisjZGVmaW5lIEFDVElWRV9D
TE5fTUFYX09WRVJMQVAgKCgxIDw8IFJBRElYX1RSRUVfTUFYX1RBR1MpIC0gMSkKKyNkZWZpbmUg
Q0FDSEVMSU5FX1BFUl9QQUdFX1NISUZUIChQQUdFX1NISUZUIC0gTDFfQ0FDSEVfU0hJRlQpCisj
ZGVmaW5lIENBQ0hFTElORVNfUEVSX1BBR0UgKDEgPDwgQ0FDSEVMSU5FX1BFUl9QQUdFX1NISUZU
KQogCi1zdGF0aWMgaW50IGFjdGl2ZV9wZm5fcmVhZF9vdmVybGFwKHVuc2lnbmVkIGxvbmcgcGZu
KQordW5zaWduZWQgbG9uZyB0b19jbG4oc3RydWN0IGRtYV9kZWJ1Z19lbnRyeSAqZW50cnkpCit7
CisJcmV0dXJuIChlbnRyeS0+cGZuIDw8IENBQ0hFTElORV9QRVJfUEFHRV9TSElGVCkgKworCQko
ZW50cnktPm9mZnNldCA+PiBMMV9DQUNIRV9TSElGVCk7Cit9CisKK3N0YXRpYyBpbnQgYWN0aXZl
X2Nsbl9yZWFkX292ZXJsYXAodW5zaWduZWQgbG9uZyBjbG4pCiB7CiAJaW50IG92ZXJsYXAgPSAw
LCBpOwogCiAJZm9yIChpID0gUkFESVhfVFJFRV9NQVhfVEFHUyAtIDE7IGkgPj0gMDsgaS0tKQot
CQlpZiAocmFkaXhfdHJlZV90YWdfZ2V0KCZkbWFfYWN0aXZlX3BmbiwgcGZuLCBpKSkKKwkJaWYg
KHJhZGl4X3RyZWVfdGFnX2dldCgmZG1hX2FjdGl2ZV9jYWNoZWxpbmUsIGNsbiwgaSkpCiAJCQlv
dmVybGFwIHw9IDEgPDwgaTsKIAlyZXR1cm4gb3ZlcmxhcDsKIH0KIAotc3RhdGljIGludCBhY3Rp
dmVfcGZuX3NldF9vdmVybGFwKHVuc2lnbmVkIGxvbmcgcGZuLCBpbnQgb3ZlcmxhcCkKK3N0YXRp
YyBpbnQgYWN0aXZlX2Nsbl9zZXRfb3ZlcmxhcCh1bnNpZ25lZCBsb25nIGNsbiwgaW50IG92ZXJs
YXApCiB7CiAJaW50IGk7CiAKLQlpZiAob3ZlcmxhcCA+IEFDVElWRV9QRk5fTUFYX09WRVJMQVAg
fHwgb3ZlcmxhcCA8IDApCisJaWYgKG92ZXJsYXAgPiBBQ1RJVkVfQ0xOX01BWF9PVkVSTEFQIHx8
IG92ZXJsYXAgPCAwKQogCQlyZXR1cm4gb3ZlcmxhcDsKIAogCWZvciAoaSA9IFJBRElYX1RSRUVf
TUFYX1RBR1MgLSAxOyBpID49IDA7IGktLSkKIAkJaWYgKG92ZXJsYXAgJiAxIDw8IGkpCi0JCQly
YWRpeF90cmVlX3RhZ19zZXQoJmRtYV9hY3RpdmVfcGZuLCBwZm4sIGkpOworCQkJcmFkaXhfdHJl
ZV90YWdfc2V0KCZkbWFfYWN0aXZlX2NhY2hlbGluZSwgY2xuLCBpKTsKIAkJZWxzZQotCQkJcmFk
aXhfdHJlZV90YWdfY2xlYXIoJmRtYV9hY3RpdmVfcGZuLCBwZm4sIGkpOworCQkJcmFkaXhfdHJl
ZV90YWdfY2xlYXIoJmRtYV9hY3RpdmVfY2FjaGVsaW5lLCBjbG4sIGkpOwogCiAJcmV0dXJuIG92
ZXJsYXA7CiB9CiAKLXN0YXRpYyB2b2lkIGFjdGl2ZV9wZm5faW5jX292ZXJsYXAodW5zaWduZWQg
bG9uZyBwZm4pCitzdGF0aWMgdm9pZCBhY3RpdmVfY2xuX2luY19vdmVybGFwKHVuc2lnbmVkIGxv
bmcgY2xuKQogewotCWludCBvdmVybGFwID0gYWN0aXZlX3Bmbl9yZWFkX292ZXJsYXAocGZuKTsK
KwlpbnQgb3ZlcmxhcCA9IGFjdGl2ZV9jbG5fcmVhZF9vdmVybGFwKGNsbik7CiAKLQlvdmVybGFw
ID0gYWN0aXZlX3Bmbl9zZXRfb3ZlcmxhcChwZm4sICsrb3ZlcmxhcCk7CisJb3ZlcmxhcCA9IGFj
dGl2ZV9jbG5fc2V0X292ZXJsYXAoY2xuLCArK292ZXJsYXApOwogCiAJLyogSWYgd2Ugb3ZlcmZs
b3dlZCB0aGUgb3ZlcmxhcCBjb3VudGVyIHRoZW4gd2UncmUgcG90ZW50aWFsbHkKIAkgKiBsZWFr
aW5nIGRtYS1tYXBwaW5ncy4gIE90aGVyd2lzZSwgaWYgbWFwcyBhbmQgdW5tYXBzIGFyZQogCSAq
IGJhbGFuY2VkIHRoZW4gdGhpcyBvdmVyZmxvdyBtYXkgY2F1c2UgZmFsc2UgbmVnYXRpdmVzIGlu
Ci0JICogZGVidWdfZG1hX2Fzc2VydF9pZGxlKCkgYXMgdGhlIHBmbiBtYXkgYmUgbWFya2VkIGlk
bGUKKwkgKiBkZWJ1Z19kbWFfYXNzZXJ0X2lkbGUoKSBhcyB0aGUgY2xuIG1heSBiZSBtYXJrZWQg
aWRsZQogCSAqIHByZW1hdHVyZWx5LgogCSAqLwotCVdBUk5fT05DRShvdmVybGFwID4gQUNUSVZF
X1BGTl9NQVhfT1ZFUkxBUCwKLQkJICAiRE1BLUFQSTogZXhjZWVkZWQgJWQgb3ZlcmxhcHBpbmcg
bWFwcGluZ3Mgb2YgcGZuICVseFxuIiwKLQkJICBBQ1RJVkVfUEZOX01BWF9PVkVSTEFQLCBwZm4p
OworCVdBUk5fT05DRShvdmVybGFwID4gQUNUSVZFX0NMTl9NQVhfT1ZFUkxBUCwKKwkJICAiRE1B
LUFQSTogZXhjZWVkZWQgJWQgb3ZlcmxhcHBpbmcgbWFwcGluZ3Mgb2YgY2xuICVseFxuIiwKKwkJ
ICBBQ1RJVkVfQ0xOX01BWF9PVkVSTEFQLCBjbG4pOwogfQogCi1zdGF0aWMgaW50IGFjdGl2ZV9w
Zm5fZGVjX292ZXJsYXAodW5zaWduZWQgbG9uZyBwZm4pCitzdGF0aWMgaW50IGFjdGl2ZV9jbG5f
ZGVjX292ZXJsYXAodW5zaWduZWQgbG9uZyBjbG4pCiB7Ci0JaW50IG92ZXJsYXAgPSBhY3RpdmVf
cGZuX3JlYWRfb3ZlcmxhcChwZm4pOworCWludCBvdmVybGFwID0gYWN0aXZlX2Nsbl9yZWFkX292
ZXJsYXAoY2xuKTsKIAotCXJldHVybiBhY3RpdmVfcGZuX3NldF9vdmVybGFwKHBmbiwgLS1vdmVy
bGFwKTsKKwlyZXR1cm4gYWN0aXZlX2Nsbl9zZXRfb3ZlcmxhcChjbG4sIC0tb3ZlcmxhcCk7CiB9
CiAKLXN0YXRpYyBpbnQgYWN0aXZlX3Bmbl9pbnNlcnQoc3RydWN0IGRtYV9kZWJ1Z19lbnRyeSAq
ZW50cnkpCitzdGF0aWMgaW50IGFjdGl2ZV9jbG5faW5zZXJ0KHN0cnVjdCBkbWFfZGVidWdfZW50
cnkgKmVudHJ5KQogewogCXVuc2lnbmVkIGxvbmcgZmxhZ3M7CiAJaW50IHJjOwogCiAJc3Bpbl9s
b2NrX2lycXNhdmUoJnJhZGl4X2xvY2ssIGZsYWdzKTsKLQlyYyA9IHJhZGl4X3RyZWVfaW5zZXJ0
KCZkbWFfYWN0aXZlX3BmbiwgZW50cnktPnBmbiwgZW50cnkpOworCXJjID0gcmFkaXhfdHJlZV9p
bnNlcnQoJmRtYV9hY3RpdmVfY2FjaGVsaW5lLCB0b19jbG4oZW50cnkpLCBlbnRyeSk7CiAJaWYg
KHJjID09IC1FRVhJU1QpCi0JCWFjdGl2ZV9wZm5faW5jX292ZXJsYXAoZW50cnktPnBmbik7CisJ
CWFjdGl2ZV9jbG5faW5jX292ZXJsYXAodG9fY2xuKGVudHJ5KSk7CiAJc3Bpbl91bmxvY2tfaXJx
cmVzdG9yZSgmcmFkaXhfbG9jaywgZmxhZ3MpOwogCiAJcmV0dXJuIHJjOwogfQogCi1zdGF0aWMg
dm9pZCBhY3RpdmVfcGZuX3JlbW92ZShzdHJ1Y3QgZG1hX2RlYnVnX2VudHJ5ICplbnRyeSkKK3N0
YXRpYyB2b2lkIGFjdGl2ZV9jbG5fcmVtb3ZlKHN0cnVjdCBkbWFfZGVidWdfZW50cnkgKmVudHJ5
KQogewogCXVuc2lnbmVkIGxvbmcgZmxhZ3M7CiAKIAlzcGluX2xvY2tfaXJxc2F2ZSgmcmFkaXhf
bG9jaywgZmxhZ3MpOwogCS8qIHNpbmNlIHdlIGFyZSBjb3VudGluZyBvdmVybGFwcyB0aGUgZmlu
YWwgcHV0IG9mIHRoZQotCSAqIGVudHJ5LT5wZm4gd2lsbCBvY2N1ciB3aGVuIHRoZSBvdmVybGFw
IGNvdW50IGlzIDAuCi0JICogYWN0aXZlX3Bmbl9kZWNfb3ZlcmxhcCgpIHJldHVybnMgLTEgaW4g
dGhhdCBjYXNlCisJICogY2FjaGVsaW5lIHdpbGwgb2NjdXIgd2hlbiB0aGUgb3ZlcmxhcCBjb3Vu
dCBpcyAwLgorCSAqIGFjdGl2ZV9jbG5fZGVjX292ZXJsYXAoKSByZXR1cm5zIC0xIGluIHRoYXQg
Y2FzZQogCSAqLwotCWlmIChhY3RpdmVfcGZuX2RlY19vdmVybGFwKGVudHJ5LT5wZm4pIDwgMCkK
LQkJcmFkaXhfdHJlZV9kZWxldGUoJmRtYV9hY3RpdmVfcGZuLCBlbnRyeS0+cGZuKTsKKwlpZiAo
YWN0aXZlX2Nsbl9kZWNfb3ZlcmxhcCh0b19jbG4oZW50cnkpKSA8IDApCisJCXJhZGl4X3RyZWVf
ZGVsZXRlKCZkbWFfYWN0aXZlX2NhY2hlbGluZSwgdG9fY2xuKGVudHJ5KSk7CiAJc3Bpbl91bmxv
Y2tfaXJxcmVzdG9yZSgmcmFkaXhfbG9jaywgZmxhZ3MpOwogfQogCiAvKioKICAqIGRlYnVnX2Rt
YV9hc3NlcnRfaWRsZSgpIC0gYXNzZXJ0IHRoYXQgYSBwYWdlIGlzIG5vdCB1bmRlcmdvaW5nIGRt
YQotICogQHBhZ2U6IHBhZ2UgdG8gbG9va3VwIGluIHRoZSBkbWFfYWN0aXZlX3BmbiB0cmVlCisg
KiBAcGFnZTogcGFnZSB0byBsb29rdXAgaW4gdGhlIGRtYV9hY3RpdmVfY2FjaGVsaW5lIHRyZWUK
ICAqCiAgKiBQbGFjZSBhIGNhbGwgdG8gdGhpcyByb3V0aW5lIGluIGNhc2VzIHdoZXJlIHRoZSBj
cHUgdG91Y2hpbmcgdGhlIHBhZ2UKICAqIGJlZm9yZSB0aGUgZG1hIGNvbXBsZXRlcyAocGFnZSBp
cyBkbWFfdW5tYXBwZWQpIHdpbGwgbGVhZCB0byBkYXRhCkBAIC01MzYsMTQgKzU0NiwyNiBAQCBz
dGF0aWMgdm9pZCBhY3RpdmVfcGZuX3JlbW92ZShzdHJ1Y3QgZG1hX2RlYnVnX2VudHJ5ICplbnRy
eSkKICAqLwogdm9pZCBkZWJ1Z19kbWFfYXNzZXJ0X2lkbGUoc3RydWN0IHBhZ2UgKnBhZ2UpCiB7
CisJdW5zaWduZWQgbG9uZyBjbG4gPSBwYWdlX3RvX3BmbihwYWdlKSA8PCBDQUNIRUxJTkVfUEVS
X1BBR0VfU0hJRlQ7CisJc3RhdGljIHN0cnVjdCBkbWFfZGVidWdfZW50cnkgKmVudHNbQ0FDSEVM
SU5FU19QRVJfUEFHRV07CisJc3RydWN0IGRtYV9kZWJ1Z19lbnRyeSAqZW50cnkgPSBOVUxMOwor
CXZvaWQgKipyZXN1bHRzID0gKHZvaWQgKiopICZlbnRzOworCXVuc2lnbmVkIGludCBuZW50cywg
aTsKIAl1bnNpZ25lZCBsb25nIGZsYWdzOwotCXN0cnVjdCBkbWFfZGVidWdfZW50cnkgKmVudHJ5
OwogCiAJaWYgKCFwYWdlKQogCQlyZXR1cm47CiAKIAlzcGluX2xvY2tfaXJxc2F2ZSgmcmFkaXhf
bG9jaywgZmxhZ3MpOwotCWVudHJ5ID0gcmFkaXhfdHJlZV9sb29rdXAoJmRtYV9hY3RpdmVfcGZu
LCBwYWdlX3RvX3BmbihwYWdlKSk7CisJbmVudHMgPSByYWRpeF90cmVlX2dhbmdfbG9va3VwKCZk
bWFfYWN0aXZlX2NhY2hlbGluZSwgcmVzdWx0cywgY2xuLAorCQkJCSAgICAgICBDQUNIRUxJTkVT
X1BFUl9QQUdFKTsKKwlmb3IgKGkgPSAwOyBpIDwgbmVudHM7IGkrKykgeworCQlpZiAodG9fY2xu
KGVudHNbaV0pID09IGNsbikgeworCQkJZW50cnkgPSBlbnRzW2ldOworCQkJYnJlYWs7CisJCX0g
ZWxzZSBpZiAodG9fY2xuKGVudHNbaV0pID49IGNsbiArIENBQ0hFTElORVNfUEVSX1BBR0UpCisJ
CQlicmVhazsKKwl9CiAJc3Bpbl91bmxvY2tfaXJxcmVzdG9yZSgmcmFkaXhfbG9jaywgZmxhZ3Mp
OwogCiAJaWYgKCFlbnRyeSkKQEAgLTU1MSw3ICs1NzMsNyBAQCB2b2lkIGRlYnVnX2RtYV9hc3Nl
cnRfaWRsZShzdHJ1Y3QgcGFnZSAqcGFnZSkKIAogCWVycl9wcmludGsoZW50cnktPmRldiwgZW50
cnksCiAJCSAgICJETUEtQVBJOiBjcHUgdG91Y2hpbmcgYW4gYWN0aXZlIGRtYSBtYXBwZWQgcGFn
ZSAiCi0JCSAgICJbcGZuPTB4JWx4XVxuIiwgZW50cnktPnBmbik7CisJCSAgICJbY2xuPTB4JWx4
XVxuIiwgdG9fY2xuKGVudHJ5KSk7CiB9CiAKIC8qCkBAIC01NjgsOSArNTkwLDkgQEAgc3RhdGlj
IHZvaWQgYWRkX2RtYV9lbnRyeShzdHJ1Y3QgZG1hX2RlYnVnX2VudHJ5ICplbnRyeSkKIAloYXNo
X2J1Y2tldF9hZGQoYnVja2V0LCBlbnRyeSk7CiAJcHV0X2hhc2hfYnVja2V0KGJ1Y2tldCwgJmZs
YWdzKTsKIAotCXJjID0gYWN0aXZlX3Bmbl9pbnNlcnQoZW50cnkpOworCXJjID0gYWN0aXZlX2Ns
bl9pbnNlcnQoZW50cnkpOwogCWlmIChyYyA9PSAtRU5PTUVNKSB7Ci0JCXByX2VycigiRE1BLUFQ
STogcGZuIHRyYWNraW5nIEVOT01FTSwgZG1hLWRlYnVnIGRpc2FibGVkXG4iKTsKKwkJcHJfZXJy
KCJETUEtQVBJOiBjYWNoZWxpbmUgdHJhY2tpbmcgRU5PTUVNLCBkbWEtZGVidWcgZGlzYWJsZWRc
biIpOwogCQlnbG9iYWxfZGlzYWJsZSA9IHRydWU7CiAJfQogCkBAIC02MzEsNyArNjUzLDcgQEAg
c3RhdGljIHZvaWQgZG1hX2VudHJ5X2ZyZWUoc3RydWN0IGRtYV9kZWJ1Z19lbnRyeSAqZW50cnkp
CiB7CiAJdW5zaWduZWQgbG9uZyBmbGFnczsKIAotCWFjdGl2ZV9wZm5fcmVtb3ZlKGVudHJ5KTsK
KwlhY3RpdmVfY2xuX3JlbW92ZShlbnRyeSk7CiAKIAkvKgogCSAqIGFkZCB0byBiZWdpbm5pbmcg
b2YgdGhlIGxpc3QgLSB0aGlzIHdheSB0aGUgZW50cmllcyBhcmUK
--20cf30223c1dcfa44d04f22c07e0--
