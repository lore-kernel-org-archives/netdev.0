From: Brian King <brking@linux.vnet.ibm.com>
Subject: [PATCH 1/2] ibmveth: Fix h_free_logical_lan error on pool resize
Date: Fri, 08 Jun 2007 14:05:16 -0500
Message-ID: <200706081905.l58J5J3U017418@d03av01.boulder.ibm.com>
Cc: rcjenn@linux.vnet.ibm.com, netdev@vger.kernel.org,
	brking@linux.vnet.ibm.com
To: santil@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:42165 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751562AbXFHTFV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jun 2007 15:05:21 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l58J5LtT008291
	for <netdev@vger.kernel.org>; Fri, 8 Jun 2007 15:05:21 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l58J5K0h203936
	for <netdev@vger.kernel.org>; Fri, 8 Jun 2007 13:05:20 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l58J5K4U017444
	for <netdev@vger.kernel.org>; Fri, 8 Jun 2007 13:05:20 -0600
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


When attempting to activate additional rx buffer pools on an ibmveth interface that
was not yet up, the error below was seen. The patch fixes this by only closing
and opening the interface to activate the resize if the interface is already
opened.

(drivers/net/ibmveth.c:597 ua:30000004) ERROR: h_free_logical_lan failed with fffffffffffffffc, continuing with close
Unable to handle kernel paging request for data at address 0x00000ff8
Faulting instruction address: 0xd0000000002540e0
Oops: Kernel access of bad area, sig: 11 [#1]
SMP NR_CPUS=128 NUMA PSERIES LPAR 
Modules linked in: ip6t_REJECT xt_tcpudp ipt_REJECT xt_state iptable_mangle ipta
ble_nat ip_nat iptable_filter ip6table_mangle ip_conntrack nfnetlink ip_tables i
p6table_filter ip6_tables x_tables ipv6 apparmor aamatch_pcre loop dm_mod ibmvet
h sg ibmvscsic sd_mod scsi_mod
NIP: D0000000002540E0 LR: D0000000002540D4 CTR: 80000000001AF404
REGS: c00000001cd27870 TRAP: 0300   Not tainted  (2.6.16.46-0.4-ppc64)
MSR: 8000000000009032 <EE,ME,IR,DR>  CR: 24242422  XER: 00000007
DAR: 0000000000000FF8, DSISR: 0000000040000000
TASK = c00000001ca7b4e0[1636] 'sh' THREAD: c00000001cd24000 CPU: 0
GPR00: D0000000002540D4 C00000001CD27AF0 D000000000265650 C00000001C936500 
GPR04: 8000000000009032 FFFFFFFFFFFFFFFF 0000000000000007 000000000002C2EF 
GPR08: FFFFFFFFFFFFFFFF 0000000000000000 C000000000652A10 C000000000652AE0 
GPR12: 0000000000004000 C0000000004A3300 00000000100A0000 0000000000000000 
GPR16: 00000000100B8808 00000000100C0F60 0000000000000000 0000000010084878 
GPR20: 0000000000000000 00000000100C0CB0 00000000100AF498 0000000000000002 
GPR24: 00000000100BA488 C00000001C936760 D000000000258DD0 C00000001C936000 
GPR28: 0000000000000000 C00000001C936500 D000000000265180 C00000001C936000 
NIP [D0000000002540E0] .ibmveth_close+0xc8/0xf4 [ibmveth]
LR [D0000000002540D4] .ibmveth_close+0xbc/0xf4 [ibmveth]
Call Trace:
[C00000001CD27AF0] [D0000000002540D4] .ibmveth_close+0xbc/0xf4 [ibmveth] (unreliable)
[C00000001CD27B80] [D0000000002545FC] .veth_pool_store+0xd0/0x260 [ibmveth]
[C00000001CD27C40] [C00000000012E0E8] .sysfs_write_file+0x118/0x198
[C00000001CD27CF0] [C0000000000CDAF0] .vfs_write+0x130/0x218
[C00000001CD27D90] [C0000000000CE52C] .sys_write+0x4c/0x8c
[C00000001CD27E30] [C00000000000871C] syscall_exit+0x0/0x40
Instruction dump:
419affd8 2fa30000 419e0020 e93d0000 e89e8040 38a00255 e87e81b0 80c90018 
48001531 e8410028 e93d00e0 7fa3eb78 <e8090ff8> f81d0430 4bfffdc9 38210090 

Signed-off-by: Brian King <brking@linux.vnet.ibm.com>
---

 linux-2.6-bjking1/drivers/net/ibmveth.c |   53 ++++++++++++++++++--------------
 1 file changed, 31 insertions(+), 22 deletions(-)

diff -puN drivers/net/ibmveth.c~ibmveth_large_frames drivers/net/ibmveth.c
--- linux-2.6/drivers/net/ibmveth.c~ibmveth_large_frames	2007-05-14 15:03:06.000000000 -0500
+++ linux-2.6-bjking1/drivers/net/ibmveth.c	2007-05-15 09:18:46.000000000 -0500
@@ -1243,16 +1243,19 @@ const char * buf, size_t count)
 
 	if (attr == &veth_active_attr) {
 		if (value && !pool->active) {
-			if(ibmveth_alloc_buffer_pool(pool)) {
-                                ibmveth_error_printk("unable to alloc pool\n");
-                                return -ENOMEM;
-                        }
-			pool->active = 1;
-			adapter->pool_config = 1;
-			ibmveth_close(netdev);
-			adapter->pool_config = 0;
-			if ((rc = ibmveth_open(netdev)))
-				return rc;
+			if (netif_running(netdev)) {
+				if(ibmveth_alloc_buffer_pool(pool)) {
+					ibmveth_error_printk("unable to alloc pool\n");
+					return -ENOMEM;
+				}
+				pool->active = 1;
+				adapter->pool_config = 1;
+				ibmveth_close(netdev);
+				adapter->pool_config = 0;
+				if ((rc = ibmveth_open(netdev)))
+					return rc;
+			} else
+				pool->active = 1;
 		} else if (!value && pool->active) {
 			int mtu = netdev->mtu + IBMVETH_BUFF_OH;
 			int i;
@@ -1281,23 +1284,29 @@ const char * buf, size_t count)
 		if (value <= 0 || value > IBMVETH_MAX_POOL_COUNT)
 			return -EINVAL;
 		else {
-			adapter->pool_config = 1;
-			ibmveth_close(netdev);
-			adapter->pool_config = 0;
-			pool->size = value;
-			if ((rc = ibmveth_open(netdev)))
-				return rc;
+			if (netif_running(netdev)) {
+				adapter->pool_config = 1;
+				ibmveth_close(netdev);
+				adapter->pool_config = 0;
+				pool->size = value;
+				if ((rc = ibmveth_open(netdev)))
+					return rc;
+			} else
+				pool->size = value;
 		}
 	} else if (attr == &veth_size_attr) {
 		if (value <= IBMVETH_BUFF_OH || value > IBMVETH_MAX_BUF_SIZE)
 			return -EINVAL;
 		else {
-			adapter->pool_config = 1;
-			ibmveth_close(netdev);
-			adapter->pool_config = 0;
-			pool->buff_size = value;
-			if ((rc = ibmveth_open(netdev)))
-				return rc;
+			if (netif_running(netdev)) {
+				adapter->pool_config = 1;
+				ibmveth_close(netdev);
+				adapter->pool_config = 0;
+				pool->buff_size = value;
+				if ((rc = ibmveth_open(netdev)))
+					return rc;
+			} else
+				pool->buff_size = value;
 		}
 	}
 
_
