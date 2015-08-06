From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 4/7] mlxsw: Strip FCS from incoming packets
Date: Thu,  6 Aug 2015 16:41:55 +0200
Message-ID: <1438872118-16869-5-git-send-email-jiri@resnulli.us>
References: <1438872118-16869-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	ogerlitz@mellanox.com, Jiri Pirko <jiri@mellanox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f171.google.com ([209.85.212.171]:38134 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754755AbbHFOmM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Aug 2015 10:42:12 -0400
Received: by wibxm9 with SMTP id xm9so27415961wib.1
        for <netdev@vger.kernel.org>; Thu, 06 Aug 2015 07:42:11 -0700 (PDT)
In-Reply-To: <1438872118-16869-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

FCS of incoming packets is already checked by HW. Just strip it out.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/pci.c | 6 +++++-
 drivers/net/ethernet/mellanox/mlxsw/pci.h | 6 ++++++
 2 files changed, 11 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/pci.c b/drivers/net/ethernet/mellanox/mlxsw/pci.c
index 298ead5..3ec52ea 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/pci.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/pci.c
@@ -667,6 +667,7 @@ static void mlxsw_pci_cqe_rdq_handle(struct mlxsw_pci *mlxsw_pci,
 	char *wqe;
 	struct sk_buff *skb;
 	struct mlxsw_rx_info rx_info;
+	u16 byte_count;
 	int err;
 
 	elem_info = mlxsw_pci_queue_elem_info_consumer_get(q);
@@ -686,7 +687,10 @@ static void mlxsw_pci_cqe_rdq_handle(struct mlxsw_pci *mlxsw_pci,
 	rx_info.sys_port = mlxsw_pci_cqe_system_port_get(cqe);
 	rx_info.trap_id = mlxsw_pci_cqe_trap_id_get(cqe);
 
-	skb_put(skb, mlxsw_pci_cqe_byte_count_get(cqe));
+	byte_count = mlxsw_pci_cqe_byte_count_get(cqe);
+	if (mlxsw_pci_cqe_crc_get(cqe))
+		byte_count -= ETH_FCS_LEN;
+	skb_put(skb, byte_count);
 	mlxsw_core_skb_receive(mlxsw_pci->core, skb, &rx_info);
 
 put_new_skb:
diff --git a/drivers/net/ethernet/mellanox/mlxsw/pci.h b/drivers/net/ethernet/mellanox/mlxsw/pci.h
index 887af84..1ef9664 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/pci.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/pci.h
@@ -155,6 +155,12 @@ MLXSW_ITEM32(pci, cqe, byte_count, 0x04, 0, 14);
  */
 MLXSW_ITEM32(pci, cqe, trap_id, 0x08, 0, 8);
 
+/* pci_cqe_crc
+ * Length include CRC. Indicates the length field includes
+ * the packet's CRC.
+ */
+MLXSW_ITEM32(pci, cqe, crc, 0x0C, 8, 1);
+
 /* pci_cqe_e
  * CQE with Error.
  */
-- 
1.9.3
