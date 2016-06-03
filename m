From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net-next 04/15] smc: introduce SMC as an IB-client
Date: Fri,  3 Jun 2016 17:27:03 +0200
Message-ID: <201606031527.u53FQ1xY015796@mx0a-001b2d01.pphosted.com>
References: <cover.1464967161.git.ursula.braun@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
	utz.bacher@de.ibm.com, ubraun@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:47340 "EHLO
	mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752546AbcFCP1p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jun 2016 11:27:45 -0400
Received: from pps.filterd (m0075420.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u53FQ1xY015796
	for <netdev@vger.kernel.org>; Fri, 3 Jun 2016 11:27:44 -0400
Received: from e06smtp06.uk.ibm.com (e06smtp06.uk.ibm.com [195.75.94.102])
	by mx0a-001b2d01.pphosted.com with ESMTP id 23bcamrn52-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 03 Jun 2016 11:27:43 -0400
Received: from localhost
	by e06smtp06.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
	Fri, 3 Jun 2016 16:27:41 +0100
In-Reply-To: <cover.1464967161.git.ursula.braun@de.ibm.com>
In-Reply-To: <cover.1464967161.git.ursula.braun@de.ibm.com>
References: <cover.1464967161.git.ursula.braun@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* create a list of SMC IB-devices (IB-devices mentioned in PNET table)
* determine RoCE device and port belonging to used internal TCP interface
  according to the PNET table definitions

Signed-off-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
---
 net/smc/Makefile   |   2 +-
 net/smc/af_smc.c   |  10 ++++
 net/smc/smc.h      |   5 ++
 net/smc/smc_ib.c   | 157 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 net/smc/smc_ib.h   |  40 ++++++++++++++
 net/smc/smc_pnet.c |  98 +++++++++++++++++++++++++++++++++
 net/smc/smc_pnet.h |   7 +++
 7 files changed, 318 insertions(+), 1 deletion(-)
 create mode 100644 net/smc/smc_ib.c
 create mode 100644 net/smc/smc_ib.h

diff --git a/net/smc/Makefile b/net/smc/Makefile
index 64dab53..50f39ff 100644
--- a/net/smc/Makefile
+++ b/net/smc/Makefile
@@ -1,2 +1,2 @@
 obj-$(CONFIG_SMC)	+= smc.o
-smc-y := af_smc.o smc_pnet.o
+smc-y := af_smc.o smc_pnet.o smc_ib.o
diff --git a/net/smc/af_smc.c b/net/smc/af_smc.c
index e6bbadc..2fa3042 100644
--- a/net/smc/af_smc.c
+++ b/net/smc/af_smc.c
@@ -20,6 +20,7 @@
 #include <net/sock.h>
 
 #include "smc.h"
+#include "smc_ib.h"
 #include "smc_pnet.h"
 
 static void smc_set_keepalive(struct sock *sk, int val)
@@ -605,8 +606,16 @@ static int __init smc_init(void)
 		goto out_proto;
 	}
 
+	rc = smc_ib_register_client();
+	if (rc) {
+		pr_err("%s: ib_register fails with %d\n", __func__, rc);
+		goto out_sock;
+	}
+
 	return 0;
 
+out_sock:
+	sock_unregister(PF_SMC);
 out_proto:
 	proto_unregister(&smc_proto);
 out_pnet:
@@ -616,6 +625,7 @@ out_pnet:
 
 static void __exit smc_exit(void)
 {
+	smc_ib_unregister_client();
 	sock_unregister(PF_SMC);
 	proto_unregister(&smc_proto);
 	smc_pnet_exit();
diff --git a/net/smc/smc.h b/net/smc/smc.h
index f282b27..8f5c014 100644
--- a/net/smc/smc.h
+++ b/net/smc/smc.h
@@ -33,4 +33,9 @@ static inline struct smc_sock *smc_sk(const struct sock *sk)
 {
 	return (struct smc_sock *)sk;
 }
+
+#define SMC_SYSTEMID_LEN		8
+
+extern u8	local_systemid[SMC_SYSTEMID_LEN]; /* unique system identifier */
+
 #endif	/* _SMC_H */
diff --git a/net/smc/smc_ib.c b/net/smc/smc_ib.c
new file mode 100644
index 0000000..8b6bb50
--- /dev/null
+++ b/net/smc/smc_ib.c
@@ -0,0 +1,157 @@
+/*
+ *  Shared Memory Communications over RDMA (SMC-R) and RoCE
+ *
+ *  IB infrastructure:
+ *  Establish SMC-R as an Infiniband Client to be notified about added and
+ *  removed IB devices of type RDMA.
+ *  Determine device and port characteristics for these IB devices.
+ *
+ *  Copyright IBM Corp. 2016
+ *
+ *  Author(s):  Ursula Braun <ubraun@linux.vnet.ibm.com>
+ */
+
+#include <linux/random.h>
+#include <rdma/ib_verbs.h>
+
+#include "smc_pnet.h"
+#include "smc_ib.h"
+#include "smc.h"
+
+struct smc_ib_devices smc_ib_devices = {	/* smc-registered ib devices */
+	.lock = __SPIN_LOCK_UNLOCKED(smc_ib_devices.lock),
+	.list = LIST_HEAD_INIT(smc_ib_devices.list),
+};
+
+#define SMC_LOCAL_SYSTEMID_RESET	"%%%%%%%"
+
+u8 local_systemid[SMC_SYSTEMID_LEN] = SMC_LOCAL_SYSTEMID_RESET;	/* unique system
+								 * identifier
+								 */
+
+static int smc_ib_fill_gid_and_mac(struct smc_ib_device *smcibdev, u8 ibport)
+{
+	struct net_device *ndev;
+	int rc;
+
+	rc = ib_query_gid(smcibdev->ibdev, ibport, 0,
+			  &smcibdev->gid[ibport - 1], NULL);
+	/* the SMC protocol requires specification of the roce MAC address;
+	 * if net_device cannot be determined, it can be derived from gid 0
+	 */
+	ndev = smcibdev->ibdev->get_netdev(smcibdev->ibdev, ibport);
+	if (ndev) {
+		memcpy(&smcibdev->mac, ndev->dev_addr, ETH_ALEN);
+	} else if (!rc) {
+		memcpy(&smcibdev->mac[ibport - 1][0],
+		       &smcibdev->gid[ibport - 1].raw[8], 3);
+		memcpy(&smcibdev->mac[ibport - 1][3],
+		       &smcibdev->gid[ibport - 1].raw[13], 3);
+		smcibdev->mac[ibport - 1][0] &= ~0x02;
+	}
+	return rc;
+}
+
+/* Create an identifier unique for this instance of SMC-R.
+ * The MAC-address of the first active registered IB device
+ * plus a random 2-byte number is used to create this identifier.
+ * This name is delivered to the peer during connection initialization.
+ */
+static inline void smc_ib_define_local_systemid(struct smc_ib_device *smcibdev,
+						u8 ibport)
+{
+	memcpy(&local_systemid[2], &smcibdev->mac[ibport - 1],
+	       sizeof(smcibdev->mac[ibport - 1]));
+	get_random_bytes(&local_systemid[0], 2);
+}
+
+bool smc_ib_port_active(struct smc_ib_device *smcibdev, u8 ibport)
+{
+	return smcibdev->pattr[ibport - 1].state == IB_PORT_ACTIVE;
+}
+
+int smc_ib_remember_port_attr(struct smc_ib_device *smcibdev, u8 ibport)
+{
+	int rc;
+
+	memset(&smcibdev->pattr[ibport - 1], 0,
+	       sizeof(smcibdev->pattr[ibport - 1]));
+	rc = ib_query_port(smcibdev->ibdev, ibport,
+			   &smcibdev->pattr[ibport - 1]);
+	if (rc)
+		goto out;
+	rc = smc_ib_fill_gid_and_mac(smcibdev, ibport);
+	if (rc)
+		goto out;
+	if (!strncmp(local_systemid, SMC_LOCAL_SYSTEMID_RESET,
+		     sizeof(local_systemid)) &&
+	    smc_ib_port_active(smcibdev, ibport))
+		/* create unique system identifier */
+		smc_ib_define_local_systemid(smcibdev, ibport);
+out:
+	return rc;
+}
+
+static struct ib_client smc_ib_client;
+
+/* callback function for ib_register_client() */
+static void smc_ib_add_dev(struct ib_device *ibdev)
+{
+	struct smc_ib_device *smcibdev;
+	int i;
+
+	if (ibdev->node_type != RDMA_NODE_IB_CA)
+		return;
+
+	smcibdev = kzalloc(sizeof(*smcibdev), GFP_KERNEL);
+	if (!smcibdev)
+		return;
+
+	smcibdev->ibdev = ibdev;
+
+	for (i = 1; i <= SMC_MAX_PORTS; i++) {
+		if (smc_pnet_exists_in_table(smcibdev, i) &&
+		    !smcibdev->initialized) {
+			/* dev hotplug: ib device and port is in pnet table */
+			if (smc_ib_remember_port_attr(smcibdev, i)) {
+				kfree(smcibdev);
+				return;
+			}
+			smcibdev->initialized = 1;
+			break;
+		}
+	}
+	spin_lock(&smc_ib_devices.lock);
+	list_add_tail(&smcibdev->list, &smc_ib_devices.list);
+	spin_unlock(&smc_ib_devices.lock);
+	ib_set_client_data(ibdev, &smc_ib_client, smcibdev);
+}
+
+/* callback function for ib_register_client() */
+static void smc_ib_remove_dev(struct ib_device *ibdev, void *client_data)
+{
+	struct smc_ib_device *smcibdev;
+
+	smcibdev = ib_get_client_data(ibdev, &smc_ib_client);
+	ib_set_client_data(ibdev, &smc_ib_client, NULL);
+	spin_lock(&smc_ib_devices.lock);
+	list_del_init(&smcibdev->list); /* remove from smc_ib_devices */
+	spin_unlock(&smc_ib_devices.lock);
+	kfree(smcibdev);
+}
+
+static struct ib_client smc_ib_client = {
+	.name	= "smc_ib",
+	.add	= smc_ib_add_dev,
+	.remove = smc_ib_remove_dev,
+};
+
+int __init smc_ib_register_client(void)
+{
+	return ib_register_client(&smc_ib_client);
+}
+
+void smc_ib_unregister_client(void)
+{
+	ib_unregister_client(&smc_ib_client);
+}
diff --git a/net/smc/smc_ib.h b/net/smc/smc_ib.h
new file mode 100644
index 0000000..a1ca04f
--- /dev/null
+++ b/net/smc/smc_ib.h
@@ -0,0 +1,40 @@
+/*
+ * Shared Memory Communications over RDMA (SMC-R) and RoCE
+ *
+ *  Definitions for IB environment
+ *
+ *  Copyright IBM Corp. 2016
+ *
+ *  Author(s):  Ursula Braun <Ursula Braun@linux.vnet.ibm.com>
+ */
+
+#ifndef _SMC_IB_H
+#define _SMC_IB_H
+
+#include <rdma/ib_verbs.h>
+
+#define SMC_MAX_PORTS			2	/* Max # of ports */
+#define SMC_GID_SIZE			sizeof(union ib_gid)
+
+struct smc_ib_devices {			/* list of smc ib devices definition */
+	struct list_head	list;
+	spinlock_t		lock;	/* protects list of smc ib devices */
+};
+
+extern struct smc_ib_devices	smc_ib_devices; /* list of smc ib devices */
+
+struct smc_ib_device {				/* ib-device infos for smc */
+	struct list_head	list;
+	struct ib_device	*ibdev;
+	struct ib_port_attr	pattr[SMC_MAX_PORTS];	/* ib dev. port attrs */
+	char			mac[SMC_MAX_PORTS][6]; /* mac address per port*/
+	union ib_gid		gid[SMC_MAX_PORTS]; /* gid per port */
+	u8			initialized : 1; /* ib dev CQ, evthdl done */
+};
+
+int smc_ib_register_client(void) __init;
+void smc_ib_unregister_client(void);
+bool smc_ib_port_active(struct smc_ib_device *, u8);
+int smc_ib_remember_port_attr(struct smc_ib_device *, u8);
+
+#endif
diff --git a/net/smc/smc_pnet.c b/net/smc/smc_pnet.c
index 1d41375..ee4876d 100644
--- a/net/smc/smc_pnet.c
+++ b/net/smc/smc_pnet.c
@@ -18,6 +18,7 @@
 
 #include <rdma/ib_verbs.h>
 
+#include "smc_ib.h"
 #include "smc_pnet.h"
 
 #define SMC_MAX_PNET_ID_LEN	16	/* Max. length of PNET id */
@@ -185,6 +186,8 @@ static bool smc_pnet_same_ibname(struct smc_pnetentry *a, char *name, u8 ibport)
 static int smc_pnet_add_ib(struct smc_pnetentry *pnetelem, char *name,
 			   u8 ibport)
 {
+	struct smc_ib_device *smcibdev = NULL;
+	struct smc_ib_device *dev;
 	struct smc_pnetentry *p;
 	int rc = -EEXIST;
 
@@ -196,10 +199,32 @@ static int smc_pnet_add_ib(struct smc_pnetentry *pnetelem, char *name,
 	if (pnetelem->ib_name[0] == '\0') {
 		strncpy(pnetelem->ib_name, name, sizeof(pnetelem->ib_name));
 		pnetelem->ib_port = ibport;
+		spin_lock(&smc_ib_devices.lock);
+		/* using string ib_name, search smcibdev in global list */
+		list_for_each_entry(dev, &smc_ib_devices.list, list) {
+			if (!strncmp(dev->ibdev->name, pnetelem->ib_name,
+				     sizeof(pnetelem->ib_name))) {
+				smcibdev = dev;
+				break;
+			}
+		}
+		spin_unlock(&smc_ib_devices.lock);
 		rc = 0;
 	}
 out:
 	write_unlock(&smc_pnettable.lock);
+	if (smcibdev && !smcibdev->initialized) {
+		/* ib dev already existed [dev coldplug].
+		 * Complements: smc_ib_add_dev() [dev hotplug],
+		 * smc_ib_global_event_handler() [port hotplug].
+		 * Function call chain can sleep so outside of our locks.
+		 */
+		rc = smc_ib_remember_port_attr(smcibdev,
+					       pnetelem->ib_port);
+		if (rc)
+			return rc;
+		smcibdev->initialized = 1;
+	}
 	return rc;
 }
 
@@ -508,3 +533,76 @@ bad1:
 bad0:
 	return rc;
 }
+
+/* Scan the pnet table and find an IB device given the pnetid entry.
+ * Return infiniband device and port number if an active port is found.
+ * This function is called under smc_pnettable.lock.
+ */
+static void smc_pnet_ib_dev_by_pnet(struct smc_pnetentry *pnetelem,
+				    struct smc_ib_device **smcibdev, u8 *ibport)
+{
+	struct smc_ib_device *dev;
+
+	*smcibdev = NULL;
+	*ibport = 0;
+	spin_lock(&smc_ib_devices.lock);
+	/* using string ib->ib_name, search ibdev in global list */
+	list_for_each_entry(dev, &smc_ib_devices.list, list) {
+		if (!strncmp(dev->ibdev->name, pnetelem->ib_name,
+			     sizeof(pnetelem->ib_name)) &&
+		    smc_ib_port_active(dev, pnetelem->ib_port)) {
+			*smcibdev = dev;
+			*ibport = pnetelem->ib_port;
+			break;
+		}
+	}
+	spin_unlock(&smc_ib_devices.lock);
+}
+
+/* PNET table analysis for a given sock:
+ * determine ib_device and port belonging to used internal TCP socket
+ * ethernet interface.
+ */
+void smc_pnet_find_roce_resource(struct sock *sk,
+				 struct smc_ib_device **smcibdev, u8 *ibport)
+{
+	struct dst_entry *dst = sk_dst_get(sk);
+	struct smc_pnetentry *pnetelem;
+
+	*smcibdev = NULL;
+	*ibport = 0;
+
+	if (!dst)
+		return;
+	if (!dst->dev)
+		goto out_rel;
+	read_lock(&smc_pnettable.lock);
+	list_for_each_entry(pnetelem, &smc_pnettable.pnetlist, list) {
+		if (!strncmp(dst->dev->name, pnetelem->if_name, IFNAMSIZ)) {
+			smc_pnet_ib_dev_by_pnet(pnetelem, smcibdev, ibport);
+			break;
+		}
+	}
+	read_unlock(&smc_pnettable.lock);
+out_rel:
+	dst_release(dst);
+}
+
+/* Returns true if a specific ib_device and port is in the PNET table. */
+bool smc_pnet_exists_in_table(struct smc_ib_device *smcibdev, u8 ibport)
+{
+	struct smc_pnetentry *pnetelem;
+	int rc = false;
+
+	read_lock(&smc_pnettable.lock);
+	list_for_each_entry(pnetelem, &smc_pnettable.pnetlist, list) {
+		if (!strncmp(smcibdev->ibdev->name, pnetelem->ib_name,
+			     IB_DEVICE_NAME_MAX) &&
+		    ibport == pnetelem->ib_port) {
+			rc = true;
+			break;
+		}
+	}
+	read_unlock(&smc_pnettable.lock);
+	return rc;
+}
diff --git a/net/smc/smc_pnet.h b/net/smc/smc_pnet.h
index 34f85f6..1ff35df 100644
--- a/net/smc/smc_pnet.h
+++ b/net/smc/smc_pnet.h
@@ -13,6 +13,13 @@
 
 #define SMC_MAX_PORTS		2	/* Max # of ports */
 
+#include <net/sock.h>
+
+struct smc_ib_device;
+
+bool smc_pnet_exists_in_table(struct smc_ib_device *, u8);
+void smc_pnet_find_roce_resource(struct sock *, struct smc_ib_device **, u8 *);
+
 int smc_pnet_init(void) __init;
 void smc_pnet_exit(void);
 
-- 
2.6.6
