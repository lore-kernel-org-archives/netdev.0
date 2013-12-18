From: valentina.giusti@bmw-carit.de
Subject: [PATCH 2/2] libnetfilter_queue: add support for UID/GID socket info
Date: Wed, 18 Dec 2013 19:04:04 +0100
Message-ID: <1387389844-5263-3-git-send-email-valentina.giusti@bmw-carit.de>
References: <1387389844-5263-1-git-send-email-valentina.giusti@bmw-carit.de>
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com, tgraf@redhat.com,
	jpa@google.com, pablo@netfilter.org, davem@davemloft.net,
	daniel.wagner@bmw-carit.de,
	Valentina Giusti <Valentina.Giusti@bmw-carit.de>
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1387389844-5263-1-git-send-email-valentina.giusti@bmw-carit.de>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Valentina Giusti <Valentina.Giusti@bmw-carit.de>

With this patch libnetfilter_queue is able to parse the UID/GID socket
information from nfnetlink_queue.

Signed-off-by: Valentina Giusti <Valentina.Giusti@bmw-carit.de>
---
 include/libnetfilter_queue/libnetfilter_queue.h    |  4 ++++
 include/libnetfilter_queue/linux_nfnetlink_queue.h |  2 ++
 include/linux/netfilter/nfnetlink_queue.h          |  3 +++
 src/libnetfilter_queue.c                           | 25 ++++++++++++++++++++++
 src/nlmsg.c                                        |  2 ++
 5 files changed, 36 insertions(+)

diff --git a/include/libnetfilter_queue/libnetfilter_queue.h b/include/libnetfilter_queue/libnetfilter_queue.h
index b9f16e2..b4e2679 100644
--- a/include/libnetfilter_queue/libnetfilter_queue.h
+++ b/include/libnetfilter_queue/libnetfilter_queue.h
@@ -103,6 +103,8 @@ extern u_int32_t nfq_get_indev(struct nfq_data *nfad);
 extern u_int32_t nfq_get_physindev(struct nfq_data *nfad);
 extern u_int32_t nfq_get_outdev(struct nfq_data *nfad);
 extern u_int32_t nfq_get_physoutdev(struct nfq_data *nfad);
+extern u_int32_t nfq_get_uid(struct nfq_data *nfad);
+extern u_int32_t nfq_get_gid(struct nfq_data *nfad);
 
 extern int nfq_get_indev_name(struct nlif_handle *nlif_handle,
 			      struct nfq_data *nfad, char *name);
@@ -125,6 +127,8 @@ enum {
 	NFQ_XML_PHYSDEV	= (1 << 3),
 	NFQ_XML_PAYLOAD	= (1 << 4),
 	NFQ_XML_TIME	= (1 << 5),
+	NFQ_XML_UID	= (1 << 6),
+	NFQ_XML_GID	= (1 << 7),
 	NFQ_XML_ALL	= ~0U,
 };
 
diff --git a/include/libnetfilter_queue/linux_nfnetlink_queue.h b/include/libnetfilter_queue/linux_nfnetlink_queue.h
index 81a485b..88fd0c0 100644
--- a/include/libnetfilter_queue/linux_nfnetlink_queue.h
+++ b/include/libnetfilter_queue/linux_nfnetlink_queue.h
@@ -50,6 +50,8 @@ enum nfqnl_attr_type {
 	NFQA_CAP_LEN,                   /* __u32 length of captured packet */
 	NFQA_SKB_INFO,                  /* __u32 skb meta information */
 
+	NFQA_UID,			/* __u32 sk uid */
+	NFQA_GID,			/* __u32 sk gid */
 	__NFQA_MAX
 };
 #define NFQA_MAX (__NFQA_MAX - 1)
diff --git a/include/linux/netfilter/nfnetlink_queue.h b/include/linux/netfilter/nfnetlink_queue.h
index a2308ae..dfbd1ad 100644
--- a/include/linux/netfilter/nfnetlink_queue.h
+++ b/include/linux/netfilter/nfnetlink_queue.h
@@ -46,6 +46,9 @@ enum nfqnl_attr_type {
 	NFQA_CT_INFO,			/* enum ip_conntrack_info */
 	NFQA_CAP_LEN,			/* __u32 length of captured packet */
 	NFQA_SKB_INFO,			/* __u32 skb meta information */
+	NFQA_EXP,			/* nf_conntrack_netlink.h */
+	NFQA_UID,			/* __u32 sk uid */
+	NFQA_GID,			/* __u32 sk gid */
 
 	__NFQA_MAX
 };
diff --git a/src/libnetfilter_queue.c b/src/libnetfilter_queue.c
index fa8efe7..52456db 100644
--- a/src/libnetfilter_queue.c
+++ b/src/libnetfilter_queue.c
@@ -1180,6 +1180,18 @@ struct nfqnl_msg_packet_hw *nfq_get_packet_hw(struct nfq_data *nfad)
 }
 EXPORT_SYMBOL(nfq_get_packet_hw);
 
+uint32_t nfq_get_uid(struct nfq_data *nfad)
+{
+	return ntohl(nfnl_get_data(nfad->data, NFQA_UID, u_int32_t));
+}
+EXPORT_SYMBOL(nfq_get_uid);
+
+uint32_t nfq_get_gid(struct nfq_data *nfad)
+{
+	return ntohl(nfnl_get_data(nfad->data, NFQA_GID, u_int32_t));
+}
+EXPORT_SYMBOL(nfq_get_gid);
+
 /**
  * nfq_get_payload - get payload 
  * \param nfad Netlink packet data handle passed to callback function
@@ -1250,6 +1262,7 @@ int nfq_snprintf_xml(char *buf, size_t rem, struct nfq_data *tb, int flags)
 	struct nfqnl_msg_packet_hdr *ph;
 	struct nfqnl_msg_packet_hw *hwph;
 	u_int32_t mark, ifi;
+	u_int32_t uid, gid;
 	int size, offset = 0, len = 0, ret;
 	unsigned char *data;
 
@@ -1365,6 +1378,18 @@ int nfq_snprintf_xml(char *buf, size_t rem, struct nfq_data *tb, int flags)
 		SNPRINTF_FAILURE(size, rem, offset, len);
 	}
 
+	uid = nfq_get_uid(tb);
+	if (uid && (flags & NFQ_XML_UID)) {
+		size = snprintf(buf + offset, rem, "<uid>%u</uid>", uid);
+		SNPRINTF_FAILURE(size, rem, offset, len);
+	}
+
+	gid = nfq_get_gid(tb);
+	if (gid && (flags & NFQ_XML_GID)) {
+		size = snprintf(buf + offset, rem, "<gid>%u</gid>", gid);
+		SNPRINTF_FAILURE(size, rem, offset, len);
+	}
+
 	ret = nfq_get_payload(tb, &data);
 	if (ret >= 0 && (flags & NFQ_XML_PAYLOAD)) {
 		int i;
diff --git a/src/nlmsg.c b/src/nlmsg.c
index e7a30e0..81e170e 100644
--- a/src/nlmsg.c
+++ b/src/nlmsg.c
@@ -134,6 +134,8 @@ static int nfq_pkt_parse_attr_cb(const struct nlattr *attr, void *data)
 	case NFQA_IFINDEX_PHYSOUTDEV:
 	case NFQA_CAP_LEN:
 	case NFQA_SKB_INFO:
+	case NFQA_UID:
+	case NFQA_GID:
 		if (mnl_attr_validate(attr, MNL_TYPE_U32) < 0)
 			return MNL_CB_ERROR;
 		break;
-- 
1.8.5.1

