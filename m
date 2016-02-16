From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH v2 8/8] net: ixgbe: abort with cls u32 divisor
 groups greater than 1
Date: Mon, 15 Feb 2016 22:03:41 -0800
Message-ID: <20160216060341.32452.24832.stgit@john-Precision-Tower-5810>
References: <20160216055819.32452.84181.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us,
	jeffrey.t.kirsher@intel.com
To: amir@vadai.me, john.fastabend@gmail.com, jhs@mojatatu.com,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:34761 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753641AbcBPGEF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2016 01:04:05 -0500
Received: by mail-pa0-f44.google.com with SMTP id fy10so57985635pac.1
        for <netdev@vger.kernel.org>; Mon, 15 Feb 2016 22:04:04 -0800 (PST)
In-Reply-To: <20160216055819.32452.84181.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch ensures ixgbe will not try to offload hash tables from the
u32 module. The device class does not currently support this so until
it is enabled just abort on these tables.

Interestingly the more flexible your hardware is the less code you
need to implement to guard against these cases.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h      |    1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   31 +++++++++++++++++++++++++
 2 files changed, 32 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index fc877c7..84fa28c 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -798,6 +798,7 @@ struct ixgbe_adapter {
 
 #define IXGBE_MAX_LINK_HANDLE 10
 	struct ixgbe_mat_field *jump_tables[IXGBE_MAX_LINK_HANDLE];
+	unsigned long tables;
 
 /* maximum number of RETA entries among all devices supported by ixgbe
  * driver: currently it's x550 device in non-SRIOV mode
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index adbb7c7..3d154c9 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -8217,6 +8217,27 @@ static int ixgbe_delete_clsu32(struct ixgbe_adapter *adapter,
 	return err;
 }
 
+static int ixgbe_configure_clsu32_add_hnode(struct ixgbe_adapter *adapter,
+					    __be16 protocol,
+					    struct tc_cls_u32_offload *cls)
+{
+	/* This ixgbe devices do not support hash tables at the moment
+	 * so abort when given hash tables.
+	 */
+	if (cls->hnode.divisor > 0)
+		return -EINVAL;
+
+	set_bit(TC_U32_USERHTID(cls->hnode.handle), &adapter->tables);
+	return 0;
+}
+
+static int ixgbe_configure_clsu32_del_hnode(struct ixgbe_adapter *adapter,
+					    struct tc_cls_u32_offload *cls)
+{
+	clear_bit(TC_U32_USERHTID(cls->hnode.handle), &adapter->tables);
+	return 0;
+}
+
 static int ixgbe_configure_clsu32(struct ixgbe_adapter *adapter,
 				  __be16 protocol,
 				  struct tc_cls_u32_offload *cls)
@@ -8251,6 +8272,9 @@ static int ixgbe_configure_clsu32(struct ixgbe_adapter *adapter,
 		struct ixgbe_nexthdr *nexthdr = ixgbe_ipv4_jumps;
 		u32 uhtid = TC_U32_USERHTID(cls->knode.link_handle);
 
+		if (!test_bit(uhtid, &adapter->tables))
+			return -EINVAL;
+
 		for (i = 0; nexthdr[i].jump; i++) {
 			if (nexthdr->o != cls->knode.sel->offoff ||
 			    nexthdr->s != cls->knode.sel->offshift ||
@@ -8386,6 +8410,13 @@ int __ixgbe_setup_tc(struct net_device *dev, u32 handle, __be16 proto,
 						      proto, tc->cls_u32);
 		case TC_CLSU32_DELETE_KNODE:
 			return ixgbe_delete_clsu32(adapter, tc->cls_u32);
+		case TC_CLSU32_NEW_HNODE:
+		case TC_CLSU32_REPLACE_HNODE:
+			return ixgbe_configure_clsu32_add_hnode(adapter, proto,
+								tc->cls_u32);
+		case TC_CLSU32_DELETE_HNODE:
+			return ixgbe_configure_clsu32_del_hnode(adapter,
+								tc->cls_u32);
 		default:
 			return -EINVAL;
 		}
