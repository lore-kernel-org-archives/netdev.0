From: Steve Wise <swise@opengridcomputing.com>
Subject: [PATCH v2] iw_cxgb3: Support "iwarp-only" interfaces to avoid 4-tuple conflicts.
Date: Thu, 13 Sep 2007 14:16:17 -0500
Message-ID: <20070913191617.30937.95960.stgit@dell3.ogc.int>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	general@lists.openfabrics.org
To: rdreier@cisco.com, sean.hefty@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([71.42.183.126]:38086 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754372AbXIMTQT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Sep 2007 15:16:19 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


iw_cxgb3: Support "iwarp-only" interfaces to avoid 4-tuple conflicts.

Version 2:

- added a per-device mutex for the address and listening endpoints lists.

- wait for all replies if sending multiple passive_open requests to rnic.

- log warning if no addresses are available when a listen is issued.

- tested

---

Design:

The sysadmin creates "for iwarp use only" alias interfaces of the form
"devname:iw*" where devname is the native interface name (eg eth0) for the
iwarp netdev device.  The alias label can be anything starting with "iw".
The "iw" immediately after the ':' is the key used by the iw_cxgb3 driver.

EG:
	ifconfig eth0 192.168.70.123 up
	ifconfig eth0:iw1 192.168.71.123 up
	ifconfig eth0:iw2 192.168.72.123 up

In the above example, 192.168.70/24 is for TCP traffic, while
192.168.71/24 and 192.168.72/24 are for iWARP/RDMA use.

The rdma-only interface must be on its own IP subnet. This allows routing
all rdma traffic onto this interface.

The iWARP driver must translate all listens on address 0.0.0.0 to the
set of rdma-only ip addresses for the device in question.  This prevents
incoming connect requests to the TCP ipaddresses from going up the
rdma stack.

Implementation Details:

- The iw_cxgb3 driver registers for inetaddr events via
register_inetaddr_notifier().  This allows tracking the iwarp-only
addresses/subnets as they get added and deleted.  The iwarp driver
maintains a list of the current iwarp-only addresses.

- The iw_cxgb3 driver builds the list of iwarp-only addresses for its
devices at module insert time.  This is needed because the inetaddr
notifier callbacks don't "replay" address-add events when someone
registers.  So the driver must build the initial list at module load time.

- When a listen is done on address 0.0.0.0, then the iw_cxgb3 driver
must translate that into a set of listens on the iwarp-only addresses.
This is implemented by maintaining a list of stid/addr entries per
listening endpoint.

- When a new iwarp-only address is added or removed, the iw_cxgb3 driver
must traverse the set of listening endpoints and update them accordingly.
This allows an application to bind to 0.0.0.0 prior to the iwarp-only
interfaces being configured.  It also allows changing the iwarp-only set
of addresses and getting the expected behavior for apps already bound
to 0.0.0.0.  This is done by maintaining a list of listening endpoints
off the device struct.

- The address list, the listening endpoint list, and each list of
stid/addrs in use per listening endpoint are all protected via a mutex
per iw_cxgb3 device.

Signed-off-by: Steve Wise <swise@opengridcomputing.com>
---

 drivers/infiniband/hw/cxgb3/iwch.c    |  125 ++++++++++++++++
 drivers/infiniband/hw/cxgb3/iwch.h    |   11 +
 drivers/infiniband/hw/cxgb3/iwch_cm.c |  259 +++++++++++++++++++++++++++------
 drivers/infiniband/hw/cxgb3/iwch_cm.h |   15 ++
 4 files changed, 360 insertions(+), 50 deletions(-)

diff --git a/drivers/infiniband/hw/cxgb3/iwch.c b/drivers/infiniband/hw/cxgb3/iwch.c
index 0315c9d..296fb66 100644
--- a/drivers/infiniband/hw/cxgb3/iwch.c
+++ b/drivers/infiniband/hw/cxgb3/iwch.c
@@ -63,6 +63,123 @@ struct cxgb3_client t3c_client = {
 static LIST_HEAD(dev_list);
 static DEFINE_MUTEX(dev_mutex);
 
+static void insert_ifa(struct iwch_dev *rnicp, struct in_ifaddr *ifa)
+{
+	struct iwch_addrlist *addr;
+
+	addr = kmalloc(sizeof *addr, GFP_KERNEL);
+	if (!addr) {
+		printk(KERN_ERR MOD "%s - failed to alloc memory!\n",
+		       __FUNCTION__);
+		return;
+	}
+	addr->ifa = ifa;
+	mutex_lock(&rnicp->mutex);
+	list_add_tail(&addr->entry, &rnicp->addrlist);
+	mutex_unlock(&rnicp->mutex);
+}
+
+static void remove_ifa(struct iwch_dev *rnicp, struct in_ifaddr *ifa)
+{
+	struct iwch_addrlist *addr, *tmp;
+
+	mutex_lock(&rnicp->mutex);
+	list_for_each_entry_safe(addr, tmp, &rnicp->addrlist, entry) {
+		if (addr->ifa == ifa) {
+			list_del_init(&addr->entry);
+			kfree(addr);
+			goto out;
+		}
+	}
+out:
+	mutex_unlock(&rnicp->mutex);
+}
+
+static int netdev_is_ours(struct iwch_dev *rnicp, struct net_device *netdev)
+{
+	int i;
+
+	for (i = 0; i < rnicp->rdev.port_info.nports; i++)
+		if (netdev == rnicp->rdev.port_info.lldevs[i])
+			return 1;
+	return 0;
+}
+
+static inline int is_iwarp_label(char *label)
+{
+	char *colon;
+
+	colon = strchr(label, ':');
+	if (colon && !strncmp(colon+1, "iw", 2))
+		return 1;
+	return 0;
+}
+
+static int nb_callback(struct notifier_block *self, unsigned long event,
+		       void *ctx)
+{
+	struct in_ifaddr *ifa = ctx;
+	struct iwch_dev *rnicp = container_of(self, struct iwch_dev, nb);
+
+	PDBG("%s rnicp %p event %lx\n", __FUNCTION__, rnicp, event);
+
+	switch (event) {
+	case NETDEV_UP:
+		if (netdev_is_ours(rnicp, ifa->ifa_dev->dev) &&
+		    is_iwarp_label(ifa->ifa_label)) {
+			PDBG("%s label %s addr 0x%x added\n",
+				__FUNCTION__, ifa->ifa_label, ifa->ifa_address);
+			insert_ifa(rnicp, ifa);
+			iwch_listeners_add_addr(rnicp, ifa->ifa_address);
+		}
+		break;
+	case NETDEV_DOWN:
+		if (netdev_is_ours(rnicp, ifa->ifa_dev->dev) &&
+		    is_iwarp_label(ifa->ifa_label)) {
+			PDBG("%s label %s addr 0x%x deleted\n",
+				__FUNCTION__, ifa->ifa_label, ifa->ifa_address);
+			iwch_listeners_del_addr(rnicp, ifa->ifa_address);
+			remove_ifa(rnicp, ifa);
+		}
+		break;
+	default:
+		break;
+	}
+	return 0;
+}
+
+static void delete_addrlist(struct iwch_dev *rnicp)
+{
+	struct iwch_addrlist *addr, *tmp;
+
+	mutex_lock(&rnicp->mutex);
+	list_for_each_entry_safe(addr, tmp, &rnicp->addrlist, entry) {
+		list_del_init(&addr->entry);
+		kfree(addr);
+	}
+	mutex_unlock(&rnicp->mutex);
+}
+
+static void populate_addrlist(struct iwch_dev *rnicp)
+{
+	int i;
+	struct in_device *indev;
+
+	for (i = 0; i < rnicp->rdev.port_info.nports; i++) {
+		indev = in_dev_get(rnicp->rdev.port_info.lldevs[i]);
+		if (!indev)
+			continue;
+		for_ifa(indev)
+			if (is_iwarp_label(ifa->ifa_label)) {
+				PDBG("%s label %s addr 0x%x added\n",
+				     __FUNCTION__, ifa->ifa_label,
+				     ifa->ifa_address);
+				insert_ifa(rnicp, ifa);
+			}
+		endfor_ifa(indev);
+	}
+}
+
 static void rnic_init(struct iwch_dev *rnicp)
 {
 	PDBG("%s iwch_dev %p\n", __FUNCTION__,  rnicp);
@@ -70,6 +187,12 @@ static void rnic_init(struct iwch_dev *r
 	idr_init(&rnicp->qpidr);
 	idr_init(&rnicp->mmidr);
 	spin_lock_init(&rnicp->lock);
+	INIT_LIST_HEAD(&rnicp->addrlist);
+	INIT_LIST_HEAD(&rnicp->listen_eps);
+	mutex_init(&rnicp->mutex);
+	rnicp->nb.notifier_call = nb_callback;
+	populate_addrlist(rnicp);
+	register_inetaddr_notifier(&rnicp->nb);
 
 	rnicp->attr.vendor_id = 0x168;
 	rnicp->attr.vendor_part_id = 7;
@@ -148,6 +271,8 @@ static void close_rnic_dev(struct t3cdev
 	mutex_lock(&dev_mutex);
 	list_for_each_entry_safe(dev, tmp, &dev_list, entry) {
 		if (dev->rdev.t3cdev_p == tdev) {
+			unregister_inetaddr_notifier(&dev->nb);
+			delete_addrlist(dev);
 			list_del(&dev->entry);
 			iwch_unregister_device(dev);
 			cxio_rdev_close(&dev->rdev);
diff --git a/drivers/infiniband/hw/cxgb3/iwch.h b/drivers/infiniband/hw/cxgb3/iwch.h
index caf4e60..7fa0a47 100644
--- a/drivers/infiniband/hw/cxgb3/iwch.h
+++ b/drivers/infiniband/hw/cxgb3/iwch.h
@@ -36,6 +36,8 @@ #include <linux/mutex.h>
 #include <linux/list.h>
 #include <linux/spinlock.h>
 #include <linux/idr.h>
+#include <linux/notifier.h>
+#include <linux/inetdevice.h>
 
 #include <rdma/ib_verbs.h>
 
@@ -101,6 +103,11 @@ struct iwch_rnic_attributes {
 	u32 cq_overflow_detection;
 };
 
+struct iwch_addrlist {
+	struct list_head entry;
+	struct in_ifaddr *ifa;
+};
+
 struct iwch_dev {
 	struct ib_device ibdev;
 	struct cxio_rdev rdev;
@@ -111,6 +118,10 @@ struct iwch_dev {
 	struct idr mmidr;
 	spinlock_t lock;
 	struct list_head entry;
+	struct notifier_block nb;
+	struct list_head addrlist;
+	struct list_head listen_eps;
+	struct mutex mutex;
 };
 
 static inline struct iwch_dev *to_iwch_dev(struct ib_device *ibdev)
diff --git a/drivers/infiniband/hw/cxgb3/iwch_cm.c b/drivers/infiniband/hw/cxgb3/iwch_cm.c
index 1cdfcd4..954069f 100644
--- a/drivers/infiniband/hw/cxgb3/iwch_cm.c
+++ b/drivers/infiniband/hw/cxgb3/iwch_cm.c
@@ -1127,23 +1127,149 @@ static int act_open_rpl(struct t3cdev *t
 	return CPL_RET_BUF_DONE;
 }
 
-static int listen_start(struct iwch_listen_ep *ep)
+static int wait_for_reply(struct iwch_ep_common *epc)
+{
+	PDBG("%s ep %p waiting\n", __FUNCTION__, epc);
+	wait_event(epc->waitq, epc->rpl_done);
+	PDBG("%s ep %p done waiting err %d\n", __FUNCTION__, epc, epc->rpl_err);
+	return epc->rpl_err;
+}
+
+static struct iwch_listen_entry *alloc_listener(struct iwch_listen_ep *ep,
+						  __be32 addr)
+{
+	struct iwch_dev *h = to_iwch_dev(ep->com.cm_id->device);
+	struct iwch_listen_entry *le;
+
+	le = kmalloc(sizeof *le, GFP_KERNEL);
+	if (!le) {
+		printk(KERN_ERR MOD "%s - failed to alloc memory!\n",
+		       __FUNCTION__);
+		return NULL;
+	}
+	le->stid = cxgb3_alloc_stid(h->rdev.t3cdev_p,
+				    &t3c_client, ep);
+	if (le->stid == -1) {
+		printk(KERN_ERR MOD "%s - cannot alloc stid.\n",
+		       __FUNCTION__);
+		kfree(le);
+		return NULL;
+	}
+	le->addr = addr;
+	PDBG("%s stid %u addr %x port %x\n", __FUNCTION__, le->stid,
+	     ntohl(le->addr), ntohs(ep->com.local_addr.sin_port));
+	return le;
+}
+
+static void dealloc_listener(struct iwch_listen_ep *ep,
+			     struct iwch_listen_entry *le)
+{
+	PDBG("%s stid %u addr %x port %x\n", __FUNCTION__, le->stid,
+	     ntohl(le->addr), ntohs(ep->com.local_addr.sin_port));
+	cxgb3_free_stid(ep->com.tdev, le->stid);
+	kfree(le);
+}
+
+static void dealloc_listener_list(struct iwch_listen_ep *ep)
+{
+	struct iwch_listen_entry *le, *tmp;
+	struct iwch_dev *h = to_iwch_dev(ep->com.cm_id->device);
+
+	mutex_lock(&h->mutex);
+	list_for_each_entry_safe(le, tmp, &ep->listeners, entry) {
+		list_del_init(&le->entry);
+		dealloc_listener(ep, le);
+	}
+	mutex_unlock(&h->mutex);
+}
+
+static int alloc_listener_list(struct iwch_listen_ep *ep)
+{
+	struct iwch_dev *h = to_iwch_dev(ep->com.cm_id->device);
+	struct iwch_addrlist *addr;
+	struct iwch_listen_entry *le;
+	int err = 0;
+	int added=0;
+	mutex_lock(&h->mutex);
+	list_for_each_entry(addr, &h->addrlist, entry) {
+		if (ep->com.local_addr.sin_addr.s_addr == 0 ||
+		    ep->com.local_addr.sin_addr.s_addr ==
+		    addr->ifa->ifa_address) {
+			le = alloc_listener(ep, addr->ifa->ifa_address);
+			if (!le)
+				break;
+			list_add_tail(&le->entry, &ep->listeners);
+			added++;
+		}
+	}
+	mutex_unlock(&h->mutex);
+	if (ep->com.local_addr.sin_addr.s_addr != 0 && !added)
+		err = -EADDRNOTAVAIL;
+	if (!err && !added)
+		printk(KERN_WARNING MOD
+		       "No RDMA interface found for device %s\n",
+		       pci_name(h->rdev.rnic_info.pdev));
+	return err;
+}
+
+static int listen_stop_one(struct iwch_listen_ep  *ep, unsigned int stid)
 {
 	struct sk_buff *skb;
-	struct cpl_pass_open_req *req;
+	struct cpl_close_listserv_req *req;
+
+	PDBG("%s stid %u\n", __FUNCTION__, stid);
+	skb = get_skb(NULL, sizeof(*req), GFP_KERNEL);
+	if (!skb) {
+		printk(KERN_ERR MOD "%s - failed to alloc skb\n", __FUNCTION__);
+		return -ENOMEM;
+	}
+	req = (struct cpl_close_listserv_req *) skb_put(skb, sizeof(*req));
+	req->wr.wr_hi = htonl(V_WR_OP(FW_WROPCODE_FORWARD));
+	req->cpu_idx = 0;
+	OPCODE_TID(req) = htonl(MK_OPCODE_TID(CPL_CLOSE_LISTSRV_REQ, stid));
+	skb->priority = 1;
+	ep->com.rpl_err = 0;
+	ep->com.rpl_done = 0;
+	cxgb3_ofld_send(ep->com.tdev, skb);
+	return wait_for_reply(&ep->com);
+}
+
+static int listen_stop(struct iwch_listen_ep *ep)
+{
+	struct iwch_listen_entry *le;
+	struct iwch_dev *h = to_iwch_dev(ep->com.cm_id->device);
+	int err = 0;
 
 	PDBG("%s ep %p\n", __FUNCTION__, ep);
+	mutex_lock(&h->mutex);
+	list_for_each_entry(le, &ep->listeners, entry) {
+		err = listen_stop_one(ep, le->stid);
+		if (err)
+			break;
+	}
+	mutex_unlock(&h->mutex);
+	return err;
+}
+
+static int listen_start_one(struct iwch_listen_ep *ep, unsigned int stid,
+			    __be32 addr, __be16 port)
+{
+	struct sk_buff *skb;
+	struct cpl_pass_open_req *req;
+
+	PDBG("%s stid %u addr %x port %x\n", __FUNCTION__, stid, ntohl(addr),
+	     ntohs(port));
 	skb = get_skb(NULL, sizeof(*req), GFP_KERNEL);
 	if (!skb) {
-		printk(KERN_ERR MOD "t3c_listen_start failed to alloc skb!\n");
+		printk(KERN_ERR MOD "%s - failed to alloc skb\n", __FUNCTION__);
 		return -ENOMEM;
 	}
 
 	req = (struct cpl_pass_open_req *) skb_put(skb, sizeof(*req));
 	req->wr.wr_hi = htonl(V_WR_OP(FW_WROPCODE_FORWARD));
-	OPCODE_TID(req) = htonl(MK_OPCODE_TID(CPL_PASS_OPEN_REQ, ep->stid));
-	req->local_port = ep->com.local_addr.sin_port;
-	req->local_ip = ep->com.local_addr.sin_addr.s_addr;
+	OPCODE_TID(req) = htonl(MK_OPCODE_TID(CPL_PASS_OPEN_REQ, stid));
+	req->local_port = port;
+	req->local_ip = addr;
 	req->peer_port = 0;
 	req->peer_ip = 0;
 	req->peer_netmask = 0;
@@ -1152,8 +1278,32 @@ static int listen_start(struct iwch_list
 	req->opt1 = htonl(V_CONN_POLICY(CPL_CONN_POLICY_ASK));
 
 	skb->priority = 1;
+	ep->com.rpl_err = 0;
+	ep->com.rpl_done = 0;
 	cxgb3_ofld_send(ep->com.tdev, skb);
-	return 0;
+	return wait_for_reply(&ep->com);
+}
+
+static int listen_start(struct iwch_listen_ep *ep)
+{
+	struct iwch_listen_entry *le;
+	struct iwch_dev *h = to_iwch_dev(ep->com.cm_id->device);
+	int err = 0;
+
+	PDBG("%s ep %p\n", __FUNCTION__, ep);
+	mutex_lock(&h->mutex);
+	list_for_each_entry(le, &ep->listeners, entry) {
+		err = listen_start_one(ep, le->stid, le->addr,
+				 ep->com.local_addr.sin_port);
+		if (err)
+			goto fail;
+	}
+	mutex_unlock(&h->mutex);
+	return err;
+fail:
+	mutex_unlock(&h->mutex);
+	listen_stop(ep);
+	return err;
 }
 
 static int pass_open_rpl(struct t3cdev *tdev, struct sk_buff *skb, void *ctx)
@@ -1170,39 +1320,59 @@ static int pass_open_rpl(struct t3cdev *
 	return CPL_RET_BUF_DONE;
 }
 
-static int listen_stop(struct iwch_listen_ep *ep)
-{
-	struct sk_buff *skb;
-	struct cpl_close_listserv_req *req;
-
-	PDBG("%s ep %p\n", __FUNCTION__, ep);
-	skb = get_skb(NULL, sizeof(*req), GFP_KERNEL);
-	if (!skb) {
-		printk(KERN_ERR MOD "%s - failed to alloc skb\n", __FUNCTION__);
-		return -ENOMEM;
-	}
-	req = (struct cpl_close_listserv_req *) skb_put(skb, sizeof(*req));
-	req->wr.wr_hi = htonl(V_WR_OP(FW_WROPCODE_FORWARD));
-	req->cpu_idx = 0;
-	OPCODE_TID(req) = htonl(MK_OPCODE_TID(CPL_CLOSE_LISTSRV_REQ, ep->stid));
-	skb->priority = 1;
-	cxgb3_ofld_send(ep->com.tdev, skb);
-	return 0;
-}
-
 static int close_listsrv_rpl(struct t3cdev *tdev, struct sk_buff *skb,
 			     void *ctx)
 {
 	struct iwch_listen_ep *ep = ctx;
 	struct cpl_close_listserv_rpl *rpl = cplhdr(skb);
 
-	PDBG("%s ep %p\n", __FUNCTION__, ep);
+	PDBG("%s ep %p stid %u\n", __FUNCTION__, ep, GET_TID(rpl));
+
 	ep->com.rpl_err = status2errno(rpl->status);
 	ep->com.rpl_done = 1;
 	wake_up(&ep->com.waitq);
 	return CPL_RET_BUF_DONE;
 }
 
+void iwch_listeners_add_addr(struct iwch_dev *rnicp, __be32 addr)
+{
+	struct iwch_listen_ep *listen_ep;
+	struct iwch_listen_entry *le;
+
+	mutex_lock(&rnicp->mutex);
+	list_for_each_entry(listen_ep, &rnicp->listen_eps, entry) {
+		if (listen_ep->com.local_addr.sin_addr.s_addr)
+			continue;
+		le = alloc_listener(listen_ep, addr);
+		if (le) {
+			list_add_tail(&le->entry, &listen_ep->listeners);
+			listen_start_one(listen_ep, le->stid, addr,
+					 listen_ep->com.local_addr.sin_port);
+		}
+	}
+	mutex_unlock(&rnicp->mutex);
+}
+
+void iwch_listeners_del_addr(struct iwch_dev *rnicp, __be32 addr)
+{
+	struct iwch_listen_ep *listen_ep;
+	struct iwch_listen_entry *le, *tmp;
+
+	mutex_lock(&rnicp->mutex);
+	list_for_each_entry(listen_ep, &rnicp->listen_eps, entry) {
+		if (listen_ep->com.local_addr.sin_addr.s_addr)
+			continue;
+		list_for_each_entry_safe(le, tmp, &listen_ep->listeners,
+					 entry)
+			if (le->addr == addr) {
+				listen_stop_one(listen_ep, le->stid);
+				list_del_init(&le->entry);
+				dealloc_listener(listen_ep, le);
+			}
+	}
+	mutex_unlock(&rnicp->mutex);
+}
+
 static void accept_cr(struct iwch_ep *ep, __be32 peer_ip, struct sk_buff *skb)
 {
 	struct cpl_pass_accept_rpl *rpl;
@@ -1767,8 +1937,7 @@ int iwch_accept_cr(struct iw_cm_id *cm_i
 		goto err;
 
 	/* wait for wr_ack */
-	wait_event(ep->com.waitq, ep->com.rpl_done);
-	err = ep->com.rpl_err;
+	err = wait_for_reply(&ep->com);
 	if (err)
 		goto err;
 
@@ -1887,31 +2056,23 @@ int iwch_create_listen(struct iw_cm_id *
 	ep->com.cm_id = cm_id;
 	ep->backlog = backlog;
 	ep->com.local_addr = cm_id->local_addr;
+	INIT_LIST_HEAD(&ep->listeners);
 
-	/*
-	 * Allocate a server TID.
-	 */
-	ep->stid = cxgb3_alloc_stid(h->rdev.t3cdev_p, &t3c_client, ep);
-	if (ep->stid == -1) {
-		printk(KERN_ERR MOD "%s - cannot alloc atid.\n", __FUNCTION__);
-		err = -ENOMEM;
+	err = alloc_listener_list(ep);
+	if (err)
 		goto fail2;
-	}
 
 	state_set(&ep->com, LISTEN);
 	err = listen_start(ep);
-	if (err)
-		goto fail3;
 
-	/* wait for pass_open_rpl */
-	wait_event(ep->com.waitq, ep->com.rpl_done);
-	err = ep->com.rpl_err;
 	if (!err) {
 		cm_id->provider_data = ep;
+		mutex_lock(&h->mutex);
+		list_add_tail(&ep->entry, &h->listen_eps);
+		mutex_unlock(&h->mutex);
 		goto out;
 	}
-fail3:
-	cxgb3_free_stid(ep->com.tdev, ep->stid);
+	dealloc_listener_list(ep);
 fail2:
 	cm_id->rem_ref(cm_id);
 	put_ep(&ep->com);
@@ -1923,18 +2084,20 @@ out:
 int iwch_destroy_listen(struct iw_cm_id *cm_id)
 {
 	int err;
+	struct iwch_dev *h = to_iwch_dev(cm_id->device);
 	struct iwch_listen_ep *ep = to_listen_ep(cm_id);
 
 	PDBG("%s ep %p\n", __FUNCTION__, ep);
 
 	might_sleep();
+	mutex_lock(&h->mutex);
+	list_del_init(&ep->entry);
+	mutex_unlock(&h->mutex);
 	state_set(&ep->com, DEAD);
 	ep->com.rpl_done = 0;
 	ep->com.rpl_err = 0;
 	err = listen_stop(ep);
-	wait_event(ep->com.waitq, ep->com.rpl_done);
-	cxgb3_free_stid(ep->com.tdev, ep->stid);
-	err = ep->com.rpl_err;
+	dealloc_listener_list(ep);
 	cm_id->rem_ref(cm_id);
 	put_ep(&ep->com);
 	return err;
diff --git a/drivers/infiniband/hw/cxgb3/iwch_cm.h b/drivers/infiniband/hw/cxgb3/iwch_cm.h
index 6107e7c..23e5a22 100644
--- a/drivers/infiniband/hw/cxgb3/iwch_cm.h
+++ b/drivers/infiniband/hw/cxgb3/iwch_cm.h
@@ -162,10 +162,19 @@ struct iwch_ep_common {
 	int rpl_err;
 };
 
-struct iwch_listen_ep {
-	struct iwch_ep_common com;
+struct iwch_listen_entry {
+	struct list_head entry;
 	unsigned int stid;
+	__be32 addr;
+};
+
+struct iwch_listen_ep {
+	struct iwch_ep_common com;	/* Must be first entry! */
+	struct list_head entry;
+	struct list_head listeners;
 	int backlog;
+	int listen_count;
+	int listen_rpls;
 };
 
 struct iwch_ep {
@@ -222,6 +231,8 @@ int iwch_resume_tid(struct iwch_ep *ep);
 void __free_ep(struct kref *kref);
 void iwch_rearp(struct iwch_ep *ep);
 int iwch_ep_redirect(void *ctx, struct dst_entry *old, struct dst_entry *new, struct l2t_entry *l2t);
+void iwch_listeners_add_addr(struct iwch_dev *rnicp, __be32 addr);
+void iwch_listeners_del_addr(struct iwch_dev *rnicp, __be32 addr);
 
 int __init iwch_cm_init(void);
 void __exit iwch_cm_term(void);
