From: Steve Wise <swise@opengridcomputing.com>
Subject: [ofa-general] [PATCH 2.6.25 2/2] RDMA/cxgb3: Support 5.0 firmware.
Date: Mon, 26 Nov 2007 11:28:46 -0600
Message-ID: <20071126172846.22792.8854.stgit@dell3.ogc.int>
References: <20071126172457.22792.62583.stgit@dell3.ogc.int>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, ewg@lists.openfabrics.org,
	general@lists.openfabrics.org
To: rdreier@cisco.com
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20071126172457.22792.62583.stgit@dell3.ogc.int>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org


RDMA/cxgb3: Support 5.0 firmware.

The 5.0 firmware now supports translating sgls in recv wrs, so remove
the host driver logic currently doing the translation.

Note: this change requires 5.0 firmware.

Signed-off-by: Steve Wise <swise@opengridcomputing.com>
---

 drivers/infiniband/hw/cxgb3/iwch_qp.c |   21 ++-------------------
 1 files changed, 2 insertions(+), 19 deletions(-)

diff --git a/drivers/infiniband/hw/cxgb3/iwch_qp.c b/drivers/infiniband/h=
w/cxgb3/iwch_qp.c
index dd89b6b..9bb8112 100644
--- a/drivers/infiniband/hw/cxgb3/iwch_qp.c
+++ b/drivers/infiniband/hw/cxgb3/iwch_qp.c
@@ -208,36 +208,19 @@ static int iwch_sgl2pbl_map(struct iwch_dev *rhp, s=
truct ib_sge *sg_list,
 static int iwch_build_rdma_recv(struct iwch_dev *rhp, union t3_wr *wqe,
 				struct ib_recv_wr *wr)
 {
-	int i, err =3D 0;
-	u32 pbl_addr[4];
-	u8 page_size[4];
+	int i;
 	if (wr->num_sge > T3_MAX_SGE)
 		return -EINVAL;
-	err =3D iwch_sgl2pbl_map(rhp, wr->sg_list, wr->num_sge, pbl_addr,
-			       page_size);
-	if (err)
-		return err;
-	wqe->recv.pagesz[0] =3D page_size[0];
-	wqe->recv.pagesz[1] =3D page_size[1];
-	wqe->recv.pagesz[2] =3D page_size[2];
-	wqe->recv.pagesz[3] =3D page_size[3];
 	wqe->recv.num_sgle =3D cpu_to_be32(wr->num_sge);
 	for (i =3D 0; i < wr->num_sge; i++) {
 		wqe->recv.sgl[i].stag =3D cpu_to_be32(wr->sg_list[i].lkey);
 		wqe->recv.sgl[i].len =3D cpu_to_be32(wr->sg_list[i].length);
-
-		/* to in the WQE =3D=3D the offset into the page */
-		wqe->recv.sgl[i].to =3D cpu_to_be64(((u32) wr->sg_list[i].addr) %
-				(1UL << (12 + page_size[i])));
-
-		/* pbl_addr is the adapters address in the PBL */
-		wqe->recv.pbl_addr[i] =3D cpu_to_be32(pbl_addr[i]);
+		wqe->recv.sgl[i].to =3D cpu_to_be64(wr->sg_list[i].addr);
 	}
 	for (; i < T3_MAX_SGE; i++) {
 		wqe->recv.sgl[i].stag =3D 0;
 		wqe->recv.sgl[i].len =3D 0;
 		wqe->recv.sgl[i].to =3D 0;
-		wqe->recv.pbl_addr[i] =3D 0;
 	}
 	return 0;
 }
