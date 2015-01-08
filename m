From: Tom Herbert <therbert@google.com>
Subject: [PATCHn net-next] vxlan: Improve support for header flags
Date: Thu,  8 Jan 2015 12:31:18 -0800
Message-ID: <1420749078-18913-1-git-send-email-therbert@google.com>
To: davem@davemloft.net, tgraf@suug.ch, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:56252 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752141AbbAHUbd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2015 15:31:33 -0500
Received: by mail-ig0-f178.google.com with SMTP id b16so4838668igk.5
        for <netdev@vger.kernel.org>; Thu, 08 Jan 2015 12:31:33 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch cleans up the header flags of VXLAN in anticipation of
defining some new ones:

- Move header related definitions from vxlan.c to vxlan.h
- Change VXLAN_FLAGS to be VXLAN_HF_VNI (only currently defined flag)
- Move check for unknown flags to after we find vxlan_sock, this
  assumes that some flags may be processed based on tunnel
  configuration
- Add a comment about why the stack treating unknown set flags as an
  error instead of ignoring them

Signed-off-by: Tom Herbert <therbert@google.com>
---
 drivers/net/vxlan.c | 42 ++++++++++++++++++++++++++++--------------
 include/net/vxlan.h |  7 +++++++
 2 files changed, 35 insertions(+), 14 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 2ab0922..3a18d8e 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -61,12 +61,6 @@
 #define FDB_AGE_DEFAULT 300 /* 5 min */
 #define FDB_AGE_INTERVAL (10 * HZ)	/* rescan interval */
 
-#define VXLAN_N_VID	(1u << 24)
-#define VXLAN_VID_MASK	(VXLAN_N_VID - 1)
-#define VXLAN_HLEN (sizeof(struct udphdr) + sizeof(struct vxlanhdr))
-
-#define VXLAN_FLAGS 0x08000000	/* struct vxlanhdr.vx_flags required value. */
-
 /* UDP port for VXLAN traffic.
  * The IANA assigned port is 4789, but the Linux default is 8472
  * for compatibility with early adopters.
@@ -1095,18 +1089,21 @@ static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 {
 	struct vxlan_sock *vs;
 	struct vxlanhdr *vxh;
+	u32 flags, vni;
 
 	/* Need Vxlan and inner Ethernet header to be present */
 	if (!pskb_may_pull(skb, VXLAN_HLEN))
 		goto error;
 
-	/* Return packets with reserved bits set */
 	vxh = (struct vxlanhdr *)(udp_hdr(skb) + 1);
-	if (vxh->vx_flags != htonl(VXLAN_FLAGS) ||
-	    (vxh->vx_vni & htonl(0xff))) {
-		netdev_dbg(skb->dev, "invalid vxlan flags=%#x vni=%#x\n",
-			   ntohl(vxh->vx_flags), ntohl(vxh->vx_vni));
-		goto error;
+	flags = ntohl(vxh->vx_flags);
+	vni = ntohl(vxh->vx_vni);
+
+	if (flags & VXLAN_HF_VNI) {
+		flags &= ~VXLAN_HF_VNI;
+	} else {
+		/* VNI flag always required to be set */
+		goto bad_flags;
 	}
 
 	if (iptunnel_pull_header(skb, VXLAN_HLEN, htons(ETH_P_TEB)))
@@ -1116,6 +1113,19 @@ static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 	if (!vs)
 		goto drop;
 
+	if (flags || (vni & 0xff)) {
+		/* If there are any unprocessed flags remaining treat
+		 * this as a malformed packet. This behavior diverges from
+		 * VXLAN RFC (RFC7348) which stipulates that bits in reserved
+		 * in reserved fields are to be ignored. The approach here
+		 * maintains compatbility with previous stack code, and also
+		 * is more robust and provides a little more security in
+		 * adding extensions to VXLAN.
+		 */
+
+		goto bad_flags;
+	}
+
 	vs->rcv(vs, skb, vxh->vx_vni);
 	return 0;
 
@@ -1124,6 +1134,10 @@ drop:
 	kfree_skb(skb);
 	return 0;
 
+bad_flags:
+	netdev_dbg(skb->dev, "invalid vxlan flags=%#x vni=%#x\n",
+		   ntohl(vxh->vx_flags), ntohl(vxh->vx_vni));
+
 error:
 	/* Return non vxlan pkt */
 	return 1;
@@ -1563,7 +1577,7 @@ static int vxlan6_xmit_skb(struct vxlan_sock *vs,
 	}
 
 	vxh = (struct vxlanhdr *) __skb_push(skb, sizeof(*vxh));
-	vxh->vx_flags = htonl(VXLAN_FLAGS);
+	vxh->vx_flags = htonl(VXLAN_HF_VNI);
 	vxh->vx_vni = vni;
 
 	skb_set_inner_protocol(skb, htons(ETH_P_TEB));
@@ -1607,7 +1621,7 @@ int vxlan_xmit_skb(struct vxlan_sock *vs,
 		return -ENOMEM;
 
 	vxh = (struct vxlanhdr *) __skb_push(skb, sizeof(*vxh));
-	vxh->vx_flags = htonl(VXLAN_FLAGS);
+	vxh->vx_flags = htonl(VXLAN_HF_VNI);
 	vxh->vx_vni = vni;
 
 	skb_set_inner_protocol(skb, htons(ETH_P_TEB));
diff --git a/include/net/vxlan.h b/include/net/vxlan.h
index 903461a..a0d8073 100644
--- a/include/net/vxlan.h
+++ b/include/net/vxlan.h
@@ -17,6 +17,13 @@ struct vxlanhdr {
 	__be32 vx_vni;
 };
 
+/* VXLAN header flags. */
+#define VXLAN_HF_VNI 0x08000000
+
+#define VXLAN_N_VID     (1u << 24)
+#define VXLAN_VID_MASK  (VXLAN_N_VID - 1)
+#define VXLAN_HLEN (sizeof(struct udphdr) + sizeof(struct vxlanhdr))
+
 struct vxlan_sock;
 typedef void (vxlan_rcv_t)(struct vxlan_sock *vh, struct sk_buff *skb, __be32 key);
 
-- 
2.2.0.rc0.207.ga3a616c
