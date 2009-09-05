From: Roel Kluin <roel.kluin@gmail.com>
Subject: Re: [PATCH] atm: dereference of he_dev->rbps_virt in he_init_group()
Date: Sat, 05 Sep 2009 14:35:18 +0200
Message-ID: <4AA25B06.2090703@gmail.com>
References: <4A9979CC.2090905@gmail.com>	<4A997A78.9080309@gmail.com> <20090902.232548.238393942.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: chas@cmf.nrl.navy.mil, linux-atm-general@lists.sourceforge.net,
	netdev@vger.kernel.org, akpm@linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f206.google.com ([209.85.219.206]:52703 "EHLO
	mail-ew0-f206.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753161AbZIEM3O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Sep 2009 08:29:14 -0400
Received: by ewy2 with SMTP id 2so1065786ewy.17
        for <netdev@vger.kernel.org>; Sat, 05 Sep 2009 05:29:16 -0700 (PDT)
In-Reply-To: <20090902.232548.238393942.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

he_dev->rbps_virt or he_dev->rbpl_virt allocation may fail, so check
them. Make sure that he_init_group() cleans up after errors.

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
> These new return statements will both leak resources allocated
> earlier.
> 
> All the caller is going to do is return -ENOMEM as well and
> it does not cleanup actions at all.
> 
> Please fix this up.

I am new to this api, so please review.

diff --git a/drivers/atm/he.c b/drivers/atm/he.c
index 2de6406..1d873cb 100644
--- a/drivers/atm/he.c
+++ b/drivers/atm/he.c
@@ -777,7 +777,7 @@ he_init_cs_block_rcm(struct he_dev *he_dev)
 static int __devinit
 he_init_group(struct he_dev *he_dev, int group)
 {
-	int i;
+	int i, ret;
 
 	/* small buffer pool */
 	he_dev->rbps_pool = pci_pool_create("rbps", he_dev->pci_dev,
@@ -790,19 +790,27 @@ he_init_group(struct he_dev *he_dev, int group)
 	he_dev->rbps_base = pci_alloc_consistent(he_dev->pci_dev,
 		CONFIG_RBPS_SIZE * sizeof(struct he_rbp), &he_dev->rbps_phys);
 	if (he_dev->rbps_base == NULL) {
-		hprintk("failed to alloc rbps\n");
-		return -ENOMEM;
+		hprintk("failed to alloc rbps_base\n");
+		ret = -ENOMEM;
+		goto out_destroy_rbps_pool;
 	}
 	memset(he_dev->rbps_base, 0, CONFIG_RBPS_SIZE * sizeof(struct he_rbp));
 	he_dev->rbps_virt = kmalloc(CONFIG_RBPS_SIZE * sizeof(struct he_virt), GFP_KERNEL);
+	if (he_dev->rbps_virt == NULL) {
+		hprintk("failed to alloc rbps_virt\n");
+		ret = -ENOMEM;
+		goto out_free_rbps_base;
+	}
 
 	for (i = 0; i < CONFIG_RBPS_SIZE; ++i) {
 		dma_addr_t dma_handle;
 		void *cpuaddr;
 
 		cpuaddr = pci_pool_alloc(he_dev->rbps_pool, GFP_KERNEL|GFP_DMA, &dma_handle);
-		if (cpuaddr == NULL)
-			return -ENOMEM;
+		if (cpuaddr == NULL) {
+			ret = -ENOMEM;
+			goto out_free_rbps_virt;
+		}
 
 		he_dev->rbps_virt[i].virt = cpuaddr;
 		he_dev->rbps_base[i].status = RBP_LOANED | RBP_SMALLBUF | (i << RBP_INDEX_OFF);
@@ -827,25 +835,34 @@ he_init_group(struct he_dev *he_dev, int group)
 			CONFIG_RBPL_BUFSIZE, 8, 0);
 	if (he_dev->rbpl_pool == NULL) {
 		hprintk("unable to create rbpl pool\n");
-		return -ENOMEM;
+		ret = -ENOMEM;
+		goto out_free_rbps_virt;
 	}
 
 	he_dev->rbpl_base = pci_alloc_consistent(he_dev->pci_dev,
 		CONFIG_RBPL_SIZE * sizeof(struct he_rbp), &he_dev->rbpl_phys);
 	if (he_dev->rbpl_base == NULL) {
-		hprintk("failed to alloc rbpl\n");
-		return -ENOMEM;
+		hprintk("failed to alloc rbpl_base\n");
+		ret = -ENOMEM;
+		goto out_destroy_rbpl_pool;
 	}
 	memset(he_dev->rbpl_base, 0, CONFIG_RBPL_SIZE * sizeof(struct he_rbp));
 	he_dev->rbpl_virt = kmalloc(CONFIG_RBPL_SIZE * sizeof(struct he_virt), GFP_KERNEL);
+	if (he_dev->rbpl_virt == NULL) {
+		hprintk("failed to alloc rbpl_virt\n");
+		ret = -ENOMEM;
+		goto out_free_rbpl_base;
+	}
 
 	for (i = 0; i < CONFIG_RBPL_SIZE; ++i) {
 		dma_addr_t dma_handle;
 		void *cpuaddr;
 
 		cpuaddr = pci_pool_alloc(he_dev->rbpl_pool, GFP_KERNEL|GFP_DMA, &dma_handle);
-		if (cpuaddr == NULL)
-			return -ENOMEM;
+		if (cpuaddr == NULL) {
+			ret = -ENOMEM;
+			goto out_free_rbpl_virt;
+		}
 
 		he_dev->rbpl_virt[i].virt = cpuaddr;
 		he_dev->rbpl_base[i].status = RBP_LOANED | (i << RBP_INDEX_OFF);
@@ -870,7 +887,8 @@ he_init_group(struct he_dev *he_dev, int group)
 		CONFIG_RBRQ_SIZE * sizeof(struct he_rbrq), &he_dev->rbrq_phys);
 	if (he_dev->rbrq_base == NULL) {
 		hprintk("failed to allocate rbrq\n");
-		return -ENOMEM;
+		ret = -ENOMEM;
+		goto out_free_rbpl_virt;
 	}
 	memset(he_dev->rbrq_base, 0, CONFIG_RBRQ_SIZE * sizeof(struct he_rbrq));
 
@@ -894,7 +912,8 @@ he_init_group(struct he_dev *he_dev, int group)
 		CONFIG_TBRQ_SIZE * sizeof(struct he_tbrq), &he_dev->tbrq_phys);
 	if (he_dev->tbrq_base == NULL) {
 		hprintk("failed to allocate tbrq\n");
-		return -ENOMEM;
+		ret = -ENOMEM;
+		goto out_free_rbpq_base;
 	}
 	memset(he_dev->tbrq_base, 0, CONFIG_TBRQ_SIZE * sizeof(struct he_tbrq));
 
@@ -906,6 +925,34 @@ he_init_group(struct he_dev *he_dev, int group)
 	he_writel(he_dev, CONFIG_TBRQ_THRESH, G0_TBRQ_THRESH + (group * 16));
 
 	return 0;
+
+out_free_rbpq_base:
+	pci_free_consistent(he_dev->pci_dev, CONFIG_RBRQ_SIZE * sizeof(struct he_rbrq),
+			he_dev->rbrq_base, he_dev->rbrq_phys);
+	i = CONFIG_RBPL_SIZE;
+out_free_rbpl_virt:
+	while (--i)
+		pci_pool_free(he_dev->rbpl_virt[i].virt);
+	kfree(he_dev->rbpl_virt);
+
+out_free_rbpl_base:
+	pci_free_consistent(he_dev->pci_dev, CONFIG_RBPL_SIZE * sizeof(struct he_rbp),
+			he_dev->rbpl_base, he_dev->rbpl_phys);
+out_destroy_rbpl_pool:
+	pci_pool_destroy(he_dev->rbpl_pool);
+
+	i = CONFIG_RBPL_SIZE;
+out_free_rbps_virt:
+	while (--i)
+		pci_pool_free(he_dev->rbps_virt[i].virt);
+	kfree(he_dev->rbps_virt);
+
+out_free_rbps_base:
+	pci_free_consistent(he_dev->pci_dev, CONFIG_RBPS_SIZE * sizeof(struct he_rbp),
+			he_dev->rbps_base, he_dev->rbps_phys);
+out_destroy_rbps_pool:
+	pci_pool_destroy(he_dev->rbps_pool);
+	return ret;
 }
 
 static int __devinit
