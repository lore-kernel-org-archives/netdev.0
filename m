From: "Guilherme G. Piccoli" <gpiccoli@linux.vnet.ibm.com>
Subject: [PATCH net-next 1/2] be2net: set temperature value for all adapter's functions
Date: Fri, 22 Jul 2016 22:29:54 -0300
Message-ID: <1469237395-11501-1-git-send-email-gpiccoli@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org
To: sathya.perla@broadcom.com, ajit.khaparde@broadcom.com,
	padmanabh.ratnakar@broadcom.com,
	sriharsha.basavapatna@broadcom.com, somnath.kotur@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:13361 "EHLO
	mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751288AbcGWBaC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jul 2016 21:30:02 -0400
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u6N1TEHt072503
	for <netdev@vger.kernel.org>; Fri, 22 Jul 2016 21:30:01 -0400
Received: from e24smtp01.br.ibm.com (e24smtp01.br.ibm.com [32.104.18.85])
	by mx0a-001b2d01.pphosted.com with ESMTP id 24bhuvja5b-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 22 Jul 2016 21:30:01 -0400
Received: from localhost
	by e24smtp01.br.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <gpiccoli@linux.vnet.ibm.com>;
	Fri, 22 Jul 2016 22:29:58 -0300
Received: from d24relay01.br.ibm.com (d24relay01.br.ibm.com [9.8.31.16])
	by d24dlp02.br.ibm.com (Postfix) with ESMTP id 6C5181DC0051
	for <netdev@vger.kernel.org>; Fri, 22 Jul 2016 21:29:47 -0400 (EDT)
Received: from d24av04.br.ibm.com (d24av04.br.ibm.com [9.8.31.97])
	by d24relay01.br.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u6N1Ttl84272332
	for <netdev@vger.kernel.org>; Fri, 22 Jul 2016 22:29:55 -0300
Received: from d24av04.br.ibm.com (localhost [127.0.0.1])
	by d24av04.br.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u6N1Ttua022367
	for <netdev@vger.kernel.org>; Fri, 22 Jul 2016 22:29:55 -0300
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Temperature values on be2net driver are made available to userspace via
hwmon abstraction, so tools like lm-sensors can present them to the user.
The driver provides hwmon structures for each adapter's function.
Nevertheless, the temperature information come from fw queries performed by
be_worker() with some frequency, and this procedure is called with a single
function as argument; this means that the temperature value is updated only
in the specific function that was passed to be_worker().

This can lead to incongruency in reported temperature by a function, or in
a worse scenario, some functions might be unable to provide temperature
info to userspace, if they weren't fed with this information from fw in
be_worker() run.

This patch changes the way temperature is set in be2net driver. At anytime
the fw query is performed, it will set the temperature value for all
functions of the adapter, instead of only setting the temperature of the
function passed to be_worker().

Signed-off-by: Guilherme G. Piccoli <gpiccoli@linux.vnet.ibm.com>
---
 drivers/net/ethernet/emulex/benet/be.h      |  1 +
 drivers/net/ethernet/emulex/benet/be_cmds.c | 13 +++---
 drivers/net/ethernet/emulex/benet/be_main.c | 63 +++++++++++++++++++++++++++++
 3 files changed, 70 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index fe3763d..76f8fdb 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -851,6 +851,7 @@ u32 be_get_fw_log_level(struct be_adapter *adapter);
 int be_update_queues(struct be_adapter *adapter);
 int be_poll(struct napi_struct *napi, int budget);
 void be_eqd_update(struct be_adapter *adapter, bool force_update);
+void be_set_adapters_temperature_value(struct be_adapter *adapter, u8 temp);
 
 /*
  * internal function to initialize-cleanup roce device.
diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index 22402db..6c59351 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -221,13 +221,12 @@ static void be_async_cmd_process(struct be_adapter *adapter,
 		if (base_status == MCC_STATUS_SUCCESS) {
 			struct be_cmd_resp_get_cntl_addnl_attribs *resp =
 							(void *)resp_hdr;
-			adapter->hwmon_info.be_on_die_temp =
-						resp->on_die_temperature;
-		} else {
-			adapter->be_get_temp_freq = 0;
-			adapter->hwmon_info.be_on_die_temp =
-						BE_INVALID_DIE_TEMP;
-		}
+			be_set_adapters_temperature_value(adapter,
+							  resp->on_die_temperature);
+		} else
+			be_set_adapters_temperature_value(adapter,
+							  BE_INVALID_DIE_TEMP);
+
 		return;
 	}
 }
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index ed98ef1..9f44a00 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -53,6 +53,15 @@ static const struct pci_device_id be_dev_ids[] = {
 	{ 0 }
 };
 MODULE_DEVICE_TABLE(pci, be_dev_ids);
+
+struct adapter_list_node {
+	struct be_adapter *adapter;
+	struct list_head node;
+};
+
+static LIST_HEAD(adapters_list);
+static DEFINE_MUTEX(adapters_list_lock);
+
 /* UE Status Low CSR */
 static const char * const ue_status_low_desc[] = {
 	"CEV",
@@ -130,6 +139,40 @@ static const char * const ue_status_hi_desc[] = {
 				 BE_IF_FLAGS_MULTICAST | \
 				 BE_IF_FLAGS_PASS_L3L4_ERRORS)
 
+/* This procedure runs through adapters_list and sets the temperature for
+ * all functions of the same adapter. Since the temperature update is done
+ * by a single function in be_worker(), the other hwmon entries might remain
+ * with an invalid temperature.
+ */
+
+void be_set_adapters_temperature_value(struct be_adapter *adapter, u8 temp)
+{
+	struct adapter_list_node *adapter_lnode;
+	struct pci_bus *bus;
+	u8 bus_number, slot, dev;
+	u16 domain;
+
+	bus = adapter->pdev->bus;
+	domain = pci_domain_nr(bus);
+	bus_number = bus->number;
+	dev = PCI_SLOT(adapter->pdev->devfn);
+
+	mutex_lock(&adapters_list_lock);
+	list_for_each_entry(adapter_lnode, &adapters_list, node) {
+		bus = adapter_lnode->adapter->pdev->bus;
+		slot = PCI_SLOT(adapter_lnode->adapter->pdev->devfn);
+
+		if (pci_domain_nr(bus) == domain && bus->number == bus_number &&
+		    slot == dev) {
+			adapter_lnode->adapter->hwmon_info.be_on_die_temp
+								= temp;
+			if (unlikely(temp == BE_INVALID_DIE_TEMP))
+				adapter_lnode->adapter->be_get_temp_freq = 0;
+		}
+	}
+	mutex_unlock(&adapters_list_lock);
+}
+
 static void be_queue_free(struct be_adapter *adapter, struct be_queue_info *q)
 {
 	struct be_dma_mem *mem = &q->dma_mem;
@@ -5204,6 +5247,7 @@ free_mbox:
 static void be_remove(struct pci_dev *pdev)
 {
 	struct be_adapter *adapter = pci_get_drvdata(pdev);
+	struct adapter_list_node *lnode, *tmp;
 
 	if (!adapter)
 		return;
@@ -5215,6 +5259,15 @@ static void be_remove(struct pci_dev *pdev)
 
 	unregister_netdev(adapter->netdev);
 
+	mutex_lock(&adapters_list_lock);
+	list_for_each_entry_safe(lnode, tmp, &adapters_list, node)
+		if (lnode->adapter == adapter) {
+			list_del(&lnode->node);
+			kfree(lnode);
+			break;
+		}
+	mutex_unlock(&adapters_list_lock);
+
 	be_clear(adapter);
 
 	/* tell fw we're done with firing cmds */
@@ -5314,6 +5367,7 @@ static int be_probe(struct pci_dev *pdev, const struct pci_device_id *pdev_id)
 {
 	struct be_adapter *adapter;
 	struct net_device *netdev;
+	struct adapter_list_node *adapter_lnode;
 	int status = 0;
 
 	dev_info(&pdev->dev, "%s version is %s\n", DRV_NAME, DRV_VER);
@@ -5374,6 +5428,15 @@ static int be_probe(struct pci_dev *pdev, const struct pci_device_id *pdev_id)
 
 	be_schedule_err_detection(adapter, ERR_DETECTION_DELAY);
 
+	adapter_lnode = kmalloc(sizeof(*adapter_lnode), GFP_KERNEL);
+	if (adapter_lnode) {
+		adapter_lnode->adapter = adapter;
+		mutex_lock(&adapters_list_lock);
+		list_add_tail(&adapter_lnode->node, &adapters_list);
+		mutex_unlock(&adapters_list_lock);
+	} else
+		dev_warn(&pdev->dev, "Couldn't be added to adapters_list\n");
+
 	/* On Die temperature not supported for VF. */
 	if (be_physfn(adapter) && IS_ENABLED(CONFIG_BE2NET_HWMON)) {
 		adapter->hwmon_info.hwmon_dev =
-- 
2.1.0
