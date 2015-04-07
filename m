From: Michael Wang <yun.wang@profitbricks.com>
Subject: [PATCH v2 10/17] IB/Verbs: Adopt management helpers for IB helpers
Date: Tue, 07 Apr 2015 14:35:22 +0200
Message-ID: <5523CF0A.5090206@profitbricks.com>
References: <5523CCD5.6030401@profitbricks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Hal Rosenstock <hal.rosenstock@gmail.com>,
	Tom Tucker <tom@opengridcomputing.com>,
	Steve Wise <swise@opengridcomputing.com>,
	Hoang-Nam Nguyen <hnguyen@de.ibm.com>,
	Christoph Raisch <raisch@de.ibm.com>,
	Mike Marciniszyn <infinipath@intel.com>,
	Eli Cohen <eli@mellanox.com>,
	Faisal Latif <faisal.latif@intel.com>,
	Upinder Malhi <umalhi@cisco.com>,
	Trond Myklebust <trond.myklebust@primarydata.com>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	"David S. Miller" <davem@davemloft.net>,
	Ira Weiny <ira.weiny@intel.com>,
	PJ Waskiewicz <pj.waskiewicz@solidfire.com>,
	Tatyana Nikolova <Tatyana.E.Nikolova@intel.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Haggai Eran <haggaie@mellanox.com>,
	Ilya Nelkenbaum <ilyan@mellanox.com>,
	Yann Droneaud <ydroneaud@opteya.com>,
	Bart Van Assche <bvanassche@acm.org>,
	Shachar Raindel <raindel@mellanox.com
To: Roland Dreier <roland@kernel.org>,
	Sean Hefty <sean.hefty@intel.com>, linux-rdma@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5523CCD5.6030401@profitbricks.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Adopt management helpers for:
	ib_init_ah_from_path()
	ib_init_ah_from_wc()
	ib_resolve_eth_l2_attrs()

Cc: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Cc: Doug Ledford <dledford@redhat.com>
Cc: Ira Weiny <ira.weiny@intel.com>
Cc: Sean Hefty <sean.hefty@intel.com>
Signed-off-by: Michael Wang <yun.wang@profitbricks.com>
---
 drivers/infiniband/core/sa_query.c | 2 +-
 drivers/infiniband/core/verbs.c    | 6 ++----
 2 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/drivers/infiniband/core/sa_query.c b/drivers/infiniband/core/sa_query.c
index f704254..4e61104 100644
--- a/drivers/infiniband/core/sa_query.c
+++ b/drivers/infiniband/core/sa_query.c
@@ -540,7 +540,7 @@ int ib_init_ah_from_path(struct ib_device *device, u8 port_num,
 	ah_attr->port_num = port_num;
 	ah_attr->static_rate = rec->rate;
 
-	force_grh = rdma_port_get_link_layer(device, port_num) == IB_LINK_LAYER_ETHERNET;
+	force_grh = !rdma_transport_ib(device, port_num);
 
 	if (rec->hop_limit > 1 || force_grh) {
 		ah_attr->ah_flags = IB_AH_GRH;
diff --git a/drivers/infiniband/core/verbs.c b/drivers/infiniband/core/verbs.c
index 83370de..ca06f76 100644
--- a/drivers/infiniband/core/verbs.c
+++ b/drivers/infiniband/core/verbs.c
@@ -200,11 +200,9 @@ int ib_init_ah_from_wc(struct ib_device *device, u8 port_num, struct ib_wc *wc,
 	u32 flow_class;
 	u16 gid_index;
 	int ret;
-	int is_eth = (rdma_port_get_link_layer(device, port_num) ==
-			IB_LINK_LAYER_ETHERNET);
 
 	memset(ah_attr, 0, sizeof *ah_attr);
-	if (is_eth) {
+	if (!rdma_transport_ib(device, port_num)) {
 		if (!(wc->wc_flags & IB_WC_GRH))
 			return -EPROTOTYPE;
 
@@ -873,7 +871,7 @@ int ib_resolve_eth_l2_attrs(struct ib_qp *qp,
 	union ib_gid  sgid;
 
 	if ((*qp_attr_mask & IB_QP_AV)  &&
-	    (rdma_port_get_link_layer(qp->device, qp_attr->ah_attr.port_num) == IB_LINK_LAYER_ETHERNET)) {
+	    (!rdma_transport_ib(qp->device, qp_attr->ah_attr.port_num))) {
 		ret = ib_query_gid(qp->device, qp_attr->ah_attr.port_num,
 				   qp_attr->ah_attr.grh.sgid_index, &sgid);
 		if (ret)
-- 
2.1.0
