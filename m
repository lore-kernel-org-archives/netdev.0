From: Nathan Fontenot <nfont@linux.vnet.ibm.com>
Subject: [PATCH net-next 2/7] ibmvnic: Insert header on VLAN tagged received
 frame
Date: Fri, 21 Apr 2017 15:38:46 -0400
Message-ID: <20170421193846.11030.51150.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
References: <20170421193627.11030.34813.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: brking@linux.vnet.ibm.com, jallen@linux.vnet.ibm.com,
        muvic@linux.vnet.ibm.com, tlfalcon@linux.vnet.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:45799 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1161318AbdDUSKP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2017 14:10:15 -0400
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3LFmlBp034881
        for <netdev@vger.kernel.org>; Fri, 21 Apr 2017 11:49:52 -0400
Received: from e13.ny.us.ibm.com (e13.ny.us.ibm.com [129.33.205.203])
        by mx0a-001b2d01.pphosted.com with ESMTP id 29xyxdnaut-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 21 Apr 2017 11:49:52 -0400
Received: from localhost
        by e13.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <nfont@linux.vnet.ibm.com>;
        Fri, 21 Apr 2017 11:49:51 -0400
In-Reply-To: <20170421193627.11030.34813.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Murilo Fossa Vicentini <muvic@linux.vnet.ibm.com>

This patch addresses a modification in the PAPR+ specification which now
defines a previously reserved value for vNIC capabilities. It indicates
whether the system firmware performs a VLAN header stripping on all VLAN
tagged received frames, in case it does, the behavior expected is for
the ibmvnic driver to be responsible for inserting the VLAN header.

Reported-by: Manvanthara B. Puttashankar <mputtash@in.ibm.com>
Signed-off-by: Murilo Fossa Vicentini <muvic@linux.vnet.ibm.com>
---
 drivers/net/ethernet/ibm/ibmvnic.c |   21 ++++++++++++++++++++-
 drivers/net/ethernet/ibm/ibmvnic.h |    2 ++
 2 files changed, 22 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
index 7f4cecb..0f359543 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.c
+++ b/drivers/net/ethernet/ibm/ibmvnic.c
@@ -74,6 +74,7 @@
 #include <linux/uaccess.h>
 #include <asm/firmware.h>
 #include <linux/workqueue.h>
+#include <linux/if_vlan.h>
 
 #include "ibmvnic.h"
 
@@ -1105,7 +1106,15 @@ static int ibmvnic_poll(struct napi_struct *napi, int budget)
 		skb = rx_buff->skb;
 		skb_copy_to_linear_data(skb, rx_buff->data + offset,
 					length);
-		skb->vlan_tci = be16_to_cpu(next->rx_comp.vlan_tci);
+
+		/* VLAN Header has been stripped by the system firmware and
+		 * needs to be inserted by the driver
+		 */
+		if (adapter->rx_vlan_header_insertion &&
+		    (flags & IBMVNIC_VLAN_STRIPPED))
+			__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q),
+					       ntohs(next->rx_comp.vlan_tci));
+
 		/* free the entry */
 		next->rx_comp.first = 0;
 		remove_buff_from_pool(adapter, rx_buff);
@@ -2170,6 +2179,10 @@ static void send_cap_queries(struct ibmvnic_adapter *adapter)
 	atomic_inc(&adapter->running_cap_crqs);
 	ibmvnic_send_crq(adapter, &crq);
 
+	crq.query_capability.capability = cpu_to_be16(RX_VLAN_HEADER_INSERTION);
+	atomic_inc(&adapter->running_cap_crqs);
+	ibmvnic_send_crq(adapter, &crq);
+
 	crq.query_capability.capability = cpu_to_be16(MAX_TX_SG_ENTRIES);
 	atomic_inc(&adapter->running_cap_crqs);
 	ibmvnic_send_crq(adapter, &crq);
@@ -2719,6 +2732,12 @@ static void handle_query_cap_rsp(union ibmvnic_crq *crq,
 		netdev_dbg(netdev, "vlan_header_insertion = %lld\n",
 			   adapter->vlan_header_insertion);
 		break;
+	case RX_VLAN_HEADER_INSERTION:
+		adapter->rx_vlan_header_insertion =
+		    be64_to_cpu(crq->query_capability.number);
+		netdev_dbg(netdev, "rx_vlan_header_insertion = %lld\n",
+			   adapter->rx_vlan_header_insertion);
+		break;
 	case MAX_TX_SG_ENTRIES:
 		adapter->max_tx_sg_entries =
 		    be64_to_cpu(crq->query_capability.number);
diff --git a/drivers/net/ethernet/ibm/ibmvnic.h b/drivers/net/ethernet/ibm/ibmvnic.h
index 355225c..387c843 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.h
+++ b/drivers/net/ethernet/ibm/ibmvnic.h
@@ -733,6 +733,7 @@ enum ibmvnic_capabilities {
 	REQ_MTU = 21,
 	MAX_MULTICAST_FILTERS = 22,
 	VLAN_HEADER_INSERTION = 23,
+	RX_VLAN_HEADER_INSERTION = 24,
 	MAX_TX_SG_ENTRIES = 25,
 	RX_SG_SUPPORTED = 26,
 	RX_SG_REQUESTED = 27,
@@ -993,6 +994,7 @@ struct ibmvnic_adapter {
 	u64 req_mtu;
 	u64 max_multicast_filters;
 	u64 vlan_header_insertion;
+	u64 rx_vlan_header_insertion;
 	u64 max_tx_sg_entries;
 	u64 rx_sg_supported;
 	u64 rx_sg_requested;
