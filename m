From: Dean Nelson <dcn@sgi.com>
Subject: [PATCH 1/4] SGI Altix cross partition functionality (1st revision)
Date: Tue, 24 Aug 2004 13:22:22 -0500
Sender: linux-ia64-owner@vger.kernel.org
Message-ID: <20040824182222.GA13961@sgi.com>
References: <412B823E.mailxAMX1HROPJ@aqua.americas.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-ia64-owner@vger.kernel.org>
To: linux-ia64@vger.kernel.org, netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <412B823E.mailxAMX1HROPJ@aqua.americas.sgi.com>
List-Id: netdev.vger.kernel.org

This patch exports the symbols needed by XP[C|NET].

Signed-off-by: Dean Nelson <dcn@sgi.com>


Index: bk-linux-2.6/arch/ia64/kernel/smpboot.c
===================================================================
--- bk-linux-2.6.orig/arch/ia64/kernel/smpboot.c	2004-08-23 14:38:36.000000000 -0500
+++ bk-linux-2.6/arch/ia64/kernel/smpboot.c	2004-08-24 07:29:11.000000000 -0500
@@ -498,6 +498,7 @@
 EXPORT_SYMBOL(cpu_to_node_map);
 /* which logical CPUs are on which nodes */
 cpumask_t node_to_cpu_mask[MAX_NUMNODES] __cacheline_aligned;
+EXPORT_SYMBOL(node_to_cpu_mask);
 
 /*
  * Build cpu to node mapping and initialize the per node cpu masks.
Index: bk-linux-2.6/arch/ia64/sn/kernel/setup.c
===================================================================
--- bk-linux-2.6.orig/arch/ia64/sn/kernel/setup.c	2004-08-23 14:38:37.000000000 -0500
+++ bk-linux-2.6/arch/ia64/sn/kernel/setup.c	2004-08-24 07:29:11.000000000 -0500
@@ -50,6 +50,7 @@
 #include <asm/sn/sn2/shub.h>
 
 DEFINE_PER_CPU(struct pda_s, pda_percpu);
+EXPORT_PER_CPU_SYMBOL(pda_percpu);
 
 #define MAX_PHYS_MEMORY		(1UL << 49)     /* 1 TB */
 
@@ -65,8 +66,11 @@
 unsigned long sn_rtc_cycles_per_second;   
 
 partid_t sn_partid = -1;
+EXPORT_SYMBOL(sn_partid);
 char sn_system_serial_number_string[128];
+EXPORT_SYMBOL(sn_system_serial_number_string);
 u64 sn_partition_serial_number;
+EXPORT_SYMBOL(sn_partition_serial_number);
 
 short physical_node_map[MAX_PHYSNODE_ID];
 
Index: bk-linux-2.6/kernel/sched.c
===================================================================
--- bk-linux-2.6.orig/kernel/sched.c	2004-08-23 14:39:35.000000000 -0500
+++ bk-linux-2.6/kernel/sched.c	2004-08-24 07:29:11.000000000 -0500
@@ -2814,6 +2814,7 @@
 {
 	return setscheduler(pid, policy, param);
 }
+EXPORT_SYMBOL(sys_sched_setscheduler);
 
 /**
  * sys_sched_setparam - set/change the RT priority of a thread
Index: bk-linux-2.6/mm/page_alloc.c
===================================================================
--- bk-linux-2.6.orig/mm/page_alloc.c	2004-08-23 14:38:16.000000000 -0500
+++ bk-linux-2.6/mm/page_alloc.c	2004-08-24 07:29:11.000000000 -0500
@@ -40,6 +40,7 @@
 unsigned long totalhigh_pages;
 long nr_swap_pages;
 int numnodes = 1;
+EXPORT_SYMBOL(numnodes);
 int sysctl_lower_zone_protection = 0;
 
 EXPORT_SYMBOL(totalram_pages);
Index: bk-linux-2.6/include/asm-ia64/sn/sn_sal.h
===================================================================
--- bk-linux-2.6.orig/include/asm-ia64/sn/sn_sal.h	2004-08-23 14:40:00.000000000 -0500
+++ bk-linux-2.6/include/asm-ia64/sn/sn_sal.h	2004-08-24 07:29:11.000000000 -0500
@@ -494,7 +494,8 @@
 ia64_sn_partition_serial_get(void)
 {
 	struct ia64_sal_retval ret_stuff;
-	SAL_CALL(ret_stuff, SN_SAL_PARTITION_SERIAL_GET, 0, 0, 0, 0, 0, 0, 0);
+	ia64_sal_oemcall_reentrant(&ret_stuff, SN_SAL_PARTITION_SERIAL_GET, 0,
+				   0, 0, 0, 0, 0, 0);
 	if (ret_stuff.status != 0)
 	    return 0;
 	return ret_stuff.v0;
@@ -502,11 +503,10 @@
 
 static inline u64
 sn_partition_serial_number_val(void) {
-	if (sn_partition_serial_number) {
-		return(sn_partition_serial_number);
-	} else {
-		return(sn_partition_serial_number = ia64_sn_partition_serial_get());
+	if (unlikely(sn_partition_serial_number == 0)) {
+		sn_partition_serial_number = ia64_sn_partition_serial_get();
 	}
+	return sn_partition_serial_number;
 }
 
 /*
@@ -517,8 +517,8 @@
 ia64_sn_sysctl_partition_get(nasid_t nasid)
 {
 	struct ia64_sal_retval ret_stuff;
-	SAL_CALL(ret_stuff, SN_SAL_SYSCTL_PARTITION_GET, nasid,
-		 0, 0, 0, 0, 0, 0);
+	ia64_sal_oemcall_nolock(&ret_stuff, SN_SAL_SYSCTL_PARTITION_GET, nasid,
+				0, 0, 0, 0, 0, 0);
 	if (ret_stuff.status != 0)
 	    return INVALID_PARTID;
 	return ((partid_t)ret_stuff.v0);
@@ -532,11 +532,38 @@
 
 static inline partid_t
 sn_local_partid(void) {
-	if (sn_partid < 0) {
-		return (sn_partid = ia64_sn_sysctl_partition_get(cpuid_to_nasid(smp_processor_id())));
-	} else {
-		return sn_partid;
+	if (unlikely(sn_partid < 0)) {
+		sn_partid = ia64_sn_sysctl_partition_get(cpuid_to_nasid(smp_processor_id()));
 	}
+	return sn_partid;
+}
+
+/*
+ * Returns the physical address of the partition's reserved page through
+ * an iterative number of calls.
+ *
+ * On first call, 'cookie' and 'len' should be set to 0, and 'addr'
+ * set to the nasid of the partition whose reserved page's address is
+ * being sought.
+ * On subsequent calls, pass the values, that were passed back on the
+ * previous call.
+ *
+ * While the return status equals SALRET_MORE_PASSES, keep calling
+ * this function after first copying 'len' bytes starting at 'addr'
+ * into 'buf'. Once the return status equals SALRET_OK, 'addr' will
+ * be the physical address of the partition's reserved page. If the
+ * return status equals neither of these, an error as occurred.
+ */
+static inline s64
+sn_partition_reserved_page_pa(u64 buf, u64 *cookie, u64 *addr, u64 *len)
+{
+	struct ia64_sal_retval rv;
+	ia64_sal_oemcall_reentrant(&rv, SN_SAL_GET_PARTITION_ADDR, *cookie,
+				   *addr, buf, *len, 0, 0, 0);
+	*cookie = rv.v0;
+	*addr = rv.v1;
+	*len = rv.v2;
+	return rv.status;
 }
 
 /*
@@ -558,8 +585,8 @@
 sn_register_xp_addr_region(u64 paddr, u64 len, int operation)
 {
 	struct ia64_sal_retval ret_stuff;
-	SAL_CALL(ret_stuff, SN_SAL_XP_ADDR_REGION, paddr, len, (u64)operation,
-		 0, 0, 0, 0);
+	ia64_sal_oemcall(&ret_stuff, SN_SAL_XP_ADDR_REGION, paddr, len,
+			 (u64)operation, 0, 0, 0, 0);
 	return ret_stuff.status;
 }
 
@@ -583,8 +610,8 @@
 	} else {
 		call = SN_SAL_NO_FAULT_ZONE_PHYSICAL;
 	}
-	SAL_CALL(ret_stuff, call, start_addr, end_addr, return_addr, (u64)1,
-		 0, 0, 0);
+	ia64_sal_oemcall(&ret_stuff, call, start_addr, end_addr, return_addr,
+			 (u64)1, 0, 0, 0);
 	return ret_stuff.status;
 }
 
@@ -605,8 +632,8 @@
 sn_change_coherence(u64 *new_domain, u64 *old_domain)
 {
 	struct ia64_sal_retval ret_stuff;
-	SAL_CALL(ret_stuff, SN_SAL_COHERENCE, new_domain, old_domain, 0, 0,
-		 0, 0, 0);
+	ia64_sal_oemcall(&ret_stuff, SN_SAL_COHERENCE, (u64)new_domain,
+			 (u64)old_domain, 0, 0, 0, 0, 0);
 	return ret_stuff.status;
 }
 
@@ -625,8 +652,8 @@
 	cnodeid = nasid_to_cnodeid(get_node_number(paddr));
 	spin_lock(&NODEPDA(cnodeid)->bist_lock);
 	local_irq_save(irq_flags);
-	SAL_CALL_NOLOCK(ret_stuff, SN_SAL_MEMPROTECT, paddr, len, nasid_array,
-		 perms, 0, 0, 0);
+	ia64_sal_oemcall_nolock(&ret_stuff, SN_SAL_MEMPROTECT, paddr, len,
+				(u64)nasid_array, perms, 0, 0, 0);
 	local_irq_restore(irq_flags);
 	spin_unlock(&NODEPDA(cnodeid)->bist_lock);
 	return ret_stuff.status;
