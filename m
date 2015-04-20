From: Haggai Eran <haggaie@mellanox.com>
Subject: [PATCH v2 03/11] IB/core: Pass network namespace as a parameter to relevant functions
Date: Mon, 20 Apr 2015 12:03:34 +0300
Message-ID: <1429520622-10303-4-git-send-email-haggaie@mellanox.com>
References: <1429520622-10303-1-git-send-email-haggaie@mellanox.com>
Cc: Sean Hefty <sean.hefty@intel.com>, linux-rdma@vger.kernel.org,
	netdev@vger.kernel.org, Liran Liss <liranl@mellanox.com>,
	Guy Shapiro <guysh@mellanox.com>,
	Shachar Raindel <raindel@mellanox.com>,
	Yotam Kenneth <yotamke@mellanox.com>,
	Haggai Eran <haggaie@mellanox.com>
To: Doug Ledford <dledford@redhat.com>,
	Roland Dreier <roland@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1327.ztomy.com ([193.47.165.129]:44648 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754612AbbDTJEr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Apr 2015 05:04:47 -0400
In-Reply-To: <1429520622-10303-1-git-send-email-haggaie@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guy Shapiro <guysh@mellanox.com>

Add network namespace parameters for the address related ib_core
functions. The parameter is passed to lower level function, instead of
&init_net, so things are done in the correct namespace.

For now pass &init_net on every caller.
Callers that will pass &init_net permanently are marked with an
appropriate comment.

Signed-off-by: Haggai Eran <haggaie@mellanox.com>
Signed-off-by: Yotam Kenneth <yotamke@mellanox.com>
Signed-off-by: Shachar Raindel <raindel@mellanox.com>
Signed-off-by: Guy Shapiro <guysh@mellanox.com>
---
 drivers/infiniband/core/agent.c       |  4 +++-
 drivers/infiniband/core/cm.c          |  9 +++++++--
 drivers/infiniband/core/mad_rmpp.c    | 10 ++++++++--
 drivers/infiniband/core/user_mad.c    |  4 +++-
 drivers/infiniband/core/verbs.c       | 10 ++++++----
 drivers/infiniband/ulp/srpt/ib_srpt.c |  3 ++-
 include/rdma/ib_verbs.h               | 15 +++++++++++++--
 7 files changed, 42 insertions(+), 13 deletions(-)

diff --git a/drivers/infiniband/core/agent.c b/drivers/infiniband/core/agent.c
index f6d29614cb01..539378d64041 100644
--- a/drivers/infiniband/core/agent.c
+++ b/drivers/infiniband/core/agent.c
@@ -99,7 +99,9 @@ void agent_send_response(struct ib_mad *mad, struct ib_grh *grh,
 	}
 
 	agent = port_priv->agent[qpn];
-	ah = ib_create_ah_from_wc(agent->qp->pd, wc, grh, port_num);
+	/* Physical devices (and their MAD replies) always reside in the host
+	 * network namespace */
+	ah = ib_create_ah_from_wc(agent->qp->pd, wc, grh, port_num, &init_net);
 	if (IS_ERR(ah)) {
 		dev_err(&device->dev, "ib_create_ah_from_wc error %ld\n",
 			PTR_ERR(ah));
diff --git a/drivers/infiniband/core/cm.c b/drivers/infiniband/core/cm.c
index e28a494e2a3a..5a45cb76c43e 100644
--- a/drivers/infiniband/core/cm.c
+++ b/drivers/infiniband/core/cm.c
@@ -290,8 +290,13 @@ static int cm_alloc_response_msg(struct cm_port *port,
 	struct ib_mad_send_buf *m;
 	struct ib_ah *ah;
 
+	/* For IB, the network namespace doesn't affect the created address
+	 * handle, so we use &init_net. In the future, RoCE support will
+	 * require finding a specific network namespace to send the response
+	 * from. */
 	ah = ib_create_ah_from_wc(port->mad_agent->qp->pd, mad_recv_wc->wc,
-				  mad_recv_wc->recv_buf.grh, port->port_num);
+				  mad_recv_wc->recv_buf.grh, port->port_num,
+				  &init_net);
 	if (IS_ERR(ah))
 		return PTR_ERR(ah);
 
@@ -346,7 +351,7 @@ static void cm_init_av_for_response(struct cm_port *port, struct ib_wc *wc,
 	av->port = port;
 	av->pkey_index = wc->pkey_index;
 	ib_init_ah_from_wc(port->cm_dev->ib_device, port->port_num, wc,
-			   grh, &av->ah_attr);
+			   grh, &av->ah_attr, &init_net);
 }
 
 static int cm_init_av_by_path(struct ib_sa_path_rec *path, struct cm_av *av)
diff --git a/drivers/infiniband/core/mad_rmpp.c b/drivers/infiniband/core/mad_rmpp.c
index f37878c9c06e..6c1576202965 100644
--- a/drivers/infiniband/core/mad_rmpp.c
+++ b/drivers/infiniband/core/mad_rmpp.c
@@ -157,8 +157,11 @@ static struct ib_mad_send_buf *alloc_response_msg(struct ib_mad_agent *agent,
 	struct ib_ah *ah;
 	int hdr_len;
 
+	/* Physical devices (and their MAD replies) always reside in the host
+	 * network namespace */
 	ah = ib_create_ah_from_wc(agent->qp->pd, recv_wc->wc,
-				  recv_wc->recv_buf.grh, agent->port_num);
+				  recv_wc->recv_buf.grh, agent->port_num,
+				  &init_net);
 	if (IS_ERR(ah))
 		return (void *) ah;
 
@@ -287,10 +290,13 @@ create_rmpp_recv(struct ib_mad_agent_private *agent,
 	if (!rmpp_recv)
 		return NULL;
 
+	/* Physical devices (and their MAD replies) always reside in the host
+	 * network namespace */
 	rmpp_recv->ah = ib_create_ah_from_wc(agent->agent.qp->pd,
 					     mad_recv_wc->wc,
 					     mad_recv_wc->recv_buf.grh,
-					     agent->agent.port_num);
+					     agent->agent.port_num,
+					     &init_net);
 	if (IS_ERR(rmpp_recv->ah))
 		goto error;
 
diff --git a/drivers/infiniband/core/user_mad.c b/drivers/infiniband/core/user_mad.c
index 928cdd20e2d1..f34c6077759d 100644
--- a/drivers/infiniband/core/user_mad.c
+++ b/drivers/infiniband/core/user_mad.c
@@ -239,7 +239,9 @@ static void recv_handler(struct ib_mad_agent *agent,
 
 		ib_init_ah_from_wc(agent->device, agent->port_num,
 				   mad_recv_wc->wc, mad_recv_wc->recv_buf.grh,
-				   &ah_attr);
+				   &ah_attr, &init_net);
+		/* Note that network namespace seperation isn't supported on
+		 * umad yet. */
 
 		packet->mad.hdr.gid_index = ah_attr.grh.sgid_index;
 		packet->mad.hdr.hop_limit = ah_attr.grh.hop_limit;
diff --git a/drivers/infiniband/core/verbs.c b/drivers/infiniband/core/verbs.c
index ca5c4dd8a67a..a51d5d642fb7 100644
--- a/drivers/infiniband/core/verbs.c
+++ b/drivers/infiniband/core/verbs.c
@@ -193,7 +193,8 @@ struct ib_ah *ib_create_ah(struct ib_pd *pd, struct ib_ah_attr *ah_attr)
 EXPORT_SYMBOL(ib_create_ah);
 
 int ib_init_ah_from_wc(struct ib_device *device, u8 port_num, struct ib_wc *wc,
-		       struct ib_grh *grh, struct ib_ah_attr *ah_attr)
+		       struct ib_grh *grh, struct ib_ah_attr *ah_attr,
+		       struct net *net)
 {
 	u32 flow_class;
 	u16 gid_index;
@@ -214,7 +215,7 @@ int ib_init_ah_from_wc(struct ib_device *device, u8 port_num, struct ib_wc *wc,
 			ret = rdma_addr_find_dmac_by_grh(&grh->dgid, &grh->sgid,
 							 ah_attr->dmac,
 							 &ah_attr->vlan_id,
-							 &init_net);
+							 net);
 			if (ret)
 				return ret;
 		}
@@ -247,12 +248,13 @@ int ib_init_ah_from_wc(struct ib_device *device, u8 port_num, struct ib_wc *wc,
 EXPORT_SYMBOL(ib_init_ah_from_wc);
 
 struct ib_ah *ib_create_ah_from_wc(struct ib_pd *pd, struct ib_wc *wc,
-				   struct ib_grh *grh, u8 port_num)
+				   struct ib_grh *grh, u8 port_num,
+				   struct net *net)
 {
 	struct ib_ah_attr ah_attr;
 	int ret;
 
-	ret = ib_init_ah_from_wc(pd->device, port_num, wc, grh, &ah_attr);
+	ret = ib_init_ah_from_wc(pd->device, port_num, wc, grh, &ah_attr, net);
 	if (ret)
 		return ERR_PTR(ret);
 
diff --git a/drivers/infiniband/ulp/srpt/ib_srpt.c b/drivers/infiniband/ulp/srpt/ib_srpt.c
index 4b9b866e6b0d..a95e7d51cd8b 100644
--- a/drivers/infiniband/ulp/srpt/ib_srpt.c
+++ b/drivers/infiniband/ulp/srpt/ib_srpt.c
@@ -467,7 +467,8 @@ static void srpt_mad_recv_handler(struct ib_mad_agent *mad_agent,
 		return;
 
 	ah = ib_create_ah_from_wc(mad_agent->qp->pd, mad_wc->wc,
-				  mad_wc->recv_buf.grh, mad_agent->port_num);
+				  mad_wc->recv_buf.grh, mad_agent->port_num,
+				  &init_net);
 	if (IS_ERR(ah))
 		goto err;
 
diff --git a/include/rdma/ib_verbs.h b/include/rdma/ib_verbs.h
index 65994a19e840..f4a85decc60f 100644
--- a/include/rdma/ib_verbs.h
+++ b/include/rdma/ib_verbs.h
@@ -48,6 +48,7 @@
 #include <linux/rwsem.h>
 #include <linux/scatterlist.h>
 #include <linux/workqueue.h>
+#include <net/net_namespace.h>
 #include <uapi/linux/if_ether.h>
 
 #include <linux/atomic.h>
@@ -1798,9 +1799,14 @@ struct ib_ah *ib_create_ah(struct ib_pd *pd, struct ib_ah_attr *ah_attr);
  *   ignored unless the work completion indicates that the GRH is valid.
  * @ah_attr: Returned attributes that can be used when creating an address
  *   handle for replying to the message.
+ * @net: The network namespace to use for address resolution.
+ *
+ * It is the caller's responsibility to make sure the network namespace is
+ * alive until the function returns.
  */
 int ib_init_ah_from_wc(struct ib_device *device, u8 port_num, struct ib_wc *wc,
-		       struct ib_grh *grh, struct ib_ah_attr *ah_attr);
+		       struct ib_grh *grh, struct ib_ah_attr *ah_attr,
+		       struct net *net);
 
 /**
  * ib_create_ah_from_wc - Creates an address handle associated with the
@@ -1810,12 +1816,17 @@ int ib_init_ah_from_wc(struct ib_device *device, u8 port_num, struct ib_wc *wc,
  * @grh: References the received global route header.  This parameter is
  *   ignored unless the work completion indicates that the GRH is valid.
  * @port_num: The outbound port number to associate with the address.
+ * @net: The network namespace to use for address resolution.
  *
  * The address handle is used to reference a local or global destination
  * in all UD QP post sends.
+ *
+ * It is the caller's responsibility to make sure the network namespace is
+ * alive until the function returns.
  */
 struct ib_ah *ib_create_ah_from_wc(struct ib_pd *pd, struct ib_wc *wc,
-				   struct ib_grh *grh, u8 port_num);
+				   struct ib_grh *grh, u8 port_num,
+				   struct net *net);
 
 /**
  * ib_modify_ah - Modifies the address vector associated with an address
-- 
1.7.11.2
