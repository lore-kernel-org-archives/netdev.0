From: Thomas Klein <tklein@de.ibm.com>
Subject: [PATCH] ehea: Add hugepage detection
Date: Mon, 27 Oct 2008 10:38:46 +0100
Message-ID: <200810271038.46825.tklein@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Christoph Raisch <raisch@de.ibm.com>,
	Hannes Hering <hering2@de.ibm.com>,
	"Jan-Bernd Themann" <themann@de.ibm.com>,
	"linux-kernel" <linux-kernel@vger.kernel.org>,
	"linux-ppc" <linuxppc-dev@ozlabs.org>,
	"netdev" <netdev@vger.kernel.org>, badari@us.ibm.com,
	haveblue@us.ibm.com, tollefso@us.ibm.com
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate4.de.ibm.com ([195.212.29.153]:53518 "EHLO
	mtagate4.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750965AbYJ0Jjc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Oct 2008 05:39:32 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

All kernel memory which is used for kernel/hardware data transfer must be registered
with firmware using "memory regions". 16GB hugepages may not be part of a memory region
due to firmware restrictions.
This patch modifies the walk_memory_resource callback fn to filter hugepages and add
only standard memory to the busmap which is later on used for MR registration.

Signed-off-by: Thomas Klein <tklein@de.ibm.com>
---
This reworked patch accounts for comments I got. It's based on davem's net-2.6.git.


diff -Nurp -X dontdiff linux-2.6.27/drivers/net/ehea/ehea.h patched_kernel/drivers/net/ehea/ehea.h
--- linux-2.6.27/drivers/net/ehea/ehea.h	2008-10-24 09:29:19.000000000 +0200
+++ patched_kernel/drivers/net/ehea/ehea.h	2008-10-27 09:27:46.000000000 +0100
@@ -40,7 +40,7 @@
 #include <asm/io.h>

 #define DRV_NAME	"ehea"
-#define DRV_VERSION	"EHEA_0094"
+#define DRV_VERSION	"EHEA_0095"

 /* eHEA capability flags */
 #define DLPAR_PORT_ADD_REM 1
diff -Nurp -X dontdiff linux-2.6.27/drivers/net/ehea/ehea_qmr.c patched_kernel/drivers/net/ehea/ehea_qmr.c
--- linux-2.6.27/drivers/net/ehea/ehea_qmr.c	2008-10-24 09:29:19.000000000 +0200
+++ patched_kernel/drivers/net/ehea/ehea_qmr.c	2008-10-27 09:27:46.000000000 +0100
@@ -632,10 +632,13 @@ static void ehea_rebuild_busmap(void)
 	}
 }

-static int ehea_update_busmap(unsigned long pfn, unsigned long pgnum, int add)
+static int ehea_update_busmap(unsigned long pfn, unsigned long nr_pages, int add)
 {
 	unsigned long i, start_section, end_section;

+	if (!nr_pages)
+		return 0;
+
 	if (!ehea_bmap) {
 		ehea_bmap = kzalloc(sizeof(struct ehea_bmap), GFP_KERNEL);
 		if (!ehea_bmap)
@@ -643,7 +646,7 @@ static int ehea_update_busmap(unsigned l
 	}

 	start_section = (pfn * PAGE_SIZE) / EHEA_SECTSIZE;
-	end_section = start_section + ((pgnum * PAGE_SIZE) / EHEA_SECTSIZE);
+	end_section = start_section + ((nr_pages * PAGE_SIZE) / EHEA_SECTSIZE);
 	/* Mark entries as valid or invalid only; address is assigned later */
 	for (i = start_section; i < end_section; i++) {
 		u64 flag;
@@ -692,10 +695,54 @@ int ehea_rem_sect_bmap(unsigned long pfn
 	return ret;
 }

-static int ehea_create_busmap_callback(unsigned long pfn,
-				       unsigned long nr_pages, void *arg)
+static int ehea_is_hugepage(unsigned long pfn)
+{
+	int page_order;
+
+	if (pfn & EHEA_HUGEPAGE_PFN_MASK)
+		return 0;
+
+	page_order = compound_order(pfn_to_page(pfn));
+	if (page_order + PAGE_SHIFT != EHEA_HUGEPAGESHIFT)
+		return 0;
+
+	return 1;
+}
+
+static int ehea_create_busmap_callback(unsigned long initial_pfn,
+				       unsigned long total_nr_pages, void *arg)
 {
-	return ehea_update_busmap(pfn, nr_pages, EHEA_BUSMAP_ADD_SECT);
+	int ret;
+	unsigned long pfn, start_pfn, end_pfn, nr_pages;
+
+	if ((total_nr_pages * PAGE_SIZE) < EHEA_HUGEPAGE_SIZE)
+		return ehea_update_busmap(initial_pfn, total_nr_pages,
+					  EHEA_BUSMAP_ADD_SECT);
+
+	/* Given chunk is >= 16GB -> check for hugepages */
+	start_pfn = initial_pfn;
+	end_pfn = initial_pfn + total_nr_pages;
+	pfn = start_pfn;
+
+	while (pfn < end_pfn) {
+		if (ehea_is_hugepage(pfn)) {
+			/* Add mem found in front of the hugepage */
+			nr_pages = pfn - start_pfn;
+			ret = ehea_update_busmap(start_pfn, nr_pages,
+						 EHEA_BUSMAP_ADD_SECT);
+			if (ret)
+				return ret;
+
+			/* Skip the hugepage */
+			pfn += (EHEA_HUGEPAGE_SIZE / PAGE_SIZE);
+			start_pfn = pfn;
+		} else
+			pfn += (EHEA_SECTSIZE / PAGE_SIZE);
+	}
+
+	/* Add mem found behind the hugepage(s)  */
+	nr_pages = pfn - start_pfn;
+	return ehea_update_busmap(start_pfn, nr_pages, EHEA_BUSMAP_ADD_SECT);
 }

 int ehea_create_busmap(void)
diff -Nurp -X dontdiff linux-2.6.27/drivers/net/ehea/ehea_qmr.h patched_kernel/drivers/net/ehea/ehea_qmr.h
--- linux-2.6.27/drivers/net/ehea/ehea_qmr.h	2008-10-24 09:29:19.000000000 +0200
+++ patched_kernel/drivers/net/ehea/ehea_qmr.h	2008-10-27 09:27:46.000000000 +0100
@@ -40,6 +40,9 @@
 #define EHEA_PAGESIZE          (1UL << EHEA_PAGESHIFT)
 #define EHEA_SECTSIZE          (1UL << 24)
 #define EHEA_PAGES_PER_SECTION (EHEA_SECTSIZE >> EHEA_PAGESHIFT)
+#define EHEA_HUGEPAGESHIFT     34
+#define EHEA_HUGEPAGE_SIZE     (1UL << EHEA_HUGEPAGESHIFT)
+#define EHEA_HUGEPAGE_PFN_MASK ((EHEA_HUGEPAGE_SIZE - 1) >> PAGE_SHIFT)

 #if ((1UL << SECTION_SIZE_BITS) < EHEA_SECTSIZE)
 #error eHEA module cannot work if kernel sectionsize < ehea sectionsize

