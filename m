From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH 4/5] networking: make skb_pull & friends return void pointers
Date: Fri, 16 Jun 2017 09:07:46 +0200
Message-ID: <20170616070747.3332-5-johannes@sipsolutions.net>
References: <20170616070747.3332-1-johannes@sipsolutions.net>
Cc: Johannes Berg <johannes.berg@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:57664 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752136AbdFPHHw (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 16 Jun 2017 03:07:52 -0400
In-Reply-To: <20170616070747.3332-1-johannes@sipsolutions.net>
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
    identifier fn = {
            skb_pull,
            __skb_pull,
            skb_pull_inline,
            __pskb_pull_tail,
            __pskb_pull,
            pskb_pull
    };
    @@
    - *(fn(SKB, LEN))
    + *(u8 *)fn(SKB, LEN)

    @@
    expression E, SKB, LEN;
    identifier fn = {
            skb_pull,
            __skb_pull,
            skb_pull_inline,
            __pskb_pull_tail,
            __pskb_pull,
            pskb_pull
    };
    type T;
    @@
    - E = ((T *)(fn(SKB, LEN)))
    + E = fn(SKB, LEN)

Signed-off-by: Johannes Berg <johannes.berg@intel.com>
---
 drivers/bluetooth/hci_nokia.c  |  4 ++--
 drivers/isdn/i4l/isdn_ppp.c    |  2 +-
 drivers/net/wan/hdlc_ppp.c     |  2 +-
 drivers/nfc/nxp-nci/firmware.c |  3 +--
 drivers/scsi/fnic/fnic_fcs.c   |  2 +-
 drivers/scsi/qedf/qedf_main.c  |  2 +-
 include/linux/skbuff.h         | 14 +++++++-------
 net/bluetooth/a2mp.c           |  4 ++--
 net/core/skbuff.c              |  6 +++---
 net/ipv4/ipmr.c                |  6 ++++--
 net/ipv4/xfrm4_mode_beet.c     |  3 +--
 net/ipv6/ip6mr.c               |  6 ++++--
 net/ipv6/xfrm6_mode_beet.c     |  2 +-
 13 files changed, 29 insertions(+), 27 deletions(-)

diff --git a/drivers/bluetooth/hci_nokia.c b/drivers/bluetooth/hci_nokia.c
index c1b081725b2c..072a77a61e67 100644
--- a/drivers/bluetooth/hci_nokia.c
+++ b/drivers/bluetooth/hci_nokia.c
@@ -557,7 +557,7 @@ static int nokia_recv_negotiation_packet(struct hci_dev *hdev,
 		goto finish_neg;
 	}
 
-	evt = (struct hci_nokia_neg_evt *)skb_pull(skb, sizeof(*hdr));
+	evt = skb_pull(skb, sizeof(*hdr));
 
 	if (evt->ack != NOKIA_NEG_ACK) {
 		dev_err(dev, "Negotiation received: wrong reply");
@@ -595,7 +595,7 @@ static int nokia_recv_alive_packet(struct hci_dev *hdev, struct sk_buff *skb)
 		goto finish_alive;
 	}
 
-	pkt = (struct hci_nokia_alive_pkt *)skb_pull(skb, sizeof(*hdr));
+	pkt = skb_pull(skb, sizeof(*hdr));
 
 	if (pkt->mid != NOKIA_ALIVE_RESP) {
 		dev_err(dev, "Alive received: invalid response: 0x%02x!",
diff --git a/drivers/isdn/i4l/isdn_ppp.c b/drivers/isdn/i4l/isdn_ppp.c
index 9ce23cf3d7d2..e26cae9baf17 100644
--- a/drivers/isdn/i4l/isdn_ppp.c
+++ b/drivers/isdn/i4l/isdn_ppp.c
@@ -1509,7 +1509,7 @@ int isdn_ppp_autodial_filter(struct sk_buff *skb, isdn_net_local *lp)
 	 * temporarily remove part of the fake header stuck on
 	 * earlier.
 	 */
-	*skb_pull(skb, IPPP_MAX_HEADER - 4) = 1; /* indicate outbound */
+	*(u8 *)skb_pull(skb, IPPP_MAX_HEADER - 4) = 1; /* indicate outbound */
 
 	{
 		__be16 *p = (__be16 *)skb->data;
diff --git a/drivers/net/wan/hdlc_ppp.c b/drivers/net/wan/hdlc_ppp.c
index fa3460a0dbbe..0d2e00ece804 100644
--- a/drivers/net/wan/hdlc_ppp.c
+++ b/drivers/net/wan/hdlc_ppp.c
@@ -448,7 +448,7 @@ static int ppp_rx(struct sk_buff *skb)
 	/* Check HDLC header */
 	if (skb->len < sizeof(struct hdlc_header))
 		goto rx_error;
-	cp = (struct cp_header*)skb_pull(skb, sizeof(struct hdlc_header));
+	cp = skb_pull(skb, sizeof(struct hdlc_header));
 	if (hdr->address != HDLC_ADDR_ALLSTATIONS ||
 	    hdr->control != HDLC_CTRL_UI)
 		goto rx_error;
diff --git a/drivers/nfc/nxp-nci/firmware.c b/drivers/nfc/nxp-nci/firmware.c
index 99ffee1dfd1e..e50c6f67bb39 100644
--- a/drivers/nfc/nxp-nci/firmware.c
+++ b/drivers/nfc/nxp-nci/firmware.c
@@ -311,8 +311,7 @@ void nxp_nci_fw_recv_frame(struct nci_dev *ndev, struct sk_buff *skb)
 		if (nxp_nci_fw_check_crc(skb) != 0x00)
 			fw_info->cmd_result = -EBADMSG;
 		else
-			fw_info->cmd_result = nxp_nci_fw_read_status(
-					*skb_pull(skb, NXP_NCI_FW_HDR_LEN));
+			fw_info->cmd_result = nxp_nci_fw_read_status(*(u8 *)skb_pull(skb, NXP_NCI_FW_HDR_LEN));
 		kfree_skb(skb);
 	} else {
 		fw_info->cmd_result = -EIO;
diff --git a/drivers/scsi/fnic/fnic_fcs.c b/drivers/scsi/fnic/fnic_fcs.c
index 245dcd95e11f..e3b964b7235a 100644
--- a/drivers/scsi/fnic/fnic_fcs.c
+++ b/drivers/scsi/fnic/fnic_fcs.c
@@ -640,7 +640,7 @@ static inline int fnic_import_rq_eth_pkt(struct fnic *fnic, struct sk_buff *skb)
 	eh = (struct ethhdr *)skb->data;
 	if (eh->h_proto == htons(ETH_P_8021Q)) {
 		memmove((u8 *)eh + VLAN_HLEN, eh, ETH_ALEN * 2);
-		eh = (struct ethhdr *)skb_pull(skb, VLAN_HLEN);
+		eh = skb_pull(skb, VLAN_HLEN);
 		skb_reset_mac_header(skb);
 	}
 	if (eh->h_proto == htons(ETH_P_FIP)) {
diff --git a/drivers/scsi/qedf/qedf_main.c b/drivers/scsi/qedf/qedf_main.c
index da0fcce6f842..542a6e75c2bb 100644
--- a/drivers/scsi/qedf/qedf_main.c
+++ b/drivers/scsi/qedf/qedf_main.c
@@ -2117,7 +2117,7 @@ static void qedf_ll2_process_skb(struct work_struct *work)
 	/* Undo VLAN encapsulation */
 	if (eh->h_proto == htons(ETH_P_8021Q)) {
 		memmove((u8 *)eh + VLAN_HLEN, eh, ETH_ALEN * 2);
-		eh = (struct ethhdr *)skb_pull(skb, VLAN_HLEN);
+		eh = skb_pull(skb, VLAN_HLEN);
 		skb_reset_mac_header(skb);
 	}
 
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 454ea37dddbb..ac9d10dadd1a 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1931,22 +1931,22 @@ static inline unsigned char *__skb_push(struct sk_buff *skb, unsigned int len)
 	return skb->data;
 }
 
-unsigned char *skb_pull(struct sk_buff *skb, unsigned int len);
-static inline unsigned char *__skb_pull(struct sk_buff *skb, unsigned int len)
+void *skb_pull(struct sk_buff *skb, unsigned int len);
+static inline void *__skb_pull(struct sk_buff *skb, unsigned int len)
 {
 	skb->len -= len;
 	BUG_ON(skb->len < skb->data_len);
 	return skb->data += len;
 }
 
-static inline unsigned char *skb_pull_inline(struct sk_buff *skb, unsigned int len)
+static inline void *skb_pull_inline(struct sk_buff *skb, unsigned int len)
 {
 	return unlikely(len > skb->len) ? NULL : __skb_pull(skb, len);
 }
 
-unsigned char *__pskb_pull_tail(struct sk_buff *skb, int delta);
+void *__pskb_pull_tail(struct sk_buff *skb, int delta);
 
-static inline unsigned char *__pskb_pull(struct sk_buff *skb, unsigned int len)
+static inline void *__pskb_pull(struct sk_buff *skb, unsigned int len)
 {
 	if (len > skb_headlen(skb) &&
 	    !__pskb_pull_tail(skb, len - skb_headlen(skb)))
@@ -1955,7 +1955,7 @@ static inline unsigned char *__pskb_pull(struct sk_buff *skb, unsigned int len)
 	return skb->data += len;
 }
 
-static inline unsigned char *pskb_pull(struct sk_buff *skb, unsigned int len)
+static inline void *pskb_pull(struct sk_buff *skb, unsigned int len)
 {
 	return unlikely(len > skb->len) ? NULL : __pskb_pull(skb, len);
 }
@@ -2938,7 +2938,7 @@ static inline void skb_postpush_rcsum(struct sk_buff *skb,
 	__skb_postpush_rcsum(skb, start, len, 0);
 }
 
-unsigned char *skb_pull_rcsum(struct sk_buff *skb, unsigned int len);
+void *skb_pull_rcsum(struct sk_buff *skb, unsigned int len);
 
 /**
  *	skb_push_rcsum - push skb and update receive checksum
diff --git a/net/bluetooth/a2mp.c b/net/bluetooth/a2mp.c
index f0095fd79818..aad994edd3bb 100644
--- a/net/bluetooth/a2mp.c
+++ b/net/bluetooth/a2mp.c
@@ -239,7 +239,7 @@ static int a2mp_discover_rsp(struct amp_mgr *mgr, struct sk_buff *skb,
 		}
 
 		len -= sizeof(*cl);
-		cl = (void *) skb_pull(skb, sizeof(*cl));
+		cl = skb_pull(skb, sizeof(*cl));
 	}
 
 	/* Fall back to L2CAP init sequence */
@@ -279,7 +279,7 @@ static int a2mp_change_notify(struct amp_mgr *mgr, struct sk_buff *skb,
 	while (skb->len >= sizeof(*cl)) {
 		BT_DBG("Controller id %d type %d status %d", cl->id, cl->type,
 		       cl->status);
-		cl = (struct a2mp_cl *) skb_pull(skb, sizeof(*cl));
+		cl = skb_pull(skb, sizeof(*cl));
 	}
 
 	/* TODO send A2MP_CHANGE_RSP */
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 0baa7f2dd8ef..9a1639f7d61a 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -1481,7 +1481,7 @@ EXPORT_SYMBOL(skb_push);
  *	is returned. Once the data has been pulled future pushes will overwrite
  *	the old data.
  */
-unsigned char *skb_pull(struct sk_buff *skb, unsigned int len)
+void *skb_pull(struct sk_buff *skb, unsigned int len)
 {
 	return skb_pull_inline(skb, len);
 }
@@ -1616,7 +1616,7 @@ EXPORT_SYMBOL(___pskb_trim);
  *
  * It is pretty complicated. Luckily, it is called only in exceptional cases.
  */
-unsigned char *__pskb_pull_tail(struct sk_buff *skb, int delta)
+void *__pskb_pull_tail(struct sk_buff *skb, int delta)
 {
 	/* If skb has not enough free space at tail, get new one
 	 * plus 128 bytes for future expansions. If we have enough
@@ -3065,7 +3065,7 @@ EXPORT_SYMBOL_GPL(skb_append_pagefrags);
  *	that the checksum difference is zero (e.g., a valid IP header)
  *	or you are setting ip_summed to CHECKSUM_NONE.
  */
-unsigned char *skb_pull_rcsum(struct sk_buff *skb, unsigned int len)
+void *skb_pull_rcsum(struct sk_buff *skb, unsigned int len)
 {
 	unsigned char *data = skb->data;
 
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index abbd7c992960..3e7454aa49e8 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -669,7 +669,8 @@ static void ipmr_destroy_unres(struct mr_table *mrt, struct mfc_cache *c)
 
 	while ((skb = skb_dequeue(&c->mfc_un.unres.unresolved))) {
 		if (ip_hdr(skb)->version == 0) {
-			struct nlmsghdr *nlh = (struct nlmsghdr *)skb_pull(skb, sizeof(struct iphdr));
+			struct nlmsghdr *nlh = skb_pull(skb,
+							sizeof(struct iphdr));
 			nlh->nlmsg_type = NLMSG_ERROR;
 			nlh->nlmsg_len = nlmsg_msg_size(sizeof(struct nlmsgerr));
 			skb_trim(skb, nlh->nlmsg_len);
@@ -972,7 +973,8 @@ static void ipmr_cache_resolve(struct net *net, struct mr_table *mrt,
 	/* Play the pending entries through our router */
 	while ((skb = __skb_dequeue(&uc->mfc_un.unres.unresolved))) {
 		if (ip_hdr(skb)->version == 0) {
-			struct nlmsghdr *nlh = (struct nlmsghdr *)skb_pull(skb, sizeof(struct iphdr));
+			struct nlmsghdr *nlh = skb_pull(skb,
+							sizeof(struct iphdr));
 
 			if (__ipmr_fill_mroute(mrt, skb, c, nlmsg_data(nlh)) > 0) {
 				nlh->nlmsg_len = skb_tail_pointer(skb) -
diff --git a/net/ipv4/xfrm4_mode_beet.c b/net/ipv4/xfrm4_mode_beet.c
index 71acd0014f2d..856d2dfdb44b 100644
--- a/net/ipv4/xfrm4_mode_beet.c
+++ b/net/ipv4/xfrm4_mode_beet.c
@@ -57,8 +57,7 @@ static int xfrm4_beet_output(struct xfrm_state *x, struct sk_buff *skb)
 
 	xfrm4_beet_make_header(skb);
 
-	ph = (struct ip_beet_phdr *)
-		__skb_pull(skb, XFRM_MODE_SKB_CB(skb)->ihl - hdrlen);
+	ph = __skb_pull(skb, XFRM_MODE_SKB_CB(skb)->ihl - hdrlen);
 
 	top_iph = ip_hdr(skb);
 
diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index 2ecb39b943b5..b0e2bf1f4212 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -846,7 +846,8 @@ static void ip6mr_destroy_unres(struct mr6_table *mrt, struct mfc6_cache *c)
 
 	while ((skb = skb_dequeue(&c->mfc_un.unres.unresolved)) != NULL) {
 		if (ipv6_hdr(skb)->version == 0) {
-			struct nlmsghdr *nlh = (struct nlmsghdr *)skb_pull(skb, sizeof(struct ipv6hdr));
+			struct nlmsghdr *nlh = skb_pull(skb,
+							sizeof(struct ipv6hdr));
 			nlh->nlmsg_type = NLMSG_ERROR;
 			nlh->nlmsg_len = nlmsg_msg_size(sizeof(struct nlmsgerr));
 			skb_trim(skb, nlh->nlmsg_len);
@@ -1106,7 +1107,8 @@ static void ip6mr_cache_resolve(struct net *net, struct mr6_table *mrt,
 
 	while ((skb = __skb_dequeue(&uc->mfc_un.unres.unresolved))) {
 		if (ipv6_hdr(skb)->version == 0) {
-			struct nlmsghdr *nlh = (struct nlmsghdr *)skb_pull(skb, sizeof(struct ipv6hdr));
+			struct nlmsghdr *nlh = skb_pull(skb,
+							sizeof(struct ipv6hdr));
 
 			if (__ip6mr_fill_mroute(mrt, skb, c, nlmsg_data(nlh)) > 0) {
 				nlh->nlmsg_len = skb_tail_pointer(skb) - (u8 *)nlh;
diff --git a/net/ipv6/xfrm6_mode_beet.c b/net/ipv6/xfrm6_mode_beet.c
index 1e205c3253ac..57fd314ec2b8 100644
--- a/net/ipv6/xfrm6_mode_beet.c
+++ b/net/ipv6/xfrm6_mode_beet.c
@@ -54,7 +54,7 @@ static int xfrm6_beet_output(struct xfrm_state *x, struct sk_buff *skb)
 	skb->mac_header = skb->network_header +
 			  offsetof(struct ipv6hdr, nexthdr);
 	skb->transport_header = skb->network_header + sizeof(*top_iph);
-	ph = (struct ip_beet_phdr *)__skb_pull(skb, XFRM_MODE_SKB_CB(skb)->ihl-hdr_len);
+	ph = __skb_pull(skb, XFRM_MODE_SKB_CB(skb)->ihl - hdr_len);
 
 	xfrm6_beet_make_header(skb);
 
-- 
2.11.0
