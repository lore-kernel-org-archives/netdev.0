From: "Bryan O'Sullivan" <bos@pathscale.com>
Subject: [PATCH 10 of 39] IB/ipath - fix some memory
 leaks on failure paths
Date: Thu, 29 Jun 2006 14:41:01 -0700
Message-ID: <160e5cf91761a2daf6db.1151617261@eng-12.pathscale.com>
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

diff -r ac81d2563bba -r 160e5cf91761 drivers/infiniband/hw/ipath/ipath_init_chip.c
--- a/drivers/infiniband/hw/ipath/ipath_init_chip.c	Thu Jun 29 14:33:25 2006 -0700
+++ b/drivers/infiniband/hw/ipath/ipath_init_chip.c	Thu Jun 29 14:33:25 2006 -0700
@@ -115,6 +115,7 @@ static int create_port0_egr(struct ipath
 				      "eager TID %u\n", e);
 			while (e != 0)
 				dev_kfree_skb(skbs[--e]);
+			vfree(skbs);
 			ret = -ENOMEM;
 			goto bail;
 		}
diff -r ac81d2563bba -r 160e5cf91761 drivers/infiniband/hw/ipath/ipath_qp.c
--- a/drivers/infiniband/hw/ipath/ipath_qp.c	Thu Jun 29 14:33:25 2006 -0700
+++ b/drivers/infiniband/hw/ipath/ipath_qp.c	Thu Jun 29 14:33:25 2006 -0700
@@ -692,6 +692,7 @@ struct ib_qp *ipath_create_qp(struct ib_
 	case IB_QPT_GSI:
 		qp = kmalloc(sizeof(*qp), GFP_KERNEL);
 		if (!qp) {
+			vfree(swq);
 			ret = ERR_PTR(-ENOMEM);
 			goto bail;
 		}
@@ -702,6 +703,7 @@ struct ib_qp *ipath_create_qp(struct ib_
 		qp->r_rq.wq = vmalloc(qp->r_rq.size * sz);
 		if (!qp->r_rq.wq) {
 			kfree(qp);
+			vfree(swq);
 			ret = ERR_PTR(-ENOMEM);
 			goto bail;
 		}
