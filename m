From: Michael Wang <yun.wang-EIkl63zCoXaH+58JC4qpiA@public.gmane.org>
Subject: [PATCH v2 06/17] IB/Verbs: Use management helper cap_ib_sa() for
 sa-check
Date: Tue, 07 Apr 2015 14:32:47 +0200
Message-ID: <5523CE6F.4020206@profitbricks.com>
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
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <5523CCD5.6030401-EIkl63zCoXaH+58JC4qpiA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


Introduce helper cap_ib_sa() to help us check if the port of an
IB device support Infiniband Subnet Administrator.

Reform ib_sa_add_one() to fit per-port-check method better.

Cc: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Cc: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Ira Weiny <ira.weiny-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Cc: Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Signed-off-by: Michael Wang <yun.wang-EIkl63zCoXaH+58JC4qpiA@public.gmane.org>
---
 drivers/infiniband/core/sa_query.c | 27 +++++++++++++++++----------
 include/rdma/ib_verbs.h            | 15 +++++++++++++++
 2 files changed, 32 insertions(+), 10 deletions(-)

diff --git a/drivers/infiniband/core/sa_query.c b/drivers/infiniband/core/sa_query.c
index c38f030..f704254 100644
--- a/drivers/infiniband/core/sa_query.c
+++ b/drivers/infiniband/core/sa_query.c
@@ -450,7 +450,7 @@ static void ib_sa_event(struct ib_event_handler *handler, struct ib_event *event
 		struct ib_sa_port *port =
 			&sa_dev->port[event->element.port_num - sa_dev->start_port];
 
-		if (rdma_port_get_link_layer(handler->device, port->port_num) != IB_LINK_LAYER_INFINIBAND)
+		if (WARN_ON(!cap_ib_sa(handler->device, port->port_num)))
 			return;
 
 		spin_lock_irqsave(&port->ah_lock, flags);
@@ -1153,9 +1153,7 @@ static void ib_sa_add_one(struct ib_device *device)
 {
 	struct ib_sa_device *sa_dev;
 	int s, e, i;
-
-	if (rdma_node_get_transport(device->node_type) != RDMA_TRANSPORT_IB)
-		return;
+	int count = 0;
 
 	if (device->node_type == RDMA_NODE_IB_SWITCH)
 		s = e = 0;
@@ -1175,7 +1173,7 @@ static void ib_sa_add_one(struct ib_device *device)
 
 	for (i = 0; i <= e - s; ++i) {
 		spin_lock_init(&sa_dev->port[i].ah_lock);
-		if (rdma_port_get_link_layer(device, i + 1) != IB_LINK_LAYER_INFINIBAND)
+		if (!cap_ib_sa(device, i + 1))
 			continue;
 
 		sa_dev->port[i].sm_ah    = NULL;
@@ -1189,6 +1187,13 @@ static void ib_sa_add_one(struct ib_device *device)
 			goto err;
 
 		INIT_WORK(&sa_dev->port[i].update_task, update_sm_ah);
+
+		count++;
+	}
+
+	if (!count) {
+		kfree(sa_dev);
+		return;
 	}
 
 	ib_set_client_data(device, &sa_client, sa_dev);
@@ -1204,16 +1209,18 @@ static void ib_sa_add_one(struct ib_device *device)
 	if (ib_register_event_handler(&sa_dev->event_handler))
 		goto err;
 
-	for (i = 0; i <= e - s; ++i)
-		if (rdma_port_get_link_layer(device, i + 1) == IB_LINK_LAYER_INFINIBAND)
+	for (i = 0; i <= e - s; ++i) {
+		if (cap_ib_sa(device, i + 1))
 			update_sm_ah(&sa_dev->port[i].update_task);
+	}
 
 	return;
 
 err:
-	while (--i >= 0)
-		if (rdma_port_get_link_layer(device, i + 1) == IB_LINK_LAYER_INFINIBAND)
+	while (--i >= 0) {
+		if (cap_ib_sa(device, i + 1))
 			ib_unregister_mad_agent(sa_dev->port[i].agent);
+	}
 
 	kfree(sa_dev);
 
@@ -1233,7 +1240,7 @@ static void ib_sa_remove_one(struct ib_device *device)
 	flush_workqueue(ib_wq);
 
 	for (i = 0; i <= sa_dev->end_port - sa_dev->start_port; ++i) {
-		if (rdma_port_get_link_layer(device, i + 1) == IB_LINK_LAYER_INFINIBAND) {
+		if (cap_ib_sa(device, i + 1)) {
 			ib_unregister_mad_agent(sa_dev->port[i].agent);
 			if (sa_dev->port[i].sm_ah)
 				kref_put(&sa_dev->port[i].sm_ah->ref, free_sm_ah);
diff --git a/include/rdma/ib_verbs.h b/include/rdma/ib_verbs.h
index 3ba963f..c405e45 100644
--- a/include/rdma/ib_verbs.h
+++ b/include/rdma/ib_verbs.h
@@ -1818,6 +1818,21 @@ static inline int cap_ib_cm(struct ib_device *device, u8 port_num)
 	return rdma_ib_mgmt(device, port_num);
 }
 
+/**
+ * cap_ib_sa - Check if the port of device has the capability Infiniband
+ * Subnet Administrator.
+ *
+ * @device: Device to be checked
+ * @port_num: Port number of the device
+ *
+ * Return 0 when port of the device don't support Infiniband
+ * Subnet Administrator.
+ */
+static inline int cap_ib_sa(struct ib_device *device, u8 port_num)
+{
+	return rdma_transport_ib(device, port_num);
+}
+
 int ib_query_gid(struct ib_device *device,
 		 u8 port_num, int index, union ib_gid *gid);
 
-- 
2.1.0
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
