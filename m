From: Michael Wang <yun.wang-EIkl63zCoXaH+58JC4qpiA@public.gmane.org>
Subject: [RFC PATCH 06/11] IB/Verbs: Use management helper has_sa() and cap_sa(),
 for sa-check
Date: Fri, 27 Mar 2015 16:46:11 +0100
Message-ID: <55157B43.6060507@profitbricks.com>
References: <551579CA.4030901@profitbricks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
	Trond Myklebust <trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Moni Shoua <monis-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	PJ Waskiewicz <pj.waskiewicz-PrFOU5CTvK1l57MIdRCFDg@public.gmane.org>,
	Tatyana Nikolova <Tatyana.E.Nikolova-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Yan Burman <yanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Jack Morgenstein <jackm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>,
	Bart Van Assche <bvanassche-HInyCGIudOg@public.gmane.org>,
	Yann Droneaud <ydroneaud-RlY5vtjFyJ3QT0dZR+AlfA@public.gmane.org>,
	Colin Ian King <colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
	Majd Dibbiny <majd-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Jiri Kosina <jkosina-AlSwsSmVLrQ@public.gmane.org>,
	Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Alex Estrin <alex.estrin-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Erez Shitrit <erezsh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Sagi Grimberg <sagig-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Shachar Raindel <raindel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Mike Marciniszyn <mike.m
To: Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Hal Rosenstock <hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Ira Weiny <ira.weiny-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <551579CA.4030901-EIkl63zCoXaH+58JC4qpiA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


Introduce helper has_sa() and cap_sa() to help us check if an IB device
or it's port support Subnet Administrator.

Cc: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Cc: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Ira Weiny <ira.weiny-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Cc: Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Signed-off-by: Michael Wang <yun.wang-EIkl63zCoXaH+58JC4qpiA@public.gmane.org>
---
 drivers/infiniband/core/sa_query.c | 12 ++++++------
 include/rdma/ib_verbs.h            | 28 ++++++++++++++++++++++++++++
 2 files changed, 34 insertions(+), 6 deletions(-)

diff --git a/drivers/infiniband/core/sa_query.c b/drivers/infiniband/core/sa_query.c
index d95d25f..89c27da 100644
--- a/drivers/infiniband/core/sa_query.c
+++ b/drivers/infiniband/core/sa_query.c
@@ -450,7 +450,7 @@ static void ib_sa_event(struct ib_event_handler *handler, struct ib_event *event
         struct ib_sa_port *port =
             &sa_dev->port[event->element.port_num - sa_dev->start_port];
 
-        if (!rdma_port_ll_is_ib(handler->device, port->port_num))
+        if (!cap_sa(handler->device, port->port_num))
             return;
 
         spin_lock_irqsave(&port->ah_lock, flags);
@@ -1154,7 +1154,7 @@ static void ib_sa_add_one(struct ib_device *device)
     struct ib_sa_device *sa_dev;
     int s, e, i;
 
-    if (!rdma_transport_is_ib(device))
+    if (!has_sa(device))
         return;
 
     if (device->node_type == RDMA_NODE_IB_SWITCH)
@@ -1175,7 +1175,7 @@ static void ib_sa_add_one(struct ib_device *device)
 
     for (i = 0; i <= e - s; ++i) {
         spin_lock_init(&sa_dev->port[i].ah_lock);
-        if (!rdma_port_ll_is_ib(device, i + 1))
+        if (!cap_sa(device, i + 1))
             continue;
 
         sa_dev->port[i].sm_ah    = NULL;
@@ -1205,14 +1205,14 @@ static void ib_sa_add_one(struct ib_device *device)
         goto err;
 
     for (i = 0; i <= e - s; ++i)
-        if (rdma_port_ll_is_ib(device, i + 1))
+        if (cap_sa(device, i + 1))
             update_sm_ah(&sa_dev->port[i].update_task);
 
     return;
 
 err:
     while (--i >= 0)
-        if (rdma_port_ll_is_ib(device, i + 1))
+        if (cap_sa(device, i + 1))
             ib_unregister_mad_agent(sa_dev->port[i].agent);
 
     kfree(sa_dev);
@@ -1233,7 +1233,7 @@ static void ib_sa_remove_one(struct ib_device *device)
     flush_workqueue(ib_wq);
 
     for (i = 0; i <= sa_dev->end_port - sa_dev->start_port; ++i) {
-        if (rdma_port_ll_is_ib(device, i + 1)) {
+        if (cap_sa(device, i + 1)) {
             ib_unregister_mad_agent(sa_dev->port[i].agent);
             if (sa_dev->port[i].sm_ah)
                 kref_put(&sa_dev->port[i].sm_ah->ref, free_sm_ah);
diff --git a/include/rdma/ib_verbs.h b/include/rdma/ib_verbs.h
index c0a63f8..fa8ffa3 100644
--- a/include/rdma/ib_verbs.h
+++ b/include/rdma/ib_verbs.h
@@ -1810,6 +1810,19 @@ static inline int has_cm(struct ib_device *device)
 }
 
 /**
+ * has_sa - Check if a device support Subnet Administrator.
+ *
+ * @device: Device to be checked
+ *
+ * Return 0 when a device has none port to support
+ * Subnet Administrator.
+ */
+static inline int has_sa(struct ib_device *device)
+{
+    return rdma_transport_is_ib(device);
+}
+
+/**
  * cap_smi - Check if the port of device has the capability
  * Subnet Management Interface.
  *
@@ -1824,6 +1837,21 @@ static inline int cap_smi(struct ib_device *device, u8 port_num)
     return rdma_port_ll_is_ib(device, port_num);
 }
 
+/**
+ * cap_sa - Check if the port of device has the capability
+ * Subnet Administrator.
+ *
+ * @device: Device to be checked
+ * @port_num: Port number of the device
+ *
+ * Return 0 when port of the device don't support
+ * Subnet Administrator.
+ */
+static inline int cap_sa(struct ib_device *device, u8 port_num)
+{
+    return rdma_port_ll_is_ib(device, port_num);
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
