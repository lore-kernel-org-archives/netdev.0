From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH V4 net-next 03/15] smc: introduce SMC as an IB-client
Date: Mon,  9 Jan 2017 16:55:14 +0100
Message-ID: <20170109155526.10961-4-ubraun@linux.vnet.ibm.com>
References: <20170109155526.10961-1-ubraun@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
        schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
        utz.bacher@de.ibm.com, ubraun@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:54061 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S967910AbdAIPzj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2017 10:55:39 -0500
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id v09Frt11016193
        for <netdev@vger.kernel.org>; Mon, 9 Jan 2017 10:55:38 -0500
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
        by mx0a-001b2d01.pphosted.com with ESMTP id 27vbmvx04k-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 09 Jan 2017 10:55:38 -0500
Received: from localhost
        by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
        Mon, 9 Jan 2017 15:55:36 -0000
In-Reply-To: <20170109155526.10961-1-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* create a list of SMC IB-devices

Signed-off-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
---
 net/smc/Makefile |   2 +-
 net/smc/af_smc.c |  10 ++++
 net/smc/smc.h    |   6 +++
 net/smc/smc_ib.c | 143 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
 net/smc/smc_ib.h |  40 ++++++++++++++++
 5 files changed, 200 insertions(+), 1 deletion(-)
 create mode 100644 net/smc/smc_ib.c
 create mode 100644 net/smc/smc_ib.h

diff --git a/net/smc/Makefile b/net/smc/Makefile
index c285c86..56f2170 100644
--- a/net/smc/Makefile
+++ b/net/smc/Makefile
@@ -1,2 +1,2 @@
 obj-$(CONFIG_SMC)	+= smc.o
-smc-y := af_smc.o
+smc-y := af_smc.o smc_ib.o
diff --git a/net/smc/af_smc.c b/net/smc/af_smc.c
index 7fd773f..50492ee 100644
--- a/net/smc/af_smc.c
+++ b/net/smc/af_smc.c
@@ -20,6 +20,7 @@
 #include <net/sock.h>
 
 #include "smc.h"
+#include "smc_ib.h"
 
 static void smc_set_keepalive(struct sock *sk, int val)
 {
@@ -597,8 +598,16 @@ static int __init smc_init(void)
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
 out:
@@ -607,6 +616,7 @@ static int __init smc_init(void)
 
 static void __exit smc_exit(void)
 {
+	smc_ib_unregister_client();
 	sock_unregister(PF_SMC);
 	proto_unregister(&smc_proto);
 }
diff --git a/net/smc/smc.h b/net/smc/smc.h
index fcea739..e87d798 100644
--- a/net/smc/smc.h
+++ b/net/smc/smc.h
@@ -16,6 +16,8 @@
 
 #define SMCPROTO_SMC		0	/* SMC protocol */
 
+#define SMC_MAX_PORTS		2	/* Max # of ports */
+
 enum smc_state {		/* possible states of an SMC socket */
 	SMC_ACTIVE	= 1,
 	SMC_INIT	= 2,
@@ -34,4 +36,8 @@ static inline struct smc_sock *smc_sk(const struct sock *sk)
 	return (struct smc_sock *)sk;
 }
 
+#define SMC_SYSTEMID_LEN		8
+
+extern u8	local_systemid[SMC_SYSTEMID_LEN]; /* unique system identifier */
+
 #endif	/* __SMC_H */
diff --git a/net/smc/smc_ib.c b/net/smc/smc_ib.c
new file mode 100644
index 0000000..7222b7e
--- /dev/null
+++ b/net/smc/smc_ib.c
@@ -0,0 +1,143 @@
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
index 0000000..63613e7
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
+bool smc_ib_port_active(struct smc_ib_device *smcibdev, u8 ibport);
+int smc_ib_remember_port_attr(struct smc_ib_device *smcibdev, u8 ibport);
+
+#endif
-- 
2.8.4
