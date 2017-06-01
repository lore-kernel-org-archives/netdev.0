From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v3 4/5] net: dsa: remove out_drop label in taggers rcv
Date: Thu,  1 Jun 2017 16:07:14 -0400
Message-ID: <20170601200715.8438-5-vivien.didelot@savoirfairelinux.com>
References: <20170601200715.8438-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170601200715.8438-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Many rcv functions from net/dsa/tag_*.c have a useless out_drop goto
label which simply returns NULL. Kill it in favor of the obvious.

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 net/dsa/tag_brcm.c    | 11 ++++-------
 net/dsa/tag_dsa.c     | 13 +++++--------
 net/dsa/tag_edsa.c    | 13 +++++--------
 net/dsa/tag_mtk.c     |  9 +++------
 net/dsa/tag_qca.c     | 11 ++++-------
 net/dsa/tag_trailer.c |  9 +++------
 6 files changed, 24 insertions(+), 42 deletions(-)

diff --git a/net/dsa/tag_brcm.c b/net/dsa/tag_brcm.c
index 9f204f18ada3..635ecb6781e4 100644
--- a/net/dsa/tag_brcm.c
+++ b/net/dsa/tag_brcm.c
@@ -104,27 +104,27 @@ static struct sk_buff *brcm_tag_rcv(struct sk_buff *skb, struct net_device *dev,
 	ds = dst->cpu_dp->ds;
 
 	if (unlikely(!pskb_may_pull(skb, BRCM_TAG_LEN)))
-		goto out_drop;
+		return NULL;
 
 	/* skb->data points to the EtherType, the tag is right before it */
 	brcm_tag = skb->data - 2;
 
 	/* The opcode should never be different than 0b000 */
 	if (unlikely((brcm_tag[0] >> BRCM_OPCODE_SHIFT) & BRCM_OPCODE_MASK))
-		goto out_drop;
+		return NULL;
 
 	/* We should never see a reserved reason code without knowing how to
 	 * handle it
 	 */
 	if (unlikely(brcm_tag[2] & BRCM_EG_RC_RSVD))
-		goto out_drop;
+		return NULL;
 
 	/* Locate which port this is coming from */
 	source_port = brcm_tag[3] & BRCM_EG_PID_MASK;
 
 	/* Validate port against switch setup, either the port is totally */
 	if (source_port >= ds->num_ports || !ds->ports[source_port].netdev)
-		goto out_drop;
+		return NULL;
 
 	/* Remove Broadcom tag and update checksum */
 	skb_pull_rcsum(skb, BRCM_TAG_LEN);
@@ -137,9 +137,6 @@ static struct sk_buff *brcm_tag_rcv(struct sk_buff *skb, struct net_device *dev,
 	skb->dev = ds->ports[source_port].netdev;
 
 	return skb;
-
-out_drop:
-	return NULL;
 }
 
 const struct dsa_device_ops brcm_netdev_ops = {
diff --git a/net/dsa/tag_dsa.c b/net/dsa/tag_dsa.c
index 3b62a57956a3..089c99c8ed51 100644
--- a/net/dsa/tag_dsa.c
+++ b/net/dsa/tag_dsa.c
@@ -79,7 +79,7 @@ static struct sk_buff *dsa_rcv(struct sk_buff *skb, struct net_device *dev,
 	int source_port;
 
 	if (unlikely(!pskb_may_pull(skb, DSA_HLEN)))
-		goto out_drop;
+		return NULL;
 
 	/*
 	 * The ethertype field is part of the DSA header.
@@ -90,7 +90,7 @@ static struct sk_buff *dsa_rcv(struct sk_buff *skb, struct net_device *dev,
 	 * Check that frame type is either TO_CPU or FORWARD.
 	 */
 	if ((dsa_header[0] & 0xc0) != 0x00 && (dsa_header[0] & 0xc0) != 0xc0)
-		goto out_drop;
+		return NULL;
 
 	/*
 	 * Determine source device and port.
@@ -103,14 +103,14 @@ static struct sk_buff *dsa_rcv(struct sk_buff *skb, struct net_device *dev,
 	 * port is a registered DSA port.
 	 */
 	if (source_device >= DSA_MAX_SWITCHES)
-		goto out_drop;
+		return NULL;
 
 	ds = dst->ds[source_device];
 	if (!ds)
-		goto out_drop;
+		return NULL;
 
 	if (source_port >= ds->num_ports || !ds->ports[source_port].netdev)
-		goto out_drop;
+		return NULL;
 
 	/*
 	 * Convert the DSA header to an 802.1q header if the 'tagged'
@@ -161,9 +161,6 @@ static struct sk_buff *dsa_rcv(struct sk_buff *skb, struct net_device *dev,
 	skb->dev = ds->ports[source_port].netdev;
 
 	return skb;
-
-out_drop:
-	return NULL;
 }
 
 const struct dsa_device_ops dsa_netdev_ops = {
diff --git a/net/dsa/tag_edsa.c b/net/dsa/tag_edsa.c
index f95cafd05702..a7eed1d43d80 100644
--- a/net/dsa/tag_edsa.c
+++ b/net/dsa/tag_edsa.c
@@ -92,7 +92,7 @@ static struct sk_buff *edsa_rcv(struct sk_buff *skb, struct net_device *dev,
 	int source_port;
 
 	if (unlikely(!pskb_may_pull(skb, EDSA_HLEN)))
-		goto out_drop;
+		return NULL;
 
 	/*
 	 * Skip the two null bytes after the ethertype.
@@ -103,7 +103,7 @@ static struct sk_buff *edsa_rcv(struct sk_buff *skb, struct net_device *dev,
 	 * Check that frame type is either TO_CPU or FORWARD.
 	 */
 	if ((edsa_header[0] & 0xc0) != 0x00 && (edsa_header[0] & 0xc0) != 0xc0)
-		goto out_drop;
+		return NULL;
 
 	/*
 	 * Determine source device and port.
@@ -116,14 +116,14 @@ static struct sk_buff *edsa_rcv(struct sk_buff *skb, struct net_device *dev,
 	 * port is a registered DSA port.
 	 */
 	if (source_device >= DSA_MAX_SWITCHES)
-		goto out_drop;
+		return NULL;
 
 	ds = dst->ds[source_device];
 	if (!ds)
-		goto out_drop;
+		return NULL;
 
 	if (source_port >= ds->num_ports || !ds->ports[source_port].netdev)
-		goto out_drop;
+		return NULL;
 
 	/*
 	 * If the 'tagged' bit is set, convert the DSA tag to a 802.1q
@@ -180,9 +180,6 @@ static struct sk_buff *edsa_rcv(struct sk_buff *skb, struct net_device *dev,
 	skb->dev = ds->ports[source_port].netdev;
 
 	return skb;
-
-out_drop:
-	return NULL;
 }
 
 const struct dsa_device_ops edsa_netdev_ops = {
diff --git a/net/dsa/tag_mtk.c b/net/dsa/tag_mtk.c
index d1258e84cd71..4b4aaf1574aa 100644
--- a/net/dsa/tag_mtk.c
+++ b/net/dsa/tag_mtk.c
@@ -57,7 +57,7 @@ static struct sk_buff *mtk_tag_rcv(struct sk_buff *skb, struct net_device *dev,
 	__be16 *phdr, hdr;
 
 	if (unlikely(!pskb_may_pull(skb, MTK_HDR_LEN)))
-		goto out_drop;
+		return NULL;
 
 	/* The MTK header is added by the switch between src addr
 	 * and ethertype at this point, skb->data points to 2 bytes
@@ -79,19 +79,16 @@ static struct sk_buff *mtk_tag_rcv(struct sk_buff *skb, struct net_device *dev,
 	 */
 	ds = dst->ds[0];
 	if (!ds)
-		goto out_drop;
+		return NULL;
 
 	/* Get source port information */
 	port = (hdr & MTK_HDR_RECV_SOURCE_PORT_MASK);
 	if (!ds->ports[port].netdev)
-		goto out_drop;
+		return NULL;
 
 	skb->dev = ds->ports[port].netdev;
 
 	return skb;
-
-out_drop:
-	return NULL;
 }
 
 const struct dsa_device_ops mtk_netdev_ops = {
diff --git a/net/dsa/tag_qca.c b/net/dsa/tag_qca.c
index 2451007699b7..44f545d2761a 100644
--- a/net/dsa/tag_qca.c
+++ b/net/dsa/tag_qca.c
@@ -77,7 +77,7 @@ static struct sk_buff *qca_tag_rcv(struct sk_buff *skb, struct net_device *dev,
 	__be16 *phdr, hdr;
 
 	if (unlikely(!pskb_may_pull(skb, QCA_HDR_LEN)))
-		goto out_drop;
+		return NULL;
 
 	/* The QCA header is added by the switch between src addr and Ethertype
 	 * At this point, skb->data points to ethertype so header should be
@@ -89,7 +89,7 @@ static struct sk_buff *qca_tag_rcv(struct sk_buff *skb, struct net_device *dev,
 	/* Make sure the version is correct */
 	ver = (hdr & QCA_HDR_RECV_VERSION_MASK) >> QCA_HDR_RECV_VERSION_S;
 	if (unlikely(ver != QCA_HDR_VERSION))
-		goto out_drop;
+		return NULL;
 
 	/* Remove QCA tag and recalculate checksum */
 	skb_pull_rcsum(skb, QCA_HDR_LEN);
@@ -101,20 +101,17 @@ static struct sk_buff *qca_tag_rcv(struct sk_buff *skb, struct net_device *dev,
 	 */
 	ds = dst->cpu_dp->ds;
 	if (!ds)
-		goto out_drop;
+		return NULL;
 
 	/* Get source port information */
 	port = (hdr & QCA_HDR_RECV_SOURCE_PORT_MASK);
 	if (!ds->ports[port].netdev)
-		goto out_drop;
+		return NULL;
 
 	/* Update skb & forward the frame accordingly */
 	skb->dev = ds->ports[port].netdev;
 
 	return skb;
-
-out_drop:
-	return NULL;
 }
 
 const struct dsa_device_ops qca_netdev_ops = {
diff --git a/net/dsa/tag_trailer.c b/net/dsa/tag_trailer.c
index 7488ab2932ab..ec729c0ef390 100644
--- a/net/dsa/tag_trailer.c
+++ b/net/dsa/tag_trailer.c
@@ -70,25 +70,22 @@ static struct sk_buff *trailer_rcv(struct sk_buff *skb, struct net_device *dev,
 	ds = dst->cpu_dp->ds;
 
 	if (skb_linearize(skb))
-		goto out_drop;
+		return NULL;
 
 	trailer = skb_tail_pointer(skb) - 4;
 	if (trailer[0] != 0x80 || (trailer[1] & 0xf8) != 0x00 ||
 	    (trailer[2] & 0xef) != 0x00 || trailer[3] != 0x00)
-		goto out_drop;
+		return NULL;
 
 	source_port = trailer[1] & 7;
 	if (source_port >= ds->num_ports || !ds->ports[source_port].netdev)
-		goto out_drop;
+		return NULL;
 
 	pskb_trim_rcsum(skb, skb->len - 4);
 
 	skb->dev = ds->ports[source_port].netdev;
 
 	return skb;
-
-out_drop:
-	return NULL;
 }
 
 const struct dsa_device_ops trailer_netdev_ops = {
-- 
2.13.0
