From: Andreas Schultz <aschultz@tpip.net>
Subject: [PATCH 16/17] gtp: add genl cmd to enable GTP encapsulation on UDP socket
Date: Mon, 23 Jan 2017 12:57:05 +0100
Message-ID: <20170123115706.4354-17-aschultz@tpip.net>
References: <20170123115706.4354-1-aschultz@tpip.net>
Cc: netdev@vger.kernel.org, Harald Welte <laforge@gnumonks.org>,
        Lionel Gauthier <Lionel.Gauthier@eurecom.fr>,
        openbsc@lists.osmocom.org
To: Pablo Neira <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.tpip.net ([92.43.49.48]:33797 "EHLO mail.tpip.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750872AbdAWMGy (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 23 Jan 2017 07:06:54 -0500
In-Reply-To: <20170123115706.4354-1-aschultz@tpip.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Andreas Schultz <aschultz@tpip.net>
---
 drivers/net/gtp.c        | 48 ++++++++++++++++++++++++++++++++++++++++++++++++
 include/uapi/linux/gtp.h |  4 ++++
 2 files changed, 52 insertions(+)

diff --git a/drivers/net/gtp.c b/drivers/net/gtp.c
index 55bf098..157cf40 100644
--- a/drivers/net/gtp.c
+++ b/drivers/net/gtp.c
@@ -1240,6 +1240,46 @@ static int gtp_genl_dump_pdp(struct sk_buff *skb,
 	return skb->len;
 }
 
+static int gtp_genl_enable_socket(struct sk_buff *skb, struct genl_info *info)
+{
+	u32 version, fd, hashsize;
+	struct socket *sock;
+
+	if (!info->attrs[GTPA_VERSION] ||
+	    !info->attrs[GTPA_FD])
+		return -EINVAL;
+
+	if (!info->attrs[GTPA_PDP_HASHSIZE])
+		hashsize = 1024;
+	else
+		hashsize = nla_get_u32(info->attrs[IFLA_GTP_PDP_HASHSIZE]);
+
+	version = nla_get_u32(info->attrs[GTPA_VERSION]);
+	fd = nla_get_u32(info->attrs[GTPA_FD]);
+
+	switch (version) {
+	case GTP_V0:
+		sock = gtp_encap_enable_socket(fd, UDP_ENCAP_GTP0, hashsize);
+		break;
+
+	case GTP_V1:
+		sock = gtp_encap_enable_socket(fd, UDP_ENCAP_GTP1U, hashsize);
+		break;
+
+	default:
+		return -EINVAL;
+	}
+
+	if (!sock)
+		return -EINVAL;
+
+	if (IS_ERR(sock))
+		return PTR_ERR(sock);
+
+	sockfd_put(sock);
+	return 0;
+}
+
 static struct nla_policy gtp_genl_policy[GTPA_MAX + 1] = {
 	[GTPA_LINK]		= { .type = NLA_U32, },
 	[GTPA_VERSION]		= { .type = NLA_U32, },
@@ -1250,6 +1290,8 @@ static struct nla_policy gtp_genl_policy[GTPA_MAX + 1] = {
 	[GTPA_NET_NS_FD]	= { .type = NLA_U32, },
 	[GTPA_I_TEI]		= { .type = NLA_U32, },
 	[GTPA_O_TEI]		= { .type = NLA_U32, },
+	[GTPA_PDP_HASHSIZE]	= { .type = NLA_U32, },
+	[GTPA_FD]		= { .type = NLA_U32, },
 };
 
 static const struct genl_ops gtp_genl_ops[] = {
@@ -1272,6 +1314,12 @@ static const struct genl_ops gtp_genl_ops[] = {
 		.policy = gtp_genl_policy,
 		.flags = GENL_ADMIN_PERM,
 	},
+	{
+		.cmd = GTP_CMD_ENABLE_SOCKET,
+		.doit = gtp_genl_enable_socket,
+		.policy = gtp_genl_policy,
+		.flags = GENL_ADMIN_PERM,
+	},
 };
 
 static struct genl_family gtp_genl_family __ro_after_init = {
diff --git a/include/uapi/linux/gtp.h b/include/uapi/linux/gtp.h
index 72a04a0..a9e9fe0 100644
--- a/include/uapi/linux/gtp.h
+++ b/include/uapi/linux/gtp.h
@@ -6,6 +6,8 @@ enum gtp_genl_cmds {
 	GTP_CMD_DELPDP,
 	GTP_CMD_GETPDP,
 
+	GTP_CMD_ENABLE_SOCKET,
+
 	GTP_CMD_MAX,
 };
 
@@ -26,6 +28,8 @@ enum gtp_attrs {
 	GTPA_I_TEI,	/* for GTPv1 only */
 	GTPA_O_TEI,	/* for GTPv1 only */
 	GTPA_PAD,
+	GTPA_PDP_HASHSIZE,
+	GTPA_FD,
 	__GTPA_MAX,
 };
 #define GTPA_MAX (__GTPA_MAX + 1)
-- 
2.10.2
