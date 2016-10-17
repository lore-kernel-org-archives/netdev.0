From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH v2 net-next 7/7] fou: Support flow dissection
Date: Mon, 17 Oct 2016 12:42:02 -0700
Message-ID: <20161017194202.3510238-8-tom@herbertland.com>
References: <20161017194202.3510238-1-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:50556 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S935131AbcJQTmQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2016 15:42:16 -0400
Received: from pps.filterd (m0001303.ppops.net [127.0.0.1])
        by m0001303.ppops.net (8.16.0.17/8.16.0.17) with SMTP id u9HJfdOj008123
        for <netdev@vger.kernel.org>; Mon, 17 Oct 2016 12:42:15 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by m0001303.ppops.net with ESMTP id 26512nn95q-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 17 Oct 2016 12:42:15 -0700
Received: from facebook.com (2401:db00:21:6030:face:0:92:0)     by
 mx-out.facebook.com (10.223.100.97) with ESMTP id
 cd67092694a111e69ab924be0593f280-726f9a50 for <netdev@vger.kernel.org>;        Mon,
 17 Oct 2016 12:42:14 -0700
In-Reply-To: <20161017194202.3510238-1-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch performs flow dissection for GUE and FOU. This is an
optional feature on the receiver and is set by FOU_ATTR_DEEP_HASH
netlink configuration. When enable the UDP socket flow_dissect
function is set to fou_flow_dissect or gue_flow_dissect as
appropriate. These functions return FLOW_DIS_RET_IPPROTO and
set ip protocol argument. In the case of GUE the header is
parsed to find the protocol number.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 include/uapi/linux/fou.h |  1 +
 net/ipv4/fou.c           | 68 +++++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 68 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/fou.h b/include/uapi/linux/fou.h
index d2947c5..2c837eb 100644
--- a/include/uapi/linux/fou.h
+++ b/include/uapi/linux/fou.h
@@ -15,6 +15,7 @@ enum {
 	FOU_ATTR_IPPROTO,			/* u8 */
 	FOU_ATTR_TYPE,				/* u8 */
 	FOU_ATTR_REMCSUM_NOPARTIAL,		/* flag */
+	FOU_ATTR_DEEP_HASH,			/* flag */
 
 	__FOU_ATTR_MAX,
 };
diff --git a/net/ipv4/fou.c b/net/ipv4/fou.c
index cf50f7e..95ac5a8 100644
--- a/net/ipv4/fou.c
+++ b/net/ipv4/fou.c
@@ -27,7 +27,8 @@ struct fou {
 	struct rcu_head rcu;
 };
 
-#define FOU_F_REMCSUM_NOPARTIAL BIT(0)
+#define FOU_F_REMCSUM_NOPARTIAL	BIT(0)
+#define FOU_F_DEEP_HASH		BIT(1)
 
 struct fou_cfg {
 	u16 type;
@@ -281,6 +282,16 @@ static int fou_gro_complete(struct sock *sk, struct sk_buff *skb,
 	return err;
 }
 
+static int fou_flow_dissect(struct sock *sk, const struct sk_buff *skb,
+			    void *data, int hlen, int *nhoff, u8 *ip_proto,
+			    __be16 *proto)
+{
+	*ip_proto = fou_from_sock(sk)->protocol;
+	*nhoff += sizeof(struct udphdr);
+
+	return FLOW_DIS_RET_IPPROTO;
+}
+
 static struct guehdr *gue_gro_remcsum(struct sk_buff *skb, unsigned int off,
 				      struct guehdr *guehdr, void *data,
 				      size_t hdrlen, struct gro_remcsum *grc,
@@ -498,6 +509,48 @@ static int gue_gro_complete(struct sock *sk, struct sk_buff *skb, int nhoff)
 	return err;
 }
 
+static int gue_flow_dissect(struct sock *sk, const struct sk_buff *skb,
+			    void *data, int hlen, int *nhoff, u8 *ip_proto,
+			    __be16 *proto)
+{
+	struct guehdr _hdr, *hdr;
+
+	hdr = __skb_header_pointer(skb, *nhoff + sizeof(struct udphdr),
+				   sizeof(_hdr), data, hlen, &_hdr);
+	if (!hdr)
+		return FLOW_DIS_RET_BAD;
+
+	switch (hdr->version) {
+	case 0: /* Full GUE header present */
+		if (hdr->control)
+			return FLOW_DIS_RET_PASS;
+
+		*nhoff += sizeof(struct udphdr) + sizeof(_hdr) +
+			  (hdr->hlen << 2);
+		*ip_proto = hdr->proto_ctype;
+
+		return FLOW_DIS_RET_IPPROTO;
+	case 1:
+		/* Direct encasulation of IPv4 or IPv6 */
+
+		switch (((struct iphdr *)hdr)->version) {
+		case 4:
+			*nhoff += sizeof(struct udphdr);
+			*ip_proto = IPPROTO_IPIP;
+			return FLOW_DIS_RET_IPPROTO;
+		case 6:
+			*nhoff += sizeof(struct udphdr);
+			*ip_proto = IPPROTO_IPV6;
+			return FLOW_DIS_RET_IPPROTO;
+		default:
+			return FLOW_DIS_RET_PASS;
+		}
+
+	default:
+		return FLOW_DIS_RET_PASS;
+	}
+}
+
 static int fou_add_to_port_list(struct net *net, struct fou *fou)
 {
 	struct fou_net *fn = net_generic(net, fou_net_id);
@@ -568,12 +621,16 @@ static int fou_create(struct net *net, struct fou_cfg *cfg,
 		tunnel_cfg.encap_rcv = fou_udp_recv;
 		tunnel_cfg.gro_receive = fou_gro_receive;
 		tunnel_cfg.gro_complete = fou_gro_complete;
+		if (cfg->flags & FOU_F_DEEP_HASH)
+			tunnel_cfg.flow_dissect = fou_flow_dissect;
 		fou->protocol = cfg->protocol;
 		break;
 	case FOU_ENCAP_GUE:
 		tunnel_cfg.encap_rcv = gue_udp_recv;
 		tunnel_cfg.gro_receive = gue_gro_receive;
 		tunnel_cfg.gro_complete = gue_gro_complete;
+		if (cfg->flags & FOU_F_DEEP_HASH)
+			tunnel_cfg.flow_dissect = gue_flow_dissect;
 		break;
 	default:
 		err = -EINVAL;
@@ -637,6 +694,7 @@ static const struct nla_policy fou_nl_policy[FOU_ATTR_MAX + 1] = {
 	[FOU_ATTR_IPPROTO] = { .type = NLA_U8, },
 	[FOU_ATTR_TYPE] = { .type = NLA_U8, },
 	[FOU_ATTR_REMCSUM_NOPARTIAL] = { .type = NLA_FLAG, },
+	[FOU_ATTR_DEEP_HASH] = { .type = NLA_FLAG },
 };
 
 static int parse_nl_config(struct genl_info *info,
@@ -677,6 +735,9 @@ static int parse_nl_config(struct genl_info *info,
 	if (info->attrs[FOU_ATTR_REMCSUM_NOPARTIAL])
 		cfg->flags |= FOU_F_REMCSUM_NOPARTIAL;
 
+	if (info->attrs[FOU_ATTR_DEEP_HASH])
+		cfg->flags |= FOU_F_DEEP_HASH;
+
 	return 0;
 }
 
@@ -717,6 +778,11 @@ static int fou_fill_info(struct fou *fou, struct sk_buff *msg)
 	if (fou->flags & FOU_F_REMCSUM_NOPARTIAL)
 		if (nla_put_flag(msg, FOU_ATTR_REMCSUM_NOPARTIAL))
 			return -1;
+
+	if (fou->flags & FOU_F_DEEP_HASH)
+		if (nla_put_flag(msg, FOU_ATTR_DEEP_HASH))
+			return -1;
+
 	return 0;
 }
 
-- 
2.9.3
