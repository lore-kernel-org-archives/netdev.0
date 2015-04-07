From: Michael Wang <yun.wang-EIkl63zCoXaH+58JC4qpiA@public.gmane.org>
Subject: [PATCH v2 05/17] IB/Verbs: Use management helper cap_ib_cm() for
 cm-check
Date: Tue, 07 Apr 2015 14:32:05 +0200
Message-ID: <5523CE45.4080606@profitbricks.com>
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


Introduce helper cap_ib_cm() to help us check if the port of an
IB device support Infiniband Communication Manager.

Reform cm_add_one() to fit per-port-check method better.

Cc: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Cc: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Ira Weiny <ira.weiny-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Cc: Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Signed-off-by: Michael Wang <yun.wang-EIkl63zCoXaH+58JC4qpiA@public.gmane.org>
---
 drivers/infiniband/core/cm.c | 22 +++++++++++++++++++---
 include/rdma/ib_verbs.h      | 15 +++++++++++++++
 2 files changed, 34 insertions(+), 3 deletions(-)

diff --git a/drivers/infiniband/core/cm.c b/drivers/infiniband/core/cm.c
index e28a494..63418ee 100644
--- a/drivers/infiniband/core/cm.c
+++ b/drivers/infiniband/core/cm.c
@@ -3761,9 +3761,7 @@ static void cm_add_one(struct ib_device *ib_device)
 	unsigned long flags;
 	int ret;
 	u8 i;
-
-	if (rdma_node_get_transport(ib_device->node_type) != RDMA_TRANSPORT_IB)
-		return;
+	int count = 0;
 
 	cm_dev = kzalloc(sizeof(*cm_dev) + sizeof(*port) *
 			 ib_device->phys_port_cnt, GFP_KERNEL);
@@ -3783,6 +3781,9 @@ static void cm_add_one(struct ib_device *ib_device)
 
 	set_bit(IB_MGMT_METHOD_SEND, reg_req.method_mask);
 	for (i = 1; i <= ib_device->phys_port_cnt; i++) {
+		if (!cap_ib_cm(ib_device, i))
+			continue;
+
 		port = kzalloc(sizeof *port, GFP_KERNEL);
 		if (!port)
 			goto error1;
@@ -3809,7 +3810,16 @@ static void cm_add_one(struct ib_device *ib_device)
 		ret = ib_modify_port(ib_device, i, 0, &port_modify);
 		if (ret)
 			goto error3;
+
+		count++;
 	}
+
+	if (!count) {
+		device_unregister(cm_dev->device);
+		kfree(cm_dev);
+		return;
+	}
+
 	ib_set_client_data(ib_device, &cm_client, cm_dev);
 
 	write_lock_irqsave(&cm.device_lock, flags);
@@ -3825,6 +3835,9 @@ error1:
 	port_modify.set_port_cap_mask = 0;
 	port_modify.clr_port_cap_mask = IB_PORT_CM_SUP;
 	while (--i) {
+		if (!cap_ib_cm(ib_device, i))
+			continue;
+
 		port = cm_dev->port[i-1];
 		ib_modify_port(ib_device, port->port_num, 0, &port_modify);
 		ib_unregister_mad_agent(port->mad_agent);
@@ -3853,6 +3866,9 @@ static void cm_remove_one(struct ib_device *ib_device)
 	write_unlock_irqrestore(&cm.device_lock, flags);
 
 	for (i = 1; i <= ib_device->phys_port_cnt; i++) {
+		if (!cap_ib_cm(ib_device, i))
+			continue;
+
 		port = cm_dev->port[i-1];
 		ib_modify_port(ib_device, port->port_num, 0, &port_modify);
 		ib_unregister_mad_agent(port->mad_agent);
diff --git a/include/rdma/ib_verbs.h b/include/rdma/ib_verbs.h
index ee76010..3ba963f 100644
--- a/include/rdma/ib_verbs.h
+++ b/include/rdma/ib_verbs.h
@@ -1803,6 +1803,21 @@ static inline int cap_ib_smi(struct ib_device *device, u8 port_num)
 	return rdma_transport_ib(device, port_num);
 }
 
+/**
+ * cap_ib_cm - Check if the port of device has the capability Infiniband
+ * Communication Manager.
+ *
+ * @device: Device to be checked
+ * @port_num: Port number of the device
+ *
+ * Return 0 when port of the device don't support Infiniband
+ * Communication Manager.
+ */
+static inline int cap_ib_cm(struct ib_device *device, u8 port_num)
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
