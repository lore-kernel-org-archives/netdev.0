From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 4/4] pktgen: fix device name handling
Date: Tue, 27 Feb 2007 12:13:12 -0800
Message-ID: <20070227121312.66b268df@freekitty>
References: <20070227120447.55a7e39d@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Robert Olsson <Robert.Olsson@data.slu.se>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:52667 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752636AbXB0VTo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Feb 2007 16:19:44 -0500
In-Reply-To: <20070227120447.55a7e39d@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since devices can change name and other wierdness, don't hold onto
a copy of device name, instead use pointer to output device.

Fix a couple of leaks in error handling path as well.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

---
 net/core/pktgen.c |  137 +++++++++++++++++++++++++++---------------------------
 1 file changed, 70 insertions(+), 67 deletions(-)

--- pktgen.orig/net/core/pktgen.c	2007-02-27 12:08:58.000000000 -0800
+++ pktgen/net/core/pktgen.c	2007-02-27 12:11:32.000000000 -0800
@@ -210,15 +210,11 @@
 };
 
 struct pktgen_dev {
-
 	/*
 	 * Try to keep frequent/infrequent used vars. separated.
 	 */
-
-	char ifname[IFNAMSIZ];
-	char result[512];
-
-	struct pktgen_thread *pg_thread;	/* the owner */
+	struct proc_dir_entry *entry;	/* proc file */
+	struct pktgen_thread *pg_thread;/* the owner */
 	struct list_head list;		/* Used for chaining in the thread's run-queue */
 
 	int running;		/* if this changes to false, the test will stop */
@@ -345,6 +341,8 @@
 	unsigned cflows;	/* Concurrent flows (config) */
 	unsigned lflow;		/* Flow length  (config) */
 	unsigned nflows;	/* accumulated flows (stats) */
+
+	char result[512];
 };
 
 struct pktgen_hdr {
@@ -497,7 +495,7 @@
 static int pktgen_stop_device(struct pktgen_dev *pkt_dev);
 static void pktgen_stop(struct pktgen_thread *t);
 static void pktgen_clear_counters(struct pktgen_dev *pkt_dev);
-static int pktgen_mark_device(const char *ifname);
+
 static unsigned int scan_ip6(const char *s, char ip[16]);
 static unsigned int fmt_ip6(char *s, const char ip[16]);
 
@@ -591,7 +589,7 @@
 		   "     frags: %d  delay: %u  clone_skb: %d  ifname: %s\n",
 		   pkt_dev->nfrags,
 		   1000 * pkt_dev->delay_us + pkt_dev->delay_ns,
-		   pkt_dev->clone_skb, pkt_dev->ifname);
+		   pkt_dev->clone_skb, pkt_dev->odev->name);
 
 	seq_printf(seq, "     flows: %u flowlen: %u\n", pkt_dev->cflows,
 		   pkt_dev->lflow);
@@ -1682,13 +1680,13 @@
 	if_lock(t);
 	list_for_each_entry(pkt_dev, &t->if_list, list)
 		if (pkt_dev->running)
-			seq_printf(seq, "%s ", pkt_dev->ifname);
+			seq_printf(seq, "%s ", pkt_dev->odev->name);
 
 	seq_printf(seq, "\nStopped: ");
 
 	list_for_each_entry(pkt_dev, &t->if_list, list)
 		if (!pkt_dev->running)
-			seq_printf(seq, "%s ", pkt_dev->ifname);
+			seq_printf(seq, "%s ", pkt_dev->odev->name);
 
 	if (t->result[0])
 		seq_printf(seq, "\nResult: %s\n", t->result);
@@ -1834,12 +1832,11 @@
 /*
  * mark a device for removal
  */
-static int pktgen_mark_device(const char *ifname)
+static void pktgen_mark_device(const char *ifname)
 {
 	struct pktgen_dev *pkt_dev = NULL;
 	const int max_tries = 10, msec_per_try = 125;
 	int i = 0;
-	int ret = 0;
 
 	mutex_lock(&pktgen_thread_lock);
 	pr_debug("pktgen: pktgen_mark_device marking %s for removal\n", ifname);
@@ -1860,32 +1857,49 @@
 			printk("pktgen_mark_device: timed out after waiting "
 			       "%d msec for device %s to be removed\n",
 			       msec_per_try * i, ifname);
-			ret = 1;
 			break;
 		}
 
 	}
 
 	mutex_unlock(&pktgen_thread_lock);
+}
 
-	return ret;
+static void pktgen_change_name(struct net_device *dev)
+{
+	struct pktgen_thread *t;
+
+	list_for_each_entry(t, &pktgen_threads, th_list) {
+		struct pktgen_dev *pkt_dev;
+
+		list_for_each_entry(pkt_dev, &t->if_list, list) {
+			if (pkt_dev->odev != dev)
+				continue;
+
+			remove_proc_entry(pkt_dev->entry->name, pg_proc_dir);
+
+			pkt_dev->entry = create_proc_entry(dev->name, 0600,
+							   pg_proc_dir);
+			if (!pkt_dev->entry)
+				printk(KERN_ERR "pktgen: can't move proc "
+				       " entry for '%s'\n", dev->name);
+			break;
+		}
+	}
 }
 
 static int pktgen_device_event(struct notifier_block *unused,
 			       unsigned long event, void *ptr)
 {
-	struct net_device *dev = (struct net_device *)(ptr);
+	struct net_device *dev = ptr;
 
 	/* It is OK that we do not hold the group lock right now,
 	 * as we run under the RTNL lock.
 	 */
 
 	switch (event) {
-	case NETDEV_CHANGEADDR:
-	case NETDEV_GOING_DOWN:
-	case NETDEV_DOWN:
-	case NETDEV_UP:
-		/* Ignore for now */
+	case NETDEV_CHANGENAME:
+		pktgen_change_name(dev);
 		break;
 
 	case NETDEV_UNREGISTER:
@@ -1898,41 +1912,36 @@
 
 /* Associate pktgen_dev with a device. */
 
-static struct net_device *pktgen_setup_dev(struct pktgen_dev *pkt_dev)
+static int pktgen_setup_dev(struct pktgen_dev *pkt_dev, const char *ifname)
 {
 	struct net_device *odev;
+	int err;
 
 	/* Clean old setups */
-
 	if (pkt_dev->odev) {
 		dev_put(pkt_dev->odev);
 		pkt_dev->odev = NULL;
 	}
 
-	odev = dev_get_by_name(pkt_dev->ifname);
-
+	odev = dev_get_by_name(ifname);
 	if (!odev) {
-		printk("pktgen: no such netdevice: \"%s\"\n", pkt_dev->ifname);
-		goto out;
+		printk("pktgen: no such netdevice: \"%s\"\n", ifname);
+		return -ENODEV;
 	}
+
 	if (odev->type != ARPHRD_ETHER) {
-		printk("pktgen: not an ethernet device: \"%s\"\n",
-		       pkt_dev->ifname);
-		goto out_put;
-	}
-	if (!netif_running(odev)) {
-		printk("pktgen: device is down: \"%s\"\n", pkt_dev->ifname);
-		goto out_put;
+		printk("pktgen: not an ethernet device: \"%s\"\n", ifname);
+		err = -EINVAL;
+	} else if (!netif_running(odev)) {
+		printk("pktgen: device is down: \"%s\"\n", ifname);
+		err = -ENETDOWN;
+	} else {
+		pkt_dev->odev = odev;
+		return 0;
 	}
-	pkt_dev->odev = odev;
-
-	return pkt_dev->odev;
 
-out_put:
 	dev_put(odev);
-out:
-	return NULL;
-
+	return err;
 }
 
 /* Read pkt_dev from the interface and set up internal pktgen_dev
@@ -1940,10 +1949,6 @@
  */
 static void pktgen_setup_inject(struct pktgen_dev *pkt_dev)
 {
-	/* Try once more, just in case it works now. */
-	if (!pkt_dev->odev)
-		pktgen_setup_dev(pkt_dev);
-
 	if (!pkt_dev->odev) {
 		printk("pktgen: ERROR: pkt_dev->odev == NULL in setup_inject.\n");
 		sprintf(pkt_dev->result,
@@ -2987,7 +2992,7 @@
 
 	if (!pkt_dev->running) {
 		printk("pktgen: interface: %s is already stopped\n",
-		       pkt_dev->ifname);
+		       pkt_dev->odev->name);
 		return -EINVAL;
 	}
 
@@ -3337,7 +3342,7 @@
 	if_lock(t);
 
 	list_for_each_entry(p, &t->if_list, list)
-		if (strncmp(p->ifname, ifname, IFNAMSIZ) == 0) {
+		if (strncmp(p->odev->name, ifname, IFNAMSIZ) == 0) {
 			pkt_dev = p;
 			break;
 		}
@@ -3378,7 +3383,7 @@
 static int pktgen_add_device(struct pktgen_thread *t, const char *ifname)
 {
 	struct pktgen_dev *pkt_dev;
-	struct proc_dir_entry *pe;
+	int err;
 
 	/* We don't allow a device to be on several threads */
 
@@ -3420,29 +3425,28 @@
 	pkt_dev->svlan_cfi = 0;
 	pkt_dev->svlan_id = 0xffff;
 
-	strncpy(pkt_dev->ifname, ifname, IFNAMSIZ);
+	err = pktgen_setup_dev(pkt_dev, ifname);
+	if (err)
+		goto out1;
 
-	if (!pktgen_setup_dev(pkt_dev)) {
-		printk("pktgen: ERROR: pktgen_setup_dev failed.\n");
-		if (pkt_dev->flows)
-			vfree(pkt_dev->flows);
-		kfree(pkt_dev);
-		return -ENODEV;
-	}
-
-	pe = create_proc_entry(ifname, 0600, pg_proc_dir);
-	if (!pe) {
+	pkt_dev->entry = create_proc_entry(ifname, 0600, pg_proc_dir);
+	if (!pkt_dev->entry) {
 		printk("pktgen: cannot create %s/%s procfs entry.\n",
 		       PG_PROC_DIR, ifname);
-		if (pkt_dev->flows)
-			vfree(pkt_dev->flows);
-		kfree(pkt_dev);
-		return -EINVAL;
+		err = -EINVAL;
+		goto out2;
 	}
-	pe->proc_fops = &pktgen_if_fops;
-	pe->data = pkt_dev;
+	pkt_dev->entry->proc_fops = &pktgen_if_fops;
+	pkt_dev->entry->data = pkt_dev;
 
 	return add_dev_to_thread(t, pkt_dev);
+out2:
+	dev_put(pkt_dev->odev);
+out1:
+	if (pkt_dev->flows)
+		vfree(pkt_dev->flows);
+	kfree(pkt_dev);
+	return err;
 }
 
 static int __init pktgen_create_thread(int cpu)
@@ -3530,9 +3534,8 @@
 
 	_rem_dev_from_if_list(t, pkt_dev);
 
-	/* Clean up proc file system */
-
-	remove_proc_entry(pkt_dev->ifname, pg_proc_dir);
+	if (pkt_dev->entry)
+		remove_proc_entry(pkt_dev->entry->name, pg_proc_dir);
 
 	if (pkt_dev->flows)
 		vfree(pkt_dev->flows);
