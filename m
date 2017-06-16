From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH v2 5/6] networking: make skb_push & __skb_push return void pointers
Date: Fri, 16 Jun 2017 14:29:23 +0200
Message-ID: <20170616122924.3557-6-johannes@sipsolutions.net>
References: <20170616122924.3557-1-johannes@sipsolutions.net>
Cc: Johannes Berg <johannes.berg@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:32956 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751909AbdFPM3e (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 16 Jun 2017 08:29:34 -0400
In-Reply-To: <20170616122924.3557-1-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes.berg@intel.com>

It seems like a historic accident that these return unsigned char *,
and in many places that means casts are required, more often than not.

Make these functions return void * and remove all the casts across
the tree, adding a (u8 *) cast only where the unsigned char pointer
was used directly, all done with the following spatch:

    @@
    expression SKB, LEN;
    typedef u8;
    identifier fn = { skb_push, __skb_push, skb_push_rcsum };
    @@
    - *(fn(SKB, LEN))
    + *(u8 *)fn(SKB, LEN)

    @@
    expression E, SKB, LEN;
    identifier fn = { skb_push, __skb_push, skb_push_rcsum };
    type T;
    @@
    - E = ((T *)(fn(SKB, LEN)))
    + E = fn(SKB, LEN)

    @@
    expression SKB, LEN;
    identifier fn = { skb_push, __skb_push, skb_push_rcsum };
    @@
    - fn(SKB, LEN)[0]
    + *(u8 *)fn(SKB, LEN)

Note that the last part there converts from push(...)[0] to the
more idiomatic *(u8 *)push(...).

Signed-off-by: Johannes Berg <johannes.berg@intel.com>
---
 drivers/atm/solos-pci.c                            |  2 +-
 drivers/bluetooth/bpa10x.c                         |  2 +-
 drivers/firewire/net.c                             |  8 +++---
 drivers/infiniband/hw/cxgb3/iwch_cm.c              |  6 ++---
 drivers/infiniband/hw/cxgb4/cm.c                   |  2 +-
 drivers/infiniband/ulp/ipoib/ipoib_main.c          |  4 +--
 drivers/infiniband/ulp/opa_vnic/opa_vnic_encap.c   |  2 +-
 drivers/infiniband/ulp/opa_vnic/opa_vnic_netdev.c  |  2 +-
 drivers/isdn/i4l/isdn_ppp.c                        |  2 +-
 drivers/net/arcnet/arc-rawmode.c                   |  2 +-
 drivers/net/arcnet/capmode.c                       |  2 +-
 drivers/net/arcnet/rfc1051.c                       |  2 +-
 drivers/net/arcnet/rfc1201.c                       |  2 +-
 drivers/net/ethernet/broadcom/bcmsysport.c         |  2 +-
 drivers/net/ethernet/chelsio/cxgb/sge.c            |  4 +--
 drivers/net/ethernet/freescale/gianfar.c           |  2 +-
 .../net/ethernet/mellanox/mlx5/core/en_selftest.c  |  2 +-
 drivers/net/ethernet/sun/niu.c                     |  2 +-
 drivers/net/ethernet/toshiba/ps3_gelic_net.c       |  2 +-
 drivers/net/geneve.c                               |  3 +--
 drivers/net/gtp.c                                  |  4 +--
 drivers/net/hippi/rrunner.c                        |  2 +-
 drivers/net/macsec.c                               |  2 +-
 drivers/net/ppp/ppp_async.c                        |  2 +-
 drivers/net/ppp/ppp_generic.c                      |  6 ++---
 drivers/net/ppp/ppp_synctty.c                      |  2 +-
 drivers/net/ppp/pptp.c                             |  2 +-
 drivers/net/usb/gl620a.c                           |  2 +-
 drivers/net/usb/int51x1.c                          |  2 +-
 drivers/net/usb/kaweth.c                           |  2 +-
 drivers/net/usb/lg-vl600.c                         |  2 +-
 drivers/net/usb/net1080.c                          |  2 +-
 drivers/net/usb/qmi_wwan.c                         |  2 +-
 drivers/net/usb/rndis_host.c                       |  2 +-
 drivers/net/vrf.c                                  |  2 +-
 drivers/net/vxlan.c                                |  2 +-
 drivers/net/wimax/i2400m/netdev.c                  |  2 +-
 drivers/net/wireless/admtek/adm8211.c              |  2 +-
 drivers/net/wireless/ath/ar5523/ar5523.c           |  4 +--
 drivers/net/wireless/ath/ath6kl/htc_pipe.c         |  3 +--
 drivers/net/wireless/ath/ath9k/hif_usb.c           |  2 +-
 drivers/net/wireless/ath/ath9k/htc_hst.c           |  3 +--
 drivers/net/wireless/ath/ath9k/wmi.c               |  2 +-
 drivers/net/wireless/ath/carl9170/tx.c             |  2 +-
 drivers/net/wireless/ath/wil6210/txrx.c            |  2 +-
 .../net/wireless/intersil/hostap/hostap_80211_rx.c |  8 +++---
 drivers/net/wireless/intersil/orinoco/main.c       |  7 +++--
 drivers/net/wireless/intersil/p54/txrx.c           |  4 +--
 drivers/net/wireless/intersil/prism54/islpci_eth.c |  5 +---
 drivers/net/wireless/mac80211_hwsim.c              |  4 +--
 drivers/net/wireless/marvell/libertas/rx.c         |  2 +-
 drivers/net/wireless/marvell/libertas_tf/main.c    |  2 +-
 drivers/net/wireless/mediatek/mt7601u/tx.c         |  2 +-
 drivers/net/wireless/realtek/rtl818x/rtl8187/dev.c |  6 ++---
 .../net/wireless/realtek/rtl8xxxu/rtl8xxxu_core.c  |  2 +-
 .../net/wireless/realtek/rtlwifi/rtl8192cu/trx.c   |  2 +-
 drivers/net/wireless/st/cw1200/txrx.c              |  2 +-
 drivers/net/wireless/ti/wl1251/tx.c                |  3 +--
 drivers/net/wireless/ti/wlcore/cmd.c               |  2 +-
 drivers/net/wireless/ti/wlcore/tx.c                |  3 +--
 drivers/net/wireless/zydas/zd1211rw/zd_mac.c       |  3 +--
 drivers/nfc/fdp/i2c.c                              |  4 +--
 drivers/nfc/microread/i2c.c                        |  2 +-
 drivers/nfc/microread/microread.c                  |  4 +--
 drivers/nfc/nfcmrvl/main.c                         |  2 +-
 drivers/nfc/pn533/pn533.c                          |  8 +++---
 drivers/nfc/pn544/i2c.c                            |  2 +-
 drivers/nfc/pn544/pn544.c                          |  8 +++---
 drivers/nfc/st-nci/ndlc.c                          |  2 +-
 drivers/nfc/st21nfca/core.c                        |  6 ++---
 drivers/nfc/st21nfca/dep.c                         | 30 +++++++++++-----------
 drivers/nfc/st21nfca/i2c.c                         |  4 +--
 drivers/s390/net/qeth_l2_main.c                    |  3 +--
 drivers/s390/net/qeth_l3_main.c                    |  6 ++---
 drivers/scsi/cxgbi/cxgb3i/cxgb3i.c                 |  2 +-
 drivers/scsi/cxgbi/cxgb4i/cxgb4i.c                 |  2 +-
 drivers/scsi/fcoe/fcoe_ctlr.c                      |  2 +-
 drivers/scsi/fnic/fnic_fcs.c                       |  7 +++--
 drivers/scsi/qedf/qedf_fip.c                       |  3 +--
 drivers/staging/wilc1000/linux_mon.c               |  6 ++---
 drivers/staging/wlan-ng/p80211conv.c               | 14 ++++------
 drivers/target/iscsi/cxgbit/cxgbit_target.c        |  5 ++--
 drivers/usb/gadget/function/rndis.c                |  2 +-
 include/linux/if_vlan.h                            |  2 +-
 include/linux/skbuff.h                             |  7 +++--
 net/802/fc.c                                       |  4 +--
 net/802/fddi.c                                     |  2 +-
 net/802/hippi.c                                    |  2 +-
 net/8021q/vlan_dev.c                               |  2 +-
 net/appletalk/ddp.c                                |  2 +-
 net/ax25/af_ax25.c                                 |  2 +-
 net/bluetooth/hci_sock.c                           | 12 ++++-----
 net/bluetooth/mgmt_util.c                          |  2 +-
 net/bluetooth/rfcomm/core.c                        |  4 +--
 net/bridge/netfilter/nft_reject_bridge.c           |  2 +-
 net/core/netpoll.c                                 |  4 +--
 net/core/pktgen.c                                  |  6 ++---
 net/core/skbuff.c                                  |  2 +-
 net/dccp/options.c                                 |  2 +-
 net/decnet/dn_dev.c                                |  4 +--
 net/ethernet/eth.c                                 |  2 +-
 net/ipv4/esp4.c                                    |  2 +-
 net/ipv4/ip_gre.c                                  |  2 +-
 net/ipv6/esp6.c                                    |  2 +-
 net/ipv6/exthdrs.c                                 |  6 ++---
 net/ipv6/ip6_gre.c                                 |  2 +-
 net/ipv6/ip6_output.c                              |  4 +--
 net/ipv6/tcp_ipv6.c                                |  2 +-
 net/irda/irnet/irnet_irda.c                        |  2 +-
 net/iucv/af_iucv.c                                 |  3 +--
 net/mac80211/rx.c                                  |  2 +-
 net/mac80211/status.c                              |  2 +-
 net/mac80211/tx.c                                  |  4 +--
 net/ncsi/ncsi-cmd.c                                |  2 +-
 net/nfc/digital_dep.c                              |  2 +-
 net/nfc/digital_technology.c                       |  4 +--
 net/nfc/hci/core.c                                 |  2 +-
 net/nfc/hci/llc_shdlc.c                            |  8 +++---
 net/nfc/nci/data.c                                 |  2 +-
 net/nfc/nci/hci.c                                  |  4 +--
 net/nfc/nci/spi.c                                  |  4 +--
 net/nfc/rawsock.c                                  |  2 +-
 net/sctp/output.c                                  |  2 +-
 net/sctp/sm_statefuns.c                            |  4 +--
 net/sctp/ulpevent.c                                |  8 +++---
 net/wireless/util.c                                |  2 +-
 126 files changed, 204 insertions(+), 234 deletions(-)

diff --git a/drivers/atm/solos-pci.c b/drivers/atm/solos-pci.c
index 4fc99ae1c534..c8f2ca6d8b29 100644
--- a/drivers/atm/solos-pci.c
+++ b/drivers/atm/solos-pci.c
@@ -1174,7 +1174,7 @@ static int psend(struct atm_vcc *vcc, struct sk_buff *skb)
 		}
 	}
 
-	header = (void *)skb_push(skb, sizeof(*header));
+	header = skb_push(skb, sizeof(*header));
 
 	/* This does _not_ include the size of the header */
 	header->size = cpu_to_le16(pktlen);
diff --git a/drivers/bluetooth/bpa10x.c b/drivers/bluetooth/bpa10x.c
index a9932fe57d92..48d10cb5c9a1 100644
--- a/drivers/bluetooth/bpa10x.c
+++ b/drivers/bluetooth/bpa10x.c
@@ -297,7 +297,7 @@ static int bpa10x_send_frame(struct hci_dev *hdev, struct sk_buff *skb)
 		return -ENOMEM;
 
 	/* Prepend skb with frame type */
-	*skb_push(skb, 1) = hci_skb_pkt_type(skb);
+	*(u8 *)skb_push(skb, 1) = hci_skb_pkt_type(skb);
 
 	switch (hci_skb_pkt_type(skb)) {
 	case HCI_COMMAND_PKT:
diff --git a/drivers/firewire/net.c b/drivers/firewire/net.c
index d5040bbd34e8..242359c2d1f1 100644
--- a/drivers/firewire/net.c
+++ b/drivers/firewire/net.c
@@ -219,7 +219,7 @@ static int fwnet_header_create(struct sk_buff *skb, struct net_device *net,
 {
 	struct fwnet_header *h;
 
-	h = (struct fwnet_header *)skb_push(skb, sizeof(*h));
+	h = skb_push(skb, sizeof(*h));
 	put_unaligned_be16(type, &h->h_proto);
 
 	if (net->flags & (IFF_LOOPBACK | IFF_NOARP)) {
@@ -961,16 +961,14 @@ static int fwnet_send_packet(struct fwnet_packet_task *ptask)
 	tx_len = ptask->max_payload;
 	switch (fwnet_get_hdr_lf(&ptask->hdr)) {
 	case RFC2374_HDR_UNFRAG:
-		bufhdr = (struct rfc2734_header *)
-				skb_push(ptask->skb, RFC2374_UNFRAG_HDR_SIZE);
+		bufhdr = skb_push(ptask->skb, RFC2374_UNFRAG_HDR_SIZE);
 		put_unaligned_be32(ptask->hdr.w0, &bufhdr->w0);
 		break;
 
 	case RFC2374_HDR_FIRSTFRAG:
 	case RFC2374_HDR_INTFRAG:
 	case RFC2374_HDR_LASTFRAG:
-		bufhdr = (struct rfc2734_header *)
-				skb_push(ptask->skb, RFC2374_FRAG_HDR_SIZE);
+		bufhdr = skb_push(ptask->skb, RFC2374_FRAG_HDR_SIZE);
 		put_unaligned_be32(ptask->hdr.w0, &bufhdr->w0);
 		put_unaligned_be32(ptask->hdr.w1, &bufhdr->w1);
 		break;
diff --git a/drivers/infiniband/hw/cxgb3/iwch_cm.c b/drivers/infiniband/hw/cxgb3/iwch_cm.c
index 9ae518c01bc2..86975370a4c0 100644
--- a/drivers/infiniband/hw/cxgb3/iwch_cm.c
+++ b/drivers/infiniband/hw/cxgb3/iwch_cm.c
@@ -513,7 +513,7 @@ static void send_mpa_req(struct iwch_ep *ep, struct sk_buff *skb)
 	set_arp_failure_handler(skb, arp_failure_discard);
 	skb_reset_transport_header(skb);
 	len = skb->len;
-	req = (struct tx_data_wr *) skb_push(skb, sizeof(*req));
+	req = skb_push(skb, sizeof(*req));
 	req->wr_hi = htonl(V_WR_OP(FW_WROPCODE_OFLD_TX_DATA)|F_WR_COMPL);
 	req->wr_lo = htonl(V_WR_TID(ep->hwtid));
 	req->len = htonl(len);
@@ -564,7 +564,7 @@ static int send_mpa_reject(struct iwch_ep *ep, const void *pdata, u8 plen)
 	skb->priority = CPL_PRIORITY_DATA;
 	set_arp_failure_handler(skb, arp_failure_discard);
 	skb_reset_transport_header(skb);
-	req = (struct tx_data_wr *) skb_push(skb, sizeof(*req));
+	req = skb_push(skb, sizeof(*req));
 	req->wr_hi = htonl(V_WR_OP(FW_WROPCODE_OFLD_TX_DATA)|F_WR_COMPL);
 	req->wr_lo = htonl(V_WR_TID(ep->hwtid));
 	req->len = htonl(mpalen);
@@ -615,7 +615,7 @@ static int send_mpa_reply(struct iwch_ep *ep, const void *pdata, u8 plen)
 	set_arp_failure_handler(skb, arp_failure_discard);
 	skb_reset_transport_header(skb);
 	len = skb->len;
-	req = (struct tx_data_wr *) skb_push(skb, sizeof(*req));
+	req = skb_push(skb, sizeof(*req));
 	req->wr_hi = htonl(V_WR_OP(FW_WROPCODE_OFLD_TX_DATA)|F_WR_COMPL);
 	req->wr_lo = htonl(V_WR_TID(ep->hwtid));
 	req->len = htonl(len);
diff --git a/drivers/infiniband/hw/cxgb4/cm.c b/drivers/infiniband/hw/cxgb4/cm.c
index 36ae3023e703..76fb39415e18 100644
--- a/drivers/infiniband/hw/cxgb4/cm.c
+++ b/drivers/infiniband/hw/cxgb4/cm.c
@@ -3751,7 +3751,7 @@ static void build_cpl_pass_accept_req(struct sk_buff *skb, int stid , u8 tos)
 	tcp_clear_options(&tmp_opt);
 	tcp_parse_options(&init_net, skb, &tmp_opt, 0, NULL);
 
-	req = (struct cpl_pass_accept_req *)__skb_push(skb, sizeof(*req));
+	req = __skb_push(skb, sizeof(*req));
 	memset(req, 0, sizeof(*req));
 	req->l2info = cpu_to_be16(SYN_INTF_V(intf) |
 			 SYN_MAC_IDX_V(RX_MACIDX_G(
diff --git a/drivers/infiniband/ulp/ipoib/ipoib_main.c b/drivers/infiniband/ulp/ipoib/ipoib_main.c
index a115c0b7a310..5da6f2e9f22e 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_main.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_main.c
@@ -681,7 +681,7 @@ static void push_pseudo_header(struct sk_buff *skb, const char *daddr)
 {
 	struct ipoib_pseudo_header *phdr;
 
-	phdr = (struct ipoib_pseudo_header *)skb_push(skb, sizeof(*phdr));
+	phdr = skb_push(skb, sizeof(*phdr));
 	memcpy(phdr->hwaddr, daddr, INFINIBAND_ALEN);
 }
 
@@ -1129,7 +1129,7 @@ static int ipoib_hard_header(struct sk_buff *skb,
 {
 	struct ipoib_header *header;
 
-	header = (struct ipoib_header *) skb_push(skb, sizeof *header);
+	header = skb_push(skb, sizeof *header);
 
 	header->proto = htons(type);
 	header->reserved = 0;
diff --git a/drivers/infiniband/ulp/opa_vnic/opa_vnic_encap.c b/drivers/infiniband/ulp/opa_vnic/opa_vnic_encap.c
index 2e8fee982436..afa938bd26d6 100644
--- a/drivers/infiniband/ulp/opa_vnic/opa_vnic_encap.c
+++ b/drivers/infiniband/ulp/opa_vnic/opa_vnic_encap.c
@@ -460,7 +460,7 @@ void opa_vnic_encap_skb(struct opa_vnic_adapter *adapter, struct sk_buff *skb)
 	sc = opa_vnic_get_sc(info, skb);
 	l4_hdr = info->vesw.vesw_id;
 
-	mdata = (struct opa_vnic_skb_mdata *)skb_push(skb, sizeof(*mdata));
+	mdata = skb_push(skb, sizeof(*mdata));
 	mdata->vl = opa_vnic_get_vl(adapter, skb);
 	mdata->entropy = entropy;
 	mdata->flags = 0;
diff --git a/drivers/infiniband/ulp/opa_vnic/opa_vnic_netdev.c b/drivers/infiniband/ulp/opa_vnic/opa_vnic_netdev.c
index 905f39dda5aa..fcf75323d62a 100644
--- a/drivers/infiniband/ulp/opa_vnic/opa_vnic_netdev.c
+++ b/drivers/infiniband/ulp/opa_vnic/opa_vnic_netdev.c
@@ -103,7 +103,7 @@ static u16 opa_vnic_select_queue(struct net_device *netdev, struct sk_buff *skb,
 	int rc;
 
 	/* pass entropy and vl as metadata in skb */
-	mdata = (struct opa_vnic_skb_mdata *)skb_push(skb, sizeof(*mdata));
+	mdata = skb_push(skb, sizeof(*mdata));
 	mdata->entropy =  opa_vnic_calc_entropy(adapter, skb);
 	mdata->vl = opa_vnic_get_vl(adapter, skb);
 	rc = adapter->rn_ops->ndo_select_queue(netdev, skb,
diff --git a/drivers/isdn/i4l/isdn_ppp.c b/drivers/isdn/i4l/isdn_ppp.c
index e26cae9baf17..b7e3f1cde683 100644
--- a/drivers/isdn/i4l/isdn_ppp.c
+++ b/drivers/isdn/i4l/isdn_ppp.c
@@ -1312,7 +1312,7 @@ isdn_ppp_xmit(struct sk_buff *skb, struct net_device *netdev)
 	/* check if we should pass this packet
 	 * the filter instructions are constructed assuming
 	 * a four-byte PPP header on each packet */
-	*skb_push(skb, 4) = 1; /* indicate outbound */
+	*(u8 *)skb_push(skb, 4) = 1; /* indicate outbound */
 
 	{
 		__be16 *p = (__be16 *)skb->data;
diff --git a/drivers/net/arcnet/arc-rawmode.c b/drivers/net/arcnet/arc-rawmode.c
index d78f30186642..8c651fdee039 100644
--- a/drivers/net/arcnet/arc-rawmode.c
+++ b/drivers/net/arcnet/arc-rawmode.c
@@ -85,7 +85,7 @@ static int build_header(struct sk_buff *skb, struct net_device *dev,
 			unsigned short type, uint8_t daddr)
 {
 	int hdr_size = ARC_HDR_SIZE;
-	struct archdr *pkt = (struct archdr *)skb_push(skb, hdr_size);
+	struct archdr *pkt = skb_push(skb, hdr_size);
 
 	/* Set the source hardware address.
 	 *
diff --git a/drivers/net/arcnet/capmode.c b/drivers/net/arcnet/capmode.c
index 2056878fb087..a80f4eb9262d 100644
--- a/drivers/net/arcnet/capmode.c
+++ b/drivers/net/arcnet/capmode.c
@@ -101,7 +101,7 @@ static int build_header(struct sk_buff *skb,
 			uint8_t daddr)
 {
 	int hdr_size = ARC_HDR_SIZE;
-	struct archdr *pkt = (struct archdr *)skb_push(skb, hdr_size);
+	struct archdr *pkt = skb_push(skb, hdr_size);
 
 	arc_printk(D_PROTO, dev, "Preparing header for cap packet %x.\n",
 		   *((int *)&pkt->soft.cap.cookie[0]));
diff --git a/drivers/net/arcnet/rfc1051.c b/drivers/net/arcnet/rfc1051.c
index 4b1a75469cb1..a7752a5b647f 100644
--- a/drivers/net/arcnet/rfc1051.c
+++ b/drivers/net/arcnet/rfc1051.c
@@ -162,7 +162,7 @@ static int build_header(struct sk_buff *skb, struct net_device *dev,
 			unsigned short type, uint8_t daddr)
 {
 	int hdr_size = ARC_HDR_SIZE + RFC1051_HDR_SIZE;
-	struct archdr *pkt = (struct archdr *)skb_push(skb, hdr_size);
+	struct archdr *pkt = skb_push(skb, hdr_size);
 	struct arc_rfc1051 *soft = &pkt->soft.rfc1051;
 
 	/* set the protocol ID according to RFC1051 */
diff --git a/drivers/net/arcnet/rfc1201.c b/drivers/net/arcnet/rfc1201.c
index 566da5ecdc9d..a4c856282674 100644
--- a/drivers/net/arcnet/rfc1201.c
+++ b/drivers/net/arcnet/rfc1201.c
@@ -379,7 +379,7 @@ static int build_header(struct sk_buff *skb, struct net_device *dev,
 {
 	struct arcnet_local *lp = netdev_priv(dev);
 	int hdr_size = ARC_HDR_SIZE + RFC1201_HDR_SIZE;
-	struct archdr *pkt = (struct archdr *)skb_push(skb, hdr_size);
+	struct archdr *pkt = skb_push(skb, hdr_size);
 	struct arc_rfc1201 *soft = &pkt->soft.rfc1201;
 
 	/* set the protocol ID according to RFC1201 */
diff --git a/drivers/net/ethernet/broadcom/bcmsysport.c b/drivers/net/ethernet/broadcom/bcmsysport.c
index 5274501428e4..5333601f855f 100644
--- a/drivers/net/ethernet/broadcom/bcmsysport.c
+++ b/drivers/net/ethernet/broadcom/bcmsysport.c
@@ -1099,7 +1099,7 @@ static struct sk_buff *bcm_sysport_insert_tsb(struct sk_buff *skb,
 		skb = nskb;
 	}
 
-	tsb = (struct bcm_tsb *)skb_push(skb, sizeof(*tsb));
+	tsb = skb_push(skb, sizeof(*tsb));
 	/* Zero-out TSB by default */
 	memset(tsb, 0, sizeof(*tsb));
 
diff --git a/drivers/net/ethernet/chelsio/cxgb/sge.c b/drivers/net/ethernet/chelsio/cxgb/sge.c
index d56142b98534..0f13a7f7c1d3 100644
--- a/drivers/net/ethernet/chelsio/cxgb/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb/sge.c
@@ -1801,7 +1801,7 @@ netdev_tx_t t1_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		eth_type = skb_network_offset(skb) == ETH_HLEN ?
 			CPL_ETH_II : CPL_ETH_II_VLAN;
 
-		hdr = (struct cpl_tx_pkt_lso *)skb_push(skb, sizeof(*hdr));
+		hdr = skb_push(skb, sizeof(*hdr));
 		hdr->opcode = CPL_TX_PKT_LSO;
 		hdr->ip_csum_dis = hdr->l4_csum_dis = 0;
 		hdr->ip_hdr_words = ip_hdr(skb)->ihl;
@@ -1849,7 +1849,7 @@ netdev_tx_t t1_start_xmit(struct sk_buff *skb, struct net_device *dev)
 			}
 		}
 
-		cpl = (struct cpl_tx_pkt *)__skb_push(skb, sizeof(*cpl));
+		cpl = __skb_push(skb, sizeof(*cpl));
 		cpl->opcode = CPL_TX_PKT;
 		cpl->ip_csum_dis = 1;    /* SW calculates IP csum */
 		cpl->l4_csum_dis = skb->ip_summed == CHECKSUM_PARTIAL ? 0 : 1;
diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index 0ff166ec3e7e..a79e257bc338 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -2250,7 +2250,7 @@ static int gfar_enet_open(struct net_device *dev)
 
 static inline struct txfcb *gfar_add_fcb(struct sk_buff *skb)
 {
-	struct txfcb *fcb = (struct txfcb *)skb_push(skb, GMAC_FCB_LEN);
+	struct txfcb *fcb = skb_push(skb, GMAC_FCB_LEN);
 
 	memset(fcb, 0, GMAC_FCB_LEN);
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_selftest.c b/drivers/net/ethernet/mellanox/mlx5/core/en_selftest.c
index c456ca07b562..898759fcf9ec 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_selftest.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_selftest.c
@@ -132,7 +132,7 @@ static struct sk_buff *mlx5e_test_get_udp_skb(struct mlx5e_priv *priv)
 	skb_reserve(skb, NET_IP_ALIGN);
 
 	/*  Reserve for ethernet and IP header  */
-	ethh = (struct ethhdr *)skb_push(skb, ETH_HLEN);
+	ethh = skb_push(skb, ETH_HLEN);
 	skb_reset_mac_header(skb);
 
 	skb_set_network_header(skb, skb->len);
diff --git a/drivers/net/ethernet/sun/niu.c b/drivers/net/ethernet/sun/niu.c
index 2dcca249eb9c..46cb7f8955a2 100644
--- a/drivers/net/ethernet/sun/niu.c
+++ b/drivers/net/ethernet/sun/niu.c
@@ -6667,7 +6667,7 @@ static netdev_tx_t niu_start_xmit(struct sk_buff *skb,
 	headroom = align + sizeof(struct tx_pkt_hdr);
 
 	ehdr = (struct ethhdr *) skb->data;
-	tp = (struct tx_pkt_hdr *) skb_push(skb, headroom);
+	tp = skb_push(skb, headroom);
 
 	len = skb->len - sizeof(struct tx_pkt_hdr);
 	tp->flags = cpu_to_le64(niu_compute_tx_flags(skb, ehdr, align, len));
diff --git a/drivers/net/ethernet/toshiba/ps3_gelic_net.c b/drivers/net/ethernet/toshiba/ps3_gelic_net.c
index fa6a06571187..88d74aef218a 100644
--- a/drivers/net/ethernet/toshiba/ps3_gelic_net.c
+++ b/drivers/net/ethernet/toshiba/ps3_gelic_net.c
@@ -754,7 +754,7 @@ static struct sk_buff *gelic_put_vlan_tag(struct sk_buff *skb,
 			return NULL;
 		dev_kfree_skb_any(sk_tmp);
 	}
-	veth = (struct vlan_ethhdr *)skb_push(skb, VLAN_HLEN);
+	veth = skb_push(skb, VLAN_HLEN);
 
 	/* Move the mac addresses to the top of buffer */
 	memmove(skb->data, skb->data + VLAN_HLEN, 2 * ETH_ALEN);
diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
index 7bcf1b52020e..d586ad93aaff 100644
--- a/drivers/net/geneve.c
+++ b/drivers/net/geneve.c
@@ -687,8 +687,7 @@ static int geneve_build_skb(struct dst_entry *dst, struct sk_buff *skb,
 	if (err)
 		goto free_dst;
 
-	gnvh = (struct genevehdr *)__skb_push(skb, sizeof(*gnvh) +
-						   info->options_len);
+	gnvh = __skb_push(skb, sizeof(*gnvh) + info->options_len);
 	geneve_build_header(gnvh, info);
 	skb_set_inner_protocol(skb, htons(ETH_P_TEB));
 	return 0;
diff --git a/drivers/net/gtp.c b/drivers/net/gtp.c
index ca110cd2a4e4..8e333a8a2295 100644
--- a/drivers/net/gtp.c
+++ b/drivers/net/gtp.c
@@ -398,7 +398,7 @@ static inline void gtp0_push_header(struct sk_buff *skb, struct pdp_ctx *pctx)
 	int payload_len = skb->len;
 	struct gtp0_header *gtp0;
 
-	gtp0 = (struct gtp0_header *) skb_push(skb, sizeof(*gtp0));
+	gtp0 = skb_push(skb, sizeof(*gtp0));
 
 	gtp0->flags	= 0x1e; /* v0, GTP-non-prime. */
 	gtp0->type	= GTP_TPDU;
@@ -415,7 +415,7 @@ static inline void gtp1_push_header(struct sk_buff *skb, struct pdp_ctx *pctx)
 	int payload_len = skb->len;
 	struct gtp1_header *gtp1;
 
-	gtp1 = (struct gtp1_header *) skb_push(skb, sizeof(*gtp1));
+	gtp1 = skb_push(skb, sizeof(*gtp1));
 
 	/* Bits    8  7  6  5  4  3  2	1
 	 *	  +--+--+--+--+--+--+--+--+
diff --git a/drivers/net/hippi/rrunner.c b/drivers/net/hippi/rrunner.c
index 7683fd544344..71ddadbf2368 100644
--- a/drivers/net/hippi/rrunner.c
+++ b/drivers/net/hippi/rrunner.c
@@ -1422,7 +1422,7 @@ static netdev_tx_t rr_start_xmit(struct sk_buff *skb,
 		skb = new_skb;
 	}
 
-	ifield = (u32 *)skb_push(skb, 8);
+	ifield = skb_push(skb, 8);
 
 	ifield[0] = 0;
 	ifield[1] = hcb->ifield;
diff --git a/drivers/net/macsec.c b/drivers/net/macsec.c
index 2067dcc71535..e370d7c894cb 100644
--- a/drivers/net/macsec.c
+++ b/drivers/net/macsec.c
@@ -697,7 +697,7 @@ static struct sk_buff *macsec_encrypt(struct sk_buff *skb,
 	unprotected_len = skb->len;
 	eth = eth_hdr(skb);
 	sci_present = send_sci(secy);
-	hh = (struct macsec_eth_header *)skb_push(skb, macsec_extra_len(sci_present));
+	hh = skb_push(skb, macsec_extra_len(sci_present));
 	memmove(hh, eth, 2 * ETH_ALEN);
 
 	pn = tx_sa_update_pn(tx_sa, secy);
diff --git a/drivers/net/ppp/ppp_async.c b/drivers/net/ppp/ppp_async.c
index 32c72db654e2..814fd8fae67d 100644
--- a/drivers/net/ppp/ppp_async.c
+++ b/drivers/net/ppp/ppp_async.c
@@ -802,7 +802,7 @@ process_input_packet(struct asyncppp *ap)
 	proto = p[0];
 	if (proto & 1) {
 		/* protocol is compressed */
-		skb_push(skb, 1)[0] = 0;
+		*(u8 *)skb_push(skb, 1) = 0;
 	} else {
 		if (skb->len < 2)
 			goto err;
diff --git a/drivers/net/ppp/ppp_generic.c b/drivers/net/ppp/ppp_generic.c
index bbded33120fe..d42091f11eb8 100644
--- a/drivers/net/ppp/ppp_generic.c
+++ b/drivers/net/ppp/ppp_generic.c
@@ -1490,7 +1490,7 @@ ppp_send_frame(struct ppp *ppp, struct sk_buff *skb)
 		/* check if we should pass this packet */
 		/* the filter instructions are constructed assuming
 		   a four-byte PPP header on each packet */
-		*skb_push(skb, 2) = 1;
+		*(u8 *)skb_push(skb, 2) = 1;
 		if (ppp->pass_filter &&
 		    BPF_PROG_RUN(ppp->pass_filter, skb) == 0) {
 			if (ppp->debug & 1)
@@ -2133,7 +2133,7 @@ ppp_receive_nonmp_frame(struct ppp *ppp, struct sk_buff *skb)
 			if (skb_unclone(skb, GFP_ATOMIC))
 				goto err;
 
-			*skb_push(skb, 2) = 0;
+			*(u8 *)skb_push(skb, 2) = 0;
 			if (ppp->pass_filter &&
 			    BPF_PROG_RUN(ppp->pass_filter, skb) == 0) {
 				if (ppp->debug & 1)
@@ -2267,7 +2267,7 @@ ppp_receive_mp_frame(struct ppp *ppp, struct sk_buff *skb, struct channel *pch)
 	 * Do protocol ID decompression on the first fragment of each packet.
 	 */
 	if ((PPP_MP_CB(skb)->BEbits & B) && (skb->data[0] & 1))
-		*skb_push(skb, 1) = 0;
+		*(u8 *)skb_push(skb, 1) = 0;
 
 	/*
 	 * Expand sequence number to 32 bits, making it as close
diff --git a/drivers/net/ppp/ppp_synctty.c b/drivers/net/ppp/ppp_synctty.c
index ce2300c0bcbf..ef08590db873 100644
--- a/drivers/net/ppp/ppp_synctty.c
+++ b/drivers/net/ppp/ppp_synctty.c
@@ -711,7 +711,7 @@ ppp_sync_input(struct syncppp *ap, const unsigned char *buf,
 	/* decompress protocol field if compressed */
 	if (p[0] & 1) {
 		/* protocol is compressed */
-		skb_push(skb, 1)[0] = 0;
+		*(u8 *)skb_push(skb, 1) = 0;
 	} else if (skb->len < 2)
 		goto err;
 
diff --git a/drivers/net/ppp/pptp.c b/drivers/net/ppp/pptp.c
index 1951b1085cb8..2f22e318a67f 100644
--- a/drivers/net/ppp/pptp.c
+++ b/drivers/net/ppp/pptp.c
@@ -328,7 +328,7 @@ static int pptp_rcv_core(struct sock *sk, struct sk_buff *skb)
 
 		if ((*skb->data) & 1) {
 			/* protocol is compressed */
-			skb_push(skb, 1)[0] = 0;
+			*(u8 *)skb_push(skb, 1) = 0;
 		}
 
 		skb->ip_summed = CHECKSUM_NONE;
diff --git a/drivers/net/usb/gl620a.c b/drivers/net/usb/gl620a.c
index 29276e54bb8b..ba1ce1006c4f 100644
--- a/drivers/net/usb/gl620a.c
+++ b/drivers/net/usb/gl620a.c
@@ -174,7 +174,7 @@ genelink_tx_fixup(struct usbnet *dev, struct sk_buff *skb, gfp_t flags)
 	}
 
 	// attach the packet count to the header
-	packet_count = (__le32 *) skb_push(skb, (4 + 4*1));
+	packet_count = skb_push(skb, (4 + 4 * 1));
 	packet_len = packet_count + 1;
 
 	*packet_count = cpu_to_le32(1);
diff --git a/drivers/net/usb/int51x1.c b/drivers/net/usb/int51x1.c
index 5a43b77a6b9c..be63a829b8fe 100644
--- a/drivers/net/usb/int51x1.c
+++ b/drivers/net/usb/int51x1.c
@@ -106,7 +106,7 @@ static struct sk_buff *int51x1_tx_fixup(struct usbnet *dev,
 	pack_len += need_tail;
 	pack_len &= 0x07ff;
 
-	len = (__le16 *) __skb_push(skb, INT51X1_HEADER_SIZE);
+	len = __skb_push(skb, INT51X1_HEADER_SIZE);
 	*len = cpu_to_le16(pack_len);
 
 	if(need_tail)
diff --git a/drivers/net/usb/kaweth.c b/drivers/net/usb/kaweth.c
index 37fb621fde86..92e4fd29ae44 100644
--- a/drivers/net/usb/kaweth.c
+++ b/drivers/net/usb/kaweth.c
@@ -809,7 +809,7 @@ static netdev_tx_t kaweth_start_xmit(struct sk_buff *skb,
 		return NETDEV_TX_OK;
 	}
 
-	private_header = (__le16 *)__skb_push(skb, 2);
+	private_header = __skb_push(skb, 2);
 	*private_header = cpu_to_le16(skb->len-2);
 	kaweth->tx_skb = skb;
 
diff --git a/drivers/net/usb/lg-vl600.c b/drivers/net/usb/lg-vl600.c
index d633492bf9eb..dbabd7ca5268 100644
--- a/drivers/net/usb/lg-vl600.c
+++ b/drivers/net/usb/lg-vl600.c
@@ -304,7 +304,7 @@ static struct sk_buff *vl600_tx_fixup(struct usbnet *dev,
 	memset(&packet->dummy, 0, sizeof(packet->dummy));
 	packet->len = cpu_to_le32(orig_len);
 
-	frame = (struct vl600_frame_hdr *) skb_push(skb, sizeof(*frame));
+	frame = skb_push(skb, sizeof(*frame));
 	memset(frame, 0, sizeof(*frame));
 	frame->len = cpu_to_le32(full_len);
 	frame->serial = cpu_to_le32(serial++);
diff --git a/drivers/net/usb/net1080.c b/drivers/net/usb/net1080.c
index 861ff45f0b09..be53ff30b7b5 100644
--- a/drivers/net/usb/net1080.c
+++ b/drivers/net/usb/net1080.c
@@ -466,7 +466,7 @@ net1080_tx_fixup(struct usbnet *dev, struct sk_buff *skb, gfp_t flags)
 
 encapsulate:
 	/* header first */
-	header = (struct nc_header *) skb_push(skb, sizeof *header);
+	header = skb_push(skb, sizeof *header);
 	header->hdr_len = cpu_to_le16(sizeof (*header));
 	header->packet_len = cpu_to_le16(len);
 	header->packet_id = cpu_to_le16((u16)dev->xid++);
diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
index ffd229ec8352..5894e3c9468f 100644
--- a/drivers/net/usb/qmi_wwan.c
+++ b/drivers/net/usb/qmi_wwan.c
@@ -101,7 +101,7 @@ static netdev_tx_t qmimux_start_xmit(struct sk_buff *skb, struct net_device *dev
 	unsigned int len = skb->len;
 	struct qmimux_hdr *hdr;
 
-	hdr = (struct qmimux_hdr *)skb_push(skb, sizeof(struct qmimux_hdr));
+	hdr = skb_push(skb, sizeof(struct qmimux_hdr));
 	hdr->pad = 0;
 	hdr->mux_id = priv->mux_id;
 	hdr->pkt_len = cpu_to_be16(len);
diff --git a/drivers/net/usb/rndis_host.c b/drivers/net/usb/rndis_host.c
index e96e2e5673d7..a151f267aebb 100644
--- a/drivers/net/usb/rndis_host.c
+++ b/drivers/net/usb/rndis_host.c
@@ -578,7 +578,7 @@ rndis_tx_fixup(struct usbnet *dev, struct sk_buff *skb, gfp_t flags)
 	 * packets; Linux minimizes wasted bandwidth through tx queues.
 	 */
 fill:
-	hdr = (void *) __skb_push(skb, sizeof *hdr);
+	hdr = __skb_push(skb, sizeof *hdr);
 	memset(hdr, 0, sizeof *hdr);
 	hdr->msg_type = cpu_to_le32(RNDIS_MSG_PACKET);
 	hdr->msg_len = cpu_to_le32(skb->len);
diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index 022c0b5f9844..c6c0595d267b 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -383,7 +383,7 @@ static int vrf_finish_direct(struct net *net, struct sock *sk,
 
 	if (!list_empty(&vrf_dev->ptype_all) &&
 	    likely(skb_headroom(skb) >= ETH_HLEN)) {
-		struct ethhdr *eth = (struct ethhdr *)skb_push(skb, ETH_HLEN);
+		struct ethhdr *eth = skb_push(skb, ETH_HLEN);
 
 		ether_addr_copy(eth->h_source, vrf_dev->dev_addr);
 		eth_zero_addr(eth->h_dest);
diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 4e1d427d340c..94ce98229828 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1827,7 +1827,7 @@ static int vxlan_build_skb(struct sk_buff *skb, struct dst_entry *dst,
 	if (err)
 		return err;
 
-	vxh = (struct vxlanhdr *) __skb_push(skb, sizeof(*vxh));
+	vxh = __skb_push(skb, sizeof(*vxh));
 	vxh->vx_flags = VXLAN_HF_VNI;
 	vxh->vx_vni = vxlan_vni_field(vni);
 
diff --git a/drivers/net/wimax/i2400m/netdev.c b/drivers/net/wimax/i2400m/netdev.c
index dd7f3168c07d..a654687b5fa2 100644
--- a/drivers/net/wimax/i2400m/netdev.c
+++ b/drivers/net/wimax/i2400m/netdev.c
@@ -221,7 +221,7 @@ void i2400m_tx_prep_header(struct sk_buff *skb)
 {
 	struct i2400m_pl_data_hdr *pl_hdr;
 	skb_pull(skb, ETH_HLEN);
-	pl_hdr = (struct i2400m_pl_data_hdr *) skb_push(skb, sizeof(*pl_hdr));
+	pl_hdr = skb_push(skb, sizeof(*pl_hdr));
 	pl_hdr->reserved = 0;
 }
 
diff --git a/drivers/net/wireless/admtek/adm8211.c b/drivers/net/wireless/admtek/adm8211.c
index 5f64f3928c35..3b0802fc5bf5 100644
--- a/drivers/net/wireless/admtek/adm8211.c
+++ b/drivers/net/wireless/admtek/adm8211.c
@@ -1700,7 +1700,7 @@ static void adm8211_tx(struct ieee80211_hw *dev,
 	skb_pull(skb, hdrlen);
 	payload_len = skb->len;
 
-	txhdr = (struct adm8211_tx_hdr *) skb_push(skb, sizeof(*txhdr));
+	txhdr = skb_push(skb, sizeof(*txhdr));
 	memset(txhdr, 0, sizeof(*txhdr));
 	memcpy(txhdr->da, ieee80211_get_DA(hdr), ETH_ALEN);
 	txhdr->signal = plcp_signal;
diff --git a/drivers/net/wireless/ath/ar5523/ar5523.c b/drivers/net/wireless/ath/ar5523/ar5523.c
index f2f4ccfdf8da..106d6f8d471a 100644
--- a/drivers/net/wireless/ath/ar5523/ar5523.c
+++ b/drivers/net/wireless/ath/ar5523/ar5523.c
@@ -829,8 +829,8 @@ static void ar5523_tx_work_locked(struct ar5523 *ar)
 		data->ar = ar;
 		data->urb = urb;
 
-		desc = (struct ar5523_tx_desc *)skb_push(skb, sizeof(*desc));
-		chunk = (struct ar5523_chunk *)skb_push(skb, sizeof(*chunk));
+		desc = skb_push(skb, sizeof(*desc));
+		chunk = skb_push(skb, sizeof(*chunk));
 
 		chunk->seqnum = 0;
 		chunk->flags = UATH_CFLAGS_FINAL;
diff --git a/drivers/net/wireless/ath/ath6kl/htc_pipe.c b/drivers/net/wireless/ath/ath6kl/htc_pipe.c
index b13d61111072..5c0ba83a44aa 100644
--- a/drivers/net/wireless/ath/ath6kl/htc_pipe.c
+++ b/drivers/net/wireless/ath/ath6kl/htc_pipe.c
@@ -228,8 +228,7 @@ static int htc_issue_packets(struct htc_target *target,
 		payload_len = packet->act_len;
 
 		/* setup HTC frame header */
-		htc_hdr = (struct htc_frame_hdr *) skb_push(skb,
-							    sizeof(*htc_hdr));
+		htc_hdr = skb_push(skb, sizeof(*htc_hdr));
 		if (!htc_hdr) {
 			WARN_ON_ONCE(1);
 			status = -EINVAL;
diff --git a/drivers/net/wireless/ath/ath9k/hif_usb.c b/drivers/net/wireless/ath/ath9k/hif_usb.c
index 12aa8abbcba4..0d9687a2aa98 100644
--- a/drivers/net/wireless/ath/ath9k/hif_usb.c
+++ b/drivers/net/wireless/ath/ath9k/hif_usb.c
@@ -199,7 +199,7 @@ static int hif_usb_send_mgmt(struct hif_device_usb *hif_dev,
 	cmd->skb = skb;
 	cmd->hif_dev = hif_dev;
 
-	hdr = (__le16 *) skb_push(skb, 4);
+	hdr = skb_push(skb, 4);
 	*hdr++ = cpu_to_le16(skb->len - 4);
 	*hdr++ = cpu_to_le16(ATH_USB_TX_STREAM_MODE_TAG);
 
diff --git a/drivers/net/wireless/ath/ath9k/htc_hst.c b/drivers/net/wireless/ath/ath9k/htc_hst.c
index 9fa8970a1f7d..1bf63a4efb4c 100644
--- a/drivers/net/wireless/ath/ath9k/htc_hst.c
+++ b/drivers/net/wireless/ath/ath9k/htc_hst.c
@@ -26,8 +26,7 @@ static int htc_issue_send(struct htc_target *target, struct sk_buff* skb,
 	struct htc_endpoint *endpoint = &target->endpoint[epid];
 	int status;
 
-	hdr = (struct htc_frame_hdr *)
-		skb_push(skb, sizeof(struct htc_frame_hdr));
+	hdr = skb_push(skb, sizeof(struct htc_frame_hdr));
 	hdr->endpoint_id = epid;
 	hdr->flags = flags;
 	hdr->payload_len = cpu_to_be16(len);
diff --git a/drivers/net/wireless/ath/ath9k/wmi.c b/drivers/net/wireless/ath/ath9k/wmi.c
index c51c69b1ad96..85d09fdef8dc 100644
--- a/drivers/net/wireless/ath/ath9k/wmi.c
+++ b/drivers/net/wireless/ath/ath9k/wmi.c
@@ -277,7 +277,7 @@ static int ath9k_wmi_cmd_issue(struct wmi *wmi,
 	struct wmi_cmd_hdr *hdr;
 	unsigned long flags;
 
-	hdr = (struct wmi_cmd_hdr *) skb_push(skb, sizeof(struct wmi_cmd_hdr));
+	hdr = skb_push(skb, sizeof(struct wmi_cmd_hdr));
 	hdr->command_id = cpu_to_be16(cmd);
 	hdr->seq_no = cpu_to_be16(++wmi->tx_seq_id);
 
diff --git a/drivers/net/wireless/ath/carl9170/tx.c b/drivers/net/wireless/ath/carl9170/tx.c
index 2bf04c9edc98..0cb5b58925dc 100644
--- a/drivers/net/wireless/ath/carl9170/tx.c
+++ b/drivers/net/wireless/ath/carl9170/tx.c
@@ -991,7 +991,7 @@ static int carl9170_tx_prepare(struct ar9170 *ar,
 	else
 		cvif = NULL;
 
-	txc = (void *)skb_push(skb, sizeof(*txc));
+	txc = skb_push(skb, sizeof(*txc));
 	memset(txc, 0, sizeof(*txc));
 
 	SET_VAL(CARL9170_TX_SUPER_MISC_QUEUE, txc->s.misc, hw_queue);
diff --git a/drivers/net/wireless/ath/wil6210/txrx.c b/drivers/net/wireless/ath/wil6210/txrx.c
index edab4c0a900f..84d91606e6f3 100644
--- a/drivers/net/wireless/ath/wil6210/txrx.c
+++ b/drivers/net/wireless/ath/wil6210/txrx.c
@@ -363,7 +363,7 @@ static void wil_rx_add_radiotap_header(struct wil6210_priv *wil,
 		return;
 	}
 
-	rtap_vendor = (void *)skb_push(skb, rtap_len);
+	rtap_vendor = skb_push(skb, rtap_len);
 	memset(rtap_vendor, 0, rtap_len);
 
 	rtap_vendor->rtap.rthdr.it_version = PKTHDR_RADIOTAP_VERSION;
diff --git a/drivers/net/wireless/intersil/hostap/hostap_80211_rx.c b/drivers/net/wireless/intersil/hostap/hostap_80211_rx.c
index 34dbddbf3f9b..6d8b64ca1a63 100644
--- a/drivers/net/wireless/intersil/hostap/hostap_80211_rx.c
+++ b/drivers/net/wireless/intersil/hostap/hostap_80211_rx.c
@@ -131,8 +131,7 @@ int prism2_rx_80211(struct net_device *dev, struct sk_buff *skb,
 
 	if (prism_header == 1) {
 		struct linux_wlan_ng_prism_hdr *hdr;
-		hdr = (struct linux_wlan_ng_prism_hdr *)
-			skb_push(skb, phdrlen);
+		hdr = skb_push(skb, phdrlen);
 		memset(hdr, 0, phdrlen);
 		hdr->msgcode = LWNG_CAP_DID_BASE;
 		hdr->msglen = sizeof(*hdr);
@@ -153,8 +152,7 @@ hdr->f.status = s; hdr->f.len = l; hdr->f.data = d
 #undef LWNG_SETVAL
 	} else if (prism_header == 2) {
 		struct linux_wlan_ng_cap_hdr *hdr;
-		hdr = (struct linux_wlan_ng_cap_hdr *)
-			skb_push(skb, phdrlen);
+		hdr = skb_push(skb, phdrlen);
 		memset(hdr, 0, phdrlen);
 		hdr->version    = htonl(LWNG_CAPHDR_VERSION);
 		hdr->length     = htonl(phdrlen);
@@ -172,7 +170,7 @@ hdr->f.status = s; hdr->f.len = l; hdr->f.data = d
 		hdr->encoding   = htonl(1); /* cck */
 	} else if (prism_header == 3) {
 		struct hostap_radiotap_rx *hdr;
-		hdr = (struct hostap_radiotap_rx *)skb_push(skb, phdrlen);
+		hdr = skb_push(skb, phdrlen);
 		memset(hdr, 0, phdrlen);
 		hdr->hdr.it_len = cpu_to_le16(phdrlen);
 		hdr->hdr.it_present =
diff --git a/drivers/net/wireless/intersil/orinoco/main.c b/drivers/net/wireless/intersil/orinoco/main.c
index f7abc439fb92..28dac36d7c4c 100644
--- a/drivers/net/wireless/intersil/orinoco/main.c
+++ b/drivers/net/wireless/intersil/orinoco/main.c
@@ -396,7 +396,7 @@ int orinoco_process_xmit_skb(struct sk_buff *skb,
 		memcpy(hdr.encap, encaps_hdr, sizeof(encaps_hdr));
 
 		/* Make room for the new header, and copy it in */
-		eh = (struct ethhdr *) skb_push(skb, ENCAPS_OVERHEAD);
+		eh = skb_push(skb, ENCAPS_OVERHEAD);
 		memcpy(eh, &hdr, sizeof(hdr));
 	}
 
@@ -1029,11 +1029,10 @@ static void orinoco_rx(struct net_device *dev,
 		/* These indicate a SNAP within 802.2 LLC within
 		   802.11 frame which we'll need to de-encapsulate to
 		   the original EthernetII frame. */
-		hdr = (struct ethhdr *)skb_push(skb,
-						ETH_HLEN - ENCAPS_OVERHEAD);
+		hdr = skb_push(skb, ETH_HLEN - ENCAPS_OVERHEAD);
 	} else {
 		/* 802.3 frame - prepend 802.3 header as is */
-		hdr = (struct ethhdr *)skb_push(skb, ETH_HLEN);
+		hdr = skb_push(skb, ETH_HLEN);
 		hdr->h_proto = htons(length);
 	}
 	memcpy(hdr->h_dest, desc->addr1, ETH_ALEN);
diff --git a/drivers/net/wireless/intersil/p54/txrx.c b/drivers/net/wireless/intersil/p54/txrx.c
index b00c07d72f95..3a4214d362ff 100644
--- a/drivers/net/wireless/intersil/p54/txrx.c
+++ b/drivers/net/wireless/intersil/p54/txrx.c
@@ -815,8 +815,8 @@ void p54_tx_80211(struct ieee80211_hw *dev,
 		}
 	}
 
-	txhdr = (struct p54_tx_data *) skb_push(skb, sizeof(*txhdr) + padding);
-	hdr = (struct p54_hdr *) skb_push(skb, sizeof(*hdr));
+	txhdr = skb_push(skb, sizeof(*txhdr) + padding);
+	hdr = skb_push(skb, sizeof(*hdr));
 
 	if (padding)
 		hdr_flags |= P54_HDR_FLAG_DATA_ALIGN;
diff --git a/drivers/net/wireless/intersil/prism54/islpci_eth.c b/drivers/net/wireless/intersil/prism54/islpci_eth.c
index d83f6332019e..9b0ded733294 100644
--- a/drivers/net/wireless/intersil/prism54/islpci_eth.c
+++ b/drivers/net/wireless/intersil/prism54/islpci_eth.c
@@ -276,10 +276,7 @@ islpci_monitor_rx(islpci_private *priv, struct sk_buff **skb)
 		}
 
 		/* make room for the new header and fill it. */
-		avs =
-		    (struct avs_80211_1_header *) skb_push(*skb,
-							   sizeof (struct
-								   avs_80211_1_header));
+		avs = skb_push(*skb, sizeof(struct avs_80211_1_header));
 
 		avs->version = cpu_to_be32(P80211CAPTURE_VERSION);
 		avs->length = cpu_to_be32(sizeof (struct avs_80211_1_header));
diff --git a/drivers/net/wireless/mac80211_hwsim.c b/drivers/net/wireless/mac80211_hwsim.c
index 7418088e296f..c8852acc1462 100644
--- a/drivers/net/wireless/mac80211_hwsim.c
+++ b/drivers/net/wireless/mac80211_hwsim.c
@@ -848,7 +848,7 @@ static void mac80211_hwsim_monitor_rx(struct ieee80211_hw *hw,
 	if (skb == NULL)
 		return;
 
-	hdr = (struct hwsim_radiotap_hdr *) skb_push(skb, sizeof(*hdr));
+	hdr = skb_push(skb, sizeof(*hdr));
 	hdr->hdr.it_version = PKTHDR_RADIOTAP_VERSION;
 	hdr->hdr.it_pad = 0;
 	hdr->hdr.it_len = cpu_to_le16(sizeof(*hdr));
@@ -1146,7 +1146,7 @@ static void mac80211_hwsim_add_vendor_rtap(struct sk_buff *skb)
 	 * Note that this code requires the headroom in the SKB
 	 * that was allocated earlier.
 	 */
-	rtap = (void *)skb_push(skb, sizeof(*rtap) + 8 + 4);
+	rtap = skb_push(skb, sizeof(*rtap) + 8 + 4);
 	rtap->oui[0] = HWSIM_RADIOTAP_OUI[0];
 	rtap->oui[1] = HWSIM_RADIOTAP_OUI[1];
 	rtap->oui[2] = HWSIM_RADIOTAP_OUI[2];
diff --git a/drivers/net/wireless/marvell/libertas/rx.c b/drivers/net/wireless/marvell/libertas/rx.c
index a18bb7a9889c..7586ff681b23 100644
--- a/drivers/net/wireless/marvell/libertas/rx.c
+++ b/drivers/net/wireless/marvell/libertas/rx.c
@@ -257,7 +257,7 @@ static int process_rxed_802_11_packet(struct lbs_private *priv,
 		goto done;
 	}
 
-	pradiotap_hdr = (void *)skb_push(skb, sizeof(struct rx_radiotap_hdr));
+	pradiotap_hdr = skb_push(skb, sizeof(struct rx_radiotap_hdr));
 	memcpy(pradiotap_hdr, &radiotap_hdr, sizeof(struct rx_radiotap_hdr));
 
 	priv->cur_rate = lbs_fw_index_to_data_rate(prxpd->rx_rate);
diff --git a/drivers/net/wireless/marvell/libertas_tf/main.c b/drivers/net/wireless/marvell/libertas_tf/main.c
index d80333117989..81228bf73043 100644
--- a/drivers/net/wireless/marvell/libertas_tf/main.c
+++ b/drivers/net/wireless/marvell/libertas_tf/main.c
@@ -260,7 +260,7 @@ static void lbtf_tx_work(struct work_struct *work)
 
 	len = skb->len;
 	info  = IEEE80211_SKB_CB(skb);
-	txpd = (struct txpd *)  skb_push(skb, sizeof(struct txpd));
+	txpd = skb_push(skb, sizeof(struct txpd));
 
 	if (priv->surpriseremoved) {
 		dev_kfree_skb_any(skb);
diff --git a/drivers/net/wireless/mediatek/mt7601u/tx.c b/drivers/net/wireless/mediatek/mt7601u/tx.c
index ad77bec1ba0f..3600e911a63e 100644
--- a/drivers/net/wireless/mediatek/mt7601u/tx.c
+++ b/drivers/net/wireless/mediatek/mt7601u/tx.c
@@ -148,7 +148,7 @@ mt7601u_push_txwi(struct mt7601u_dev *dev, struct sk_buff *skb,
 	u16 rate_ctl;
 	u8 nss;
 
-	txwi = (struct mt76_txwi *)skb_push(skb, sizeof(struct mt76_txwi));
+	txwi = skb_push(skb, sizeof(struct mt76_txwi));
 	memset(txwi, 0, sizeof(*txwi));
 
 	if (!wcid->tx_rate_set)
diff --git a/drivers/net/wireless/realtek/rtl818x/rtl8187/dev.c b/drivers/net/wireless/realtek/rtl818x/rtl8187/dev.c
index 35fe991dcc56..55198ac2b755 100644
--- a/drivers/net/wireless/realtek/rtl818x/rtl8187/dev.c
+++ b/drivers/net/wireless/realtek/rtl818x/rtl8187/dev.c
@@ -278,8 +278,7 @@ static void rtl8187_tx(struct ieee80211_hw *dev,
 	}
 
 	if (!priv->is_rtl8187b) {
-		struct rtl8187_tx_hdr *hdr =
-			(struct rtl8187_tx_hdr *)skb_push(skb, sizeof(*hdr));
+		struct rtl8187_tx_hdr *hdr = skb_push(skb, sizeof(*hdr));
 		hdr->flags = cpu_to_le32(flags);
 		hdr->len = 0;
 		hdr->rts_duration = rts_dur;
@@ -292,8 +291,7 @@ static void rtl8187_tx(struct ieee80211_hw *dev,
 		unsigned int epmap[4] = { 6, 7, 5, 4 };
 		u16 fc = le16_to_cpu(tx_hdr->frame_control);
 
-		struct rtl8187b_tx_hdr *hdr =
-			(struct rtl8187b_tx_hdr *)skb_push(skb, sizeof(*hdr));
+		struct rtl8187b_tx_hdr *hdr = skb_push(skb, sizeof(*hdr));
 		struct ieee80211_rate *txrate =
 			ieee80211_get_tx_rate(dev, info);
 		memset(hdr, 0, sizeof(*hdr));
diff --git a/drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu_core.c b/drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu_core.c
index 39d56313bc94..21e5ef021260 100644
--- a/drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu_core.c
+++ b/drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu_core.c
@@ -4952,7 +4952,7 @@ static void rtl8xxxu_tx(struct ieee80211_hw *hw,
 	if (control && control->sta)
 		sta = control->sta;
 
-	tx_desc = (struct rtl8xxxu_txdesc32 *)skb_push(skb, tx_desc_size);
+	tx_desc = skb_push(skb, tx_desc_size);
 
 	memset(tx_desc, 0, tx_desc_size);
 	tx_desc->pkt_size = cpu_to_le16(pktlen);
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8192cu/trx.c b/drivers/net/wireless/realtek/rtlwifi/rtl8192cu/trx.c
index 41422e4da8b7..de6c3428f7c6 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8192cu/trx.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8192cu/trx.c
@@ -512,7 +512,7 @@ void rtl92cu_tx_fill_desc(struct ieee80211_hw *hw,
 
 	seq_number = (le16_to_cpu(hdr->seq_ctrl) & IEEE80211_SCTL_SEQ) >> 4;
 	rtl_get_tcb_desc(hw, info, sta, skb, tcb_desc);
-	txdesc = (u8 *)skb_push(skb, RTL_TX_HEADER_SIZE);
+	txdesc = skb_push(skb, RTL_TX_HEADER_SIZE);
 	memset(txdesc, 0, RTL_TX_HEADER_SIZE);
 	SET_TX_DESC_PKT_SIZE(txdesc, pktlen);
 	SET_TX_DESC_LINIP(txdesc, 0);
diff --git a/drivers/net/wireless/st/cw1200/txrx.c b/drivers/net/wireless/st/cw1200/txrx.c
index cd63ffef025a..e9050b41157a 100644
--- a/drivers/net/wireless/st/cw1200/txrx.c
+++ b/drivers/net/wireless/st/cw1200/txrx.c
@@ -574,7 +574,7 @@ cw1200_tx_h_wsm(struct cw1200_common *priv,
 		return NULL;
 	}
 
-	wsm = (struct wsm_tx *)skb_push(t->skb, sizeof(struct wsm_tx));
+	wsm = skb_push(t->skb, sizeof(struct wsm_tx));
 	t->txpriv.offset += sizeof(struct wsm_tx);
 	memset(wsm, 0, sizeof(*wsm));
 	wsm->hdr.len = __cpu_to_le16(t->skb->len);
diff --git a/drivers/net/wireless/ti/wl1251/tx.c b/drivers/net/wireless/ti/wl1251/tx.c
index 81de83c6fcf6..de2fa6705574 100644
--- a/drivers/net/wireless/ti/wl1251/tx.c
+++ b/drivers/net/wireless/ti/wl1251/tx.c
@@ -161,8 +161,7 @@ static int wl1251_tx_fill_hdr(struct wl1251 *wl, struct sk_buff *skb,
 		return id;
 
 	fc = *(u16 *)skb->data;
-	tx_hdr = (struct tx_double_buffer_desc *) skb_push(skb,
-							   sizeof(*tx_hdr));
+	tx_hdr = skb_push(skb, sizeof(*tx_hdr));
 
 	tx_hdr->length = cpu_to_le16(skb->len - sizeof(*tx_hdr));
 	rate = ieee80211_get_tx_rate(wl->hw, control);
diff --git a/drivers/net/wireless/ti/wlcore/cmd.c b/drivers/net/wireless/ti/wlcore/cmd.c
index 229f4d01f239..2bfc12fdc929 100644
--- a/drivers/net/wireless/ti/wlcore/cmd.c
+++ b/drivers/net/wireless/ti/wlcore/cmd.c
@@ -1282,7 +1282,7 @@ int wl1271_cmd_build_arp_rsp(struct wl1271 *wl, struct wl12xx_vif *wlvif)
 		memset(skb_push(skb, sizeof(__le16)), 0, sizeof(__le16));
 
 	/* mac80211 header */
-	hdr = (struct ieee80211_hdr_3addr *)skb_push(skb, sizeof(*hdr));
+	hdr = skb_push(skb, sizeof(*hdr));
 	memset(hdr, 0, sizeof(*hdr));
 	fc = IEEE80211_FTYPE_DATA | IEEE80211_FCTL_TODS;
 	if (wlvif->sta.qos)
diff --git a/drivers/net/wireless/ti/wlcore/tx.c b/drivers/net/wireless/ti/wlcore/tx.c
index c1b8e4e9d70b..a3f5e9ca492a 100644
--- a/drivers/net/wireless/ti/wlcore/tx.c
+++ b/drivers/net/wireless/ti/wlcore/tx.c
@@ -223,8 +223,7 @@ static int wl1271_tx_allocate(struct wl1271 *wl, struct wl12xx_vif *wlvif,
 	total_blocks = wlcore_hw_calc_tx_blocks(wl, total_len, spare_blocks);
 
 	if (total_blocks <= wl->tx_blocks_available) {
-		desc = (struct wl1271_tx_hw_descr *)skb_push(
-			skb, total_len - skb->len);
+		desc = skb_push(skb, total_len - skb->len);
 
 		wlcore_hw_set_tx_desc_blocks(wl, desc, total_blocks,
 					     spare_blocks);
diff --git a/drivers/net/wireless/zydas/zd1211rw/zd_mac.c b/drivers/net/wireless/zydas/zd1211rw/zd_mac.c
index 2d929d2edb00..b785742bfd9e 100644
--- a/drivers/net/wireless/zydas/zd1211rw/zd_mac.c
+++ b/drivers/net/wireless/zydas/zd1211rw/zd_mac.c
@@ -868,8 +868,7 @@ static int fill_ctrlset(struct zd_mac *mac,
 	unsigned int frag_len = skb->len + FCS_LEN;
 	unsigned int packet_length;
 	struct ieee80211_rate *txrate;
-	struct zd_ctrlset *cs = (struct zd_ctrlset *)
-		skb_push(skb, sizeof(struct zd_ctrlset));
+	struct zd_ctrlset *cs = skb_push(skb, sizeof(struct zd_ctrlset));
 	struct ieee80211_tx_info *info = IEEE80211_SKB_CB(skb);
 
 	ZD_ASSERT(frag_len <= 0xffff);
diff --git a/drivers/nfc/fdp/i2c.c b/drivers/nfc/fdp/i2c.c
index 97f003e84381..d5781aa0f791 100644
--- a/drivers/nfc/fdp/i2c.c
+++ b/drivers/nfc/fdp/i2c.c
@@ -79,8 +79,8 @@ static void fdp_nci_i2c_add_len_lrc(struct sk_buff *skb)
 
 	/* Add length header */
 	len = skb->len;
-	*skb_push(skb, 1) = len & 0xff;
-	*skb_push(skb, 1) = len >> 8;
+	*(u8 *)skb_push(skb, 1) = len & 0xff;
+	*(u8 *)skb_push(skb, 1) = len >> 8;
 
 	/* Compute and add lrc */
 	for (i = 0; i < len + 2; i++)
diff --git a/drivers/nfc/microread/i2c.c b/drivers/nfc/microread/i2c.c
index 8e328c36a816..386cc61d95b9 100644
--- a/drivers/nfc/microread/i2c.c
+++ b/drivers/nfc/microread/i2c.c
@@ -70,7 +70,7 @@ static void microread_i2c_add_len_crc(struct sk_buff *skb)
 	int len;
 
 	len = skb->len;
-	*skb_push(skb, 1) = len;
+	*(u8 *)skb_push(skb, 1) = len;
 
 	for (i = 0; i < skb->len; i++)
 		crc = crc ^ skb->data[i];
diff --git a/drivers/nfc/microread/microread.c b/drivers/nfc/microread/microread.c
index 9d0dd1be0923..38a979eacc29 100644
--- a/drivers/nfc/microread/microread.c
+++ b/drivers/nfc/microread/microread.c
@@ -419,7 +419,7 @@ static int microread_im_transceive(struct nfc_hci_dev *hdev,
 	pr_info("data exchange to gate 0x%x\n", target->hci_reader_gate);
 
 	if (target->hci_reader_gate == MICROREAD_GATE_ID_P2P_INITIATOR) {
-		*skb_push(skb, 1) = 0;
+		*(u8 *)skb_push(skb, 1) = 0;
 
 		return nfc_hci_send_event(hdev, target->hci_reader_gate,
 				     MICROREAD_EVT_P2P_INITIATOR_EXCHANGE_TO_RF,
@@ -453,7 +453,7 @@ static int microread_im_transceive(struct nfc_hci_dev *hdev,
 		return 1;
 	}
 
-	*skb_push(skb, 1) = control_bits;
+	*(u8 *)skb_push(skb, 1) = control_bits;
 
 	info->async_cb_type = MICROREAD_CB_TYPE_READER_ALL;
 	info->async_cb = cb;
diff --git a/drivers/nfc/nfcmrvl/main.c b/drivers/nfc/nfcmrvl/main.c
index 51c8240a1672..c5038e6447bd 100644
--- a/drivers/nfc/nfcmrvl/main.c
+++ b/drivers/nfc/nfcmrvl/main.c
@@ -68,7 +68,7 @@ static int nfcmrvl_nci_send(struct nci_dev *ndev, struct sk_buff *skb)
 		unsigned char *hdr;
 		unsigned char len = skb->len;
 
-		hdr = (char *) skb_push(skb, NFCMRVL_HCI_EVENT_HEADER_SIZE);
+		hdr = skb_push(skb, NFCMRVL_HCI_EVENT_HEADER_SIZE);
 		hdr[0] = NFCMRVL_HCI_COMMAND_CODE;
 		hdr[1] = NFCMRVL_HCI_OGF;
 		hdr[2] = NFCMRVL_HCI_OCF;
diff --git a/drivers/nfc/pn533/pn533.c b/drivers/nfc/pn533/pn533.c
index 68a3cd0287f6..6a711b5b9490 100644
--- a/drivers/nfc/pn533/pn533.c
+++ b/drivers/nfc/pn533/pn533.c
@@ -2090,10 +2090,10 @@ static int pn533_fill_fragment_skbs(struct pn533 *dev, struct sk_buff *skb)
 
 			/* MI + TG */
 			if (frag_size  == PN533_CMD_DATAFRAME_MAXLEN)
-				*skb_push(frag, sizeof(u8)) =
-							(PN533_CMD_MI_MASK | 1);
+				*(u8 *)skb_push(frag, sizeof(u8)) =
+						(PN533_CMD_MI_MASK | 1);
 			else
-				*skb_push(frag, sizeof(u8)) =  1; /* TG */
+				*(u8 *)skb_push(frag, sizeof(u8)) =  1; /* TG */
 		}
 
 		skb_put_data(frag, skb->data, frag_size);
@@ -2160,7 +2160,7 @@ static int pn533_transceive(struct nfc_dev *nfc_dev,
 				goto error;
 			}
 		} else {
-			*skb_push(skb, sizeof(u8)) =  1; /* TG */
+			*(u8 *)skb_push(skb, sizeof(u8)) =  1; /* TG */
 		}
 
 		rc = pn533_send_data_async(dev, PN533_CMD_IN_DATA_EXCHANGE,
diff --git a/drivers/nfc/pn544/i2c.c b/drivers/nfc/pn544/i2c.c
index dc1e3768cee6..b7be6c25b7e6 100644
--- a/drivers/nfc/pn544/i2c.c
+++ b/drivers/nfc/pn544/i2c.c
@@ -283,7 +283,7 @@ static void pn544_hci_i2c_add_len_crc(struct sk_buff *skb)
 	int len;
 
 	len = skb->len + 2;
-	*skb_push(skb, 1) = len;
+	*(u8 *)skb_push(skb, 1) = len;
 
 	crc = crc_ccitt(0xffff, skb->data, skb->len);
 	crc = ~crc;
diff --git a/drivers/nfc/pn544/pn544.c b/drivers/nfc/pn544/pn544.c
index 12e819ddf17a..70e898e38b16 100644
--- a/drivers/nfc/pn544/pn544.c
+++ b/drivers/nfc/pn544/pn544.c
@@ -649,8 +649,8 @@ static int pn544_hci_im_transceive(struct nfc_hci_dev *hdev,
 		} else
 			return 1;
 	case PN544_RF_READER_F_GATE:
-		*skb_push(skb, 1) = 0;
-		*skb_push(skb, 1) = 0;
+		*(u8 *)skb_push(skb, 1) = 0;
+		*(u8 *)skb_push(skb, 1) = 0;
 
 		info->async_cb_type = PN544_CB_TYPE_READER_F;
 		info->async_cb = cb;
@@ -665,7 +665,7 @@ static int pn544_hci_im_transceive(struct nfc_hci_dev *hdev,
 					      PN544_JEWEL_RAW_CMD, skb->data,
 					      skb->len, cb, cb_context);
 	case PN544_RF_READER_NFCIP1_INITIATOR_GATE:
-		*skb_push(skb, 1) = 0;
+		*(u8 *)skb_push(skb, 1) = 0;
 
 		return nfc_hci_send_event(hdev, target->hci_reader_gate,
 					PN544_HCI_EVT_SND_DATA, skb->data,
@@ -680,7 +680,7 @@ static int pn544_hci_tm_send(struct nfc_hci_dev *hdev, struct sk_buff *skb)
 	int r;
 
 	/* Set default false for multiple information chaining */
-	*skb_push(skb, 1) = 0;
+	*(u8 *)skb_push(skb, 1) = 0;
 
 	r = nfc_hci_send_event(hdev, PN544_RF_READER_NFCIP1_TARGET_GATE,
 			       PN544_HCI_EVT_SND_DATA, skb->data, skb->len);
diff --git a/drivers/nfc/st-nci/ndlc.c b/drivers/nfc/st-nci/ndlc.c
index 50880d747b02..9477994cf975 100644
--- a/drivers/nfc/st-nci/ndlc.c
+++ b/drivers/nfc/st-nci/ndlc.c
@@ -87,7 +87,7 @@ int ndlc_send(struct llt_ndlc *ndlc, struct sk_buff *skb)
 	u8 pcb = PCB_TYPE_DATAFRAME | PCB_DATAFRAME_RETRANSMIT_NO |
 		PCB_FRAME_CRC_INFO_NOTPRESENT;
 
-	*skb_push(skb, 1) = pcb;
+	*(u8 *)skb_push(skb, 1) = pcb;
 	skb_queue_tail(&ndlc->send_q, skb);
 
 	schedule_work(&ndlc->sm_work);
diff --git a/drivers/nfc/st21nfca/core.c b/drivers/nfc/st21nfca/core.c
index 50be3b788f1c..e803fdfa9189 100644
--- a/drivers/nfc/st21nfca/core.c
+++ b/drivers/nfc/st21nfca/core.c
@@ -782,12 +782,12 @@ static int st21nfca_hci_im_transceive(struct nfc_hci_dev *hdev,
 		if (target->supported_protocols == NFC_PROTO_NFC_DEP_MASK)
 			return st21nfca_im_send_dep_req(hdev, skb);
 
-		*skb_push(skb, 1) = 0x1a;
+		*(u8 *)skb_push(skb, 1) = 0x1a;
 		return nfc_hci_send_cmd_async(hdev, target->hci_reader_gate,
 					      ST21NFCA_WR_XCHG_DATA, skb->data,
 					      skb->len, cb, cb_context);
 	case ST21NFCA_RF_READER_14443_3_A_GATE:
-		*skb_push(skb, 1) = 0x1a;	/* CTR, see spec:10.2.2.1 */
+		*(u8 *)skb_push(skb, 1) = 0x1a;	/* CTR, see spec:10.2.2.1 */
 
 		return nfc_hci_send_cmd_async(hdev, target->hci_reader_gate,
 					      ST21NFCA_WR_XCHG_DATA, skb->data,
@@ -797,7 +797,7 @@ static int st21nfca_hci_im_transceive(struct nfc_hci_dev *hdev,
 		info->async_cb = cb;
 		info->async_cb_context = cb_context;
 
-		*skb_push(skb, 1) = 0x17;
+		*(u8 *)skb_push(skb, 1) = 0x17;
 
 		return nfc_hci_send_cmd_async(hdev, target->hci_reader_gate,
 					      ST21NFCA_WR_XCHG_DATA, skb->data,
diff --git a/drivers/nfc/st21nfca/dep.c b/drivers/nfc/st21nfca/dep.c
index ada7b114b6c1..fd08be2917e6 100644
--- a/drivers/nfc/st21nfca/dep.c
+++ b/drivers/nfc/st21nfca/dep.c
@@ -315,10 +315,10 @@ int st21nfca_tm_send_dep_res(struct nfc_hci_dev *hdev, struct sk_buff *skb)
 	int r;
 	struct st21nfca_hci_info *info = nfc_hci_get_clientdata(hdev);
 
-	*skb_push(skb, 1) = info->dep_info.curr_nfc_dep_pni;
-	*skb_push(skb, 1) = ST21NFCA_NFCIP1_DEP_RES;
-	*skb_push(skb, 1) = ST21NFCA_NFCIP1_RES;
-	*skb_push(skb, 1) = skb->len;
+	*(u8 *)skb_push(skb, 1) = info->dep_info.curr_nfc_dep_pni;
+	*(u8 *)skb_push(skb, 1) = ST21NFCA_NFCIP1_DEP_RES;
+	*(u8 *)skb_push(skb, 1) = ST21NFCA_NFCIP1_RES;
+	*(u8 *)skb_push(skb, 1) = skb->len;
 
 	r = nfc_hci_send_event(hdev, ST21NFCA_RF_CARD_F_GATE,
 			ST21NFCA_EVT_SEND_DATA, skb->data, skb->len);
@@ -466,7 +466,7 @@ static void st21nfca_im_send_psl_req(struct nfc_hci_dev *hdev, u8 did, u8 bsi,
 	psl_req->brs = (0x30 & bsi << 4) | (bri & 0x03);
 	psl_req->fsl = lri;
 
-	*skb_push(skb, 1) = info->dep_info.to | 0x10;
+	*(u8 *)skb_push(skb, 1) = info->dep_info.to | 0x10;
 
 	st21nfca_im_send_pdu(info, skb);
 }
@@ -568,7 +568,7 @@ int st21nfca_im_send_atr_req(struct nfc_hci_dev *hdev, u8 *gb, size_t gb_len)
 	}
 	atr_req->length = sizeof(struct st21nfca_atr_req) + hdev->gb_len;
 
-	*skb_push(skb, 1) = info->dep_info.to | 0x10; /* timeout */
+	*(u8 *)skb_push(skb, 1) = info->dep_info.to | 0x10; /* timeout */
 
 	info->async_cb_type = ST21NFCA_CB_TYPE_READER_F;
 	info->async_cb_context = info;
@@ -629,10 +629,10 @@ static void st21nfca_im_recv_dep_res_cb(void *context, struct sk_buff *skb,
 		case ST21NFCA_NFC_DEP_PFB_SUPERVISOR_PDU:
 			pr_err("Received a SUPERVISOR PDU\n");
 			skb_pull(skb, size);
-			*skb_push(skb, 1) = ST21NFCA_NFCIP1_DEP_REQ;
-			*skb_push(skb, 1) = ST21NFCA_NFCIP1_REQ;
-			*skb_push(skb, 1) = skb->len;
-			*skb_push(skb, 1) = info->dep_info.to | 0x10;
+			*(u8 *)skb_push(skb, 1) = ST21NFCA_NFCIP1_DEP_REQ;
+			*(u8 *)skb_push(skb, 1) = ST21NFCA_NFCIP1_REQ;
+			*(u8 *)skb_push(skb, 1) = skb->len;
+			*(u8 *)skb_push(skb, 1) = info->dep_info.to | 0x10;
 
 			st21nfca_im_send_pdu(info, skb);
 			break;
@@ -655,12 +655,12 @@ int st21nfca_im_send_dep_req(struct nfc_hci_dev *hdev, struct sk_buff *skb)
 	info->async_cb_context = info;
 	info->async_cb = st21nfca_im_recv_dep_res_cb;
 
-	*skb_push(skb, 1) = info->dep_info.curr_nfc_dep_pni;
-	*skb_push(skb, 1) = ST21NFCA_NFCIP1_DEP_REQ;
-	*skb_push(skb, 1) = ST21NFCA_NFCIP1_REQ;
-	*skb_push(skb, 1) = skb->len;
+	*(u8 *)skb_push(skb, 1) = info->dep_info.curr_nfc_dep_pni;
+	*(u8 *)skb_push(skb, 1) = ST21NFCA_NFCIP1_DEP_REQ;
+	*(u8 *)skb_push(skb, 1) = ST21NFCA_NFCIP1_REQ;
+	*(u8 *)skb_push(skb, 1) = skb->len;
 
-	*skb_push(skb, 1) = info->dep_info.to | 0x10;
+	*(u8 *)skb_push(skb, 1) = info->dep_info.to | 0x10;
 
 	return nfc_hci_send_cmd_async(hdev, ST21NFCA_RF_READER_F_GATE,
 				      ST21NFCA_WR_XCHG_DATA,
diff --git a/drivers/nfc/st21nfca/i2c.c b/drivers/nfc/st21nfca/i2c.c
index c36f0e0afdfd..396cdafb3e36 100644
--- a/drivers/nfc/st21nfca/i2c.c
+++ b/drivers/nfc/st21nfca/i2c.c
@@ -171,7 +171,7 @@ static void st21nfca_hci_add_len_crc(struct sk_buff *skb)
 	u16 crc;
 	u8 tmp;
 
-	*skb_push(skb, 1) = 0;
+	*(u8 *)skb_push(skb, 1) = 0;
 
 	crc = crc_ccitt(0xffff, skb->data, skb->len);
 	crc = ~crc;
@@ -216,7 +216,7 @@ static int st21nfca_hci_i2c_write(void *phy_id, struct sk_buff *skb)
 	/* add ST21NFCA_SOF_EOF on tail */
 	*(u8 *)skb_put(skb, 1) = ST21NFCA_SOF_EOF;
 	/* add ST21NFCA_SOF_EOF on head */
-	*skb_push(skb, 1) = ST21NFCA_SOF_EOF;
+	*(u8 *)skb_push(skb, 1) = ST21NFCA_SOF_EOF;
 
 	/*
 	 * Compute byte stuffing
diff --git a/drivers/s390/net/qeth_l2_main.c b/drivers/s390/net/qeth_l2_main.c
index 70b633f951ea..c6bc63b8b295 100644
--- a/drivers/s390/net/qeth_l2_main.c
+++ b/drivers/s390/net/qeth_l2_main.c
@@ -759,8 +759,7 @@ static netdev_tx_t qeth_l2_hard_start_xmit(struct sk_buff *skb,
 						sizeof(struct qeth_hdr));
 			if (!new_skb)
 				goto tx_drop;
-			hdr = (struct qeth_hdr *)skb_push(new_skb,
-						sizeof(struct qeth_hdr));
+			hdr = skb_push(new_skb, sizeof(struct qeth_hdr));
 			skb_set_mac_header(new_skb, sizeof(struct qeth_hdr));
 			qeth_l2_fill_header(card, hdr, new_skb, cast_type);
 			if (new_skb->ip_summed == CHECKSUM_PARTIAL)
diff --git a/drivers/s390/net/qeth_l3_main.c b/drivers/s390/net/qeth_l3_main.c
index 37b594231b76..3062cde33a3d 100644
--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -2729,16 +2729,14 @@ static netdev_tx_t qeth_l3_hard_start_xmit(struct sk_buff *skb,
 	}
 
 	if (use_tso) {
-		hdr = (struct qeth_hdr *)skb_push(new_skb,
-						sizeof(struct qeth_hdr_tso));
+		hdr = skb_push(new_skb, sizeof(struct qeth_hdr_tso));
 		memset(hdr, 0, sizeof(struct qeth_hdr_tso));
 		qeth_l3_fill_header(card, hdr, new_skb, ipv, cast_type);
 		qeth_tso_fill_header(card, hdr, new_skb);
 		hdr_elements++;
 	} else {
 		if (data_offset < 0) {
-			hdr = (struct qeth_hdr *)skb_push(new_skb,
-						sizeof(struct qeth_hdr));
+			hdr = skb_push(new_skb, sizeof(struct qeth_hdr));
 			qeth_l3_fill_header(card, hdr, new_skb, ipv,
 						cast_type);
 		} else {
diff --git a/drivers/scsi/cxgbi/cxgb3i/cxgb3i.c b/drivers/scsi/cxgbi/cxgb3i/cxgb3i.c
index 1880eb6c68f7..7b09e7ddf35e 100644
--- a/drivers/scsi/cxgbi/cxgb3i/cxgb3i.c
+++ b/drivers/scsi/cxgbi/cxgb3i/cxgb3i.c
@@ -354,7 +354,7 @@ static inline void make_tx_data_wr(struct cxgbi_sock *csk, struct sk_buff *skb,
 	struct l2t_entry *l2t = csk->l2t;
 
 	skb_reset_transport_header(skb);
-	req = (struct tx_data_wr *)__skb_push(skb, sizeof(*req));
+	req = __skb_push(skb, sizeof(*req));
 	req->wr_hi = htonl(V_WR_OP(FW_WROPCODE_OFLD_TX_DATA) |
 			(req_completion ? F_WR_COMPL : 0));
 	req->wr_lo = htonl(V_WR_TID(csk->tid));
diff --git a/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c b/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
index 397094b8bad6..5485d68f286a 100644
--- a/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
+++ b/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
@@ -644,7 +644,7 @@ static inline void make_tx_data_wr(struct cxgbi_sock *csk, struct sk_buff *skb,
 	unsigned int wr_ulp_mode = 0, val;
 	bool imm = is_ofld_imm(skb);
 
-	req = (struct fw_ofld_tx_data_wr *)__skb_push(skb, sizeof(*req));
+	req = __skb_push(skb, sizeof(*req));
 
 	if (imm) {
 		req->op_to_immdlen = htonl(FW_WR_OP_V(FW_OFLD_TX_DATA_WR) |
diff --git a/drivers/scsi/fcoe/fcoe_ctlr.c b/drivers/scsi/fcoe/fcoe_ctlr.c
index e17bdb3adf9e..fff6f1851dc1 100644
--- a/drivers/scsi/fcoe/fcoe_ctlr.c
+++ b/drivers/scsi/fcoe/fcoe_ctlr.c
@@ -626,7 +626,7 @@ static int fcoe_ctlr_encaps(struct fcoe_ctlr *fip, struct fc_lport *lport,
 	fh = (struct fc_frame_header *)skb->data;
 	op = *(u8 *)(fh + 1);
 	dlen = sizeof(struct fip_encaps) + skb->len;	/* len before push */
-	cap = (struct fip_encaps_head *)skb_push(skb, sizeof(*cap));
+	cap = skb_push(skb, sizeof(*cap));
 	memset(cap, 0, sizeof(*cap));
 
 	if (lport->point_to_multipoint) {
diff --git a/drivers/scsi/fnic/fnic_fcs.c b/drivers/scsi/fnic/fnic_fcs.c
index e3b964b7235a..e72becaad8a5 100644
--- a/drivers/scsi/fnic/fnic_fcs.c
+++ b/drivers/scsi/fnic/fnic_fcs.c
@@ -1000,8 +1000,7 @@ void fnic_eth_send(struct fcoe_ctlr *fip, struct sk_buff *skb)
 
 	if (!fnic->vlan_hw_insert) {
 		eth_hdr = (struct ethhdr *)skb_mac_header(skb);
-		vlan_hdr = (struct vlan_ethhdr *)skb_push(skb,
-				sizeof(*vlan_hdr) - sizeof(*eth_hdr));
+		vlan_hdr = skb_push(skb, sizeof(*vlan_hdr) - sizeof(*eth_hdr));
 		memcpy(vlan_hdr, eth_hdr, 2 * ETH_ALEN);
 		vlan_hdr->h_vlan_proto = htons(ETH_P_8021Q);
 		vlan_hdr->h_vlan_encapsulated_proto = eth_hdr->h_proto;
@@ -1067,7 +1066,7 @@ static int fnic_send_frame(struct fnic *fnic, struct fc_frame *fp)
 
 	if (!fnic->vlan_hw_insert) {
 		eth_hdr_len = sizeof(*vlan_hdr) + sizeof(*fcoe_hdr);
-		vlan_hdr = (struct vlan_ethhdr *)skb_push(skb, eth_hdr_len);
+		vlan_hdr = skb_push(skb, eth_hdr_len);
 		eth_hdr = (struct ethhdr *)vlan_hdr;
 		vlan_hdr->h_vlan_proto = htons(ETH_P_8021Q);
 		vlan_hdr->h_vlan_encapsulated_proto = htons(ETH_P_FCOE);
@@ -1075,7 +1074,7 @@ static int fnic_send_frame(struct fnic *fnic, struct fc_frame *fp)
 		fcoe_hdr = (struct fcoe_hdr *)(vlan_hdr + 1);
 	} else {
 		eth_hdr_len = sizeof(*eth_hdr) + sizeof(*fcoe_hdr);
-		eth_hdr = (struct ethhdr *)skb_push(skb, eth_hdr_len);
+		eth_hdr = skb_push(skb, eth_hdr_len);
 		eth_hdr->h_proto = htons(ETH_P_FCOE);
 		fcoe_hdr = (struct fcoe_hdr *)(eth_hdr + 1);
 	}
diff --git a/drivers/scsi/qedf/qedf_fip.c b/drivers/scsi/qedf/qedf_fip.c
index e10b91cc3c62..0d4bf70803ae 100644
--- a/drivers/scsi/qedf/qedf_fip.c
+++ b/drivers/scsi/qedf/qedf_fip.c
@@ -125,8 +125,7 @@ void qedf_fip_send(struct fcoe_ctlr *fip, struct sk_buff *skb)
 	sub = fiph->fip_subcode;
 
 	if (!qedf->vlan_hw_insert) {
-		vlan_hdr = (struct vlan_ethhdr *)skb_push(skb, sizeof(*vlan_hdr)
-		    - sizeof(*eth_hdr));
+		vlan_hdr = skb_push(skb, sizeof(*vlan_hdr) - sizeof(*eth_hdr));
 		memcpy(vlan_hdr, eth_hdr, 2 * ETH_ALEN);
 		vlan_hdr->h_vlan_proto = htons(ETH_P_8021Q);
 		vlan_hdr->h_vlan_encapsulated_proto = eth_hdr->h_proto;
diff --git a/drivers/staging/wilc1000/linux_mon.c b/drivers/staging/wilc1000/linux_mon.c
index dbc266a37974..01efa80b4f88 100644
--- a/drivers/staging/wilc1000/linux_mon.c
+++ b/drivers/staging/wilc1000/linux_mon.c
@@ -74,7 +74,7 @@ void WILC_WFI_monitor_rx(u8 *buff, u32 size)
 
 		skb_put_data(skb, buff, size);
 
-		cb_hdr = (struct wilc_wfi_radiotap_cb_hdr *)skb_push(skb, sizeof(*cb_hdr));
+		cb_hdr = skb_push(skb, sizeof(*cb_hdr));
 		memset(cb_hdr, 0, sizeof(struct wilc_wfi_radiotap_cb_hdr));
 
 		cb_hdr->hdr.it_version = 0; /* PKTHDR_RADIOTAP_VERSION; */
@@ -101,7 +101,7 @@ void WILC_WFI_monitor_rx(u8 *buff, u32 size)
 			return;
 
 		skb_put_data(skb, buff, size);
-		hdr = (struct wilc_wfi_radiotap_hdr *)skb_push(skb, sizeof(*hdr));
+		hdr = skb_push(skb, sizeof(*hdr));
 		memset(hdr, 0, sizeof(struct wilc_wfi_radiotap_hdr));
 		hdr->hdr.it_version = 0; /* PKTHDR_RADIOTAP_VERSION; */
 		hdr->hdr.it_len = cpu_to_le16(sizeof(struct wilc_wfi_radiotap_hdr));
@@ -202,7 +202,7 @@ static netdev_tx_t WILC_WFI_mon_xmit(struct sk_buff *skb,
 
 		skb_put_data(skb2, skb->data, skb->len);
 
-		cb_hdr = (struct wilc_wfi_radiotap_cb_hdr *)skb_push(skb2, sizeof(*cb_hdr));
+		cb_hdr = skb_push(skb2, sizeof(*cb_hdr));
 		memset(cb_hdr, 0, sizeof(struct wilc_wfi_radiotap_cb_hdr));
 
 		cb_hdr->hdr.it_version = 0; /* PKTHDR_RADIOTAP_VERSION; */
diff --git a/drivers/staging/wlan-ng/p80211conv.c b/drivers/staging/wlan-ng/p80211conv.c
index a062e80361ef..fc8ad33ade9f 100644
--- a/drivers/staging/wlan-ng/p80211conv.c
+++ b/drivers/staging/wlan-ng/p80211conv.c
@@ -148,9 +148,7 @@ int skb_ether_to_p80211(struct wlandevice *wlandev, u32 ethconv,
 			skb_pull(skb, ETH_HLEN);
 
 			/* tack on SNAP */
-			e_snap =
-			    (struct wlan_snap *)skb_push(skb,
-				sizeof(struct wlan_snap));
+			e_snap = skb_push(skb, sizeof(struct wlan_snap));
 			e_snap->type = htons(proto);
 			if (ethconv == WLAN_ETHCONV_8021h &&
 			    p80211_stt_findproto(proto)) {
@@ -162,9 +160,7 @@ int skb_ether_to_p80211(struct wlandevice *wlandev, u32 ethconv,
 			}
 
 			/* tack on llc */
-			e_llc =
-			    (struct wlan_llc *)skb_push(skb,
-				sizeof(struct wlan_llc));
+			e_llc = skb_push(skb, sizeof(struct wlan_llc));
 			e_llc->dsap = 0xAA;	/* SNAP, see IEEE 802 */
 			e_llc->ssap = 0xAA;
 			e_llc->ctl = 0x03;
@@ -407,7 +403,7 @@ int skb_p80211_to_ether(struct wlandevice *wlandev, u32 ethconv,
 		skb_pull(skb, payload_offset);
 
 		/* create 802.3 header at beginning of skb. */
-		e_hdr = (struct wlan_ethhdr *)skb_push(skb, ETH_HLEN);
+		e_hdr = skb_push(skb, ETH_HLEN);
 		ether_addr_copy(e_hdr->daddr, daddr);
 		ether_addr_copy(e_hdr->saddr, saddr);
 		e_hdr->type = htons(payload_length);
@@ -448,7 +444,7 @@ int skb_p80211_to_ether(struct wlandevice *wlandev, u32 ethconv,
 		skb_pull(skb, sizeof(struct wlan_snap));
 
 		/* create 802.3 header at beginning of skb. */
-		e_hdr = (struct wlan_ethhdr *)skb_push(skb, ETH_HLEN);
+		e_hdr = skb_push(skb, ETH_HLEN);
 		e_hdr->type = e_snap->type;
 		ether_addr_copy(e_hdr->daddr, daddr);
 		ether_addr_copy(e_hdr->saddr, saddr);
@@ -475,7 +471,7 @@ int skb_p80211_to_ether(struct wlandevice *wlandev, u32 ethconv,
 		skb_pull(skb, payload_offset);
 
 		/* create 802.3 header at beginning of skb. */
-		e_hdr = (struct wlan_ethhdr *)skb_push(skb, ETH_HLEN);
+		e_hdr = skb_push(skb, ETH_HLEN);
 		ether_addr_copy(e_hdr->daddr, daddr);
 		ether_addr_copy(e_hdr->saddr, saddr);
 		e_hdr->type = htons(payload_length);
diff --git a/drivers/target/iscsi/cxgbit/cxgbit_target.c b/drivers/target/iscsi/cxgbit/cxgbit_target.c
index bdcc8b4c522a..dda13f1af38e 100644
--- a/drivers/target/iscsi/cxgbit/cxgbit_target.c
+++ b/drivers/target/iscsi/cxgbit/cxgbit_target.c
@@ -136,7 +136,7 @@ cxgbit_cpl_tx_data_iso(struct sk_buff *skb, struct cxgbit_iso_info *iso_info)
 	unsigned int fslice = !!(iso_info->flags & CXGBIT_ISO_FSLICE);
 	unsigned int lslice = !!(iso_info->flags & CXGBIT_ISO_LSLICE);
 
-	cpl = (struct cpl_tx_data_iso *)__skb_push(skb, sizeof(*cpl));
+	cpl = __skb_push(skb, sizeof(*cpl));
 
 	cpl->op_to_scsi = htonl(CPL_TX_DATA_ISO_OP_V(CPL_TX_DATA_ISO) |
 			CPL_TX_DATA_ISO_FIRST_V(fslice) |
@@ -183,8 +183,7 @@ cxgbit_tx_data_wr(struct cxgbit_sock *csk, struct sk_buff *skb, u32 dlen,
 	if (cxgbit_is_ofld_imm(skb))
 		immlen += dlen;
 
-	req = (struct fw_ofld_tx_data_wr *)__skb_push(skb,
-							hdr_size);
+	req = __skb_push(skb, hdr_size);
 	req->op_to_immdlen = cpu_to_be32(FW_WR_OP_V(opcode) |
 					FW_WR_COMPL_V(compl) |
 					FW_WR_IMMDLEN_V(immlen));
diff --git a/drivers/usb/gadget/function/rndis.c b/drivers/usb/gadget/function/rndis.c
index a3b5e468b116..d6341045c631 100644
--- a/drivers/usb/gadget/function/rndis.c
+++ b/drivers/usb/gadget/function/rndis.c
@@ -999,7 +999,7 @@ void rndis_add_hdr(struct sk_buff *skb)
 
 	if (!skb)
 		return;
-	header = (void *)skb_push(skb, sizeof(*header));
+	header = skb_push(skb, sizeof(*header));
 	memset(header, 0, sizeof *header);
 	header->MessageType = cpu_to_le32(RNDIS_MSG_PACKET);
 	header->MessageLength = cpu_to_le32(skb->len);
diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index 283dc2f5364d..5e6a2d4dc366 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -318,7 +318,7 @@ static inline int __vlan_insert_tag(struct sk_buff *skb,
 	if (skb_cow_head(skb, VLAN_HLEN) < 0)
 		return -ENOMEM;
 
-	veth = (struct vlan_ethhdr *)skb_push(skb, VLAN_HLEN);
+	veth = skb_push(skb, VLAN_HLEN);
 
 	/* Move the mac addresses to the beginning of the new header. */
 	memmove(skb->data, skb->data + VLAN_HLEN, 2 * ETH_ALEN);
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index ac9d10dadd1a..46bd514e719c 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1923,8 +1923,8 @@ static inline void *skb_put_data(struct sk_buff *skb, const void *data,
 	return tmp;
 }
 
-unsigned char *skb_push(struct sk_buff *skb, unsigned int len);
-static inline unsigned char *__skb_push(struct sk_buff *skb, unsigned int len)
+void *skb_push(struct sk_buff *skb, unsigned int len);
+static inline void *__skb_push(struct sk_buff *skb, unsigned int len)
 {
 	skb->data -= len;
 	skb->len  += len;
@@ -2951,8 +2951,7 @@ void *skb_pull_rcsum(struct sk_buff *skb, unsigned int len);
  *	that the checksum difference is zero (e.g., a valid IP header)
  *	or you are setting ip_summed to CHECKSUM_NONE.
  */
-static inline unsigned char *skb_push_rcsum(struct sk_buff *skb,
-					    unsigned int len)
+static inline void *skb_push_rcsum(struct sk_buff *skb, unsigned int len)
 {
 	skb_push(skb, len);
 	skb_postpush_rcsum(skb, skb->data, len);
diff --git a/net/802/fc.c b/net/802/fc.c
index 1bb496ea997e..058a9f708918 100644
--- a/net/802/fc.c
+++ b/net/802/fc.c
@@ -49,7 +49,7 @@ static int fc_header(struct sk_buff *skb, struct net_device *dev,
 		struct fcllc *fcllc;
 
 		hdr_len = sizeof(struct fch_hdr) + sizeof(struct fcllc);
-		fch = (struct fch_hdr *)skb_push(skb, hdr_len);
+		fch = skb_push(skb, hdr_len);
 		fcllc = (struct fcllc *)(fch+1);
 		fcllc->dsap = fcllc->ssap = EXTENDED_SAP;
 		fcllc->llc = UI_CMD;
@@ -59,7 +59,7 @@ static int fc_header(struct sk_buff *skb, struct net_device *dev,
 	else
 	{
 		hdr_len = sizeof(struct fch_hdr);
-		fch = (struct fch_hdr *)skb_push(skb, hdr_len);
+		fch = skb_push(skb, hdr_len);
 	}
 
 	if(saddr)
diff --git a/net/802/fddi.c b/net/802/fddi.c
index 6356623fc238..90f1416567a1 100644
--- a/net/802/fddi.c
+++ b/net/802/fddi.c
@@ -58,7 +58,7 @@ static int fddi_header(struct sk_buff *skb, struct net_device *dev,
 
 	if(type != ETH_P_IP && type != ETH_P_IPV6 && type != ETH_P_ARP)
 		hl=FDDI_K_8022_HLEN-3;
-	fddi = (struct fddihdr *)skb_push(skb, hl);
+	fddi = skb_push(skb, hl);
 	fddi->fc			 = FDDI_FC_K_ASYNC_LLC_DEF;
 	if(type == ETH_P_IP || type == ETH_P_IPV6 || type == ETH_P_ARP)
 	{
diff --git a/net/802/hippi.c b/net/802/hippi.c
index 4460606e9c36..690308b9b94a 100644
--- a/net/802/hippi.c
+++ b/net/802/hippi.c
@@ -47,7 +47,7 @@ static int hippi_header(struct sk_buff *skb, struct net_device *dev,
 			unsigned short type,
 			const void *daddr, const void *saddr, unsigned int len)
 {
-	struct hippi_hdr *hip = (struct hippi_hdr *)skb_push(skb, HIPPI_HLEN);
+	struct hippi_hdr *hip = skb_push(skb, HIPPI_HLEN);
 	struct hippi_cb *hcb = (struct hippi_cb *) skb->cb;
 
 	if (!len){
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index c1742322f7d2..f7e83f6d2e64 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -58,7 +58,7 @@ static int vlan_dev_hard_header(struct sk_buff *skb, struct net_device *dev,
 	int rc;
 
 	if (!(vlan->flags & VLAN_FLAG_REORDER_HDR)) {
-		vhdr = (struct vlan_hdr *) skb_push(skb, VLAN_HLEN);
+		vhdr = skb_push(skb, VLAN_HLEN);
 
 		vlan_tci = vlan->vlan_id;
 		vlan_tci |= vlan_dev_get_egress_qos_mask(dev, skb->priority);
diff --git a/net/appletalk/ddp.c b/net/appletalk/ddp.c
index c7af6dc70fa2..5d035c1f1156 100644
--- a/net/appletalk/ddp.c
+++ b/net/appletalk/ddp.c
@@ -1529,7 +1529,7 @@ static int ltalk_rcv(struct sk_buff *skb, struct net_device *dev,
 		 * The push leaves us with a ddephdr not an shdr, and
 		 * handily the port bytes in the right place preset.
 		 */
-		ddp = (struct ddpehdr *) skb_push(skb, sizeof(*ddp) - 4);
+		ddp = skb_push(skb, sizeof(*ddp) - 4);
 
 		/* Now fill in the long header */
 
diff --git a/net/ax25/af_ax25.c b/net/ax25/af_ax25.c
index b7c486752b3a..0c92ba0cbe0b 100644
--- a/net/ax25/af_ax25.c
+++ b/net/ax25/af_ax25.c
@@ -1562,7 +1562,7 @@ static int ax25_sendmsg(struct socket *sock, struct msghdr *msg, size_t len)
 
 	/* Add the PID if one is not supplied by the user in the skb */
 	if (!ax25->pidincl)
-		*skb_push(skb, 1) = sk->sk_protocol;
+		*(u8 *)skb_push(skb, 1) = sk->sk_protocol;
 
 	if (sk->sk_type == SOCK_SEQPACKET) {
 		/* Connected mode sockets go via the LAPB machine */
diff --git a/net/bluetooth/hci_sock.c b/net/bluetooth/hci_sock.c
index 1301a8786d8d..cdb5c1a7481e 100644
--- a/net/bluetooth/hci_sock.c
+++ b/net/bluetooth/hci_sock.c
@@ -332,7 +332,7 @@ void hci_send_to_monitor(struct hci_dev *hdev, struct sk_buff *skb)
 		return;
 
 	/* Put header before the data */
-	hdr = (void *)skb_push(skb_copy, HCI_MON_HDR_SIZE);
+	hdr = skb_push(skb_copy, HCI_MON_HDR_SIZE);
 	hdr->opcode = opcode;
 	hdr->index = cpu_to_le16(hdev->id);
 	hdr->len = cpu_to_le16(skb->len);
@@ -383,7 +383,7 @@ void hci_send_monitor_ctrl_event(struct hci_dev *hdev, u16 event,
 
 		skb->tstamp = tstamp;
 
-		hdr = (void *)skb_push(skb, HCI_MON_HDR_SIZE);
+		hdr = skb_push(skb, HCI_MON_HDR_SIZE);
 		hdr->opcode = cpu_to_le16(HCI_MON_CTRL_EVENT);
 		hdr->index = index;
 		hdr->len = cpu_to_le16(skb->len - HCI_MON_HDR_SIZE);
@@ -467,7 +467,7 @@ static struct sk_buff *create_monitor_event(struct hci_dev *hdev, int event)
 
 	__net_timestamp(skb);
 
-	hdr = (void *)skb_push(skb, HCI_MON_HDR_SIZE);
+	hdr = skb_push(skb, HCI_MON_HDR_SIZE);
 	hdr->opcode = opcode;
 	hdr->index = cpu_to_le16(hdev->id);
 	hdr->len = cpu_to_le16(skb->len - HCI_MON_HDR_SIZE);
@@ -522,7 +522,7 @@ static struct sk_buff *create_monitor_ctrl_open(struct sock *sk)
 
 	__net_timestamp(skb);
 
-	hdr = (void *)skb_push(skb, HCI_MON_HDR_SIZE);
+	hdr = skb_push(skb, HCI_MON_HDR_SIZE);
 	hdr->opcode = cpu_to_le16(HCI_MON_CTRL_OPEN);
 	if (hci_pi(sk)->hdev)
 		hdr->index = cpu_to_le16(hci_pi(sk)->hdev->id);
@@ -560,7 +560,7 @@ static struct sk_buff *create_monitor_ctrl_close(struct sock *sk)
 
 	__net_timestamp(skb);
 
-	hdr = (void *)skb_push(skb, HCI_MON_HDR_SIZE);
+	hdr = skb_push(skb, HCI_MON_HDR_SIZE);
 	hdr->opcode = cpu_to_le16(HCI_MON_CTRL_CLOSE);
 	if (hci_pi(sk)->hdev)
 		hdr->index = cpu_to_le16(hci_pi(sk)->hdev->id);
@@ -590,7 +590,7 @@ static struct sk_buff *create_monitor_ctrl_command(struct sock *sk, u16 index,
 
 	__net_timestamp(skb);
 
-	hdr = (void *)skb_push(skb, HCI_MON_HDR_SIZE);
+	hdr = skb_push(skb, HCI_MON_HDR_SIZE);
 	hdr->opcode = cpu_to_le16(HCI_MON_CTRL_COMMAND);
 	hdr->index = cpu_to_le16(index);
 	hdr->len = cpu_to_le16(skb->len - HCI_MON_HDR_SIZE);
diff --git a/net/bluetooth/mgmt_util.c b/net/bluetooth/mgmt_util.c
index d057113e0d4b..0d0a6d77b9e8 100644
--- a/net/bluetooth/mgmt_util.c
+++ b/net/bluetooth/mgmt_util.c
@@ -48,7 +48,7 @@ static struct sk_buff *create_monitor_ctrl_event(__le16 index, u32 cookie,
 
 	__net_timestamp(skb);
 
-	hdr = (void *)skb_push(skb, HCI_MON_HDR_SIZE);
+	hdr = skb_push(skb, HCI_MON_HDR_SIZE);
 	hdr->opcode = cpu_to_le16(HCI_MON_CTRL_EVENT);
 	hdr->index = index;
 	hdr->len = cpu_to_le16(skb->len - HCI_MON_HDR_SIZE);
diff --git a/net/bluetooth/rfcomm/core.c b/net/bluetooth/rfcomm/core.c
index 1a9b906c5a35..4a0b41d75c84 100644
--- a/net/bluetooth/rfcomm/core.c
+++ b/net/bluetooth/rfcomm/core.c
@@ -1149,10 +1149,10 @@ static void rfcomm_make_uih(struct sk_buff *skb, u8 addr)
 	u8 *crc;
 
 	if (len > 127) {
-		hdr = (void *) skb_push(skb, 4);
+		hdr = skb_push(skb, 4);
 		put_unaligned(cpu_to_le16(__len16(len)), (__le16 *) &hdr->len);
 	} else {
-		hdr = (void *) skb_push(skb, 3);
+		hdr = skb_push(skb, 3);
 		hdr->len = __len8(len);
 	}
 	hdr->addr = addr;
diff --git a/net/bridge/netfilter/nft_reject_bridge.c b/net/bridge/netfilter/nft_reject_bridge.c
index 15bf0c5322ab..a05775afa44b 100644
--- a/net/bridge/netfilter/nft_reject_bridge.c
+++ b/net/bridge/netfilter/nft_reject_bridge.c
@@ -28,7 +28,7 @@ static void nft_reject_br_push_etherhdr(struct sk_buff *oldskb,
 {
 	struct ethhdr *eth;
 
-	eth = (struct ethhdr *)skb_push(nskb, ETH_HLEN);
+	eth = skb_push(nskb, ETH_HLEN);
 	skb_reset_mac_header(nskb);
 	ether_addr_copy(eth->h_source, eth_hdr(oldskb)->h_dest);
 	ether_addr_copy(eth->h_dest, eth_hdr(oldskb)->h_source);
diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index 29be2466970c..37c1e34ddd85 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -441,7 +441,7 @@ void netpoll_send_udp(struct netpoll *np, const char *msg, int len)
 		ip6h->saddr = np->local_ip.in6;
 		ip6h->daddr = np->remote_ip.in6;
 
-		eth = (struct ethhdr *) skb_push(skb, ETH_HLEN);
+		eth = skb_push(skb, ETH_HLEN);
 		skb_reset_mac_header(skb);
 		skb->protocol = eth->h_proto = htons(ETH_P_IPV6);
 	} else {
@@ -470,7 +470,7 @@ void netpoll_send_udp(struct netpoll *np, const char *msg, int len)
 		put_unaligned(np->remote_ip.ip, &(iph->daddr));
 		iph->check    = ip_fast_csum((unsigned char *)iph, iph->ihl);
 
-		eth = (struct ethhdr *) skb_push(skb, ETH_HLEN);
+		eth = skb_push(skb, ETH_HLEN);
 		skb_reset_mac_header(skb);
 		skb->protocol = eth->h_proto = htons(ETH_P_IP);
 	}
diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index b8bcf9021329..2dd42c5b0366 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -2675,7 +2675,7 @@ static int process_ipsec(struct pktgen_dev *pkt_dev,
 				goto err;
 			}
 			/* restore ll */
-			eth = (struct ethhdr *)skb_push(skb, ETH_HLEN);
+			eth = skb_push(skb, ETH_HLEN);
 			memcpy(eth, pkt_dev->hh, 2 * ETH_ALEN);
 			eth->h_proto = protocol;
 
@@ -2844,7 +2844,7 @@ static struct sk_buff *fill_packet_ipv4(struct net_device *odev,
 	skb_reserve(skb, 16);
 
 	/*  Reserve for ethernet and IP header  */
-	eth = (__u8 *) skb_push(skb, 14);
+	eth = skb_push(skb, 14);
 	mpls = skb_put(skb, pkt_dev->nr_labels * sizeof(__u32));
 	if (pkt_dev->nr_labels)
 		mpls_push(mpls, pkt_dev);
@@ -2972,7 +2972,7 @@ static struct sk_buff *fill_packet_ipv6(struct net_device *odev,
 	skb_reserve(skb, 16);
 
 	/*  Reserve for ethernet and IP header  */
-	eth = (__u8 *) skb_push(skb, 14);
+	eth = skb_push(skb, 14);
 	mpls = skb_put(skb, pkt_dev->nr_labels * sizeof(__u32));
 	if (pkt_dev->nr_labels)
 		mpls_push(mpls, pkt_dev);
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 9a1639f7d61a..f75897a33fa4 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -1461,7 +1461,7 @@ EXPORT_SYMBOL(skb_put);
  *	start. If this would exceed the total buffer headroom the kernel will
  *	panic. A pointer to the first byte of the extra data is returned.
  */
-unsigned char *skb_push(struct sk_buff *skb, unsigned int len)
+void *skb_push(struct sk_buff *skb, unsigned int len)
 {
 	skb->data -= len;
 	skb->len  += len;
diff --git a/net/dccp/options.c b/net/dccp/options.c
index 74d29c56c367..51cdfc3bd8ca 100644
--- a/net/dccp/options.c
+++ b/net/dccp/options.c
@@ -484,7 +484,7 @@ int dccp_insert_option_mandatory(struct sk_buff *skb)
 		return -1;
 
 	DCCP_SKB_CB(skb)->dccpd_opt_len++;
-	*skb_push(skb, 1) = DCCPO_MANDATORY;
+	*(u8 *)skb_push(skb, 1) = DCCPO_MANDATORY;
 	return 0;
 }
 
diff --git a/net/decnet/dn_dev.c b/net/decnet/dn_dev.c
index 1d84f6dae315..fa0110b57ca1 100644
--- a/net/decnet/dn_dev.c
+++ b/net/decnet/dn_dev.c
@@ -867,7 +867,7 @@ static void dn_send_endnode_hello(struct net_device *dev, struct dn_ifaddr *ifa)
 	msg->datalen = 0x02;
 	memset(msg->data, 0xAA, 2);
 
-	pktlen = (__le16 *)skb_push(skb,2);
+	pktlen = skb_push(skb, 2);
 	*pktlen = cpu_to_le16(skb->len - 2);
 
 	skb_reset_network_header(skb);
@@ -959,7 +959,7 @@ static void dn_send_router_hello(struct net_device *dev, struct dn_ifaddr *ifa)
 
 	skb_trim(skb, (27 + *i2));
 
-	pktlen = (__le16 *)skb_push(skb, 2);
+	pktlen = skb_push(skb, 2);
 	*pktlen = cpu_to_le16(skb->len - 2);
 
 	skb_reset_network_header(skb);
diff --git a/net/ethernet/eth.c b/net/ethernet/eth.c
index 1446810047f5..eaeba9b99a73 100644
--- a/net/ethernet/eth.c
+++ b/net/ethernet/eth.c
@@ -83,7 +83,7 @@ int eth_header(struct sk_buff *skb, struct net_device *dev,
 	       unsigned short type,
 	       const void *daddr, const void *saddr, unsigned int len)
 {
-	struct ethhdr *eth = (struct ethhdr *)skb_push(skb, ETH_HLEN);
+	struct ethhdr *eth = skb_push(skb, ETH_HLEN);
 
 	if (type != ETH_P_802_3 && type != ETH_P_802_2)
 		eth->h_proto = htons(type);
diff --git a/net/ipv4/esp4.c b/net/ipv4/esp4.c
index d815d1755473..1f18b4650253 100644
--- a/net/ipv4/esp4.c
+++ b/net/ipv4/esp4.c
@@ -609,7 +609,7 @@ static void esp_input_set_header(struct sk_buff *skb, __be32 *seqhi)
 	 * decryption.
 	 */
 	if ((x->props.flags & XFRM_STATE_ESN)) {
-		esph = (void *)skb_push(skb, 4);
+		esph = skb_push(skb, 4);
 		*seqhi = esph->spi;
 		esph->spi = esph->seq_no;
 		esph->seq_no = XFRM_SKB_CB(skb)->seq.input.hi;
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index e90c80a548ad..41394a4b9af9 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -592,7 +592,7 @@ static int ipgre_header(struct sk_buff *skb, struct net_device *dev,
 	struct iphdr *iph;
 	struct gre_base_hdr *greh;
 
-	iph = (struct iphdr *)skb_push(skb, t->hlen + sizeof(*iph));
+	iph = skb_push(skb, t->hlen + sizeof(*iph));
 	greh = (struct gre_base_hdr *)(iph+1);
 	greh->flags = gre_tnl_flags_to_gre_flags(t->parms.o_flags);
 	greh->protocol = htons(type);
diff --git a/net/ipv6/esp6.c b/net/ipv6/esp6.c
index 2ede4e459c4e..d8b40ff4b2e6 100644
--- a/net/ipv6/esp6.c
+++ b/net/ipv6/esp6.c
@@ -538,7 +538,7 @@ static void esp_input_set_header(struct sk_buff *skb, __be32 *seqhi)
 	 * decryption.
 	 */
 	if ((x->props.flags & XFRM_STATE_ESN)) {
-		esph = (void *)skb_push(skb, 4);
+		esph = skb_push(skb, 4);
 		*seqhi = esph->spi;
 		esph->spi = esph->seq_no;
 		esph->seq_no = XFRM_SKB_CB(skb)->seq.input.hi;
diff --git a/net/ipv6/exthdrs.c b/net/ipv6/exthdrs.c
index b636f1da9aec..0460af226011 100644
--- a/net/ipv6/exthdrs.c
+++ b/net/ipv6/exthdrs.c
@@ -847,7 +847,7 @@ static void ipv6_push_rthdr0(struct sk_buff *skb, u8 *proto,
 
 	ihdr = (struct rt0_hdr *) opt;
 
-	phdr = (struct rt0_hdr *) skb_push(skb, (ihdr->rt_hdr.hdrlen + 1) << 3);
+	phdr = skb_push(skb, (ihdr->rt_hdr.hdrlen + 1) << 3);
 	memcpy(phdr, ihdr, sizeof(struct rt0_hdr));
 
 	hops = ihdr->rt_hdr.hdrlen >> 1;
@@ -873,7 +873,7 @@ static void ipv6_push_rthdr4(struct sk_buff *skb, u8 *proto,
 	sr_ihdr = (struct ipv6_sr_hdr *)opt;
 	plen = (sr_ihdr->hdrlen + 1) << 3;
 
-	sr_phdr = (struct ipv6_sr_hdr *)skb_push(skb, plen);
+	sr_phdr = skb_push(skb, plen);
 	memcpy(sr_phdr, sr_ihdr, sizeof(struct ipv6_sr_hdr));
 
 	hops = sr_ihdr->first_segment + 1;
@@ -923,7 +923,7 @@ static void ipv6_push_rthdr(struct sk_buff *skb, u8 *proto,
 
 static void ipv6_push_exthdr(struct sk_buff *skb, u8 *proto, u8 type, struct ipv6_opt_hdr *opt)
 {
-	struct ipv6_opt_hdr *h = (struct ipv6_opt_hdr *)skb_push(skb, ipv6_optlen(opt));
+	struct ipv6_opt_hdr *h = skb_push(skb, ipv6_optlen(opt));
 
 	memcpy(h, opt, ipv6_optlen(opt));
 	h->nexthdr = *proto;
diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
index 64eea3962733..e0e726c338a7 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -942,7 +942,7 @@ static int ip6gre_header(struct sk_buff *skb, struct net_device *dev,
 			const void *daddr, const void *saddr, unsigned int len)
 {
 	struct ip6_tnl *t = netdev_priv(dev);
-	struct ipv6hdr *ipv6h = (struct ipv6hdr *)skb_push(skb, t->hlen);
+	struct ipv6hdr *ipv6h = skb_push(skb, t->hlen);
 	__be16 *p = (__be16 *)(ipv6h+1);
 
 	ip6_flow_hdr(ipv6h, 0,
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 0d6f3b6345de..8b8efb0e55bf 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -682,7 +682,7 @@ int ip6_fragment(struct net *net, struct sock *sk, struct sk_buff *skb,
 		skb_frag_list_init(skb);
 
 		__skb_pull(skb, hlen);
-		fh = (struct frag_hdr *)__skb_push(skb, sizeof(struct frag_hdr));
+		fh = __skb_push(skb, sizeof(struct frag_hdr));
 		__skb_push(skb, hlen);
 		skb_reset_network_header(skb);
 		memcpy(skb_network_header(skb), tmp_hdr, hlen);
@@ -706,7 +706,7 @@ int ip6_fragment(struct net *net, struct sock *sk, struct sk_buff *skb,
 			if (frag) {
 				frag->ip_summed = CHECKSUM_NONE;
 				skb_reset_transport_header(frag);
-				fh = (struct frag_hdr *)__skb_push(frag, sizeof(struct frag_hdr));
+				fh = __skb_push(frag, sizeof(struct frag_hdr));
 				__skb_push(frag, hlen);
 				skb_reset_network_header(frag);
 				memcpy(skb_network_header(frag), tmp_hdr,
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 84ad50218255..6264917fe4c7 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -789,7 +789,7 @@ static void tcp_v6_send_response(const struct sock *sk, struct sk_buff *skb, u32
 
 	skb_reserve(buff, MAX_HEADER + sizeof(struct ipv6hdr) + tot_len);
 
-	t1 = (struct tcphdr *) skb_push(buff, tot_len);
+	t1 = skb_push(buff, tot_len);
 	skb_reset_transport_header(buff);
 
 	/* Swap the send and the receive. */
diff --git a/net/irda/irnet/irnet_irda.c b/net/irda/irnet/irnet_irda.c
index 7f17a8020e8a..e390bceeb2f8 100644
--- a/net/irda/irnet/irnet_irda.c
+++ b/net/irda/irnet/irnet_irda.c
@@ -1065,7 +1065,7 @@ irnet_data_indication(void *	instance,
   if(p[0] & 1)
     {
       /* protocol is compressed */
-      skb_push(skb, 1)[0] = 0;
+      *(u8 *)skb_push(skb, 1) = 0;
     }
   else
     if(skb->len < 2)
diff --git a/net/iucv/af_iucv.c b/net/iucv/af_iucv.c
index 84de7b6326dc..2cf9d59f1b72 100644
--- a/net/iucv/af_iucv.c
+++ b/net/iucv/af_iucv.c
@@ -322,8 +322,7 @@ static int afiucv_hs_send(struct iucv_message *imsg, struct sock *sock,
 	int err, confirm_recv = 0;
 
 	memset(skb->head, 0, ETH_HLEN);
-	phs_hdr = (struct af_iucv_trans_hdr *)skb_push(skb,
-					sizeof(struct af_iucv_trans_hdr));
+	phs_hdr = skb_push(skb, sizeof(struct af_iucv_trans_hdr));
 	skb_reset_mac_header(skb);
 	skb_reset_network_header(skb);
 	skb_push(skb, ETH_HLEN);
diff --git a/net/mac80211/rx.c b/net/mac80211/rx.c
index 53b00bb52095..70e9d2ca8bbe 100644
--- a/net/mac80211/rx.c
+++ b/net/mac80211/rx.c
@@ -273,7 +273,7 @@ ieee80211_add_rx_radiotap_header(struct ieee80211_local *local,
 	if (!(has_fcs && ieee80211_hw_check(&local->hw, RX_INCLUDES_FCS)))
 		mpdulen += FCS_LEN;
 
-	rthdr = (struct ieee80211_radiotap_header *)skb_push(skb, rtap_len);
+	rthdr = skb_push(skb, rtap_len);
 	memset(rthdr, 0, rtap_len - rtap.len - rtap.pad);
 	it_present = &rthdr->it_present;
 
diff --git a/net/mac80211/status.c b/net/mac80211/status.c
index a9fa6ee57e8f..da7427a41529 100644
--- a/net/mac80211/status.c
+++ b/net/mac80211/status.c
@@ -288,7 +288,7 @@ ieee80211_add_tx_radiotap_header(struct ieee80211_local *local,
 	unsigned char *pos;
 	u16 txflags;
 
-	rthdr = (struct ieee80211_radiotap_header *) skb_push(skb, rtap_len);
+	rthdr = skb_push(skb, rtap_len);
 
 	memset(rthdr, 0, rtap_len);
 	rthdr->it_len = cpu_to_le16(rtap_len);
diff --git a/net/mac80211/tx.c b/net/mac80211/tx.c
index ec5a9a72797e..8858f4f185e9 100644
--- a/net/mac80211/tx.c
+++ b/net/mac80211/tx.c
@@ -2708,7 +2708,7 @@ static struct sk_buff *ieee80211_build_hdr(struct ieee80211_sub_if_data *sdata,
 	if (ieee80211_is_data_qos(fc)) {
 		__le16 *qos_control;
 
-		qos_control = (__le16 *) skb_push(skb, 2);
+		qos_control = skb_push(skb, 2);
 		memcpy(skb_push(skb, hdrlen - 2), &hdr, hdrlen - 2);
 		/*
 		 * Maybe we could actually set some fields here, for now just
@@ -3347,7 +3347,7 @@ static bool ieee80211_xmit_fast(struct ieee80211_sub_if_data *sdata,
 	}
 
 	memcpy(&eth, skb->data, ETH_HLEN - 2);
-	hdr = (void *)skb_push(skb, extra_head);
+	hdr = skb_push(skb, extra_head);
 	memcpy(skb->data, fast_tx->hdr, fast_tx->hdr_len);
 	memcpy(skb->data + fast_tx->da_offs, eth.h_dest, ETH_ALEN);
 	memcpy(skb->data + fast_tx->sa_offs, eth.h_source, ETH_ALEN);
diff --git a/net/ncsi/ncsi-cmd.c b/net/ncsi/ncsi-cmd.c
index b010ae94175b..5e03ed190e18 100644
--- a/net/ncsi/ncsi-cmd.c
+++ b/net/ncsi/ncsi-cmd.c
@@ -331,7 +331,7 @@ int ncsi_xmit_cmd(struct ncsi_cmd_arg *nca)
 	}
 
 	/* Fill the ethernet header */
-	eh = (struct ethhdr *)skb_push(nr->cmd, sizeof(*eh));
+	eh = skb_push(nr->cmd, sizeof(*eh));
 	eh->h_proto = htons(ETH_P_NCSI);
 	eth_broadcast_addr(eh->h_dest);
 	eth_broadcast_addr(eh->h_source);
diff --git a/net/nfc/digital_dep.c b/net/nfc/digital_dep.c
index 82471af5553e..f948fc2099d2 100644
--- a/net/nfc/digital_dep.c
+++ b/net/nfc/digital_dep.c
@@ -185,7 +185,7 @@ static void digital_skb_push_dep_sod(struct nfc_digital_dev *ddev,
 	skb->data[0] = skb->len;
 
 	if (ddev->curr_rf_tech == NFC_DIGITAL_RF_TECH_106A)
-		*skb_push(skb, sizeof(u8)) = DIGITAL_NFC_DEP_NFCA_SOD_SB;
+		*(u8 *)skb_push(skb, sizeof(u8)) = DIGITAL_NFC_DEP_NFCA_SOD_SB;
 }
 
 static int digital_skb_pull_dep_sod(struct nfc_digital_dev *ddev,
diff --git a/net/nfc/digital_technology.c b/net/nfc/digital_technology.c
index fae6d31b377c..492204e440ec 100644
--- a/net/nfc/digital_technology.c
+++ b/net/nfc/digital_technology.c
@@ -828,7 +828,7 @@ int digital_in_send_sensf_req(struct nfc_digital_dev *ddev, u8 rf_tech)
 	sensf_req->rc = 0;
 	sensf_req->tsn = 0;
 
-	*skb_push(skb, 1) = size + 1;
+	*(u8 *)skb_push(skb, 1) = size + 1;
 
 	if (!DIGITAL_DRV_CAPS_IN_CRC(ddev))
 		digital_skb_add_crc_f(skb);
@@ -1161,7 +1161,7 @@ static int digital_tg_send_sensf_res(struct nfc_digital_dev *ddev,
 		break;
 	}
 
-	*skb_push(skb, sizeof(u8)) = size + 1;
+	*(u8 *)skb_push(skb, sizeof(u8)) = size + 1;
 
 	if (!DIGITAL_DRV_CAPS_TG_CRC(ddev))
 		digital_skb_add_crc_f(skb);
diff --git a/net/nfc/hci/core.c b/net/nfc/hci/core.c
index 3a0c94590411..7b2bdda1514c 100644
--- a/net/nfc/hci/core.c
+++ b/net/nfc/hci/core.c
@@ -727,7 +727,7 @@ static int hci_transceive(struct nfc_dev *nfc_dev, struct nfc_target *target,
 				break;
 		}
 
-		*skb_push(skb, 1) = 0;	/* CTR, see spec:10.2.2.1 */
+		*(u8 *)skb_push(skb, 1) = 0;	/* CTR, see spec:10.2.2.1 */
 
 		hdev->async_cb_type = HCI_CB_TYPE_TRANSCEIVE;
 		hdev->async_cb = cb;
diff --git a/net/nfc/hci/llc_shdlc.c b/net/nfc/hci/llc_shdlc.c
index 9ab4a05f086f..5bd4529279f5 100644
--- a/net/nfc/hci/llc_shdlc.c
+++ b/net/nfc/hci/llc_shdlc.c
@@ -160,7 +160,7 @@ static int llc_shdlc_send_s_frame(struct llc_shdlc *shdlc,
 	if (skb == NULL)
 		return -ENOMEM;
 
-	*skb_push(skb, 1) = SHDLC_CONTROL_HEAD_S | (sframe_type << 3) | nr;
+	*(u8 *)skb_push(skb, 1) = SHDLC_CONTROL_HEAD_S | (sframe_type << 3) | nr;
 
 	r = shdlc->xmit_to_drv(shdlc->hdev, skb);
 
@@ -178,7 +178,7 @@ static int llc_shdlc_send_u_frame(struct llc_shdlc *shdlc,
 
 	pr_debug("uframe_modifier=%d\n", uframe_modifier);
 
-	*skb_push(skb, 1) = SHDLC_CONTROL_HEAD_U | uframe_modifier;
+	*(u8 *)skb_push(skb, 1) = SHDLC_CONTROL_HEAD_U | uframe_modifier;
 
 	r = shdlc->xmit_to_drv(shdlc->hdev, skb);
 
@@ -551,8 +551,8 @@ static void llc_shdlc_handle_send_queue(struct llc_shdlc *shdlc)
 
 		skb = skb_dequeue(&shdlc->send_q);
 
-		*skb_push(skb, 1) = SHDLC_CONTROL_HEAD_I | (shdlc->ns << 3) |
-				    shdlc->nr;
+		*(u8 *)skb_push(skb, 1) = SHDLC_CONTROL_HEAD_I | (shdlc->ns << 3) |
+					shdlc->nr;
 
 		pr_debug("Sending I-Frame %d, waiting to rcv %d\n", shdlc->ns,
 			 shdlc->nr);
diff --git a/net/nfc/nci/data.c b/net/nfc/nci/data.c
index 2488d9241f1d..908f25e3773e 100644
--- a/net/nfc/nci/data.c
+++ b/net/nfc/nci/data.c
@@ -81,7 +81,7 @@ static inline void nci_push_data_hdr(struct nci_dev *ndev,
 	struct nci_data_hdr *hdr;
 	int plen = skb->len;
 
-	hdr = (struct nci_data_hdr *) skb_push(skb, NCI_DATA_HDR_SIZE);
+	hdr = skb_push(skb, NCI_DATA_HDR_SIZE);
 	hdr->conn_id = conn_id;
 	hdr->rfu = 0;
 	hdr->plen = plen;
diff --git a/net/nfc/nci/hci.c b/net/nfc/nci/hci.c
index d1119bb35f24..3f93df58d9f1 100644
--- a/net/nfc/nci/hci.c
+++ b/net/nfc/nci/hci.c
@@ -170,7 +170,7 @@ static int nci_hci_send_data(struct nci_dev *ndev, u8 pipe,
 		return -ENOMEM;
 
 	skb_reserve(skb, NCI_DATA_HDR_SIZE + 2);
-	*skb_push(skb, 1) = data_type;
+	*(u8 *)skb_push(skb, 1) = data_type;
 
 	do {
 		len = conn_info->max_pkt_payload_len;
@@ -184,7 +184,7 @@ static int nci_hci_send_data(struct nci_dev *ndev, u8 pipe,
 			len = conn_info->max_pkt_payload_len - skb->len - 1;
 		}
 
-		*skb_push(skb, 1) = cb;
+		*(u8 *)skb_push(skb, 1) = cb;
 
 		if (len > 0)
 			skb_put_data(skb, data + i, len);
diff --git a/net/nfc/nci/spi.c b/net/nfc/nci/spi.c
index a502a334918a..3b4512731a2f 100644
--- a/net/nfc/nci/spi.c
+++ b/net/nfc/nci/spi.c
@@ -238,8 +238,8 @@ static struct sk_buff *__nci_spi_read(struct nci_spi *nspi)
 		goto receive_error;
 
 	if (nspi->acknowledge_mode == NCI_SPI_CRC_ENABLED) {
-		*skb_push(skb, 1) = resp_hdr[1];
-		*skb_push(skb, 1) = resp_hdr[0];
+		*(u8 *)skb_push(skb, 1) = resp_hdr[1];
+		*(u8 *)skb_push(skb, 1) = resp_hdr[0];
 	}
 
 	return skb;
diff --git a/net/nfc/rawsock.c b/net/nfc/rawsock.c
index e386e6c90b17..e2188deb08dc 100644
--- a/net/nfc/rawsock.c
+++ b/net/nfc/rawsock.c
@@ -142,7 +142,7 @@ static int rawsock_connect(struct socket *sock, struct sockaddr *_addr,
 
 static int rawsock_add_header(struct sk_buff *skb)
 {
-	*skb_push(skb, NFC_HEADER_SIZE) = 0;
+	*(u8 *)skb_push(skb, NFC_HEADER_SIZE) = 0;
 
 	return 0;
 }
diff --git a/net/sctp/output.c b/net/sctp/output.c
index febcc350cf00..89cee1482d35 100644
--- a/net/sctp/output.c
+++ b/net/sctp/output.c
@@ -585,7 +585,7 @@ int sctp_packet_transmit(struct sctp_packet *packet, gfp_t gfp)
 	sctp_packet_set_owner_w(head, sk);
 
 	/* set sctp header */
-	sh = (struct sctphdr *)skb_push(head, sizeof(struct sctphdr));
+	sh = skb_push(head, sizeof(struct sctphdr));
 	skb_reset_transport_header(head);
 	sh->source = htons(packet->source_port);
 	sh->dest = htons(packet->destination_port);
diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index df73190da761..8feff96a5bef 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -770,8 +770,8 @@ sctp_disposition_t sctp_sf_do_5_1D_ce(struct net *net,
 		auth.skb = chunk->auth_chunk;
 		auth.asoc = chunk->asoc;
 		auth.sctp_hdr = chunk->sctp_hdr;
-		auth.chunk_hdr = (sctp_chunkhdr_t *)skb_push(chunk->auth_chunk,
-					    sizeof(sctp_chunkhdr_t));
+		auth.chunk_hdr = skb_push(chunk->auth_chunk,
+					  sizeof(sctp_chunkhdr_t));
 		skb_pull(chunk->auth_chunk, sizeof(sctp_chunkhdr_t));
 		auth.transport = chunk->transport;
 
diff --git a/net/sctp/ulpevent.c b/net/sctp/ulpevent.c
index e361f0b57fb6..17854fb0e512 100644
--- a/net/sctp/ulpevent.c
+++ b/net/sctp/ulpevent.c
@@ -153,8 +153,7 @@ struct sctp_ulpevent  *sctp_ulpevent_make_assoc_change(
 		sctp_ulpevent_init(event, MSG_NOTIFICATION, skb->truesize);
 
 		/* Include the notification structure */
-		sac = (struct sctp_assoc_change *)
-			skb_push(skb, sizeof(struct sctp_assoc_change));
+		sac = skb_push(skb, sizeof(struct sctp_assoc_change));
 
 		/* Trim the buffer to the right length.  */
 		skb_trim(skb, sizeof(struct sctp_assoc_change) +
@@ -400,7 +399,7 @@ sctp_ulpevent_make_remote_error(const struct sctp_association *asoc,
 	event = sctp_skb2event(skb);
 	sctp_ulpevent_init(event, MSG_NOTIFICATION, skb->truesize);
 
-	sre = (struct sctp_remote_error *) skb_push(skb, sizeof(*sre));
+	sre = skb_push(skb, sizeof(*sre));
 
 	/* Trim the buffer to the right length.  */
 	skb_trim(skb, sizeof(*sre) + elen);
@@ -451,8 +450,7 @@ struct sctp_ulpevent *sctp_ulpevent_make_send_failed(
 	event = sctp_skb2event(skb);
 	sctp_ulpevent_init(event, MSG_NOTIFICATION, skb->truesize);
 
-	ssf = (struct sctp_send_failed *)
-		skb_push(skb, sizeof(struct sctp_send_failed));
+	ssf = skb_push(skb, sizeof(struct sctp_send_failed));
 
 	/* Socket Extensions for SCTP
 	 * 5.3.1.4 SCTP_SEND_FAILED
diff --git a/net/wireless/util.c b/net/wireless/util.c
index 96613fe2c6b1..bcb1284c3415 100644
--- a/net/wireless/util.c
+++ b/net/wireless/util.c
@@ -522,7 +522,7 @@ int ieee80211_data_to_8023_exthdr(struct sk_buff *skb, struct ethhdr *ehdr,
 	pskb_pull(skb, hdrlen);
 
 	if (!ehdr)
-		ehdr = (struct ethhdr *) skb_push(skb, sizeof(struct ethhdr));
+		ehdr = skb_push(skb, sizeof(struct ethhdr));
 	memcpy(ehdr, &tmp, sizeof(tmp));
 
 	return 0;
-- 
2.11.0
