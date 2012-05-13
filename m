From: Mike Galbraith <mgalbraith@suse.de>
Subject: [patch] Re: qlge driver corrupting kernel memory
Date: Sun, 13 May 2012 12:10:39 +0200
Message-ID: <1336903839.7390.13.camel@marge.simpson.net>
References: <1336474818.21924.94.camel@marge.simpson.net>
	 <20120508120748.GA3504@oc1711230544.ibm.com>
	 <1336736301.7361.144.camel@marge.simpson.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:46755 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751684Ab2EMKKs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 May 2012 06:10:48 -0400
In-Reply-To: <1336736301.7361.144.camel@marge.simpson.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-05-11 at 13:38 +0200, Mike Galbraith wrote: 
> On Tue, 2012-05-08 at 09:07 -0300, Thadeu Lima de Souza Cascardo wrote: 
> > On Tue, May 08, 2012 at 01:00:18PM +0200, Mike Galbraith wrote:
> > > Greetings network wizards,
> > > 
> > > $subject is happening in an 2.6.32 enterprise kernel with the driver
> > > updated to what looks to me to be 2.6.38 or so.
> > > 
> > > Allegedly, IFF boxen are running dual CNAs with storage and LAN sharing
> > > a port, $subject happens fairly regularly.  Rummaging in crashdumps
> > > seems to show corruption happens because we somehow end up stuffing
> > > loads of frags into skb_shared_info, scribbling all over the place.
> > > 
> > > Before I proceed, what I know about skbs can be found here..
> > > 
> > >     http://vger.kernel.org/~davem/skb_data.html
> > > 
> > > ..and that's the sum and total ;-)
> > > 
> > > I guess the first thing I should ask is whether anyone has seen such
> > > scribbling with this driver.  Known issue would be a case of happiness,
> > > but I doubt that will be the case from searching, so onward.
> > > 
> > 
> > Hi, Mike.
> > 
> > From what you describe, I suspect this is related to this fix:
> > 
> > http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=782428535e0819b5b7c9825cd3faa2ad37032a70
> > 
> > Please, apply and report if that works for you.
> 
> Nope, box exploded.  I haven't seen a dump yet, but expect it'll be more
> of the same scribbling.

Something else popped up meanwhile.  Shortly after tx_ring->q order 5
allocation failure and ql_release_adapter_resources(), BUG: Bad page
state has now arrived twice to muddy the water.

[ 3537.150327] Node 0 DMA: 2*4kB 2*8kB 1*16kB 2*32kB 2*64kB 1*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 360kB
[ 3537.150345] Node 0 DMA32: 318*4kB 144*8kB 89*16kB 17*32kB 3*64kB 1*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 4712kB
[ 3537.150364] 5248 total pagecache pages
[ 3537.150367] 211 pages in swap cache
[ 3537.150372] Swap cache stats: add 1437, delete 1226, find 1641/1752
[ 3537.150377] Free swap  = 67109880kB
[ 3537.150381] Total swap = 67111528kB
[ 3537.152314] 73723 pages RAM
[ 3537.152319] 13128 pages reserved
[ 3537.152322] 4910 pages shared
[ 3537.152326] 22795 pages non-shared
[ 3537.152333] qlge 0000:04:00.0: ql_alloc_mem_resources: TX resource allocation failed.
[ 3537.152343] qlge 0000:04:00.0: ql_get_adapter_resources: Unable to  allocate memory.
[ 3537.152499] qlge 0000:04:00.0: ql_set_mac_addr_reg: Adding UNICAST address 00:c0:dd:1a:46:ac at index 0 in the CAM.
[ 3537.440237] BUG: Bad page state in process ifdown-dhcp  pfn:10940
[ 3537.440244] page:ffffea00003a0600 flags:0020000000000000 count:-1 mapcount:0 mapping:(null) index:0
[ 3537.440249] Pid: 4317, comm: ifdown-dhcp Tainted: G           X 2.6.32.54-0.3.1.4242.0.TEST-default #1
[ 3537.440253] Call Trace:
[ 3537.440265]  [<ffffffff810061dc>] dump_trace+0x6c/0x2d0
[ 3537.440271]  [<ffffffff8139b366>] dump_stack+0x69/0x73
[ 3537.440279]  [<ffffffff810badb3>] bad_page+0xe3/0x170
[ 3537.440284]  [<ffffffff810bbedb>] prep_new_page+0xab/0x1b0
[ 3537.440289]  [<ffffffff810bc2e4>] get_page_from_freelist+0x304/0x720
[ 3537.440295]  [<ffffffff810bc9ba>] __alloc_pages_slowpath+0x11a/0x5f0
[ 3537.440300]  [<ffffffff810bcfca>] __alloc_pages_nodemask+0x13a/0x140
[ 3537.440305]  [<ffffffff810bbdd9>] __get_free_pages+0x9/0x50
[ 3537.440314]  [<ffffffff8104ba62>] dup_task_struct+0x42/0x150
[ 3537.440320]  [<ffffffff8104cc54>] copy_process+0xb4/0xe50
[ 3537.440324]  [<ffffffff8104da7c>] do_fork+0x8c/0x3c0
[ 3537.440331]  [<ffffffff81003263>] stub_clone+0x13/0x20
[ 3537.441094] DWARF2 unwinder stuck at stub_clone+0x13/0x20
[ 3537.441097]
[ 3537.441098] Leftover inexact backtrace:
[ 3537.441099]
[ 3537.441103]  [<ffffffff81002f7b>] ? system_call_fastpath+0x16/0x1b
[ 3537.441107] Disabling lock debugging due to kernel taint
[ 3537.899545] bonding: bond0 is being deleted..

glge: Fix double pci_free_consistent() upon tx_ring->q allocation failure

Let ql_free_tx_resources() do it's job.  You are not helping.

Signed-off-by: Mike Galbraith <mgalbraith@suse.de>
---
 drivers/net/qlge/qlge_main.c |   10 +++-------
 1 file changed, 3 insertions(+), 7 deletions(-)

--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -2664,11 +2664,8 @@ static int ql_alloc_tx_resources(struct
 	    pci_alloc_consistent(qdev->pdev, tx_ring->wq_size,
 				 &tx_ring->wq_base_dma);
 
-	if ((tx_ring->wq_base == NULL) ||
-	    tx_ring->wq_base_dma & WQ_ADDR_ALIGN) {
-		QPRINTK(qdev, IFUP, ERR, "tx_ring alloc failed.\n");
-		return -ENOMEM;
-	}
+	if ((tx_ring->wq_base == NULL) tx_ring->wq_base_dma & WQ_ADDR_ALIGN)
+		goto err;
 	tx_ring->q =
 	    kmalloc(tx_ring->wq_len * sizeof(struct tx_ring_desc), GFP_KERNEL);
 	if (tx_ring->q == NULL)
@@ -2676,8 +2673,7 @@ static int ql_alloc_tx_resources(struct
 
 	return 0;
 err:
-	pci_free_consistent(qdev->pdev, tx_ring->wq_size,
-			    tx_ring->wq_base, tx_ring->wq_base_dma);
+	QPRINTK(qdev, IFUP, ERR, "tx_ring alloc failed.\n");
 	return -ENOMEM;
 }
 
