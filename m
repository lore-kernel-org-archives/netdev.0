From: Alexey Kardashevskiy <aik@ozlabs.ru>
Subject: Re: BUG cxgb3: Check and handle the dma mapping errors
Date: Thu, 08 Aug 2013 15:38:28 +1000
Message-ID: <52032ED4.2030202@ozlabs.ru>
References: <51FF14F8.7000204@ozlabs.ru> <20130805184107.GA2998@redhat.com> <52027BEF.5040602@chelsio.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060508070806080405000502"
Cc: Jay Fenlason <fenlason@redhat.com>,
	Santosh Rastapur <santosh@chelsio.com>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Divy Le ray <divy@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:36486 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752219Ab3HHFig (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Aug 2013 01:38:36 -0400
Received: by mail-pd0-f180.google.com with SMTP id 15so2187082pdi.25
        for <netdev@vger.kernel.org>; Wed, 07 Aug 2013 22:38:35 -0700 (PDT)
In-Reply-To: <52027BEF.5040602@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------060508070806080405000502
Content-Type: text/plain; charset=KOI8-R
Content-Transfer-Encoding: 7bit

On 08/08/2013 02:55 AM, Divy Le ray wrote:
> On 08/05/2013 11:41 AM, Jay Fenlason wrote:
>> On Mon, Aug 05, 2013 at 12:59:04PM +1000, Alexey Kardashevskiy wrote:
>>> Hi!
>>>
>>> Recently I started getting multiple errors like this:
>>>
>>> cxgb3 0006:01:00.0: iommu_alloc failed, tbl c000000003067980 vaddr
>>> c000001fbdaaa882 npages 1
>>> cxgb3 0006:01:00.0: iommu_alloc failed, tbl c000000003067980 vaddr
>>> c000001fbdaaa882 npages 1
>>> cxgb3 0006:01:00.0: iommu_alloc failed, tbl c000000003067980 vaddr
>>> c000001fbdaaa882 npages 1
>>> cxgb3 0006:01:00.0: iommu_alloc failed, tbl c000000003067980 vaddr
>>> c000001fbdaaa882 npages 1
>>> cxgb3 0006:01:00.0: iommu_alloc failed, tbl c000000003067980 vaddr
>>> c000001fbdaaa882 npages 1
>>> cxgb3 0006:01:00.0: iommu_alloc failed, tbl c000000003067980 vaddr
>>> c000001fbdaaa882 npages 1
>>> cxgb3 0006:01:00.0: iommu_alloc failed, tbl c000000003067980 vaddr
>>> c000001fbdaaa882 npages 1
>>> ... and so on
>>>
>>> This is all happening on a PPC64 "powernv" platform machine. To trigger the
>>> error state, it is enough to _flood_ ping CXGB3 card from another machine
>>> (which has Emulex 10Gb NIC + Cisco switch). Just do "ping -f 172.20.1.2"
>>> and wait 10-15 seconds.
>>>
>>>
>>> The messages are coming from arch/powerpc/kernel/iommu.c and basically
>>> mean that the driver requested more pages than the DMA window has which is
>>> normally 1GB (there could be another possible source of errors -
>>> ppc_md.tce_build callback - but on powernv platform it always succeeds).
>>>
>>>
>>> The patch after which it broke is:
>>> commit f83331bab149e29fa2c49cf102c0cd8c3f1ce9f9
>>> Author: Santosh Rastapur <santosh@chelsio.com>
>>> Date:   Tue May 21 04:21:29 2013 +0000
>>> cxgb3: Check and handle the dma mapping errors
>>>
>>> Any quick ideas? Thanks!
>> That patch adds error checking to detect failed dma mapping requests.
>> Before it, the code always assumed that dma mapping requests succeded,
>> whether they actually do or not, so the fact that the older kernel
>> does not log errors only means that the failures are being ignored,
>> and any appearance of working is through pure luck.  The machine could
>> have just crashed at that point.
>>
>> What is the observed behavior of the system by the machine initiating
>> the ping flood?  Do the older and newer kernels differ in the
>> percentage of pings that do not receive replies?  O the newer kernel,
>> when the mapping errors are detected, the packet that it is trying to
>> transmit is dropped, but I'm not at all sure what happens on the older
>> kernel after the dma mapping fails.  As I mentioned earlier, I'm
>> surprised it does not crash.  Perhaps the folks from Chelsio have a
>> better idea what happens after a dma mapping error is ignored?
> 
> Hi,
> 
> It should definitely not be ignored. It should not happen this reliably
> either.
> I wonder if we are not hitting a leak of iommu entries.

Yes we do. I did some more tests with socklib from here
http://junkcode.samba.org/ftp/unpacked/junkcode/socklib/

The test is basically sock_source sending packets to sock_sink. If block
size is >=512 bytes, there is no leak, if I set packet size to <=256 bytes,
it starts leaking, smaller block size means faster leak. The type of the
other adapter does not really matter, can be the same Emulex adapter.

I am attaching a small patch which I made in order to detect the leak.
Without the patch, no leak happens, I double checked.


-- 
Alexey

--------------060508070806080405000502
Content-Type: text/x-patch;
 name="cxgb3_debug.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="cxgb3_debug.patch"

commit 8327d4ca1d63a96454897ef7e5603bf78c9a76c5
Author:     Alexey Kardashevskiy <aik@ozlabs.ru>
AuthorDate: Thu Aug 8 15:33:55 2013 +1000
Commit:     Alexey Kardashevskiy <aik@ozlabs.ru>
CommitDate: Thu Aug 8 15:33:55 2013 +1000

    cxgb3: debug patch
    
    Signed-off-by: Alexey Kardashevskiy <aik@ozlabs.ru>

diff --git a/drivers/net/ethernet/chelsio/cxgb3/sge.c b/drivers/net/ethernet/chelsio/cxgb3/sge.c
index 687ec4a..4165c0b 100644
--- a/drivers/net/ethernet/chelsio/cxgb3/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb3/sge.c
@@ -46,6 +46,15 @@
 #include "firmware_exports.h"
 #include "cxgb3_offload.h"
 
+
+unsigned long _cxgb3_maps, _cxgb3_unmaps;
+#define _FLUSH() printk("+%lu -%lu diff=%lu\n", _cxgb3_maps, _cxgb3_unmaps, _cxgb3_maps - _cxgb3_unmaps)
+#define _INC(n) _cxgb3_maps += (n); if (printk_ratelimit())  _FLUSH()
+#define _DEC(n) _cxgb3_unmaps += (n); if (printk_ratelimit()) _FLUSH()
+static int backtraced = 0;
+#define _CXBUG() _FLUSH(); if (!backtraced) { dump_stack(); backtraced = 1; }
+
+
 #define USE_GTS 0
 
 #define SGE_RX_SM_BUF_SIZE 1536
@@ -246,6 +255,7 @@ static inline void unmap_skb(struct sk_buff *skb, struct sge_txq *q,
 	if (frag_idx == 0 && skb_headlen(skb)) {
 		pci_unmap_single(pdev, be64_to_cpu(sgp->addr[0]),
 				 skb_headlen(skb), PCI_DMA_TODEVICE);
+		_DEC(1);
 		j = 1;
 	}
 
@@ -256,6 +266,7 @@ static inline void unmap_skb(struct sk_buff *skb, struct sge_txq *q,
 		pci_unmap_page(pdev, be64_to_cpu(sgp->addr[j]),
 			       skb_frag_size(&skb_shinfo(skb)->frags[frag_idx]),
 			       PCI_DMA_TODEVICE);
+		_DEC(1);
 		j ^= 1;
 		if (j == 0) {
 			sgp++;
@@ -355,15 +366,19 @@ static void clear_rx_desc(struct pci_dev *pdev, const struct sge_fl *q,
 	if (q->use_pages && d->pg_chunk.page) {
 		(*d->pg_chunk.p_cnt)--;
 		if (!*d->pg_chunk.p_cnt)
+		{
 			pci_unmap_page(pdev,
 				       d->pg_chunk.mapping,
 				       q->alloc_size, PCI_DMA_FROMDEVICE);
 
+			_DEC(1);
+		}
 		put_page(d->pg_chunk.page);
 		d->pg_chunk.page = NULL;
 	} else {
 		pci_unmap_single(pdev, dma_unmap_addr(d, dma_addr),
 				 q->buf_size, PCI_DMA_FROMDEVICE);
+		_DEC(1);
 		kfree_skb(d->skb);
 		d->skb = NULL;
 	}
@@ -416,7 +431,11 @@ static inline int add_one_rx_buf(void *va, unsigned int len,
 
 	mapping = pci_map_single(pdev, va, len, PCI_DMA_FROMDEVICE);
 	if (unlikely(pci_dma_mapping_error(pdev, mapping)))
+	{
+		_CXBUG();
 		return -ENOMEM;
+	}
+	_INC(1);
 
 	dma_unmap_addr_set(sd, dma_addr, mapping);
 
@@ -458,8 +477,10 @@ static int alloc_pg_chunk(struct adapter *adapter, struct sge_fl *q,
 		if (unlikely(pci_dma_mapping_error(adapter->pdev, mapping))) {
 			__free_pages(q->pg_chunk.page, order);
 			q->pg_chunk.page = NULL;
+			_CXBUG();
 			return -EIO;
 		}
+		_INC(1);
 		q->pg_chunk.mapping = mapping;
 	}
 	sd->pg_chunk = q->pg_chunk;
@@ -816,6 +837,7 @@ recycle:
 use_orig_buf:
 	pci_unmap_single(adap->pdev, dma_unmap_addr(sd, dma_addr),
 			 fl->buf_size, PCI_DMA_FROMDEVICE);
+	_DEC(1);
 	skb = sd->skb;
 	skb_put(skb, len);
 	__refill_fl(adap, fl);
@@ -887,10 +909,13 @@ recycle:
 				    PCI_DMA_FROMDEVICE);
 	(*sd->pg_chunk.p_cnt)--;
 	if (!*sd->pg_chunk.p_cnt && sd->pg_chunk.page != fl->pg_chunk.page)
+	{
 		pci_unmap_page(adap->pdev,
 			       sd->pg_chunk.mapping,
 			       fl->alloc_size,
 			       PCI_DMA_FROMDEVICE);
+		_DEC(1);
+	}
 	if (!skb) {
 		__skb_put(newskb, SGE_RX_PULL_LEN);
 		memcpy(newskb->data, sd->pg_chunk.va, SGE_RX_PULL_LEN);
@@ -972,7 +997,7 @@ static int map_skb(struct pci_dev *pdev, const struct sk_buff *skb,
 			       PCI_DMA_TODEVICE);
 	if (pci_dma_mapping_error(pdev, *addr))
 		goto out_err;
-
+	_INC(1);
 	si = skb_shinfo(skb);
 	end = &si->frags[si->nr_frags];
 
@@ -981,16 +1006,23 @@ static int map_skb(struct pci_dev *pdev, const struct sk_buff *skb,
 					   DMA_TO_DEVICE);
 		if (pci_dma_mapping_error(pdev, *addr))
 			goto unwind;
+		_INC(1);
 	}
 	return 0;
 
 unwind:
+	_CXBUG();
 	while (fp-- > si->frags)
+	{
 		dma_unmap_page(&pdev->dev, *--addr, skb_frag_size(fp),
 			       DMA_TO_DEVICE);
+		_DEC(1);
+	}
 
 	pci_unmap_single(pdev, addr[-1], skb_headlen(skb), PCI_DMA_TODEVICE);
+	_DEC(1);
 out_err:
+	_CXBUG();
 	return -ENOMEM;
 }
 
@@ -1584,13 +1616,18 @@ static void deferred_unmap_destructor(struct sk_buff *skb)
 	p = dui->addr;
 
 	if (skb_tail_pointer(skb) - skb_transport_header(skb))
+	{
 		pci_unmap_single(dui->pdev, *p++, skb_tail_pointer(skb) -
 				 skb_transport_header(skb), PCI_DMA_TODEVICE);
-
+		_DEC(1);
+	}
 	si = skb_shinfo(skb);
 	for (i = 0; i < si->nr_frags; i++)
+	{
 		pci_unmap_page(dui->pdev, *p++, skb_frag_size(&si->frags[i]),
 			       PCI_DMA_TODEVICE);
+		_DEC(1);
+	}
 }
 
 static void setup_deferred_unmapping(struct sk_buff *skb, struct pci_dev *pdev,
@@ -2143,11 +2180,13 @@ static void lro_add_page(struct adapter *adap, struct sge_qset *qs,
 
 	(*sd->pg_chunk.p_cnt)--;
 	if (!*sd->pg_chunk.p_cnt && sd->pg_chunk.page != fl->pg_chunk.page)
+	{
 		pci_unmap_page(adap->pdev,
 			       sd->pg_chunk.mapping,
 			       fl->alloc_size,
 			       PCI_DMA_FROMDEVICE);
-
+		_DEC(1);
+	}
 	if (!skb) {
 		put_page(sd->pg_chunk.page);
 		if (complete)

--------------060508070806080405000502--
