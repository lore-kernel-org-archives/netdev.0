From: Al Viro <viro@ftp.linux.org.uk>
Subject: [PATCH] kill eth_io_copy_and_sum()
Date: Fri, 09 Feb 2007 16:38:30 +0000
Message-ID: <E1HFYla-0006m3-LP@ZenIV.linux.org.uk>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1946641AbXBIQie@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On all targets that sucker boils down to memcpy_fromio(sbk->data, from, len).
The function name is highly misguiding (it _never_ does any checksums), the
last argument is just a noise and simply expanding the call to memcpy_fromio()
gives shorter and more readable source.  For a lot of reasons it has almost
no remaining users, so it's better to just outright kill it.

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
 drivers/net/3c503.c              |    3 +--
 drivers/net/ac3200.c             |    3 +--
 drivers/net/e2100.c              |    3 +--
 drivers/net/es3210.c             |    2 +-
 drivers/net/smc-mca.c            |    3 +--
 drivers/net/smc-ultra.c          |    3 +--
 drivers/net/smc-ultra32.c        |    3 +--
 drivers/net/wd.c                 |    2 +-
 include/asm-alpha/io.h           |    9 ---------
 include/asm-arm/arch-ixp4xx/io.h |    3 ---
 include/asm-arm/io.h             |    5 -----
 include/asm-cris/io.h            |    5 -----
 include/asm-i386/io.h            |    6 ------
 include/asm-mips/io.h            |    6 ------
 include/asm-parisc/io.h          |    9 ---------
 include/asm-ppc/io.h             |    2 --
 include/asm-x86_64/io.h          |    6 ------
 17 files changed, 8 insertions(+), 65 deletions(-)

diff --git a/drivers/net/3c503.c b/drivers/net/3c503.c
index 7e34c4f..bc7e906 100644
--- a/drivers/net/3c503.c
+++ b/drivers/net/3c503.c
@@ -600,8 +600,7 @@ el2_block_input(struct net_device *dev, int count, struct sk_buff *skb, int ring
 	    count -= semi_count;
 	    memcpy_fromio(skb->data + semi_count, base + ei_status.priv, count);
 	} else {
-		/* Packet is in one chunk -- we can copy + cksum. */
-		eth_io_copy_and_sum(skb, base + ring_offset, count, 0);
+		memcpy_fromio(skb->data, base + ring_offset, count);
 	}
 	return;
     }
diff --git a/drivers/net/ac3200.c b/drivers/net/ac3200.c
index c01f87f..644c408 100644
--- a/drivers/net/ac3200.c
+++ b/drivers/net/ac3200.c
@@ -327,8 +327,7 @@ static void ac_block_input(struct net_device *dev, int count, struct sk_buff *sk
 		memcpy_fromio(skb->data + semi_count,
 				ei_status.mem + TX_PAGES*256, count);
 	} else {
-		/* Packet is in one chunk -- we can copy + cksum. */
-		eth_io_copy_and_sum(skb, start, count, 0);
+		memcpy_fromio(skb->data, start, count);
 	}
 }
 
diff --git a/drivers/net/e2100.c b/drivers/net/e2100.c
index c62d9c6..b2b0a96 100644
--- a/drivers/net/e2100.c
+++ b/drivers/net/e2100.c
@@ -355,8 +355,7 @@ e21_block_input(struct net_device *dev, int count, struct sk_buff *skb, int ring
 
 	mem_on(ioaddr, shared_mem, (ring_offset>>8));
 
-	/* Packet is always in one chunk -- we can copy + cksum. */
-	eth_io_copy_and_sum(skb, ei_status.mem + (ring_offset & 0xff), count, 0);
+	memcpy_fromio(skb->data, ei_status.mem + (ring_offset & 0xff), count);
 
 	mem_off(ioaddr);
 }
diff --git a/drivers/net/es3210.c b/drivers/net/es3210.c
index 2d2ea94..822e5bf 100644
--- a/drivers/net/es3210.c
+++ b/drivers/net/es3210.c
@@ -375,7 +375,7 @@ static void es_block_input(struct net_device *dev, int count, struct sk_buff *sk
 		memcpy_fromio(skb->data + semi_count, ei_status.mem, count);
 	} else {
 		/* Packet is in one chunk. */
-		eth_io_copy_and_sum(skb, xfer_start, count, 0);
+		memcpy_fromio(skb->data, xfer_start, count);
 	}
 }
 
diff --git a/drivers/net/smc-mca.c b/drivers/net/smc-mca.c
index 7122932..ae1ae34 100644
--- a/drivers/net/smc-mca.c
+++ b/drivers/net/smc-mca.c
@@ -482,8 +482,7 @@ static void ultramca_block_input(struct net_device *dev, int count, struct sk_bu
 		count -= semi_count;
 		memcpy_fromio(skb->data + semi_count, ei_status.mem + TX_PAGES * 256, count);
 	} else {
-		/* Packet is in one chunk -- we can copy + cksum. */
-		eth_io_copy_and_sum(skb, xfer_start, count, 0);
+		memcpy_fromio(skb->data, xfer_start, count);
 	}
 
 }
diff --git a/drivers/net/smc-ultra.c b/drivers/net/smc-ultra.c
index d70bc97..a52b22d 100644
--- a/drivers/net/smc-ultra.c
+++ b/drivers/net/smc-ultra.c
@@ -454,8 +454,7 @@ ultra_block_input(struct net_device *dev, int count, struct sk_buff *skb, int ri
 		count -= semi_count;
 		memcpy_fromio(skb->data + semi_count, ei_status.mem + TX_PAGES * 256, count);
 	} else {
-		/* Packet is in one chunk -- we can copy + cksum. */
-		eth_io_copy_and_sum(skb, xfer_start, count, 0);
+		memcpy_fromio(skb->data, xfer_start, count);
 	}
 
 	outb(0x00, dev->base_addr - ULTRA_NIC_OFFSET);	/* Disable memory. */
diff --git a/drivers/net/smc-ultra32.c b/drivers/net/smc-ultra32.c
index 2c5319c..88a30e5 100644
--- a/drivers/net/smc-ultra32.c
+++ b/drivers/net/smc-ultra32.c
@@ -395,8 +395,7 @@ static void ultra32_block_input(struct net_device *dev,
 			memcpy_fromio(skb->data + semi_count, ei_status.mem + TX_PAGES * 256, count);
 		}
 	} else {
-		/* Packet is in one chunk -- we can copy + cksum. */
-		eth_io_copy_and_sum(skb, xfer_start, count, 0);
+		memcpy_fromio(skb->data, xfer_start, count);
 	}
 }
 
diff --git a/drivers/net/wd.c b/drivers/net/wd.c
index 7f38012..a032681 100644
--- a/drivers/net/wd.c
+++ b/drivers/net/wd.c
@@ -433,7 +433,7 @@ wd_block_input(struct net_device *dev, int count, struct sk_buff *skb, int ring_
 		memcpy_fromio(skb->data + semi_count, ei_status.mem + TX_PAGES * 256, count);
 	} else {
 		/* Packet is in one chunk -- we can copy + cksum. */
-		eth_io_copy_and_sum(skb, xfer_start, count, 0);
+		memcpy_fromio(skb->data, xfer_start, count);
 	}
 
 	/* Turn off 16 bit access so that reboot works.	 ISA brain-damage */
diff --git a/include/asm-alpha/io.h b/include/asm-alpha/io.h
index 5d15af2..24bdcc8 100644
--- a/include/asm-alpha/io.h
+++ b/include/asm-alpha/io.h
@@ -525,15 +525,6 @@ extern void outsw (unsigned long port, const void *src, unsigned long count);
 extern void outsl (unsigned long port, const void *src, unsigned long count);
 
 /*
- * XXX - We don't have csum_partial_copy_fromio() yet, so we cheat here and 
- * just copy it. The net code will then do the checksum later. Presently 
- * only used by some shared memory 8390 Ethernet cards anyway.
- */
-
-#define eth_io_copy_and_sum(skb,src,len,unused) \
-  memcpy_fromio((skb)->data,src,len)
-
-/*
  * The Alpha Jensen hardware for some rather strange reason puts
  * the RTC clock at 0x170 instead of 0x70. Probably due to some
  * misguided idea about using 0x70 for NMI stuff.
diff --git a/include/asm-arm/arch-ixp4xx/io.h b/include/asm-arm/arch-ixp4xx/io.h
index 0d51726..b7b5414 100644
--- a/include/asm-arm/arch-ixp4xx/io.h
+++ b/include/asm-arm/arch-ixp4xx/io.h
@@ -238,9 +238,6 @@ __ixp4xx_readsl(const volatile void __iomem *bus_addr, u32 *vaddr, u32 count)
 #define memcpy_fromio(a,c,l)		_memcpy_fromio((a),(c),(l))
 #define memcpy_toio(c,a,l)		_memcpy_toio((c),(a),(l))
 
-#define eth_io_copy_and_sum(s,c,l,b) \
-				eth_copy_and_sum((s),__mem_pci(c),(l),(b))
-
 static inline int
 check_signature(const unsigned char __iomem *bus_addr, const unsigned char *signature,
 		int length)
diff --git a/include/asm-arm/io.h b/include/asm-arm/io.h
index 288f76b..5f60b42 100644
--- a/include/asm-arm/io.h
+++ b/include/asm-arm/io.h
@@ -182,9 +182,6 @@ extern void _memset_io(volatile void __iomem *, int, size_t);
 #define memcpy_fromio(a,c,l)	_memcpy_fromio((a),__mem_pci(c),(l))
 #define memcpy_toio(c,a,l)	_memcpy_toio(__mem_pci(c),(a),(l))
 
-#define eth_io_copy_and_sum(s,c,l,b) \
-				eth_copy_and_sum((s),__mem_pci(c),(l),(b))
-
 #elif !defined(readb)
 
 #define readb(c)			(__readwrite_bug("readb"),0)
@@ -194,8 +191,6 @@ extern void _memset_io(volatile void __iomem *, int, size_t);
 #define writew(v,c)			__readwrite_bug("writew")
 #define writel(v,c)			__readwrite_bug("writel")
 
-#define eth_io_copy_and_sum(s,c,l,b)	__readwrite_bug("eth_io_copy_and_sum")
-
 #define check_signature(io,sig,len)	(0)
 
 #endif	/* __mem_pci */
diff --git a/include/asm-cris/io.h b/include/asm-cris/io.h
index 716c69b..d196dd6 100644
--- a/include/asm-cris/io.h
+++ b/include/asm-cris/io.h
@@ -121,11 +121,6 @@ static inline void writel(unsigned int b, volatile void __iomem *addr)
 #define memcpy_fromio(a,b,c)	memcpy((a),(void *)(b),(c))
 #define memcpy_toio(a,b,c)	memcpy((void *)(a),(b),(c))
 
-/*
- * Again, CRIS does not require mem IO specific function.
- */
-
-#define eth_io_copy_and_sum(a,b,c,d)	eth_copy_and_sum((a),(void __force *)(b),(c),(d))
 
 /* The following is junk needed for the arch-independent code but which
  * we never use in the CRIS port
diff --git a/include/asm-i386/io.h b/include/asm-i386/io.h
index 86ff5e8..59fe616 100644
--- a/include/asm-i386/io.h
+++ b/include/asm-i386/io.h
@@ -219,12 +219,6 @@ static inline void memcpy_toio(volatile void __iomem *dst, const void *src, int
 #define __ISA_IO_base ((char __iomem *)(PAGE_OFFSET))
 
 /*
- * Again, i386 does not require mem IO specific function.
- */
-
-#define eth_io_copy_and_sum(a,b,c,d)		eth_copy_and_sum((a),(void __force *)(b),(c),(d))
-
-/*
  *	Cache management
  *
  *	This needed for two cases
diff --git a/include/asm-mips/io.h b/include/asm-mips/io.h
index 67f0810..b6a2eb8 100644
--- a/include/asm-mips/io.h
+++ b/include/asm-mips/io.h
@@ -556,12 +556,6 @@ extern void pci_iounmap(struct pci_dev *dev, void __iomem *);
 #define __ISA_IO_base ((char *)(isa_slot_offset))
 
 /*
- * We don't have csum_partial_copy_fromio() yet, so we cheat here and
- * just copy it. The net code will then do the checksum later.
- */
-#define eth_io_copy_and_sum(skb,src,len,unused) memcpy_fromio((skb)->data,(src),(len))
-
-/*
  * The caches on some architectures aren't dma-coherent and have need to
  * handle this in software.  There are three types of operations that
  * can be applied to dma buffers.
diff --git a/include/asm-parisc/io.h b/include/asm-parisc/io.h
index c1963ce..ca46e7c 100644
--- a/include/asm-parisc/io.h
+++ b/include/asm-parisc/io.h
@@ -191,15 +191,6 @@ void memset_io(volatile void __iomem *addr, unsigned char val, int count);
 void memcpy_fromio(void *dst, const volatile void __iomem *src, int count);
 void memcpy_toio(volatile void __iomem *dst, const void *src, int count);
 
-/*
- * XXX - We don't have csum_partial_copy_fromio() yet, so we cheat here and 
- * just copy it. The net code will then do the checksum later. Presently 
- * only used by some shared memory 8390 Ethernet cards anyway.
- */
-
-#define eth_io_copy_and_sum(skb,src,len,unused) \
-  memcpy_fromio((skb)->data,(src),(len))
-
 /* Port-space IO */
 
 #define inb_p inb
diff --git a/include/asm-ppc/io.h b/include/asm-ppc/io.h
index ccf1a9b..95d5904 100644
--- a/include/asm-ppc/io.h
+++ b/include/asm-ppc/io.h
@@ -358,8 +358,6 @@ static inline void memcpy_toio(volatile void __iomem *dst, const void *src, int
 }
 #endif
 
-#define eth_io_copy_and_sum(a,b,c,d)		eth_copy_and_sum((a),(void __force *)(void __iomem *)(b),(c),(d))
-
 /*
  * Map in an area of physical address space, for accessing
  * I/O devices etc.
diff --git a/include/asm-x86_64/io.h b/include/asm-x86_64/io.h
index 6ee9fad..f5d84bb 100644
--- a/include/asm-x86_64/io.h
+++ b/include/asm-x86_64/io.h
@@ -248,12 +248,6 @@ void memset_io(volatile void __iomem *a, int b, size_t c);
  */
 #define __ISA_IO_base ((char __iomem *)(PAGE_OFFSET))
 
-/*
- * Again, x86-64 does not require mem IO specific function.
- */
-
-#define eth_io_copy_and_sum(a,b,c,d)		eth_copy_and_sum((a),(void *)(b),(c),(d))
-
 /* Nothing to do */
 
 #define dma_cache_inv(_start,_size)		do { } while (0)
-- 
1.5.0-rc2.GIT
