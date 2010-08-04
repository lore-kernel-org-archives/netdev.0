From: Denis Kirjanov <dkirjanov@kernel.org>
Subject: [PATCH -staging] slicoss: Remove explicit arch dependencies
Date: Wed, 4 Aug 2010 19:24:08 +0000
Message-ID: <20100804192408.GA11385@hera.kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: greg@kroah.com, liodot@gmail.com, dkirjanov@kernel.org,
	charrer@alacritech.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org
To: gregkh@suse.de
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove explicit arch dependencies

Signed-off-by: Denis Kirjanov <dkirjanov@kernel.org>
---
diff --git a/drivers/staging/slicoss/slic.h b/drivers/staging/slicoss/slic.h
index beab400..ebdcc6f 100644
--- a/drivers/staging/slicoss/slic.h
+++ b/drivers/staging/slicoss/slic.h
@@ -515,14 +515,16 @@ struct adapter {
     (largestat) += ((newstat) - (oldstat));                              \
 }
 
-#if defined(CONFIG_X86_64) || defined(CONFIG_IA64)
+#if BITS_PER_LONG == 64
 #define   SLIC_GET_ADDR_LOW(_addr)  (u32)((u64)(_addr) & \
 	0x00000000FFFFFFFF)
 #define   SLIC_GET_ADDR_HIGH(_addr)  (u32)(((u64)(_addr) >> 32) & \
 	0x00000000FFFFFFFF)
-#else
-#define   SLIC_GET_ADDR_LOW(_addr)   (u32)_addr
+#elif BITS_PER_LONG == 32
+#define   SLIC_GET_ADDR_LOW(_addr)   (u32)(_addr)
 #define   SLIC_GET_ADDR_HIGH(_addr)  (u32)0
+#else
+#error BITS_PER_LONG must be 32 or 64
 #endif
 
 #define FLUSH		true
diff --git a/drivers/staging/slicoss/slicoss.c b/drivers/staging/slicoss/slicoss.c
index f8c4b12..58ff123 100644
--- a/drivers/staging/slicoss/slicoss.c
+++ b/drivers/staging/slicoss/slicoss.c
@@ -1099,19 +1099,17 @@ static void slic_link_upr_complete(struct adapter *adapter, u32 isr)
 		struct slic_shmem *pshmem;
 
 		pshmem = (struct slic_shmem *)adapter->phys_shmem;
-#if defined(CONFIG_X86_64)
+#if BITS_PER_LONG == 64
 		slic_upr_queue_request(adapter,
 				       SLIC_UPR_RLSR,
 				       SLIC_GET_ADDR_LOW(&pshmem->linkstatus),
 				       SLIC_GET_ADDR_HIGH(&pshmem->linkstatus),
 				       0, 0);
-#elif defined(CONFIG_X86)
+#else
 		slic_upr_queue_request(adapter,
 				       SLIC_UPR_RLSR,
 				       (u32) &pshmem->linkstatus,
 				       SLIC_GET_ADDR_HIGH(pshmem), 0, 0);
-#else
-		Stop Compilation;
 #endif
 		return;
 	}
@@ -1327,7 +1325,7 @@ static ushort slic_eeprom_cksum(char *m, int len)
 	s_util.s = 0;
 
 	w = (u16 *)m;
-#ifdef CONFIG_X86_64
+#if BITS_PER_LONG == 64
 	w_int = (u32) ((ulong) w & 0x00000000FFFFFFFF);
 #else
 	w_int = (u32) (w);
@@ -1439,12 +1437,16 @@ static int slic_rspqueue_init(struct adapter *adapter)
 			slic_rspqueue_free(adapter);
 			return -ENOMEM;
 		}
+		/* FIXME:
+		 * do we really need this assertions (4K PAGE_SIZE aligned addr)? */
+#if 0
 #ifndef CONFIG_X86_64
 		ASSERT(((u32) rspq->vaddr[i] & 0xFFFFF000) ==
 		       (u32) rspq->vaddr[i]);
 		ASSERT(((u32) rspq->paddr[i] & 0xFFFFF000) ==
 		       (u32) rspq->paddr[i]);
 #endif
+#endif
 		memset(rspq->vaddr[i], 0, PAGE_SIZE);
 
 		if (paddrh == 0) {
@@ -1473,13 +1475,13 @@ static struct slic_rspbuf *slic_rspqueue_getnext(struct adapter *adapter)
 		return NULL;
 
 	buf = rspq->rspbuf;
-#ifndef CONFIG_X86_64
+#if BITS_PER_LONG == 32
 	ASSERT((buf->status & 0xFFFFFFE0) == 0);
 #endif
 	ASSERT(buf->hosthandle);
 	if (++rspq->offset < SLIC_RSPQ_BUFSINPAGE) {
 		rspq->rspbuf++;
-#ifndef CONFIG_X86_64
+#if BITS_PER_LONG == 32
 		ASSERT(((u32) rspq->rspbuf & 0xFFFFFFE0) ==
 		       (u32) rspq->rspbuf);
 #endif
@@ -1492,12 +1494,12 @@ static struct slic_rspbuf *slic_rspqueue_getnext(struct adapter *adapter)
 		rspq->offset = 0;
 		rspq->rspbuf = (struct slic_rspbuf *)
 						rspq->vaddr[rspq->pageindex];
-#ifndef CONFIG_X86_64
+#if BITS_PER_LONG == 32
 		ASSERT(((u32) rspq->rspbuf & 0xFFFFF000) ==
 		       (u32) rspq->rspbuf);
 #endif
 	}
-#ifndef CONFIG_X86_64
+#if BITS_PER_LONG == 32
 	ASSERT(((u32) buf & 0xFFFFFFE0) == (u32) buf);
 #endif
 	return buf;
@@ -1538,7 +1540,7 @@ static u32 *slic_cmdqmem_addpage(struct adapter *adapter)
 					&cmdqmem->dma_pages[cmdqmem->pagecnt]);
 	if (!pageaddr)
 		return NULL;
-#ifndef CONFIG_X86_64
+#if BITS_PER_LONG == 32
 	ASSERT(((u32) pageaddr & 0xFFFFF000) == (u32) pageaddr);
 #endif
 	cmdqmem->pages[cmdqmem->pagecnt] = pageaddr;
@@ -1650,7 +1652,7 @@ static int slic_cmdq_init(struct adapter *adapter)
 	adapter->slic_handle_ix = 1;
 	for (i = 0; i < SLIC_CMDQ_INITPAGES; i++) {
 		pageaddr = slic_cmdqmem_addpage(adapter);
-#ifndef CONFIG_X86_64
+#if BITS_PER_LONG == 32
 		ASSERT(((u32) pageaddr & 0xFFFFF000) == (u32) pageaddr);
 #endif
 		if (!pageaddr) {
@@ -2447,18 +2449,16 @@ static void slic_link_event_handler(struct adapter *adapter)
 
 	pshmem = (struct slic_shmem *)adapter->phys_shmem;
 
-#if defined(CONFIG_X86_64)
+#if BITS_PER_LONG == 64
 	status = slic_upr_request(adapter,
 				  SLIC_UPR_RLSR,
 				  SLIC_GET_ADDR_LOW(&pshmem->linkstatus),
 				  SLIC_GET_ADDR_HIGH(&pshmem->linkstatus),
 				  0, 0);
-#elif defined(CONFIG_X86)
+#else
 	status = slic_upr_request(adapter, SLIC_UPR_RLSR,
 		(u32) &pshmem->linkstatus,	/* no 4GB wrap guaranteed */
 				  0, 0, 0);
-#else
-	Stop compilation;
 #endif
 	ASSERT(status == 0);
 }
@@ -2575,14 +2575,12 @@ static void slic_xmit_build_request(struct adapter *adapter,
 	ihcmd->u.slic_buffers.bufs[0].paddrl = SLIC_GET_ADDR_LOW(phys_addr);
 	ihcmd->u.slic_buffers.bufs[0].paddrh = SLIC_GET_ADDR_HIGH(phys_addr);
 	ihcmd->u.slic_buffers.bufs[0].length = skb->len;
-#if defined(CONFIG_X86_64)
+#if BITS_PER_LONG == 64
 	hcmd->cmdsize = (u32) ((((u64)&ihcmd->u.slic_buffers.bufs[1] -
 				     (u64) hcmd) + 31) >> 5);
-#elif defined(CONFIG_X86)
+#else
 	hcmd->cmdsize = ((((u32) &ihcmd->u.slic_buffers.bufs[1] -
 			   (u32) hcmd) + 31) >> 5);
-#else
-	Stop Compilation;
 #endif
 }
 
@@ -3078,16 +3076,14 @@ static int slic_if_init(struct adapter *adapter)
 		spin_lock_irqsave(&adapter->bit64reglock.lock,
 					adapter->bit64reglock.flags);
 
-#if defined(CONFIG_X86_64)
+#if BITS_PER_LONG == 64
 		slic_reg32_write(&slic_regs->slic_addr_upper,
 				 SLIC_GET_ADDR_HIGH(&pshmem->isr), DONT_FLUSH);
 		slic_reg32_write(&slic_regs->slic_isp,
 				 SLIC_GET_ADDR_LOW(&pshmem->isr), FLUSH);
-#elif defined(CONFIG_X86)
+#else
 		slic_reg32_write(&slic_regs->slic_addr_upper, 0, DONT_FLUSH);
 		slic_reg32_write(&slic_regs->slic_isp, (u32)&pshmem->isr, FLUSH);
-#else
-		Stop Compilations
 #endif
 		spin_unlock_irqrestore(&adapter->bit64reglock.lock,
 					adapter->bit64reglock.flags);
