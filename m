From: David Miller <davem@davemloft.net>
Subject: Re: [Bug #14265] ifconfig: page allocation failure. order:5,
 mode:0x8020 w/ e100
Date: Mon, 12 Oct 2009 04:05:36 -0700 (PDT)
Message-ID: <20091012.040536.10656720.davem@davemloft.net>
References: <56acieJJ2fF.A.nEB.Hzl0KB@chimera>
	<L6tb-VyKHZK.A.YoC.lzl0KB@chimera>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel-testers@vger.kernel.org,
	karol.k.lewandowski@gmail.com, mel@csn.ul.ie,
	netdev@vger.kernel.org
To: rjw@sisk.pl
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756164AbZJLLFm@vger.kernel.org>
In-Reply-To: <L6tb-VyKHZK.A.YoC.lzl0KB@chimera>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Rafael J. Wysocki" <rjw@sisk.pl>
Date: Mon, 12 Oct 2009 01:01:08 +0200 (CEST)

[ Netdev CC:'d ]

> Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=14265
> Subject		: ifconfig: page allocation failure. order:5, mode:0x8020 w/ e100
> Submitter	: Karol Lewandowski <karol.k.lewandowski@gmail.com>
> Date		: 2009-09-15 12:05 (27 days old)
> References	: http://marc.info/?l=linux-kernel&m=125301636509517&w=4

A 128K memory allocation fails after resume, film at 11.

That e100 driver code has been that way forever, so likely it's
something in the page allocator or similar that is making this happen
more likely now.  Perhaps it's related to the iwlagn allocation
failures being tracked down in another thread.

It's a shame that pci_alloc_consistent() has to always use GFP_ATOMIC
for compatability.

As far as I can tell, these code paths can sleep.  So maybe the
following hack would fix this for now.  Could someone test this?

diff --git a/drivers/net/e100.c b/drivers/net/e100.c
index 679965c..c71729f 100644
--- a/drivers/net/e100.c
+++ b/drivers/net/e100.c
@@ -1780,9 +1780,9 @@ static void e100_clean_cbs(struct nic *nic)
 			nic->cb_to_clean = nic->cb_to_clean->next;
 			nic->cbs_avail++;
 		}
-		pci_free_consistent(nic->pdev,
-			sizeof(struct cb) * nic->params.cbs.count,
-			nic->cbs, nic->cbs_dma_addr);
+		dma_free_coherent(&nic->pdev->dev,
+				  sizeof(struct cb) * nic->params.cbs.count,
+				  nic->cbs, nic->cbs_dma_addr);
 		nic->cbs = NULL;
 		nic->cbs_avail = 0;
 	}
@@ -1800,8 +1800,10 @@ static int e100_alloc_cbs(struct nic *nic)
 	nic->cb_to_use = nic->cb_to_send = nic->cb_to_clean = NULL;
 	nic->cbs_avail = 0;
 
-	nic->cbs = pci_alloc_consistent(nic->pdev,
-		sizeof(struct cb) * count, &nic->cbs_dma_addr);
+	nic->cbs = dma_alloc_coherent(&nic->pdev->dev,
+				      sizeof(struct cb) * count,
+				      &nic->cbs_dma_addr,
+				      GFP_KERNEL);
 	if (!nic->cbs)
 		return -ENOMEM;
 
@@ -2655,16 +2657,16 @@ static int e100_do_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
 
 static int e100_alloc(struct nic *nic)
 {
-	nic->mem = pci_alloc_consistent(nic->pdev, sizeof(struct mem),
-		&nic->dma_addr);
+	nic->mem = dma_alloc_coherent(&nic->pdev->dev, sizeof(struct mem),
+				      &nic->dma_addr, GFP_KERNEL);
 	return nic->mem ? 0 : -ENOMEM;
 }
 
 static void e100_free(struct nic *nic)
 {
 	if (nic->mem) {
-		pci_free_consistent(nic->pdev, sizeof(struct mem),
-			nic->mem, nic->dma_addr);
+		dma_free_coherent(&nic->pdev->dev, sizeof(struct mem),
+				  nic->mem, nic->dma_addr);
 		nic->mem = NULL;
 	}
 }
