From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Subject: Re: [PATCH 2/2] benet: fix the misusage of zero dma address
Date: Mon, 5 Apr 2010 16:40:18 +0900
Message-ID: <20100405163942P.fujita.tomonori@lab.ntt.co.jp>
References: <1270176803-8561-1-git-send-email-fujita.tomonori@lab.ntt.co.jp>
	<1270176803-8561-2-git-send-email-fujita.tomonori@lab.ntt.co.jp>
	<20100405071059.GA32671@serverengines.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fujita.tomonori@lab.ntt.co.jp, subbus@serverengines.com,
	sarveshwarb@serverengines.com, ajitk@serverengines.com,
	netdev@vger.kernel.org
To: sathyap@serverengines.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from sh.osrg.net ([192.16.179.4]:38848 "EHLO sh.osrg.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750994Ab0DEHkY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Apr 2010 03:40:24 -0400
In-Reply-To: <20100405071059.GA32671@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 5 Apr 2010 12:40:59 +0530
Sathya Perla <sathyap@serverengines.com> wrote:

> Hi Fujita, thanks for the patch; pls see below:
> 
> On 02/04/10 11:53 +0900, FUJITA Tomonori wrote:
> > benet driver wrongly assumes that zero is an invalid dma address
> > (calls dma_unmap_page for only non zero dma addresses). Zero is a
> > valid dma address on some architectures. The dma length can be used
> > here.
> > 
> > Signed-off-by: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
> > ---
> >  drivers/net/benet/be_main.c |    6 ++++--
> >  1 files changed, 4 insertions(+), 2 deletions(-)
> > 
> > diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
> > index 8d5e27b..8828c7d 100644
> > --- a/drivers/net/benet/be_main.c
> > +++ b/drivers/net/benet/be_main.c
> > @@ -394,13 +394,15 @@ static void unmap_tx_frag(struct pci_dev *pdev, struct be_eth_wrb *wrb,
> >  	be_dws_le_to_cpu(wrb, sizeof(*wrb));
> >  
> >  	dma = (u64)wrb->frag_pa_hi << 32 | (u64)wrb->frag_pa_lo;
> > -	if (dma != 0) {
> > +	if (wrb->frag_len) {
> >  		if (unmap_single)
> >  			pci_unmap_single(pdev, dma, wrb->frag_len,
> >  				PCI_DMA_TODEVICE);
> >  		else
> >  			pci_unmap_page(pdev, dma, wrb->frag_len,
> >  				PCI_DMA_TODEVICE);
> > +
> > +		wrb->frag_len = 0;
> Why does wrb->frag_len need to be reset here?
> In the TX path, it is set to the proper value for data wrbs and zero
> for dummy and hdr wrbs.

I guess that I misunderstood why unmap_tx_frag() checks a dma address.
The checking is necessary to avoid calling pci_unamp_* API for dummy
hdr wrbs?

Anyway, if wrb->frag_len doesn't need to be reset here, the following
patch is ok?

=
From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Subject: [PATCH v2 2/2] benet: fix the misusage of zero dma address

benet driver wrongly assumes that zero is an invalid dma address
(calls dma_unmap_page for only non zero dma addresses). Zero is a
valid dma address on some architectures. The dma length can be used
here.

Signed-off-by: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
---
 drivers/net/benet/be_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index a27a0a1..c95e1a2 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -404,7 +404,7 @@ static void unmap_tx_frag(struct pci_dev *pdev, struct be_eth_wrb *wrb,
 	be_dws_le_to_cpu(wrb, sizeof(*wrb));
 
 	dma = (u64)wrb->frag_pa_hi << 32 | (u64)wrb->frag_pa_lo;
-	if (dma != 0) {
+	if (wrb->frag_len) {
 		if (unmap_single)
 			pci_unmap_single(pdev, dma, wrb->frag_len,
 				PCI_DMA_TODEVICE);
-- 
1.7.0


