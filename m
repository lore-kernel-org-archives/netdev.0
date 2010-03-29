From: Sreenivasa Honnur <Sreenivasa.Honnur@neterion.com>
Subject: [net-next-2.6 PATCH 3/8] vxge: Align the memory only if it is
 misaligned.
Date: Mon, 29 Mar 2010 04:09:47 -0400 (EDT)
Message-ID: <Pine.GSO.4.10.11003290409080.4435-100000@guinness>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, support@neterion.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:48131 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753027Ab0C2IXW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Mar 2010 04:23:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- Align the memory only if it is misaligned.

Signed-off-by: Sreenivasa Honnur <sreenivasa.honnur@neterion.com>
Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>
---
diff -urpN patch2/drivers/net/vxge/vxge-config.h patch3/drivers/net/vxge/vxge-config.h
--- patch2/drivers/net/vxge/vxge-config.h	2010-03-19 16:08:43.000000000 +0530
+++ patch3/drivers/net/vxge/vxge-config.h	2010-03-22 12:15:04.000000000 +0530
@@ -1914,20 +1914,32 @@ static inline void *vxge_os_dma_malloc(s
 	gfp_t flags;
 	void *vaddr;
 	unsigned long misaligned = 0;
+	int realloc_flag = 0;
 	*p_dma_acch = *p_dmah = NULL;
 
 	if (in_interrupt())
 		flags = GFP_ATOMIC | GFP_DMA;
 	else
 		flags = GFP_KERNEL | GFP_DMA;
-
-	size += VXGE_CACHE_LINE_SIZE;
-
+realloc:
 	vaddr = kmalloc((size), flags);
 	if (vaddr == NULL)
 		return vaddr;
-	misaligned = (unsigned long)VXGE_ALIGN(*((u64 *)&vaddr),
+	misaligned = (unsigned long)VXGE_ALIGN((unsigned long)vaddr,
 				VXGE_CACHE_LINE_SIZE);
+	if (realloc_flag)
+		goto out;
+
+	if (misaligned) {
+		/* misaligned, free current one and try allocating
+		 * size + VXGE_CACHE_LINE_SIZE memory
+		 */
+		kfree((void *) vaddr);
+		size += VXGE_CACHE_LINE_SIZE;
+		realloc_flag = 1;
+		goto realloc;
+	}
+out:
 	*(unsigned long *)p_dma_acch = misaligned;
 	vaddr = (void *)((u8 *)vaddr + misaligned);
 	return vaddr;

