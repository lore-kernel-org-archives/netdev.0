From: John Allen <jallen@linux.vnet.ibm.com>
Subject: [PATCH net-next 1/2] ibmvnic: Update reset infrastructure to support
 tunable parameters
Date: Fri, 20 Oct 2017 16:02:22 -0500
Message-ID: <17d5c9cb-740c-cde2-140a-4f9e938f5313@linux.vnet.ibm.com>
References: <9bafaca4-75e7-ba82-8eea-35a69c61b6db@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org,
        Thomas Falcon <tlfalcon@linux.vnet.ibm.com>,
        Nathan Fontenot <nfont@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:47508 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751721AbdJTVCc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2017 17:02:32 -0400
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v9KL2U3u094502
        for <netdev@vger.kernel.org>; Fri, 20 Oct 2017 17:02:32 -0400
Received: from e12.ny.us.ibm.com (e12.ny.us.ibm.com [129.33.205.202])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2dqn708b03-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 20 Oct 2017 17:02:31 -0400
Received: from localhost
        by e12.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <jallen@linux.vnet.ibm.com>;
        Fri, 20 Oct 2017 17:02:25 -0400
In-Reply-To: <9bafaca4-75e7-ba82-8eea-35a69c61b6db@linux.vnet.ibm.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update ibmvnic reset infrastructure to include a new reset option that will
allow changing of tunable parameters. There currently is no way to request
different capabilities from the vnic server on the fly so this patch
achieves this by resetting the driver and attempting to log in with the
requested changes. If the reset operation fails, the old values of the
tunable parameters are stored in the "fallback" struct and we attempt to
login with the fallback values.

Signed-off-by: John Allen <jallen@linux.vnet.ibm.com>
---
diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
index 4bc14a9..36898b0 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.c
+++ b/drivers/net/ethernet/ibm/ibmvnic.c
@@ -115,6 +115,7 @@ static union sub_crq *ibmvnic_next_scrq(struct ibmvnic_adapter *,
 static int init_sub_crq_irqs(struct ibmvnic_adapter *adapter);
 static int ibmvnic_init(struct ibmvnic_adapter *);
 static void release_crq_queue(struct ibmvnic_adapter *);
+static int __ibmvnic_set_mac(struct net_device *netdev, struct sockaddr *p);

 struct ibmvnic_stat {
 	char name[ETH_GSTRING_LEN];
@@ -910,6 +911,11 @@ static int ibmvnic_open(struct net_device *netdev)

 	mutex_lock(&adapter->reset_lock);

+	if (adapter->desired->mac) {
+		__ibmvnic_set_mac(netdev, adapter->desired->mac);
+		adapter->desired->mac = NULL;
+	}
+
 	if (adapter->state != VNIC_CLOSED) {
 		rc = ibmvnic_login(netdev);
 		if (rc) {
@@ -1372,7 +1378,7 @@ static void ibmvnic_set_multi(struct net_device *netdev)
 	}
 }

-static int ibmvnic_set_mac(struct net_device *netdev, void *p)
+static int __ibmvnic_set_mac(struct net_device *netdev, struct sockaddr *p)
 {
 	struct ibmvnic_adapter *adapter = netdev_priv(netdev);
 	struct sockaddr *addr = p;
@@ -1390,6 +1396,21 @@ static int ibmvnic_set_mac(struct net_device *netdev, void *p)
 	return 0;
 }

+static int ibmvnic_set_mac(struct net_device *netdev, void *p)
+{
+	struct ibmvnic_adapter *adapter = netdev_priv(netdev);
+	struct sockaddr *addr = p;
+
+	if (adapter->state != VNIC_OPEN) {
+		memcpy(adapter->desired->mac, addr, sizeof(struct sockaddr));
+		return 0;
+	}
+
+	__ibmvnic_set_mac(netdev, addr);
+
+	return 0;
+}
+
 /**
  * do_reset returns zero if we are able to keep processing reset events, or
  * non-zero if we hit a fatal error and must halt.
@@ -1416,6 +1437,13 @@ static int do_reset(struct ibmvnic_adapter *adapter,
 	if (rc)
 		return rc;

+	if (adapter->reset_reason == VNIC_RESET_CHANGE_PARAM ||
+	    adapter->wait_for_reset) {
+		release_resources(adapter);
+		release_sub_crqs(adapter);
+		release_crq_queue(adapter);
+	}
+
 	if (adapter->reset_reason != VNIC_RESET_NON_FATAL) {
 		/* remove the closed state so when we call open it appears
 		 * we are coming from the probed state.
@@ -1438,16 +1466,23 @@ static int do_reset(struct ibmvnic_adapter *adapter,
 			return 0;
 		}

-		rc = reset_tx_pools(adapter);
-		if (rc)
-			return rc;
+		if (adapter->reset_reason == VNIC_RESET_CHANGE_PARAM ||
+		    adapter->wait_for_reset) {
+			rc = init_resources(adapter);
+			if (rc)
+				return rc;
+		} else {
+			rc = reset_tx_pools(adapter);
+			if (rc)
+				return rc;

-		rc = reset_rx_pools(adapter);
-		if (rc)
-			return rc;
+			rc = reset_rx_pools(adapter);
+			if (rc)
+				return rc;

-		if (reset_state == VNIC_CLOSED)
-			return 0;
+			if (reset_state == VNIC_CLOSED)
+				return 0;
+		}
 	}

 	rc = __ibmvnic_open(netdev);
@@ -1526,6 +1561,12 @@ static void __ibmvnic_reset(struct work_struct *work)
 		rwi = get_next_rwi(adapter);
 	}

+	if (adapter->wait_for_reset) {
+		adapter->wait_for_reset = false;
+		adapter->reset_done_rc = rc;
+		complete(&adapter->reset_done);
+	}
+
 	if (rc) {
 		netdev_dbg(adapter->netdev, "Reset failed\n");
 		free_all_rwi(adapter);
@@ -1705,9 +1746,42 @@ static void ibmvnic_netpoll_controller(struct net_device *dev)
 }
 #endif

+static int wait_for_reset(struct ibmvnic_adapter *adapter)
+{
+	adapter->fallback->mtu = adapter->req_mtu;
+	adapter->fallback->rx_queues = adapter->req_rx_queues;
+	adapter->fallback->tx_queues = adapter->req_tx_queues;
+	adapter->fallback->rx_entries = adapter->req_rx_add_entries_per_subcrq;
+	adapter->fallback->tx_entries = adapter->req_tx_entries_per_subcrq;
+
+	init_completion(&adapter->reset_done);
+	ibmvnic_reset(adapter, VNIC_RESET_CHANGE_PARAM);
+	adapter->wait_for_reset = true;
+	wait_for_completion(&adapter->reset_done);
+
+	if (adapter->reset_done_rc) {
+		adapter->desired->mtu = adapter->fallback->mtu;
+		adapter->desired->rx_queues = adapter->fallback->rx_queues;
+		adapter->desired->tx_queues = adapter->fallback->tx_queues;
+		adapter->desired->rx_entries = adapter->fallback->rx_entries;
+		adapter->desired->tx_entries = adapter->fallback->tx_entries;
+
+		init_completion(&adapter->reset_done);
+		ibmvnic_reset(adapter, VNIC_RESET_CHANGE_PARAM);
+		wait_for_completion(&adapter->reset_done);
+	}
+	adapter->wait_for_reset = false;
+
+	return adapter->reset_done_rc;
+}
+
 static int ibmvnic_change_mtu(struct net_device *netdev, int new_mtu)
 {
-	return -EOPNOTSUPP;
+	struct ibmvnic_adapter *adapter = netdev_priv(netdev);
+
+	adapter->desired->mtu = new_mtu + ETH_HLEN;
+
+	return wait_for_reset(adapter);
 }

 static const struct net_device_ops ibmvnic_netdev_ops = {
@@ -1795,6 +1869,27 @@ static void ibmvnic_get_ringparam(struct net_device *netdev,
 	ring->rx_jumbo_pending = 0;
 }

+static int ibmvnic_set_ringparam(struct net_device *netdev,
+				 struct ethtool_ringparam *ring)
+{
+	struct ibmvnic_adapter *adapter = netdev_priv(netdev);
+
+	if (ring->rx_pending > adapter->max_rx_add_entries_per_subcrq  ||
+	    ring->tx_pending > adapter->max_tx_entries_per_subcrq) {
+		netdev_err(netdev, "Invalid request.\n");
+		netdev_err(netdev, "Max tx buffers = %llu\n",
+			   adapter->max_rx_add_entries_per_subcrq);
+		netdev_err(netdev, "Max rx buffers = %llu\n",
+			   adapter->max_tx_entries_per_subcrq);
+		return -EINVAL;
+	}
+
+	adapter->desired->rx_entries = ring->rx_pending;
+	adapter->desired->tx_entries = ring->tx_pending;
+
+	return wait_for_reset(adapter);
+}
+
 static void ibmvnic_get_channels(struct net_device *netdev,
 				 struct ethtool_channels *channels)
 {
@@ -1810,6 +1905,17 @@ static void ibmvnic_get_channels(struct net_device *netdev,
 	channels->combined_count = 0;
 }

+static int ibmvnic_set_channels(struct net_device *netdev,
+				struct ethtool_channels *channels)
+{
+	struct ibmvnic_adapter *adapter = netdev_priv(netdev);
+
+	adapter->desired->rx_queues = channels->rx_count;
+	adapter->desired->tx_queues = channels->tx_count;
+
+	return wait_for_reset(adapter);
+}
+
 static void ibmvnic_get_strings(struct net_device *dev, u32 stringset, u8 *data)
 {
 	struct ibmvnic_adapter *adapter = netdev_priv(dev);
@@ -1906,7 +2012,9 @@ static void ibmvnic_get_ethtool_stats(struct net_device *dev,
 	.set_msglevel		= ibmvnic_set_msglevel,
 	.get_link		= ibmvnic_get_link,
 	.get_ringparam		= ibmvnic_get_ringparam,
+	.set_ringparam		= ibmvnic_set_ringparam,
 	.get_channels		= ibmvnic_get_channels,
+	.set_channels		= ibmvnic_set_channels,
 	.get_strings            = ibmvnic_get_strings,
 	.get_sset_count         = ibmvnic_get_sset_count,
 	.get_ethtool_stats	= ibmvnic_get_ethtool_stats,
@@ -2372,6 +2480,7 @@ static void ibmvnic_send_req_caps(struct ibmvnic_adapter *adapter, int retry)
 {
 	struct device *dev = &adapter->vdev->dev;
 	union ibmvnic_crq crq;
+	int max_entries;

 	if (!retry) {
 		/* Sub-CRQ entries are 32 byte long */
@@ -2383,21 +2492,60 @@ static void ibmvnic_send_req_caps(struct ibmvnic_adapter *adapter, int retry)
 			return;
 		}

-		/* Get the minimum between the queried max and the entries
-		 * that fit in our PAGE_SIZE
-		 */
-		adapter->req_tx_entries_per_subcrq =
-		    adapter->max_tx_entries_per_subcrq > entries_page ?
-		    entries_page : adapter->max_tx_entries_per_subcrq;
-		adapter->req_rx_add_entries_per_subcrq =
-		    adapter->max_rx_add_entries_per_subcrq > entries_page ?
-		    entries_page : adapter->max_rx_add_entries_per_subcrq;
-
-		adapter->req_tx_queues = adapter->opt_tx_comp_sub_queues;
-		adapter->req_rx_queues = adapter->opt_rx_comp_queues;
-		adapter->req_rx_add_queues = adapter->max_rx_add_queues;
+		if (adapter->desired->mtu)
+			adapter->req_mtu = adapter->desired->mtu;
+		else
+			adapter->req_mtu = adapter->netdev->mtu + ETH_HLEN;
+
+		if (!adapter->desired->tx_entries)
+			adapter->desired->tx_entries =
+					adapter->max_tx_entries_per_subcrq;
+		if (!adapter->desired->rx_entries)
+			adapter->desired->rx_entries =
+					adapter->max_rx_add_entries_per_subcrq;
+
+		max_entries = IBMVNIC_MAX_LTB_SIZE /
+			      (adapter->req_mtu + IBMVNIC_BUFFER_HLEN);
+
+		if ((adapter->req_mtu + IBMVNIC_BUFFER_HLEN) *
+			adapter->desired->tx_entries > IBMVNIC_MAX_LTB_SIZE) {
+			adapter->desired->tx_entries = max_entries;
+		}
+
+		if ((adapter->req_mtu + IBMVNIC_BUFFER_HLEN) *
+			adapter->desired->rx_entries > IBMVNIC_MAX_LTB_SIZE) {
+			adapter->desired->rx_entries = max_entries;
+		}

-		adapter->req_mtu = adapter->netdev->mtu + ETH_HLEN;
+		if (adapter->desired->tx_entries)
+			adapter->req_tx_entries_per_subcrq =
+					adapter->desired->tx_entries;
+		else
+			adapter->req_tx_entries_per_subcrq =
+					adapter->max_tx_entries_per_subcrq;
+
+		if (adapter->desired->rx_entries)
+			adapter->req_rx_add_entries_per_subcrq =
+					adapter->desired->rx_entries;
+		else
+			adapter->req_rx_add_entries_per_subcrq =
+					adapter->max_rx_add_entries_per_subcrq;
+
+		if (adapter->desired->tx_queues)
+			adapter->req_tx_queues =
+					adapter->desired->tx_queues;
+		else
+			adapter->req_tx_queues =
+					adapter->opt_tx_comp_sub_queues;
+
+		if (adapter->desired->rx_queues)
+			adapter->req_rx_queues =
+					adapter->desired->rx_queues;
+		else
+			adapter->req_rx_queues =
+					adapter->opt_rx_comp_queues;
+
+		adapter->req_rx_add_queues = adapter->max_rx_add_queues;
 	}

 	memset(&crq, 0, sizeof(crq));
@@ -3211,6 +3359,7 @@ static int handle_login_rsp(union ibmvnic_crq *login_rsp_crq,
 			    struct ibmvnic_adapter *adapter)
 {
 	struct device *dev = &adapter->vdev->dev;
+	struct net_device *netdev = adapter->netdev;
 	struct ibmvnic_login_rsp_buffer *login_rsp = adapter->login_rsp_buf;
 	struct ibmvnic_login_buffer *login = adapter->login_buf;
 	int i;
@@ -3230,6 +3379,8 @@ static int handle_login_rsp(union ibmvnic_crq *login_rsp_crq,
 		return 0;
 	}

+	netdev->mtu = adapter->req_mtu - ETH_HLEN;
+
 	netdev_dbg(adapter->netdev, "Login Response Buffer:\n");
 	for (i = 0; i < (adapter->login_rsp_buf_sz - 1) / 8 + 1; i++) {
 		netdev_dbg(adapter->netdev, "%016lx\n",
@@ -3785,7 +3936,7 @@ static int ibmvnic_init(struct ibmvnic_adapter *adapter)
 	unsigned long timeout = msecs_to_jiffies(30000);
 	int rc;

-	if (adapter->resetting) {
+	if (adapter->resetting && !adapter->wait_for_reset) {
 		rc = ibmvnic_reset_crq(adapter);
 		if (!rc)
 			rc = vio_enable_interrupts(adapter->vdev);
@@ -3819,7 +3970,7 @@ static int ibmvnic_init(struct ibmvnic_adapter *adapter)
 		return -1;
 	}

-	if (adapter->resetting)
+	if (adapter->resetting && !adapter->wait_for_reset)
 		rc = reset_sub_crq_queues(adapter);
 	else
 		rc = init_sub_crqs(adapter);
@@ -3870,6 +4021,11 @@ static int ibmvnic_probe(struct vio_dev *dev, const struct vio_device_id *id)
 	adapter->vdev = dev;
 	adapter->netdev = netdev;

+	adapter->desired = kzalloc(sizeof(*adapter->desired), GFP_KERNEL);
+	adapter->desired->mac = kzalloc(sizeof(*adapter->desired->mac),
+					GFP_KERNEL);
+	adapter->fallback = kzalloc(sizeof(*adapter->fallback), GFP_KERNEL);
+
 	ether_addr_copy(adapter->mac_addr, mac_addr_p);
 	ether_addr_copy(netdev->dev_addr, adapter->mac_addr);
 	netdev->irq = dev->irq;
@@ -3895,6 +4051,8 @@ static int ibmvnic_probe(struct vio_dev *dev, const struct vio_device_id *id)
 	} while (rc == EAGAIN);

 	netdev->mtu = adapter->req_mtu - ETH_HLEN;
+	netdev->min_mtu = adapter->min_mtu - ETH_HLEN;
+	netdev->max_mtu = adapter->max_mtu - ETH_HLEN;

 	rc = device_create_file(&dev->dev, &dev_attr_failover);
 	if (rc)
@@ -3909,6 +4067,9 @@ static int ibmvnic_probe(struct vio_dev *dev, const struct vio_device_id *id)
 	dev_info(&dev->dev, "ibmvnic registered\n");

 	adapter->state = VNIC_PROBED;
+
+	adapter->wait_for_reset = false;
+
 	return 0;

 ibmvnic_register_fail:
@@ -3932,6 +4093,11 @@ static int ibmvnic_remove(struct vio_dev *dev)
 	mutex_lock(&adapter->reset_lock);

 	release_resources(adapter);
+
+	kfree(adapter->desired->mac);
+	kfree(adapter->desired);
+	kfree(adapter->fallback);
+
 	release_sub_crqs(adapter);
 	release_crq_queue(adapter);

diff --git a/drivers/net/ethernet/ibm/ibmvnic.h b/drivers/net/ethernet/ibm/ibmvnic.h
index d02257c..5347a7c 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.h
+++ b/drivers/net/ethernet/ibm/ibmvnic.h
@@ -38,7 +38,8 @@
 /* when changing this, update IBMVNIC_IO_ENTITLEMENT_DEFAULT */
 #define IBMVNIC_BUFFS_PER_POOL	100
 #define IBMVNIC_MAX_TX_QUEUES	5
-
+#define IBMVNIC_MAX_LTB_SIZE ((1 << (MAX_ORDER - 1)) * PAGE_SIZE)
+#define IBMVNIC_BUFFER_HLEN 500
 struct ibmvnic_login_buffer {
 	__be32 len;
 	__be32 version;
@@ -940,13 +941,23 @@ enum ibmvnic_reset_reason {VNIC_RESET_FAILOVER = 1,
 			   VNIC_RESET_MOBILITY,
 			   VNIC_RESET_FATAL,
 			   VNIC_RESET_NON_FATAL,
-			   VNIC_RESET_TIMEOUT};
+			   VNIC_RESET_TIMEOUT,
+			   VNIC_RESET_CHANGE_PARAM};

 struct ibmvnic_rwi {
 	enum ibmvnic_reset_reason reset_reason;
 	struct list_head list;
 };

+struct ibmvnic_tunables {
+	u64 rx_queues;
+	u64 tx_queues;
+	u64 rx_entries;
+	u64 tx_entries;
+	u64 mtu;
+	struct sockaddr *mac;
+};
+
 struct ibmvnic_adapter {
 	struct vio_dev *vdev;
 	struct net_device *netdev;
@@ -1007,6 +1018,10 @@ struct ibmvnic_adapter {
 	struct completion fw_done;
 	int fw_done_rc;

+	struct completion reset_done;
+	int reset_done_rc;
+	bool wait_for_reset;
+
 	/* partner capabilities */
 	u64 min_tx_queues;
 	u64 min_rx_queues;
@@ -1051,4 +1066,7 @@ struct ibmvnic_adapter {
 	struct work_struct ibmvnic_reset;
 	bool resetting;
 	bool napi_enabled, from_passive_init;
+
+	struct ibmvnic_tunables *desired;
+	struct ibmvnic_tunables *fallback;
 };
