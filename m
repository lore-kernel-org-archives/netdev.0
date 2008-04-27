From: Steve Wise <swise@opengridcomputing.com>
Subject: [ofa-general] [PATCH 2.6.26 2/3] RDMA/cxgb3: Correctly set the
	max_mr_size device attribute.
Date: Sun, 27 Apr 2008 11:00:08 -0500
Message-ID: <20080427160008.31018.15516.stgit@dell3.ogc.int>
References: <20080427155456.31018.22282.stgit@dell3.ogc.int>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, divy@chelsio.com, linux-kernel@vger.kernel.org,
	general@lists.openfabrics.org
To: rdreier@cisco.com
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20080427155456.31018.22282.stgit@dell3.ogc.int>
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


cxgb3 only supports 4GB memory regions.  The lustre RDMA code uses this
attribute and currently has to code around our bad setting.

Signed-off-by: Steve Wise <swise@opengridcomputing.com>
---

 drivers/infiniband/hw/cxgb3/cxio_hal.h      |    1 +
 drivers/infiniband/hw/cxgb3/iwch.c          |    1 +
 drivers/infiniband/hw/cxgb3/iwch.h          |    1 +
 drivers/infiniband/hw/cxgb3/iwch_provider.c |    2 +-
 4 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/drivers/infiniband/hw/cxgb3/cxio_hal.h b/drivers/infiniband/=
hw/cxgb3/cxio_hal.h
index 99543d6..2bcff7f 100644
--- a/drivers/infiniband/hw/cxgb3/cxio_hal.h
+++ b/drivers/infiniband/hw/cxgb3/cxio_hal.h
@@ -53,6 +53,7 @@
 #define T3_MAX_PBL_SIZE 256
 #define T3_MAX_RQ_SIZE 1024
 #define T3_MAX_NUM_STAG (1<<15)
+#define T3_MAX_MR_SIZE 0x100000000ULL
=20
 #define T3_STAG_UNSET 0xffffffff
=20
diff --git a/drivers/infiniband/hw/cxgb3/iwch.c b/drivers/infiniband/hw/c=
xgb3/iwch.c
index 0315c9d..98a768f 100644
--- a/drivers/infiniband/hw/cxgb3/iwch.c
+++ b/drivers/infiniband/hw/cxgb3/iwch.c
@@ -83,6 +83,7 @@ static void rnic_init(struct iwch_dev *rnicp)
 	rnicp->attr.max_phys_buf_entries =3D T3_MAX_PBL_SIZE;
 	rnicp->attr.max_pds =3D T3_MAX_NUM_PD - 1;
 	rnicp->attr.mem_pgsizes_bitmask =3D 0x7FFF;	/* 4KB-128MB */
+	rnicp->attr.max_mr_size =3D T3_MAX_MR_SIZE;
 	rnicp->attr.can_resize_wq =3D 0;
 	rnicp->attr.max_rdma_reads_per_qp =3D 8;
 	rnicp->attr.max_rdma_read_resources =3D
diff --git a/drivers/infiniband/hw/cxgb3/iwch.h b/drivers/infiniband/hw/c=
xgb3/iwch.h
index caf4e60..238c103 100644
--- a/drivers/infiniband/hw/cxgb3/iwch.h
+++ b/drivers/infiniband/hw/cxgb3/iwch.h
@@ -66,6 +66,7 @@ struct iwch_rnic_attributes {
 	 * size (4k)^i.  Phys block list mode unsupported.
 	 */
 	u32 mem_pgsizes_bitmask;
+	u64 max_mr_size;
 	u8 can_resize_wq;
=20
 	/*
diff --git a/drivers/infiniband/hw/cxgb3/iwch_provider.c b/drivers/infini=
band/hw/cxgb3/iwch_provider.c
index b2ea921..f7df213 100644
--- a/drivers/infiniband/hw/cxgb3/iwch_provider.c
+++ b/drivers/infiniband/hw/cxgb3/iwch_provider.c
@@ -998,7 +998,7 @@ static int iwch_query_device(struct ib_device *ibdev,
 	props->device_cap_flags =3D dev->device_cap_flags;
 	props->vendor_id =3D (u32)dev->rdev.rnic_info.pdev->vendor;
 	props->vendor_part_id =3D (u32)dev->rdev.rnic_info.pdev->device;
-	props->max_mr_size =3D ~0ull;
+	props->max_mr_size =3D dev->attr.max_mr_size;
 	props->max_qp =3D dev->attr.max_qps;
 	props->max_qp_wr =3D dev->attr.max_wrs;
 	props->max_sge =3D dev->attr.max_sge_per_wr;
