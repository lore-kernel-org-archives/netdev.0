From: Tom Herbert <therbert@google.com>
Subject: [PATCH net-next 6/7] vxlan: Use checksum partial with remote checksum offload
Date: Tue, 10 Feb 2015 16:30:32 -0800
Message-ID: <1423614633-25042-7-git-send-email-therbert@google.com>
References: <1423614633-25042-1-git-send-email-therbert@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f169.google.com ([209.85.213.169]:51692 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752086AbbBKAa5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Feb 2015 19:30:57 -0500
Received: by mail-ig0-f169.google.com with SMTP id hl2so25000911igb.0
        for <netdev@vger.kernel.org>; Tue, 10 Feb 2015 16:30:56 -0800 (PST)
In-Reply-To: <1423614633-25042-1-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change remote checksum handling to set checksum partial as default
behavior. Added an iflink parameter to configure not using
checksum partial (calling csum_partial to update checksum).

Signed-off-by: Tom Herbert <therbert@google.com>
---
 drivers/net/vxlan.c          | 25 +++++++++++++++++++------
 include/net/vxlan.h          |  4 +++-
 include/uapi/linux/if_link.h |  1 +
 3 files changed, 23 insertions(+), 7 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 4f04443..1e0a775 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -555,7 +555,8 @@ static int vxlan_fdb_append(struct vxlan_fdb *f,
 static struct vxlanhdr *vxlan_gro_remcsum(struct sk_buff *skb,
 					  unsigned int off,
 					  struct vxlanhdr *vh, size_t hdrlen,
-					  u32 data, struct gro_remcsum *grc)
+					  u32 data, struct gro_remcsum *grc,
+					  bool nopartial)
 {
 	size_t start, offset, plen;
 
@@ -580,7 +581,7 @@ static struct vxlanhdr *vxlan_gro_remcsum(struct sk_buff *skb,
 	}
 
 	skb_gro_remcsum_process(skb, (void *)vh + hdrlen,
-				start, offset, grc, true);
+				start, offset, grc, nopartial);
 
 	skb->remcsum_offload = 1;
 
@@ -618,7 +619,9 @@ static struct sk_buff **vxlan_gro_receive(struct sk_buff **head,
 
 	if ((flags & VXLAN_HF_RCO) && (vs->flags & VXLAN_F_REMCSUM_RX)) {
 		vh = vxlan_gro_remcsum(skb, off_vx, vh, sizeof(struct vxlanhdr),
-				       ntohl(vh->vx_vni), &grc);
+				       ntohl(vh->vx_vni), &grc,
+				       !!(vs->flags &
+					  VXLAN_F_REMCSUM_NOPARTIAL));
 
 		if (!vh)
 			goto out;
@@ -1155,7 +1158,7 @@ static void vxlan_igmp_leave(struct work_struct *work)
 }
 
 static struct vxlanhdr *vxlan_remcsum(struct sk_buff *skb, struct vxlanhdr *vh,
-				      size_t hdrlen, u32 data)
+				      size_t hdrlen, u32 data, bool nopartial)
 {
 	size_t start, offset, plen;
 
@@ -1171,7 +1174,8 @@ static struct vxlanhdr *vxlan_remcsum(struct sk_buff *skb, struct vxlanhdr *vh,
 
 	vh = (struct vxlanhdr *)(udp_hdr(skb) + 1);
 
-	skb_remcsum_process(skb, (void *)vh + hdrlen, start, offset, true);
+	skb_remcsum_process(skb, (void *)vh + hdrlen, start, offset,
+			    nopartial);
 
 	return vh;
 }
@@ -1208,7 +1212,8 @@ static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 		goto drop;
 
 	if ((flags & VXLAN_HF_RCO) && (vs->flags & VXLAN_F_REMCSUM_RX)) {
-		vxh = vxlan_remcsum(skb, vxh, sizeof(struct vxlanhdr), vni);
+		vxh = vxlan_remcsum(skb, vxh, sizeof(struct vxlanhdr), vni,
+				    !!(vs->flags & VXLAN_F_REMCSUM_NOPARTIAL));
 		if (!vxh)
 			goto drop;
 
@@ -2437,6 +2442,7 @@ static const struct nla_policy vxlan_policy[IFLA_VXLAN_MAX + 1] = {
 	[IFLA_VXLAN_REMCSUM_TX]	= { .type = NLA_U8 },
 	[IFLA_VXLAN_REMCSUM_RX]	= { .type = NLA_U8 },
 	[IFLA_VXLAN_GBP]	= { .type = NLA_FLAG, },
+	[IFLA_VXLAN_REMCSUM_NOPARTIAL]	= { .type = NLA_FLAG },
 };
 
 static int vxlan_validate(struct nlattr *tb[], struct nlattr *data[])
@@ -2760,6 +2766,9 @@ static int vxlan_newlink(struct net *src_net, struct net_device *dev,
 	if (data[IFLA_VXLAN_GBP])
 		vxlan->flags |= VXLAN_F_GBP;
 
+	if (data[IFLA_VXLAN_REMCSUM_NOPARTIAL])
+		vxlan->flags |= VXLAN_F_REMCSUM_NOPARTIAL;
+
 	if (vxlan_find_vni(src_net, vni, use_ipv6 ? AF_INET6 : AF_INET,
 			   vxlan->dst_port, vxlan->flags)) {
 		pr_info("duplicate VNI %u\n", vni);
@@ -2909,6 +2918,10 @@ static int vxlan_fill_info(struct sk_buff *skb, const struct net_device *dev)
 	    nla_put_flag(skb, IFLA_VXLAN_GBP))
 		goto nla_put_failure;
 
+	if (vxlan->flags & VXLAN_F_REMCSUM_NOPARTIAL &&
+	    nla_put_flag(skb, IFLA_VXLAN_REMCSUM_NOPARTIAL))
+		goto nla_put_failure;
+
 	return 0;
 
 nla_put_failure:
diff --git a/include/net/vxlan.h b/include/net/vxlan.h
index 2927d62..eabd3a0 100644
--- a/include/net/vxlan.h
+++ b/include/net/vxlan.h
@@ -128,13 +128,15 @@ struct vxlan_sock {
 #define VXLAN_F_REMCSUM_TX		0x200
 #define VXLAN_F_REMCSUM_RX		0x400
 #define VXLAN_F_GBP			0x800
+#define VXLAN_F_REMCSUM_NOPARTIAL	0x1000
 
 /* Flags that are used in the receive patch. These flags must match in
  * order for a socket to be shareable
  */
 #define VXLAN_F_RCV_FLAGS		(VXLAN_F_GBP |			\
 					 VXLAN_F_UDP_ZERO_CSUM6_RX |	\
-					 VXLAN_F_REMCSUM_RX)
+					 VXLAN_F_REMCSUM_RX |		\
+					 VXLAN_F_REMCSUM_NOPARTIAL)
 
 struct vxlan_sock *vxlan_sock_add(struct net *net, __be16 port,
 				  vxlan_rcv_t *rcv, void *data,
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index 0deee3e..dfd0bb2 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -374,6 +374,7 @@ enum {
 	IFLA_VXLAN_REMCSUM_TX,
 	IFLA_VXLAN_REMCSUM_RX,
 	IFLA_VXLAN_GBP,
+	IFLA_VXLAN_REMCSUM_NOPARTIAL,
 	__IFLA_VXLAN_MAX
 };
 #define IFLA_VXLAN_MAX	(__IFLA_VXLAN_MAX - 1)
-- 
2.2.0.rc0.207.ga3a616c
