From: Roger Oksanen <roger.oksanen@cs.helsinki.fi>
Subject: Re: e100 REGRESSION in 2.6.32 (PATCH)
Date: Thu, 17 Dec 2009 14:14:16 +0200
Message-ID: <200912171414.16846.roger.oksanen@cs.helsinki.fi>
References: <Pine.LNX.4.44L0.0912161447260.2643-100000@iolanthe.rowland.org>
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
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Roger Oksanen <roger.oksanen@cs.helsinki.fi>
To: Alan Stern <stern@rowland.harvard.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:46557 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753424AbZLQMPE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2009 07:15:04 -0500
In-Reply-To: <Pine.LNX.4.44L0.0912161447260.2643-100000@iolanthe.rowland.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 16 December 2009 21:50:38 Alan Stern wrote:
> On Wed, 16 Dec 2009, Brandeburg, Jesse wrote:
> 
> > copied the netdev mailing list.
> 
> Oops.  With all the other CC's I forgot to include netdev.  Shame, 
> shame...
> 
> >  Alan thanks for the report, I wonder if 
> > you can revert 98468efddb101f8a29af974101c17ba513b07be1 and see if that 
> > fixes it?
> 
> It does indeed.  Thanks for the quick response.
> 
> > Roger on the To: line made that change, which may have broken e100 for 
> > your system.
> 
> It looks simple enough, but obviously something is wrong with it.

Well it took a while, and it seems that I had missed the undocumented(?) fact
that pci_alloc_consistent returns zeroed memory (and pci_pool doesn't), and 
the alloc_cbs doesn't explicitly zero the cb->status field when allocating. So
here is a patch against v2.6.32:
(David: 98468efddb101f8a29af974101c17ba513b07be1 should be removed from
the -stable queue and replaced by a patch that includes this fix)

e100: Fix broken cbs accounting due to missing memset.

Alan Stern noticed that e100 caused slab corruption.
commit 98468efddb101f8a29af974101c17ba513b07be1 changed
the allocation of cbs to use dma pools that don't return zeroed memory,
especially the cb->status field used to track which cb to clean, causing
(the visible) double freeing of skbs and a wrong free cbs count.

Now the cbs are explicitly zeroed at allocation time.

Reported-by: Alan Stern <stern@rowland.harvard.edu>
Signed-off-by: Roger Oksanen <roger.oksanen@cs.helsinki.fi>
---
 drivers/net/e100.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/e100.c b/drivers/net/e100.c
index d269a68..29a8840 100644
--- a/drivers/net/e100.c
+++ b/drivers/net/e100.c
@@ -1815,6 +1815,7 @@ static int e100_alloc_cbs(struct nic *nic)
 
 	nic->cbs = pci_pool_alloc(nic->cbs_pool, GFP_KERNEL,
 				  &nic->cbs_dma_addr);
+	memset(nic->cbs, 0, count * sizeof(struct cb));
 	if (!nic->cbs)
 		return -ENOMEM;
 
@@ -1825,7 +1826,6 @@ static int e100_alloc_cbs(struct nic *nic)
 		cb->dma_addr = nic->cbs_dma_addr + i * sizeof(struct cb);
 		cb->link = cpu_to_le32(nic->cbs_dma_addr +
 			((i+1) % count) * sizeof(struct cb));
-		cb->skb = NULL;
 	}
 
 	nic->cb_to_use = nic->cb_to_send = nic->cb_to_clean = nic->cbs;
