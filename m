From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Subject: [PATCH net-next V3 4/7] liquidio CN23XX: VF scatter gather lists
Date: Wed, 7 Dec 2016 08:54:34 -0800
Message-ID: <1481129677-10586-5-git-send-email-rvatsavayi@caviumnetworks.com>
References: <1481129677-10586-1-git-send-email-rvatsavayi@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
        Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>,
        Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>,
        Derek Chickles <derek.chickles@caviumnetworks.com>,
        Satanand Burla <satananda.burla@caviumnetworks.com>,
        Felix Manlunas <felix.manlunas@caviumnetworks.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-cys01nam02on0084.outbound.protection.outlook.com ([104.47.37.84]:43712
        "EHLO NAM02-CY1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S932532AbcLGQzH (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 7 Dec 2016 11:55:07 -0500
In-Reply-To: <1481129677-10586-1-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adds support for VF scatter gather lists.

Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
Signed-off-by: Derek Chickles <derek.chickles@caviumnetworks.com>
Signed-off-by: Satanand Burla <satananda.burla@caviumnetworks.com>
Signed-off-by: Felix Manlunas <felix.manlunas@caviumnetworks.com>
---
 drivers/net/ethernet/cavium/liquidio/lio_vf_main.c | 134 +++++++++++++++++++++
 1 file changed, 134 insertions(+)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
index 6f23944..f861a9b 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
@@ -55,10 +55,28 @@ struct liquidio_if_cfg_resp {
 	u64 status;
 };
 
+#define OCTNIC_MAX_SG  (MAX_SKB_FRAGS)
+
 #define OCTNIC_GSO_MAX_HEADER_SIZE 128
 #define OCTNIC_GSO_MAX_SIZE \
 		(CN23XX_DEFAULT_INPUT_JABBER - OCTNIC_GSO_MAX_HEADER_SIZE)
 
+struct octnic_gather {
+	/* List manipulation. Next and prev pointers. */
+	struct list_head list;
+
+	/* Size of the gather component at sg in bytes. */
+	int sg_size;
+
+	/* Number of bytes that sg was adjusted to make it 8B-aligned. */
+	int adjust;
+
+	/* Gather component that can accommodate max sized fragment list
+	 * received from the IP layer.
+	 */
+	struct octeon_sg_entry *sg;
+};
+
 struct octeon_device_priv {
 	/* Tasklet structures for this device. */
 	struct tasklet_struct droq_tasklet;
@@ -237,6 +255,114 @@ static void start_txq(struct net_device *netdev)
 }
 
 /**
+ * Remove the node at the head of the list. The list would be empty at
+ * the end of this call if there are no more nodes in the list.
+ */
+static struct list_head *list_delete_head(struct list_head *root)
+{
+	struct list_head *node;
+
+	if ((root->prev == root) && (root->next == root))
+		node = NULL;
+	else
+		node = root->next;
+
+	if (node)
+		list_del(node);
+
+	return node;
+}
+
+/**
+ * \brief Delete gather lists
+ * @param lio per-network private data
+ */
+static void delete_glists(struct lio *lio)
+{
+	struct octnic_gather *g;
+	int i;
+
+	if (!lio->glist)
+		return;
+
+	for (i = 0; i < lio->linfo.num_txpciq; i++) {
+		do {
+			g = (struct octnic_gather *)
+			    list_delete_head(&lio->glist[i]);
+			if (g) {
+				if (g->sg)
+					kfree((void *)((unsigned long)g->sg -
+							g->adjust));
+				kfree(g);
+			}
+		} while (g);
+	}
+
+	kfree(lio->glist);
+	kfree(lio->glist_lock);
+}
+
+/**
+ * \brief Setup gather lists
+ * @param lio per-network private data
+ */
+static int setup_glists(struct lio *lio, int num_iqs)
+{
+	struct octnic_gather *g;
+	int i, j;
+
+	lio->glist_lock =
+	    kzalloc(sizeof(*lio->glist_lock) * num_iqs, GFP_KERNEL);
+	if (!lio->glist_lock)
+		return 1;
+
+	lio->glist =
+	    kzalloc(sizeof(*lio->glist) * num_iqs, GFP_KERNEL);
+	if (!lio->glist) {
+		kfree(lio->glist_lock);
+		return 1;
+	}
+
+	for (i = 0; i < num_iqs; i++) {
+		spin_lock_init(&lio->glist_lock[i]);
+
+		INIT_LIST_HEAD(&lio->glist[i]);
+
+		for (j = 0; j < lio->tx_qsize; j++) {
+			g = kzalloc(sizeof(*g), GFP_KERNEL);
+			if (!g)
+				break;
+
+			g->sg_size = ((ROUNDUP4(OCTNIC_MAX_SG) >> 2) *
+				      OCT_SG_ENTRY_SIZE);
+
+			g->sg = kmalloc(g->sg_size + 8, GFP_KERNEL);
+			if (!g->sg) {
+				kfree(g);
+				break;
+			}
+
+			/* The gather component should be aligned on 64-bit
+			 * boundary
+			 */
+			if (((unsigned long)g->sg) & 7) {
+				g->adjust = 8 - (((unsigned long)g->sg) & 7);
+				g->sg = (struct octeon_sg_entry *)
+					((unsigned long)g->sg + g->adjust);
+			}
+			list_add_tail(&g->list, &lio->glist[i]);
+		}
+
+		if (j != lio->tx_qsize) {
+			delete_glists(lio);
+			return 1;
+		}
+	}
+
+	return 0;
+}
+
+/**
  * \brief Print link information
  * @param netdev network device
  */
@@ -681,6 +807,8 @@ static void liquidio_destroy_nic_device(struct octeon_device *oct, int ifidx)
 
 	cleanup_link_status_change_wq(netdev);
 
+	delete_glists(lio);
+
 	free_netdev(netdev);
 
 	oct->props[ifidx].gmxport = -1;
@@ -1379,6 +1507,12 @@ static int setup_nic_devices(struct octeon_device *octeon_dev)
 		/* Copy MAC Address to OS network device structure */
 		ether_addr_copy(netdev->dev_addr, mac);
 
+		if (setup_glists(lio, num_iqueues)) {
+			dev_err(&octeon_dev->pci_dev->dev,
+				"Gather list allocation failed\n");
+			goto setup_nic_dev_fail;
+		}
+
 		if (netdev->features & NETIF_F_LRO)
 			liquidio_set_feature(netdev, OCTNET_CMD_LRO_ENABLE,
 					     OCTNIC_LROIPV4 | OCTNIC_LROIPV6);
-- 
1.8.3.1
