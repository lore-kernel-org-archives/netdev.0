From: Roger Oksanen <roger.oksanen@cs.helsinki.fi>
Subject: Re: e100 REGRESSION in 2.6.32 (PATCH v2)
Date: Thu, 17 Dec 2009 18:10:45 +0200
Message-ID: <200912171810.45575.roger.oksanen@cs.helsinki.fi>
References: <Pine.LNX.4.44L0.0912171046070.2645-100000@iolanthe.rowland.org>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	Kernel development list <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Alan Stern <stern@rowland.harvard.edu>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752555AbZLQQLg@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.44L0.0912171046070.2645-100000@iolanthe.rowland.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 17 December 2009 17:47:32 Alan Stern wrote:
> On Thu, 17 Dec 2009, Roger Oksanen wrote:
> 
> > e100: Fix broken cbs accounting due to missing memset.
> > 
> > Alan Stern noticed that e100 caused slab corruption.
> > commit 98468efddb101f8a29af974101c17ba513b07be1 changed
> > the allocation of cbs to use dma pools that don't return zeroed memory,
> > especially the cb->status field used to track which cb to clean, causing
> > (the visible) double freeing of skbs and a wrong free cbs count.
> > 
> > Now the cbs are explicitly zeroed at allocation time.
> > 
> > Reported-by: Alan Stern <stern@rowland.harvard.edu>
> > Signed-off-by: Roger Oksanen <roger.oksanen@cs.helsinki.fi>
> > ---
> >  drivers/net/e100.c |    2 +-
> >  1 files changed, 1 insertions(+), 1 deletions(-)
> > 
> > diff --git a/drivers/net/e100.c b/drivers/net/e100.c
> > index d269a68..29a8840 100644
> > --- a/drivers/net/e100.c
> > +++ b/drivers/net/e100.c
> > @@ -1815,6 +1815,7 @@ static int e100_alloc_cbs(struct nic *nic)
> >  
> >  	nic->cbs = pci_pool_alloc(nic->cbs_pool, GFP_KERNEL,
> >  				  &nic->cbs_dma_addr);
> > +	memset(nic->cbs, 0, count * sizeof(struct cb));
> >  	if (!nic->cbs)
> >  		return -ENOMEM;
> >  
> > @@ -1825,7 +1826,6 @@ static int e100_alloc_cbs(struct nic *nic)
> >  		cb->dma_addr = nic->cbs_dma_addr + i * sizeof(struct cb);
> >  		cb->link = cpu_to_le32(nic->cbs_dma_addr +
> >  			((i+1) % count) * sizeof(struct cb));
> > -		cb->skb = NULL;
> >  	}
> >  
> >  	nic->cb_to_use = nic->cb_to_send = nic->cb_to_clean = nic->cbs;
> 
> Clearly the memset() belongs after the "if" test, not before.  Apart 
> from that, I confirm that this patch fixes the problem in 2.6.32.

Silly me! Thanks for testing it. 
Here is the updated patch.

e100: Fix broken cbs accounting due to missing memset.

Alan Stern noticed that e100 caused slab corruption.
commit 98468efddb101f8a29af974101c17ba513b07be1 changed
the allocation of cbs to use dma pools that don't return zeroed memory,
especially the cb->status field used to track which cb to clean, causing
(the visible) double freeing of skbs and a wrong free cbs count.

Now the cbs are explicitly zeroed at allocation time.

Reported-by: Alan Stern <stern@rowland.harvard.edu>
Tested-by: Alan Stern <stern@rowland.harvard.edu>
Signed-off-by: Roger Oksanen <roger.oksanen@cs.helsinki.fi>
---
 drivers/net/e100.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/e100.c b/drivers/net/e100.c
index d269a68..0c53c92 100644
--- a/drivers/net/e100.c
+++ b/drivers/net/e100.c
@@ -1817,6 +1817,7 @@ static int e100_alloc_cbs(struct nic *nic)
 				  &nic->cbs_dma_addr);
 	if (!nic->cbs)
 		return -ENOMEM;
+	memset(nic->cbs, 0, count * sizeof(struct cb));
 
 	for (cb = nic->cbs, i = 0; i < count; cb++, i++) {
 		cb->next = (i + 1 < count) ? cb + 1 : nic->cbs;
@@ -1825,7 +1826,6 @@ static int e100_alloc_cbs(struct nic *nic)
 		cb->dma_addr = nic->cbs_dma_addr + i * sizeof(struct cb);
 		cb->link = cpu_to_le32(nic->cbs_dma_addr +
 			((i+1) % count) * sizeof(struct cb));
-		cb->skb = NULL;
 	}
 
 	nic->cb_to_use = nic->cb_to_send = nic->cb_to_clean = nic->cbs;
