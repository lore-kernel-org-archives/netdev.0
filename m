From: "Amit S. Kale" <amitkale@netxen.com>
Subject: [PATCH 1/2] NetXen: Fixes for ppc architecture.
Date: Fri, 9 Feb 2007 05:45:18 -0800
Message-ID: <200702091345.l19DjIwd010864@dut39.unminc.com>
Cc: amitkale@netxen.com, jeff@garzik.org, netxenproj@linsyssoft.com,
	rob@netxen.com, sanjeev@netxen.com, wendyx@us.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 66-126-254-34.unm.net ([66.126.254.34]:29641 "EHLO
	nxmail.netxen.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1946461AbXBINpT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Feb 2007 08:45:19 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

NetXen: Fixes for ppc architecture.

Signed-off-by: Amit S. Kale <amitkale@netxen.com>

---

 netxen_nic_hw.c   |    2 ++
 netxen_nic_init.c |    4 ++--
 netxen_nic_main.c |    3 ++-
 netxen_nic_niu.c  |    2 +-
 4 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index f263232..7195af3 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -420,6 +420,7 @@ static int netxen_get_flash_block(struct
 	for (i = 0; i < size / sizeof(u32); i++) {
 		if (netxen_rom_fast_read(adapter, addr, ptr32) == -1)
 			return -1;
+		*ptr32 = cpu_to_le32(*ptr32);
 		ptr32++;
 		addr += sizeof(u32);
 	}
@@ -428,6 +429,7 @@ static int netxen_get_flash_block(struct
 
 		if (netxen_rom_fast_read(adapter, addr, &local) == -1)
 			return -1;
+		local = cpu_to_le32(local);
 		memcpy(ptr32, &local, (char *)buf + size - (char *)ptr32);
 	}
 
diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index f7bb8c9..c243c16 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -1246,7 +1246,7 @@ int netxen_process_cmd_ring(unsigned lon
 	 * the netdev which is associated with that device.
 	 */
 
-	consumer = *(adapter->cmd_consumer);
+	consumer = le32_to_cpu(*(adapter->cmd_consumer));
 	if (last_consumer == consumer) {	/* Ring is empty    */
 		DPRINTK(INFO, "last_consumer %d == consumer %d\n",
 			last_consumer, consumer);
@@ -1340,7 +1340,7 @@ int netxen_process_cmd_ring(unsigned lon
 	if (adapter->last_cmd_consumer == consumer &&
 	    (((adapter->cmd_producer + 1) %
 	      adapter->max_tx_desc_count) == adapter->last_cmd_consumer)) {
-		consumer = *(adapter->cmd_consumer);
+		consumer = le32_to_cpu(*(adapter->cmd_consumer));
 	}
 	done = (adapter->last_cmd_consumer == consumer);
 
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 69c1b9d..c2da7ec 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -434,12 +434,13 @@ #endif
 		adapter->port_count++;
 		adapter->port[i] = port;
 	}
-
+#ifndef CONFIG_PPC64
 	writel(0, NETXEN_CRB_NORMALIZE(adapter, CRB_CMDPEG_STATE));
 	netxen_pinit_from_rom(adapter, 0);
 	udelay(500);
 	netxen_load_firmware(adapter);
 	netxen_phantom_init(adapter, NETXEN_NIC_PEG_TUNE);
+#endif
 	/*
 	 * delay a while to ensure that the Pegs are up & running.
 	 * Otherwise, we might see some flaky behaviour.
diff --git a/drivers/net/netxen/netxen_nic_niu.c b/drivers/net/netxen/netxen_nic_niu.c
index 40d7003..d5d9507 100644
--- a/drivers/net/netxen/netxen_nic_niu.c
+++ b/drivers/net/netxen/netxen_nic_niu.c
@@ -458,7 +458,7 @@ int netxen_niu_gbe_init_port(struct netx
 
 int netxen_niu_xg_init_port(struct netxen_adapter *adapter, int port)
 {
-	long reg = 0, ret = 0;
+	u32 reg = 0, ret = 0;
 
 	if (adapter->ahw.boardcfg.board_type == NETXEN_BRDTYPE_P2_SB31_10G_IMEZ) {
 		netxen_crb_writelit_adapter(adapter,
