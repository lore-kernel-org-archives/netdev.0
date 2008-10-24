From: Thomas Klein <tklein@de.ibm.com>
Subject: [PATCH] ehea: Add hugepage detection
Date: Fri, 24 Oct 2008 13:07:30 +0200
Message-ID: <35990.8692575575$1224846751@news.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: badari@us.ibm.com, Jan-Bernd Themann <themann@de.ibm.com>,
	netdev <netdev@vger.kernel.org>, tollefso@us.ibm.com,
	Hannes Hering <hering2@de.ibm.com>, haveblue@us.ibm.com,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linux-ppc <linuxppc-dev@ozlabs.org>, Christoph Raisch <raisch@de.ibm.com>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
Content-Disposition: inline
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

16GB hugepages may not be part of a memory region (firmware restriction). This patch
modifies the walk_memory_resource callback fn to filter hugepages and add only standard
memory to the busmap which is later on used for MR registration.

Signed-off-by: Thomas Klein <tklein@de.ibm.com>
---
This patch is based on davem's net-2.6.git.

diff -Nurp -X dontdiff linux-2.6.27/drivers/net/ehea/ehea.h patched_kernel/drivers/net/ehea/ehea.h
--- linux-2.6.27/drivers/net/ehea/ehea.h	2008-10-24 09:29:19.000000000 +0200
+++ patched_kernel/drivers/net/ehea/ehea.h	2008-10-24 09:45:15.000000000 +0200
@@ -40,7 +40,7 @@
 #include <asm/io.h>
 
 #define DRV_NAME	"ehea"
-#define DRV_VERSION	"EHEA_0094"
+#define DRV_VERSION	"EHEA_0095"
 
 /* eHEA capability flags */
 #define DLPAR_PORT_ADD_REM 1
diff -Nurp -X dontdiff linux-2.6.27/drivers/net/ehea/ehea_qmr.c patched_kernel/drivers/net/ehea/ehea_qmr.c
--- linux-2.6.27/drivers/net/ehea/ehea_qmr.c	2008-10-24 09:29:19.000000000 +0200
+++ patched_kernel/drivers/net/ehea/ehea_qmr.c	2008-10-24 09:45:15.000000000 +0200
@@ -636,6 +636,9 @@ static int ehea_update_busmap(unsigned l
 {
 	unsigned long i, start_section, end_section;
 
+	if (!pgnum)
+		return 0;
+
 	if (!ehea_bmap) {
 		ehea_bmap = kzalloc(sizeof(struct ehea_bmap), GFP_KERNEL);
 		if (!ehea_bmap)
@@ -692,10 +695,47 @@ int ehea_rem_sect_bmap(unsigned long pfn
 	return ret;
 }
 
-static int ehea_create_busmap_callback(unsigned long pfn,
-				       unsigned long nr_pages, void *arg)
+static int ehea_is_hugepage(unsigned long pfn)
+{
+	return ((((pfn << PAGE_SHIFT) & (EHEA_HUGEPAGE_SIZE - 1)) == 0)
+		&& (compound_order(pfn_to_page(pfn)) + PAGE_SHIFT
+		    == EHEA_HUGEPAGESHIFT) );
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
+++ patched_kernel/drivers/net/ehea/ehea_qmr.h	2008-10-24 09:45:15.000000000 +0200
@@ -40,6 +40,8 @@
 #define EHEA_PAGESIZE          (1UL << EHEA_PAGESHIFT)
 #define EHEA_SECTSIZE          (1UL << 24)
 #define EHEA_PAGES_PER_SECTION (EHEA_SECTSIZE >> EHEA_PAGESHIFT)
+#define EHEA_HUGEPAGESHIFT     34
+#define EHEA_HUGEPAGE_SIZE     (1UL << EHEA_HUGEPAGESHIFT)
 
 #if ((1UL << SECTION_SIZE_BITS) < EHEA_SECTSIZE)
 #error eHEA module cannot work if kernel sectionsize < ehea sectionsize
