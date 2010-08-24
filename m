From: Dimitris Michailidis <dm@chelsio.com>
Subject: [PATCH net-next 2/4] cxgb4: support eeprom read/write on functions other than 0
Date: Mon, 23 Aug 2010 20:20:59 -0700
Message-ID: <1282620061-32608-3-git-send-email-dm@chelsio.com>
References: <1282620061-32608-1-git-send-email-dm@chelsio.com>
 <1282620061-32608-2-git-send-email-dm@chelsio.com>
Cc: Dimitris Michailidis <dm@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:29851 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751993Ab0HXD2V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Aug 2010 23:28:21 -0400
Received: from maui.asicdesigners.com (maui.asicdesigners.com [10.192.180.15])
	by stargate.chelsio.com (8.13.1/8.13.1) with SMTP id o7O3SLM8022367
	for <netdev@vger.kernel.org>; Mon, 23 Aug 2010 20:28:21 -0700
In-Reply-To: <1282620061-32608-2-git-send-email-dm@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Extend the address translation for eeprom read/write (code used by
ethtool -[eE]) to functions other than 0.

Signed-off-by: Dimitris Michailidis <dm@chelsio.com>
---
 drivers/net/cxgb4/cxgb4_main.c |   40 +++++++++++++++++++++++++++++++---------
 drivers/net/cxgb4/t4_hw.h      |    1 +
 2 files changed, 32 insertions(+), 9 deletions(-)

diff --git a/drivers/net/cxgb4/cxgb4_main.c b/drivers/net/cxgb4/cxgb4_main.c
index 6e08e2d..cadf334 100644
--- a/drivers/net/cxgb4/cxgb4_main.c
+++ b/drivers/net/cxgb4/cxgb4_main.c
@@ -1681,27 +1681,41 @@ static int get_coalesce(struct net_device *dev, struct ethtool_coalesce *c)
 	return 0;
 }
 
-/*
- * Translate a physical EEPROM address to virtual.  The first 1K is accessed
- * through virtual addresses starting at 31K, the rest is accessed through
- * virtual addresses starting at 0.  This mapping is correct only for PF0.
+/**
+ *	eeprom_ptov - translate a physical EEPROM address to virtual
+ *	@phys_addr: the physical EEPROM address
+ *	@fn: the PCI function number
+ *	@sz: size of function-specific area
+ *
+ *	Translate a physical EEPROM address to virtual.  The first 1K is
+ *	accessed through virtual addresses starting at 31K, the rest is
+ *	accessed through virtual addresses starting at 0.
+ *
+ *	The mapping is as follows:
+ *	[0..1K) -> [31K..32K)
+ *	[1K..1K+A) -> [31K-A..31K)
+ *	[1K+A..ES) -> [0..ES-A-1K)
+ *
+ *	where A = @fn * @sz, and ES = EEPROM size.
  */
-static int eeprom_ptov(unsigned int phys_addr)
+static int eeprom_ptov(unsigned int phys_addr, unsigned int fn, unsigned int sz)
 {
+	fn *= sz;
 	if (phys_addr < 1024)
 		return phys_addr + (31 << 10);
+	if (phys_addr < 1024 + fn)
+		return 31744 - fn + phys_addr - 1024;
 	if (phys_addr < EEPROMSIZE)
-		return phys_addr - 1024;
+		return phys_addr - 1024 - fn;
 	return -EINVAL;
 }
 
 /*
  * The next two routines implement eeprom read/write from physical addresses.
- * The physical->virtual translation is correct only for PF0.
  */
 static int eeprom_rd_phys(struct adapter *adap, unsigned int phys_addr, u32 *v)
 {
-	int vaddr = eeprom_ptov(phys_addr);
+	int vaddr = eeprom_ptov(phys_addr, adap->fn, EEPROMPFSIZE);
 
 	if (vaddr >= 0)
 		vaddr = pci_read_vpd(adap->pdev, vaddr, sizeof(u32), v);
@@ -1710,7 +1724,7 @@ static int eeprom_rd_phys(struct adapter *adap, unsigned int phys_addr, u32 *v)
 
 static int eeprom_wr_phys(struct adapter *adap, unsigned int phys_addr, u32 v)
 {
-	int vaddr = eeprom_ptov(phys_addr);
+	int vaddr = eeprom_ptov(phys_addr, adap->fn, EEPROMPFSIZE);
 
 	if (vaddr >= 0)
 		vaddr = pci_write_vpd(adap->pdev, vaddr, sizeof(u32), &v);
@@ -1753,6 +1767,14 @@ static int set_eeprom(struct net_device *dev, struct ethtool_eeprom *eeprom,
 	aligned_offset = eeprom->offset & ~3;
 	aligned_len = (eeprom->len + (eeprom->offset & 3) + 3) & ~3;
 
+	if (adapter->fn > 0) {
+		u32 start = 1024 + adapter->fn * EEPROMPFSIZE;
+
+		if (aligned_offset < start ||
+		    aligned_offset + aligned_len > start + EEPROMPFSIZE)
+			return -EPERM;
+	}
+
 	if (aligned_offset != eeprom->offset || aligned_len != eeprom->len) {
 		/*
 		 * RMW possibly needed for first or last words.
diff --git a/drivers/net/cxgb4/t4_hw.h b/drivers/net/cxgb4/t4_hw.h
index 10a0555..c26b455 100644
--- a/drivers/net/cxgb4/t4_hw.h
+++ b/drivers/net/cxgb4/t4_hw.h
@@ -42,6 +42,7 @@ enum {
 	MAX_MTU        = 9600,  /* max MAC MTU, excluding header + FCS */
 	EEPROMSIZE     = 17408, /* Serial EEPROM physical size */
 	EEPROMVSIZE    = 32768, /* Serial EEPROM virtual address space size */
+	EEPROMPFSIZE   = 1024,  /* EEPROM writable area size for PFn, n>0 */
 	RSS_NENTRIES   = 2048,  /* # of entries in RSS mapping table */
 	TCB_SIZE       = 128,   /* TCB size */
 	NMTUS          = 16,    /* size of MTU table */
-- 
1.5.4

