From: Michael Wang <yun.wang-EIkl63zCoXaH+58JC4qpiA@public.gmane.org>
Subject: [PATCH v2 03/17] IB/Verbs: Use management helper cap_ib_mad() for
 mad-check
Date: Tue, 07 Apr 2015 14:30:22 +0200
Message-ID: <5523CDDE.4050209@profitbricks.com>
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


Introduce helper cap_ib_mad() to help us check if the port of an
IB device support Infiniband Management Datagrams.

Reform ib_umad_add_one() to fit per-port-check method better.

Cc: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Cc: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Ira Weiny <ira.weiny-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Cc: Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Signed-off-by: Michael Wang <yun.wang-EIkl63zCoXaH+58JC4qpiA@public.gmane.org>
---
 drivers/infiniband/core/mad.c      | 18 +++++++++---------
 drivers/infiniband/core/user_mad.c | 26 ++++++++++++++++++++------
 include/rdma/ib_verbs.h            | 15 +++++++++++++++
 3 files changed, 44 insertions(+), 15 deletions(-)

diff --git a/drivers/infiniband/core/mad.c b/drivers/infiniband/core/mad.c
index 74c30f4..ef0c0c5 100644
--- a/drivers/infiniband/core/mad.c
+++ b/drivers/infiniband/core/mad.c
@@ -3057,9 +3057,6 @@ static void ib_mad_init_device(struct ib_device *device)
 {
 	int start, end, i;
 
-	if (rdma_node_get_transport(device->node_type) != RDMA_TRANSPORT_IB)
-		return;
-
 	if (device->node_type == RDMA_NODE_IB_SWITCH) {
 		start = 0;
 		end   = 0;
@@ -3069,6 +3066,9 @@ static void ib_mad_init_device(struct ib_device *device)
 	}
 
 	for (i = start; i <= end; i++) {
+		if (!cap_ib_mad(device, i))
+			continue;
+
 		if (ib_mad_port_open(device, i)) {
 			dev_err(&device->dev, "Couldn't open port %d\n", i);
 			goto error;
@@ -3086,15 +3086,15 @@ error_agent:
 		dev_err(&device->dev, "Couldn't close port %d\n", i);
 
 error:
-	i--;
+	while (--i >= start) {
+		if (!cap_ib_mad(device, i))
+			continue;
 
-	while (i >= start) {
 		if (ib_agent_port_close(device, i))
 			dev_err(&device->dev,
 				"Couldn't close port %d for agents\n", i);
 		if (ib_mad_port_close(device, i))
 			dev_err(&device->dev, "Couldn't close port %d\n", i);
-		i--;
 	}
 }
 
@@ -3102,9 +3102,6 @@ static void ib_mad_remove_device(struct ib_device *device)
 {
 	int i, num_ports, cur_port;
 
-	if (rdma_node_get_transport(device->node_type) != RDMA_TRANSPORT_IB)
-		return;
-
 	if (device->node_type == RDMA_NODE_IB_SWITCH) {
 		num_ports = 1;
 		cur_port = 0;
@@ -3113,6 +3110,9 @@ static void ib_mad_remove_device(struct ib_device *device)
 		cur_port = 1;
 	}
 	for (i = 0; i < num_ports; i++, cur_port++) {
+		if (!cap_ib_mad(device, i))
+			continue;
+
 		if (ib_agent_port_close(device, cur_port))
 			dev_err(&device->dev,
 				"Couldn't close port %d for agents\n",
diff --git a/drivers/infiniband/core/user_mad.c b/drivers/infiniband/core/user_mad.c
index 928cdd2..b52884b 100644
--- a/drivers/infiniband/core/user_mad.c
+++ b/drivers/infiniband/core/user_mad.c
@@ -1273,9 +1273,7 @@ static void ib_umad_add_one(struct ib_device *device)
 {
 	struct ib_umad_device *umad_dev;
 	int s, e, i;
-
-	if (rdma_node_get_transport(device->node_type) != RDMA_TRANSPORT_IB)
-		return;
+	int count = 0;
 
 	if (device->node_type == RDMA_NODE_IB_SWITCH)
 		s = e = 0;
@@ -1296,11 +1294,21 @@ static void ib_umad_add_one(struct ib_device *device)
 	umad_dev->end_port   = e;
 
 	for (i = s; i <= e; ++i) {
+		if (!cap_ib_mad(device, i))
+			continue;
+
 		umad_dev->port[i - s].umad_dev = umad_dev;
 
 		if (ib_umad_init_port(device, i, umad_dev,
 				      &umad_dev->port[i - s]))
 			goto err;
+
+		count++;
+	}
+
+	if (!count) {
+		kobject_put(&umad_dev->kobj);
+		return;
 	}
 
 	ib_set_client_data(device, &umad_client, umad_dev);
@@ -1308,8 +1316,12 @@ static void ib_umad_add_one(struct ib_device *device)
 	return;
 
 err:
-	while (--i >= s)
+	while (--i >= s) {
+		if (!cap_ib_mad(device, i))
+			continue;
+
 		ib_umad_kill_port(&umad_dev->port[i - s]);
+	}
 
 	kobject_put(&umad_dev->kobj);
 }
@@ -1322,8 +1334,10 @@ static void ib_umad_remove_one(struct ib_device *device)
 	if (!umad_dev)
 		return;
 
-	for (i = 0; i <= umad_dev->end_port - umad_dev->start_port; ++i)
-		ib_umad_kill_port(&umad_dev->port[i]);
+	for (i = 0; i <= umad_dev->end_port - umad_dev->start_port; ++i) {
+		if (cap_ib_mad(device, i))
+			ib_umad_kill_port(&umad_dev->port[i]);
+	}
 
 	kobject_put(&umad_dev->kobj);
 }
diff --git a/include/rdma/ib_verbs.h b/include/rdma/ib_verbs.h
index 780b3b7..4013933 100644
--- a/include/rdma/ib_verbs.h
+++ b/include/rdma/ib_verbs.h
@@ -1773,6 +1773,21 @@ static inline int rdma_ib_mgmt(struct ib_device *device, u8 port_num)
 	return (tp == RDMA_TRANSPORT_IB || tp == RDMA_TRANSPORT_IBOE);
 }
 
+/**
+ * cap_ib_mad - Check if the port of device has the capability Infiniband
+ * Management Datagrams.
+ *
+ * @device: Device to be checked
+ * @port_num: Port number of the device
+ *
+ * Return 0 when port of the device don't support Infiniband
+ * Management Datagrams.
+ */
+static inline int cap_ib_mad(struct ib_device *device, u8 port_num)
+{
+	return rdma_ib_mgmt(device, port_num);
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
