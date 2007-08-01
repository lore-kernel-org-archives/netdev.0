From: Brian King <brking@linux.vnet.ibm.com>
Subject: [PATCH 1/1] ibmveth: Fix rx pool deactivate oops
Date: Wed, 01 Aug 2007 15:26:50 -0500
Message-ID: <41031.1648542576$1186000027@news.gmane.org>
Cc: rcjenn@linux.vnet.ibm.com, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org, brking@linux.vnet.ibm.com
To: santil@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:56272 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750811AbXHAU0x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Aug 2007 16:26:53 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e33.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l71KQqnJ011013
	for <netdev@vger.kernel.org>; Wed, 1 Aug 2007 16:26:52 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.4) with ESMTP id l71KQqNQ214732
	for <netdev@vger.kernel.org>; Wed, 1 Aug 2007 14:26:52 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l71KQpC6010787
	for <netdev@vger.kernel.org>; Wed, 1 Aug 2007 14:26:52 -0600
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This fixes the following oops which can occur when trying to deallocate
receive buffer pools using sysfs with the ibmveth driver.

NIP: d00000000024f954 LR: d00000000024fa58 CTR: c0000000000d7478
REGS: c00000000ffef9f0 TRAP: 0300   Not tainted  (2.6.22-ppc64)
MSR: 8000000000009032 <EE,ME,IR,DR>  CR: 24242442  XER: 00000010
DAR: 00000000000007f0, DSISR: 0000000042000000
TASK = c000000002f91360[2967] 'bash' THREAD: c00000001398c000 CPU: 2
GPR00: 0000000000000000 c00000000ffefc70 d000000000262d30 c00000001c4087a0 
GPR04: 00000003000000fe 0000000000000000 000000000000000f c000000000579d80 
GPR08: 0000000000365688 c00000001c408998 00000000000007f0 0000000000000000 
GPR12: d000000000251e88 c000000000579d80 00000000200957ec 0000000000000000 
GPR16: 00000000100b8808 00000000100feb30 0000000000000000 0000000010084828 
GPR20: 0000000000000000 000000001014d4d0 0000000000000010 c00000000ffefeb0 
GPR24: c00000001c408000 0000000000000000 c00000001c408000 00000000ffffb054 
GPR28: 00000000000000fe 0000000000000003 d000000000262700 c00000001c4087a0 
NIP [d00000000024f954] .ibmveth_remove_buffer_from_pool+0x38/0x108 [ibmveth]
LR [d00000000024fa58] .ibmveth_rxq_harvest_buffer+0x34/0x78 [ibmveth]
Call Trace:
[c00000000ffefc70] [c0000000000280a8] .dma_iommu_unmap_single+0x14/0x28 (unreliable)
[c00000000ffefd00] [d00000000024fa58] .ibmveth_rxq_harvest_buffer+0x34/0x78 [ibmveth]
[c00000000ffefd80] [d000000000250e40] .ibmveth_poll+0xd8/0x434 [ibmveth]
[c00000000ffefe40] [c00000000032da8c] .net_rx_action+0xdc/0x248
[c00000000ffefef0] [c000000000068b4c] .__do_softirq+0xa8/0x164
[c00000000ffeff90] [c00000000002789c] .call_do_softirq+0x14/0x24
[c00000001398f6f0] [c00000000000c04c] .do_softirq+0x68/0xac
[c00000001398f780] [c000000000068ca0] .irq_exit+0x54/0x6c
[c00000001398f800] [c00000000000c8e4] .do_IRQ+0x170/0x1ac
[c00000001398f890] [c000000000004790] hardware_interrupt_entry+0x18/0x1c
   Exception: 501 at .plpar_hcall_norets+0x24/0x94
    LR = .veth_pool_store+0x15c/0x298 [ibmveth]
[c00000001398fb80] [d000000000250b2c] .veth_pool_store+0x5c/0x298 [ibmveth] (unreliable)
[c00000001398fc30] [c000000000145530] .sysfs_write_file+0x140/0x1d8
[c00000001398fcf0] [c0000000000de89c] .vfs_write+0x120/0x208
[c00000001398fd90] [c0000000000df2c8] .sys_write+0x4c/0x8c
[c00000001398fe30] [c0000000000086ac] syscall_exit+0x0/0x40
Instruction dump:
fba1ffe8 fbe1fff8 789d0022 f8010010 f821ff71 789c0020 1d3d00a8 7b8a1f24 
38000000 7c7f1b78 7d291a14 e9690128 <7c0a592a> e8030000 e9690120 80a90100 

Signed-off-by: Brian King <brking@linux.vnet.ibm.com>
---

 linux-2.6-bjking1/drivers/net/ibmveth.c |   24 ++++++++++++++----------
 linux-2.6-bjking1/drivers/net/ibmveth.h |    3 ---
 2 files changed, 14 insertions(+), 13 deletions(-)

diff -puN drivers/net/ibmveth.c~ibmveth_fixup_pool_deactivate drivers/net/ibmveth.c
--- linux-2.6/drivers/net/ibmveth.c~ibmveth_fixup_pool_deactivate	2007-08-01 10:22:37.000000000 -0500
+++ linux-2.6-bjking1/drivers/net/ibmveth.c	2007-08-01 10:23:20.000000000 -0500
@@ -1280,24 +1280,28 @@ const char * buf, size_t count)
 			int i;
 			/* Make sure there is a buffer pool with buffers that
 			   can hold a packet of the size of the MTU */
-			for(i = 0; i<IbmVethNumBufferPools; i++) {
+			for (i = 0; i < IbmVethNumBufferPools; i++) {
 				if (pool == &adapter->rx_buff_pool[i])
 					continue;
 				if (!adapter->rx_buff_pool[i].active)
 					continue;
-				if (mtu < adapter->rx_buff_pool[i].buff_size) {
-					pool->active = 0;
-					h_free_logical_lan_buffer(adapter->
-								  vdev->
-								  unit_address,
-								  pool->
-								  buff_size);
-				}
+				if (mtu <= adapter->rx_buff_pool[i].buff_size)
+					break;
 			}
-			if (pool->active) {
+
+			if (i == IbmVethNumBufferPools) {
 				ibmveth_error_printk("no active pool >= MTU\n");
 				return -EPERM;
 			}
+
+			pool->active = 0;
+			if (netif_running(netdev)) {
+				adapter->pool_config = 1;
+				ibmveth_close(netdev);
+				adapter->pool_config = 0;
+				if ((rc = ibmveth_open(netdev)))
+					return rc;
+			}
 		}
 	} else if (attr == &veth_num_attr) {
 		if (value <= 0 || value > IBMVETH_MAX_POOL_COUNT)
diff -puN drivers/net/ibmveth.h~ibmveth_fixup_pool_deactivate drivers/net/ibmveth.h
--- linux-2.6/drivers/net/ibmveth.h~ibmveth_fixup_pool_deactivate	2007-08-01 14:45:09.000000000 -0500
+++ linux-2.6-bjking1/drivers/net/ibmveth.h	2007-08-01 14:45:21.000000000 -0500
@@ -73,9 +73,6 @@ static inline long h_send_logical_lan(un
 #define h_change_logical_lan_mac(ua, mac) \
   plpar_hcall_norets(H_CHANGE_LOGICAL_LAN_MAC, ua, mac)
 
-#define h_free_logical_lan_buffer(ua, bufsize) \
-  plpar_hcall_norets(H_FREE_LOGICAL_LAN_BUFFER, ua, bufsize)
-
 #define IbmVethNumBufferPools 5
 #define IBMVETH_BUFF_OH 22 /* Overhead: 14 ethernet header + 8 opaque handle */
 #define IBMVETH_MAX_MTU 68
_
