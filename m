From: Michael Wang <yun.wang-EIkl63zCoXaH+58JC4qpiA@public.gmane.org>
Subject: [RFC PATCH 07/11] IB/Verbs: Use management helper has_mcast() and,
 cap_mcast() for mcast-check
Date: Fri, 27 Mar 2015 16:46:57 +0100
Message-ID: <55157B71.6040505@profitbricks.com>
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


Introduce helper has_mcast() and cap_mcast() to help us check if an
IB device or it's port support Multicast.

Cc: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Cc: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Ira Weiny <ira.weiny-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Cc: Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Signed-off-by: Michael Wang <yun.wang-EIkl63zCoXaH+58JC4qpiA@public.gmane.org>
---
 drivers/infiniband/core/cma.c       |  2 +-
 drivers/infiniband/core/multicast.c |  8 ++++----
 include/rdma/ib_verbs.h             | 28 ++++++++++++++++++++++++++++
 3 files changed, 33 insertions(+), 5 deletions(-)

diff --git a/drivers/infiniband/core/cma.c b/drivers/infiniband/core/cma.c
index 276fb76..cbbc85b 100644
--- a/drivers/infiniband/core/cma.c
+++ b/drivers/infiniband/core/cma.c
@@ -3398,7 +3398,7 @@ void rdma_leave_multicast(struct rdma_cm_id *id, struct sockaddr *addr)
                 ib_detach_mcast(id->qp,
                         &mc->multicast.ib->rec.mgid,
                         be16_to_cpu(mc->multicast.ib->rec.mlid));
-            if (rdma_transport_is_ib(id_priv->cma_dev->device)) {
+            if (has_mcast(id_priv->cma_dev->device)) {
                 switch (rdma_port_get_link_layer(id->device, id->port_num)) {
                 case IB_LINK_LAYER_INFINIBAND:
                     ib_sa_free_multicast(mc->multicast.ib);
diff --git a/drivers/infiniband/core/multicast.c b/drivers/infiniband/core/multicast.c
index 17573ff..ffeaf27 100644
--- a/drivers/infiniband/core/multicast.c
+++ b/drivers/infiniband/core/multicast.c
@@ -780,7 +780,7 @@ static void mcast_event_handler(struct ib_event_handler *handler,
     int index;
 
     dev = container_of(handler, struct mcast_device, event_handler);
-    if (!rdma_port_ll_is_ib(dev->device, event->element.port_num))
+    if (!cap_mcast(dev->device, event->element.port_num))
         return;
 
     index = event->element.port_num - dev->start_port;
@@ -807,7 +807,7 @@ static void mcast_add_one(struct ib_device *device)
     int i;
     int count = 0;
 
-    if (!rdma_transport_is_ib(device))
+    if (!has_mcast(device))
         return;
 
     dev = kmalloc(sizeof *dev + device->phys_port_cnt * sizeof *port,
@@ -823,7 +823,7 @@ static void mcast_add_one(struct ib_device *device)
     }
 
     for (i = 0; i <= dev->end_port - dev->start_port; i++) {
-        if (!rdma_port_ll_is_ib(device, dev->start_port + i))
+        if (!cap_mcast(device, dev->start_port + i))
             continue;
         port = &dev->port[i];
         port->dev = dev;
@@ -861,7 +861,7 @@ static void mcast_remove_one(struct ib_device *device)
     flush_workqueue(mcast_wq);
 
     for (i = 0; i <= dev->end_port - dev->start_port; i++) {
-        if (rdma_port_ll_is_ib(device, dev->start_port + i)) {
+        if (cap_mcast(device, dev->start_port + i)) {
             port = &dev->port[i];
             deref_port(port);
             wait_for_completion(&port->comp);
diff --git a/include/rdma/ib_verbs.h b/include/rdma/ib_verbs.h
index fa8ffa3..e796104 100644
--- a/include/rdma/ib_verbs.h
+++ b/include/rdma/ib_verbs.h
@@ -1823,6 +1823,19 @@ static inline int has_sa(struct ib_device *device)
 }
 
 /**
+ * has_mcast - Check if a device support Multicast.
+ *
+ * @device: Device to be checked
+ *
+ * Return 0 when a device has none port to support
+ * Multicast.
+ */
+static inline int has_mcast(struct ib_device *device)
+{
+    return rdma_transport_is_ib(device);
+}
+
+/**
  * cap_smi - Check if the port of device has the capability
  * Subnet Management Interface.
  *
@@ -1852,6 +1865,21 @@ static inline int cap_sa(struct ib_device *device, u8 port_num)
     return rdma_port_ll_is_ib(device, port_num);
 }
 
+/**
+ * cap_mcast - Check if the port of device has the capability
+ * Multicast.
+ *
+ * @device: Device to be checked
+ * @port_num: Port number of the device
+ *
+ * Return 0 when port of the device don't support
+ * Multicast.
+ */
+static inline int cap_mcast(struct ib_device *device, u8 port_num)
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
