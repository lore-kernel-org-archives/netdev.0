From: Nathan Lynch <ntl@pobox.com>
Subject: Re: [PATCH 2/3] [2.6.26] ehea: Add dependency to Kconfig
Date: Wed, 28 May 2008 11:44:05 -0500
Message-ID: <20080528164405.GA4836@localdomain>
References: <200805071443.20192.hannes.hering@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, tklein@de.ibm.com, themann@de.ibm.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	raisch@de.ibm.com, ossrosch@linux.vnet.ibm.com,
	linuxppc-dev@ozlabs.org, ossthema@de.ibm.com
To: Hannes Hering <hannes.hering@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a-sasl-fastnet.sasl.smtp.pobox.com ([207.106.133.19]:48979 "EHLO
	sasl.smtp.pobox.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751762AbYE1QoJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 May 2008 12:44:09 -0400
Content-Disposition: inline
In-Reply-To: <200805071443.20192.hannes.hering@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

Hannes Hering wrote:
> The new ehea memory hot plug implementation depends on MEMORY_HOTPLUG.
> 
> Signed-off-by: Hannes Hering <hering2@de.ibm.com>
> ---
> 
> diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
> index f90a86b..181cd86 100644
> --- a/drivers/net/Kconfig
> +++ b/drivers/net/Kconfig
> @@ -2440,7 +2440,7 @@ config CHELSIO_T3
>  
>  config EHEA
>  	tristate "eHEA Ethernet support"
> -	depends on IBMEBUS && INET && SPARSEMEM
> +	depends on IBMEBUS && INET && SPARSEMEM && MEMORY_HOTPLUG
>  	select INET_LRO
>  	---help---
>  	  This driver supports the IBM pSeries eHEA ethernet adapter.

I disagree with this change.

It makes it impossible to build the ehea driver without memory hotplug
enabled.  Presumably, this commit was intended to work around a build
break of this sort (with EHEA=m and MEMORY_HOTPLUG=n):

drivers/net/ehea/ehea_qmr.c: In function 'ehea_create_busmap':
drivers/net/ehea/ehea_qmr.c:635: error: implicit declaration of function 'walk_memory_resource'

(some indication of this should have been in the commit message, btw)

I think this was the wrong way to fix the issue.  EHEA=m and
MEMORY_HOTPLUG=n is a valid configuration for machines I test.

Any thoughts on the following, which makes walk_memory_resource()
available regardless of MEMORY_HOTPLUG's setting?  I've tested it on a
JS22 (Power6 blade).

---

 arch/powerpc/mm/mem.c          |    3 +--
 drivers/net/Kconfig            |    2 +-
 include/linux/memory_hotplug.h |   16 ++++++++--------
 3 files changed, 10 insertions(+), 11 deletions(-)

diff --git a/arch/powerpc/mm/mem.c b/arch/powerpc/mm/mem.c
index f67e118..51f82d8 100644
--- a/arch/powerpc/mm/mem.c
+++ b/arch/powerpc/mm/mem.c
@@ -151,6 +151,7 @@ out:
 	return ret;
 }
 #endif /* CONFIG_MEMORY_HOTREMOVE */
+#endif /* CONFIG_MEMORY_HOTPLUG */
 
 /*
  * walk_memory_resource() needs to make sure there is no holes in a given
@@ -184,8 +185,6 @@ walk_memory_resource(unsigned long start_pfn, unsigned long nr_pages, void *arg,
 }
 EXPORT_SYMBOL_GPL(walk_memory_resource);
 
-#endif /* CONFIG_MEMORY_HOTPLUG */
-
 void show_mem(void)
 {
 	unsigned long total = 0, reserved = 0;
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index dd0ec9e..f4182cf 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2426,7 +2426,7 @@ config CHELSIO_T3
 
 config EHEA
 	tristate "eHEA Ethernet support"
-	depends on IBMEBUS && INET && SPARSEMEM && MEMORY_HOTPLUG
+	depends on IBMEBUS && INET && SPARSEMEM
 	select INET_LRO
 	---help---
 	  This driver supports the IBM pSeries eHEA ethernet adapter.
diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index 73e3586..ea9f5ad 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -77,14 +77,6 @@ extern int __add_pages(struct zone *zone, unsigned long start_pfn,
 extern int __remove_pages(struct zone *zone, unsigned long start_pfn,
 	unsigned long nr_pages);
 
-/*
- * Walk through all memory which is registered as resource.
- * arg is (start_pfn, nr_pages, private_arg_pointer)
- */
-extern int walk_memory_resource(unsigned long start_pfn,
-			unsigned long nr_pages, void *arg,
-			int (*func)(unsigned long, unsigned long, void *));
-
 #ifdef CONFIG_NUMA
 extern int memory_add_physaddr_to_nid(u64 start);
 #else
@@ -199,6 +191,14 @@ static inline void register_page_bootmem_info_node(struct pglist_data *pgdat)
 
 #endif /* ! CONFIG_MEMORY_HOTPLUG */
 
+/*
+ * Walk through all memory which is registered as resource.
+ * arg is (start_pfn, nr_pages, private_arg_pointer)
+ */
+extern int walk_memory_resource(unsigned long start_pfn,
+			unsigned long nr_pages, void *arg,
+			int (*func)(unsigned long, unsigned long, void *));
+
 extern int add_memory(int nid, u64 start, u64 size);
 extern int arch_add_memory(int nid, u64 start, u64 size);
 extern int remove_memory(u64 start, u64 size);
