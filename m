From: valentina.giusti@bmw-carit.de
Subject: [PATCH 1/2] src: add support for UID/GID socket info
Date: Tue,  7 Jan 2014 14:30:19 +0100
Message-ID: <1389101420-16557-2-git-send-email-valentina.giusti@bmw-carit.de>
References: <20131221113804.GA17964@localhost>
 <1389101420-16557-1-git-send-email-valentina.giusti@bmw-carit.de>
Cc: netdev@vger.kernel.org, fw@strlen.de, daniel.wagner@bmw-carit.de
To: pablo@netfilter.org, netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1389101420-16557-1-git-send-email-valentina.giusti@bmw-carit.de>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Valentina Giusti <Valentina.Giusti@bmw-carit.de>

With this patch libnetfilter_queue is able to parse UID/GID
socket information.

Signed-off-by: Valentina Giusti <Valentina.Giusti@bmw-carit.de>
---
 include/libnetfilter_queue/libnetfilter_queue.h    |  4 ++
 include/libnetfilter_queue/linux_nfnetlink_queue.h |  6 ++-
 include/linux/netfilter/nfnetlink_queue.h          |  6 ++-
 src/libnetfilter_queue.c                           | 46 ++++++++++++++++++++++
 src/nlmsg.c                                        |  2 +
 5 files changed, 62 insertions(+), 2 deletions(-)

diff --git a/include/libnetfilter_queue/libnetfilter_queue.h b/include/libnetfilter_queue/libnetfilter_queue.h
index b9f16e2..122cd10 100644
--- a/include/libnetfilter_queue/libnetfilter_queue.h
+++ b/include/libnetfilter_queue/libnetfilter_queue.h
@@ -103,6 +103,8 @@ extern u_int32_t nfq_get_indev(struct nfq_data *nfad);
 extern u_int32_t nfq_get_physindev(struct nfq_data *nfad);
 extern u_int32_t nfq_get_outdev(struct nfq_data *nfad);
 extern u_int32_t nfq_get_physoutdev(struct nfq_data *nfad);
+extern int nfq_get_uid(struct nfq_data *nfad, u_int32_t *uid);
+extern int nfq_get_gid(struct nfq_data *nfad, u_int32_t *gid);
 
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
index 81a485b..f732201 100644
--- a/include/libnetfilter_queue/linux_nfnetlink_queue.h
+++ b/include/libnetfilter_queue/linux_nfnetlink_queue.h
@@ -49,6 +49,9 @@ enum nfqnl_attr_type {
 	NFQA_CT_INFO,			/* enum ip_conntrack_info */
 	NFQA_CAP_LEN,                   /* __u32 length of captured packet */
 	NFQA_SKB_INFO,                  /* __u32 skb meta information */
+	NFQA_EXP,			/* nf_conntrack_netlink.h */
+	NFQA_UID,			/* __u32 sk uid */
+	NFQA_GID,			/* __u32 sk gid */
 
 	__NFQA_MAX
 };
@@ -101,7 +104,8 @@ enum nfqnl_attr_config {
 #define NFQA_CFG_F_FAIL_OPEN		(1 << 0)
 #define NFQA_CFG_F_CONNTRACK		(1 << 1)
 #define NFQA_CFG_F_GSO			(1 << 2)
-#define NFQA_CFG_F_MAX			(1 << 3)
+#define NFQA_CFG_F_UID_GID		(1 << 3)
+#define NFQA_CFG_F_MAX			(1 << 4)
 
 /* flags for NFQA_SKB_INFO */
 /* packet appears to have wrong checksums, but they are ok */
diff --git a/include/linux/netfilter/nfnetlink_queue.h b/include/linux/netfilter/nfnetlink_queue.h
index a2308ae..22f5d45 100644
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
@@ -98,7 +101,8 @@ enum nfqnl_attr_config {
 #define NFQA_CFG_F_FAIL_OPEN			(1 << 0)
 #define NFQA_CFG_F_CONNTRACK			(1 << 1)
 #define NFQA_CFG_F_GSO				(1 << 2)
-#define NFQA_CFG_F_MAX				(1 << 3)
+#define NFQA_CFG_F_UID_GID			(1 << 3)
+#define NFQA_CFG_F_MAX				(1 << 4)
 
 /* flags for NFQA_SKB_INFO */
 /* packet appears to have wrong checksums, but they are ok */
diff --git a/src/libnetfilter_queue.c b/src/libnetfilter_queue.c
index fa8efe7..32725d1 100644
--- a/src/libnetfilter_queue.c
+++ b/src/libnetfilter_queue.c
@@ -668,6 +668,9 @@ EXPORT_SYMBOL(nfq_set_mode);
  *  if this bit is set, the layer 3/4 checksums of the packet appear incorrect,
  *  but are not (because they will be corrected later by the kernel).
  *
+ *  - NFQA_CFG_F_UID_GID: the kernel will dump UID and GID of the socket to
+ *  which each packet belongs.
+ *
  * Here's a little code snippet to show how to use this API:
  * \verbatim
 	uint32_t flags = NFQA_CFG_F_FAIL_OPEN;
@@ -1181,6 +1184,38 @@ struct nfqnl_msg_packet_hw *nfq_get_packet_hw(struct nfq_data *nfad)
 EXPORT_SYMBOL(nfq_get_packet_hw);
 
 /**
+ * nfq_get_uid - get the UID of the user the packet belongs to
+ * \param nfad Netlink packet data handle passed to callback function
+ *
+ * \return 1 if there is a UID available, 0 otherwise.
+ */
+int nfq_get_uid(struct nfq_data *nfad, u_int32_t *uid)
+{
+	if (!nfnl_attr_present(nfad->data, NFQA_UID))
+		return 0;
+
+	*uid = ntohl(nfnl_get_data(nfad->data, NFQA_UID, u_int32_t));
+	return 1;
+}
+EXPORT_SYMBOL(nfq_get_uid);
+
+/**
+ * nfq_get_gid - get the GID of the user the packet belongs to
+ * \param nfad Netlink packet data handle passed to callback function
+ *
+ * \return 1 if there is a GID available, 0 otherwise.
+ */
+int nfq_get_gid(struct nfq_data *nfad, u_int32_t *gid)
+{
+	if (!nfnl_attr_present(nfad->data, NFQA_GID))
+		return 0;
+
+	*gid = ntohl(nfnl_get_data(nfad->data, NFQA_GID, u_int32_t));
+	return 1;
+}
+EXPORT_SYMBOL(nfq_get_gid);
+
+/**
  * nfq_get_payload - get payload 
  * \param nfad Netlink packet data handle passed to callback function
  * \param data Pointer of pointer that will be pointed to the payload
@@ -1250,6 +1285,7 @@ int nfq_snprintf_xml(char *buf, size_t rem, struct nfq_data *tb, int flags)
 	struct nfqnl_msg_packet_hdr *ph;
 	struct nfqnl_msg_packet_hw *hwph;
 	u_int32_t mark, ifi;
+	u_int32_t uid, gid;
 	int size, offset = 0, len = 0, ret;
 	unsigned char *data;
 
@@ -1365,6 +1401,16 @@ int nfq_snprintf_xml(char *buf, size_t rem, struct nfq_data *tb, int flags)
 		SNPRINTF_FAILURE(size, rem, offset, len);
 	}
 
+	if (nfq_get_uid(tb, &uid) && (flags & NFQ_XML_UID)) {
+		size = snprintf(buf + offset, rem, "<uid>%u</uid>", uid);
+		SNPRINTF_FAILURE(size, rem, offset, len);
+	}
+
+	if (nfq_get_gid(tb, &gid) && (flags & NFQ_XML_GID)) {
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

