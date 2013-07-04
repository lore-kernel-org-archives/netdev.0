From: Vipul Pandya <vipul@chelsio.com>
Subject: [PATCH V3 2/4] cxgb4: Add routines to create and remove listening IPv6 servers
Date: Thu,  4 Jul 2013 16:10:45 +0530
Message-ID: <1372934447-16556-3-git-send-email-vipul@chelsio.com>
References: <1372934447-16556-1-git-send-email-vipul@chelsio.com>
Cc: roland@purestorage.com, davem@davemloft.net, divy@chelsio.com,
	dm@chelsio.com, swise@opengridcomputing.com, roland@kernel.org,
	sean.hefty@intel.com, hal.rosenstock@gmail.com,
	tom@opengridcomputing.com, faisal.latif@intel.com,
	tatyana.e.nikolova@intel.com, akpm@linux-foundation.org,
	sasha.levin@oracle.com, vipul@chelsio.com, hariprasad@chelsio.com,
	nirranjan@chelsio.com
To: linux-rdma@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:4890 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755186Ab3GDKrt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jul 2013 06:47:49 -0400
In-Reply-To: <1372934447-16556-1-git-send-email-vipul@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add cxgb4_create_server6 and cxgb4_remove_server routines to create and remove
listening IPv6 servers.

Return success (0) from cxgb4_create_server in case of ctrl queue congestion
since in case of congestion, passive open request gets queued and gets
processed later. If non zero value is returned it can be treated as an error
and ULD can free STID which can result into an error in passive open reply.

Add cpl structure for active open request with IPv6 address for T5.

Signed-off-by: Vipul Pandya <vipul@chelsio.com>
---
V2: Used local variables instead of typecasting in patch 1/4.
V3: Removed dereferencing ep before initializing it in patch 4/4.

 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 71 ++++++++++++++++++++++++-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h  |  5 ++
 drivers/net/ethernet/chelsio/cxgb4/t4_msg.h     | 17 +++++-
 3 files changed, 91 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 5a3256b..d1d6ff7 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -3246,6 +3246,7 @@ int cxgb4_create_server(const struct net_device *dev, unsigned int stid,
 	struct sk_buff *skb;
 	struct adapter *adap;
 	struct cpl_pass_open_req *req;
+	int ret;
 
 	skb = alloc_skb(sizeof(*req), GFP_KERNEL);
 	if (!skb)
@@ -3263,10 +3264,78 @@ int cxgb4_create_server(const struct net_device *dev, unsigned int stid,
 	req->opt0 = cpu_to_be64(TX_CHAN(chan));
 	req->opt1 = cpu_to_be64(CONN_POLICY_ASK |
 				SYN_RSS_ENABLE | SYN_RSS_QUEUE(queue));
-	return t4_mgmt_tx(adap, skb);
+	ret = t4_mgmt_tx(adap, skb);
+	return net_xmit_eval(ret);
 }
 EXPORT_SYMBOL(cxgb4_create_server);
 
+/*	cxgb4_create_server6 - create an IPv6 server
+ *	@dev: the device
+ *	@stid: the server TID
+ *	@sip: local IPv6 address to bind server to
+ *	@sport: the server's TCP port
+ *	@queue: queue to direct messages from this server to
+ *
+ *	Create an IPv6 server for the given port and address.
+ *	Returns <0 on error and one of the %NET_XMIT_* values on success.
+ */
+int cxgb4_create_server6(const struct net_device *dev, unsigned int stid,
+			 const struct in6_addr *sip, __be16 sport,
+			 unsigned int queue)
+{
+	unsigned int chan;
+	struct sk_buff *skb;
+	struct adapter *adap;
+	struct cpl_pass_open_req6 *req;
+	int ret;
+
+	skb = alloc_skb(sizeof(*req), GFP_KERNEL);
+	if (!skb)
+		return -ENOMEM;
+
+	adap = netdev2adap(dev);
+	req = (struct cpl_pass_open_req6 *)__skb_put(skb, sizeof(*req));
+	INIT_TP_WR(req, 0);
+	OPCODE_TID(req) = htonl(MK_OPCODE_TID(CPL_PASS_OPEN_REQ6, stid));
+	req->local_port = sport;
+	req->peer_port = htons(0);
+	req->local_ip_hi = *(__be64 *)(sip->s6_addr);
+	req->local_ip_lo = *(__be64 *)(sip->s6_addr + 8);
+	req->peer_ip_hi = cpu_to_be64(0);
+	req->peer_ip_lo = cpu_to_be64(0);
+	chan = rxq_to_chan(&adap->sge, queue);
+	req->opt0 = cpu_to_be64(TX_CHAN(chan));
+	req->opt1 = cpu_to_be64(CONN_POLICY_ASK |
+				SYN_RSS_ENABLE | SYN_RSS_QUEUE(queue));
+	ret = t4_mgmt_tx(adap, skb);
+	return net_xmit_eval(ret);
+}
+EXPORT_SYMBOL(cxgb4_create_server6);
+
+int cxgb4_remove_server(const struct net_device *dev, unsigned int stid,
+			unsigned int queue, bool ipv6)
+{
+	struct sk_buff *skb;
+	struct adapter *adap;
+	struct cpl_close_listsvr_req *req;
+	int ret;
+
+	adap = netdev2adap(dev);
+
+	skb = alloc_skb(sizeof(*req), GFP_KERNEL);
+	if (!skb)
+		return -ENOMEM;
+
+	req = (struct cpl_close_listsvr_req *)__skb_put(skb, sizeof(*req));
+	INIT_TP_WR(req, 0);
+	OPCODE_TID(req) = htonl(MK_OPCODE_TID(CPL_CLOSE_LISTSRV_REQ, stid));
+	req->reply_ctrl = htons(NO_REPLY(0) | (ipv6 ? LISTSVR_IPV6(1) :
+				LISTSVR_IPV6(0)) | QUEUENO(queue));
+	ret = t4_mgmt_tx(adap, skb);
+	return net_xmit_eval(ret);
+}
+EXPORT_SYMBOL(cxgb4_remove_server);
+
 /**
  *	cxgb4_best_mtu - find the entry in the MTU table closest to an MTU
  *	@mtus: the HW MTU table
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h
index 4faf4d0..6f21f24 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h
@@ -154,6 +154,11 @@ struct in6_addr;
 int cxgb4_create_server(const struct net_device *dev, unsigned int stid,
 			__be32 sip, __be16 sport, __be16 vlan,
 			unsigned int queue);
+int cxgb4_create_server6(const struct net_device *dev, unsigned int stid,
+			 const struct in6_addr *sip, __be16 sport,
+			 unsigned int queue);
+int cxgb4_remove_server(const struct net_device *dev, unsigned int stid,
+			unsigned int queue, bool ipv6);
 int cxgb4_create_server_filter(const struct net_device *dev, unsigned int stid,
 			       __be32 sip, __be16 sport, __be16 vlan,
 			       unsigned int queue,
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h b/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h
index 01d4844..cd6874b 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h
@@ -320,6 +320,21 @@ struct cpl_act_open_req6 {
 	__be32 opt2;
 };
 
+struct cpl_t5_act_open_req6 {
+	WR_HDR;
+	union opcode_tid ot;
+	__be16 local_port;
+	__be16 peer_port;
+	__be64 local_ip_hi;
+	__be64 local_ip_lo;
+	__be64 peer_ip_hi;
+	__be64 peer_ip_lo;
+	__be64 opt0;
+	__be32 rsvd;
+	__be32 opt2;
+	__be64 params;
+};
+
 struct cpl_act_open_rpl {
 	union opcode_tid ot;
 	__be32 atid_status;
@@ -405,7 +420,7 @@ struct cpl_close_listsvr_req {
 	WR_HDR;
 	union opcode_tid ot;
 	__be16 reply_ctrl;
-#define LISTSVR_IPV6 (1 << 14)
+#define LISTSVR_IPV6(x) ((x) << 14)
 	__be16 rsvd;
 };
 
-- 
1.8.0
