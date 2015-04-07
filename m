From: Michael Wang <yun.wang-EIkl63zCoXaH+58JC4qpiA@public.gmane.org>
Subject: [PATCH v2 07/17] IB/Verbs: Use management helper cap_ib_mcast() for
 mcast-check
Date: Tue, 07 Apr 2015 14:33:23 +0200
Message-ID: <5523CE93.8080809@profitbricks.com>
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


Introduce helper cap_ib_mcast() to help us check if the port of an
IB device support Infiniband Multicast.

Cc: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Cc: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Ira Weiny <ira.weiny-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Cc: Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Signed-off-by: Michael Wang <yun.wang-EIkl63zCoXaH+58JC4qpiA@public.gmane.org>
---
 drivers/infiniband/core/multicast.c | 12 +++---------
 include/rdma/ib_verbs.h             | 15 +++++++++++++++
 2 files changed, 18 insertions(+), 9 deletions(-)

diff --git a/drivers/infiniband/core/multicast.c b/drivers/infiniband/core/multicast.c
index fa17b55..bdc1880 100644
--- a/drivers/infiniband/core/multicast.c
+++ b/drivers/infiniband/core/multicast.c
@@ -780,8 +780,7 @@ static void mcast_event_handler(struct ib_event_handler *handler,
 	int index;
 
 	dev = container_of(handler, struct mcast_device, event_handler);
-	if (rdma_port_get_link_layer(dev->device, event->element.port_num) !=
-	    IB_LINK_LAYER_INFINIBAND)
+	if (WARN_ON(!cap_ib_mcast(dev->device, event->element.port_num)))
 		return;
 
 	index = event->element.port_num - dev->start_port;
@@ -808,9 +807,6 @@ static void mcast_add_one(struct ib_device *device)
 	int i;
 	int count = 0;
 
-	if (rdma_node_get_transport(device->node_type) != RDMA_TRANSPORT_IB)
-		return;
-
 	dev = kmalloc(sizeof *dev + device->phys_port_cnt * sizeof *port,
 		      GFP_KERNEL);
 	if (!dev)
@@ -824,8 +820,7 @@ static void mcast_add_one(struct ib_device *device)
 	}
 
 	for (i = 0; i <= dev->end_port - dev->start_port; i++) {
-		if (rdma_port_get_link_layer(device, dev->start_port + i) !=
-		    IB_LINK_LAYER_INFINIBAND)
+		if (!cap_ib_mcast(device, dev->start_port + i))
 			continue;
 		port = &dev->port[i];
 		port->dev = dev;
@@ -863,8 +858,7 @@ static void mcast_remove_one(struct ib_device *device)
 	flush_workqueue(mcast_wq);
 
 	for (i = 0; i <= dev->end_port - dev->start_port; i++) {
-		if (rdma_port_get_link_layer(device, dev->start_port + i) ==
-		    IB_LINK_LAYER_INFINIBAND) {
+		if (cap_ib_mcast(device, dev->start_port + i)) {
 			port = &dev->port[i];
 			deref_port(port);
 			wait_for_completion(&port->comp);
diff --git a/include/rdma/ib_verbs.h b/include/rdma/ib_verbs.h
index c405e45..5a5f6d5 100644
--- a/include/rdma/ib_verbs.h
+++ b/include/rdma/ib_verbs.h
@@ -1833,6 +1833,21 @@ static inline int cap_ib_sa(struct ib_device *device, u8 port_num)
 	return rdma_transport_ib(device, port_num);
 }
 
+/**
+ * cap_ib_mcast - Check if the port of device has the capability Infiniband
+ * Multicast.
+ *
+ * @device: Device to be checked
+ * @port_num: Port number of the device
+ *
+ * Return 0 when port of the device don't support Infiniband
+ * Multicast.
+ */
+static inline int cap_ib_mcast(struct ib_device *device, u8 port_num)
+{
+	return cap_ib_sa(device, port_num);
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
