From: "Bryan O'Sullivan" <bos@pathscale.com>
Subject: [PATCH 9 of 39] IB/ipath - don't allow
 resources to be created with illegal values
Date: Thu, 29 Jun 2006 14:41:00 -0700
Message-ID: <ac81d2563bbaf9c23dae.1151617260@eng-12.pathscale.com>
References: <patchbomb.1151617251@eng-12.pathscale.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
In-Reply-To: <patchbomb.1151617251@eng-12.pathscale.com>
To: akpm@osdl.org,
	rdreier@cisco.com,
	mst@mellanox.co.il
List-Unsubscribe: <http://openib.org/mailman/listinfo/openib-general>,
 <mailto:openib-general-request@openib.org?subject=unsubscribe>
List-Archive: <http://openib.org/pipermail/openib-general>
List-Post: <mailto:openib-general@openib.org>
List-Help: <mailto:openib-general-request@openib.org?subject=help>
List-Subscribe: <http://openib.org/mailman/listinfo/openib-general>,
 <mailto:openib-general-request@openib.org?subject=subscribe>
Sender: openib-general-bounces@openib.org
Errors-To: openib-general-bounces@openib.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Robert Walsh <robert.walsh@qlogic.com>
Signed-off-by: Bryan O'Sullivan <bryan.osullivan@qlogic.com>

diff -r 081142011371 -r ac81d2563bba drivers/infiniband/hw/ipath/ipath_mr.c
--- a/drivers/infiniband/hw/ipath/ipath_mr.c	Thu Jun 29 14:33:25 2006 -0700
+++ b/drivers/infiniband/hw/ipath/ipath_mr.c	Thu Jun 29 14:33:25 2006 -0700
@@ -169,6 +169,11 @@ struct ib_mr *ipath_reg_user_mr(struct i
 	struct ib_umem_chunk *chunk;
 	int n, m, i;
 	struct ib_mr *ret;
+
+	if (region->length == 0) {
+		ret = ERR_PTR(-EINVAL);
+		goto bail;
+	}
 
 	n = 0;
 	list_for_each_entry(chunk, &region->chunk_list, list)
diff -r 081142011371 -r ac81d2563bba drivers/infiniband/hw/ipath/ipath_qp.c
--- a/drivers/infiniband/hw/ipath/ipath_qp.c	Thu Jun 29 14:33:25 2006 -0700
+++ b/drivers/infiniband/hw/ipath/ipath_qp.c	Thu Jun 29 14:33:25 2006 -0700
@@ -667,6 +667,14 @@ struct ib_qp *ipath_create_qp(struct ib_
 		goto bail;
 	}
 
+	if (init_attr->cap.max_send_sge +
+	    init_attr->cap.max_recv_sge +
+	    init_attr->cap.max_send_wr +
+	    init_attr->cap.max_recv_wr == 0) {
+		ret = ERR_PTR(-EINVAL);
+		goto bail;
+	}
+
 	switch (init_attr->qp_type) {
 	case IB_QPT_UC:
 	case IB_QPT_RC:
diff -r 081142011371 -r ac81d2563bba drivers/infiniband/hw/ipath/ipath_verbs.c
--- a/drivers/infiniband/hw/ipath/ipath_verbs.c	Thu Jun 29 14:33:25 2006 -0700
+++ b/drivers/infiniband/hw/ipath/ipath_verbs.c	Thu Jun 29 14:33:25 2006 -0700
@@ -788,6 +788,17 @@ static struct ib_ah *ipath_create_ah(str
 	if (ah_attr->dlid >= IPS_MULTICAST_LID_BASE &&
 	    ah_attr->dlid != IPS_PERMISSIVE_LID &&
 	    !(ah_attr->ah_flags & IB_AH_GRH)) {
+		ret = ERR_PTR(-EINVAL);
+		goto bail;
+	}
+
+	if (ah_attr->dlid == 0) {
+		ret = ERR_PTR(-EINVAL);
+		goto bail;
+	}
+
+	if (ah_attr->port_num != 1 ||
+	    ah_attr->port_num > pd->device->phys_port_cnt) {
 		ret = ERR_PTR(-EINVAL);
 		goto bail;
 	}
