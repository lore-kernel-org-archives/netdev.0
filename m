From: Andi Kleen <andi@firstfloor.org>
Subject: Re: Receive side performance issue with multi-10-GigE and NUMA
Date: Wed, 12 Aug 2009 09:21:32 +0200
Message-ID: <20090812072132.GA28848@basil.fritz.box>
References: <20090807175112.a1f57407.billfink@mindspring.com> <4A7CCEFC.7020308@myri.com> <20090807213557.d0faec23.billfink@mindspring.com> <4A7D5CA4.3030307@myri.com> <20090808112636.GB18518@localhost.localdomain> <4A7DC230.6060206@myri.com> <20090808183251.GA23300@localhost.localdomain> <20090811033210.6b422ed1.billfink@mindspring.com> <87ws5af0km.fsf@basil.nowhere.org> <20090812003049.185cd52a.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>,
	Neil Horman <nhorman@tuxdriver.com>,
	Andrew Gallatin <gallatin@myri.com>,
	Brice Goglin <Brice.Goglin@inria.fr>,
	Linux Network Developers <netdev@vger.kernel.org>,
	Yinghai Lu <yhlu.kernel@gmail.com>, jbarnes@virtuousgeek.org
To: Bill Fink <billfink@mindspring.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:38503 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752461AbZHLHVg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2009 03:21:36 -0400
Content-Disposition: inline
In-Reply-To: <20090812003049.185cd52a.billfink@mindspring.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> There are now NUMA nodes 0 and 1 instead of 0 and 2, and the CPUs
> for node 0 are 0 through 3 while the CPUs for node 1 are 4 through 7
> (previously the even CPUs were on the first Xeon 5580 processor while
> the odd CPUs were on the second processor).

That might be ok, depending on how the APICs are configured.
Of course you should have the same number of CPUs on the different
nodes. Anyways, it's gone now.

> 
> [root@xeontest1 ~]# numastat
>                            node0           node1
> numa_hit                28087735        27195340
> numa_miss                      0               0
> numa_foreign                   0               0
> interleave_hit             12065           11978
> local_node              28081559        27182572
> other_node                  6176           12768
> 
> [root@xeontest1 ~]# grep 'physical id' /proc/cpuinfo
> physical id     : 0
> physical id     : 0
> physical id     : 0
> physical id     : 0
> physical id     : 1
> physical id     : 1
> physical id     : 1
> physical id     : 1
> 
> [root@xeontest1 ~]# cat /sys/devices/system/node/node0/cpulist
> 0-3
> [root@xeontest1 ~]# cat /sys/devices/system/node/node1/cpulist
> 4-7
> 
> But _all_ the PCI devices are still just on node 0.

Most likely you need the appended patch from linux-next.

It should be probably in .31, but I can't see it in linus' tree only in -next. 
Jesse? 

Unfortunately the patch seems to combine code movement with fixes :-(

> Are you still interested in me posting the dmesg output?

No.

-Andi



commit eaf2f454cc9a76dbe1890af6269e60fe9978a3a5
Author: Jesse Barnes <jbarnes@virtuousgeek.org>
Date:   Fri Jul 10 14:04:30 2009 -0700

    x86/PCI: initialize PCI bus node numbers early
    
    The current mp_bus_to_node array is initialized only by AMD specific
    code, since AMD platforms have registers that can be used for
    determining mode numbers.  On new Intel platforms it's necessary to
    initialize this array as well though, otherwise all PCI node numbers
    will be 0, when in fact they should be -1 (indicating that I/O isn't
    tied to any particular node).
    
    So move the mp_bus_to_node code into the common PCI code, and
    initialize it early with a default value of -1.  This may be overridden
    later by arch code (e.g. the AMD code).
    
    With this change, PCI consistent memory and other node specific
    allocations (e.g. skbuff allocs) should occur on the "current" node.
    If, for performance reasons, applications want to be bound to specific
    nodes, they should open their devices only after being pinned to the
    CPU where they'll run, for maximum locality.
    
    Acked-by: Yinghai Lu <yinghai@kernel.org>
    Tested-by: Jesse Brandeburg <jesse.brandeburg@gmail.com>
    Signed-off-by: Jesse Barnes <jbarnes@virtuousgeek.org>

diff --git a/arch/x86/pci/amd_bus.c b/arch/x86/pci/amd_bus.c
index 3ffa10d..572ee97 100644
--- a/arch/x86/pci/amd_bus.c
+++ b/arch/x86/pci/amd_bus.c
@@ -15,63 +15,6 @@
  * also get peer root bus resource for io,mmio
  */
 
-#ifdef CONFIG_NUMA
-
-#define BUS_NR 256
-
-#ifdef CONFIG_X86_64
-
-static int mp_bus_to_node[BUS_NR];
-
-void set_mp_bus_to_node(int busnum, int node)
-{
-	if (busnum >= 0 &&  busnum < BUS_NR)
-		mp_bus_to_node[busnum] = node;
-}
-
-int get_mp_bus_to_node(int busnum)
-{
-	int node = -1;
-
-	if (busnum < 0 || busnum > (BUS_NR - 1))
-		return node;
-
-	node = mp_bus_to_node[busnum];
-
-	/*
-	 * let numa_node_id to decide it later in dma_alloc_pages
-	 * if there is no ram on that node
-	 */
-	if (node != -1 && !node_online(node))
-		node = -1;
-
-	return node;
-}
-
-#else /* CONFIG_X86_32 */
-
-static unsigned char mp_bus_to_node[BUS_NR];
-
-void set_mp_bus_to_node(int busnum, int node)
-{
-	if (busnum >= 0 &&  busnum < BUS_NR)
-	mp_bus_to_node[busnum] = (unsigned char) node;
-}
-
-int get_mp_bus_to_node(int busnum)
-{
-	int node;
-
-	if (busnum < 0 || busnum > (BUS_NR - 1))
-		return 0;
-	node = mp_bus_to_node[busnum];
-	return node;
-}
-
-#endif /* CONFIG_X86_32 */
-
-#endif /* CONFIG_NUMA */
-
 #ifdef CONFIG_X86_64
 
 /*
@@ -301,11 +244,6 @@ static int __init early_fill_mp_bus_info(void)
 	u64 val;
 	u32 address;
 
-#ifdef CONFIG_NUMA
-	for (i = 0; i < BUS_NR; i++)
-		mp_bus_to_node[i] = -1;
-#endif
-
 	if (!early_pci_allowed())
 		return -1;
 
@@ -346,7 +284,7 @@ static int __init early_fill_mp_bus_info(void)
 		node = (reg >> 4) & 0x07;
 #ifdef CONFIG_NUMA
 		for (j = min_bus; j <= max_bus; j++)
-			mp_bus_to_node[j] = (unsigned char) node;
+			set_mp_bus_to_node(j, node);
 #endif
 		link = (reg >> 8) & 0x03;
 
diff --git a/arch/x86/pci/common.c b/arch/x86/pci/common.c
index 2202b62..5db96d4 100644
--- a/arch/x86/pci/common.c
+++ b/arch/x86/pci/common.c
@@ -600,3 +600,72 @@ struct pci_bus * __devinit pci_scan_bus_with_sysdata(int busno)
 {
 	return pci_scan_bus_on_node(busno, &pci_root_ops, -1);
 }
+
+/*
+ * NUMA info for PCI busses
+ *
+ * Early arch code is responsible for filling in reasonable values here.
+ * A node id of "-1" means "use current node".  In other words, if a bus
+ * has a -1 node id, it's not tightly coupled to any particular chunk
+ * of memory (as is the case on some Nehalem systems).
+ */
+#ifdef CONFIG_NUMA
+
+#define BUS_NR 256
+
+#ifdef CONFIG_X86_64
+
+static int mp_bus_to_node[BUS_NR] = {
+	[0 ... BUS_NR - 1] = -1
+};
+
+void set_mp_bus_to_node(int busnum, int node)
+{
+	if (busnum >= 0 &&  busnum < BUS_NR)
+		mp_bus_to_node[busnum] = node;
+}
+
+int get_mp_bus_to_node(int busnum)
+{
+	int node = -1;
+
+	if (busnum < 0 || busnum > (BUS_NR - 1))
+		return node;
+
+	node = mp_bus_to_node[busnum];
+
+	/*
+	 * let numa_node_id to decide it later in dma_alloc_pages
+	 * if there is no ram on that node
+	 */
+	if (node != -1 && !node_online(node))
+		node = -1;
+
+	return node;
+}
+
+#else /* CONFIG_X86_32 */
+
+static unsigned char mp_bus_to_node[BUS_NR] = {
+	[0 ... BUS_NR - 1] = -1
+};
+
+void set_mp_bus_to_node(int busnum, int node)
+{
+	if (busnum >= 0 &&  busnum < BUS_NR)
+	mp_bus_to_node[busnum] = (unsigned char) node;
+}
+
+int get_mp_bus_to_node(int busnum)
+{
+	int node;
+
+	if (busnum < 0 || busnum > (BUS_NR - 1))
+		return 0;
+	node = mp_bus_to_node[busnum];
+	return node;
+}
+
+#endif /* CONFIG_X86_32 */
+
+#endif /* CONFIG_NUMA */


-- 
ak@linux.intel.com -- Speaking for myself only.
