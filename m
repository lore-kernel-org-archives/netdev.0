From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 1/6] cxgb4: Free Virtual Interfaces in remove routine
Date: Fri,  5 Jun 2015 14:24:47 +0530
Message-ID: <1433494492-7638-2-git-send-email-hariprasad@chelsio.com>
References: <1433494492-7638-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:16485 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754014AbbFEDlk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jun 2015 23:41:40 -0400
In-Reply-To: <1433494492-7638-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Free VI interfaces in remove routine. If we don't do this then the
firmware will never drop the physical link to the peer.

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h      |  3 +++
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |  5 +++++
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c      | 27 +++++++++++++++++++++++++
 3 files changed, 35 insertions(+)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
index bf2b822..93e6cbc 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
@@ -1378,6 +1378,9 @@ int t4_cfg_pfvf(struct adapter *adap, unsigned int mbox, unsigned int pf,
 int t4_alloc_vi(struct adapter *adap, unsigned int mbox, unsigned int port,
 		unsigned int pf, unsigned int vf, unsigned int nmac, u8 *mac,
 		unsigned int *rss_size);
+int t4_free_vi(struct adapter *adap, unsigned int mbox,
+	       unsigned int pf, unsigned int vf,
+	       unsigned int viid);
 int t4_set_rxmode(struct adapter *adap, unsigned int mbox, unsigned int viid,
 		int mtu, int promisc, int all_multi, int bcast, int vlanex,
 		bool sleep_ok);
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 3057154..e6abdb7 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -4538,6 +4538,11 @@ static void free_some_resources(struct adapter *adapter)
 
 	for_each_port(adapter, i)
 		if (adapter->port[i]) {
+			struct port_info *pi = adap2pinfo(adapter, i);
+
+			if (pi->viid != 0)
+				t4_free_vi(adapter, adapter->mbox, adapter->pf,
+					   0, pi->viid);
 			kfree(adap2pinfo(adapter, i)->rss);
 			free_netdev(adapter->port[i]);
 		}
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index c21ab26..3a56254 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -5226,6 +5226,33 @@ int t4_alloc_vi(struct adapter *adap, unsigned int mbox, unsigned int port,
 }
 
 /**
+ *	t4_free_vi - free a virtual interface
+ *	@adap: the adapter
+ *	@mbox: mailbox to use for the FW command
+ *	@pf: the PF owning the VI
+ *	@vf: the VF owning the VI
+ *	@viid: virtual interface identifiler
+ *
+ *	Free a previously allocated virtual interface.
+ */
+int t4_free_vi(struct adapter *adap, unsigned int mbox, unsigned int pf,
+	       unsigned int vf, unsigned int viid)
+{
+	struct fw_vi_cmd c;
+
+	memset(&c, 0, sizeof(c));
+	c.op_to_vfn = cpu_to_be32(FW_CMD_OP_V(FW_VI_CMD) |
+				  FW_CMD_REQUEST_F |
+				  FW_CMD_EXEC_F |
+				  FW_VI_CMD_PFN_V(pf) |
+				  FW_VI_CMD_VFN_V(vf));
+	c.alloc_to_len16 = cpu_to_be32(FW_VI_CMD_FREE_F | FW_LEN16(c));
+	c.type_viid = cpu_to_be16(FW_VI_CMD_VIID_V(viid));
+
+	return t4_wr_mbox(adap, mbox, &c, sizeof(c), &c);
+}
+
+/**
  *	t4_set_rxmode - set Rx properties of a virtual interface
  *	@adap: the adapter
  *	@mbox: mailbox to use for the FW command
-- 
2.3.4
