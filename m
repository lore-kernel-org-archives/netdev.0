From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Subject: [PATCH v2] [arch-x86] Allow SRAT integrity check to be skipped
Date: Wed, 01 Sep 2010 15:59:37 -0700
Message-ID: <20100901225937.18457.16372.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, andi@firstfloor.org,
	netdev@vger.kernel.org, peter.p.waskiewicz.jr@intel.com
To: tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On certain BIOSes, SRAT enumeration isn't exported correctly.
This leads to NUMA node enumeration failure, and causes the kernel
to fall back onto a single node treated as flat memory.  This
can happen on large, multi-socket systems (4 or more sockets), and
becomes problematic for performance.

This patch adds a boot parameter to allow a kernel to be booted
with the option to skip the SRAT check.  There are BIOSes in
production that have these failures, so this will allow people
in the field to work around these BIOS issues.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
---

 Documentation/x86/x86_64/boot-options.txt |    4 ++++
 arch/x86/mm/srat_64.c                     |   20 +++++++++++++++++---
 2 files changed, 21 insertions(+), 3 deletions(-)

diff --git a/Documentation/x86/x86_64/boot-options.txt b/Documentation/x86/x86_64/boot-options.txt
index 7fbbaf8..7863d9c 100644
--- a/Documentation/x86/x86_64/boot-options.txt
+++ b/Documentation/x86/x86_64/boot-options.txt
@@ -316,3 +316,7 @@ Miscellaneous
 		Do not use GB pages for kernel direct mappings.
 	gbpages
 		Use GB pages for kernel direct mappings.
+ 	sratbypassbios
+		If specified, will skip an SRAT check for PXM coverage
+		from BIOS enumeration.  Only to be used on systems with
+		buggy BIOSes that munge the SRAT enumeration.
diff --git a/arch/x86/mm/srat_64.c b/arch/x86/mm/srat_64.c
index f9897f7..9fa2e32 100644
--- a/arch/x86/mm/srat_64.c
+++ b/arch/x86/mm/srat_64.c
@@ -351,6 +351,15 @@ int __init acpi_get_nodes(struct bootnode *physnodes)
 	return ret;
 }
 
+static int srat_bypass_bios;
+
+static int __init srat_bypass_bios_setup(char *str)
+{
+        srat_bypass_bios = 1;
+        return 0;
+}
+early_param("sratbypassbios", srat_bypass_bios_setup);
+
 /* Use the information discovered above to actually set up the nodes. */
 int __init acpi_scan_nodes(unsigned long start, unsigned long end)
 {
@@ -425,9 +434,14 @@ int __init acpi_scan_nodes(unsigned long start, unsigned long end)
 						nodes[i].end >> PAGE_SHIFT);
 	/* for out of order entries in SRAT */
 	sort_node_map();
-	if (!nodes_cover_memory(nodes)) {
-		bad_srat();
-		return -1;
+	if (!srat_bypass_bios) {
+		if (!nodes_cover_memory(nodes)) {
+			bad_srat();
+			return -1;
+		}
+	} else {
+		printk(KERN_INFO
+		           "SRAT: Bypassing NUMA sanity check...bad BIOS...\n");
 	}
 
 	/* Account for nodes with cpus and no memory */
