From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Subject: [PATCH net-next 4/5] liquidio VF timestamp
Date: Thu, 8 Dec 2016 13:00:47 -0800
Message-ID: <1481230848-2393-5-git-send-email-rvatsavayi@caviumnetworks.com>
References: <1481230848-2393-1-git-send-email-rvatsavayi@caviumnetworks.com>
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
Received: from mail-by2nam03on0072.outbound.protection.outlook.com ([104.47.42.72]:2178
        "EHLO NAM03-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753436AbcLHVBX (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 8 Dec 2016 16:01:23 -0500
In-Reply-To: <1481230848-2393-1-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adds support for VF timestamp.

Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
Signed-off-by: Derek Chickles <derek.chickles@caviumnetworks.com>
Signed-off-by: Satanand Burla <satananda.burla@caviumnetworks.com>
Signed-off-by: Felix Manlunas <felix.manlunas@caviumnetworks.com>
---
 drivers/net/ethernet/cavium/liquidio/lio_vf_main.c | 180 ++++++++++++++++++++-
 1 file changed, 179 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
index 97e9b6b..dc0e1f6 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
@@ -42,6 +42,7 @@
 #define   LIO_IFSTATE_DROQ_OPS             0x01
 #define   LIO_IFSTATE_REGISTERED           0x02
 #define   LIO_IFSTATE_RUNNING              0x04
+#define   LIO_IFSTATE_RX_TIMESTAMP_ENABLED 0x08
 
 struct liquidio_if_cfg_context {
 	int octeon_id;
@@ -65,6 +66,12 @@ struct liquidio_rx_ctl_context {
 	int cond;
 };
 
+struct oct_timestamp_resp {
+	u64 rh;
+	u64 timestamp;
+	u64 status;
+};
+
 union tx_info {
 	u64 u64;
 	struct {
@@ -1894,6 +1901,169 @@ static int liquidio_change_mtu(struct net_device *netdev, int new_mtu)
 	return 0;
 }
 
+/**
+ * \brief Handler for SIOCSHWTSTAMP ioctl
+ * @param netdev network device
+ * @param ifr interface request
+ * @param cmd command
+ */
+static int hwtstamp_ioctl(struct net_device *netdev, struct ifreq *ifr)
+{
+	struct lio *lio = GET_LIO(netdev);
+	struct hwtstamp_config conf;
+
+	if (copy_from_user(&conf, ifr->ifr_data, sizeof(conf)))
+		return -EFAULT;
+
+	if (conf.flags)
+		return -EINVAL;
+
+	switch (conf.tx_type) {
+	case HWTSTAMP_TX_ON:
+	case HWTSTAMP_TX_OFF:
+		break;
+	default:
+		return -ERANGE;
+	}
+
+	switch (conf.rx_filter) {
+	case HWTSTAMP_FILTER_NONE:
+		break;
+	case HWTSTAMP_FILTER_ALL:
+	case HWTSTAMP_FILTER_SOME:
+	case HWTSTAMP_FILTER_PTP_V1_L4_EVENT:
+	case HWTSTAMP_FILTER_PTP_V1_L4_SYNC:
+	case HWTSTAMP_FILTER_PTP_V1_L4_DELAY_REQ:
+	case HWTSTAMP_FILTER_PTP_V2_L4_EVENT:
+	case HWTSTAMP_FILTER_PTP_V2_L4_SYNC:
+	case HWTSTAMP_FILTER_PTP_V2_L4_DELAY_REQ:
+	case HWTSTAMP_FILTER_PTP_V2_L2_EVENT:
+	case HWTSTAMP_FILTER_PTP_V2_L2_SYNC:
+	case HWTSTAMP_FILTER_PTP_V2_L2_DELAY_REQ:
+	case HWTSTAMP_FILTER_PTP_V2_EVENT:
+	case HWTSTAMP_FILTER_PTP_V2_SYNC:
+	case HWTSTAMP_FILTER_PTP_V2_DELAY_REQ:
+		conf.rx_filter = HWTSTAMP_FILTER_ALL;
+		break;
+	default:
+		return -ERANGE;
+	}
+
+	if (conf.rx_filter == HWTSTAMP_FILTER_ALL)
+		ifstate_set(lio, LIO_IFSTATE_RX_TIMESTAMP_ENABLED);
+
+	else
+		ifstate_reset(lio, LIO_IFSTATE_RX_TIMESTAMP_ENABLED);
+
+	return copy_to_user(ifr->ifr_data, &conf, sizeof(conf)) ? -EFAULT : 0;
+}
+
+/**
+ * \brief ioctl handler
+ * @param netdev network device
+ * @param ifr interface request
+ * @param cmd command
+ */
+static int liquidio_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
+{
+	switch (cmd) {
+	case SIOCSHWTSTAMP:
+		return hwtstamp_ioctl(netdev, ifr);
+	default:
+		return -EOPNOTSUPP;
+	}
+}
+
+static void handle_timestamp(struct octeon_device *oct, u32 status, void *buf)
+{
+	struct sk_buff *skb = (struct sk_buff *)buf;
+	struct octnet_buf_free_info *finfo;
+	struct oct_timestamp_resp *resp;
+	struct octeon_soft_command *sc;
+	struct lio *lio;
+
+	finfo = (struct octnet_buf_free_info *)skb->cb;
+	lio = finfo->lio;
+	sc = finfo->sc;
+	oct = lio->oct_dev;
+	resp = (struct oct_timestamp_resp *)sc->virtrptr;
+
+	if (status != OCTEON_REQUEST_DONE) {
+		dev_err(&oct->pci_dev->dev, "Tx timestamp instruction failed. Status: %llx\n",
+			CVM_CAST64(status));
+		resp->timestamp = 0;
+	}
+
+	octeon_swap_8B_data(&resp->timestamp, 1);
+
+	if (unlikely(skb_shinfo(skb)->tx_flags & SKBTX_IN_PROGRESS)) {
+		struct skb_shared_hwtstamps ts;
+		u64 ns = resp->timestamp;
+
+		netif_info(lio, tx_done, lio->netdev,
+			   "Got resulting SKBTX_HW_TSTAMP skb=%p ns=%016llu\n",
+			   skb, (unsigned long long)ns);
+		ts.hwtstamp = ns_to_ktime(ns + lio->ptp_adjust);
+		skb_tstamp_tx(skb, &ts);
+	}
+
+	octeon_free_soft_command(oct, sc);
+	tx_buffer_free(skb);
+}
+
+/* \brief Send a data packet that will be timestamped
+ * @param oct octeon device
+ * @param ndata pointer to network data
+ * @param finfo pointer to private network data
+ */
+static int send_nic_timestamp_pkt(struct octeon_device *oct,
+				  struct octnic_data_pkt *ndata,
+				  struct octnet_buf_free_info *finfo)
+{
+	struct octeon_soft_command *sc;
+	int ring_doorbell;
+	struct lio *lio;
+	int retval;
+	u32 len;
+
+	lio = finfo->lio;
+
+	sc = octeon_alloc_soft_command_resp(oct, &ndata->cmd,
+					    sizeof(struct oct_timestamp_resp));
+	finfo->sc = sc;
+
+	if (!sc) {
+		dev_err(&oct->pci_dev->dev, "No memory for timestamped data packet\n");
+		return IQ_SEND_FAILED;
+	}
+
+	if (ndata->reqtype == REQTYPE_NORESP_NET)
+		ndata->reqtype = REQTYPE_RESP_NET;
+	else if (ndata->reqtype == REQTYPE_NORESP_NET_SG)
+		ndata->reqtype = REQTYPE_RESP_NET_SG;
+
+	sc->callback = handle_timestamp;
+	sc->callback_arg = finfo->skb;
+	sc->iq_no = ndata->q_no;
+
+	len = (u32)((struct octeon_instr_ih3 *)(&sc->cmd.cmd3.ih3))->dlengsz;
+
+	ring_doorbell = 1;
+
+	retval = octeon_send_command(oct, sc->iq_no, ring_doorbell, &sc->cmd,
+				     sc, len, ndata->reqtype);
+
+	if (retval == IQ_SEND_FAILED) {
+		dev_err(&oct->pci_dev->dev, "timestamp data packet failed status: %x\n",
+			retval);
+		octeon_free_soft_command(oct, sc);
+	} else {
+		netif_info(lio, tx_queued, lio->netdev, "Queued timestamp packet\n");
+	}
+
+	return retval;
+}
+
 /** \brief Transmit networks packets to the Octeon interface
  * @param skbuff   skbuff struct to be passed to network layer.
  * @param netdev   pointer to network device
@@ -1986,6 +2156,10 @@ static int liquidio_xmit(struct sk_buff *skb, struct net_device *netdev)
 			cmdsetup.s.transport_csum = 1;
 		}
 	}
+	if (unlikely(skb_shinfo(skb)->tx_flags & SKBTX_HW_TSTAMP)) {
+		skb_shinfo(skb)->tx_flags |= SKBTX_IN_PROGRESS;
+		cmdsetup.s.timestamp = 1;
+	}
 
 	if (!skb_shinfo(skb)->nr_frags) {
 		cmdsetup.s.u.datasize = skb->len;
@@ -2110,7 +2284,10 @@ static int liquidio_xmit(struct sk_buff *skb, struct net_device *netdev)
 		irh->vlan = skb_vlan_tag_get(skb) & VLAN_VID_MASK;
 	}
 
-	status = octnet_send_nic_data_pkt(oct, &ndata);
+	if (unlikely(cmdsetup.s.timestamp))
+		status = send_nic_timestamp_pkt(oct, &ndata, finfo);
+	else
+		status = octnet_send_nic_data_pkt(oct, &ndata);
 	if (status == IQ_SEND_FAILED)
 		goto lio_xmit_failed;
 
@@ -2382,6 +2559,7 @@ static void liquidio_del_vxlan_port(struct net_device *netdev,
 	.ndo_vlan_rx_add_vid    = liquidio_vlan_rx_add_vid,
 	.ndo_vlan_rx_kill_vid   = liquidio_vlan_rx_kill_vid,
 	.ndo_change_mtu		= liquidio_change_mtu,
+	.ndo_do_ioctl		= liquidio_ioctl,
 	.ndo_fix_features	= liquidio_fix_features,
 	.ndo_set_features	= liquidio_set_features,
 	.ndo_udp_tunnel_add     = liquidio_add_vxlan_port,
-- 
1.8.3.1
