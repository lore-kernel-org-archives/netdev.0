From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] jme: Fix DMA unmap warning
Date: Tue, 6 May 2014 16:50:46 -0400
Message-ID: <20140506205046.GC2858@hmsreliant.think-freely.org>
References: <1399315907-27148-1-git-send-email-nhorman@tuxdriver.com>
 <alpine.LNX.2.03.1405070152550.22076@ws.cisco>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Guo-Fu Tseng <cooldavid@cooldavid.org>,
	"David S. Miller" <davem@davemloft.net>
To: Govindarajulu Varadarajan <_govind@gmx.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:57891 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753796AbaEFUuz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 May 2014 16:50:55 -0400
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.03.1405070152550.22076@ws.cisco>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 07, 2014 at 01:55:00AM +0530, Govindarajulu Varadarajan wrote:
> 
> 
> On Mon, 5 May 2014, Neil Horman wrote:
> 
> >The jme driver forgot to check the return status from pci_map_page in its tx
> >path, causing a dma api warning on unmap.  Easy fix, just do the check and
> >augment the tx path to tell the stack that the driver is busy so we re-queue the
> >frame.
> >
> >Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> >CC: Guo-Fu Tseng <cooldavid@cooldavid.org>
> >CC: "David S. Miller" <davem@davemloft.net>
> >---
> >drivers/net/ethernet/jme.c | 53 ++++++++++++++++++++++++++++++++++++++++------
> >1 file changed, 47 insertions(+), 6 deletions(-)
> >
> >diff --git a/drivers/net/ethernet/jme.c b/drivers/net/ethernet/jme.c
> >index b0c6050..6e664d9 100644
> >--- a/drivers/net/ethernet/jme.c
> >+++ b/drivers/net/ethernet/jme.c
> >@@ -1988,7 +1988,7 @@ jme_alloc_txdesc(struct jme_adapter *jme,
> >	return idx;
> >}
> >
> >-static void
> >+static int
> >jme_fill_tx_map(struct pci_dev *pdev,
> >		struct txdesc *txdesc,
> >		struct jme_buffer_info *txbi,
> >@@ -2005,6 +2005,9 @@ jme_fill_tx_map(struct pci_dev *pdev,
> >				len,
> >				PCI_DMA_TODEVICE);
> >
> >+	if (unlikely(pci_dma_mapping_error(pdev, dmaaddr)))
> >+		return -EINVAL;
> >+
> >	pci_dma_sync_single_for_device(pdev,
> >				       dmaaddr,
> >				       len,
> >@@ -2021,9 +2024,30 @@ jme_fill_tx_map(struct pci_dev *pdev,
> >
> >	txbi->mapping = dmaaddr;
> >	txbi->len = len;
> >+	return 0;
> >}
> >
> >-static void
> >+static void jme_drop_tx_map(struct jme_adapter *jme, int startidx, int endidx)
> >+{
> >+	struct jme_ring *txring = &(jme->txring[0]);
> >+	struct jme_buffer_info *txbi = txring->bufinf, *ctxbi;
> >+	int mask = jme->tx_ring_mask;
> >+	int j;
> >+
> >+	for (j = startidx ; j < endidx ; ++j) {
> >+		ctxbi = txbi + ((startidx + j + 2) & (mask));
> >+		pci_unmap_page(jme->pdev,
> >+				ctxbi->mapping,
> >+				ctxbi->len,
> >+				PCI_DMA_TODEVICE);
> >+
> >+				ctxbi->mapping = 0;
> >+				ctxbi->len = 0;
> 
> Alignment, a tab from 'for'
Not sure what you mean by this, I don't see any alignment errors above, or in my
tree.  Checkpatch also claims its clean.

> >+	}
> >+
> >+}
> >+
> >+static int
> >jme_map_tx_skb(struct jme_adapter *jme, struct sk_buff *skb, int idx)
> >{
> >	struct jme_ring *txring = &(jme->txring[0]);
> >@@ -2034,25 +2058,37 @@ jme_map_tx_skb(struct jme_adapter *jme, struct sk_buff *skb, int idx)
> >	int mask = jme->tx_ring_mask;
> >	const struct skb_frag_struct *frag;
> >	u32 len;
> >+	int ret = 0;
> >
> >	for (i = 0 ; i < nr_frags ; ++i) {
> >		frag = &skb_shinfo(skb)->frags[i];
> >		ctxdesc = txdesc + ((idx + i + 2) & (mask));
> >		ctxbi = txbi + ((idx + i + 2) & (mask));
> >
> >-		jme_fill_tx_map(jme->pdev, ctxdesc, ctxbi,
> >+		ret = jme_fill_tx_map(jme->pdev, ctxdesc, ctxbi,
> >				skb_frag_page(frag),
> >				frag->page_offset, skb_frag_size(frag), hidma);
> >+		if (ret) {
> >+			jme_drop_tx_map(jme, idx, idx+i);
> >+			goto out;
> 
> Why not just return here, you are using out:, only once.
> 
Because thats in keeping with the coding style of the file, and the kernel at
large.  I could just return sure, but nominally thats only done at the head of a
function when its very clear no cleanup is needed.  This way, we keep a single
return point in the function.  Its done in several other places within this
driver already (see jme_check_link for an example)

Regards
Neil
