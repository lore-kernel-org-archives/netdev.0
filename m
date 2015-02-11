From: Tom Herbert <therbert@google.com>
Subject: [PATCH net-next 7/7] gue: Use checksum partial with remote checksum offload
Date: Tue, 10 Feb 2015 16:30:33 -0800
Message-ID: <1423614633-25042-8-git-send-email-therbert@google.com>
References: <1423614633-25042-1-git-send-email-therbert@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f177.google.com ([209.85.223.177]:41486 "EHLO
	mail-ie0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752350AbbBKAa6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Feb 2015 19:30:58 -0500
Received: by iecrd18 with SMTP id rd18so435958iec.8
        for <netdev@vger.kernel.org>; Tue, 10 Feb 2015 16:30:58 -0800 (PST)
In-Reply-To: <1423614633-25042-1-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change remote checksum handling to set checksum partial as default
behavior. Added an iflink parameter to configure not using
checksum partial (calling csum_partial to update checksum).

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/uapi/linux/fou.h |  1 +
 net/ipv4/fou.c           | 28 ++++++++++++++++++++++------
 2 files changed, 23 insertions(+), 6 deletions(-)

diff --git a/include/uapi/linux/fou.h b/include/uapi/linux/fou.h
index 8df0689..c303588 100644
--- a/include/uapi/linux/fou.h
+++ b/include/uapi/linux/fou.h
@@ -14,6 +14,7 @@ enum {
 	FOU_ATTR_AF,				/* u8 */
 	FOU_ATTR_IPPROTO,			/* u8 */
 	FOU_ATTR_TYPE,				/* u8 */
+	FOU_ATTR_REMCSUM_NOPARTIAL,		/* flag */
 
 	__FOU_ATTR_MAX,
 };
diff --git a/net/ipv4/fou.c b/net/ipv4/fou.c
index d320f57..ff069f6 100644
--- a/net/ipv4/fou.c
+++ b/net/ipv4/fou.c
@@ -22,14 +22,18 @@ static LIST_HEAD(fou_list);
 struct fou {
 	struct socket *sock;
 	u8 protocol;
+	u8 flags;
 	u16 port;
 	struct udp_offload udp_offloads;
 	struct list_head list;
 };
 
+#define FOU_F_REMCSUM_NOPARTIAL BIT(0)
+
 struct fou_cfg {
 	u16 type;
 	u8 protocol;
+	u8 flags;
 	struct udp_port_cfg udp_config;
 };
 
@@ -64,7 +68,8 @@ static int fou_udp_recv(struct sock *sk, struct sk_buff *skb)
 }
 
 static struct guehdr *gue_remcsum(struct sk_buff *skb, struct guehdr *guehdr,
-				  void *data, size_t hdrlen, u8 ipproto)
+				  void *data, size_t hdrlen, u8 ipproto,
+				  bool nopartial)
 {
 	__be16 *pd = data;
 	size_t start = ntohs(pd[0]);
@@ -75,7 +80,8 @@ static struct guehdr *gue_remcsum(struct sk_buff *skb, struct guehdr *guehdr,
 		return NULL;
 	guehdr = (struct guehdr *)&udp_hdr(skb)[1];
 
-	skb_remcsum_process(skb, (void *)guehdr + hdrlen, start, offset, true);
+	skb_remcsum_process(skb, (void *)guehdr + hdrlen,
+			    start, offset, nopartial);
 
 	return guehdr;
 }
@@ -136,7 +142,9 @@ static int gue_udp_recv(struct sock *sk, struct sk_buff *skb)
 
 		if (flags & GUE_PFLAG_REMCSUM) {
 			guehdr = gue_remcsum(skb, guehdr, data + doffset,
-					     hdrlen, guehdr->proto_ctype);
+					     hdrlen, guehdr->proto_ctype,
+					     !!(fou->flags &
+						FOU_F_REMCSUM_NOPARTIAL));
 			if (!guehdr)
 				goto drop;
 
@@ -209,7 +217,7 @@ out_unlock:
 static struct guehdr *gue_gro_remcsum(struct sk_buff *skb, unsigned int off,
 				      struct guehdr *guehdr, void *data,
 				      size_t hdrlen, u8 ipproto,
-				      struct gro_remcsum *grc)
+				      struct gro_remcsum *grc, bool nopartial)
 {
 	__be16 *pd = data;
 	size_t start = ntohs(pd[0]);
@@ -230,7 +238,7 @@ static struct guehdr *gue_gro_remcsum(struct sk_buff *skb, unsigned int off,
 	}
 
 	skb_gro_remcsum_process(skb, (void *)guehdr + hdrlen,
-				start, offset, grc, true);
+				start, offset, grc, nopartial);
 
 	skb->remcsum_offload = 1;
 
@@ -250,6 +258,7 @@ static struct sk_buff **gue_gro_receive(struct sk_buff **head,
 	void *data;
 	u16 doffset = 0;
 	int flush = 1;
+	struct fou *fou = container_of(uoff, struct fou, udp_offloads);
 	struct gro_remcsum grc;
 
 	skb_gro_remcsum_init(&grc);
@@ -294,7 +303,9 @@ static struct sk_buff **gue_gro_receive(struct sk_buff **head,
 		if (flags & GUE_PFLAG_REMCSUM) {
 			guehdr = gue_gro_remcsum(skb, off, guehdr,
 						 data + doffset, hdrlen,
-						 guehdr->proto_ctype, &grc);
+						 guehdr->proto_ctype, &grc,
+						 !!(fou->flags &
+						    FOU_F_REMCSUM_NOPARTIAL));
 			if (!guehdr)
 				goto out;
 
@@ -455,6 +466,7 @@ static int fou_create(struct net *net, struct fou_cfg *cfg,
 
 	sk = sock->sk;
 
+	fou->flags = cfg->flags;
 	fou->port = cfg->udp_config.local_udp_port;
 
 	/* Initial for fou type */
@@ -541,6 +553,7 @@ static struct nla_policy fou_nl_policy[FOU_ATTR_MAX + 1] = {
 	[FOU_ATTR_AF] = { .type = NLA_U8, },
 	[FOU_ATTR_IPPROTO] = { .type = NLA_U8, },
 	[FOU_ATTR_TYPE] = { .type = NLA_U8, },
+	[FOU_ATTR_REMCSUM_NOPARTIAL] = { .type = NLA_FLAG, },
 };
 
 static int parse_nl_config(struct genl_info *info,
@@ -571,6 +584,9 @@ static int parse_nl_config(struct genl_info *info,
 	if (info->attrs[FOU_ATTR_TYPE])
 		cfg->type = nla_get_u8(info->attrs[FOU_ATTR_TYPE]);
 
+	if (info->attrs[FOU_ATTR_REMCSUM_NOPARTIAL])
+		cfg->flags |= FOU_F_REMCSUM_NOPARTIAL;
+
 	return 0;
 }
 
-- 
2.2.0.rc0.207.ga3a616c
