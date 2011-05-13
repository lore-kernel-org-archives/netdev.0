From: Roland Dreier <roland@kernel.org>
Subject: [RFC 3/3] RDMA/cma: Save PID of ID's owner
Date: Fri, 13 May 2011 09:18:45 -0700
Message-ID: <1305303525-11113-4-git-send-email-roland@kernel.org>
References: <1305303525-11113-1-git-send-email-roland@kernel.org>
To: netdev@vger.kernel.org, linux-rdma@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys010aog102.obsmtp.com ([74.125.245.72]:43044 "HELO
	na3sys010aog102.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1759486Ab1EMQS4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2011 12:18:56 -0400
In-Reply-To: <1305303525-11113-1-git-send-email-roland@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nir Muchtar <nirm@voltaire.com>

[Dave please do not apply even if this ends up in netdev patchwork!]

Save the PID associated with an RDMA CM ID for reporting via netlink.

NOT-Signed-off-by: Nir Muchtar <nirm@voltaire.com>
NOT-Signed-off-by: Roland Dreier <roland@purestorage.com>
---
 drivers/infiniband/core/cma.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/drivers/infiniband/core/cma.c b/drivers/infiniband/core/cma.c
index d4701a8..1e25434 100644
--- a/drivers/infiniband/core/cma.c
+++ b/drivers/infiniband/core/cma.c
@@ -133,6 +133,7 @@ struct rdma_id_private {
 	u32			seq_num;
 	u32			qkey;
 	u32			qp_num;
+	pid_t			owner;
 	u8			srq;
 	u8			tos;
 };
@@ -423,6 +424,7 @@ struct rdma_cm_id *rdma_create_id(rdma_cm_event_handler event_handler,
 	if (!id_priv)
 		return ERR_PTR(-ENOMEM);
 
+	id_priv->owner = task_pid_nr(current);
 	id_priv->state = RDMA_CM_IDLE;
 	id_priv->id.context = context;
 	id_priv->id.event_handler = event_handler;
@@ -2678,6 +2680,9 @@ int rdma_accept(struct rdma_cm_id *id, struct rdma_conn_param *conn_param)
 	int ret;
 
 	id_priv = container_of(id, struct rdma_id_private, id);
+
+	id_priv->owner = task_pid_nr(current);
+
 	if (!cma_comp(id_priv, RDMA_CM_CONNECT))
 		return -EINVAL;
 
@@ -3320,6 +3325,7 @@ static int cma_get_id_stats(struct sk_buff *skb, struct netlink_callback *cb)
 			id_stats->port_space = id->ps;
 			id_stats->cm_state = id_priv->state;
 			id_stats->qp_num = id_priv->qp_num;
+			id_stats->pid = id_priv->owner;
 
 			i_id++;
 		}
-- 
1.7.4.1

