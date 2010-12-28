From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH net-2.6] starfire: Replace broken preprocessor test for
 dma_addr_t size
Date: Tue, 28 Dec 2010 04:19:49 +0000
Message-ID: <1293509989.2928.99.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: Ion Badulescu <ionut@badula.org>,
	Akinobu Mita <akinobu.mita@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:51708 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753244Ab0L1EUA convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Dec 2010 23:20:00 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 56543af "starfire: use BUILD_BUG_ON for netdrv_addr_t" revealed
that the preprocessor condition used to find the size of dma_addr_t
yielded the wrong result for some architectures and configurations.
This was kluged for 64-bit PowerPC in commit 3e502e6 by adding yet
another case to the condition.  However, some MIPS configurations are
still handled incorrectly.

Replace the preprocessor test with expressions using ?: or
__builtin_choose_expr() as necessary.

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
This is compile-tested only.

The build failure on MIPS can be seen at
<https://buildd.debian.org/fetch.cgi?pkg=linux-2.6;ver=2.6.37~rc7-1~experimental.1;arch=mips;stamp=1293414847>.

Ben.

 drivers/net/starfire.c |   59 +++++++++++++++++++----------------------------
 1 files changed, 24 insertions(+), 35 deletions(-)

diff --git a/drivers/net/starfire.c b/drivers/net/starfire.c
index 4adf124..ea789d6 100644
--- a/drivers/net/starfire.c
+++ b/drivers/net/starfire.c
@@ -144,31 +144,22 @@ static int full_duplex[MAX_UNITS] = {0, };
 /* Time in jiffies before concluding the transmitter is hung. */
 #define TX_TIMEOUT	(2 * HZ)
 
-/*
- * This SUCKS.
- * We need a much better method to determine if dma_addr_t is 64-bit.
- */
-#if (defined(__i386__) && defined(CONFIG_HIGHMEM64G)) || defined(__x86_64__) || defined (__ia64__) || defined(__alpha__) || defined(__mips64__) || (defined(__mips__) && defined(CONFIG_HIGHMEM) && defined(CONFIG_64BIT_PHYS_ADDR)) || (defined(__powerpc64__) || defined(CONFIG_PHYS_64BIT))
-/* 64-bit dma_addr_t */
-#define ADDR_64BITS	/* This chip uses 64 bit addresses. */
-#define netdrv_addr_t __le64
-#define cpu_to_dma(x) cpu_to_le64(x)
-#define dma_to_cpu(x) le64_to_cpu(x)
-#define RX_DESC_Q_ADDR_SIZE RxDescQAddr64bit
-#define TX_DESC_Q_ADDR_SIZE TxDescQAddr64bit
-#define RX_COMPL_Q_ADDR_SIZE RxComplQAddr64bit
-#define TX_COMPL_Q_ADDR_SIZE TxComplQAddr64bit
-#define RX_DESC_ADDR_SIZE RxDescAddr64bit
-#else  /* 32-bit dma_addr_t */
-#define netdrv_addr_t __le32
-#define cpu_to_dma(x) cpu_to_le32(x)
-#define dma_to_cpu(x) le32_to_cpu(x)
-#define RX_DESC_Q_ADDR_SIZE RxDescQAddr32bit
-#define TX_DESC_Q_ADDR_SIZE TxDescQAddr32bit
-#define RX_COMPL_Q_ADDR_SIZE RxComplQAddr32bit
-#define TX_COMPL_Q_ADDR_SIZE TxComplQAddr32bit
-#define RX_DESC_ADDR_SIZE RxDescAddr32bit
-#endif
+#define IS_ADDR_64BIT (sizeof(dma_addr_t) == 8)
+#define cpu_to_dma(x)							\
+	__builtin_choose_expr(IS_ADDR_64BIT, cpu_to_le64(x), cpu_to_le32(x))
+#define dma_to_cpu(x)							\
+	__builtin_choose_expr(IS_ADDR_64BIT, le64_to_cpu(x), le32_to_cpu(x))
+typedef typeof(cpu_to_dma(0)) netdrv_addr_t;
+#define RX_DESC_Q_ADDR_SIZE						\
+	(IS_ADDR_64BIT ? RxDescQAddr64bit : RxDescQAddr32bit)
+#define TX_DESC_Q_ADDR_SIZE						\
+	(IS_ADDR_64BIT ? TxDescQAddr64bit : TxDescQAddr32bit)
+#define RX_COMPL_Q_ADDR_SIZE						\
+	(IS_ADDR_64BIT ? RxComplQAddr64bit : RxComplQAddr32bit)
+#define TX_COMPL_Q_ADDR_SIZE						\
+	(IS_ADDR_64BIT ? TxComplQAddr64bit : TxComplQAddr32bit)
+#define RX_DESC_ADDR_SIZE						\
+	(IS_ADDR_64BIT ? RxDescAddr64bit : RxDescAddr32bit)
 
 #define skb_first_frag_len(skb)	skb_headlen(skb)
 #define skb_num_frags(skb) (skb_shinfo(skb)->nr_frags + 1)
@@ -512,13 +503,12 @@ struct starfire_tx_desc_2 {
 	__le64 addr;
 };
 
-#ifdef ADDR_64BITS
-typedef struct starfire_tx_desc_2 starfire_tx_desc;
-#define TX_DESC_TYPE TxDescType2
-#else  /* not ADDR_64BITS */
-typedef struct starfire_tx_desc_1 starfire_tx_desc;
-#define TX_DESC_TYPE TxDescType1
-#endif /* not ADDR_64BITS */
+extern struct starfire_tx_desc_1 starfire_tx_desc_1_dummy(void);
+extern struct starfire_tx_desc_2 starfire_tx_desc_2_dummy(void);
+typedef typeof(__builtin_choose_expr(IS_ADDR_64BIT, starfire_tx_desc_2_dummy(),
+				     starfire_tx_desc_1_dummy()))
+starfire_tx_desc;
+#define TX_DESC_TYPE (IS_ADDR_64BIT ? TxDescType2 : TxDescType1)
 #define TX_DESC_SPACING TxDescSpaceUnlim
 
 enum tx_desc_bits {
@@ -731,9 +721,8 @@ static int __devinit starfire_init_one(struct pci_dev *pdev,
 #ifdef VLAN_SUPPORT
 	dev->features |= NETIF_F_HW_VLAN_RX | NETIF_F_HW_VLAN_FILTER;
 #endif /* VLAN_RX_KILL_VID */
-#ifdef ADDR_64BITS
-	dev->features |= NETIF_F_HIGHDMA;
-#endif /* ADDR_64BITS */
+	if (IS_ADDR_64BIT)
+		dev->features |= NETIF_F_HIGHDMA;
 
 	/* Serial EEPROM reads are hidden by the hardware. */
 	for (i = 0; i < 6; i++)
-- 
1.7.2.3


