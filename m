From: Johannes Berg <johannes@sipsolutions.net>
Subject: [RFC 1/3] networking: make skb_put & friends return void pointers
Date: Fri, 16 Jun 2017 00:12:15 +0200
Message-ID: <20170615221217.16510-2-johannes@sipsolutions.net>
References: <20170615221217.16510-1-johannes@sipsolutions.net>
Cc: Johannes Berg <johannes.berg@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:53852 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751883AbdFOWMW (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 15 Jun 2017 18:12:22 -0400
In-Reply-To: <20170615221217.16510-1-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes.berg@intel.com>

It seems like a historic accident that these return unsigned char *,
and in many places that means casts are required, more often than not.

Make these functions (skb_put, __skb_put and pskb_put) return void *
and remove all the casts across the tree, adding a (u8 *) cast only
where the unsigned char pointer was used directly, all done with the
following spatch:

    @@
    expression SKB, LEN;
    typedef u8;
    identifier fn = { skb_put, __skb_put };
    @@
    - *(fn(SKB, LEN))
    + *(u8 *)fn(SKB, LEN)

    @@
    expression E, SKB, LEN;
    identifier fn = { skb_put, __skb_put };
    type T;
    @@
    - E = ((T *)(fn(SKB, LEN)))
    + E = fn(SKB, LEN)

which actually doesn't cover pskb_put since there are only three
users overall.

A handful of stragglers were converted manually, notably a macro in
drivers/isdn/i4l/isdn_bsdcomp.c and, oddly enough, one of the many
instances in net/bluetooth/hci_sock.c. In the former file, I also
had to fix one whitespace problem spatch introduced.

Signed-off-by: Johannes Berg <johannes.berg@intel.com>
---
 drivers/atm/atmtcp.c                               |   4 +-
 drivers/atm/solos-pci.c                            |  12 +--
 drivers/bluetooth/bluecard_cs.c                    |   2 +-
 drivers/bluetooth/bt3c_cs.c                        |   2 +-
 drivers/bluetooth/btmrvl_main.c                    |   2 +-
 drivers/bluetooth/btuart_cs.c                      |   2 +-
 drivers/bluetooth/btusb.c                          |  10 +-
 drivers/bluetooth/dtl1_cs.c                        |   4 +-
 drivers/bluetooth/hci_bcm.c                        |   6 +-
 drivers/bluetooth/hci_intel.c                      |   6 +-
 drivers/bluetooth/hci_ll.c                         |   2 +-
 drivers/bluetooth/hci_nokia.c                      |  10 +-
 drivers/bluetooth/hci_qca.c                        |   2 +-
 drivers/bluetooth/hci_vhci.c                       |   4 +-
 drivers/crypto/chelsio/chcr_algo.c                 |  10 +-
 drivers/infiniband/core/addr.c                     |   3 +-
 drivers/infiniband/core/sa_query.c                 |   3 +-
 drivers/infiniband/hw/cxgb3/cxio_hal.c             |   2 +-
 drivers/infiniband/hw/cxgb3/iwch_cm.c              |  22 ++--
 drivers/infiniband/hw/cxgb4/cm.c                   |  22 ++--
 drivers/infiniband/hw/cxgb4/cq.c                   |   4 +-
 drivers/infiniband/hw/cxgb4/mem.c                  |   4 +-
 drivers/infiniband/hw/cxgb4/qp.c                   |   8 +-
 drivers/isdn/capi/capi.c                           |   4 +-
 drivers/isdn/gigaset/asyncdata.c                   |  26 ++---
 drivers/isdn/gigaset/isocdata.c                    |   2 +-
 drivers/isdn/i4l/isdn_audio.c                      |   4 +-
 drivers/isdn/i4l/isdn_bsdcomp.c                    |   8 +-
 drivers/isdn/i4l/isdn_x25iface.c                   |   4 +-
 drivers/media/dvb-core/dvb_net.c                   |   2 +-
 drivers/media/radio/wl128x/fmdrv_common.c          |   2 +-
 drivers/net/bonding/bond_3ad.c                     |   4 +-
 drivers/net/can/dev.c                              |   4 +-
 drivers/net/ethernet/allwinner/sun4i-emac.c        |   2 +-
 drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c    |  12 +--
 drivers/net/ethernet/chelsio/cxgb3/cxgb3_offload.c |   4 +-
 drivers/net/ethernet/chelsio/cxgb3/l2t.c           |   2 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_filter.c  |   4 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    |   8 +-
 drivers/net/ethernet/chelsio/cxgb4/l2t.c           |   2 +-
 drivers/net/ethernet/chelsio/libcxgb/libcxgb_cm.h  |  10 +-
 drivers/net/ethernet/davicom/dm9000.c              |   2 +-
 drivers/net/ethernet/dnet.c                        |   2 +-
 drivers/net/ethernet/hp/hp100.c                    |   2 +-
 drivers/net/ethernet/intel/i40e/i40e_fcoe.c        |   2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c      |   2 +-
 drivers/net/ethernet/mellanox/mlx4/en_selftest.c   |   4 +-
 .../net/ethernet/mellanox/mlx5/core/en_selftest.c  |   6 +-
 drivers/net/ethernet/micrel/ks8842.c               |   4 +-
 drivers/net/ethernet/sfc/falcon/selftest.c         |   3 +-
 drivers/net/ethernet/sfc/selftest.c                |   3 +-
 drivers/net/hamradio/scc.c                         |   4 +-
 drivers/net/ppp/pppoe.c                            |   2 +-
 drivers/net/usb/cdc_ncm.c                          |   2 +-
 drivers/net/usb/net1080.c                          |   4 +-
 drivers/net/usb/zaurus.c                           |   8 +-
 drivers/net/wan/hdlc_ppp.c                         |   2 +-
 drivers/net/wireless/ath/ath6kl/debug.c            |   2 +-
 drivers/net/wireless/ath/ath6kl/htc_pipe.c         |   6 +-
 drivers/net/wireless/ath/ath9k/htc_hst.c           |   9 +-
 drivers/net/wireless/ath/wil6210/wmi.c             |   2 +-
 drivers/net/wireless/cisco/airo.c                  |   4 +-
 drivers/net/wireless/intel/ipw2x00/ipw2200.c       |   2 +-
 drivers/net/wireless/intel/ipw2x00/libipw_tx.c     |   3 +-
 drivers/net/wireless/intersil/hostap/hostap_ap.c   |   2 +-
 drivers/net/wireless/intersil/p54/fwio.c           |  43 ++++----
 drivers/net/wireless/mac80211_hwsim.c              |   8 +-
 drivers/net/wireless/marvell/mwifiex/11n_aggr.c    |   2 +-
 drivers/net/wireless/marvell/mwifiex/tdls.c        |  38 +++----
 .../net/wireless/quantenna/qtnfmac/qlink_util.h    |  11 +-
 drivers/net/wireless/ralink/rt2x00/rt2x00debug.c   |   2 +-
 .../net/wireless/realtek/rtlwifi/rtl8192se/fw.c    |   2 +-
 drivers/nfc/fdp/i2c.c                              |   2 +-
 drivers/nfc/microread/i2c.c                        |   4 +-
 drivers/nfc/microread/microread.c                  |   4 +-
 drivers/nfc/nfcmrvl/fw_dnld.c                      |   6 +-
 drivers/nfc/pn533/pn533.c                          |  32 +++---
 drivers/nfc/pn544/i2c.c                            |   6 +-
 drivers/nfc/port100.c                              |   4 +-
 drivers/nfc/st21nfca/i2c.c                         |   6 +-
 drivers/nfc/st95hf/core.c                          |   2 +-
 drivers/scsi/bnx2fc/bnx2fc_fcoe.c                  |   2 +-
 drivers/scsi/fcoe/fcoe.c                           |   2 +-
 drivers/scsi/qedf/qedf_main.c                      |   2 +-
 drivers/staging/rtl8192e/rtl819x_BAProc.c          |  10 +-
 drivers/staging/rtl8192e/rtllib_softmac.c          |  34 +++---
 .../staging/rtl8192u/ieee80211/ieee80211_softmac.c |  21 ++--
 .../staging/rtl8192u/ieee80211/rtl819x_BAProc.c    |   8 +-
 drivers/target/iscsi/cxgbit/cxgbit_cm.c            |   8 +-
 drivers/target/iscsi/cxgbit/cxgbit_ddp.c           |   2 +-
 drivers/usb/gadget/function/f_ncm.c                |   5 +-
 include/linux/skbuff.h                             |   8 +-
 lib/nlattr.c                                       |   2 +-
 net/802/garp.c                                     |   6 +-
 net/802/mrp.c                                      |  11 +-
 net/appletalk/ddp.c                                |   2 +-
 net/atm/clip.c                                     |   2 +-
 net/batman-adv/icmp_socket.c                       |   2 +-
 net/batman-adv/tp_meter.c                          |   6 +-
 net/bluetooth/hci_request.c                        |   2 +-
 net/bluetooth/hci_sock.c                           |  12 +--
 net/bluetooth/hidp/core.c                          |   2 +-
 net/bluetooth/l2cap_core.c                         |  14 +--
 net/bluetooth/mgmt_util.c                          |  10 +-
 net/bluetooth/rfcomm/core.c                        |   2 +-
 net/core/pktgen.c                                  |  32 +++---
 net/core/skbuff.c                                  |   6 +-
 net/decnet/dn_dev.c                                |   2 +-
 net/decnet/dn_nsp_out.c                            |  18 ++--
 net/ipv4/arp.c                                     |   2 +-
 net/ipv4/igmp.c                                    |   6 +-
 net/ipv4/ipmr.c                                    |   2 +-
 net/ipv4/netfilter/ipt_SYNPROXY.c                  |  10 +-
 net/ipv4/netfilter/nf_reject_ipv4.c                |   2 +-
 net/ipv6/mcast.c                                   |   4 +-
 net/ipv6/ndisc.c                                   |   8 +-
 net/ipv6/netfilter/ip6t_SYNPROXY.c                 |  10 +-
 net/ipv6/netfilter/nf_reject_ipv6.c                |   2 +-
 net/irda/irlap_frame.c                             |  17 ++-
 net/key/af_key.c                                   | 116 +++++++++------------
 net/mac80211/cfg.c                                 |   4 +-
 net/mac80211/ht.c                                  |   2 +-
 net/mac80211/mesh.c                                |   2 +-
 net/mac80211/mesh_ps.c                             |   2 +-
 net/mac80211/sta_info.c                            |   2 +-
 net/mac80211/tdls.c                                |  10 +-
 net/mac80211/tx.c                                  |   2 +-
 net/mac80211/wpa.c                                 |   6 +-
 net/netfilter/nfnetlink_log.c                      |   2 +-
 net/netfilter/nfnetlink_queue.c                    |   2 +-
 net/netlink/af_netlink.c                           |   2 +-
 net/nfc/digital_core.c                             |   4 +-
 net/nfc/digital_dep.c                              |   2 +-
 net/nfc/digital_technology.c                       |  18 ++--
 net/nfc/hci/core.c                                 |   2 +-
 net/nfc/hci/llc_shdlc.c                            |   4 +-
 net/nfc/nci/core.c                                 |   2 +-
 net/nfc/nci/hci.c                                  |   2 +-
 net/nfc/nci/spi.c                                  |   8 +-
 net/nfc/nci/uart.c                                 |   2 +-
 net/psample/psample.c                              |   2 +-
 net/qrtr/qrtr.c                                    |   2 +-
 net/sctp/sm_make_chunk.c                           |   2 +-
 net/sctp/ulpevent.c                                |  29 ++----
 net/vmw_vsock/virtio_transport_common.c            |   2 +-
 145 files changed, 486 insertions(+), 547 deletions(-)

diff --git a/drivers/atm/atmtcp.c b/drivers/atm/atmtcp.c
index 3ef6253e1cce..56fa16c85ebf 100644
--- a/drivers/atm/atmtcp.c
+++ b/drivers/atm/atmtcp.c
@@ -60,7 +60,7 @@ static int atmtcp_send_control(struct atm_vcc *vcc,int type,
 		return -EUNATCH;
 	}
 	atm_force_charge(out_vcc,skb->truesize);
-	new_msg = (struct atmtcp_control *) skb_put(skb,sizeof(*new_msg));
+	new_msg = skb_put(skb, sizeof(*new_msg));
 	*new_msg = *msg;
 	new_msg->hdr.length = ATMTCP_HDR_MAGIC;
 	new_msg->type = type;
@@ -217,7 +217,7 @@ static int atmtcp_v_send(struct atm_vcc *vcc,struct sk_buff *skb)
 		atomic_inc(&vcc->stats->tx_err);
 		return -ENOBUFS;
 	}
-	hdr = (void *) skb_put(new_skb,sizeof(struct atmtcp_hdr));
+	hdr = skb_put(new_skb, sizeof(struct atmtcp_hdr));
 	hdr->vpi = htons(vcc->vpi);
 	hdr->vci = htons(vcc->vci);
 	hdr->length = htonl(skb->len);
diff --git a/drivers/atm/solos-pci.c b/drivers/atm/solos-pci.c
index 3ff5846cd039..1e009783b5f3 100644
--- a/drivers/atm/solos-pci.c
+++ b/drivers/atm/solos-pci.c
@@ -205,7 +205,7 @@ static ssize_t solos_param_show(struct device *dev, struct device_attribute *att
 		return -ENOMEM;
 	}
 
-	header = (void *)skb_put(skb, sizeof(*header));
+	header = skb_put(skb, sizeof(*header));
 
 	buflen = snprintf((void *)&header[1], buflen - 1,
 			  "L%05d\n%s\n", current->pid, attr->attr.name);
@@ -261,7 +261,7 @@ static ssize_t solos_param_store(struct device *dev, struct device_attribute *at
 		return -ENOMEM;
 	}
 
-	header = (void *)skb_put(skb, sizeof(*header));
+	header = skb_put(skb, sizeof(*header));
 
 	buflen = snprintf((void *)&header[1], buflen - 1,
 			  "L%05d\n%s\n%s\n", current->pid, attr->attr.name, buf);
@@ -486,7 +486,7 @@ static int send_command(struct solos_card *card, int dev, const char *buf, size_
 		return 0;
 	}
 
-	header = (void *)skb_put(skb, sizeof(*header));
+	header = skb_put(skb, sizeof(*header));
 
 	header->size = cpu_to_le16(size);
 	header->vpi = cpu_to_le16(0);
@@ -945,7 +945,7 @@ static int popen(struct atm_vcc *vcc)
 			dev_warn(&card->dev->dev, "Failed to allocate sk_buff in popen()\n");
 		return -ENOMEM;
 	}
-	header = (void *)skb_put(skb, sizeof(*header));
+	header = skb_put(skb, sizeof(*header));
 
 	header->size = cpu_to_le16(0);
 	header->vpi = cpu_to_le16(vcc->vpi);
@@ -982,7 +982,7 @@ static void pclose(struct atm_vcc *vcc)
 		dev_warn(&card->dev->dev, "Failed to allocate sk_buff in pclose()\n");
 		return;
 	}
-	header = (void *)skb_put(skb, sizeof(*header));
+	header = skb_put(skb, sizeof(*header));
 
 	header->size = cpu_to_le16(0);
 	header->vpi = cpu_to_le16(vcc->vpi);
@@ -1398,7 +1398,7 @@ static int atm_init(struct solos_card *card, struct device *parent)
 			continue;
 		}
 
-		header = (void *)skb_put(skb, sizeof(*header));
+		header = skb_put(skb, sizeof(*header));
 
 		header->size = cpu_to_le16(0);
 		header->vpi = cpu_to_le16(0);
diff --git a/drivers/bluetooth/bluecard_cs.c b/drivers/bluetooth/bluecard_cs.c
index 1d30c116b2ee..39a05b0c8998 100644
--- a/drivers/bluetooth/bluecard_cs.c
+++ b/drivers/bluetooth/bluecard_cs.c
@@ -448,7 +448,7 @@ static void bluecard_receive(struct bluecard_info *info,
 
 		} else {
 
-			*skb_put(info->rx_skb, 1) = buf[i];
+			*(u8 *)skb_put(info->rx_skb, 1) = buf[i];
 			info->rx_count--;
 
 			if (info->rx_count == 0) {
diff --git a/drivers/bluetooth/bt3c_cs.c b/drivers/bluetooth/bt3c_cs.c
index 8165ef2fe877..be2d431aa366 100644
--- a/drivers/bluetooth/bt3c_cs.c
+++ b/drivers/bluetooth/bt3c_cs.c
@@ -282,7 +282,7 @@ static void bt3c_receive(struct bt3c_info *info)
 
 			__u8 x = inb(iobase + DATA_L);
 
-			*skb_put(info->rx_skb, 1) = x;
+			*(u8 *)skb_put(info->rx_skb, 1) = x;
 			inb(iobase + DATA_H);
 			info->rx_count--;
 
diff --git a/drivers/bluetooth/btmrvl_main.c b/drivers/bluetooth/btmrvl_main.c
index 24a188eab360..8d3d9175d891 100644
--- a/drivers/bluetooth/btmrvl_main.c
+++ b/drivers/bluetooth/btmrvl_main.c
@@ -189,7 +189,7 @@ static int btmrvl_send_sync_cmd(struct btmrvl_private *priv, u16 opcode,
 		return -ENOMEM;
 	}
 
-	hdr = (struct hci_command_hdr *)skb_put(skb, HCI_COMMAND_HDR_SIZE);
+	hdr = skb_put(skb, HCI_COMMAND_HDR_SIZE);
 	hdr->opcode = cpu_to_le16(opcode);
 	hdr->plen = len;
 
diff --git a/drivers/bluetooth/btuart_cs.c b/drivers/bluetooth/btuart_cs.c
index 9624b29f8349..80b64e9684a3 100644
--- a/drivers/bluetooth/btuart_cs.c
+++ b/drivers/bluetooth/btuart_cs.c
@@ -233,7 +233,7 @@ static void btuart_receive(struct btuart_info *info)
 
 		} else {
 
-			*skb_put(info->rx_skb, 1) = inb(iobase + UART_RX);
+			*(u8 *)skb_put(info->rx_skb, 1) = inb(iobase + UART_RX);
 			info->rx_count--;
 
 			if (info->rx_count == 0) {
diff --git a/drivers/bluetooth/btusb.c b/drivers/bluetooth/btusb.c
index c7ea398e65c1..ba207c787605 100644
--- a/drivers/bluetooth/btusb.c
+++ b/drivers/bluetooth/btusb.c
@@ -1836,15 +1836,15 @@ static int inject_cmd_complete(struct hci_dev *hdev, __u16 opcode)
 	if (!skb)
 		return -ENOMEM;
 
-	hdr = (struct hci_event_hdr *)skb_put(skb, sizeof(*hdr));
+	hdr = skb_put(skb, sizeof(*hdr));
 	hdr->evt = HCI_EV_CMD_COMPLETE;
 	hdr->plen = sizeof(*evt) + 1;
 
-	evt = (struct hci_ev_cmd_complete *)skb_put(skb, sizeof(*evt));
+	evt = skb_put(skb, sizeof(*evt));
 	evt->ncmd = 0x01;
 	evt->opcode = cpu_to_le16(opcode);
 
-	*skb_put(skb, 1) = 0x00;
+	*(u8 *)skb_put(skb, 1) = 0x00;
 
 	hci_skb_pkt_type(skb) = HCI_EVENT_PKT;
 
@@ -2767,8 +2767,8 @@ static struct urb *alloc_diag_urb(struct hci_dev *hdev, bool enable)
 		return ERR_PTR(-ENOMEM);
 	}
 
-	*skb_put(skb, 1) = 0xf0;
-	*skb_put(skb, 1) = enable;
+	*(u8 *)skb_put(skb, 1) = 0xf0;
+	*(u8 *)skb_put(skb, 1) = enable;
 
 	pipe = usb_sndbulkpipe(data->udev, data->diag_tx_ep->bEndpointAddress);
 
diff --git a/drivers/bluetooth/dtl1_cs.c b/drivers/bluetooth/dtl1_cs.c
index 6317c6f323bf..6c5a3aa566a4 100644
--- a/drivers/bluetooth/dtl1_cs.c
+++ b/drivers/bluetooth/dtl1_cs.c
@@ -226,7 +226,7 @@ static void dtl1_receive(struct dtl1_info *info)
 			}
 		}
 
-		*skb_put(info->rx_skb, 1) = inb(iobase + UART_RX);
+		*(u8 *)skb_put(info->rx_skb, 1) = inb(iobase + UART_RX);
 		nsh = (struct nsh *)info->rx_skb->data;
 
 		info->rx_count--;
@@ -414,7 +414,7 @@ static int dtl1_hci_send_frame(struct hci_dev *hdev, struct sk_buff *skb)
 	skb_reserve(s, NSHL);
 	skb_copy_from_linear_data(skb, skb_put(s, skb->len), skb->len);
 	if (skb->len & 0x0001)
-		*skb_put(s, 1) = 0;	/* PAD */
+		*(u8 *)skb_put(s, 1) = 0;	/* PAD */
 
 	/* Prepend skb with Nokia frame header and queue */
 	memcpy(skb_push(s, NSHL), &nsh, NSHL);
diff --git a/drivers/bluetooth/hci_bcm.c b/drivers/bluetooth/hci_bcm.c
index e2096c7803b3..c1c4048ee37d 100644
--- a/drivers/bluetooth/hci_bcm.c
+++ b/drivers/bluetooth/hci_bcm.c
@@ -262,9 +262,9 @@ static int bcm_set_diag(struct hci_dev *hdev, bool enable)
 	if (!skb)
 		return -ENOMEM;
 
-	*skb_put(skb, 1) = BCM_LM_DIAG_PKT;
-	*skb_put(skb, 1) = 0xf0;
-	*skb_put(skb, 1) = enable;
+	*(u8 *)skb_put(skb, 1) = BCM_LM_DIAG_PKT;
+	*(u8 *)skb_put(skb, 1) = 0xf0;
+	*(u8 *)skb_put(skb, 1) = enable;
 
 	skb_queue_tail(&bcm->txq, skb);
 	hci_uart_tx_wakeup(hu);
diff --git a/drivers/bluetooth/hci_intel.c b/drivers/bluetooth/hci_intel.c
index 16e728577cd8..ee97c465e32e 100644
--- a/drivers/bluetooth/hci_intel.c
+++ b/drivers/bluetooth/hci_intel.c
@@ -462,15 +462,15 @@ static int inject_cmd_complete(struct hci_dev *hdev, __u16 opcode)
 	if (!skb)
 		return -ENOMEM;
 
-	hdr = (struct hci_event_hdr *)skb_put(skb, sizeof(*hdr));
+	hdr = skb_put(skb, sizeof(*hdr));
 	hdr->evt = HCI_EV_CMD_COMPLETE;
 	hdr->plen = sizeof(*evt) + 1;
 
-	evt = (struct hci_ev_cmd_complete *)skb_put(skb, sizeof(*evt));
+	evt = skb_put(skb, sizeof(*evt));
 	evt->ncmd = 0x01;
 	evt->opcode = cpu_to_le16(opcode);
 
-	*skb_put(skb, 1) = 0x00;
+	*(u8 *)skb_put(skb, 1) = 0x00;
 
 	hci_skb_pkt_type(skb) = HCI_EVENT_PKT;
 
diff --git a/drivers/bluetooth/hci_ll.c b/drivers/bluetooth/hci_ll.c
index cc2fa78b434e..c982943f0747 100644
--- a/drivers/bluetooth/hci_ll.c
+++ b/drivers/bluetooth/hci_ll.c
@@ -120,7 +120,7 @@ static int send_hcill_cmd(u8 cmd, struct hci_uart *hu)
 	}
 
 	/* prepare packet */
-	hcill_packet = (struct hcill_cmd *) skb_put(skb, 1);
+	hcill_packet = skb_put(skb, 1);
 	hcill_packet->cmd = cmd;
 
 	/* send packet */
diff --git a/drivers/bluetooth/hci_nokia.c b/drivers/bluetooth/hci_nokia.c
index a7d687d8d456..c1b081725b2c 100644
--- a/drivers/bluetooth/hci_nokia.c
+++ b/drivers/bluetooth/hci_nokia.c
@@ -246,9 +246,9 @@ static int nokia_send_alive_packet(struct hci_uart *hu)
 	hci_skb_pkt_type(skb) = HCI_NOKIA_ALIVE_PKT;
 	memset(skb->data, 0x00, len);
 
-	hdr = (struct hci_nokia_alive_hdr *)skb_put(skb, sizeof(*hdr));
+	hdr = skb_put(skb, sizeof(*hdr));
 	hdr->dlen = sizeof(*pkt);
-	pkt = (struct hci_nokia_alive_pkt *)skb_put(skb, sizeof(*pkt));
+	pkt = skb_put(skb, sizeof(*pkt));
 	pkt->mid = NOKIA_ALIVE_REQ;
 
 	nokia_enqueue(hu, skb);
@@ -285,10 +285,10 @@ static int nokia_send_negotiation(struct hci_uart *hu)
 
 	hci_skb_pkt_type(skb) = HCI_NOKIA_NEG_PKT;
 
-	neg_hdr = (struct hci_nokia_neg_hdr *)skb_put(skb, sizeof(*neg_hdr));
+	neg_hdr = skb_put(skb, sizeof(*neg_hdr));
 	neg_hdr->dlen = sizeof(*neg_cmd);
 
-	neg_cmd = (struct hci_nokia_neg_cmd *)skb_put(skb, sizeof(*neg_cmd));
+	neg_cmd = skb_put(skb, sizeof(*neg_cmd));
 	neg_cmd->ack = NOKIA_NEG_REQ;
 	neg_cmd->baud = cpu_to_le16(baud);
 	neg_cmd->unused1 = 0x0000;
@@ -532,7 +532,7 @@ static int nokia_enqueue(struct hci_uart *hu, struct sk_buff *skb)
 		err = skb_pad(skb, 1);
 		if (err)
 			return err;
-		*skb_put(skb, 1) = 0x00;
+		*(u8 *)skb_put(skb, 1) = 0x00;
 	}
 
 	skb_queue_tail(&btdev->txq, skb);
diff --git a/drivers/bluetooth/hci_qca.c b/drivers/bluetooth/hci_qca.c
index b55f01320631..e2c88515340a 100644
--- a/drivers/bluetooth/hci_qca.c
+++ b/drivers/bluetooth/hci_qca.c
@@ -215,7 +215,7 @@ static int send_hci_ibs_cmd(u8 cmd, struct hci_uart *hu)
 	}
 
 	/* Assign HCI_IBS type */
-	*skb_put(skb, 1) = cmd;
+	*(u8 *)skb_put(skb, 1) = cmd;
 
 	skb_queue_tail(&qca->txq, skb);
 
diff --git a/drivers/bluetooth/hci_vhci.c b/drivers/bluetooth/hci_vhci.c
index 233e850fdac7..1ef9c427a2d8 100644
--- a/drivers/bluetooth/hci_vhci.c
+++ b/drivers/bluetooth/hci_vhci.c
@@ -146,8 +146,8 @@ static int __vhci_create_device(struct vhci_data *data, __u8 opcode)
 
 	hci_skb_pkt_type(skb) = HCI_VENDOR_PKT;
 
-	*skb_put(skb, 1) = 0xff;
-	*skb_put(skb, 1) = opcode;
+	*(u8 *)skb_put(skb, 1) = 0xff;
+	*(u8 *)skb_put(skb, 1) = opcode;
 	put_unaligned_le16(hdev->id, skb_put(skb, 2));
 	skb_queue_tail(&data->readq, skb);
 
diff --git a/drivers/crypto/chelsio/chcr_algo.c b/drivers/crypto/chelsio/chcr_algo.c
index f00e0d8bd039..92185ab6797d 100644
--- a/drivers/crypto/chelsio/chcr_algo.c
+++ b/drivers/crypto/chelsio/chcr_algo.c
@@ -604,7 +604,7 @@ static struct sk_buff
 	if (!skb)
 		return ERR_PTR(-ENOMEM);
 	skb_reserve(skb, sizeof(struct sge_opaque_hdr));
-	chcr_req = (struct chcr_wr *)__skb_put(skb, transhdr_len);
+	chcr_req = __skb_put(skb, transhdr_len);
 	memset(chcr_req, 0, transhdr_len);
 	chcr_req->sec_cpl.op_ivinsrtofst =
 		FILL_SEC_CPL_OP_IVINSR(ctx->dev->rx_channel_id, 2, 1);
@@ -881,7 +881,7 @@ static struct sk_buff *create_hash_wr(struct ahash_request *req,
 		return skb;
 
 	skb_reserve(skb, sizeof(struct sge_opaque_hdr));
-	chcr_req = (struct chcr_wr *)__skb_put(skb, transhdr_len);
+	chcr_req = __skb_put(skb, transhdr_len);
 	memset(chcr_req, 0, transhdr_len);
 
 	chcr_req->sec_cpl.op_ivinsrtofst =
@@ -1447,7 +1447,7 @@ static struct sk_buff *create_authenc_wr(struct aead_request *req,
 	skb_reserve(skb, sizeof(struct sge_opaque_hdr));
 
 	/* Write WR */
-	chcr_req = (struct chcr_wr *) __skb_put(skb, transhdr_len);
+	chcr_req = __skb_put(skb, transhdr_len);
 	memset(chcr_req, 0, transhdr_len);
 
 	stop_offset = (op_type == CHCR_ENCRYPT_OP) ? 0 : authsize;
@@ -1779,7 +1779,7 @@ static struct sk_buff *create_aead_ccm_wr(struct aead_request *req,
 
 	skb_reserve(skb, sizeof(struct sge_opaque_hdr));
 
-	chcr_req = (struct chcr_wr *) __skb_put(skb, transhdr_len);
+	chcr_req = __skb_put(skb, transhdr_len);
 	memset(chcr_req, 0, transhdr_len);
 
 	fill_sec_cpl_for_aead(&chcr_req->sec_cpl, dst_size, req, op_type, ctx);
@@ -1892,7 +1892,7 @@ static struct sk_buff *create_gcm_wr(struct aead_request *req,
 	/* NIC driver is going to write the sge hdr. */
 	skb_reserve(skb, sizeof(struct sge_opaque_hdr));
 
-	chcr_req = (struct chcr_wr *)__skb_put(skb, transhdr_len);
+	chcr_req = __skb_put(skb, transhdr_len);
 	memset(chcr_req, 0, transhdr_len);
 
 	if (get_aead_subtype(tfm) == CRYPTO_ALG_SUB_TYPE_AEAD_RFC4106)
diff --git a/drivers/infiniband/core/addr.c b/drivers/infiniband/core/addr.c
index 02971e239a18..d2957b38575f 100644
--- a/drivers/infiniband/core/addr.c
+++ b/drivers/infiniband/core/addr.c
@@ -179,8 +179,7 @@ static int ib_nl_ip_send_msg(struct rdma_dev_addr *dev_addr,
 	}
 
 	/* Construct the family header first */
-	header = (struct rdma_ls_ip_resolve_header *)
-		skb_put(skb, NLMSG_ALIGN(sizeof(*header)));
+	header = skb_put(skb, NLMSG_ALIGN(sizeof(*header)));
 	header->ifindex = dev_addr->bound_dev_if;
 	nla_put(skb, attrtype, size, daddr);
 
diff --git a/drivers/infiniband/core/sa_query.c b/drivers/infiniband/core/sa_query.c
index fb7aec4047c8..70fa4cabe48e 100644
--- a/drivers/infiniband/core/sa_query.c
+++ b/drivers/infiniband/core/sa_query.c
@@ -759,8 +759,7 @@ static void ib_nl_set_path_rec_attrs(struct sk_buff *skb,
 	query->mad_buf->context[1] = NULL;
 
 	/* Construct the family header first */
-	header = (struct rdma_ls_resolve_header *)
-		skb_put(skb, NLMSG_ALIGN(sizeof(*header)));
+	header = skb_put(skb, NLMSG_ALIGN(sizeof(*header)));
 	memcpy(header->device_name, query->port->agent->device->name,
 	       LS_DEVICE_NAME_MAX);
 	header->port_num = query->port->port_num;
diff --git a/drivers/infiniband/hw/cxgb3/cxio_hal.c b/drivers/infiniband/hw/cxgb3/cxio_hal.c
index 97f7f9544e70..3eff6541bd6f 100644
--- a/drivers/infiniband/hw/cxgb3/cxio_hal.c
+++ b/drivers/infiniband/hw/cxgb3/cxio_hal.c
@@ -835,7 +835,7 @@ int cxio_rdma_init(struct cxio_rdev *rdev_p, struct t3_rdma_init_attr *attr)
 	if (!skb)
 		return -ENOMEM;
 	pr_debug("%s rdev_p %p\n", __func__, rdev_p);
-	wqe = (struct t3_rdma_init_wr *) __skb_put(skb, sizeof(*wqe));
+	wqe = __skb_put(skb, sizeof(*wqe));
 	wqe->wrh.op_seop_flags = cpu_to_be32(V_FW_RIWR_OP(T3_WR_INIT));
 	wqe->wrh.gen_tid_len = cpu_to_be32(V_FW_RIWR_TID(attr->tid) |
 					   V_FW_RIWR_LEN(sizeof(*wqe) >> 3));
diff --git a/drivers/infiniband/hw/cxgb3/iwch_cm.c b/drivers/infiniband/hw/cxgb3/iwch_cm.c
index f4c23a74f18c..9ae518c01bc2 100644
--- a/drivers/infiniband/hw/cxgb3/iwch_cm.c
+++ b/drivers/infiniband/hw/cxgb3/iwch_cm.c
@@ -175,7 +175,7 @@ static void release_tid(struct t3cdev *tdev, u32 hwtid, struct sk_buff *skb)
 	skb = get_skb(skb, sizeof *req, GFP_KERNEL);
 	if (!skb)
 		return;
-	req = (struct cpl_tid_release *) skb_put(skb, sizeof(*req));
+	req = skb_put(skb, sizeof(*req));
 	req->wr.wr_hi = htonl(V_WR_OP(FW_WROPCODE_FORWARD));
 	OPCODE_TID(req) = htonl(MK_OPCODE_TID(CPL_TID_RELEASE, hwtid));
 	skb->priority = CPL_PRIORITY_SETUP;
@@ -190,7 +190,7 @@ int iwch_quiesce_tid(struct iwch_ep *ep)
 
 	if (!skb)
 		return -ENOMEM;
-	req = (struct cpl_set_tcb_field *) skb_put(skb, sizeof(*req));
+	req = skb_put(skb, sizeof(*req));
 	req->wr.wr_hi = htonl(V_WR_OP(FW_WROPCODE_FORWARD));
 	req->wr.wr_lo = htonl(V_WR_TID(ep->hwtid));
 	OPCODE_TID(req) = htonl(MK_OPCODE_TID(CPL_SET_TCB_FIELD, ep->hwtid));
@@ -211,7 +211,7 @@ int iwch_resume_tid(struct iwch_ep *ep)
 
 	if (!skb)
 		return -ENOMEM;
-	req = (struct cpl_set_tcb_field *) skb_put(skb, sizeof(*req));
+	req = skb_put(skb, sizeof(*req));
 	req->wr.wr_hi = htonl(V_WR_OP(FW_WROPCODE_FORWARD));
 	req->wr.wr_lo = htonl(V_WR_TID(ep->hwtid));
 	OPCODE_TID(req) = htonl(MK_OPCODE_TID(CPL_SET_TCB_FIELD, ep->hwtid));
@@ -398,7 +398,7 @@ static int send_halfclose(struct iwch_ep *ep, gfp_t gfp)
 	}
 	skb->priority = CPL_PRIORITY_DATA;
 	set_arp_failure_handler(skb, arp_failure_discard);
-	req = (struct cpl_close_con_req *) skb_put(skb, sizeof(*req));
+	req = skb_put(skb, sizeof(*req));
 	req->wr.wr_hi = htonl(V_WR_OP(FW_WROPCODE_OFLD_CLOSE_CON));
 	req->wr.wr_lo = htonl(V_WR_TID(ep->hwtid));
 	OPCODE_TID(req) = htonl(MK_OPCODE_TID(CPL_CLOSE_CON_REQ, ep->hwtid));
@@ -455,7 +455,7 @@ static int send_connect(struct iwch_ep *ep)
 	skb->priority = CPL_PRIORITY_SETUP;
 	set_arp_failure_handler(skb, act_open_req_arp_failure);
 
-	req = (struct cpl_act_open_req *) skb_put(skb, sizeof(*req));
+	req = skb_put(skb, sizeof(*req));
 	req->wr.wr_hi = htonl(V_WR_OP(FW_WROPCODE_FORWARD));
 	OPCODE_TID(req) = htonl(MK_OPCODE_TID(CPL_ACT_OPEN_REQ, ep->atid));
 	req->local_port = ep->com.local_addr.sin_port;
@@ -546,7 +546,7 @@ static int send_mpa_reject(struct iwch_ep *ep, const void *pdata, u8 plen)
 		return -ENOMEM;
 	}
 	skb_reserve(skb, sizeof(*req));
-	mpa = (struct mpa_message *) skb_put(skb, mpalen);
+	mpa = skb_put(skb, mpalen);
 	memset(mpa, 0, sizeof(*mpa));
 	memcpy(mpa->key, MPA_KEY_REP, sizeof(mpa->key));
 	mpa->flags = MPA_REJECT;
@@ -596,7 +596,7 @@ static int send_mpa_reply(struct iwch_ep *ep, const void *pdata, u8 plen)
 	}
 	skb->priority = CPL_PRIORITY_DATA;
 	skb_reserve(skb, sizeof(*req));
-	mpa = (struct mpa_message *) skb_put(skb, mpalen);
+	mpa = skb_put(skb, mpalen);
 	memset(mpa, 0, sizeof(*mpa));
 	memcpy(mpa->key, MPA_KEY_REP, sizeof(mpa->key));
 	mpa->flags = (ep->mpa_attr.crc_enabled ? MPA_CRC : 0) |
@@ -800,7 +800,7 @@ static int update_rx_credits(struct iwch_ep *ep, u32 credits)
 		return 0;
 	}
 
-	req = (struct cpl_rx_data_ack *) skb_put(skb, sizeof(*req));
+	req = skb_put(skb, sizeof(*req));
 	req->wr.wr_hi = htonl(V_WR_OP(FW_WROPCODE_FORWARD));
 	OPCODE_TID(req) = htonl(MK_OPCODE_TID(CPL_RX_DATA_ACK, ep->hwtid));
 	req->credit_dack = htonl(V_RX_CREDITS(credits) | V_RX_FORCE_ACK(1));
@@ -1205,7 +1205,7 @@ static int listen_start(struct iwch_listen_ep *ep)
 		return -ENOMEM;
 	}
 
-	req = (struct cpl_pass_open_req *) skb_put(skb, sizeof(*req));
+	req = skb_put(skb, sizeof(*req));
 	req->wr.wr_hi = htonl(V_WR_OP(FW_WROPCODE_FORWARD));
 	OPCODE_TID(req) = htonl(MK_OPCODE_TID(CPL_PASS_OPEN_REQ, ep->stid));
 	req->local_port = ep->com.local_addr.sin_port;
@@ -1246,7 +1246,7 @@ static int listen_stop(struct iwch_listen_ep *ep)
 		pr_err("%s - failed to alloc skb\n", __func__);
 		return -ENOMEM;
 	}
-	req = (struct cpl_close_listserv_req *) skb_put(skb, sizeof(*req));
+	req = skb_put(skb, sizeof(*req));
 	req->wr.wr_hi = htonl(V_WR_OP(FW_WROPCODE_FORWARD));
 	req->cpu_idx = 0;
 	OPCODE_TID(req) = htonl(MK_OPCODE_TID(CPL_CLOSE_LISTSRV_REQ, ep->stid));
@@ -1614,7 +1614,7 @@ static int peer_abort(struct t3cdev *tdev, struct sk_buff *skb, void *ctx)
 		goto out;
 	}
 	rpl_skb->priority = CPL_PRIORITY_DATA;
-	rpl = (struct cpl_abort_rpl *) skb_put(rpl_skb, sizeof(*rpl));
+	rpl = skb_put(rpl_skb, sizeof(*rpl));
 	rpl->wr.wr_hi = htonl(V_WR_OP(FW_WROPCODE_OFLD_HOST_ABORT_CON_RPL));
 	rpl->wr.wr_lo = htonl(V_WR_TID(ep->hwtid));
 	OPCODE_TID(rpl) = htonl(MK_OPCODE_TID(CPL_ABORT_RPL, ep->hwtid));
diff --git a/drivers/infiniband/hw/cxgb4/cm.c b/drivers/infiniband/hw/cxgb4/cm.c
index 7c32a7c7977d..36ae3023e703 100644
--- a/drivers/infiniband/hw/cxgb4/cm.c
+++ b/drivers/infiniband/hw/cxgb4/cm.c
@@ -597,7 +597,7 @@ static int send_flowc(struct c4iw_ep *ep)
 	else
 		nparams = 9;
 
-	flowc = (struct fw_flowc_wr *)__skb_put(skb, FLOWC_LEN);
+	flowc = __skb_put(skb, FLOWC_LEN);
 
 	flowc->op_to_nparams = cpu_to_be32(FW_WR_OP_V(FW_FLOWC_WR) |
 					   FW_FLOWC_WR_NPARAMS_V(nparams));
@@ -787,18 +787,16 @@ static int send_connect(struct c4iw_ep *ep)
 	if (ep->com.remote_addr.ss_family == AF_INET) {
 		switch (CHELSIO_CHIP_VERSION(adapter_type)) {
 		case CHELSIO_T4:
-			req = (struct cpl_act_open_req *)skb_put(skb, wrlen);
+			req = skb_put(skb, wrlen);
 			INIT_TP_WR(req, 0);
 			break;
 		case CHELSIO_T5:
-			t5req = (struct cpl_t5_act_open_req *)skb_put(skb,
-					wrlen);
+			t5req = skb_put(skb, wrlen);
 			INIT_TP_WR(t5req, 0);
 			req = (struct cpl_act_open_req *)t5req;
 			break;
 		case CHELSIO_T6:
-			t6req = (struct cpl_t6_act_open_req *)skb_put(skb,
-					wrlen);
+			t6req = skb_put(skb, wrlen);
 			INIT_TP_WR(t6req, 0);
 			req = (struct cpl_act_open_req *)t6req;
 			t5req = (struct cpl_t5_act_open_req *)t6req;
@@ -839,18 +837,16 @@ static int send_connect(struct c4iw_ep *ep)
 	} else {
 		switch (CHELSIO_CHIP_VERSION(adapter_type)) {
 		case CHELSIO_T4:
-			req6 = (struct cpl_act_open_req6 *)skb_put(skb, wrlen);
+			req6 = skb_put(skb, wrlen);
 			INIT_TP_WR(req6, 0);
 			break;
 		case CHELSIO_T5:
-			t5req6 = (struct cpl_t5_act_open_req6 *)skb_put(skb,
-					wrlen);
+			t5req6 = skb_put(skb, wrlen);
 			INIT_TP_WR(t5req6, 0);
 			req6 = (struct cpl_act_open_req6 *)t5req6;
 			break;
 		case CHELSIO_T6:
-			t6req6 = (struct cpl_t6_act_open_req6 *)skb_put(skb,
-					wrlen);
+			t6req6 = skb_put(skb, wrlen);
 			INIT_TP_WR(t6req6, 0);
 			req6 = (struct cpl_act_open_req6 *)t6req6;
 			t5req6 = (struct cpl_t5_act_open_req6 *)t6req6;
@@ -1904,7 +1900,7 @@ static int send_fw_act_open_req(struct c4iw_ep *ep, unsigned int atid)
 	int win;
 
 	skb = get_skb(NULL, sizeof(*req), GFP_KERNEL);
-	req = (struct fw_ofld_connection_wr *)__skb_put(skb, sizeof(*req));
+	req = __skb_put(skb, sizeof(*req));
 	memset(req, 0, sizeof(*req));
 	req->op_compl = htonl(WR_OP_V(FW_OFLD_CONNECTION_WR));
 	req->len16_pkd = htonl(FW_WR_LEN16_V(DIV_ROUND_UP(sizeof(*req), 16)));
@@ -3807,7 +3803,7 @@ static void send_fw_pass_open_req(struct c4iw_dev *dev, struct sk_buff *skb,
 	req_skb = alloc_skb(sizeof(struct fw_ofld_connection_wr), GFP_KERNEL);
 	if (!req_skb)
 		return;
-	req = (struct fw_ofld_connection_wr *)__skb_put(req_skb, sizeof(*req));
+	req = __skb_put(req_skb, sizeof(*req));
 	memset(req, 0, sizeof(*req));
 	req->op_compl = htonl(WR_OP_V(FW_OFLD_CONNECTION_WR) | FW_WR_COMPL_F);
 	req->len16_pkd = htonl(FW_WR_LEN16_V(DIV_ROUND_UP(sizeof(*req), 16)));
diff --git a/drivers/infiniband/hw/cxgb4/cq.c b/drivers/infiniband/hw/cxgb4/cq.c
index 14de5bde1b63..394cfe2625fe 100644
--- a/drivers/infiniband/hw/cxgb4/cq.c
+++ b/drivers/infiniband/hw/cxgb4/cq.c
@@ -44,7 +44,7 @@ static int destroy_cq(struct c4iw_rdev *rdev, struct t4_cq *cq,
 	wr_len = sizeof *res_wr + sizeof *res;
 	set_wr_txq(skb, CPL_PRIORITY_CONTROL, 0);
 
-	res_wr = (struct fw_ri_res_wr *)__skb_put(skb, wr_len);
+	res_wr = __skb_put(skb, wr_len);
 	memset(res_wr, 0, wr_len);
 	res_wr->op_nres = cpu_to_be32(
 			FW_WR_OP_V(FW_RI_RES_WR) |
@@ -114,7 +114,7 @@ static int create_cq(struct c4iw_rdev *rdev, struct t4_cq *cq,
 	}
 	set_wr_txq(skb, CPL_PRIORITY_CONTROL, 0);
 
-	res_wr = (struct fw_ri_res_wr *)__skb_put(skb, wr_len);
+	res_wr = __skb_put(skb, wr_len);
 	memset(res_wr, 0, wr_len);
 	res_wr->op_nres = cpu_to_be32(
 			FW_WR_OP_V(FW_RI_RES_WR) |
diff --git a/drivers/infiniband/hw/cxgb4/mem.c b/drivers/infiniband/hw/cxgb4/mem.c
index 3ee7f43e419a..ca992e4b66e4 100644
--- a/drivers/infiniband/hw/cxgb4/mem.c
+++ b/drivers/infiniband/hw/cxgb4/mem.c
@@ -81,7 +81,7 @@ static int _c4iw_write_mem_dma_aligned(struct c4iw_rdev *rdev, u32 addr,
 	}
 	set_wr_txq(skb, CPL_PRIORITY_CONTROL, 0);
 
-	req = (struct ulp_mem_io *)__skb_put(skb, wr_len);
+	req = __skb_put(skb, wr_len);
 	memset(req, 0, wr_len);
 	INIT_ULPTX_WR(req, wr_len, 0, 0);
 	req->wr.wr_hi = cpu_to_be32(FW_WR_OP_V(FW_ULPTX_WR) |
@@ -142,7 +142,7 @@ static int _c4iw_write_mem_inline(struct c4iw_rdev *rdev, u32 addr, u32 len,
 		}
 		set_wr_txq(skb, CPL_PRIORITY_CONTROL, 0);
 
-		req = (struct ulp_mem_io *)__skb_put(skb, wr_len);
+		req = __skb_put(skb, wr_len);
 		memset(req, 0, wr_len);
 		INIT_ULPTX_WR(req, wr_len, 0, 0);
 
diff --git a/drivers/infiniband/hw/cxgb4/qp.c b/drivers/infiniband/hw/cxgb4/qp.c
index 8e4154b4253e..b23a0b057347 100644
--- a/drivers/infiniband/hw/cxgb4/qp.c
+++ b/drivers/infiniband/hw/cxgb4/qp.c
@@ -293,7 +293,7 @@ static int create_qp(struct c4iw_rdev *rdev, struct t4_wq *wq,
 	}
 	set_wr_txq(skb, CPL_PRIORITY_CONTROL, 0);
 
-	res_wr = (struct fw_ri_res_wr *)__skb_put(skb, wr_len);
+	res_wr = __skb_put(skb, wr_len);
 	memset(res_wr, 0, wr_len);
 	res_wr->op_nres = cpu_to_be32(
 			FW_WR_OP_V(FW_RI_RES_WR) |
@@ -1228,7 +1228,7 @@ static void post_terminate(struct c4iw_qp *qhp, struct t4_cqe *err_cqe,
 
 	set_wr_txq(skb, CPL_PRIORITY_DATA, qhp->ep->txq_idx);
 
-	wqe = (struct fw_ri_wr *)__skb_put(skb, sizeof(*wqe));
+	wqe = __skb_put(skb, sizeof(*wqe));
 	memset(wqe, 0, sizeof *wqe);
 	wqe->op_compl = cpu_to_be32(FW_WR_OP_V(FW_RI_INIT_WR));
 	wqe->flowid_len16 = cpu_to_be32(
@@ -1350,7 +1350,7 @@ static int rdma_fini(struct c4iw_dev *rhp, struct c4iw_qp *qhp,
 
 	set_wr_txq(skb, CPL_PRIORITY_DATA, ep->txq_idx);
 
-	wqe = (struct fw_ri_wr *)__skb_put(skb, sizeof(*wqe));
+	wqe = __skb_put(skb, sizeof(*wqe));
 	memset(wqe, 0, sizeof *wqe);
 	wqe->op_compl = cpu_to_be32(
 		FW_WR_OP_V(FW_RI_INIT_WR) |
@@ -1419,7 +1419,7 @@ static int rdma_init(struct c4iw_dev *rhp, struct c4iw_qp *qhp)
 	}
 	set_wr_txq(skb, CPL_PRIORITY_DATA, qhp->ep->txq_idx);
 
-	wqe = (struct fw_ri_wr *)__skb_put(skb, sizeof(*wqe));
+	wqe = __skb_put(skb, sizeof(*wqe));
 	memset(wqe, 0, sizeof *wqe);
 	wqe->op_compl = cpu_to_be32(
 		FW_WR_OP_V(FW_RI_INIT_WR) |
diff --git a/drivers/isdn/capi/capi.c b/drivers/isdn/capi/capi.c
index 77be17590866..96f586d34d2d 100644
--- a/drivers/isdn/capi/capi.c
+++ b/drivers/isdn/capi/capi.c
@@ -1082,7 +1082,7 @@ static int capinc_tty_put_char(struct tty_struct *tty, unsigned char ch)
 	skb = mp->outskb;
 	if (skb) {
 		if (skb_tailroom(skb) > 0) {
-			*(skb_put(skb, 1)) = ch;
+			*(u8 *)skb_put(skb, 1) = ch;
 			goto unlock_out;
 		}
 		mp->outskb = NULL;
@@ -1094,7 +1094,7 @@ static int capinc_tty_put_char(struct tty_struct *tty, unsigned char ch)
 	skb = alloc_skb(CAPI_DATA_B3_REQ_LEN + CAPI_MAX_BLKSIZE, GFP_ATOMIC);
 	if (skb) {
 		skb_reserve(skb, CAPI_DATA_B3_REQ_LEN);
-		*(skb_put(skb, 1)) = ch;
+		*(u8 *)skb_put(skb, 1) = ch;
 		mp->outskb = skb;
 	} else {
 		printk(KERN_ERR "capinc_put_char: char %u lost\n", ch);
diff --git a/drivers/isdn/gigaset/asyncdata.c b/drivers/isdn/gigaset/asyncdata.c
index c90dca5abeac..03ac9fbfe318 100644
--- a/drivers/isdn/gigaset/asyncdata.c
+++ b/drivers/isdn/gigaset/asyncdata.c
@@ -264,7 +264,7 @@ static unsigned hdlc_loop(unsigned numbytes, struct inbuf_t *inbuf)
 				/* skip remainder of packet */
 				bcs->rx_skb = skb = NULL;
 			} else {
-				*__skb_put(skb, 1) = c;
+				*(u8 *)__skb_put(skb, 1) = c;
 				fcs = crc_ccitt_byte(fcs, c);
 			}
 		}
@@ -315,7 +315,7 @@ static unsigned iraw_loop(unsigned numbytes, struct inbuf_t *inbuf)
 
 		/* regular data byte: append to current skb */
 		inputstate |= INS_have_data;
-		*__skb_put(skb, 1) = bitrev8(c);
+		*(u8 *)__skb_put(skb, 1) = bitrev8(c);
 	}
 
 	/* pass data up */
@@ -492,33 +492,33 @@ static struct sk_buff *HDLC_Encode(struct sk_buff *skb)
 	hdlc_skb->mac_len = skb->mac_len;
 
 	/* Add flag sequence in front of everything.. */
-	*(skb_put(hdlc_skb, 1)) = PPP_FLAG;
+	*(u8 *)skb_put(hdlc_skb, 1) = PPP_FLAG;
 
 	/* Perform byte stuffing while copying data. */
 	while (skb->len--) {
 		if (muststuff(*skb->data)) {
-			*(skb_put(hdlc_skb, 1)) = PPP_ESCAPE;
-			*(skb_put(hdlc_skb, 1)) = (*skb->data++) ^ PPP_TRANS;
+			*(u8 *)skb_put(hdlc_skb, 1) = PPP_ESCAPE;
+			*(u8 *)skb_put(hdlc_skb, 1) = (*skb->data++) ^ PPP_TRANS;
 		} else
-			*(skb_put(hdlc_skb, 1)) = *skb->data++;
+			*(u8 *)skb_put(hdlc_skb, 1) = *skb->data++;
 	}
 
 	/* Finally add FCS (byte stuffed) and flag sequence */
 	c = (fcs & 0x00ff);	/* least significant byte first */
 	if (muststuff(c)) {
-		*(skb_put(hdlc_skb, 1)) = PPP_ESCAPE;
+		*(u8 *)skb_put(hdlc_skb, 1) = PPP_ESCAPE;
 		c ^= PPP_TRANS;
 	}
-	*(skb_put(hdlc_skb, 1)) = c;
+	*(u8 *)skb_put(hdlc_skb, 1) = c;
 
 	c = ((fcs >> 8) & 0x00ff);
 	if (muststuff(c)) {
-		*(skb_put(hdlc_skb, 1)) = PPP_ESCAPE;
+		*(u8 *)skb_put(hdlc_skb, 1) = PPP_ESCAPE;
 		c ^= PPP_TRANS;
 	}
-	*(skb_put(hdlc_skb, 1)) = c;
+	*(u8 *)skb_put(hdlc_skb, 1) = c;
 
-	*(skb_put(hdlc_skb, 1)) = PPP_FLAG;
+	*(u8 *)skb_put(hdlc_skb, 1) = PPP_FLAG;
 
 	dev_kfree_skb_any(skb);
 	return hdlc_skb;
@@ -561,8 +561,8 @@ static struct sk_buff *iraw_encode(struct sk_buff *skb)
 	while (len--) {
 		c = bitrev8(*cp++);
 		if (c == DLE_FLAG)
-			*(skb_put(iraw_skb, 1)) = c;
-		*(skb_put(iraw_skb, 1)) = c;
+			*(u8 *)skb_put(iraw_skb, 1) = c;
+		*(u8 *)skb_put(iraw_skb, 1) = c;
 	}
 	dev_kfree_skb_any(skb);
 	return iraw_skb;
diff --git a/drivers/isdn/gigaset/isocdata.c b/drivers/isdn/gigaset/isocdata.c
index bc29f1d52a2f..74e250664ce9 100644
--- a/drivers/isdn/gigaset/isocdata.c
+++ b/drivers/isdn/gigaset/isocdata.c
@@ -511,7 +511,7 @@ static inline void hdlc_putbyte(unsigned char c, struct bc_state *bcs)
 		bcs->rx_skb = NULL;
 		return;
 	}
-	*__skb_put(bcs->rx_skb, 1) = c;
+	*(u8 *)__skb_put(bcs->rx_skb, 1) = c;
 }
 
 /* hdlc_flush
diff --git a/drivers/isdn/i4l/isdn_audio.c b/drivers/isdn/i4l/isdn_audio.c
index 78ce42214713..b6bcd1eca128 100644
--- a/drivers/isdn/i4l/isdn_audio.c
+++ b/drivers/isdn/i4l/isdn_audio.c
@@ -462,7 +462,7 @@ isdn_audio_goertzel(int *sample, modem_info *info)
 		       info->line);
 		return;
 	}
-	result = (int *) skb_put(skb, sizeof(int) * NCOEFF);
+	result = skb_put(skb, sizeof(int) * NCOEFF);
 	for (k = 0; k < NCOEFF; k++) {
 		sk = sk1 = sk2 = 0;
 		for (n = 0; n < DTMF_NPOINTS; n++) {
@@ -672,7 +672,7 @@ isdn_audio_put_dle_code(modem_info *info, u_char code)
 		       info->line);
 		return;
 	}
-	p = (char *) skb_put(skb, 2);
+	p = skb_put(skb, 2);
 	p[0] = 0x10;
 	p[1] = code;
 	ISDN_AUDIO_SKB_DLECOUNT(skb) = 0;
diff --git a/drivers/isdn/i4l/isdn_bsdcomp.c b/drivers/isdn/i4l/isdn_bsdcomp.c
index 8837ac5a492d..6ade0916da4e 100644
--- a/drivers/isdn/i4l/isdn_bsdcomp.c
+++ b/drivers/isdn/i4l/isdn_bsdcomp.c
@@ -472,7 +472,7 @@ static int bsd_compress(void *state, struct sk_buff *skb_in, struct sk_buff *skb
 		accm |= ((ent) << bitno);				\
 		do	{						\
 			if (skb_out && skb_tailroom(skb_out) > 0)	\
-				*(skb_put(skb_out, 1)) = (unsigned char)(accm >> 24); \
+				*(u8 *)skb_put(skb_out, 1) = (u8)(accm >> 24); \
 			accm <<= 8;					\
 			bitno += 8;					\
 		} while (bitno <= 24);					\
@@ -602,7 +602,7 @@ static int bsd_compress(void *state, struct sk_buff *skb_in, struct sk_buff *skb
 	 * Do not emit a completely useless byte of ones.
 	 */
 	if (bitno < 32 && skb_out && skb_tailroom(skb_out) > 0)
-		*(skb_put(skb_out, 1)) = (unsigned char)((accm | (0xff << (bitno - 8))) >> 24);
+		*(u8 *)skb_put(skb_out, 1) = (unsigned char)((accm | (0xff << (bitno - 8))) >> 24);
 
 	/*
 	 * Increase code size if we would have without the packet
@@ -698,7 +698,7 @@ static int bsd_decompress(void *state, struct sk_buff *skb_in, struct sk_buff *s
 	db->bytes_out += ilen;
 
 	if (skb_tailroom(skb_out) > 0)
-		*(skb_put(skb_out, 1)) = 0;
+		*(u8 *)skb_put(skb_out, 1) = 0;
 	else
 		return DECOMP_ERR_NOMEM;
 
@@ -816,7 +816,7 @@ static int bsd_decompress(void *state, struct sk_buff *skb_in, struct sk_buff *s
 #endif
 
 		if (extra)		/* the KwKwK case again */
-			*(skb_put(skb_out, 1)) = finchar;
+			*(u8 *)skb_put(skb_out, 1) = finchar;
 
 		/*
 		 * If not first code in a packet, and
diff --git a/drivers/isdn/i4l/isdn_x25iface.c b/drivers/isdn/i4l/isdn_x25iface.c
index ba60076e0b95..e33fa3073f74 100644
--- a/drivers/isdn/i4l/isdn_x25iface.c
+++ b/drivers/isdn/i4l/isdn_x25iface.c
@@ -224,7 +224,7 @@ static int isdn_x25iface_connect_ind(struct concap_proto *cprot)
 
 	skb = dev_alloc_skb(1);
 	if (skb) {
-		*(skb_put(skb, 1)) = X25_IFACE_CONNECT;
+		*(u8 *)skb_put(skb, 1) = X25_IFACE_CONNECT;
 		skb->protocol = x25_type_trans(skb, cprot->net_dev);
 		netif_rx(skb);
 		return 0;
@@ -253,7 +253,7 @@ static int isdn_x25iface_disconn_ind(struct concap_proto *cprot)
 	*state_p = WAN_DISCONNECTED;
 	skb = dev_alloc_skb(1);
 	if (skb) {
-		*(skb_put(skb, 1)) = X25_IFACE_DISCONNECT;
+		*(u8 *)skb_put(skb, 1) = X25_IFACE_DISCONNECT;
 		skb->protocol = x25_type_trans(skb, cprot->net_dev);
 		netif_rx(skb);
 		return 0;
diff --git a/drivers/media/dvb-core/dvb_net.c b/drivers/media/dvb-core/dvb_net.c
index bbaf0a8cae8b..06b0dcc13695 100644
--- a/drivers/media/dvb-core/dvb_net.c
+++ b/drivers/media/dvb-core/dvb_net.c
@@ -963,7 +963,7 @@ static void dvb_net_sec(struct net_device *dev,
 	skb->dev = dev;
 
 	/* copy L3 payload */
-	eth = (u8 *) skb_put(skb, pkt_len - 12 - 4 + 14 - snap);
+	eth = skb_put(skb, pkt_len - 12 - 4 + 14 - snap);
 	memcpy(eth + 14, pkt + 12 + snap, pkt_len - 12 - 4 - snap);
 
 	/* create ethernet header: */
diff --git a/drivers/media/radio/wl128x/fmdrv_common.c b/drivers/media/radio/wl128x/fmdrv_common.c
index c67e055a12c9..ab3428bf63fe 100644
--- a/drivers/media/radio/wl128x/fmdrv_common.c
+++ b/drivers/media/radio/wl128x/fmdrv_common.c
@@ -416,7 +416,7 @@ static int fm_send_cmd(struct fmdev *fmdev, u8 fm_op, u16 type,	void *payload,
 	if (!test_bit(FM_FW_DW_INPROGRESS, &fmdev->flag) ||
 			test_bit(FM_INTTASK_RUNNING, &fmdev->flag)) {
 		/* Fill command header info */
-		hdr = (struct fm_cmd_msg_hdr *)skb_put(skb, FM_CMD_MSG_HDR_SIZE);
+		hdr = skb_put(skb, FM_CMD_MSG_HDR_SIZE);
 		hdr->hdr = FM_PKT_LOGICAL_CHAN_NUMBER;	/* 0x08 */
 
 		/* 3 (fm_opcode,rd_wr,dlen) + payload len) */
diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index 5427032aa05e..f43fb2f958a5 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -857,7 +857,7 @@ static int ad_lacpdu_send(struct port *port)
 	skb->protocol = PKT_TYPE_LACPDU;
 	skb->priority = TC_PRIO_CONTROL;
 
-	lacpdu_header = (struct lacpdu_header *)skb_put(skb, length);
+	lacpdu_header = skb_put(skb, length);
 
 	ether_addr_copy(lacpdu_header->hdr.h_dest, lacpdu_mcast_addr);
 	/* Note: source address is set to be the member's PERMANENT address,
@@ -899,7 +899,7 @@ static int ad_marker_send(struct port *port, struct bond_marker *marker)
 	skb->network_header = skb->mac_header + ETH_HLEN;
 	skb->protocol = PKT_TYPE_LACPDU;
 
-	marker_header = (struct bond_marker_header *)skb_put(skb, length);
+	marker_header = skb_put(skb, length);
 
 	ether_addr_copy(marker_header->hdr.h_dest, lacpdu_mcast_addr);
 	/* Note: source address is set to be the member's PERMANENT address,
diff --git a/drivers/net/can/dev.c b/drivers/net/can/dev.c
index ae4ed03dc642..a3011c001080 100644
--- a/drivers/net/can/dev.c
+++ b/drivers/net/can/dev.c
@@ -648,7 +648,7 @@ struct sk_buff *alloc_can_skb(struct net_device *dev, struct can_frame **cf)
 	can_skb_prv(skb)->ifindex = dev->ifindex;
 	can_skb_prv(skb)->skbcnt = 0;
 
-	*cf = (struct can_frame *)skb_put(skb, sizeof(struct can_frame));
+	*cf = skb_put(skb, sizeof(struct can_frame));
 	memset(*cf, 0, sizeof(struct can_frame));
 
 	return skb;
@@ -677,7 +677,7 @@ struct sk_buff *alloc_canfd_skb(struct net_device *dev,
 	can_skb_prv(skb)->ifindex = dev->ifindex;
 	can_skb_prv(skb)->skbcnt = 0;
 
-	*cfd = (struct canfd_frame *)skb_put(skb, sizeof(struct canfd_frame));
+	*cfd = skb_put(skb, sizeof(struct canfd_frame));
 	memset(*cfd, 0, sizeof(struct canfd_frame));
 
 	return skb;
diff --git a/drivers/net/ethernet/allwinner/sun4i-emac.c b/drivers/net/ethernet/allwinner/sun4i-emac.c
index c8f4d26fc9d4..3143de45baaa 100644
--- a/drivers/net/ethernet/allwinner/sun4i-emac.c
+++ b/drivers/net/ethernet/allwinner/sun4i-emac.c
@@ -633,7 +633,7 @@ static void emac_rx(struct net_device *dev)
 			if (!skb)
 				continue;
 			skb_reserve(skb, 2);
-			rdptr = (u8 *) skb_put(skb, rxlen - 4);
+			rdptr = skb_put(skb, rxlen - 4);
 
 			/* Read received packet from RX SRAM */
 			if (netif_msg_rx_status(db))
diff --git a/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c b/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c
index 2ff6bd139c96..e1a50c87c9a9 100644
--- a/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c
@@ -471,7 +471,7 @@ static int init_tp_parity(struct adapter *adap)
 		if (!skb)
 			goto alloc_skb_fail;
 
-		req = (struct cpl_smt_write_req *)__skb_put(skb, sizeof(*req));
+		req = __skb_put(skb, sizeof(*req));
 		memset(req, 0, sizeof(*req));
 		req->wr.wr_hi = htonl(V_WR_OP(FW_WROPCODE_FORWARD));
 		OPCODE_TID(req) = htonl(MK_OPCODE_TID(CPL_SMT_WRITE_REQ, i));
@@ -495,7 +495,7 @@ static int init_tp_parity(struct adapter *adap)
 		if (!skb)
 			goto alloc_skb_fail;
 
-		req = (struct cpl_l2t_write_req *)__skb_put(skb, sizeof(*req));
+		req = __skb_put(skb, sizeof(*req));
 		memset(req, 0, sizeof(*req));
 		req->wr.wr_hi = htonl(V_WR_OP(FW_WROPCODE_FORWARD));
 		OPCODE_TID(req) = htonl(MK_OPCODE_TID(CPL_L2T_WRITE_REQ, i));
@@ -518,7 +518,7 @@ static int init_tp_parity(struct adapter *adap)
 		if (!skb)
 			goto alloc_skb_fail;
 
-		req = (struct cpl_rte_write_req *)__skb_put(skb, sizeof(*req));
+		req = __skb_put(skb, sizeof(*req));
 		memset(req, 0, sizeof(*req));
 		req->wr.wr_hi = htonl(V_WR_OP(FW_WROPCODE_FORWARD));
 		OPCODE_TID(req) = htonl(MK_OPCODE_TID(CPL_RTE_WRITE_REQ, i));
@@ -538,7 +538,7 @@ static int init_tp_parity(struct adapter *adap)
 	if (!skb)
 		goto alloc_skb_fail;
 
-	greq = (struct cpl_set_tcb_field *)__skb_put(skb, sizeof(*greq));
+	greq = __skb_put(skb, sizeof(*greq));
 	memset(greq, 0, sizeof(*greq));
 	greq->wr.wr_hi = htonl(V_WR_OP(FW_WROPCODE_FORWARD));
 	OPCODE_TID(greq) = htonl(MK_OPCODE_TID(CPL_SET_TCB_FIELD, 0));
@@ -909,7 +909,7 @@ static int write_smt_entry(struct adapter *adapter, int idx)
 	if (!skb)
 		return -ENOMEM;
 
-	req = (struct cpl_smt_write_req *)__skb_put(skb, sizeof(*req));
+	req = __skb_put(skb, sizeof(*req));
 	req->wr.wr_hi = htonl(V_WR_OP(FW_WROPCODE_FORWARD));
 	OPCODE_TID(req) = htonl(MK_OPCODE_TID(CPL_SMT_WRITE_REQ, idx));
 	req->mtu_idx = NMTUS - 1;	/* should be 0 but there's a T3 bug */
@@ -952,7 +952,7 @@ static int send_pktsched_cmd(struct adapter *adap, int sched, int qidx, int lo,
 	if (!skb)
 		return -ENOMEM;
 
-	req = (struct mngt_pktsched_wr *)skb_put(skb, sizeof(*req));
+	req = skb_put(skb, sizeof(*req));
 	req->wr_hi = htonl(V_WR_OP(FW_WROPCODE_MNGT));
 	req->mngt_opcode = FW_MNGTOPCODE_PKTSCHED_SET;
 	req->sched = sched;
diff --git a/drivers/net/ethernet/chelsio/cxgb3/cxgb3_offload.c b/drivers/net/ethernet/chelsio/cxgb3/cxgb3_offload.c
index fa81445e334c..50cd660732c5 100644
--- a/drivers/net/ethernet/chelsio/cxgb3/cxgb3_offload.c
+++ b/drivers/net/ethernet/chelsio/cxgb3/cxgb3_offload.c
@@ -552,7 +552,7 @@ static inline void mk_tid_release(struct sk_buff *skb, unsigned int tid)
 	struct cpl_tid_release *req;
 
 	skb->priority = CPL_PRIORITY_SETUP;
-	req = (struct cpl_tid_release *)__skb_put(skb, sizeof(*req));
+	req = __skb_put(skb, sizeof(*req));
 	req->wr.wr_hi = htonl(V_WR_OP(FW_WROPCODE_FORWARD));
 	OPCODE_TID(req) = htonl(MK_OPCODE_TID(CPL_TID_RELEASE, tid));
 }
@@ -1096,7 +1096,7 @@ static void set_l2t_ix(struct t3cdev *tdev, u32 tid, struct l2t_entry *e)
 		return;
 	}
 	skb->priority = CPL_PRIORITY_CONTROL;
-	req = (struct cpl_set_tcb_field *)skb_put(skb, sizeof(*req));
+	req = skb_put(skb, sizeof(*req));
 	req->wr.wr_hi = htonl(V_WR_OP(FW_WROPCODE_FORWARD));
 	OPCODE_TID(req) = htonl(MK_OPCODE_TID(CPL_SET_TCB_FIELD, tid));
 	req->reply = 0;
diff --git a/drivers/net/ethernet/chelsio/cxgb3/l2t.c b/drivers/net/ethernet/chelsio/cxgb3/l2t.c
index 26264125865f..248e40c6966c 100644
--- a/drivers/net/ethernet/chelsio/cxgb3/l2t.c
+++ b/drivers/net/ethernet/chelsio/cxgb3/l2t.c
@@ -96,7 +96,7 @@ static int setup_l2e_send_pending(struct t3cdev *dev, struct sk_buff *skb,
 			return -ENOMEM;
 	}
 
-	req = (struct cpl_l2t_write_req *)__skb_put(skb, sizeof(*req));
+	req = __skb_put(skb, sizeof(*req));
 	req->wr.wr_hi = htonl(V_WR_OP(FW_WROPCODE_FORWARD));
 	OPCODE_TID(req) = htonl(MK_OPCODE_TID(CPL_L2T_WRITE_REQ, e->idx));
 	req->params = htonl(V_L2T_W_IDX(e->idx) | V_L2T_W_IFF(e->smt_idx) |
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_filter.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_filter.c
index 10736738ff30..a0fab65e80e8 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_filter.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_filter.c
@@ -190,7 +190,7 @@ static int del_filter_wr(struct adapter *adapter, int fidx)
 	if (!skb)
 		return -ENOMEM;
 
-	fwr = (struct fw_filter_wr *)__skb_put(skb, len);
+	fwr = __skb_put(skb, len);
 	t4_mk_filtdelwr(f->tid, fwr, adapter->sge.fw_evtq.abs_id);
 
 	/* Mark the filter as "pending" and ship off the Filter Work Request.
@@ -231,7 +231,7 @@ int set_filter_wr(struct adapter *adapter, int fidx)
 		}
 	}
 
-	fwr = (struct fw_filter_wr *)__skb_put(skb, sizeof(*fwr));
+	fwr = __skb_put(skb, sizeof(*fwr));
 	memset(fwr, 0, sizeof(*fwr));
 
 	/* It would be nice to put most of the following in t4_hw.c but most
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 2c6de769f4e6..15fb284eafc0 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -1175,7 +1175,7 @@ static void mk_tid_release(struct sk_buff *skb, unsigned int chan,
 	struct cpl_tid_release *req;
 
 	set_wr_txq(skb, CPL_PRIORITY_SETUP, chan);
-	req = (struct cpl_tid_release *)__skb_put(skb, sizeof(*req));
+	req = __skb_put(skb, sizeof(*req));
 	INIT_TP_WR(req, tid);
 	OPCODE_TID(req) = htonl(MK_OPCODE_TID(CPL_TID_RELEASE, tid));
 }
@@ -1359,7 +1359,7 @@ int cxgb4_create_server(const struct net_device *dev, unsigned int stid,
 		return -ENOMEM;
 
 	adap = netdev2adap(dev);
-	req = (struct cpl_pass_open_req *)__skb_put(skb, sizeof(*req));
+	req = __skb_put(skb, sizeof(*req));
 	INIT_TP_WR(req, 0);
 	OPCODE_TID(req) = htonl(MK_OPCODE_TID(CPL_PASS_OPEN_REQ, stid));
 	req->local_port = sport;
@@ -1400,7 +1400,7 @@ int cxgb4_create_server6(const struct net_device *dev, unsigned int stid,
 		return -ENOMEM;
 
 	adap = netdev2adap(dev);
-	req = (struct cpl_pass_open_req6 *)__skb_put(skb, sizeof(*req));
+	req = __skb_put(skb, sizeof(*req));
 	INIT_TP_WR(req, 0);
 	OPCODE_TID(req) = htonl(MK_OPCODE_TID(CPL_PASS_OPEN_REQ6, stid));
 	req->local_port = sport;
@@ -1432,7 +1432,7 @@ int cxgb4_remove_server(const struct net_device *dev, unsigned int stid,
 	if (!skb)
 		return -ENOMEM;
 
-	req = (struct cpl_close_listsvr_req *)__skb_put(skb, sizeof(*req));
+	req = __skb_put(skb, sizeof(*req));
 	INIT_TP_WR(req, 0);
 	OPCODE_TID(req) = htonl(MK_OPCODE_TID(CPL_CLOSE_LISTSRV_REQ, stid));
 	req->reply_ctrl = htons(NO_REPLY_V(0) | (ipv6 ? LISTSVR_IPV6_V(1) :
diff --git a/drivers/net/ethernet/chelsio/cxgb4/l2t.c b/drivers/net/ethernet/chelsio/cxgb4/l2t.c
index 6f3692db29af..f7ef8871dd0b 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/l2t.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/l2t.c
@@ -146,7 +146,7 @@ static int write_l2e(struct adapter *adap, struct l2t_entry *e, int sync)
 	if (!skb)
 		return -ENOMEM;
 
-	req = (struct cpl_l2t_write_req *)__skb_put(skb, sizeof(*req));
+	req = __skb_put(skb, sizeof(*req));
 	INIT_TP_WR(req, 0);
 
 	OPCODE_TID(req) = htonl(MK_OPCODE_TID(CPL_L2T_WRITE_REQ,
diff --git a/drivers/net/ethernet/chelsio/libcxgb/libcxgb_cm.h b/drivers/net/ethernet/chelsio/libcxgb/libcxgb_cm.h
index 515b94ff9080..4b5aacc09cab 100644
--- a/drivers/net/ethernet/chelsio/libcxgb/libcxgb_cm.h
+++ b/drivers/net/ethernet/chelsio/libcxgb/libcxgb_cm.h
@@ -90,7 +90,7 @@ cxgb_mk_tid_release(struct sk_buff *skb, u32 len, u32 tid, u16 chan)
 {
 	struct cpl_tid_release *req;
 
-	req = (struct cpl_tid_release *)__skb_put(skb, len);
+	req = __skb_put(skb, len);
 	memset(req, 0, len);
 
 	INIT_TP_WR(req, tid);
@@ -104,7 +104,7 @@ cxgb_mk_close_con_req(struct sk_buff *skb, u32 len, u32 tid, u16 chan,
 {
 	struct cpl_close_con_req *req;
 
-	req = (struct cpl_close_con_req *)__skb_put(skb, len);
+	req = __skb_put(skb, len);
 	memset(req, 0, len);
 
 	INIT_TP_WR(req, tid);
@@ -119,7 +119,7 @@ cxgb_mk_abort_req(struct sk_buff *skb, u32 len, u32 tid, u16 chan,
 {
 	struct cpl_abort_req *req;
 
-	req = (struct cpl_abort_req *)__skb_put(skb, len);
+	req = __skb_put(skb, len);
 	memset(req, 0, len);
 
 	INIT_TP_WR(req, tid);
@@ -134,7 +134,7 @@ cxgb_mk_abort_rpl(struct sk_buff *skb, u32 len, u32 tid, u16 chan)
 {
 	struct cpl_abort_rpl *rpl;
 
-	rpl = (struct cpl_abort_rpl *)__skb_put(skb, len);
+	rpl = __skb_put(skb, len);
 	memset(rpl, 0, len);
 
 	INIT_TP_WR(rpl, tid);
@@ -149,7 +149,7 @@ cxgb_mk_rx_data_ack(struct sk_buff *skb, u32 len, u32 tid, u16 chan,
 {
 	struct cpl_rx_data_ack *req;
 
-	req = (struct cpl_rx_data_ack *)__skb_put(skb, len);
+	req = __skb_put(skb, len);
 	memset(req, 0, len);
 
 	INIT_TP_WR(req, tid);
diff --git a/drivers/net/ethernet/davicom/dm9000.c b/drivers/net/ethernet/davicom/dm9000.c
index 008dc8161775..16fe776ddbe5 100644
--- a/drivers/net/ethernet/davicom/dm9000.c
+++ b/drivers/net/ethernet/davicom/dm9000.c
@@ -1171,7 +1171,7 @@ dm9000_rx(struct net_device *dev)
 		if (GoodPacket &&
 		    ((skb = netdev_alloc_skb(dev, RxLen + 4)) != NULL)) {
 			skb_reserve(skb, 2);
-			rdptr = (u8 *) skb_put(skb, RxLen - 4);
+			rdptr = skb_put(skb, RxLen - 4);
 
 			/* Read received packet from RX SRAM */
 
diff --git a/drivers/net/ethernet/dnet.c b/drivers/net/ethernet/dnet.c
index 3e77dd863175..5a847941c46b 100644
--- a/drivers/net/ethernet/dnet.c
+++ b/drivers/net/ethernet/dnet.c
@@ -399,7 +399,7 @@ static int dnet_poll(struct napi_struct *napi, int budget)
 			 * 'skb_put()' points to the start of sk_buff
 			 * data area.
 			 */
-			data_ptr = (unsigned int *)skb_put(skb, pkt_len);
+			data_ptr = skb_put(skb, pkt_len);
 			for (i = 0; i < (pkt_len + 3) >> 2; i++)
 				*data_ptr++ = dnet_readl(bp, RX_DATA_FIFO);
 			skb->protocol = eth_type_trans(skb, dev);
diff --git a/drivers/net/ethernet/hp/hp100.c b/drivers/net/ethernet/hp/hp100.c
index 5673b071e39d..c6164a98f257 100644
--- a/drivers/net/ethernet/hp/hp100.c
+++ b/drivers/net/ethernet/hp/hp100.c
@@ -1281,7 +1281,7 @@ static int hp100_build_rx_pdl(hp100_ring_t * ringptr,
 		 */
 		skb_reserve(ringptr->skb, 2);
 
-		ringptr->skb->data = (u_char *) skb_put(ringptr->skb, MAX_ETHER_SIZE);
+		ringptr->skb->data = skb_put(ringptr->skb, MAX_ETHER_SIZE);
 
 		/* ringptr->pdl points to the beginning of the PDL, i.e. the PDH */
 		/* Note: 1st Fragment is used for the 4 byte packet status
diff --git a/drivers/net/ethernet/intel/i40e/i40e_fcoe.c b/drivers/net/ethernet/intel/i40e/i40e_fcoe.c
index b077ef8b00fa..2d1253c5b7a1 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_fcoe.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_fcoe.c
@@ -762,7 +762,7 @@ int i40e_fcoe_handle_offload(struct i40e_ring *rx_ring,
 		    (fh->fh_r_ctl == FC_RCTL_DD_SOL_DATA)) {
 			struct fcoe_crc_eof *crc = NULL;
 
-			crc = (struct fcoe_crc_eof *)skb_put(skb, sizeof(*crc));
+			crc = skb_put(skb, sizeof(*crc));
 			crc->fcoe_eof = FC_EOF_T;
 		} else {
 			/* otherwise, drop the header only frame */
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c
index 2a653ec954f5..a23c2b5411a0 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c
@@ -491,7 +491,7 @@ int ixgbe_fcoe_ddp(struct ixgbe_adapter *adapter,
 	if ((fh->fh_r_ctl == FC_RCTL_DD_SOL_DATA) &&
 	    (fctl & FC_FC_END_SEQ)) {
 		skb_linearize(skb);
-		crc = (struct fcoe_crc_eof *)skb_put(skb, sizeof(*crc));
+		crc = skb_put(skb, sizeof(*crc));
 		crc->fcoe_eof = FC_EOF_T;
 	}
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_selftest.c b/drivers/net/ethernet/mellanox/mlx4/en_selftest.c
index 17112faafbcc..88699b181946 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_selftest.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_selftest.c
@@ -63,8 +63,8 @@ static int mlx4_en_test_loopback_xmit(struct mlx4_en_priv *priv)
 
 	skb_reserve(skb, NET_IP_ALIGN);
 
-	ethh = (struct ethhdr *)skb_put(skb, sizeof(struct ethhdr));
-	packet	= (unsigned char *)skb_put(skb, packet_size);
+	ethh = skb_put(skb, sizeof(struct ethhdr));
+	packet = skb_put(skb, packet_size);
 	memcpy(ethh->h_dest, priv->dev->dev_addr, ETH_ALEN);
 	eth_zero_addr(ethh->h_source);
 	ethh->h_proto = htons(ETH_P_ARP);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_selftest.c b/drivers/net/ethernet/mellanox/mlx5/core/en_selftest.c
index 601abf240d63..c456ca07b562 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_selftest.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_selftest.c
@@ -136,10 +136,10 @@ static struct sk_buff *mlx5e_test_get_udp_skb(struct mlx5e_priv *priv)
 	skb_reset_mac_header(skb);
 
 	skb_set_network_header(skb, skb->len);
-	iph = (struct iphdr *)skb_put(skb, sizeof(struct iphdr));
+	iph = skb_put(skb, sizeof(struct iphdr));
 
 	skb_set_transport_header(skb, skb->len);
-	udph = (struct udphdr *)skb_put(skb, sizeof(struct udphdr));
+	udph = skb_put(skb, sizeof(struct udphdr));
 
 	/* Fill ETH header */
 	ether_addr_copy(ethh->h_dest, priv->netdev->dev_addr);
@@ -167,7 +167,7 @@ static struct sk_buff *mlx5e_test_get_udp_skb(struct mlx5e_priv *priv)
 	ip_send_check(iph);
 
 	/* Fill test header and data */
-	mlxh = (struct mlx5ehdr *)skb_put(skb, sizeof(*mlxh));
+	mlxh = skb_put(skb, sizeof(*mlxh));
 	mlxh->version = 0;
 	mlxh->magic = cpu_to_be64(MLX5E_TEST_MAGIC);
 	strlcpy(mlxh->text, mlx5e_test_text, sizeof(mlxh->text));
diff --git a/drivers/net/ethernet/micrel/ks8842.c b/drivers/net/ethernet/micrel/ks8842.c
index cb0102dd7f70..e3d7c74d47bb 100644
--- a/drivers/net/ethernet/micrel/ks8842.c
+++ b/drivers/net/ethernet/micrel/ks8842.c
@@ -669,7 +669,7 @@ static void ks8842_rx_frame(struct net_device *netdev,
 			ks8842_update_rx_counters(netdev, status, len);
 
 			if (adapter->conf_flags & KS884X_16BIT) {
-				u16 *data16 = (u16 *)skb_put(skb, len);
+				u16 *data16 = skb_put(skb, len);
 				ks8842_select_bank(adapter, 17);
 				while (len > 0) {
 					*data16++ = ioread16(adapter->hw_addr +
@@ -679,7 +679,7 @@ static void ks8842_rx_frame(struct net_device *netdev,
 					len -= sizeof(u32);
 				}
 			} else {
-				u32 *data = (u32 *)skb_put(skb, len);
+				u32 *data = skb_put(skb, len);
 
 				ks8842_select_bank(adapter, 17);
 				while (len > 0) {
diff --git a/drivers/net/ethernet/sfc/falcon/selftest.c b/drivers/net/ethernet/sfc/falcon/selftest.c
index 92bc34c91547..55c0fbbc4fb8 100644
--- a/drivers/net/ethernet/sfc/falcon/selftest.c
+++ b/drivers/net/ethernet/sfc/falcon/selftest.c
@@ -431,8 +431,7 @@ static int ef4_begin_loopback(struct ef4_tx_queue *tx_queue)
 
 		/* Copy the payload in, incrementing the source address to
 		 * exercise the rss vectors */
-		payload = ((struct ef4_loopback_payload *)
-			   skb_put(skb, sizeof(state->payload)));
+		payload = skb_put(skb, sizeof(state->payload));
 		memcpy(payload, &state->payload, sizeof(state->payload));
 		payload->ip.saddr = htonl(INADDR_LOOPBACK | (i << 2));
 
diff --git a/drivers/net/ethernet/sfc/selftest.c b/drivers/net/ethernet/sfc/selftest.c
index dab286a337a6..f6936949fc85 100644
--- a/drivers/net/ethernet/sfc/selftest.c
+++ b/drivers/net/ethernet/sfc/selftest.c
@@ -431,8 +431,7 @@ static int efx_begin_loopback(struct efx_tx_queue *tx_queue)
 
 		/* Copy the payload in, incrementing the source address to
 		 * exercise the rss vectors */
-		payload = ((struct efx_loopback_payload *)
-			   skb_put(skb, sizeof(state->payload)));
+		payload = skb_put(skb, sizeof(state->payload));
 		memcpy(payload, &state->payload, sizeof(state->payload));
 		payload->ip.saddr = htonl(INADDR_LOOPBACK | (i << 2));
 
diff --git a/drivers/net/hamradio/scc.c b/drivers/net/hamradio/scc.c
index 6754cd01c605..140a209f22ab 100644
--- a/drivers/net/hamradio/scc.c
+++ b/drivers/net/hamradio/scc.c
@@ -540,7 +540,7 @@ static inline void scc_rxint(struct scc_channel *scc)
 		}
 		
 		scc->rx_buff = skb;
-		*(skb_put(skb, 1)) = 0;	/* KISS data */
+		*(u8 *)skb_put(skb, 1) = 0;	/* KISS data */
 	}
 	
 	if (skb->len >= scc->stat.bufsize)
@@ -555,7 +555,7 @@ static inline void scc_rxint(struct scc_channel *scc)
 		return;
 	}
 
-	*(skb_put(skb, 1)) = Inb(scc->data);
+	*(u8 *)skb_put(skb, 1) = Inb(scc->data);
 }
 
 
diff --git a/drivers/net/ppp/pppoe.c b/drivers/net/ppp/pppoe.c
index d7e405268983..4e1da1645b15 100644
--- a/drivers/net/ppp/pppoe.c
+++ b/drivers/net/ppp/pppoe.c
@@ -877,7 +877,7 @@ static int pppoe_sendmsg(struct socket *sock, struct msghdr *m,
 	skb->priority = sk->sk_priority;
 	skb->protocol = cpu_to_be16(ETH_P_PPP_SES);
 
-	ph = (struct pppoe_hdr *)skb_put(skb, total_len + sizeof(struct pppoe_hdr));
+	ph = skb_put(skb, total_len + sizeof(struct pppoe_hdr));
 	start = (char *)&ph->tag[0];
 
 	error = memcpy_from_msg(start, m, total_len);
diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index 8a4c8a1b9dd3..4d4837a0645b 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -1250,7 +1250,7 @@ cdc_ncm_fill_tx_frame(struct usbnet *dev, struct sk_buff *skb, __le32 sign)
 		skb_put_zero(skb_out, padding_count);
 	} else if (skb_out->len < ctx->tx_max &&
 		   (skb_out->len % dev->maxpacket) == 0) {
-		*skb_put(skb_out, 1) = 0;	/* force short packet */
+		*(u8 *)skb_put(skb_out, 1) = 0;	/* force short packet */
 	}
 
 	/* set final frame length */
diff --git a/drivers/net/usb/net1080.c b/drivers/net/usb/net1080.c
index 3202c19df83d..861ff45f0b09 100644
--- a/drivers/net/usb/net1080.c
+++ b/drivers/net/usb/net1080.c
@@ -473,8 +473,8 @@ net1080_tx_fixup(struct usbnet *dev, struct sk_buff *skb, gfp_t flags)
 
 	/* maybe pad; then trailer */
 	if (!((skb->len + sizeof *trailer) & 0x01))
-		*skb_put(skb, 1) = PAD_BYTE;
-	trailer = (struct nc_trailer *) skb_put(skb, sizeof *trailer);
+		*(u8 *)skb_put(skb, 1) = PAD_BYTE;
+	trailer = skb_put(skb, sizeof *trailer);
 	put_unaligned(header->packet_id, &trailer->packet_id);
 #if 0
 	netdev_dbg(dev->net, "frame >tx h %d p %d id %d\n",
diff --git a/drivers/net/usb/zaurus.c b/drivers/net/usb/zaurus.c
index 6aaa6eb9df72..dc3cd03763af 100644
--- a/drivers/net/usb/zaurus.c
+++ b/drivers/net/usb/zaurus.c
@@ -74,10 +74,10 @@ zaurus_tx_fixup(struct usbnet *dev, struct sk_buff *skb, gfp_t flags)
 		fcs = crc32_le(~0, skb->data, skb->len);
 		fcs = ~fcs;
 
-		*skb_put (skb, 1) = fcs       & 0xff;
-		*skb_put (skb, 1) = (fcs>> 8) & 0xff;
-		*skb_put (skb, 1) = (fcs>>16) & 0xff;
-		*skb_put (skb, 1) = (fcs>>24) & 0xff;
+		*(u8 *)skb_put(skb, 1) = fcs       & 0xff;
+		*(u8 *)skb_put(skb, 1) = (fcs>> 8) & 0xff;
+		*(u8 *)skb_put(skb, 1) = (fcs>>16) & 0xff;
+		*(u8 *)skb_put(skb, 1) = (fcs>>24) & 0xff;
 	}
 	return skb;
 }
diff --git a/drivers/net/wan/hdlc_ppp.c b/drivers/net/wan/hdlc_ppp.c
index f5b4ad45831a..fa3460a0dbbe 100644
--- a/drivers/net/wan/hdlc_ppp.c
+++ b/drivers/net/wan/hdlc_ppp.c
@@ -228,7 +228,7 @@ static void ppp_tx_cp(struct net_device *dev, u16 pid, u8 code,
 	}
 	skb_reserve(skb, sizeof(struct hdlc_header));
 
-	cp = (struct cp_header *)skb_put(skb, sizeof(struct cp_header));
+	cp = skb_put(skb, sizeof(struct cp_header));
 	cp->code = code;
 	cp->id = id;
 	cp->len = htons(sizeof(struct cp_header) + magic_len + len);
diff --git a/drivers/net/wireless/ath/ath6kl/debug.c b/drivers/net/wireless/ath/ath6kl/debug.c
index e2b7809d7886..1eea6c23976f 100644
--- a/drivers/net/wireless/ath/ath6kl/debug.c
+++ b/drivers/net/wireless/ath/ath6kl/debug.c
@@ -348,7 +348,7 @@ void ath6kl_debug_fwlog_event(struct ath6kl *ar, const void *buf, size_t len)
 	if (!skb)
 		return;
 
-	slot = (struct ath6kl_fwlog_slot *) skb_put(skb, slot_len);
+	slot = skb_put(skb, slot_len);
 	slot->timestamp = cpu_to_le32(jiffies);
 	slot->length = cpu_to_le32(len);
 	memcpy(slot->payload, buf, len);
diff --git a/drivers/net/wireless/ath/ath6kl/htc_pipe.c b/drivers/net/wireless/ath/ath6kl/htc_pipe.c
index d127a08d60df..b13d61111072 100644
--- a/drivers/net/wireless/ath/ath6kl/htc_pipe.c
+++ b/drivers/net/wireless/ath/ath6kl/htc_pipe.c
@@ -1274,8 +1274,7 @@ static int ath6kl_htc_pipe_conn_service(struct htc_target *target,
 		length = sizeof(struct htc_conn_service_msg);
 
 		/* assemble connect service message */
-		conn_msg = (struct htc_conn_service_msg *) skb_put(skb,
-								   length);
+		conn_msg = skb_put(skb, length);
 		if (conn_msg == NULL) {
 			WARN_ON_ONCE(1);
 			status = -EINVAL;
@@ -1504,8 +1503,7 @@ static int ath6kl_htc_pipe_start(struct htc_target *target)
 	skb = packet->skb;
 
 	/* assemble setup complete message */
-	setup = (struct htc_setup_comp_ext_msg *) skb_put(skb,
-							  sizeof(*setup));
+	setup = skb_put(skb, sizeof(*setup));
 	memset(setup, 0, sizeof(struct htc_setup_comp_ext_msg));
 	setup->msg_id = cpu_to_le16(HTC_MSG_SETUP_COMPLETE_EX_ID);
 
diff --git a/drivers/net/wireless/ath/ath9k/htc_hst.c b/drivers/net/wireless/ath/ath9k/htc_hst.c
index 8e6dae23669b..9fa8970a1f7d 100644
--- a/drivers/net/wireless/ath/ath9k/htc_hst.c
+++ b/drivers/net/wireless/ath/ath9k/htc_hst.c
@@ -156,8 +156,7 @@ static int htc_config_pipe_credits(struct htc_target *target)
 	}
 	skb_reserve(skb, sizeof(struct htc_frame_hdr));
 
-	cp_msg = (struct htc_config_pipe_msg *)
-		skb_put(skb, sizeof(struct htc_config_pipe_msg));
+	cp_msg = skb_put(skb, sizeof(struct htc_config_pipe_msg));
 
 	cp_msg->message_id = cpu_to_be16(HTC_MSG_CONFIG_PIPE_ID);
 	cp_msg->pipe_id = USB_WLAN_TX_PIPE;
@@ -195,8 +194,7 @@ static int htc_setup_complete(struct htc_target *target)
 	}
 	skb_reserve(skb, sizeof(struct htc_frame_hdr));
 
-	comp_msg = (struct htc_comp_msg *)
-		skb_put(skb, sizeof(struct htc_comp_msg));
+	comp_msg = skb_put(skb, sizeof(struct htc_comp_msg));
 	comp_msg->msg_id = cpu_to_be16(HTC_MSG_SETUP_COMPLETE_ID);
 
 	target->htc_flags |= HTC_OP_START_WAIT;
@@ -265,8 +263,7 @@ int htc_connect_service(struct htc_target *target,
 
 	skb_reserve(skb, sizeof(struct htc_frame_hdr));
 
-	conn_msg = (struct htc_conn_svc_msg *)
-			skb_put(skb, sizeof(struct htc_conn_svc_msg));
+	conn_msg = skb_put(skb, sizeof(struct htc_conn_svc_msg));
 	conn_msg->service_id = cpu_to_be16(service_connreq->service_id);
 	conn_msg->msg_id = cpu_to_be16(HTC_MSG_CONNECT_SERVICE_ID);
 	conn_msg->con_flags = cpu_to_be16(service_connreq->con_flags);
diff --git a/drivers/net/wireless/ath/wil6210/wmi.c b/drivers/net/wireless/ath/wil6210/wmi.c
index cff9c585972f..0a5020f31de1 100644
--- a/drivers/net/wireless/ath/wil6210/wmi.c
+++ b/drivers/net/wireless/ath/wil6210/wmi.c
@@ -677,7 +677,7 @@ static void wmi_evt_eapol_rx(struct wil6210_priv *wil, int id,
 		return;
 	}
 
-	eth = (struct ethhdr *)skb_put(skb, ETH_HLEN);
+	eth = skb_put(skb, ETH_HLEN);
 	ether_addr_copy(eth->h_dest, ndev->dev_addr);
 	ether_addr_copy(eth->h_source, evt->src_mac);
 	eth->h_proto = cpu_to_be16(ETH_P_PAE);
diff --git a/drivers/net/wireless/cisco/airo.c b/drivers/net/wireless/cisco/airo.c
index 1b7e125a28e2..4623155ec36e 100644
--- a/drivers/net/wireless/cisco/airo.c
+++ b/drivers/net/wireless/cisco/airo.c
@@ -3330,7 +3330,7 @@ static void airo_handle_rx(struct airo_info *ai)
 	}
 
 	skb_reserve(skb, 2); /* This way the IP header is aligned */
-	buffer = (__le16 *) skb_put(skb, len + hdrlen);
+	buffer = skb_put(skb, len + hdrlen);
 	if (test_bit(FLAG_802_11, &ai->flags)) {
 		buffer[0] = fc;
 		bap_read(ai, buffer + 1, hdrlen - 2, BAP0);
@@ -3734,7 +3734,7 @@ static void mpi_receive_802_11(struct airo_info *ai)
 		ai->dev->stats.rx_dropped++;
 		goto badrx;
 	}
-	buffer = (u16*)skb_put (skb, len + hdrlen);
+	buffer = skb_put(skb, len + hdrlen);
 	memcpy ((char *)buffer, ptr, hdrlen);
 	ptr += hdrlen;
 	if (hdrlen == 24)
diff --git a/drivers/net/wireless/intel/ipw2x00/ipw2200.c b/drivers/net/wireless/intel/ipw2x00/ipw2200.c
index e0c690b48d4e..5e4ce4abd62e 100644
--- a/drivers/net/wireless/intel/ipw2x00/ipw2200.c
+++ b/drivers/net/wireless/intel/ipw2x00/ipw2200.c
@@ -10371,7 +10371,7 @@ static void ipw_handle_promiscuous_tx(struct ipw_priv *priv,
 		if (!dst)
 			continue;
 
-		rt_hdr = (void *)skb_put(dst, sizeof(*rt_hdr));
+		rt_hdr = skb_put(dst, sizeof(*rt_hdr));
 
 		rt_hdr->it_version = PKTHDR_RADIOTAP_VERSION;
 		rt_hdr->it_pad = 0;
diff --git a/drivers/net/wireless/intel/ipw2x00/libipw_tx.c b/drivers/net/wireless/intel/ipw2x00/libipw_tx.c
index 5339d1eeb2f7..84205aa508df 100644
--- a/drivers/net/wireless/intel/ipw2x00/libipw_tx.c
+++ b/drivers/net/wireless/intel/ipw2x00/libipw_tx.c
@@ -439,8 +439,7 @@ netdev_tx_t libipw_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	if (rts_required) {
 		skb_frag = txb->fragments[0];
-		frag_hdr =
-		    (struct libipw_hdr_3addrqos *)skb_put(skb_frag, hdr_len);
+		frag_hdr = skb_put(skb_frag, hdr_len);
 
 		/*
 		 * Set header frame_ctl to the RTS.
diff --git a/drivers/net/wireless/intersil/hostap/hostap_ap.c b/drivers/net/wireless/intersil/hostap/hostap_ap.c
index 91757defb9be..eb9cd6fa9c4d 100644
--- a/drivers/net/wireless/intersil/hostap/hostap_ap.c
+++ b/drivers/net/wireless/intersil/hostap/hostap_ap.c
@@ -2361,7 +2361,7 @@ static void schedule_packet_send(local_info_t *local, struct sta_info *sta)
 		return;
 	}
 
-	hdr = (struct ieee80211_hdr *) skb_put(skb, 16);
+	hdr = skb_put(skb, 16);
 
 	/* Generate a fake pspoll frame to start packet delivery */
 	hdr->frame_control = cpu_to_le16(
diff --git a/drivers/net/wireless/intersil/p54/fwio.c b/drivers/net/wireless/intersil/p54/fwio.c
index 3076f646c829..52c095c7765f 100644
--- a/drivers/net/wireless/intersil/p54/fwio.c
+++ b/drivers/net/wireless/intersil/p54/fwio.c
@@ -206,7 +206,7 @@ static struct sk_buff *p54_alloc_skb(struct p54_common *priv, u16 hdr_flags,
 		return NULL;
 	skb_reserve(skb, priv->tx_hdr_len);
 
-	hdr = (struct p54_hdr *) skb_put(skb, sizeof(*hdr));
+	hdr = skb_put(skb, sizeof(*hdr));
 	hdr->flags = cpu_to_le16(hdr_flags);
 	hdr->len = cpu_to_le16(payload_len);
 	hdr->type = cpu_to_le16(type);
@@ -236,8 +236,7 @@ int p54_download_eeprom(struct p54_common *priv, void *buf,
 
 	mutex_lock(&priv->eeprom_mutex);
 	priv->eeprom = buf;
-	eeprom_hdr = (struct p54_eeprom_lm86 *) skb_put(skb,
-		eeprom_hdr_size + len);
+	eeprom_hdr = skb_put(skb, eeprom_hdr_size + len);
 
 	if (priv->fw_var < 0x509) {
 		eeprom_hdr->v1.offset = cpu_to_le16(offset);
@@ -273,7 +272,7 @@ int p54_update_beacon_tim(struct p54_common *priv, u16 aid, bool set)
 	if (unlikely(!skb))
 		return -ENOMEM;
 
-	tim = (struct p54_tim *) skb_put(skb, sizeof(*tim));
+	tim = skb_put(skb, sizeof(*tim));
 	tim->count = 1;
 	tim->entry[0] = cpu_to_le16(set ? (aid | 0x8000) : aid);
 	p54_tx(priv, skb);
@@ -290,7 +289,7 @@ int p54_sta_unlock(struct p54_common *priv, u8 *addr)
 	if (unlikely(!skb))
 		return -ENOMEM;
 
-	sta = (struct p54_sta_unlock *)skb_put(skb, sizeof(*sta));
+	sta = skb_put(skb, sizeof(*sta));
 	memcpy(sta->addr, addr, ETH_ALEN);
 	p54_tx(priv, skb);
 	return 0;
@@ -310,7 +309,7 @@ int p54_tx_cancel(struct p54_common *priv, __le32 req_id)
 	if (unlikely(!skb))
 		return -ENOMEM;
 
-	cancel = (struct p54_txcancel *)skb_put(skb, sizeof(*cancel));
+	cancel = skb_put(skb, sizeof(*cancel));
 	cancel->req_id = req_id;
 	p54_tx(priv, skb);
 	return 0;
@@ -327,7 +326,7 @@ int p54_setup_mac(struct p54_common *priv)
 	if (!skb)
 		return -ENOMEM;
 
-	setup = (struct p54_setup_mac *) skb_put(skb, sizeof(*setup));
+	setup = skb_put(skb, sizeof(*setup));
 	if (!(priv->hw->conf.flags & IEEE80211_CONF_IDLE)) {
 		switch (priv->mode) {
 		case NL80211_IFTYPE_STATION:
@@ -413,18 +412,18 @@ int p54_scan(struct p54_common *priv, u16 mode, u16 dwell)
 	if (!skb)
 		return -ENOMEM;
 
-	head = (struct p54_scan_head *) skb_put(skb, sizeof(*head));
+	head = skb_put(skb, sizeof(*head));
 	memset(head->scan_params, 0, sizeof(head->scan_params));
 	head->mode = cpu_to_le16(mode);
 	head->dwell = cpu_to_le16(dwell);
 	head->freq = freq;
 
 	if (priv->rxhw == PDR_SYNTH_FRONTEND_LONGBOW) {
-		__le16 *pa_power_points = (__le16 *) skb_put(skb, 2);
+		__le16 *pa_power_points = skb_put(skb, 2);
 		*pa_power_points = cpu_to_le16(0x0c);
 	}
 
-	iq_autocal = (void *) skb_put(skb, sizeof(*iq_autocal));
+	iq_autocal = skb_put(skb, sizeof(*iq_autocal));
 	for (i = 0; i < priv->iq_autocal_len; i++) {
 		if (priv->iq_autocal[i].freq != freq)
 			continue;
@@ -437,9 +436,9 @@ int p54_scan(struct p54_common *priv, u16 mode, u16 dwell)
 		goto err;
 
 	if (priv->rxhw == PDR_SYNTH_FRONTEND_LONGBOW)
-		body = (void *) skb_put(skb, sizeof(body->longbow));
+		body = skb_put(skb, sizeof(body->longbow));
 	else
-		body = (void *) skb_put(skb, sizeof(body->normal));
+		body = skb_put(skb, sizeof(body->normal));
 
 	for (i = 0; i < priv->output_limit->entries; i++) {
 		__le16 *entry_freq = (void *) (priv->output_limit->data +
@@ -500,25 +499,25 @@ int p54_scan(struct p54_common *priv, u16 mode, u16 dwell)
 		goto err;
 
 	if ((priv->fw_var >= 0x500) && (priv->fw_var < 0x509)) {
-		rate = (void *) skb_put(skb, sizeof(*rate));
+		rate = skb_put(skb, sizeof(*rate));
 		rate->basic_rate_mask = cpu_to_le32(priv->basic_rate_mask);
 		for (i = 0; i < sizeof(rate->rts_rates); i++)
 			rate->rts_rates[i] = i;
 	}
 
-	rssi = (struct pda_rssi_cal_entry *) skb_put(skb, sizeof(*rssi));
+	rssi = skb_put(skb, sizeof(*rssi));
 	rssi_data = p54_rssi_find(priv, le16_to_cpu(freq));
 	rssi->mul = cpu_to_le16(rssi_data->mul);
 	rssi->add = cpu_to_le16(rssi_data->add);
 	if (priv->rxhw == PDR_SYNTH_FRONTEND_LONGBOW) {
 		/* Longbow frontend needs ever more */
-		rssi = (void *) skb_put(skb, sizeof(*rssi));
+		rssi = skb_put(skb, sizeof(*rssi));
 		rssi->mul = cpu_to_le16(rssi_data->longbow_unkn);
 		rssi->add = cpu_to_le16(rssi_data->longbow_unk2);
 	}
 
 	if (priv->fw_var >= 0x509) {
-		rate = (void *) skb_put(skb, sizeof(*rate));
+		rate = skb_put(skb, sizeof(*rate));
 		rate->basic_rate_mask = cpu_to_le32(priv->basic_rate_mask);
 		for (i = 0; i < sizeof(rate->rts_rates); i++)
 			rate->rts_rates[i] = i;
@@ -550,7 +549,7 @@ int p54_set_leds(struct p54_common *priv)
 	if (unlikely(!skb))
 		return -ENOMEM;
 
-	led = (struct p54_led *) skb_put(skb, sizeof(*led));
+	led = skb_put(skb, sizeof(*led));
 	led->flags = cpu_to_le16(0x0003);
 	led->mask[0] = led->mask[1] = cpu_to_le16(priv->softled_state);
 	led->delay[0] = cpu_to_le16(1);
@@ -570,7 +569,7 @@ int p54_set_edcf(struct p54_common *priv)
 	if (unlikely(!skb))
 		return -ENOMEM;
 
-	edcf = (struct p54_edcf *)skb_put(skb, sizeof(*edcf));
+	edcf = skb_put(skb, sizeof(*edcf));
 	if (priv->use_short_slot) {
 		edcf->slottime = 9;
 		edcf->sifs = 0x10;
@@ -615,7 +614,7 @@ int p54_set_ps(struct p54_common *priv)
 	if (!skb)
 		return -ENOMEM;
 
-	psm = (struct p54_psm *)skb_put(skb, sizeof(*psm));
+	psm = skb_put(skb, sizeof(*psm));
 	psm->mode = cpu_to_le16(mode);
 	psm->aid = cpu_to_le16(priv->aid);
 	for (i = 0; i < ARRAY_SIZE(psm->intervals); i++) {
@@ -644,7 +643,7 @@ int p54_init_xbow_synth(struct p54_common *priv)
 	if (unlikely(!skb))
 		return -ENOMEM;
 
-	xbow = (struct p54_xbow_synth *)skb_put(skb, sizeof(*xbow));
+	xbow = skb_put(skb, sizeof(*xbow));
 	xbow->magic1 = cpu_to_le16(0x1);
 	xbow->magic2 = cpu_to_le16(0x2);
 	xbow->freq = cpu_to_le16(5390);
@@ -664,7 +663,7 @@ int p54_upload_key(struct p54_common *priv, u8 algo, int slot, u8 idx, u8 len,
 	if (unlikely(!skb))
 		return -ENOMEM;
 
-	rxkey = (struct p54_keycache *)skb_put(skb, sizeof(*rxkey));
+	rxkey = skb_put(skb, sizeof(*rxkey));
 	rxkey->entry = slot;
 	rxkey->key_id = idx;
 	rxkey->key_type = algo;
@@ -744,7 +743,7 @@ int p54_set_groupfilter(struct p54_common *priv)
 	if (!skb)
 		return -ENOMEM;
 
-	grp = (struct p54_group_address_table *)skb_put(skb, sizeof(*grp));
+	grp = skb_put(skb, sizeof(*grp));
 
 	on = !(priv->filter_flags & FIF_ALLMULTI) &&
 	     (priv->mc_maclist_num > 0 &&
diff --git a/drivers/net/wireless/mac80211_hwsim.c b/drivers/net/wireless/mac80211_hwsim.c
index 1d6e180052b8..7418088e296f 100644
--- a/drivers/net/wireless/mac80211_hwsim.c
+++ b/drivers/net/wireless/mac80211_hwsim.c
@@ -650,7 +650,7 @@ static void hwsim_send_ps_poll(void *dat, u8 *mac, struct ieee80211_vif *vif)
 	skb = dev_alloc_skb(sizeof(*pspoll));
 	if (!skb)
 		return;
-	pspoll = (void *) skb_put(skb, sizeof(*pspoll));
+	pspoll = skb_put(skb, sizeof(*pspoll));
 	pspoll->frame_control = cpu_to_le16(IEEE80211_FTYPE_CTL |
 					    IEEE80211_STYPE_PSPOLL |
 					    IEEE80211_FCTL_PM);
@@ -681,7 +681,7 @@ static void hwsim_send_nullfunc(struct mac80211_hwsim_data *data, u8 *mac,
 	skb = dev_alloc_skb(sizeof(*hdr));
 	if (!skb)
 		return;
-	hdr = (void *) skb_put(skb, sizeof(*hdr) - ETH_ALEN);
+	hdr = skb_put(skb, sizeof(*hdr) - ETH_ALEN);
 	hdr->frame_control = cpu_to_le16(IEEE80211_FTYPE_DATA |
 					 IEEE80211_STYPE_NULLFUNC |
 					 (ps ? IEEE80211_FCTL_PM : 0));
@@ -892,7 +892,7 @@ static void mac80211_hwsim_monitor_ack(struct ieee80211_channel *chan,
 	if (skb == NULL)
 		return;
 
-	hdr = (struct hwsim_radiotap_ack_hdr *) skb_put(skb, sizeof(*hdr));
+	hdr = skb_put(skb, sizeof(*hdr));
 	hdr->hdr.it_version = PKTHDR_RADIOTAP_VERSION;
 	hdr->hdr.it_pad = 0;
 	hdr->hdr.it_len = cpu_to_le16(sizeof(*hdr));
@@ -904,7 +904,7 @@ static void mac80211_hwsim_monitor_ack(struct ieee80211_channel *chan,
 	flags = IEEE80211_CHAN_2GHZ;
 	hdr->rt_chbitmask = cpu_to_le16(flags);
 
-	hdr11 = (struct ieee80211_hdr *) skb_put(skb, 10);
+	hdr11 = skb_put(skb, 10);
 	hdr11->frame_control = cpu_to_le16(IEEE80211_FTYPE_CTL |
 					   IEEE80211_STYPE_ACK);
 	hdr11->duration_id = cpu_to_le16(0);
diff --git a/drivers/net/wireless/marvell/mwifiex/11n_aggr.c b/drivers/net/wireless/marvell/mwifiex/11n_aggr.c
index bc12c37e7501..042a1d07f686 100644
--- a/drivers/net/wireless/marvell/mwifiex/11n_aggr.c
+++ b/drivers/net/wireless/marvell/mwifiex/11n_aggr.c
@@ -62,7 +62,7 @@ mwifiex_11n_form_amsdu_pkt(struct sk_buff *skb_aggr,
 	};
 	struct tx_packet_hdr *tx_header;
 
-	tx_header = (void *)skb_put(skb_aggr, sizeof(*tx_header));
+	tx_header = skb_put(skb_aggr, sizeof(*tx_header));
 
 	/* Copy DA and SA */
 	dt_offset = 2 * ETH_ALEN;
diff --git a/drivers/net/wireless/marvell/mwifiex/tdls.c b/drivers/net/wireless/marvell/mwifiex/tdls.c
index d38555fe4284..39cd677d4159 100644
--- a/drivers/net/wireless/marvell/mwifiex/tdls.c
+++ b/drivers/net/wireless/marvell/mwifiex/tdls.c
@@ -158,7 +158,7 @@ static void mwifiex_tdls_add_aid(struct mwifiex_private *priv,
 	u8 *pos;
 
 	assoc_rsp = (struct ieee_types_assoc_rsp *)&priv->assoc_rsp_buf;
-	pos = (void *)skb_put(skb, 4);
+	pos = skb_put(skb, 4);
 	*pos++ = WLAN_EID_AID;
 	*pos++ = 2;
 	memcpy(pos, &assoc_rsp->a_id, sizeof(assoc_rsp->a_id));
@@ -172,7 +172,7 @@ static int mwifiex_tdls_add_vht_capab(struct mwifiex_private *priv,
 	struct ieee80211_vht_cap vht_cap;
 	u8 *pos;
 
-	pos = (void *)skb_put(skb, sizeof(struct ieee80211_vht_cap) + 2);
+	pos = skb_put(skb, sizeof(struct ieee80211_vht_cap) + 2);
 	*pos++ = WLAN_EID_VHT_CAPABILITY;
 	*pos++ = sizeof(struct ieee80211_vht_cap);
 
@@ -207,7 +207,7 @@ mwifiex_tdls_add_ht_oper(struct mwifiex_private *priv, const u8 *mac,
 		return 0;
 	}
 
-	pos = (void *)skb_put(skb, sizeof(struct ieee80211_ht_operation) + 2);
+	pos = skb_put(skb, sizeof(struct ieee80211_ht_operation) + 2);
 	*pos++ = WLAN_EID_HT_OPERATION;
 	*pos++ = sizeof(struct ieee80211_ht_operation);
 	ht_oper = (void *)pos;
@@ -272,7 +272,7 @@ static int mwifiex_tdls_add_vht_oper(struct mwifiex_private *priv,
 		ap_vht_cap = bss_desc->bcn_vht_cap;
 	}
 
-	pos = (void *)skb_put(skb, sizeof(struct ieee80211_vht_operation) + 2);
+	pos = skb_put(skb, sizeof(struct ieee80211_vht_operation) + 2);
 	*pos++ = WLAN_EID_VHT_OPERATION;
 	*pos++ = sizeof(struct ieee80211_vht_operation);
 	vht_oper = (struct ieee80211_vht_operation *)pos;
@@ -359,7 +359,7 @@ static void mwifiex_tdls_add_ext_capab(struct mwifiex_private *priv,
 {
 	struct ieee_types_extcap *extcap;
 
-	extcap = (void *)skb_put(skb, sizeof(struct ieee_types_extcap));
+	extcap = skb_put(skb, sizeof(struct ieee_types_extcap));
 	extcap->ieee_hdr.element_id = WLAN_EID_EXT_CAPABILITY;
 	extcap->ieee_hdr.len = 8;
 	memset(extcap->ext_capab, 0, 8);
@@ -372,7 +372,7 @@ static void mwifiex_tdls_add_ext_capab(struct mwifiex_private *priv,
 
 static void mwifiex_tdls_add_qos_capab(struct sk_buff *skb)
 {
-	u8 *pos = (void *)skb_put(skb, 3);
+	u8 *pos = skb_put(skb, 3);
 
 	*pos++ = WLAN_EID_QOS_CAPA;
 	*pos++ = 1;
@@ -413,8 +413,8 @@ mwifiex_add_wmm_info_ie(struct mwifiex_private *priv, struct sk_buff *skb,
 {
 	u8 *buf;
 
-	buf = (void *)skb_put(skb, MWIFIEX_TDLS_WMM_INFO_SIZE +
-			      sizeof(struct ieee_types_header));
+	buf = skb_put(skb,
+		      MWIFIEX_TDLS_WMM_INFO_SIZE + sizeof(struct ieee_types_header));
 
 	*buf++ = WLAN_EID_VENDOR_SPECIFIC;
 	*buf++ = 7; /* len */
@@ -431,7 +431,7 @@ static void mwifiex_tdls_add_bss_co_2040(struct sk_buff *skb)
 {
 	struct ieee_types_bss_co_2040 *bssco;
 
-	bssco = (void *)skb_put(skb, sizeof(struct ieee_types_bss_co_2040));
+	bssco = skb_put(skb, sizeof(struct ieee_types_bss_co_2040));
 	bssco->ieee_hdr.element_id = WLAN_EID_BSS_COEX_2040;
 	bssco->ieee_hdr.len = sizeof(struct ieee_types_bss_co_2040) -
 			      sizeof(struct ieee_types_header);
@@ -443,8 +443,8 @@ static void mwifiex_tdls_add_supported_chan(struct sk_buff *skb)
 	struct ieee_types_generic *supp_chan;
 	u8 chan_supp[] = {1, 11};
 
-	supp_chan = (void *)skb_put(skb, (sizeof(struct ieee_types_header) +
-					  sizeof(chan_supp)));
+	supp_chan = skb_put(skb,
+			    (sizeof(struct ieee_types_header) + sizeof(chan_supp)));
 	supp_chan->ieee_hdr.element_id = WLAN_EID_SUPPORTED_CHANNELS;
 	supp_chan->ieee_hdr.len = sizeof(chan_supp);
 	memcpy(supp_chan->data, chan_supp, sizeof(chan_supp));
@@ -455,8 +455,8 @@ static void mwifiex_tdls_add_oper_class(struct sk_buff *skb)
 	struct ieee_types_generic *reg_class;
 	u8 rc_list[] = {1,
 		1, 2, 3, 4, 12, 22, 23, 24, 25, 27, 28, 29, 30, 32, 33};
-	reg_class = (void *)skb_put(skb, (sizeof(struct ieee_types_header) +
-					  sizeof(rc_list)));
+	reg_class = skb_put(skb,
+			    (sizeof(struct ieee_types_header) + sizeof(rc_list)));
 	reg_class->ieee_hdr.element_id = WLAN_EID_SUPPORTED_REGULATORY_CLASSES;
 	reg_class->ieee_hdr.len = sizeof(rc_list);
 	memcpy(reg_class->data, rc_list, sizeof(rc_list));
@@ -475,7 +475,7 @@ static int mwifiex_prep_tdls_encap_data(struct mwifiex_private *priv,
 
 	capab = priv->curr_bss_params.bss_descriptor.cap_info_bitmap;
 
-	tf = (void *)skb_put(skb, offsetof(struct ieee80211_tdls_data, u));
+	tf = skb_put(skb, offsetof(struct ieee80211_tdls_data, u));
 	memcpy(tf->da, peer, ETH_ALEN);
 	memcpy(tf->sa, priv->curr_addr, ETH_ALEN);
 	tf->ether_type = cpu_to_be16(ETH_P_TDLS);
@@ -494,7 +494,7 @@ static int mwifiex_prep_tdls_encap_data(struct mwifiex_private *priv,
 			return ret;
 		}
 
-		pos = (void *)skb_put(skb, sizeof(struct ieee80211_ht_cap) + 2);
+		pos = skb_put(skb, sizeof(struct ieee80211_ht_cap) + 2);
 		*pos++ = WLAN_EID_HT_CAPABILITY;
 		*pos++ = sizeof(struct ieee80211_ht_cap);
 		ht_cap = (void *)pos;
@@ -534,7 +534,7 @@ static int mwifiex_prep_tdls_encap_data(struct mwifiex_private *priv,
 			return ret;
 		}
 
-		pos = (void *)skb_put(skb, sizeof(struct ieee80211_ht_cap) + 2);
+		pos = skb_put(skb, sizeof(struct ieee80211_ht_cap) + 2);
 		*pos++ = WLAN_EID_HT_CAPABILITY;
 		*pos++ = sizeof(struct ieee80211_ht_cap);
 		ht_cap = (void *)pos;
@@ -616,7 +616,7 @@ mwifiex_tdls_add_link_ie(struct sk_buff *skb, const u8 *src_addr,
 {
 	struct ieee80211_tdls_lnkie *lnkid;
 
-	lnkid = (void *)skb_put(skb, sizeof(struct ieee80211_tdls_lnkie));
+	lnkid = skb_put(skb, sizeof(struct ieee80211_tdls_lnkie));
 	lnkid->ie_type = WLAN_EID_LINK_ID;
 	lnkid->ie_len = sizeof(struct ieee80211_tdls_lnkie) -
 			sizeof(struct ieee_types_header);
@@ -741,7 +741,7 @@ mwifiex_construct_tdls_action_frame(struct mwifiex_private *priv,
 
 	capab = priv->curr_bss_params.bss_descriptor.cap_info_bitmap;
 
-	mgmt = (void *)skb_put(skb, offsetof(struct ieee80211_mgmt, u));
+	mgmt = skb_put(skb, offsetof(struct ieee80211_mgmt, u));
 
 	memset(mgmt, 0, 24);
 	memcpy(mgmt->da, peer, ETH_ALEN);
@@ -775,7 +775,7 @@ mwifiex_construct_tdls_action_frame(struct mwifiex_private *priv,
 			return ret;
 		}
 
-		pos = (void *)skb_put(skb, sizeof(struct ieee80211_ht_cap) + 2);
+		pos = skb_put(skb, sizeof(struct ieee80211_ht_cap) + 2);
 		*pos++ = WLAN_EID_HT_CAPABILITY;
 		*pos++ = sizeof(struct ieee80211_ht_cap);
 		ht_cap = (void *)pos;
diff --git a/drivers/net/wireless/quantenna/qtnfmac/qlink_util.h b/drivers/net/wireless/quantenna/qtnfmac/qlink_util.h
index 9844ff0add2b..f6ac39973b5d 100644
--- a/drivers/net/wireless/quantenna/qtnfmac/qlink_util.h
+++ b/drivers/net/wireless/quantenna/qtnfmac/qlink_util.h
@@ -26,7 +26,7 @@ static inline void qtnf_cmd_skb_put_action(struct sk_buff *skb, u16 action)
 {
 	__le16 *buf_ptr;
 
-	buf_ptr = (__le16 *)skb_put(skb, sizeof(action));
+	buf_ptr = skb_put(skb, sizeof(action));
 	*buf_ptr = cpu_to_le16(action);
 }
 
@@ -42,8 +42,7 @@ static inline void qtnf_cmd_skb_put_tlv_arr(struct sk_buff *skb,
 					    u16 tlv_id, const u8 arr[],
 					    size_t arr_len)
 {
-	struct qlink_tlv_hdr *hdr =
-			(void *)skb_put(skb, sizeof(*hdr) + arr_len);
+	struct qlink_tlv_hdr *hdr = skb_put(skb, sizeof(*hdr) + arr_len);
 
 	hdr->type = cpu_to_le16(tlv_id);
 	hdr->len = cpu_to_le16(arr_len);
@@ -53,8 +52,7 @@ static inline void qtnf_cmd_skb_put_tlv_arr(struct sk_buff *skb,
 static inline void qtnf_cmd_skb_put_tlv_u8(struct sk_buff *skb, u16 tlv_id,
 					   u8 value)
 {
-	struct qlink_tlv_hdr *hdr =
-			(void *)skb_put(skb, sizeof(*hdr) + sizeof(value));
+	struct qlink_tlv_hdr *hdr = skb_put(skb, sizeof(*hdr) + sizeof(value));
 
 	hdr->type = cpu_to_le16(tlv_id);
 	hdr->len = cpu_to_le16(sizeof(value));
@@ -64,8 +62,7 @@ static inline void qtnf_cmd_skb_put_tlv_u8(struct sk_buff *skb, u16 tlv_id,
 static inline void qtnf_cmd_skb_put_tlv_u16(struct sk_buff *skb,
 					    u16 tlv_id, u16 value)
 {
-	struct qlink_tlv_hdr *hdr =
-			(void *)skb_put(skb, sizeof(*hdr) + sizeof(value));
+	struct qlink_tlv_hdr *hdr = skb_put(skb, sizeof(*hdr) + sizeof(value));
 	__le16 tmp = cpu_to_le16(value);
 
 	hdr->type = cpu_to_le16(tlv_id);
diff --git a/drivers/net/wireless/ralink/rt2x00/rt2x00debug.c b/drivers/net/wireless/ralink/rt2x00/rt2x00debug.c
index b70985e126bf..51520a0e2138 100644
--- a/drivers/net/wireless/ralink/rt2x00/rt2x00debug.c
+++ b/drivers/net/wireless/ralink/rt2x00/rt2x00debug.c
@@ -188,7 +188,7 @@ void rt2x00debug_dump_frame(struct rt2x00_dev *rt2x00dev,
 		return;
 	}
 
-	dump_hdr = (struct rt2x00dump_hdr *)skb_put(skbcopy, sizeof(*dump_hdr));
+	dump_hdr = skb_put(skbcopy, sizeof(*dump_hdr));
 	dump_hdr->version = cpu_to_le32(DUMP_HEADER_VERSION);
 	dump_hdr->header_length = cpu_to_le32(sizeof(*dump_hdr));
 	dump_hdr->desc_length = cpu_to_le32(skbdesc->desc_len);
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8192se/fw.c b/drivers/net/wireless/realtek/rtlwifi/rtl8192se/fw.c
index dd3ba4810e7d..e7b1d7c0f542 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8192se/fw.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8192se/fw.c
@@ -462,7 +462,7 @@ static u32 _rtl92s_fill_h2c_cmd(struct sk_buff *skb, u32 h2cbufferlen,
 			break;
 
 		/* Clear content */
-		ph2c_buffer = (u8 *)skb_put(skb, (u32)len);
+		ph2c_buffer = skb_put(skb, (u32)len);
 		memset((ph2c_buffer + totallen + tx_desclen), 0, len);
 
 		/* CMD len */
diff --git a/drivers/nfc/fdp/i2c.c b/drivers/nfc/fdp/i2c.c
index 0877e2283f35..97f003e84381 100644
--- a/drivers/nfc/fdp/i2c.c
+++ b/drivers/nfc/fdp/i2c.c
@@ -86,7 +86,7 @@ static void fdp_nci_i2c_add_len_lrc(struct sk_buff *skb)
 	for (i = 0; i < len + 2; i++)
 		lrc ^= skb->data[i];
 
-	*skb_put(skb, 1) = lrc;
+	*(u8 *)skb_put(skb, 1) = lrc;
 }
 
 static void fdp_nci_i2c_remove_len_lrc(struct sk_buff *skb)
diff --git a/drivers/nfc/microread/i2c.c b/drivers/nfc/microread/i2c.c
index e0e8afd27849..8e328c36a816 100644
--- a/drivers/nfc/microread/i2c.c
+++ b/drivers/nfc/microread/i2c.c
@@ -75,7 +75,7 @@ static void microread_i2c_add_len_crc(struct sk_buff *skb)
 	for (i = 0; i < skb->len; i++)
 		crc = crc ^ skb->data[i];
 
-	*skb_put(skb, 1) = crc;
+	*(u8 *)skb_put(skb, 1) = crc;
 }
 
 static void microread_i2c_remove_len_crc(struct sk_buff *skb)
@@ -173,7 +173,7 @@ static int microread_i2c_read(struct microread_i2c_phy *phy,
 		goto flush;
 	}
 
-	*skb_put(*skb, 1) = len;
+	*(u8 *)skb_put(*skb, 1) = len;
 
 	r = i2c_master_recv(client, skb_put(*skb, len), len);
 	if (r != len) {
diff --git a/drivers/nfc/microread/microread.c b/drivers/nfc/microread/microread.c
index f454dc68cc03..9d0dd1be0923 100644
--- a/drivers/nfc/microread/microread.c
+++ b/drivers/nfc/microread/microread.c
@@ -441,8 +441,8 @@ static int microread_im_transceive(struct nfc_hci_dev *hdev,
 
 		crc = crc_ccitt(0xffff, skb->data, skb->len);
 		crc = ~crc;
-		*skb_put(skb, 1) = crc & 0xff;
-		*skb_put(skb, 1) = crc >> 8;
+		*(u8 *)skb_put(skb, 1) = crc & 0xff;
+		*(u8 *)skb_put(skb, 1) = crc >> 8;
 		break;
 	case MICROREAD_GATE_ID_MREAD_NFC_T3:
 		control_bits = 0xDB;
diff --git a/drivers/nfc/nfcmrvl/fw_dnld.c b/drivers/nfc/nfcmrvl/fw_dnld.c
index 7c710458568e..788599de9d8a 100644
--- a/drivers/nfc/nfcmrvl/fw_dnld.c
+++ b/drivers/nfc/nfcmrvl/fw_dnld.c
@@ -92,7 +92,7 @@ static struct sk_buff *alloc_lc_skb(struct nfcmrvl_private *priv, uint8_t plen)
 		return NULL;
 	}
 
-	hdr = (struct nci_data_hdr *) skb_put(skb, NCI_DATA_HDR_SIZE);
+	hdr = skb_put(skb, NCI_DATA_HDR_SIZE);
 	hdr->conn_id = NCI_CORE_LC_CONNID_PROP_FW_DL;
 	hdr->rfu = 0;
 	hdr->plen = plen;
@@ -292,7 +292,7 @@ static int process_state_fw_dnld(struct nfcmrvl_private *priv,
 			out_skb = alloc_lc_skb(priv, 1);
 			if (!out_skb)
 				return -ENOMEM;
-			*skb_put(out_skb, 1) = 0xBF;
+			*(u8 *)skb_put(out_skb, 1) = 0xBF;
 			nci_send_frame(priv->ndev, out_skb);
 			priv->fw_dnld.substate = SUBSTATE_WAIT_NACK_CREDIT;
 			return 0;
@@ -301,7 +301,7 @@ static int process_state_fw_dnld(struct nfcmrvl_private *priv,
 		out_skb = alloc_lc_skb(priv, 1);
 		if (!out_skb)
 			return -ENOMEM;
-		*skb_put(out_skb, 1) = HELPER_ACK_PACKET_FORMAT;
+		*(u8 *)skb_put(out_skb, 1) = HELPER_ACK_PACKET_FORMAT;
 		nci_send_frame(priv->ndev, out_skb);
 		priv->fw_dnld.substate = SUBSTATE_WAIT_ACK_CREDIT;
 		break;
diff --git a/drivers/nfc/pn533/pn533.c b/drivers/nfc/pn533/pn533.c
index 9200bb308e42..68a3cd0287f6 100644
--- a/drivers/nfc/pn533/pn533.c
+++ b/drivers/nfc/pn533/pn533.c
@@ -1032,7 +1032,7 @@ static struct sk_buff *pn533_alloc_poll_tg_frame(struct pn533 *dev)
 		return NULL;
 
 	/* DEP support only */
-	*skb_put(skb, 1) = PN533_INIT_TARGET_DEP;
+	*(u8 *)skb_put(skb, 1) = PN533_INIT_TARGET_DEP;
 
 	/* MIFARE params */
 	skb_put_data(skb, mifare_params, 6);
@@ -1046,12 +1046,12 @@ static struct sk_buff *pn533_alloc_poll_tg_frame(struct pn533 *dev)
 	memcpy(nfcid3, felica, 8);
 
 	/* General bytes */
-	*skb_put(skb, 1) = gbytes_len;
+	*(u8 *)skb_put(skb, 1) = gbytes_len;
 
 	gb = skb_put_data(skb, gbytes, gbytes_len);
 
 	/* Len Tk */
-	*skb_put(skb, 1) = 0;
+	*(u8 *)skb_put(skb, 1) = 0;
 
 	return skb;
 }
@@ -1280,8 +1280,8 @@ static void pn533_wq_rf(struct work_struct *work)
 	if (!skb)
 		return;
 
-	*skb_put(skb, 1) = PN533_CFGITEM_RF_FIELD;
-	*skb_put(skb, 1) = PN533_CFGITEM_RF_FIELD_AUTO_RFCA;
+	*(u8 *)skb_put(skb, 1) = PN533_CFGITEM_RF_FIELD;
+	*(u8 *)skb_put(skb, 1) = PN533_CFGITEM_RF_FIELD_AUTO_RFCA;
 
 	rc = pn533_send_cmd_async(dev, PN533_CMD_RF_CONFIGURATION, skb,
 				  pn533_rf_complete, NULL);
@@ -1375,8 +1375,8 @@ static int pn533_poll_dep(struct nfc_dev *nfc_dev)
 	if (!skb)
 		return -ENOMEM;
 
-	*skb_put(skb, 1) = 0x01;  /* Active */
-	*skb_put(skb, 1) = 0x02;  /* 424 kbps */
+	*(u8 *)skb_put(skb, 1) = 0x01;  /* Active */
+	*(u8 *)skb_put(skb, 1) = 0x02;  /* 424 kbps */
 
 	next = skb_put(skb, 1);  /* Next */
 	*next = 0;
@@ -1620,8 +1620,8 @@ static int pn533_activate_target_nfcdep(struct pn533 *dev)
 	if (!skb)
 		return -ENOMEM;
 
-	*skb_put(skb, sizeof(u8)) = 1; /* TG */
-	*skb_put(skb, sizeof(u8)) = 0; /* Next */
+	*(u8 *)skb_put(skb, sizeof(u8)) = 1; /* TG */
+	*(u8 *)skb_put(skb, sizeof(u8)) = 0; /* Next */
 
 	resp = pn533_send_cmd_sync(dev, PN533_CMD_IN_ATR, skb);
 	if (IS_ERR(resp))
@@ -1737,7 +1737,7 @@ static void pn533_deactivate_target(struct nfc_dev *nfc_dev,
 	if (!skb)
 		return;
 
-	*skb_put(skb, 1) = 1; /* TG*/
+	*(u8 *)skb_put(skb, 1) = 1; /* TG*/
 
 	rc = pn533_send_cmd_async(dev, PN533_CMD_IN_RELEASE, skb,
 				  pn533_deactivate_target_complete, NULL);
@@ -1848,8 +1848,8 @@ static int pn533_dep_link_up(struct nfc_dev *nfc_dev, struct nfc_target *target,
 	if (!skb)
 		return -ENOMEM;
 
-	*skb_put(skb, 1) = !comm_mode;  /* ActPass */
-	*skb_put(skb, 1) = 0x02;  /* 424 kbps */
+	*(u8 *)skb_put(skb, 1) = !comm_mode;  /* ActPass */
+	*(u8 *)skb_put(skb, 1) = 0x02;  /* 424 kbps */
 
 	next = skb_put(skb, 1);  /* Next */
 	*next = 0;
@@ -2274,7 +2274,7 @@ static void pn533_wq_mi_recv(struct work_struct *work)
 			break;
 		}
 	default:
-		*skb_put(skb, sizeof(u8)) =  1; /*TG*/
+		*(u8 *)skb_put(skb, sizeof(u8)) =  1; /*TG*/
 
 		rc = pn533_send_cmd_direct_async(dev,
 						 PN533_CMD_IN_DATA_EXCHANGE,
@@ -2370,7 +2370,7 @@ static int pn533_set_configuration(struct pn533 *dev, u8 cfgitem, u8 *cfgdata,
 	if (!skb)
 		return -ENOMEM;
 
-	*skb_put(skb, sizeof(cfgitem)) = cfgitem;
+	*(u8 *)skb_put(skb, sizeof(cfgitem)) = cfgitem;
 	skb_put_data(skb, cfgdata, cfgdata_len);
 
 	resp = pn533_send_cmd_sync(dev, PN533_CMD_RF_CONFIGURATION, skb);
@@ -2415,7 +2415,7 @@ static int pn533_pasori_fw_reset(struct pn533 *dev)
 	if (!skb)
 		return -ENOMEM;
 
-	*skb_put(skb, sizeof(u8)) = 0x1;
+	*(u8 *)skb_put(skb, sizeof(u8)) = 0x1;
 
 	resp = pn533_send_cmd_sync(dev, 0x18, skb);
 	if (IS_ERR(resp))
@@ -2454,7 +2454,7 @@ static int pn532_sam_configuration(struct nfc_dev *nfc_dev)
 	if (!skb)
 		return -ENOMEM;
 
-	*skb_put(skb, 1) = 0x01;
+	*(u8 *)skb_put(skb, 1) = 0x01;
 
 	resp = pn533_send_cmd_sync(dev, PN533_CMD_SAM_CONFIGURATION, skb);
 	if (IS_ERR(resp))
diff --git a/drivers/nfc/pn544/i2c.c b/drivers/nfc/pn544/i2c.c
index 71ac0836c9f4..dc1e3768cee6 100644
--- a/drivers/nfc/pn544/i2c.c
+++ b/drivers/nfc/pn544/i2c.c
@@ -287,8 +287,8 @@ static void pn544_hci_i2c_add_len_crc(struct sk_buff *skb)
 
 	crc = crc_ccitt(0xffff, skb->data, skb->len);
 	crc = ~crc;
-	*skb_put(skb, 1) = crc & 0xff;
-	*skb_put(skb, 1) = crc >> 8;
+	*(u8 *)skb_put(skb, 1) = crc & 0xff;
+	*(u8 *)skb_put(skb, 1) = crc >> 8;
 }
 
 static void pn544_hci_i2c_remove_len_crc(struct sk_buff *skb)
@@ -391,7 +391,7 @@ static int pn544_hci_i2c_read(struct pn544_i2c_phy *phy, struct sk_buff **skb)
 		goto flush;
 	}
 
-	*skb_put(*skb, 1) = len;
+	*(u8 *)skb_put(*skb, 1) = len;
 
 	r = i2c_master_recv(client, skb_put(*skb, len), len);
 	if (r != len) {
diff --git a/drivers/nfc/port100.c b/drivers/nfc/port100.c
index e1260da73d45..5fa3cf0fabd6 100644
--- a/drivers/nfc/port100.c
+++ b/drivers/nfc/port100.c
@@ -991,7 +991,7 @@ static int port100_set_command_type(struct port100 *dev, u8 command_type)
 	if (!skb)
 		return -ENOMEM;
 
-	*skb_put(skb, sizeof(u8)) = command_type;
+	*(u8 *)skb_put(skb, sizeof(u8)) = command_type;
 
 	resp = port100_send_cmd_sync(dev, PORT100_CMD_SET_COMMAND_TYPE, skb);
 	if (IS_ERR(resp))
@@ -1059,7 +1059,7 @@ static int port100_switch_rf(struct nfc_digital_dev *ddev, bool on)
 	if (!skb)
 		return -ENOMEM;
 
-	*skb_put(skb, 1) = on ? 1 : 0;
+	*(u8 *)skb_put(skb, 1) = on ? 1 : 0;
 
 	/* Cancel the last command if the device is being switched off */
 	if (!on)
diff --git a/drivers/nfc/st21nfca/i2c.c b/drivers/nfc/st21nfca/i2c.c
index 94d0b913b627..c36f0e0afdfd 100644
--- a/drivers/nfc/st21nfca/i2c.c
+++ b/drivers/nfc/st21nfca/i2c.c
@@ -177,10 +177,10 @@ static void st21nfca_hci_add_len_crc(struct sk_buff *skb)
 	crc = ~crc;
 
 	tmp = crc & 0x00ff;
-	*skb_put(skb, 1) = tmp;
+	*(u8 *)skb_put(skb, 1) = tmp;
 
 	tmp = (crc >> 8) & 0x00ff;
-	*skb_put(skb, 1) = tmp;
+	*(u8 *)skb_put(skb, 1) = tmp;
 }
 
 static void st21nfca_hci_remove_len_crc(struct sk_buff *skb)
@@ -214,7 +214,7 @@ static int st21nfca_hci_i2c_write(void *phy_id, struct sk_buff *skb)
 	st21nfca_hci_add_len_crc(skb);
 
 	/* add ST21NFCA_SOF_EOF on tail */
-	*skb_put(skb, 1) = ST21NFCA_SOF_EOF;
+	*(u8 *)skb_put(skb, 1) = ST21NFCA_SOF_EOF;
 	/* add ST21NFCA_SOF_EOF on head */
 	*skb_push(skb, 1) = ST21NFCA_SOF_EOF;
 
diff --git a/drivers/nfc/st95hf/core.c b/drivers/nfc/st95hf/core.c
index c2840e412962..168adcc46cb8 100644
--- a/drivers/nfc/st95hf/core.c
+++ b/drivers/nfc/st95hf/core.c
@@ -949,7 +949,7 @@ static int st95hf_in_send_cmd(struct nfc_digital_dev *ddev,
 	switch (stcontext->current_rf_tech) {
 	case NFC_DIGITAL_RF_TECH_106A:
 		len_data_to_tag = skb->len + 1;
-		*skb_put(skb, 1) = stcontext->sendrcv_trflag;
+		*(u8 *)skb_put(skb, 1) = stcontext->sendrcv_trflag;
 		break;
 	case NFC_DIGITAL_RF_TECH_106B:
 	case NFC_DIGITAL_RF_TECH_ISO15693:
diff --git a/drivers/scsi/bnx2fc/bnx2fc_fcoe.c b/drivers/scsi/bnx2fc/bnx2fc_fcoe.c
index 902722dc4ce3..b025ee5da1ba 100644
--- a/drivers/scsi/bnx2fc/bnx2fc_fcoe.c
+++ b/drivers/scsi/bnx2fc/bnx2fc_fcoe.c
@@ -351,7 +351,7 @@ static int bnx2fc_xmit(struct fc_lport *lport, struct fc_frame *fp)
 		frag = &skb_shinfo(skb)->frags[skb_shinfo(skb)->nr_frags - 1];
 		cp = kmap_atomic(skb_frag_page(frag)) + frag->page_offset;
 	} else {
-		cp = (struct fcoe_crc_eof *)skb_put(skb, tlen);
+		cp = skb_put(skb, tlen);
 	}
 
 	memset(cp, 0, sizeof(*cp));
diff --git a/drivers/scsi/fcoe/fcoe.c b/drivers/scsi/fcoe/fcoe.c
index 90939f66bc0d..539e23ec0e59 100644
--- a/drivers/scsi/fcoe/fcoe.c
+++ b/drivers/scsi/fcoe/fcoe.c
@@ -1543,7 +1543,7 @@ static int fcoe_xmit(struct fc_lport *lport, struct fc_frame *fp)
 		cp = kmap_atomic(skb_frag_page(frag))
 			+ frag->page_offset;
 	} else {
-		cp = (struct fcoe_crc_eof *)skb_put(skb, tlen);
+		cp = skb_put(skb, tlen);
 	}
 
 	memset(cp, 0, sizeof(*cp));
diff --git a/drivers/scsi/qedf/qedf_main.c b/drivers/scsi/qedf/qedf_main.c
index b97405ed6cae..da0fcce6f842 100644
--- a/drivers/scsi/qedf/qedf_main.c
+++ b/drivers/scsi/qedf/qedf_main.c
@@ -874,7 +874,7 @@ static int qedf_xmit(struct fc_lport *lport, struct fc_frame *fp)
 		frag = &skb_shinfo(skb)->frags[skb_shinfo(skb)->nr_frags - 1];
 		cp = kmap_atomic(skb_frag_page(frag)) + frag->page_offset;
 	} else {
-		cp = (struct fcoe_crc_eof *)skb_put(skb, tlen);
+		cp = skb_put(skb, tlen);
 	}
 
 	memset(cp, 0, sizeof(*cp));
diff --git a/drivers/staging/rtl8192e/rtl819x_BAProc.c b/drivers/staging/rtl8192e/rtl819x_BAProc.c
index 1d3963136295..1720e1b6ae04 100644
--- a/drivers/staging/rtl8192e/rtl819x_BAProc.c
+++ b/drivers/staging/rtl8192e/rtl819x_BAProc.c
@@ -95,8 +95,7 @@ static struct sk_buff *rtllib_ADDBA(struct rtllib_device *ieee, u8 *Dst,
 
 	skb_reserve(skb, ieee->tx_headroom);
 
-	BAReq = (struct rtllib_hdr_3addr *)skb_put(skb,
-		 sizeof(struct rtllib_hdr_3addr));
+	BAReq = skb_put(skb, sizeof(struct rtllib_hdr_3addr));
 
 	ether_addr_copy(BAReq->addr1, Dst);
 	ether_addr_copy(BAReq->addr2, ieee->dev->dev_addr);
@@ -104,7 +103,7 @@ static struct sk_buff *rtllib_ADDBA(struct rtllib_device *ieee, u8 *Dst,
 	ether_addr_copy(BAReq->addr3, ieee->current_network.bssid);
 	BAReq->frame_ctl = cpu_to_le16(RTLLIB_STYPE_MANAGE_ACT);
 
-	tag = (u8 *)skb_put(skb, 9);
+	tag = skb_put(skb, 9);
 	*tag++ = ACT_CAT_BA;
 	*tag++ = type;
 	*tag++ = pBA->DialogToken;
@@ -159,15 +158,14 @@ static struct sk_buff *rtllib_DELBA(struct rtllib_device *ieee, u8 *dst,
 
 	skb_reserve(skb, ieee->tx_headroom);
 
-	Delba = (struct rtllib_hdr_3addr *) skb_put(skb,
-		 sizeof(struct rtllib_hdr_3addr));
+	Delba = skb_put(skb, sizeof(struct rtllib_hdr_3addr));
 
 	ether_addr_copy(Delba->addr1, dst);
 	ether_addr_copy(Delba->addr2, ieee->dev->dev_addr);
 	ether_addr_copy(Delba->addr3, ieee->current_network.bssid);
 	Delba->frame_ctl = cpu_to_le16(RTLLIB_STYPE_MANAGE_ACT);
 
-	tag = (u8 *)skb_put(skb, 6);
+	tag = skb_put(skb, 6);
 
 	*tag++ = ACT_CAT_BA;
 	*tag++ = ACT_DELBA;
diff --git a/drivers/staging/rtl8192e/rtllib_softmac.c b/drivers/staging/rtl8192e/rtllib_softmac.c
index 60d07d0bb4eb..5f2751d4d464 100644
--- a/drivers/staging/rtl8192e/rtllib_softmac.c
+++ b/drivers/staging/rtl8192e/rtllib_softmac.c
@@ -351,8 +351,7 @@ static inline struct sk_buff *rtllib_probe_req(struct rtllib_device *ieee)
 
 	skb_reserve(skb, ieee->tx_headroom);
 
-	req = (struct rtllib_probe_request *) skb_put(skb,
-	      sizeof(struct rtllib_probe_request));
+	req = skb_put(skb, sizeof(struct rtllib_probe_request));
 	req->header.frame_ctl = cpu_to_le16(RTLLIB_STYPE_PROBE_REQ);
 	req->header.duration_id = 0;
 
@@ -360,7 +359,7 @@ static inline struct sk_buff *rtllib_probe_req(struct rtllib_device *ieee)
 	ether_addr_copy(req->header.addr2, ieee->dev->dev_addr);
 	eth_broadcast_addr(req->header.addr3);
 
-	tag = (u8 *) skb_put(skb, len + 2 + rate_len);
+	tag = skb_put(skb, len + 2 + rate_len);
 
 	*tag++ = MFIE_TYPE_SSID;
 	*tag++ = len;
@@ -789,8 +788,7 @@ rtllib_authentication_req(struct rtllib_network *beacon,
 
 	skb_reserve(skb, ieee->tx_headroom);
 
-	auth = (struct rtllib_authentication *)
-		skb_put(skb, sizeof(struct rtllib_authentication));
+	auth = skb_put(skb, sizeof(struct rtllib_authentication));
 
 	auth->header.frame_ctl = cpu_to_le16(RTLLIB_STYPE_AUTH);
 	if (challengelen)
@@ -889,8 +887,7 @@ static struct sk_buff *rtllib_probe_resp(struct rtllib_device *ieee,
 
 	skb_reserve(skb, ieee->tx_headroom);
 
-	beacon_buf = (struct rtllib_probe_response *) skb_put(skb,
-		     (beacon_size - ieee->tx_headroom));
+	beacon_buf = skb_put(skb, (beacon_size - ieee->tx_headroom));
 	ether_addr_copy(beacon_buf->header.addr1, dest);
 	ether_addr_copy(beacon_buf->header.addr2, ieee->dev->dev_addr);
 	ether_addr_copy(beacon_buf->header.addr3, ieee->current_network.bssid);
@@ -984,8 +981,7 @@ static struct sk_buff *rtllib_assoc_resp(struct rtllib_device *ieee, u8 *dest)
 
 	skb_reserve(skb, ieee->tx_headroom);
 
-	assoc = (struct rtllib_assoc_response_frame *)
-		skb_put(skb, sizeof(struct rtllib_assoc_response_frame));
+	assoc = skb_put(skb, sizeof(struct rtllib_assoc_response_frame));
 
 	assoc->header.frame_ctl = cpu_to_le16(RTLLIB_STYPE_ASSOC_RESP);
 	ether_addr_copy(assoc->header.addr1, dest);
@@ -1016,7 +1012,7 @@ static struct sk_buff *rtllib_assoc_resp(struct rtllib_device *ieee, u8 *dest)
 	else
 		ieee->assoc_id++;
 
-	tag = (u8 *) skb_put(skb, rate_len);
+	tag = skb_put(skb, rate_len);
 	rtllib_MFIE_Brate(ieee, &tag);
 	rtllib_MFIE_Grate(ieee, &tag);
 
@@ -1038,8 +1034,7 @@ static struct sk_buff *rtllib_auth_resp(struct rtllib_device *ieee, int status,
 
 	skb_reserve(skb, ieee->tx_headroom);
 
-	auth = (struct rtllib_authentication *)
-		skb_put(skb, sizeof(struct rtllib_authentication));
+	auth = skb_put(skb, sizeof(struct rtllib_authentication));
 
 	auth->status = cpu_to_le16(status);
 	auth->transaction = cpu_to_le16(2);
@@ -1065,8 +1060,7 @@ static struct sk_buff *rtllib_null_func(struct rtllib_device *ieee, short pwr)
 
 	skb_reserve(skb, ieee->tx_headroom);
 
-	hdr = (struct rtllib_hdr_3addr *)skb_put(skb,
-	      sizeof(struct rtllib_hdr_3addr));
+	hdr = skb_put(skb, sizeof(struct rtllib_hdr_3addr));
 
 	ether_addr_copy(hdr->addr1, ieee->current_network.bssid);
 	ether_addr_copy(hdr->addr2, ieee->dev->dev_addr);
@@ -1092,8 +1086,7 @@ static struct sk_buff *rtllib_pspoll_func(struct rtllib_device *ieee)
 
 	skb_reserve(skb, ieee->tx_headroom);
 
-	hdr = (struct rtllib_pspoll_hdr *)skb_put(skb,
-	      sizeof(struct rtllib_pspoll_hdr));
+	hdr = skb_put(skb, sizeof(struct rtllib_pspoll_hdr));
 
 	ether_addr_copy(hdr->bssid, ieee->current_network.bssid);
 	ether_addr_copy(hdr->ta, ieee->dev->dev_addr);
@@ -1243,8 +1236,7 @@ rtllib_association_req(struct rtllib_network *beacon,
 
 	skb_reserve(skb, ieee->tx_headroom);
 
-	hdr = (struct rtllib_assoc_request_frame *)
-		skb_put(skb, sizeof(struct rtllib_assoc_request_frame) + 2);
+	hdr = skb_put(skb, sizeof(struct rtllib_assoc_request_frame) + 2);
 
 
 	hdr->header.frame_ctl = cpu_to_le16(RTLLIB_STYPE_ASSOC_REQ);
@@ -3414,8 +3406,7 @@ rtllib_disauth_skb(struct rtllib_network *beacon,
 
 	skb_reserve(skb, ieee->tx_headroom);
 
-	disauth = (struct rtllib_disauth *) skb_put(skb,
-		  sizeof(struct rtllib_disauth));
+	disauth = skb_put(skb, sizeof(struct rtllib_disauth));
 	disauth->header.frame_ctl = cpu_to_le16(RTLLIB_STYPE_DEAUTH);
 	disauth->header.duration_id = 0;
 
@@ -3442,8 +3433,7 @@ rtllib_disassociate_skb(struct rtllib_network *beacon,
 
 	skb_reserve(skb, ieee->tx_headroom);
 
-	disass = (struct rtllib_disassoc *) skb_put(skb,
-					 sizeof(struct rtllib_disassoc));
+	disass = skb_put(skb, sizeof(struct rtllib_disassoc));
 	disass->header.frame_ctl = cpu_to_le16(RTLLIB_STYPE_DISASSOC);
 	disass->header.duration_id = 0;
 
diff --git a/drivers/staging/rtl8192u/ieee80211/ieee80211_softmac.c b/drivers/staging/rtl8192u/ieee80211/ieee80211_softmac.c
index 903a1d0269df..107069180ed2 100644
--- a/drivers/staging/rtl8192u/ieee80211/ieee80211_softmac.c
+++ b/drivers/staging/rtl8192u/ieee80211/ieee80211_softmac.c
@@ -341,7 +341,7 @@ static inline struct sk_buff *ieee80211_probe_req(struct ieee80211_device *ieee)
 
 	skb_reserve(skb, ieee->tx_headroom);
 
-	req = (struct ieee80211_probe_request *) skb_put(skb,sizeof(struct ieee80211_probe_request));
+	req = skb_put(skb, sizeof(struct ieee80211_probe_request));
 	req->header.frame_ctl = cpu_to_le16(IEEE80211_STYPE_PROBE_REQ);
 	req->header.duration_id = 0; /* FIXME: is this OK? */
 
@@ -349,7 +349,7 @@ static inline struct sk_buff *ieee80211_probe_req(struct ieee80211_device *ieee)
 	memcpy(req->header.addr2, ieee->dev->dev_addr, ETH_ALEN);
 	eth_broadcast_addr(req->header.addr3);
 
-	tag = (u8 *) skb_put(skb,len+2+rate_len);
+	tag = skb_put(skb, len + 2 + rate_len);
 
 	*tag++ = MFIE_TYPE_SSID;
 	*tag++ = len;
@@ -659,8 +659,7 @@ ieee80211_authentication_req(struct ieee80211_network *beacon,
 	if (!skb) return NULL;
 
 	skb_reserve(skb, ieee->tx_headroom);
-	auth = (struct ieee80211_authentication *)
-		skb_put(skb, sizeof(struct ieee80211_authentication));
+	auth = skb_put(skb, sizeof(struct ieee80211_authentication));
 
 	if (challengelen)
 		auth->header.frame_ctl = cpu_to_le16(IEEE80211_STYPE_AUTH
@@ -768,7 +767,7 @@ static struct sk_buff *ieee80211_probe_resp(struct ieee80211_device *ieee, u8 *d
 	if (!skb)
 		return NULL;
 	skb_reserve(skb, ieee->tx_headroom);
-	beacon_buf = (struct ieee80211_probe_response *) skb_put(skb, (beacon_size - ieee->tx_headroom));
+	beacon_buf = skb_put(skb, (beacon_size - ieee->tx_headroom));
 	memcpy (beacon_buf->header.addr1, dest,ETH_ALEN);
 	memcpy (beacon_buf->header.addr2, ieee->dev->dev_addr, ETH_ALEN);
 	memcpy (beacon_buf->header.addr3, ieee->current_network.bssid, ETH_ALEN);
@@ -864,8 +863,7 @@ static struct sk_buff *ieee80211_assoc_resp(struct ieee80211_device *ieee,
 
 	skb_reserve(skb, ieee->tx_headroom);
 
-	assoc = (struct ieee80211_assoc_response_frame *)
-		skb_put(skb, sizeof(struct ieee80211_assoc_response_frame));
+	assoc = skb_put(skb, sizeof(struct ieee80211_assoc_response_frame));
 
 	assoc->header.frame_ctl = cpu_to_le16(IEEE80211_STYPE_ASSOC_RESP);
 	memcpy(assoc->header.addr1, dest,ETH_ALEN);
@@ -892,7 +890,7 @@ static struct sk_buff *ieee80211_assoc_resp(struct ieee80211_device *ieee,
 	if (ieee->assoc_id == 0x2007) ieee->assoc_id=0;
 	else ieee->assoc_id++;
 
-	tag = (u8 *) skb_put(skb, rate_len);
+	tag = skb_put(skb, rate_len);
 
 	ieee80211_MFIE_Brate(ieee, &tag);
 	ieee80211_MFIE_Grate(ieee, &tag);
@@ -940,7 +938,7 @@ static struct sk_buff *ieee80211_null_func(struct ieee80211_device *ieee,
 	if (!skb)
 		return NULL;
 
-	hdr = (struct rtl_80211_hdr_3addr *)skb_put(skb,sizeof(struct rtl_80211_hdr_3addr));
+	hdr = skb_put(skb, sizeof(struct rtl_80211_hdr_3addr));
 
 	memcpy(hdr->addr1, ieee->current_network.bssid, ETH_ALEN);
 	memcpy(hdr->addr2, ieee->dev->dev_addr, ETH_ALEN);
@@ -1086,8 +1084,7 @@ ieee80211_association_req(struct ieee80211_network *beacon,
 
 	skb_reserve(skb, ieee->tx_headroom);
 
-	hdr = (struct ieee80211_assoc_request_frame *)
-		skb_put(skb, sizeof(struct ieee80211_assoc_request_frame)+2);
+	hdr = skb_put(skb, sizeof(struct ieee80211_assoc_request_frame) + 2);
 
 
 	hdr->header.frame_ctl = IEEE80211_STYPE_ASSOC_REQ;
@@ -3110,7 +3107,7 @@ static inline struct sk_buff *ieee80211_disassociate_skb(
 	if (!skb)
 		return NULL;
 
-	disass = (struct ieee80211_disassoc *) skb_put(skb, sizeof(struct ieee80211_disassoc));
+	disass = skb_put(skb, sizeof(struct ieee80211_disassoc));
 	disass->header.frame_ctl = cpu_to_le16(IEEE80211_STYPE_DISASSOC);
 	disass->header.duration_id = 0;
 
diff --git a/drivers/staging/rtl8192u/ieee80211/rtl819x_BAProc.c b/drivers/staging/rtl8192u/ieee80211/rtl819x_BAProc.c
index e82b5073c3f1..8aa38dcf0dfd 100644
--- a/drivers/staging/rtl8192u/ieee80211/rtl819x_BAProc.c
+++ b/drivers/staging/rtl8192u/ieee80211/rtl819x_BAProc.c
@@ -125,7 +125,7 @@ static struct sk_buff *ieee80211_ADDBA(struct ieee80211_device *ieee, u8 *Dst, P
 	memset(skb->data, 0, sizeof( struct rtl_80211_hdr_3addr));	//I wonder whether it's necessary. Apparently kernel will not do it when alloc a skb.
 	skb_reserve(skb, ieee->tx_headroom);
 
-	BAReq = ( struct rtl_80211_hdr_3addr *) skb_put(skb,sizeof( struct rtl_80211_hdr_3addr));
+	BAReq = skb_put(skb, sizeof(struct rtl_80211_hdr_3addr));
 
 	memcpy(BAReq->addr1, Dst, ETH_ALEN);
 	memcpy(BAReq->addr2, ieee->dev->dev_addr, ETH_ALEN);
@@ -135,7 +135,7 @@ static struct sk_buff *ieee80211_ADDBA(struct ieee80211_device *ieee, u8 *Dst, P
 	BAReq->frame_ctl = cpu_to_le16(IEEE80211_STYPE_MANAGE_ACT); //action frame
 
 	//tag += sizeof( struct rtl_80211_hdr_3addr); //move to action field
-	tag = (u8 *)skb_put(skb, 9);
+	tag = skb_put(skb, 9);
 	*tag ++= ACT_CAT_BA;
 	*tag ++= type;
 	// Dialog Token
@@ -209,14 +209,14 @@ static struct sk_buff *ieee80211_DELBA(
 //	memset(skb->data, 0, len+sizeof( struct rtl_80211_hdr_3addr));
 	skb_reserve(skb, ieee->tx_headroom);
 
-	Delba = ( struct rtl_80211_hdr_3addr *) skb_put(skb,sizeof( struct rtl_80211_hdr_3addr));
+	Delba = skb_put(skb, sizeof(struct rtl_80211_hdr_3addr));
 
 	memcpy(Delba->addr1, dst, ETH_ALEN);
 	memcpy(Delba->addr2, ieee->dev->dev_addr, ETH_ALEN);
 	memcpy(Delba->addr3, ieee->current_network.bssid, ETH_ALEN);
 	Delba->frame_ctl = cpu_to_le16(IEEE80211_STYPE_MANAGE_ACT); //action frame
 
-	tag = (u8 *)skb_put(skb, 6);
+	tag = skb_put(skb, 6);
 
 	*tag ++= ACT_CAT_BA;
 	*tag ++= ACT_DELBA;
diff --git a/drivers/target/iscsi/cxgbit/cxgbit_cm.c b/drivers/target/iscsi/cxgbit/cxgbit_cm.c
index 939c6ec51e4d..15cd1e33b16b 100644
--- a/drivers/target/iscsi/cxgbit/cxgbit_cm.c
+++ b/drivers/target/iscsi/cxgbit/cxgbit_cm.c
@@ -1085,7 +1085,7 @@ cxgbit_pass_accept_rpl(struct cxgbit_sock *csk, struct cpl_pass_accept_req *req)
 		return;
 	}
 
-	rpl5 = (struct cpl_t5_pass_accept_rpl *)__skb_put(skb, len);
+	rpl5 = __skb_put(skb, len);
 	memset(rpl5, 0, len);
 
 	INIT_TP_WR(rpl5, csk->tid);
@@ -1367,7 +1367,7 @@ u32 cxgbit_send_tx_flowc_wr(struct cxgbit_sock *csk)
 	flowclen16 = cxgbit_tx_flowc_wr_credits(csk, &nparams, &flowclen);
 
 	skb = __skb_dequeue(&csk->skbq);
-	flowc = (struct fw_flowc_wr *)__skb_put(skb, flowclen);
+	flowc = __skb_put(skb, flowclen);
 	memset(flowc, 0, flowclen);
 
 	flowc->op_to_nparams = cpu_to_be32(FW_WR_OP_V(FW_FLOWC_WR) |
@@ -1439,7 +1439,7 @@ int cxgbit_setup_conn_digest(struct cxgbit_sock *csk)
 		return -ENOMEM;
 
 	/*  set up ulp submode */
-	req = (struct cpl_set_tcb_field *)__skb_put(skb, len);
+	req = __skb_put(skb, len);
 	memset(req, 0, len);
 
 	INIT_TP_WR(req, csk->tid);
@@ -1476,7 +1476,7 @@ int cxgbit_setup_conn_pgidx(struct cxgbit_sock *csk, u32 pg_idx)
 	if (!skb)
 		return -ENOMEM;
 
-	req = (struct cpl_set_tcb_field *)__skb_put(skb, len);
+	req = __skb_put(skb, len);
 	memset(req, 0, len);
 
 	INIT_TP_WR(req, csk->tid);
diff --git a/drivers/target/iscsi/cxgbit/cxgbit_ddp.c b/drivers/target/iscsi/cxgbit/cxgbit_ddp.c
index 5d78bdb7fc64..5fdb57cac968 100644
--- a/drivers/target/iscsi/cxgbit/cxgbit_ddp.c
+++ b/drivers/target/iscsi/cxgbit/cxgbit_ddp.c
@@ -79,7 +79,7 @@ cxgbit_ppod_init_idata(struct cxgbit_device *cdev, struct cxgbi_ppm *ppm,
 	if (!skb)
 		return NULL;
 
-	req = (struct ulp_mem_io *)__skb_put(skb, wr_len);
+	req = __skb_put(skb, wr_len);
 	INIT_ULPTX_WR(req, wr_len, 0, tid);
 	req->wr.wr_hi = htonl(FW_WR_OP_V(FW_ULPTX_WR) |
 		FW_WR_ATOMIC_V(0));
diff --git a/drivers/usb/gadget/function/f_ncm.c b/drivers/usb/gadget/function/f_ncm.c
index 630616aaa861..a9c28c72c1c7 100644
--- a/drivers/usb/gadget/function/f_ncm.c
+++ b/drivers/usb/gadget/function/f_ncm.c
@@ -1047,7 +1047,7 @@ static struct sk_buff *ncm_wrap_ntb(struct gether *port,
 			crc = ~crc32_le(~0,
 					skb->data,
 					skb->len);
-			crc_pos = (void *) skb_put(skb, sizeof(uint32_t));
+			crc_pos = skb_put(skb, sizeof(uint32_t));
 			put_unaligned_le32(crc, crc_pos);
 		}
 
@@ -1097,8 +1097,7 @@ static struct sk_buff *ncm_wrap_ntb(struct gether *port,
 				goto err;
 
 			ncm->skb_tx_ndp->dev = ncm->netdev;
-			ntb_ndp = (void *) skb_put(ncm->skb_tx_ndp,
-						    opts->ndp_size);
+			ntb_ndp = skb_put(ncm->skb_tx_ndp, opts->ndp_size);
 			memset(ntb_ndp, 0, ncb_len);
 			/* dwSignature */
 			put_unaligned_le32(ncm->ndp_sign, ntb_ndp);
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 5af5385a0e72..454ea37dddbb 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1893,11 +1893,11 @@ static inline void skb_set_tail_pointer(struct sk_buff *skb, const int offset)
 /*
  *	Add data to an sk_buff
  */
-unsigned char *pskb_put(struct sk_buff *skb, struct sk_buff *tail, int len);
-unsigned char *skb_put(struct sk_buff *skb, unsigned int len);
-static inline unsigned char *__skb_put(struct sk_buff *skb, unsigned int len)
+void *pskb_put(struct sk_buff *skb, struct sk_buff *tail, int len);
+void *skb_put(struct sk_buff *skb, unsigned int len);
+static inline void *__skb_put(struct sk_buff *skb, unsigned int len)
 {
-	unsigned char *tmp = skb_tail_pointer(skb);
+	void *tmp = skb_tail_pointer(skb);
 	SKB_LINEAR_ASSERT(skb);
 	skb->tail += len;
 	skb->len  += len;
diff --git a/lib/nlattr.c b/lib/nlattr.c
index ab15a6c095d3..a0c738aa6a79 100644
--- a/lib/nlattr.c
+++ b/lib/nlattr.c
@@ -352,7 +352,7 @@ struct nlattr *__nla_reserve(struct sk_buff *skb, int attrtype, int attrlen)
 {
 	struct nlattr *nla;
 
-	nla = (struct nlattr *) skb_put(skb, nla_total_size(attrlen));
+	nla = skb_put(skb, nla_total_size(attrlen));
 	nla->nla_type = attrtype;
 	nla->nla_len = nla_attr_size(attrlen);
 
diff --git a/net/802/garp.c b/net/802/garp.c
index b38ee6dcba45..a9a266569293 100644
--- a/net/802/garp.c
+++ b/net/802/garp.c
@@ -221,7 +221,7 @@ static int garp_pdu_init(struct garp_applicant *app)
 	skb->protocol = htons(ETH_P_802_2);
 	skb_reserve(skb, LL_RESERVED_SPACE(app->dev) + LLC_RESERVE);
 
-	gp = (struct garp_pdu_hdr *)__skb_put(skb, sizeof(*gp));
+	gp = __skb_put(skb, sizeof(*gp));
 	put_unaligned(htons(GARP_PROTOCOL_ID), &gp->protocol);
 
 	app->pdu = skb;
@@ -268,7 +268,7 @@ static int garp_pdu_append_msg(struct garp_applicant *app, u8 attrtype)
 
 	if (skb_tailroom(app->pdu) < sizeof(*gm))
 		return -1;
-	gm = (struct garp_msg_hdr *)__skb_put(app->pdu, sizeof(*gm));
+	gm = __skb_put(app->pdu, sizeof(*gm));
 	gm->attrtype = attrtype;
 	garp_cb(app->pdu)->cur_type = attrtype;
 	return 0;
@@ -299,7 +299,7 @@ static int garp_pdu_append_attr(struct garp_applicant *app,
 	len = sizeof(*ga) + attr->dlen;
 	if (skb_tailroom(app->pdu) < len)
 		goto queue;
-	ga = (struct garp_attr_hdr *)__skb_put(app->pdu, len);
+	ga = __skb_put(app->pdu, len);
 	ga->len   = len;
 	ga->event = event;
 	memcpy(ga->data, attr->data, attr->dlen);
diff --git a/net/802/mrp.c b/net/802/mrp.c
index 72db2785ef2c..be4dd3165347 100644
--- a/net/802/mrp.c
+++ b/net/802/mrp.c
@@ -311,7 +311,7 @@ static int mrp_pdu_init(struct mrp_applicant *app)
 	skb_reset_network_header(skb);
 	skb_reset_transport_header(skb);
 
-	ph = (struct mrp_pdu_hdr *)__skb_put(skb, sizeof(*ph));
+	ph = __skb_put(skb, sizeof(*ph));
 	ph->version = app->app->version;
 
 	app->pdu = skb;
@@ -324,7 +324,7 @@ static int mrp_pdu_append_end_mark(struct mrp_applicant *app)
 
 	if (skb_tailroom(app->pdu) < sizeof(*endmark))
 		return -1;
-	endmark = (__be16 *)__skb_put(app->pdu, sizeof(*endmark));
+	endmark = __skb_put(app->pdu, sizeof(*endmark));
 	put_unaligned(MRP_END_MARK, endmark);
 	return 0;
 }
@@ -368,7 +368,7 @@ static int mrp_pdu_append_msg_hdr(struct mrp_applicant *app,
 
 	if (skb_tailroom(app->pdu) < sizeof(*mh))
 		return -1;
-	mh = (struct mrp_msg_hdr *)__skb_put(app->pdu, sizeof(*mh));
+	mh = __skb_put(app->pdu, sizeof(*mh));
 	mh->attrtype = attrtype;
 	mh->attrlen = attrlen;
 	mrp_cb(app->pdu)->mh = mh;
@@ -382,8 +382,7 @@ static int mrp_pdu_append_vecattr_hdr(struct mrp_applicant *app,
 
 	if (skb_tailroom(app->pdu) < sizeof(*vah) + attrlen)
 		return -1;
-	vah = (struct mrp_vecattr_hdr *)__skb_put(app->pdu,
-						  sizeof(*vah) + attrlen);
+	vah = __skb_put(app->pdu, sizeof(*vah) + attrlen);
 	put_unaligned(0, &vah->lenflags);
 	memcpy(vah->firstattrvalue, firstattrvalue, attrlen);
 	mrp_cb(app->pdu)->vah = vah;
@@ -435,7 +434,7 @@ static int mrp_pdu_append_vecattr_event(struct mrp_applicant *app,
 	if (!pos) {
 		if (skb_tailroom(app->pdu) < sizeof(u8))
 			goto queue;
-		vaevents = (u8 *)__skb_put(app->pdu, sizeof(u8));
+		vaevents = __skb_put(app->pdu, sizeof(u8));
 	} else {
 		vaevents = (u8 *)(skb_tail_pointer(app->pdu) - sizeof(u8));
 	}
diff --git a/net/appletalk/ddp.c b/net/appletalk/ddp.c
index 465cc24b41e5..c7af6dc70fa2 100644
--- a/net/appletalk/ddp.c
+++ b/net/appletalk/ddp.c
@@ -1647,7 +1647,7 @@ static int atalk_sendmsg(struct socket *sock, struct msghdr *msg, size_t len)
 
 	SOCK_DEBUG(sk, "SK %p: Begin build.\n", sk);
 
-	ddp = (struct ddpehdr *)skb_put(skb, sizeof(struct ddpehdr));
+	ddp = skb_put(skb, sizeof(struct ddpehdr));
 	ddp->deh_len_hops  = htons(len + sizeof(*ddp));
 	ddp->deh_dnet  = usat->sat_addr.s_net;
 	ddp->deh_snet  = at->src_net;
diff --git a/net/atm/clip.c b/net/atm/clip.c
index ec527b62f79d..a7e4018370b4 100644
--- a/net/atm/clip.c
+++ b/net/atm/clip.c
@@ -60,7 +60,7 @@ static int to_atmarpd(enum atmarp_ctrl_type type, int itf, __be32 ip)
 	skb = alloc_skb(sizeof(struct atmarp_ctrl), GFP_ATOMIC);
 	if (!skb)
 		return -ENOMEM;
-	ctrl = (struct atmarp_ctrl *)skb_put(skb, sizeof(struct atmarp_ctrl));
+	ctrl = skb_put(skb, sizeof(struct atmarp_ctrl));
 	ctrl->type = type;
 	ctrl->itf_num = itf;
 	ctrl->ip = ip;
diff --git a/net/batman-adv/icmp_socket.c b/net/batman-adv/icmp_socket.c
index 6308c9f0fd96..8ead292886d1 100644
--- a/net/batman-adv/icmp_socket.c
+++ b/net/batman-adv/icmp_socket.c
@@ -207,7 +207,7 @@ static ssize_t batadv_socket_write(struct file *file, const char __user *buff,
 
 	skb->priority = TC_PRIO_CONTROL;
 	skb_reserve(skb, ETH_HLEN);
-	icmp_header = (struct batadv_icmp_header *)skb_put(skb, packet_len);
+	icmp_header = skb_put(skb, packet_len);
 
 	if (copy_from_user(icmp_header, buff, packet_len)) {
 		len = -EFAULT;
diff --git a/net/batman-adv/tp_meter.c b/net/batman-adv/tp_meter.c
index e3e2585d0977..bfe8effe9238 100644
--- a/net/batman-adv/tp_meter.c
+++ b/net/batman-adv/tp_meter.c
@@ -595,7 +595,7 @@ static int batadv_tp_send_msg(struct batadv_tp_vars *tp_vars, const u8 *src,
 		return BATADV_TP_REASON_MEMORY_ERROR;
 
 	skb_reserve(skb, ETH_HLEN);
-	icmp = (struct batadv_icmp_tp_packet *)skb_put(skb, sizeof(*icmp));
+	icmp = skb_put(skb, sizeof(*icmp));
 
 	/* fill the icmp header */
 	ether_addr_copy(icmp->dst, orig_node->orig);
@@ -612,7 +612,7 @@ static int batadv_tp_send_msg(struct batadv_tp_vars *tp_vars, const u8 *src,
 	icmp->timestamp = htonl(timestamp);
 
 	data_len = len - sizeof(*icmp);
-	data = (u8 *)skb_put(skb, data_len);
+	data = skb_put(skb, data_len);
 	batadv_tp_fill_prerandom(tp_vars, data, data_len);
 
 	r = batadv_send_skb_to_orig(skb, orig_node, NULL);
@@ -1190,7 +1190,7 @@ static int batadv_tp_send_ack(struct batadv_priv *bat_priv, const u8 *dst,
 	}
 
 	skb_reserve(skb, ETH_HLEN);
-	icmp = (struct batadv_icmp_tp_packet *)skb_put(skb, sizeof(*icmp));
+	icmp = skb_put(skb, sizeof(*icmp));
 	icmp->packet_type = BATADV_ICMP;
 	icmp->version = BATADV_COMPAT_VERSION;
 	icmp->ttl = BATADV_TTL;
diff --git a/net/bluetooth/hci_request.c b/net/bluetooth/hci_request.c
index 4e4105a932bd..b73ac149de34 100644
--- a/net/bluetooth/hci_request.c
+++ b/net/bluetooth/hci_request.c
@@ -299,7 +299,7 @@ struct sk_buff *hci_prepare_cmd(struct hci_dev *hdev, u16 opcode, u32 plen,
 	if (!skb)
 		return NULL;
 
-	hdr = (struct hci_command_hdr *) skb_put(skb, HCI_COMMAND_HDR_SIZE);
+	hdr = skb_put(skb, HCI_COMMAND_HDR_SIZE);
 	hdr->opcode = cpu_to_le16(opcode);
 	hdr->plen   = plen;
 
diff --git a/net/bluetooth/hci_sock.c b/net/bluetooth/hci_sock.c
index 083e87f26a0f..1301a8786d8d 100644
--- a/net/bluetooth/hci_sock.c
+++ b/net/bluetooth/hci_sock.c
@@ -410,7 +410,7 @@ static struct sk_buff *create_monitor_event(struct hci_dev *hdev, int event)
 		if (!skb)
 			return NULL;
 
-		ni = (void *)skb_put(skb, HCI_MON_NEW_INDEX_SIZE);
+		ni = skb_put(skb, HCI_MON_NEW_INDEX_SIZE);
 		ni->type = hdev->dev_type;
 		ni->bus = hdev->bus;
 		bacpy(&ni->bdaddr, &hdev->bdaddr);
@@ -438,7 +438,7 @@ static struct sk_buff *create_monitor_event(struct hci_dev *hdev, int event)
 		if (!skb)
 			return NULL;
 
-		ii = (void *)skb_put(skb, HCI_MON_INDEX_INFO_SIZE);
+		ii = skb_put(skb, HCI_MON_INDEX_INFO_SIZE);
 		bacpy(&ii->bdaddr, &hdev->bdaddr);
 		ii->manufacturer = cpu_to_le16(hdev->manufacturer);
 
@@ -517,7 +517,7 @@ static struct sk_buff *create_monitor_ctrl_open(struct sock *sk)
 	put_unaligned_le16(format, skb_put(skb, 2));
 	skb_put_data(skb, ver, sizeof(ver));
 	put_unaligned_le32(flags, skb_put(skb, 4));
-	*skb_put(skb, 1) = TASK_COMM_LEN;
+	*(u8 *)skb_put(skb, 1) = TASK_COMM_LEN;
 	skb_put_data(skb, hci_pi(sk)->comm, TASK_COMM_LEN);
 
 	__net_timestamp(skb);
@@ -616,7 +616,7 @@ send_monitor_note(struct sock *sk, const char *fmt, ...)
 
 	va_start(args, fmt);
 	vsprintf(skb_put(skb, len), fmt, args);
-	*skb_put(skb, 1) = 0;
+	*(u8 *)skb_put(skb, 1) = 0;
 	va_end(args);
 
 	__net_timestamp(skb);
@@ -703,11 +703,11 @@ static void hci_si_event(struct hci_dev *hdev, int type, int dlen, void *data)
 	if (!skb)
 		return;
 
-	hdr = (void *)skb_put(skb, HCI_EVENT_HDR_SIZE);
+	hdr = skb_put(skb, HCI_EVENT_HDR_SIZE);
 	hdr->evt  = HCI_EV_STACK_INTERNAL;
 	hdr->plen = sizeof(*ev) + dlen;
 
-	ev  = (void *)skb_put(skb, sizeof(*ev) + dlen);
+	ev = skb_put(skb, sizeof(*ev) + dlen);
 	ev->type = type;
 	memcpy(ev->data, data, dlen);
 
diff --git a/net/bluetooth/hidp/core.c b/net/bluetooth/hidp/core.c
index 9e83713262e8..c0d0832a023d 100644
--- a/net/bluetooth/hidp/core.c
+++ b/net/bluetooth/hidp/core.c
@@ -112,7 +112,7 @@ static int hidp_send_message(struct hidp_session *session, struct socket *sock,
 		return -ENOMEM;
 	}
 
-	*skb_put(skb, 1) = hdr;
+	*(u8 *)skb_put(skb, 1) = hdr;
 	if (data && size > 0)
 		skb_put_data(skb, data, size);
 
diff --git a/net/bluetooth/l2cap_core.c b/net/bluetooth/l2cap_core.c
index fe6a5529bdf5..303c779bfe38 100644
--- a/net/bluetooth/l2cap_core.c
+++ b/net/bluetooth/l2cap_core.c
@@ -1048,7 +1048,7 @@ static struct sk_buff *l2cap_create_sframe_pdu(struct l2cap_chan *chan,
 	if (!skb)
 		return ERR_PTR(-ENOMEM);
 
-	lh = (struct l2cap_hdr *) skb_put(skb, L2CAP_HDR_SIZE);
+	lh = skb_put(skb, L2CAP_HDR_SIZE);
 	lh->len = cpu_to_le16(hlen - L2CAP_HDR_SIZE);
 	lh->cid = cpu_to_le16(chan->dcid);
 
@@ -2182,7 +2182,7 @@ static struct sk_buff *l2cap_create_connless_pdu(struct l2cap_chan *chan,
 		return skb;
 
 	/* Create L2CAP header */
-	lh = (struct l2cap_hdr *) skb_put(skb, L2CAP_HDR_SIZE);
+	lh = skb_put(skb, L2CAP_HDR_SIZE);
 	lh->cid = cpu_to_le16(chan->dcid);
 	lh->len = cpu_to_le16(len + L2CAP_PSMLEN_SIZE);
 	put_unaligned(chan->psm, (__le16 *) skb_put(skb, L2CAP_PSMLEN_SIZE));
@@ -2213,7 +2213,7 @@ static struct sk_buff *l2cap_create_basic_pdu(struct l2cap_chan *chan,
 		return skb;
 
 	/* Create L2CAP header */
-	lh = (struct l2cap_hdr *) skb_put(skb, L2CAP_HDR_SIZE);
+	lh = skb_put(skb, L2CAP_HDR_SIZE);
 	lh->cid = cpu_to_le16(chan->dcid);
 	lh->len = cpu_to_le16(len);
 
@@ -2255,7 +2255,7 @@ static struct sk_buff *l2cap_create_iframe_pdu(struct l2cap_chan *chan,
 		return skb;
 
 	/* Create L2CAP header */
-	lh = (struct l2cap_hdr *) skb_put(skb, L2CAP_HDR_SIZE);
+	lh = skb_put(skb, L2CAP_HDR_SIZE);
 	lh->cid = cpu_to_le16(chan->dcid);
 	lh->len = cpu_to_le16(len + (hlen - L2CAP_HDR_SIZE));
 
@@ -2373,7 +2373,7 @@ static struct sk_buff *l2cap_create_le_flowctl_pdu(struct l2cap_chan *chan,
 		return skb;
 
 	/* Create L2CAP header */
-	lh = (struct l2cap_hdr *) skb_put(skb, L2CAP_HDR_SIZE);
+	lh = skb_put(skb, L2CAP_HDR_SIZE);
 	lh->cid = cpu_to_le16(chan->dcid);
 	lh->len = cpu_to_le16(len + (hlen - L2CAP_HDR_SIZE));
 
@@ -2908,7 +2908,7 @@ static struct sk_buff *l2cap_build_cmd(struct l2cap_conn *conn, u8 code,
 	if (!skb)
 		return NULL;
 
-	lh = (struct l2cap_hdr *) skb_put(skb, L2CAP_HDR_SIZE);
+	lh = skb_put(skb, L2CAP_HDR_SIZE);
 	lh->len = cpu_to_le16(L2CAP_CMD_HDR_SIZE + dlen);
 
 	if (conn->hcon->type == LE_LINK)
@@ -2916,7 +2916,7 @@ static struct sk_buff *l2cap_build_cmd(struct l2cap_conn *conn, u8 code,
 	else
 		lh->cid = cpu_to_le16(L2CAP_CID_SIGNALING);
 
-	cmd = (struct l2cap_cmd_hdr *) skb_put(skb, L2CAP_CMD_HDR_SIZE);
+	cmd = skb_put(skb, L2CAP_CMD_HDR_SIZE);
 	cmd->code  = code;
 	cmd->ident = ident;
 	cmd->len   = cpu_to_le16(dlen);
diff --git a/net/bluetooth/mgmt_util.c b/net/bluetooth/mgmt_util.c
index 11d0ca64402b..d057113e0d4b 100644
--- a/net/bluetooth/mgmt_util.c
+++ b/net/bluetooth/mgmt_util.c
@@ -66,7 +66,7 @@ int mgmt_send_event(u16 event, struct hci_dev *hdev, unsigned short channel,
 	if (!skb)
 		return -ENOMEM;
 
-	hdr = (void *) skb_put(skb, sizeof(*hdr));
+	hdr = skb_put(skb, sizeof(*hdr));
 	hdr->opcode = cpu_to_le16(event);
 	if (hdev)
 		hdr->index = cpu_to_le16(hdev->id);
@@ -103,13 +103,13 @@ int mgmt_cmd_status(struct sock *sk, u16 index, u16 cmd, u8 status)
 	if (!skb)
 		return -ENOMEM;
 
-	hdr = (void *) skb_put(skb, sizeof(*hdr));
+	hdr = skb_put(skb, sizeof(*hdr));
 
 	hdr->opcode = cpu_to_le16(MGMT_EV_CMD_STATUS);
 	hdr->index = cpu_to_le16(index);
 	hdr->len = cpu_to_le16(sizeof(*ev));
 
-	ev = (void *) skb_put(skb, sizeof(*ev));
+	ev = skb_put(skb, sizeof(*ev));
 	ev->status = status;
 	ev->opcode = cpu_to_le16(cmd);
 
@@ -147,13 +147,13 @@ int mgmt_cmd_complete(struct sock *sk, u16 index, u16 cmd, u8 status,
 	if (!skb)
 		return -ENOMEM;
 
-	hdr = (void *) skb_put(skb, sizeof(*hdr));
+	hdr = skb_put(skb, sizeof(*hdr));
 
 	hdr->opcode = cpu_to_le16(MGMT_EV_CMD_COMPLETE);
 	hdr->index = cpu_to_le16(index);
 	hdr->len = cpu_to_le16(sizeof(*ev) + rp_len);
 
-	ev = (void *) skb_put(skb, sizeof(*ev) + rp_len);
+	ev = skb_put(skb, sizeof(*ev) + rp_len);
 	ev->opcode = cpu_to_le16(cmd);
 	ev->status = status;
 
diff --git a/net/bluetooth/rfcomm/core.c b/net/bluetooth/rfcomm/core.c
index 8ebca9033d60..1a9b906c5a35 100644
--- a/net/bluetooth/rfcomm/core.c
+++ b/net/bluetooth/rfcomm/core.c
@@ -863,7 +863,7 @@ static int rfcomm_queue_disc(struct rfcomm_dlc *d)
 	if (!skb)
 		return -ENOMEM;
 
-	cmd = (void *) __skb_put(skb, sizeof(*cmd));
+	cmd = __skb_put(skb, sizeof(*cmd));
 	cmd->addr = d->addr;
 	cmd->ctrl = __ctrl(RFCOMM_DISC, 1);
 	cmd->len  = __len8(0);
diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 8860ad985d68..b8bcf9021329 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -2714,7 +2714,7 @@ static void pktgen_finalize_skb(struct pktgen_dev *pkt_dev, struct sk_buff *skb,
 	struct timeval timestamp;
 	struct pktgen_hdr *pgh;
 
-	pgh = (struct pktgen_hdr *)skb_put(skb, sizeof(*pgh));
+	pgh = skb_put(skb, sizeof(*pgh));
 	datalen -= sizeof(*pgh);
 
 	if (pkt_dev->nfrags <= 0) {
@@ -2845,33 +2845,34 @@ static struct sk_buff *fill_packet_ipv4(struct net_device *odev,
 
 	/*  Reserve for ethernet and IP header  */
 	eth = (__u8 *) skb_push(skb, 14);
-	mpls = (__be32 *)skb_put(skb, pkt_dev->nr_labels*sizeof(__u32));
+	mpls = skb_put(skb, pkt_dev->nr_labels * sizeof(__u32));
 	if (pkt_dev->nr_labels)
 		mpls_push(mpls, pkt_dev);
 
 	if (pkt_dev->vlan_id != 0xffff) {
 		if (pkt_dev->svlan_id != 0xffff) {
-			svlan_tci = (__be16 *)skb_put(skb, sizeof(__be16));
+			svlan_tci = skb_put(skb, sizeof(__be16));
 			*svlan_tci = build_tci(pkt_dev->svlan_id,
 					       pkt_dev->svlan_cfi,
 					       pkt_dev->svlan_p);
-			svlan_encapsulated_proto = (__be16 *)skb_put(skb, sizeof(__be16));
+			svlan_encapsulated_proto = skb_put(skb,
+							   sizeof(__be16));
 			*svlan_encapsulated_proto = htons(ETH_P_8021Q);
 		}
-		vlan_tci = (__be16 *)skb_put(skb, sizeof(__be16));
+		vlan_tci = skb_put(skb, sizeof(__be16));
 		*vlan_tci = build_tci(pkt_dev->vlan_id,
 				      pkt_dev->vlan_cfi,
 				      pkt_dev->vlan_p);
-		vlan_encapsulated_proto = (__be16 *)skb_put(skb, sizeof(__be16));
+		vlan_encapsulated_proto = skb_put(skb, sizeof(__be16));
 		*vlan_encapsulated_proto = htons(ETH_P_IP);
 	}
 
 	skb_reset_mac_header(skb);
 	skb_set_network_header(skb, skb->len);
-	iph = (struct iphdr *) skb_put(skb, sizeof(struct iphdr));
+	iph = skb_put(skb, sizeof(struct iphdr));
 
 	skb_set_transport_header(skb, skb->len);
-	udph = (struct udphdr *) skb_put(skb, sizeof(struct udphdr));
+	udph = skb_put(skb, sizeof(struct udphdr));
 	skb_set_queue_mapping(skb, queue_map);
 	skb->priority = pkt_dev->skb_priority;
 
@@ -2972,33 +2973,34 @@ static struct sk_buff *fill_packet_ipv6(struct net_device *odev,
 
 	/*  Reserve for ethernet and IP header  */
 	eth = (__u8 *) skb_push(skb, 14);
-	mpls = (__be32 *)skb_put(skb, pkt_dev->nr_labels*sizeof(__u32));
+	mpls = skb_put(skb, pkt_dev->nr_labels * sizeof(__u32));
 	if (pkt_dev->nr_labels)
 		mpls_push(mpls, pkt_dev);
 
 	if (pkt_dev->vlan_id != 0xffff) {
 		if (pkt_dev->svlan_id != 0xffff) {
-			svlan_tci = (__be16 *)skb_put(skb, sizeof(__be16));
+			svlan_tci = skb_put(skb, sizeof(__be16));
 			*svlan_tci = build_tci(pkt_dev->svlan_id,
 					       pkt_dev->svlan_cfi,
 					       pkt_dev->svlan_p);
-			svlan_encapsulated_proto = (__be16 *)skb_put(skb, sizeof(__be16));
+			svlan_encapsulated_proto = skb_put(skb,
+							   sizeof(__be16));
 			*svlan_encapsulated_proto = htons(ETH_P_8021Q);
 		}
-		vlan_tci = (__be16 *)skb_put(skb, sizeof(__be16));
+		vlan_tci = skb_put(skb, sizeof(__be16));
 		*vlan_tci = build_tci(pkt_dev->vlan_id,
 				      pkt_dev->vlan_cfi,
 				      pkt_dev->vlan_p);
-		vlan_encapsulated_proto = (__be16 *)skb_put(skb, sizeof(__be16));
+		vlan_encapsulated_proto = skb_put(skb, sizeof(__be16));
 		*vlan_encapsulated_proto = htons(ETH_P_IPV6);
 	}
 
 	skb_reset_mac_header(skb);
 	skb_set_network_header(skb, skb->len);
-	iph = (struct ipv6hdr *) skb_put(skb, sizeof(struct ipv6hdr));
+	iph = skb_put(skb, sizeof(struct ipv6hdr));
 
 	skb_set_transport_header(skb, skb->len);
-	udph = (struct udphdr *) skb_put(skb, sizeof(struct udphdr));
+	udph = skb_put(skb, sizeof(struct udphdr));
 	skb_set_queue_mapping(skb, queue_map);
 	skb->priority = pkt_dev->skb_priority;
 
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index c4d2c1f824bb..0baa7f2dd8ef 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -1421,7 +1421,7 @@ EXPORT_SYMBOL(skb_pad);
  *	returned.
  */
 
-unsigned char *pskb_put(struct sk_buff *skb, struct sk_buff *tail, int len)
+void *pskb_put(struct sk_buff *skb, struct sk_buff *tail, int len)
 {
 	if (tail != skb) {
 		skb->data_len += len;
@@ -1440,9 +1440,9 @@ EXPORT_SYMBOL_GPL(pskb_put);
  *	exceed the total buffer size the kernel will panic. A pointer to the
  *	first byte of the extra data is returned.
  */
-unsigned char *skb_put(struct sk_buff *skb, unsigned int len)
+void *skb_put(struct sk_buff *skb, unsigned int len)
 {
-	unsigned char *tmp = skb_tail_pointer(skb);
+	void *tmp = skb_tail_pointer(skb);
 	SKB_LINEAR_ASSERT(skb);
 	skb->tail += len;
 	skb->len  += len;
diff --git a/net/decnet/dn_dev.c b/net/decnet/dn_dev.c
index 9017a9a73ab5..1d84f6dae315 100644
--- a/net/decnet/dn_dev.c
+++ b/net/decnet/dn_dev.c
@@ -846,7 +846,7 @@ static void dn_send_endnode_hello(struct net_device *dev, struct dn_ifaddr *ifa)
 
 	skb->dev = dev;
 
-	msg = (struct endnode_hello_message *)skb_put(skb,sizeof(*msg));
+	msg = skb_put(skb, sizeof(*msg));
 
 	msg->msgflg  = 0x0D;
 	memcpy(msg->tiver, dn_eco_version, 3);
diff --git a/net/decnet/dn_nsp_out.c b/net/decnet/dn_nsp_out.c
index b8a558715395..7e054b2f270a 100644
--- a/net/decnet/dn_nsp_out.c
+++ b/net/decnet/dn_nsp_out.c
@@ -484,7 +484,7 @@ void dn_send_conn_ack (struct sock *sk)
 	if ((skb = dn_alloc_skb(sk, 3, sk->sk_allocation)) == NULL)
 		return;
 
-	msg = (struct nsp_conn_ack_msg *)skb_put(skb, 3);
+	msg = skb_put(skb, 3);
 	msg->msgflg = 0x24;
 	msg->dstaddr = scp->addrrem;
 
@@ -522,7 +522,7 @@ void dn_send_conn_conf(struct sock *sk, gfp_t gfp)
 	if ((skb = dn_alloc_skb(sk, 50 + len, gfp)) == NULL)
 		return;
 
-	msg = (struct nsp_conn_init_msg *)skb_put(skb, sizeof(*msg));
+	msg = skb_put(skb, sizeof(*msg));
 	msg->msgflg = 0x28;
 	msg->dstaddr = scp->addrrem;
 	msg->srcaddr = scp->addrloc;
@@ -530,7 +530,7 @@ void dn_send_conn_conf(struct sock *sk, gfp_t gfp)
 	msg->info = scp->info_loc;
 	msg->segsize = cpu_to_le16(scp->segsize_loc);
 
-	*skb_put(skb,1) = len;
+	*(u8 *)skb_put(skb, 1) = len;
 
 	if (len > 0)
 		skb_put_data(skb, scp->conndata_out.opt_data, len);
@@ -662,7 +662,7 @@ void dn_nsp_send_conninit(struct sock *sk, unsigned char msgflg)
 		return;
 
 	cb  = DN_SKB_CB(skb);
-	msg = (struct nsp_conn_init_msg *)skb_put(skb,sizeof(*msg));
+	msg = skb_put(skb, sizeof(*msg));
 
 	msg->msgflg	= msgflg;
 	msg->dstaddr	= 0x0000;		/* Remote Node will assign it*/
@@ -686,25 +686,25 @@ void dn_nsp_send_conninit(struct sock *sk, unsigned char msgflg)
 	if (scp->peer.sdn_flags & SDF_UICPROXY)
 		menuver |= DN_MENUVER_UIC;
 
-	*skb_put(skb, 1) = menuver;	/* Menu Version		*/
+	*(u8 *)skb_put(skb, 1) = menuver;	/* Menu Version		*/
 
 	aux = scp->accessdata.acc_userl;
-	*skb_put(skb, 1) = aux;
+	*(u8 *)skb_put(skb, 1) = aux;
 	if (aux > 0)
 		skb_put_data(skb, scp->accessdata.acc_user, aux);
 
 	aux = scp->accessdata.acc_passl;
-	*skb_put(skb, 1) = aux;
+	*(u8 *)skb_put(skb, 1) = aux;
 	if (aux > 0)
 		skb_put_data(skb, scp->accessdata.acc_pass, aux);
 
 	aux = scp->accessdata.acc_accl;
-	*skb_put(skb, 1) = aux;
+	*(u8 *)skb_put(skb, 1) = aux;
 	if (aux > 0)
 		skb_put_data(skb, scp->accessdata.acc_acc, aux);
 
 	aux = (__u8)le16_to_cpu(scp->conndata_out.opt_optl);
-	*skb_put(skb, 1) = aux;
+	*(u8 *)skb_put(skb, 1) = aux;
 	if (aux > 0)
 		skb_put_data(skb, scp->conndata_out.opt_data, aux);
 
diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index a651c53260ec..8b52179ddc6e 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -539,7 +539,7 @@ struct sk_buff *arp_create(int type, int ptype, __be32 dest_ip,
 
 	skb_reserve(skb, hlen);
 	skb_reset_network_header(skb);
-	arp = (struct arphdr *) skb_put(skb, arp_hdr_len(dev));
+	arp = skb_put(skb, arp_hdr_len(dev));
 	skb->dev = dev;
 	skb->protocol = htons(ETH_P_ARP);
 	if (!src_hw)
diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index 8f6b5bbcbf69..2202edf31884 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -414,7 +414,7 @@ static struct sk_buff *add_grhead(struct sk_buff *skb, struct ip_mc_list *pmc,
 		skb = igmpv3_newpack(dev, dev->mtu);
 	if (!skb)
 		return NULL;
-	pgr = (struct igmpv3_grec *)skb_put(skb, sizeof(struct igmpv3_grec));
+	pgr = skb_put(skb, sizeof(struct igmpv3_grec));
 	pgr->grec_type = type;
 	pgr->grec_auxwords = 0;
 	pgr->grec_nsrcs = 0;
@@ -508,7 +508,7 @@ static struct sk_buff *add_grec(struct sk_buff *skb, struct ip_mc_list *pmc,
 		}
 		if (!skb)
 			return NULL;
-		psrc = (__be32 *)skb_put(skb, sizeof(__be32));
+		psrc = skb_put(skb, sizeof(__be32));
 		*psrc = psf->sf_inaddr;
 		scount++; stotal++;
 		if ((type == IGMPV3_ALLOW_NEW_SOURCES ||
@@ -742,7 +742,7 @@ static int igmp_send_report(struct in_device *in_dev, struct ip_mc_list *pmc,
 	((u8 *)&iph[1])[2] = 0;
 	((u8 *)&iph[1])[3] = 0;
 
-	ih = (struct igmphdr *)skb_put(skb, sizeof(struct igmphdr));
+	ih = skb_put(skb, sizeof(struct igmphdr));
 	ih->type = type;
 	ih->code = 0;
 	ih->csum = 0;
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index a1199895b8a6..abbd7c992960 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -1044,7 +1044,7 @@ static int ipmr_cache_report(struct mr_table *mrt,
 		msg->im_vif = vifi;
 		skb_dst_set(skb, dst_clone(skb_dst(pkt)));
 		/* Add our header */
-		igmp = (struct igmphdr *)skb_put(skb, sizeof(struct igmphdr));
+		igmp = skb_put(skb, sizeof(struct igmphdr));
 		igmp->type = assert;
 		msg->im_msgtype = assert;
 		igmp->code = 0;
diff --git a/net/ipv4/netfilter/ipt_SYNPROXY.c b/net/ipv4/netfilter/ipt_SYNPROXY.c
index af2b69b6895f..f1528f7175a8 100644
--- a/net/ipv4/netfilter/ipt_SYNPROXY.c
+++ b/net/ipv4/netfilter/ipt_SYNPROXY.c
@@ -24,7 +24,7 @@ synproxy_build_ip(struct net *net, struct sk_buff *skb, __be32 saddr,
 	struct iphdr *iph;
 
 	skb_reset_network_header(skb);
-	iph = (struct iphdr *)skb_put(skb, sizeof(*iph));
+	iph = skb_put(skb, sizeof(*iph));
 	iph->version	= 4;
 	iph->ihl	= sizeof(*iph) / 4;
 	iph->tos	= 0;
@@ -91,7 +91,7 @@ synproxy_send_client_synack(struct net *net,
 	niph = synproxy_build_ip(net, nskb, iph->daddr, iph->saddr);
 
 	skb_reset_transport_header(nskb);
-	nth = (struct tcphdr *)skb_put(nskb, tcp_hdr_size);
+	nth = skb_put(nskb, tcp_hdr_size);
 	nth->source	= th->dest;
 	nth->dest	= th->source;
 	nth->seq	= htonl(__cookie_v4_init_sequence(iph, th, &mss));
@@ -133,7 +133,7 @@ synproxy_send_server_syn(struct net *net,
 	niph = synproxy_build_ip(net, nskb, iph->saddr, iph->daddr);
 
 	skb_reset_transport_header(nskb);
-	nth = (struct tcphdr *)skb_put(nskb, tcp_hdr_size);
+	nth = skb_put(nskb, tcp_hdr_size);
 	nth->source	= th->source;
 	nth->dest	= th->dest;
 	nth->seq	= htonl(recv_seq - 1);
@@ -178,7 +178,7 @@ synproxy_send_server_ack(struct net *net,
 	niph = synproxy_build_ip(net, nskb, iph->daddr, iph->saddr);
 
 	skb_reset_transport_header(nskb);
-	nth = (struct tcphdr *)skb_put(nskb, tcp_hdr_size);
+	nth = skb_put(nskb, tcp_hdr_size);
 	nth->source	= th->dest;
 	nth->dest	= th->source;
 	nth->seq	= htonl(ntohl(th->ack_seq));
@@ -216,7 +216,7 @@ synproxy_send_client_ack(struct net *net,
 	niph = synproxy_build_ip(net, nskb, iph->saddr, iph->daddr);
 
 	skb_reset_transport_header(nskb);
-	nth = (struct tcphdr *)skb_put(nskb, tcp_hdr_size);
+	nth = skb_put(nskb, tcp_hdr_size);
 	nth->source	= th->source;
 	nth->dest	= th->dest;
 	nth->seq	= htonl(ntohl(th->seq) + 1);
diff --git a/net/ipv4/netfilter/nf_reject_ipv4.c b/net/ipv4/netfilter/nf_reject_ipv4.c
index 52b7dcc5aaf3..eeacbdaf7cdf 100644
--- a/net/ipv4/netfilter/nf_reject_ipv4.c
+++ b/net/ipv4/netfilter/nf_reject_ipv4.c
@@ -51,7 +51,7 @@ struct iphdr *nf_reject_iphdr_put(struct sk_buff *nskb,
 	struct iphdr *niph, *oiph = ip_hdr(oldskb);
 
 	skb_reset_network_header(nskb);
-	niph = (struct iphdr *)skb_put(nskb, sizeof(struct iphdr));
+	niph = skb_put(nskb, sizeof(struct iphdr));
 	niph->version	= 4;
 	niph->ihl	= sizeof(struct iphdr) / 4;
 	niph->tos	= 0;
diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index b64046ccae69..e2221135858b 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -1692,7 +1692,7 @@ static struct sk_buff *add_grhead(struct sk_buff *skb, struct ifmcaddr6 *pmc,
 		skb = mld_newpack(pmc->idev, dev->mtu);
 	if (!skb)
 		return NULL;
-	pgr = (struct mld2_grec *)skb_put(skb, sizeof(struct mld2_grec));
+	pgr = skb_put(skb, sizeof(struct mld2_grec));
 	pgr->grec_type = type;
 	pgr->grec_auxwords = 0;
 	pgr->grec_nsrcs = 0;
@@ -1784,7 +1784,7 @@ static struct sk_buff *add_grec(struct sk_buff *skb, struct ifmcaddr6 *pmc,
 		}
 		if (!skb)
 			return NULL;
-		psrc = (struct in6_addr *)skb_put(skb, sizeof(*psrc));
+		psrc = skb_put(skb, sizeof(*psrc));
 		*psrc = psf->sf_addr;
 		scount++; stotal++;
 		if ((type == MLD2_ALLOW_NEW_SOURCES ||
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index d310dc41209a..0327c1f2e6fc 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -528,7 +528,7 @@ void ndisc_send_na(struct net_device *dev, const struct in6_addr *daddr,
 	if (!skb)
 		return;
 
-	msg = (struct nd_msg *)skb_put(skb, sizeof(*msg));
+	msg = skb_put(skb, sizeof(*msg));
 	*msg = (struct nd_msg) {
 		.icmph = {
 			.icmp6_type = NDISC_NEIGHBOUR_ADVERTISEMENT,
@@ -597,7 +597,7 @@ void ndisc_send_ns(struct net_device *dev, const struct in6_addr *solicit,
 	if (!skb)
 		return;
 
-	msg = (struct nd_msg *)skb_put(skb, sizeof(*msg));
+	msg = skb_put(skb, sizeof(*msg));
 	*msg = (struct nd_msg) {
 		.icmph = {
 			.icmp6_type = NDISC_NEIGHBOUR_SOLICITATION,
@@ -657,7 +657,7 @@ void ndisc_send_rs(struct net_device *dev, const struct in6_addr *saddr,
 	if (!skb)
 		return;
 
-	msg = (struct rs_msg *)skb_put(skb, sizeof(*msg));
+	msg = skb_put(skb, sizeof(*msg));
 	*msg = (struct rs_msg) {
 		.icmph = {
 			.icmp6_type = NDISC_ROUTER_SOLICITATION,
@@ -1633,7 +1633,7 @@ void ndisc_send_redirect(struct sk_buff *skb, const struct in6_addr *target)
 	if (!buff)
 		goto release;
 
-	msg = (struct rd_msg *)skb_put(buff, sizeof(*msg));
+	msg = skb_put(buff, sizeof(*msg));
 	*msg = (struct rd_msg) {
 		.icmph = {
 			.icmp6_type = NDISC_REDIRECT,
diff --git a/net/ipv6/netfilter/ip6t_SYNPROXY.c b/net/ipv6/netfilter/ip6t_SYNPROXY.c
index d3c4daa708b9..ce203dd729e0 100644
--- a/net/ipv6/netfilter/ip6t_SYNPROXY.c
+++ b/net/ipv6/netfilter/ip6t_SYNPROXY.c
@@ -27,7 +27,7 @@ synproxy_build_ip(struct net *net, struct sk_buff *skb,
 	struct ipv6hdr *iph;
 
 	skb_reset_network_header(skb);
-	iph = (struct ipv6hdr *)skb_put(skb, sizeof(*iph));
+	iph = skb_put(skb, sizeof(*iph));
 	ip6_flow_hdr(iph, 0, 0);
 	iph->hop_limit	= net->ipv6.devconf_all->hop_limit;
 	iph->nexthdr	= IPPROTO_TCP;
@@ -105,7 +105,7 @@ synproxy_send_client_synack(struct net *net,
 	niph = synproxy_build_ip(net, nskb, &iph->daddr, &iph->saddr);
 
 	skb_reset_transport_header(nskb);
-	nth = (struct tcphdr *)skb_put(nskb, tcp_hdr_size);
+	nth = skb_put(nskb, tcp_hdr_size);
 	nth->source	= th->dest;
 	nth->dest	= th->source;
 	nth->seq	= htonl(__cookie_v6_init_sequence(iph, th, &mss));
@@ -147,7 +147,7 @@ synproxy_send_server_syn(struct net *net,
 	niph = synproxy_build_ip(net, nskb, &iph->saddr, &iph->daddr);
 
 	skb_reset_transport_header(nskb);
-	nth = (struct tcphdr *)skb_put(nskb, tcp_hdr_size);
+	nth = skb_put(nskb, tcp_hdr_size);
 	nth->source	= th->source;
 	nth->dest	= th->dest;
 	nth->seq	= htonl(recv_seq - 1);
@@ -192,7 +192,7 @@ synproxy_send_server_ack(struct net *net,
 	niph = synproxy_build_ip(net, nskb, &iph->daddr, &iph->saddr);
 
 	skb_reset_transport_header(nskb);
-	nth = (struct tcphdr *)skb_put(nskb, tcp_hdr_size);
+	nth = skb_put(nskb, tcp_hdr_size);
 	nth->source	= th->dest;
 	nth->dest	= th->source;
 	nth->seq	= htonl(ntohl(th->ack_seq));
@@ -230,7 +230,7 @@ synproxy_send_client_ack(struct net *net,
 	niph = synproxy_build_ip(net, nskb, &iph->saddr, &iph->daddr);
 
 	skb_reset_transport_header(nskb);
-	nth = (struct tcphdr *)skb_put(nskb, tcp_hdr_size);
+	nth = skb_put(nskb, tcp_hdr_size);
 	nth->source	= th->source;
 	nth->dest	= th->dest;
 	nth->seq	= htonl(ntohl(th->seq) + 1);
diff --git a/net/ipv6/netfilter/nf_reject_ipv6.c b/net/ipv6/netfilter/nf_reject_ipv6.c
index f63b18e05c69..24858402e374 100644
--- a/net/ipv6/netfilter/nf_reject_ipv6.c
+++ b/net/ipv6/netfilter/nf_reject_ipv6.c
@@ -95,7 +95,7 @@ void nf_reject_ip6_tcphdr_put(struct sk_buff *nskb,
 	int needs_ack;
 
 	skb_reset_transport_header(nskb);
-	tcph = (struct tcphdr *)skb_put(nskb, sizeof(struct tcphdr));
+	tcph = skb_put(nskb, sizeof(struct tcphdr));
 	/* Truncate to length (no data) */
 	tcph->doff = sizeof(struct tcphdr)/4;
 	tcph->source = oth->dest;
diff --git a/net/irda/irlap_frame.c b/net/irda/irlap_frame.c
index bf56ac7dba96..82e71e5622c2 100644
--- a/net/irda/irlap_frame.c
+++ b/net/irda/irlap_frame.c
@@ -133,7 +133,7 @@ void irlap_send_snrm_frame(struct irlap_cb *self, struct qos_info *qos)
 	if (!tx_skb)
 		return;
 
-	frame = (struct snrm_frame *) skb_put(tx_skb, 2);
+	frame = skb_put(tx_skb, 2);
 
 	/* Insert connection address field */
 	if (qos)
@@ -228,7 +228,7 @@ void irlap_send_ua_response_frame(struct irlap_cb *self, struct qos_info *qos)
 	if (!tx_skb)
 		return;
 
-	frame = (struct ua_frame *) skb_put(tx_skb, 10);
+	frame = skb_put(tx_skb, 10);
 
 	/* Build UA response */
 	frame->caddr = self->caddr;
@@ -268,7 +268,7 @@ void irlap_send_dm_frame( struct irlap_cb *self)
 	if (!tx_skb)
 		return;
 
-	frame = (struct dm_frame *)skb_put(tx_skb, 2);
+	frame = skb_put(tx_skb, 2);
 
 	if (self->state == LAP_NDM)
 		frame->caddr = CBROADCAST;
@@ -298,7 +298,7 @@ void irlap_send_disc_frame(struct irlap_cb *self)
 	if (!tx_skb)
 		return;
 
-	frame = (struct disc_frame *)skb_put(tx_skb, 2);
+	frame = skb_put(tx_skb, 2);
 
 	frame->caddr = self->caddr | CMD_FRAME;
 	frame->control = DISC_CMD | PF_BIT;
@@ -587,7 +587,7 @@ void irlap_send_rr_frame(struct irlap_cb *self, int command)
 	if (!tx_skb)
 		return;
 
-	frame = (struct rr_frame *)skb_put(tx_skb, 2);
+	frame = skb_put(tx_skb, 2);
 
 	frame->caddr = self->caddr;
 	frame->caddr |= (command) ? CMD_FRAME : 0;
@@ -612,7 +612,7 @@ void irlap_send_rd_frame(struct irlap_cb *self)
 	if (!tx_skb)
 		return;
 
-	frame = (struct rd_frame *)skb_put(tx_skb, 2);
+	frame = skb_put(tx_skb, 2);
 
 	frame->caddr = self->caddr;
 	frame->control = RD_RSP | PF_BIT;
@@ -1202,14 +1202,13 @@ void irlap_send_test_frame(struct irlap_cb *self, __u8 caddr, __u32 daddr,
 
 	/* Broadcast frames must include saddr and daddr fields */
 	if (caddr == CBROADCAST) {
-		frame = (struct test_frame *)
-			skb_put(tx_skb, sizeof(struct test_frame));
+		frame = skb_put(tx_skb, sizeof(struct test_frame));
 
 		/* Insert the swapped addresses */
 		frame->saddr = cpu_to_le32(self->saddr);
 		frame->daddr = cpu_to_le32(daddr);
 	} else
-		frame = (struct test_frame *) skb_put(tx_skb, LAP_ADDR_HEADER + LAP_CTRL_HEADER);
+		frame = skb_put(tx_skb, LAP_ADDR_HEADER + LAP_CTRL_HEADER);
 
 	frame->caddr = caddr;
 	frame->control = TEST_RSP | PF_BIT;
diff --git a/net/key/af_key.c b/net/key/af_key.c
index 3ebb4268973b..daa4e90dc4db 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -349,7 +349,7 @@ static int pfkey_error(const struct sadb_msg *orig, int err, struct sock *sk)
 		err = EINVAL;
 	BUG_ON(err <= 0 || err >= 256);
 
-	hdr = (struct sadb_msg *) skb_put(skb, sizeof(struct sadb_msg));
+	hdr = skb_put(skb, sizeof(struct sadb_msg));
 	pfkey_hdr_dup(hdr, orig);
 	hdr->sadb_msg_errno = (uint8_t) err;
 	hdr->sadb_msg_len = (sizeof(struct sadb_msg) /
@@ -810,12 +810,12 @@ static struct sk_buff *__pfkey_xfrm_state2msg(const struct xfrm_state *x,
 		return ERR_PTR(-ENOBUFS);
 
 	/* call should fill header later */
-	hdr = (struct sadb_msg *) skb_put(skb, sizeof(struct sadb_msg));
+	hdr = skb_put(skb, sizeof(struct sadb_msg));
 	memset(hdr, 0, size);	/* XXX do we need this ? */
 	hdr->sadb_msg_len = size / sizeof(uint64_t);
 
 	/* sa */
-	sa = (struct sadb_sa *)  skb_put(skb, sizeof(struct sadb_sa));
+	sa = skb_put(skb, sizeof(struct sadb_sa));
 	sa->sadb_sa_len = sizeof(struct sadb_sa)/sizeof(uint64_t);
 	sa->sadb_sa_exttype = SADB_EXT_SA;
 	sa->sadb_sa_spi = x->id.spi;
@@ -862,8 +862,7 @@ static struct sk_buff *__pfkey_xfrm_state2msg(const struct xfrm_state *x,
 
 	/* hard time */
 	if (hsc & 2) {
-		lifetime = (struct sadb_lifetime *)  skb_put(skb,
-							     sizeof(struct sadb_lifetime));
+		lifetime = skb_put(skb, sizeof(struct sadb_lifetime));
 		lifetime->sadb_lifetime_len =
 			sizeof(struct sadb_lifetime)/sizeof(uint64_t);
 		lifetime->sadb_lifetime_exttype = SADB_EXT_LIFETIME_HARD;
@@ -874,8 +873,7 @@ static struct sk_buff *__pfkey_xfrm_state2msg(const struct xfrm_state *x,
 	}
 	/* soft time */
 	if (hsc & 1) {
-		lifetime = (struct sadb_lifetime *)  skb_put(skb,
-							     sizeof(struct sadb_lifetime));
+		lifetime = skb_put(skb, sizeof(struct sadb_lifetime));
 		lifetime->sadb_lifetime_len =
 			sizeof(struct sadb_lifetime)/sizeof(uint64_t);
 		lifetime->sadb_lifetime_exttype = SADB_EXT_LIFETIME_SOFT;
@@ -885,8 +883,7 @@ static struct sk_buff *__pfkey_xfrm_state2msg(const struct xfrm_state *x,
 		lifetime->sadb_lifetime_usetime = x->lft.soft_use_expires_seconds;
 	}
 	/* current time */
-	lifetime = (struct sadb_lifetime *)  skb_put(skb,
-						     sizeof(struct sadb_lifetime));
+	lifetime = skb_put(skb, sizeof(struct sadb_lifetime));
 	lifetime->sadb_lifetime_len =
 		sizeof(struct sadb_lifetime)/sizeof(uint64_t);
 	lifetime->sadb_lifetime_exttype = SADB_EXT_LIFETIME_CURRENT;
@@ -895,8 +892,7 @@ static struct sk_buff *__pfkey_xfrm_state2msg(const struct xfrm_state *x,
 	lifetime->sadb_lifetime_addtime = x->curlft.add_time;
 	lifetime->sadb_lifetime_usetime = x->curlft.use_time;
 	/* src address */
-	addr = (struct sadb_address*) skb_put(skb,
-					      sizeof(struct sadb_address)+sockaddr_size);
+	addr = skb_put(skb, sizeof(struct sadb_address) + sockaddr_size);
 	addr->sadb_address_len =
 		(sizeof(struct sadb_address)+sockaddr_size)/
 			sizeof(uint64_t);
@@ -915,8 +911,7 @@ static struct sk_buff *__pfkey_xfrm_state2msg(const struct xfrm_state *x,
 		BUG();
 
 	/* dst address */
-	addr = (struct sadb_address*) skb_put(skb,
-					      sizeof(struct sadb_address)+sockaddr_size);
+	addr = skb_put(skb, sizeof(struct sadb_address) + sockaddr_size);
 	addr->sadb_address_len =
 		(sizeof(struct sadb_address)+sockaddr_size)/
 			sizeof(uint64_t);
@@ -933,8 +928,8 @@ static struct sk_buff *__pfkey_xfrm_state2msg(const struct xfrm_state *x,
 
 	if (!xfrm_addr_equal(&x->sel.saddr, &x->props.saddr,
 			     x->props.family)) {
-		addr = (struct sadb_address*) skb_put(skb,
-			sizeof(struct sadb_address)+sockaddr_size);
+		addr = skb_put(skb,
+			       sizeof(struct sadb_address) + sockaddr_size);
 		addr->sadb_address_len =
 			(sizeof(struct sadb_address)+sockaddr_size)/
 			sizeof(uint64_t);
@@ -951,8 +946,7 @@ static struct sk_buff *__pfkey_xfrm_state2msg(const struct xfrm_state *x,
 
 	/* auth key */
 	if (add_keys && auth_key_size) {
-		key = (struct sadb_key *) skb_put(skb,
-						  sizeof(struct sadb_key)+auth_key_size);
+		key = skb_put(skb, sizeof(struct sadb_key) + auth_key_size);
 		key->sadb_key_len = (sizeof(struct sadb_key) + auth_key_size) /
 			sizeof(uint64_t);
 		key->sadb_key_exttype = SADB_EXT_KEY_AUTH;
@@ -962,8 +956,7 @@ static struct sk_buff *__pfkey_xfrm_state2msg(const struct xfrm_state *x,
 	}
 	/* encrypt key */
 	if (add_keys && encrypt_key_size) {
-		key = (struct sadb_key *) skb_put(skb,
-						  sizeof(struct sadb_key)+encrypt_key_size);
+		key = skb_put(skb, sizeof(struct sadb_key) + encrypt_key_size);
 		key->sadb_key_len = (sizeof(struct sadb_key) +
 				     encrypt_key_size) / sizeof(uint64_t);
 		key->sadb_key_exttype = SADB_EXT_KEY_ENCRYPT;
@@ -974,7 +967,7 @@ static struct sk_buff *__pfkey_xfrm_state2msg(const struct xfrm_state *x,
 	}
 
 	/* sa */
-	sa2 = (struct sadb_x_sa2 *)  skb_put(skb, sizeof(struct sadb_x_sa2));
+	sa2 = skb_put(skb, sizeof(struct sadb_x_sa2));
 	sa2->sadb_x_sa2_len = sizeof(struct sadb_x_sa2)/sizeof(uint64_t);
 	sa2->sadb_x_sa2_exttype = SADB_X_EXT_SA2;
 	if ((mode = pfkey_mode_from_xfrm(x->props.mode)) < 0) {
@@ -992,7 +985,7 @@ static struct sk_buff *__pfkey_xfrm_state2msg(const struct xfrm_state *x,
 		struct sadb_x_nat_t_port *n_port;
 
 		/* type */
-		n_type = (struct sadb_x_nat_t_type*) skb_put(skb, sizeof(*n_type));
+		n_type = skb_put(skb, sizeof(*n_type));
 		n_type->sadb_x_nat_t_type_len = sizeof(*n_type)/sizeof(uint64_t);
 		n_type->sadb_x_nat_t_type_exttype = SADB_X_EXT_NAT_T_TYPE;
 		n_type->sadb_x_nat_t_type_type = natt->encap_type;
@@ -1001,14 +994,14 @@ static struct sk_buff *__pfkey_xfrm_state2msg(const struct xfrm_state *x,
 		n_type->sadb_x_nat_t_type_reserved[2] = 0;
 
 		/* source port */
-		n_port = (struct sadb_x_nat_t_port*) skb_put(skb, sizeof (*n_port));
+		n_port = skb_put(skb, sizeof(*n_port));
 		n_port->sadb_x_nat_t_port_len = sizeof(*n_port)/sizeof(uint64_t);
 		n_port->sadb_x_nat_t_port_exttype = SADB_X_EXT_NAT_T_SPORT;
 		n_port->sadb_x_nat_t_port_port = natt->encap_sport;
 		n_port->sadb_x_nat_t_port_reserved = 0;
 
 		/* dest port */
-		n_port = (struct sadb_x_nat_t_port*) skb_put(skb, sizeof (*n_port));
+		n_port = skb_put(skb, sizeof(*n_port));
 		n_port->sadb_x_nat_t_port_len = sizeof(*n_port)/sizeof(uint64_t);
 		n_port->sadb_x_nat_t_port_exttype = SADB_X_EXT_NAT_T_DPORT;
 		n_port->sadb_x_nat_t_port_port = natt->encap_dport;
@@ -1017,8 +1010,8 @@ static struct sk_buff *__pfkey_xfrm_state2msg(const struct xfrm_state *x,
 
 	/* security context */
 	if (xfrm_ctx) {
-		sec_ctx = (struct sadb_x_sec_ctx *) skb_put(skb,
-				sizeof(struct sadb_x_sec_ctx) + ctx_size);
+		sec_ctx = skb_put(skb,
+				  sizeof(struct sadb_x_sec_ctx) + ctx_size);
 		sec_ctx->sadb_x_sec_len =
 		  (sizeof(struct sadb_x_sec_ctx) + ctx_size) / sizeof(uint64_t);
 		sec_ctx->sadb_x_sec_exttype = SADB_X_EXT_SEC_CTX;
@@ -1617,7 +1610,7 @@ static struct sk_buff *compose_sadb_supported(const struct sadb_msg *orig,
 	if (!skb)
 		goto out_put_algs;
 
-	hdr = (struct sadb_msg *) skb_put(skb, sizeof(*hdr));
+	hdr = skb_put(skb, sizeof(*hdr));
 	pfkey_hdr_dup(hdr, orig);
 	hdr->sadb_msg_errno = 0;
 	hdr->sadb_msg_len = len / sizeof(uint64_t);
@@ -1626,7 +1619,7 @@ static struct sk_buff *compose_sadb_supported(const struct sadb_msg *orig,
 		struct sadb_supported *sp;
 		struct sadb_alg *ap;
 
-		sp = (struct sadb_supported *) skb_put(skb, auth_len);
+		sp = skb_put(skb, auth_len);
 		ap = (struct sadb_alg *) (sp + 1);
 
 		sp->sadb_supported_len = auth_len / sizeof(uint64_t);
@@ -1647,7 +1640,7 @@ static struct sk_buff *compose_sadb_supported(const struct sadb_msg *orig,
 		struct sadb_supported *sp;
 		struct sadb_alg *ap;
 
-		sp = (struct sadb_supported *) skb_put(skb, enc_len);
+		sp = skb_put(skb, enc_len);
 		ap = (struct sadb_alg *) (sp + 1);
 
 		sp->sadb_supported_len = enc_len / sizeof(uint64_t);
@@ -1721,7 +1714,7 @@ static int key_notify_sa_flush(const struct km_event *c)
 	skb = alloc_skb(sizeof(struct sadb_msg) + 16, GFP_ATOMIC);
 	if (!skb)
 		return -ENOBUFS;
-	hdr = (struct sadb_msg *) skb_put(skb, sizeof(struct sadb_msg));
+	hdr = skb_put(skb, sizeof(struct sadb_msg));
 	hdr->sadb_msg_satype = pfkey_proto2satype(c->data.proto);
 	hdr->sadb_msg_type = SADB_FLUSH;
 	hdr->sadb_msg_seq = c->seq;
@@ -2046,12 +2039,11 @@ static int pfkey_xfrm_policy2msg(struct sk_buff *skb, const struct xfrm_policy *
 	size = pfkey_xfrm_policy2msg_size(xp);
 
 	/* call should fill header later */
-	hdr = (struct sadb_msg *) skb_put(skb, sizeof(struct sadb_msg));
+	hdr = skb_put(skb, sizeof(struct sadb_msg));
 	memset(hdr, 0, size);	/* XXX do we need this ? */
 
 	/* src address */
-	addr = (struct sadb_address*) skb_put(skb,
-					      sizeof(struct sadb_address)+sockaddr_size);
+	addr = skb_put(skb, sizeof(struct sadb_address) + sockaddr_size);
 	addr->sadb_address_len =
 		(sizeof(struct sadb_address)+sockaddr_size)/
 			sizeof(uint64_t);
@@ -2066,8 +2058,7 @@ static int pfkey_xfrm_policy2msg(struct sk_buff *skb, const struct xfrm_policy *
 		BUG();
 
 	/* dst address */
-	addr = (struct sadb_address*) skb_put(skb,
-					      sizeof(struct sadb_address)+sockaddr_size);
+	addr = skb_put(skb, sizeof(struct sadb_address) + sockaddr_size);
 	addr->sadb_address_len =
 		(sizeof(struct sadb_address)+sockaddr_size)/
 			sizeof(uint64_t);
@@ -2081,8 +2072,7 @@ static int pfkey_xfrm_policy2msg(struct sk_buff *skb, const struct xfrm_policy *
 			    xp->family);
 
 	/* hard time */
-	lifetime = (struct sadb_lifetime *)  skb_put(skb,
-						     sizeof(struct sadb_lifetime));
+	lifetime = skb_put(skb, sizeof(struct sadb_lifetime));
 	lifetime->sadb_lifetime_len =
 		sizeof(struct sadb_lifetime)/sizeof(uint64_t);
 	lifetime->sadb_lifetime_exttype = SADB_EXT_LIFETIME_HARD;
@@ -2091,8 +2081,7 @@ static int pfkey_xfrm_policy2msg(struct sk_buff *skb, const struct xfrm_policy *
 	lifetime->sadb_lifetime_addtime = xp->lft.hard_add_expires_seconds;
 	lifetime->sadb_lifetime_usetime = xp->lft.hard_use_expires_seconds;
 	/* soft time */
-	lifetime = (struct sadb_lifetime *)  skb_put(skb,
-						     sizeof(struct sadb_lifetime));
+	lifetime = skb_put(skb, sizeof(struct sadb_lifetime));
 	lifetime->sadb_lifetime_len =
 		sizeof(struct sadb_lifetime)/sizeof(uint64_t);
 	lifetime->sadb_lifetime_exttype = SADB_EXT_LIFETIME_SOFT;
@@ -2101,8 +2090,7 @@ static int pfkey_xfrm_policy2msg(struct sk_buff *skb, const struct xfrm_policy *
 	lifetime->sadb_lifetime_addtime = xp->lft.soft_add_expires_seconds;
 	lifetime->sadb_lifetime_usetime = xp->lft.soft_use_expires_seconds;
 	/* current time */
-	lifetime = (struct sadb_lifetime *)  skb_put(skb,
-						     sizeof(struct sadb_lifetime));
+	lifetime = skb_put(skb, sizeof(struct sadb_lifetime));
 	lifetime->sadb_lifetime_len =
 		sizeof(struct sadb_lifetime)/sizeof(uint64_t);
 	lifetime->sadb_lifetime_exttype = SADB_EXT_LIFETIME_CURRENT;
@@ -2111,7 +2099,7 @@ static int pfkey_xfrm_policy2msg(struct sk_buff *skb, const struct xfrm_policy *
 	lifetime->sadb_lifetime_addtime = xp->curlft.add_time;
 	lifetime->sadb_lifetime_usetime = xp->curlft.use_time;
 
-	pol = (struct sadb_x_policy *)  skb_put(skb, sizeof(struct sadb_x_policy));
+	pol = skb_put(skb, sizeof(struct sadb_x_policy));
 	pol->sadb_x_policy_len = sizeof(struct sadb_x_policy)/sizeof(uint64_t);
 	pol->sadb_x_policy_exttype = SADB_X_EXT_POLICY;
 	pol->sadb_x_policy_type = IPSEC_POLICY_DISCARD;
@@ -2139,7 +2127,7 @@ static int pfkey_xfrm_policy2msg(struct sk_buff *skb, const struct xfrm_policy *
 		} else {
 			size -= 2*socklen;
 		}
-		rq = (void*)skb_put(skb, req_size);
+		rq = skb_put(skb, req_size);
 		pol->sadb_x_policy_len += req_size/8;
 		memset(rq, 0, sizeof(*rq));
 		rq->sadb_x_ipsecrequest_len = req_size;
@@ -2169,7 +2157,7 @@ static int pfkey_xfrm_policy2msg(struct sk_buff *skb, const struct xfrm_policy *
 	if ((xfrm_ctx = xp->security)) {
 		int ctx_size = pfkey_xfrm_policy2sec_ctx_size(xp);
 
-		sec_ctx = (struct sadb_x_sec_ctx *) skb_put(skb, ctx_size);
+		sec_ctx = skb_put(skb, ctx_size);
 		sec_ctx->sadb_x_sec_len = ctx_size / sizeof(uint64_t);
 		sec_ctx->sadb_x_sec_exttype = SADB_X_EXT_SEC_CTX;
 		sec_ctx->sadb_x_ctx_doi = xfrm_ctx->ctx_doi;
@@ -2733,7 +2721,7 @@ static int key_notify_policy_flush(const struct km_event *c)
 	skb_out = alloc_skb(sizeof(struct sadb_msg) + 16, GFP_ATOMIC);
 	if (!skb_out)
 		return -ENOBUFS;
-	hdr = (struct sadb_msg *) skb_put(skb_out, sizeof(struct sadb_msg));
+	hdr = skb_put(skb_out, sizeof(struct sadb_msg));
 	hdr->sadb_msg_type = SADB_X_SPDFLUSH;
 	hdr->sadb_msg_seq = c->seq;
 	hdr->sadb_msg_pid = c->portid;
@@ -2917,7 +2905,7 @@ static void dump_ah_combs(struct sk_buff *skb, const struct xfrm_tmpl *t)
 	struct sadb_prop *p;
 	int i;
 
-	p = (struct sadb_prop*)skb_put(skb, sizeof(struct sadb_prop));
+	p = skb_put(skb, sizeof(struct sadb_prop));
 	p->sadb_prop_len = sizeof(struct sadb_prop)/8;
 	p->sadb_prop_exttype = SADB_EXT_PROPOSAL;
 	p->sadb_prop_replay = 32;
@@ -2951,7 +2939,7 @@ static void dump_esp_combs(struct sk_buff *skb, const struct xfrm_tmpl *t)
 	struct sadb_prop *p;
 	int i, k;
 
-	p = (struct sadb_prop*)skb_put(skb, sizeof(struct sadb_prop));
+	p = skb_put(skb, sizeof(struct sadb_prop));
 	p->sadb_prop_len = sizeof(struct sadb_prop)/8;
 	p->sadb_prop_exttype = SADB_EXT_PROPOSAL;
 	p->sadb_prop_replay = 32;
@@ -2977,7 +2965,7 @@ static void dump_esp_combs(struct sk_buff *skb, const struct xfrm_tmpl *t)
 				continue;
 			if (!(aalg_tmpl_set(t, aalg) && aalg->available))
 				continue;
-			c = (struct sadb_comb*)skb_put(skb, sizeof(struct sadb_comb));
+			c = skb_put(skb, sizeof(struct sadb_comb));
 			memset(c, 0, sizeof(*c));
 			p->sadb_prop_len += sizeof(struct sadb_comb)/8;
 			c->sadb_comb_auth = aalg->desc.sadb_alg_id;
@@ -3144,7 +3132,7 @@ static int pfkey_send_acquire(struct xfrm_state *x, struct xfrm_tmpl *t, struct
 	if (skb == NULL)
 		return -ENOMEM;
 
-	hdr = (struct sadb_msg *) skb_put(skb, sizeof(struct sadb_msg));
+	hdr = skb_put(skb, sizeof(struct sadb_msg));
 	hdr->sadb_msg_version = PF_KEY_V2;
 	hdr->sadb_msg_type = SADB_ACQUIRE;
 	hdr->sadb_msg_satype = pfkey_proto2satype(x->id.proto);
@@ -3155,8 +3143,7 @@ static int pfkey_send_acquire(struct xfrm_state *x, struct xfrm_tmpl *t, struct
 	hdr->sadb_msg_pid = 0;
 
 	/* src address */
-	addr = (struct sadb_address*) skb_put(skb,
-					      sizeof(struct sadb_address)+sockaddr_size);
+	addr = skb_put(skb, sizeof(struct sadb_address) + sockaddr_size);
 	addr->sadb_address_len =
 		(sizeof(struct sadb_address)+sockaddr_size)/
 			sizeof(uint64_t);
@@ -3171,8 +3158,7 @@ static int pfkey_send_acquire(struct xfrm_state *x, struct xfrm_tmpl *t, struct
 		BUG();
 
 	/* dst address */
-	addr = (struct sadb_address*) skb_put(skb,
-					      sizeof(struct sadb_address)+sockaddr_size);
+	addr = skb_put(skb, sizeof(struct sadb_address) + sockaddr_size);
 	addr->sadb_address_len =
 		(sizeof(struct sadb_address)+sockaddr_size)/
 			sizeof(uint64_t);
@@ -3186,7 +3172,7 @@ static int pfkey_send_acquire(struct xfrm_state *x, struct xfrm_tmpl *t, struct
 	if (!addr->sadb_address_prefixlen)
 		BUG();
 
-	pol = (struct sadb_x_policy *)  skb_put(skb, sizeof(struct sadb_x_policy));
+	pol = skb_put(skb, sizeof(struct sadb_x_policy));
 	pol->sadb_x_policy_len = sizeof(struct sadb_x_policy)/sizeof(uint64_t);
 	pol->sadb_x_policy_exttype = SADB_X_EXT_POLICY;
 	pol->sadb_x_policy_type = IPSEC_POLICY_IPSEC;
@@ -3203,8 +3189,8 @@ static int pfkey_send_acquire(struct xfrm_state *x, struct xfrm_tmpl *t, struct
 
 	/* security context */
 	if (xfrm_ctx) {
-		sec_ctx = (struct sadb_x_sec_ctx *) skb_put(skb,
-				sizeof(struct sadb_x_sec_ctx) + ctx_size);
+		sec_ctx = skb_put(skb,
+				  sizeof(struct sadb_x_sec_ctx) + ctx_size);
 		sec_ctx->sadb_x_sec_len =
 		  (sizeof(struct sadb_x_sec_ctx) + ctx_size) / sizeof(uint64_t);
 		sec_ctx->sadb_x_sec_exttype = SADB_X_EXT_SEC_CTX;
@@ -3346,7 +3332,7 @@ static int pfkey_send_new_mapping(struct xfrm_state *x, xfrm_address_t *ipaddr,
 	if (skb == NULL)
 		return -ENOMEM;
 
-	hdr = (struct sadb_msg *) skb_put(skb, sizeof(struct sadb_msg));
+	hdr = skb_put(skb, sizeof(struct sadb_msg));
 	hdr->sadb_msg_version = PF_KEY_V2;
 	hdr->sadb_msg_type = SADB_X_NAT_T_NEW_MAPPING;
 	hdr->sadb_msg_satype = satype;
@@ -3357,7 +3343,7 @@ static int pfkey_send_new_mapping(struct xfrm_state *x, xfrm_address_t *ipaddr,
 	hdr->sadb_msg_pid = 0;
 
 	/* SA */
-	sa = (struct sadb_sa *) skb_put(skb, sizeof(struct sadb_sa));
+	sa = skb_put(skb, sizeof(struct sadb_sa));
 	sa->sadb_sa_len = sizeof(struct sadb_sa)/sizeof(uint64_t);
 	sa->sadb_sa_exttype = SADB_EXT_SA;
 	sa->sadb_sa_spi = x->id.spi;
@@ -3368,8 +3354,7 @@ static int pfkey_send_new_mapping(struct xfrm_state *x, xfrm_address_t *ipaddr,
 	sa->sadb_sa_flags = 0;
 
 	/* ADDRESS_SRC (old addr) */
-	addr = (struct sadb_address*)
-		skb_put(skb, sizeof(struct sadb_address)+sockaddr_size);
+	addr = skb_put(skb, sizeof(struct sadb_address) + sockaddr_size);
 	addr->sadb_address_len =
 		(sizeof(struct sadb_address)+sockaddr_size)/
 			sizeof(uint64_t);
@@ -3384,15 +3369,14 @@ static int pfkey_send_new_mapping(struct xfrm_state *x, xfrm_address_t *ipaddr,
 		BUG();
 
 	/* NAT_T_SPORT (old port) */
-	n_port = (struct sadb_x_nat_t_port*) skb_put(skb, sizeof (*n_port));
+	n_port = skb_put(skb, sizeof(*n_port));
 	n_port->sadb_x_nat_t_port_len = sizeof(*n_port)/sizeof(uint64_t);
 	n_port->sadb_x_nat_t_port_exttype = SADB_X_EXT_NAT_T_SPORT;
 	n_port->sadb_x_nat_t_port_port = natt->encap_sport;
 	n_port->sadb_x_nat_t_port_reserved = 0;
 
 	/* ADDRESS_DST (new addr) */
-	addr = (struct sadb_address*)
-		skb_put(skb, sizeof(struct sadb_address)+sockaddr_size);
+	addr = skb_put(skb, sizeof(struct sadb_address) + sockaddr_size);
 	addr->sadb_address_len =
 		(sizeof(struct sadb_address)+sockaddr_size)/
 			sizeof(uint64_t);
@@ -3407,7 +3391,7 @@ static int pfkey_send_new_mapping(struct xfrm_state *x, xfrm_address_t *ipaddr,
 		BUG();
 
 	/* NAT_T_DPORT (new port) */
-	n_port = (struct sadb_x_nat_t_port*) skb_put(skb, sizeof (*n_port));
+	n_port = skb_put(skb, sizeof(*n_port));
 	n_port->sadb_x_nat_t_port_len = sizeof(*n_port)/sizeof(uint64_t);
 	n_port->sadb_x_nat_t_port_exttype = SADB_X_EXT_NAT_T_DPORT;
 	n_port->sadb_x_nat_t_port_port = sport;
@@ -3421,7 +3405,7 @@ static int set_sadb_address(struct sk_buff *skb, int sasize, int type,
 			    const struct xfrm_selector *sel)
 {
 	struct sadb_address *addr;
-	addr = (struct sadb_address *)skb_put(skb, sizeof(struct sadb_address) + sasize);
+	addr = skb_put(skb, sizeof(struct sadb_address) + sasize);
 	addr->sadb_address_len = (sizeof(struct sadb_address) + sasize)/8;
 	addr->sadb_address_exttype = type;
 	addr->sadb_address_proto = sel->proto;
@@ -3553,7 +3537,7 @@ static int pfkey_send_migrate(const struct xfrm_selector *sel, u8 dir, u8 type,
 	if (skb == NULL)
 		return -ENOMEM;
 
-	hdr = (struct sadb_msg *)skb_put(skb, sizeof(struct sadb_msg));
+	hdr = skb_put(skb, sizeof(struct sadb_msg));
 	hdr->sadb_msg_version = PF_KEY_V2;
 	hdr->sadb_msg_type = SADB_X_MIGRATE;
 	hdr->sadb_msg_satype = pfkey_proto2satype(m->proto);
@@ -3574,7 +3558,7 @@ static int pfkey_send_migrate(const struct xfrm_selector *sel, u8 dir, u8 type,
 	set_sadb_address(skb, sasize_sel, SADB_EXT_ADDRESS_DST, sel);
 
 	/* policy information */
-	pol = (struct sadb_x_policy *)skb_put(skb, sizeof(struct sadb_x_policy));
+	pol = skb_put(skb, sizeof(struct sadb_x_policy));
 	pol->sadb_x_policy_len = size_pol / 8;
 	pol->sadb_x_policy_exttype = SADB_X_EXT_POLICY;
 	pol->sadb_x_policy_type = IPSEC_POLICY_IPSEC;
diff --git a/net/mac80211/cfg.c b/net/mac80211/cfg.c
index f9eb2486d550..a354f1939e49 100644
--- a/net/mac80211/cfg.c
+++ b/net/mac80211/cfg.c
@@ -1107,7 +1107,7 @@ static void ieee80211_send_layer2_update(struct sta_info *sta)
 	skb = dev_alloc_skb(sizeof(*msg));
 	if (!skb)
 		return;
-	msg = (struct iapp_layer2_update *)skb_put(skb, sizeof(*msg));
+	msg = skb_put(skb, sizeof(*msg));
 
 	/* 802.2 Type 1 Logical Link Control (LLC) Exchange Identifier (XID)
 	 * Update response frame; IEEE Std 802.2-1998, 5.4.1.2.1 */
@@ -3414,7 +3414,7 @@ static int ieee80211_probe_client(struct wiphy *wiphy, struct net_device *dev,
 
 	skb_reserve(skb, local->hw.extra_tx_headroom);
 
-	nullfunc = (void *) skb_put(skb, size);
+	nullfunc = skb_put(skb, size);
 	nullfunc->frame_control = fc;
 	nullfunc->duration_id = 0;
 	memcpy(nullfunc->addr1, sta->sta.addr, ETH_ALEN);
diff --git a/net/mac80211/ht.c b/net/mac80211/ht.c
index 927215d4dd8f..c92df492e898 100644
--- a/net/mac80211/ht.c
+++ b/net/mac80211/ht.c
@@ -459,7 +459,7 @@ int ieee80211_send_smps_action(struct ieee80211_sub_if_data *sdata,
 		return -ENOMEM;
 
 	skb_reserve(skb, local->hw.extra_tx_headroom);
-	action_frame = (void *)skb_put(skb, 27);
+	action_frame = skb_put(skb, 27);
 	memcpy(action_frame->da, da, ETH_ALEN);
 	memcpy(action_frame->sa, sdata->dev->dev_addr, ETH_ALEN);
 	memcpy(action_frame->bssid, bssid, ETH_ALEN);
diff --git a/net/mac80211/mesh.c b/net/mac80211/mesh.c
index 861697f2d75b..a550c707cd8a 100644
--- a/net/mac80211/mesh.c
+++ b/net/mac80211/mesh.c
@@ -1265,7 +1265,7 @@ static int mesh_fwd_csa_frame(struct ieee80211_sub_if_data *sdata,
 	if (!skb)
 		return -ENOMEM;
 	skb_reserve(skb, local->tx_headroom);
-	mgmt_fwd = (struct ieee80211_mgmt *) skb_put(skb, len);
+	mgmt_fwd = skb_put(skb, len);
 
 	/* offset_ttl is based on whether the secondary channel
 	 * offset is available or not. Subtract 1 from the mesh TTL
diff --git a/net/mac80211/mesh_ps.c b/net/mac80211/mesh_ps.c
index 96c987e641b3..d8cd91424175 100644
--- a/net/mac80211/mesh_ps.c
+++ b/net/mac80211/mesh_ps.c
@@ -30,7 +30,7 @@ static struct sk_buff *mps_qos_null_get(struct sta_info *sta)
 		return NULL;
 	skb_reserve(skb, local->hw.extra_tx_headroom);
 
-	nullfunc = (struct ieee80211_hdr *) skb_put(skb, size);
+	nullfunc = skb_put(skb, size);
 	fc = cpu_to_le16(IEEE80211_FTYPE_DATA | IEEE80211_STYPE_QOS_NULLFUNC);
 	ieee80211_fill_mesh_addresses(nullfunc, &fc, sta->sta.addr,
 				      sdata->vif.addr);
diff --git a/net/mac80211/sta_info.c b/net/mac80211/sta_info.c
index 46e1809356f6..69615016d5bf 100644
--- a/net/mac80211/sta_info.c
+++ b/net/mac80211/sta_info.c
@@ -1312,7 +1312,7 @@ static void ieee80211_send_null_response(struct sta_info *sta, int tid,
 
 	skb_reserve(skb, local->hw.extra_tx_headroom);
 
-	nullfunc = (void *) skb_put(skb, size);
+	nullfunc = skb_put(skb, size);
 	nullfunc->frame_control = fc;
 	nullfunc->duration_id = 0;
 	memcpy(nullfunc->addr1, sta->sta.addr, ETH_ALEN);
diff --git a/net/mac80211/tdls.c b/net/mac80211/tdls.c
index 86740670102d..709ef02fe67e 100644
--- a/net/mac80211/tdls.c
+++ b/net/mac80211/tdls.c
@@ -49,7 +49,7 @@ static void ieee80211_tdls_add_ext_capab(struct ieee80211_sub_if_data *sdata,
 			  !ifmgd->tdls_wider_bw_prohibited;
 	struct ieee80211_supported_band *sband = ieee80211_get_sband(sdata);
 	bool vht = sband && sband->vht_cap.vht_supported;
-	u8 *pos = (void *)skb_put(skb, 10);
+	u8 *pos = skb_put(skb, 10);
 
 	*pos++ = WLAN_EID_EXT_CAPABILITY;
 	*pos++ = 8; /* len */
@@ -168,7 +168,7 @@ static void ieee80211_tdls_add_oper_classes(struct ieee80211_sub_if_data *sdata,
 
 static void ieee80211_tdls_add_bss_coex_ie(struct sk_buff *skb)
 {
-	u8 *pos = (void *)skb_put(skb, 3);
+	u8 *pos = skb_put(skb, 3);
 
 	*pos++ = WLAN_EID_BSS_COEX_2040;
 	*pos++ = 1; /* len */
@@ -209,7 +209,7 @@ static void ieee80211_tdls_add_link_ie(struct ieee80211_sub_if_data *sdata,
 		rsp_addr = sdata->vif.addr;
 	}
 
-	lnkid = (void *)skb_put(skb, sizeof(struct ieee80211_tdls_lnkie));
+	lnkid = skb_put(skb, sizeof(struct ieee80211_tdls_lnkie));
 
 	lnkid->ie_type = WLAN_EID_LINK_ID;
 	lnkid->ie_len = sizeof(struct ieee80211_tdls_lnkie) - 2;
@@ -223,7 +223,7 @@ static void
 ieee80211_tdls_add_aid(struct ieee80211_sub_if_data *sdata, struct sk_buff *skb)
 {
 	struct ieee80211_if_managed *ifmgd = &sdata->u.mgd;
-	u8 *pos = (void *)skb_put(skb, 4);
+	u8 *pos = skb_put(skb, 4);
 
 	*pos++ = WLAN_EID_AID;
 	*pos++ = 2; /* len */
@@ -745,7 +745,7 @@ ieee80211_prep_tdls_encap_data(struct wiphy *wiphy, struct net_device *dev,
 	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 	struct ieee80211_tdls_data *tf;
 
-	tf = (void *)skb_put(skb, offsetof(struct ieee80211_tdls_data, u));
+	tf = skb_put(skb, offsetof(struct ieee80211_tdls_data, u));
 
 	memcpy(tf->da, peer, ETH_ALEN);
 	memcpy(tf->sa, sdata->vif.addr, ETH_ALEN);
diff --git a/net/mac80211/tx.c b/net/mac80211/tx.c
index 18c5d6e6305d..ec5a9a72797e 100644
--- a/net/mac80211/tx.c
+++ b/net/mac80211/tx.c
@@ -3874,7 +3874,7 @@ static void __ieee80211_beacon_add_tim(struct ieee80211_sub_if_data *sdata,
 			ps->dtim_count--;
 	}
 
-	tim = pos = (u8 *) skb_put(skb, 6);
+	tim = pos = skb_put(skb, 6);
 	*pos++ = WLAN_EID_TIM;
 	*pos++ = 4;
 	*pos++ = ps->dtim_count;
diff --git a/net/mac80211/wpa.c b/net/mac80211/wpa.c
index cc19614ff4e6..0d722ea98a1b 100644
--- a/net/mac80211/wpa.c
+++ b/net/mac80211/wpa.c
@@ -949,7 +949,7 @@ ieee80211_crypto_aes_cmac_encrypt(struct ieee80211_tx_data *tx)
 	if (WARN_ON(skb_tailroom(skb) < sizeof(*mmie)))
 		return TX_DROP;
 
-	mmie = (struct ieee80211_mmie *) skb_put(skb, sizeof(*mmie));
+	mmie = skb_put(skb, sizeof(*mmie));
 	mmie->element_id = WLAN_EID_MMIE;
 	mmie->length = sizeof(*mmie) - 2;
 	mmie->key_id = cpu_to_le16(key->conf.keyidx);
@@ -993,7 +993,7 @@ ieee80211_crypto_aes_cmac_256_encrypt(struct ieee80211_tx_data *tx)
 	if (WARN_ON(skb_tailroom(skb) < sizeof(*mmie)))
 		return TX_DROP;
 
-	mmie = (struct ieee80211_mmie_16 *)skb_put(skb, sizeof(*mmie));
+	mmie = skb_put(skb, sizeof(*mmie));
 	mmie->element_id = WLAN_EID_MMIE;
 	mmie->length = sizeof(*mmie) - 2;
 	mmie->key_id = cpu_to_le16(key->conf.keyidx);
@@ -1138,7 +1138,7 @@ ieee80211_crypto_aes_gmac_encrypt(struct ieee80211_tx_data *tx)
 	if (WARN_ON(skb_tailroom(skb) < sizeof(*mmie)))
 		return TX_DROP;
 
-	mmie = (struct ieee80211_mmie_16 *)skb_put(skb, sizeof(*mmie));
+	mmie = skb_put(skb, sizeof(*mmie));
 	mmie->element_id = WLAN_EID_MMIE;
 	mmie->length = sizeof(*mmie) - 2;
 	mmie->key_id = cpu_to_le16(key->conf.keyidx);
diff --git a/net/netfilter/nfnetlink_log.c b/net/netfilter/nfnetlink_log.c
index da9704971a83..94ec0d0765a8 100644
--- a/net/netfilter/nfnetlink_log.c
+++ b/net/netfilter/nfnetlink_log.c
@@ -590,7 +590,7 @@ __build_packet_message(struct nfnl_log_net *log,
 		if (skb_tailroom(inst->skb) < nla_total_size(data_len))
 			goto nla_put_failure;
 
-		nla = (struct nlattr *)skb_put(inst->skb, nla_total_size(data_len));
+		nla = skb_put(inst->skb, nla_total_size(data_len));
 		nla->nla_type = NFULA_PAYLOAD;
 		nla->nla_len = size;
 
diff --git a/net/netfilter/nfnetlink_queue.c b/net/netfilter/nfnetlink_queue.c
index 8a0f218b7938..1b17a1b445a3 100644
--- a/net/netfilter/nfnetlink_queue.c
+++ b/net/netfilter/nfnetlink_queue.c
@@ -589,7 +589,7 @@ nfqnl_build_packet_message(struct net *net, struct nfqnl_instance *queue,
 		if (skb_tailroom(skb) < sizeof(*nla) + hlen)
 			goto nla_put_failure;
 
-		nla = (struct nlattr *)skb_put(skb, sizeof(*nla));
+		nla = skb_put(skb, sizeof(*nla));
 		nla->nla_type = NFQA_PAYLOAD;
 		nla->nla_len = nla_attr_size(data_len);
 
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index bd24a975fd49..a88745e4b7df 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -2104,7 +2104,7 @@ __nlmsg_put(struct sk_buff *skb, u32 portid, u32 seq, int type, int len, int fla
 	struct nlmsghdr *nlh;
 	int size = nlmsg_msg_size(len);
 
-	nlh = (struct nlmsghdr *)skb_put(skb, NLMSG_ALIGN(size));
+	nlh = skb_put(skb, NLMSG_ALIGN(size));
 	nlh->nlmsg_type = type;
 	nlh->nlmsg_len = size;
 	nlh->nlmsg_flags = flags;
diff --git a/net/nfc/digital_core.c b/net/nfc/digital_core.c
index 0fd5518bf252..fec47a7d0092 100644
--- a/net/nfc/digital_core.c
+++ b/net/nfc/digital_core.c
@@ -74,8 +74,8 @@ void digital_skb_add_crc(struct sk_buff *skb, crc_func_t crc_func, u16 init,
 	if (msb_first)
 		crc = __fswab16(crc);
 
-	*skb_put(skb, 1) = crc & 0xFF;
-	*skb_put(skb, 1) = (crc >> 8) & 0xFF;
+	*(u8 *)skb_put(skb, 1) = crc & 0xFF;
+	*(u8 *)skb_put(skb, 1) = (crc >> 8) & 0xFF;
 }
 
 int digital_skb_check_crc(struct sk_buff *skb, crc_func_t crc_func,
diff --git a/net/nfc/digital_dep.c b/net/nfc/digital_dep.c
index f44f75a2a4d5..82471af5553e 100644
--- a/net/nfc/digital_dep.c
+++ b/net/nfc/digital_dep.c
@@ -654,7 +654,7 @@ static int digital_in_send_rtox(struct nfc_digital_dev *ddev,
 	if (!skb)
 		return -ENOMEM;
 
-	*skb_put(skb, 1) = rtox;
+	*(u8 *)skb_put(skb, 1) = rtox;
 
 	skb_push(skb, sizeof(struct digital_dep_req_res));
 
diff --git a/net/nfc/digital_technology.c b/net/nfc/digital_technology.c
index d9080dec5d27..fae6d31b377c 100644
--- a/net/nfc/digital_technology.c
+++ b/net/nfc/digital_technology.c
@@ -266,8 +266,8 @@ static int digital_in_send_rats(struct nfc_digital_dev *ddev,
 	if (!skb)
 		return -ENOMEM;
 
-	*skb_put(skb, 1) = DIGITAL_RATS_BYTE1;
-	*skb_put(skb, 1) = DIGITAL_RATS_PARAM;
+	*(u8 *)skb_put(skb, 1) = DIGITAL_RATS_BYTE1;
+	*(u8 *)skb_put(skb, 1) = DIGITAL_RATS_PARAM;
 
 	rc = digital_in_send_cmd(ddev, skb, 30, digital_in_recv_ats,
 				 target);
@@ -470,8 +470,8 @@ static int digital_in_send_sdd_req(struct nfc_digital_dev *ddev,
 	else
 		sel_cmd = DIGITAL_CMD_SEL_REQ_CL3;
 
-	*skb_put(skb, sizeof(u8)) = sel_cmd;
-	*skb_put(skb, sizeof(u8)) = DIGITAL_SDD_REQ_SEL_PAR;
+	*(u8 *)skb_put(skb, sizeof(u8)) = sel_cmd;
+	*(u8 *)skb_put(skb, sizeof(u8)) = DIGITAL_SDD_REQ_SEL_PAR;
 
 	return digital_in_send_cmd(ddev, skb, 30, digital_in_recv_sdd_res,
 				   target);
@@ -541,7 +541,7 @@ int digital_in_send_sens_req(struct nfc_digital_dev *ddev, u8 rf_tech)
 	if (!skb)
 		return -ENOMEM;
 
-	*skb_put(skb, sizeof(u8)) = DIGITAL_CMD_SENS_REQ;
+	*(u8 *)skb_put(skb, sizeof(u8)) = DIGITAL_CMD_SENS_REQ;
 
 	rc = digital_in_send_cmd(ddev, skb, 30, digital_in_recv_sens_res, NULL);
 	if (rc)
@@ -625,8 +625,7 @@ static int digital_in_send_attrib_req(struct nfc_digital_dev *ddev,
 	if (!skb)
 		return -ENOMEM;
 
-	attrib_req = (struct digital_attrib_req *)skb_put(skb,
-							  sizeof(*attrib_req));
+	attrib_req = skb_put(skb, sizeof(*attrib_req));
 
 	attrib_req->cmd = DIGITAL_CMD_ATTRIB_REQ;
 	memcpy(attrib_req->nfcid0, sensb_res->nfcid0,
@@ -730,8 +729,7 @@ int digital_in_send_sensb_req(struct nfc_digital_dev *ddev, u8 rf_tech)
 	if (!skb)
 		return -ENOMEM;
 
-	sensb_req = (struct digital_sensb_req *)skb_put(skb,
-							sizeof(*sensb_req));
+	sensb_req = skb_put(skb, sizeof(*sensb_req));
 
 	sensb_req->cmd = DIGITAL_CMD_SENSB_REQ;
 	sensb_req->afi = 0x00; /* All families and sub-families */
@@ -939,7 +937,7 @@ static int digital_tg_send_sel_res(struct nfc_digital_dev *ddev)
 	if (!skb)
 		return -ENOMEM;
 
-	*skb_put(skb, 1) = DIGITAL_SEL_RES_NFC_DEP;
+	*(u8 *)skb_put(skb, 1) = DIGITAL_SEL_RES_NFC_DEP;
 
 	if (!DIGITAL_DRV_CAPS_TG_CRC(ddev))
 		digital_skb_add_crc_a(skb);
diff --git a/net/nfc/hci/core.c b/net/nfc/hci/core.c
index 8741ad47a6fb..3a0c94590411 100644
--- a/net/nfc/hci/core.c
+++ b/net/nfc/hci/core.c
@@ -874,7 +874,7 @@ static void nfc_hci_recv_from_llc(struct nfc_hci_dev *hdev, struct sk_buff *skb)
 			return;
 		}
 
-		*skb_put(hcp_skb, NFC_HCI_HCP_PACKET_HEADER_LEN) = pipe;
+		*(u8 *)skb_put(hcp_skb, NFC_HCI_HCP_PACKET_HEADER_LEN) = pipe;
 
 		skb_queue_walk(&hdev->rx_hcp_frags, frag_skb) {
 			msg_len = frag_skb->len - NFC_HCI_HCP_PACKET_HEADER_LEN;
diff --git a/net/nfc/hci/llc_shdlc.c b/net/nfc/hci/llc_shdlc.c
index 401c7e255273..9ab4a05f086f 100644
--- a/net/nfc/hci/llc_shdlc.c
+++ b/net/nfc/hci/llc_shdlc.c
@@ -382,8 +382,8 @@ static int llc_shdlc_connect_initiate(struct llc_shdlc *shdlc)
 	if (skb == NULL)
 		return -ENOMEM;
 
-	*skb_put(skb, 1) = SHDLC_MAX_WINDOW;
-	*skb_put(skb, 1) = SHDLC_SREJ_SUPPORT ? 1 : 0;
+	*(u8 *)skb_put(skb, 1) = SHDLC_MAX_WINDOW;
+	*(u8 *)skb_put(skb, 1) = SHDLC_SREJ_SUPPORT ? 1 : 0;
 
 	return llc_shdlc_send_u_frame(shdlc, skb, U_FRAME_RSET);
 }
diff --git a/net/nfc/nci/core.c b/net/nfc/nci/core.c
index 17b9f1ce23db..a3dac34cf790 100644
--- a/net/nfc/nci/core.c
+++ b/net/nfc/nci/core.c
@@ -1341,7 +1341,7 @@ int nci_send_cmd(struct nci_dev *ndev, __u16 opcode, __u8 plen, void *payload)
 		return -ENOMEM;
 	}
 
-	hdr = (struct nci_ctrl_hdr *) skb_put(skb, NCI_CTRL_HDR_SIZE);
+	hdr = skb_put(skb, NCI_CTRL_HDR_SIZE);
 	hdr->gid = nci_opcode_gid(opcode);
 	hdr->oid = nci_opcode_oid(opcode);
 	hdr->plen = plen;
diff --git a/net/nfc/nci/hci.c b/net/nfc/nci/hci.c
index d4a53ce818c3..d1119bb35f24 100644
--- a/net/nfc/nci/hci.c
+++ b/net/nfc/nci/hci.c
@@ -472,7 +472,7 @@ void nci_hci_data_received_cb(void *context,
 			return;
 		}
 
-		*skb_put(hcp_skb, NCI_HCI_HCP_PACKET_HEADER_LEN) = pipe;
+		*(u8 *)skb_put(hcp_skb, NCI_HCI_HCP_PACKET_HEADER_LEN) = pipe;
 
 		skb_queue_walk(&ndev->hci_dev->rx_hcp_frags, frag_skb) {
 			msg_len = frag_skb->len - NCI_HCI_HCP_PACKET_HEADER_LEN;
diff --git a/net/nfc/nci/spi.c b/net/nfc/nci/spi.c
index d904cd2f1442..a502a334918a 100644
--- a/net/nfc/nci/spi.c
+++ b/net/nfc/nci/spi.c
@@ -86,8 +86,8 @@ int nci_spi_send(struct nci_spi *nspi,
 		u16 crc;
 
 		crc = crc_ccitt(CRC_INIT, skb->data, skb->len);
-		*skb_put(skb, 1) = crc >> 8;
-		*skb_put(skb, 1) = crc & 0xFF;
+		*(u8 *)skb_put(skb, 1) = crc >> 8;
+		*(u8 *)skb_put(skb, 1) = crc & 0xFF;
 	}
 
 	if (write_handshake_completion)	{
@@ -172,8 +172,8 @@ static int send_acknowledge(struct nci_spi *nspi, u8 acknowledge)
 	hdr[3] = 0;
 
 	crc = crc_ccitt(CRC_INIT, skb->data, skb->len);
-	*skb_put(skb, 1) = crc >> 8;
-	*skb_put(skb, 1) = crc & 0xFF;
+	*(u8 *)skb_put(skb, 1) = crc >> 8;
+	*(u8 *)skb_put(skb, 1) = crc & 0xFF;
 
 	ret = __nci_spi_send(nspi, skb, 0);
 
diff --git a/net/nfc/nci/uart.c b/net/nfc/nci/uart.c
index cfa7f352c1c3..442f8eadfc76 100644
--- a/net/nfc/nci/uart.c
+++ b/net/nfc/nci/uart.c
@@ -355,7 +355,7 @@ static int nci_uart_default_recv_buf(struct nci_uart *nu, const u8 *data,
 
 		/* Eat byte after byte till full packet header is received */
 		if (nu->rx_skb->len < NCI_CTRL_HDR_SIZE) {
-			*skb_put(nu->rx_skb, 1) = *data++;
+			*(u8 *)skb_put(nu->rx_skb, 1) = *data++;
 			--count;
 			continue;
 		}
diff --git a/net/psample/psample.c b/net/psample/psample.c
index 8aa58a918783..3a6ad0f438dc 100644
--- a/net/psample/psample.c
+++ b/net/psample/psample.c
@@ -264,7 +264,7 @@ void psample_sample_packet(struct psample_group *group, struct sk_buff *skb,
 		int nla_len = nla_total_size(data_len);
 		struct nlattr *nla;
 
-		nla = (struct nlattr *)skb_put(nl_skb, nla_len);
+		nla = skb_put(nl_skb, nla_len);
 		nla->nla_type = PSAMPLE_ATTR_DATA;
 		nla->nla_len = nla_attr_size(data_len);
 
diff --git a/net/qrtr/qrtr.c b/net/qrtr/qrtr.c
index cff679167bdc..5586609afa27 100644
--- a/net/qrtr/qrtr.c
+++ b/net/qrtr/qrtr.c
@@ -259,7 +259,7 @@ static struct sk_buff *qrtr_alloc_ctrl_packet(u32 type, size_t pkt_len,
 		return NULL;
 	skb_reset_transport_header(skb);
 
-	hdr = (struct qrtr_hdr *)skb_put(skb, QRTR_HDR_SIZE);
+	hdr = skb_put(skb, QRTR_HDR_SIZE);
 	hdr->version = cpu_to_le32(QRTR_PROTO_VER);
 	hdr->type = cpu_to_le32(type);
 	hdr->src_node_id = cpu_to_le32(src_node);
diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index 034e916362cf..2c196b3e9cd3 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -1389,7 +1389,7 @@ static struct sctp_chunk *_sctp_make_chunk(const struct sctp_association *asoc,
 		goto nodata;
 
 	/* Make room for the chunk header.  */
-	chunk_hdr = (sctp_chunkhdr_t *)skb_put(skb, sizeof(sctp_chunkhdr_t));
+	chunk_hdr = skb_put(skb, sizeof(sctp_chunkhdr_t));
 	chunk_hdr->type	  = type;
 	chunk_hdr->flags  = flags;
 	chunk_hdr->length = htons(sizeof(sctp_chunkhdr_t));
diff --git a/net/sctp/ulpevent.c b/net/sctp/ulpevent.c
index ec2b3e013c2f..e361f0b57fb6 100644
--- a/net/sctp/ulpevent.c
+++ b/net/sctp/ulpevent.c
@@ -167,8 +167,7 @@ struct sctp_ulpevent  *sctp_ulpevent_make_assoc_change(
 			goto fail;
 
 		skb = sctp_event2skb(event);
-		sac = (struct sctp_assoc_change *) skb_put(skb,
-					sizeof(struct sctp_assoc_change));
+		sac = skb_put(skb, sizeof(struct sctp_assoc_change));
 	}
 
 	/* Socket Extensions for SCTP
@@ -270,8 +269,7 @@ struct sctp_ulpevent *sctp_ulpevent_make_peer_addr_change(
 		goto fail;
 
 	skb = sctp_event2skb(event);
-	spc = (struct sctp_paddr_change *)
-		skb_put(skb, sizeof(struct sctp_paddr_change));
+	spc = skb_put(skb, sizeof(struct sctp_paddr_change));
 
 	/* Sockets API Extensions for SCTP
 	 * Section 5.3.1.2 SCTP_PEER_ADDR_CHANGE
@@ -549,8 +547,7 @@ struct sctp_ulpevent *sctp_ulpevent_make_shutdown_event(
 		goto fail;
 
 	skb = sctp_event2skb(event);
-	sse = (struct sctp_shutdown_event *)
-		skb_put(skb, sizeof(struct sctp_shutdown_event));
+	sse = skb_put(skb, sizeof(struct sctp_shutdown_event));
 
 	/* Socket Extensions for SCTP
 	 * 5.3.1.5 SCTP_SHUTDOWN_EVENT
@@ -612,8 +609,7 @@ struct sctp_ulpevent *sctp_ulpevent_make_adaptation_indication(
 		goto fail;
 
 	skb = sctp_event2skb(event);
-	sai = (struct sctp_adaptation_event *)
-		skb_put(skb, sizeof(struct sctp_adaptation_event));
+	sai = skb_put(skb, sizeof(struct sctp_adaptation_event));
 
 	sai->sai_type = SCTP_ADAPTATION_INDICATION;
 	sai->sai_flags = 0;
@@ -751,8 +747,7 @@ struct sctp_ulpevent *sctp_ulpevent_make_pdapi(
 		goto fail;
 
 	skb = sctp_event2skb(event);
-	pd = (struct sctp_pdapi_event *)
-		skb_put(skb, sizeof(struct sctp_pdapi_event));
+	pd = skb_put(skb, sizeof(struct sctp_pdapi_event));
 
 	/* pdapi_type
 	 *   It should be SCTP_PARTIAL_DELIVERY_EVENT
@@ -803,8 +798,7 @@ struct sctp_ulpevent *sctp_ulpevent_make_authkey(
 		goto fail;
 
 	skb = sctp_event2skb(event);
-	ak = (struct sctp_authkey_event *)
-		skb_put(skb, sizeof(struct sctp_authkey_event));
+	ak = skb_put(skb, sizeof(struct sctp_authkey_event));
 
 	ak->auth_type = SCTP_AUTHENTICATION_EVENT;
 	ak->auth_flags = 0;
@@ -842,8 +836,7 @@ struct sctp_ulpevent *sctp_ulpevent_make_sender_dry_event(
 		return NULL;
 
 	skb = sctp_event2skb(event);
-	sdry = (struct sctp_sender_dry_event *)
-		skb_put(skb, sizeof(struct sctp_sender_dry_event));
+	sdry = skb_put(skb, sizeof(struct sctp_sender_dry_event));
 
 	sdry->sender_dry_type = SCTP_SENDER_DRY_EVENT;
 	sdry->sender_dry_flags = 0;
@@ -869,7 +862,7 @@ struct sctp_ulpevent *sctp_ulpevent_make_stream_reset_event(
 		return NULL;
 
 	skb = sctp_event2skb(event);
-	sreset = (struct sctp_stream_reset_event *)skb_put(skb, length);
+	sreset = skb_put(skb, length);
 
 	sreset->strreset_type = SCTP_STREAM_RESET_EVENT;
 	sreset->strreset_flags = flags;
@@ -897,8 +890,7 @@ struct sctp_ulpevent *sctp_ulpevent_make_assoc_reset_event(
 		return NULL;
 
 	skb = sctp_event2skb(event);
-	areset = (struct sctp_assoc_reset_event *)
-		skb_put(skb, sizeof(struct sctp_assoc_reset_event));
+	areset = skb_put(skb, sizeof(struct sctp_assoc_reset_event));
 
 	areset->assocreset_type = SCTP_ASSOC_RESET_EVENT;
 	areset->assocreset_flags = flags;
@@ -925,8 +917,7 @@ struct sctp_ulpevent *sctp_ulpevent_make_stream_change_event(
 		return NULL;
 
 	skb = sctp_event2skb(event);
-	schange = (struct sctp_stream_change_event *)
-		skb_put(skb, sizeof(struct sctp_stream_change_event));
+	schange = skb_put(skb, sizeof(struct sctp_stream_change_event));
 
 	schange->strchange_type = SCTP_STREAM_CHANGE_EVENT;
 	schange->strchange_flags = flags;
diff --git a/net/vmw_vsock/virtio_transport_common.c b/net/vmw_vsock/virtio_transport_common.c
index 24e2054bfbaf..7d6ee03f2762 100644
--- a/net/vmw_vsock/virtio_transport_common.c
+++ b/net/vmw_vsock/virtio_transport_common.c
@@ -99,7 +99,7 @@ static struct sk_buff *virtio_transport_build_skb(void *opaque)
 	if (!skb)
 		return NULL;
 
-	hdr = (struct af_vsockmon_hdr *)skb_put(skb, sizeof(*hdr));
+	hdr = skb_put(skb, sizeof(*hdr));
 
 	/* pkt->hdr is little-endian so no need to byteswap here */
 	hdr->src_cid = pkt->hdr.src_cid;
-- 
2.11.0
