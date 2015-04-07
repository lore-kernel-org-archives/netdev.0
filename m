From: Michael Wang <yun.wang-EIkl63zCoXaH+58JC4qpiA@public.gmane.org>
Subject: [PATCH v2 08/17] IB/Verbs: Use management helper cap_ipoib() for
 ipoib-check
Date: Tue, 07 Apr 2015 14:34:02 +0200
Message-ID: <5523CEBA.7010808@profitbricks.com>
References: <5523CCD5.6030401@profitbricks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Hal Rosenstock <hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Tom Tucker <tom-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>,
	Steve Wise <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>,
	Hoang-Nam Nguyen <hnguyen-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>,
	Christoph Raisch <raisch-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>,
	Mike Marciniszyn <infinipath-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Eli Cohen <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Faisal Latif <faisal.latif-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Upinder Malhi <umalhi-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>,
	Trond Myklebust <trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>,
	"J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Ira Weiny <ira.weiny-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	PJ Waskiewicz <pj.waskiewicz-PrFOU5CTvK1l57MIdRCFDg@public.gmane.org>,
	Tatyana Nikolova <Tatyana.E.Nikolova-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Jack Morgenstein <jackm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>,
	Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Ilya Nelkenbaum <ilyan-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Yann Droneaud <ydroneaud-RlY5vtjFyJ3QT0dZR+AlfA@public.gmane.org>,
	Bart Van Assche <bvanassche-HInyCGIudOg@public.gmane.org>,
	Shachar Raindel <raindel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org
To: Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <5523CCD5.6030401-EIkl63zCoXaH+58JC4qpiA@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


Introduce helper cap_ipoib() to help us check if the port of an
IB device support IP over Infiniband.

Reform ipoib_add_one() to fit per-port-check method better.

Cc: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Cc: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Ira Weiny <ira.weiny-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Cc: Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Signed-off-by: Michael Wang <yun.wang-EIkl63zCoXaH+58JC4qpiA@public.gmane.org>
---
 drivers/infiniband/ulp/ipoib/ipoib_main.c | 17 ++++++++++-------
 include/rdma/ib_verbs.h                   | 15 +++++++++++++++
 2 files changed, 25 insertions(+), 7 deletions(-)

diff --git a/drivers/infiniband/ulp/ipoib/ipoib_main.c b/drivers/infiniband/ulp/ipoib/ipoib_main.c
index 58b5aa3..e36a926 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_main.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_main.c
@@ -1654,9 +1654,7 @@ static void ipoib_add_one(struct ib_device *device)
 	struct net_device *dev;
 	struct ipoib_dev_priv *priv;
 	int s, e, p;
-
-	if (rdma_node_get_transport(device->node_type) != RDMA_TRANSPORT_IB)
-		return;
+	int count = 0;
 
 	dev_list = kmalloc(sizeof *dev_list, GFP_KERNEL);
 	if (!dev_list)
@@ -1673,13 +1671,21 @@ static void ipoib_add_one(struct ib_device *device)
 	}
 
 	for (p = s; p <= e; ++p) {
-		if (rdma_port_get_link_layer(device, p) != IB_LINK_LAYER_INFINIBAND)
+		if (!cap_ipoib(device, p))
 			continue;
+
 		dev = ipoib_add_port("ib%d", device, p);
 		if (!IS_ERR(dev)) {
 			priv = netdev_priv(dev);
 			list_add_tail(&priv->list, dev_list);
 		}
+
+		count++;
+	}
+
+	if (!count) {
+		kfree(dev_list);
+		return;
 	}
 
 	ib_set_client_data(device, &ipoib_client, dev_list);
@@ -1690,9 +1696,6 @@ static void ipoib_remove_one(struct ib_device *device)
 	struct ipoib_dev_priv *priv, *tmp;
 	struct list_head *dev_list;
 
-	if (rdma_node_get_transport(device->node_type) != RDMA_TRANSPORT_IB)
-		return;
-
 	dev_list = ib_get_client_data(device, &ipoib_client);
 	if (!dev_list)
 		return;
diff --git a/include/rdma/ib_verbs.h b/include/rdma/ib_verbs.h
index 5a5f6d5..9db8966 100644
--- a/include/rdma/ib_verbs.h
+++ b/include/rdma/ib_verbs.h
@@ -1848,6 +1848,21 @@ static inline int cap_ib_mcast(struct ib_device *device, u8 port_num)
 	return cap_ib_sa(device, port_num);
 }
 
+/**
+ * cap_ipoib - Check if the port of device has the capability
+ * IP over Infiniband.
+ *
+ * @device: Device to be checked
+ * @port_num: Port number of the device
+ *
+ * Return 0 when port of the device don't support
+ * IP over Infiniband.
+ */
+static inline int cap_ipoib(struct ib_device *device, u8 port_num)
+{
+	return rdma_transport_ib(device, port_num);
+}
+
 int ib_query_gid(struct ib_device *device,
 		 u8 port_num, int index, union ib_gid *gid);
 
-- 
2.1.0
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
