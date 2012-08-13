From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH 2/4] packet: Report more packet sk info via diag module
Date: Mon, 13 Aug 2012 19:55:46 +0400
Message-ID: <50292382.9070304@parallels.com>
References: <5029219C.20305@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:20223 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751431Ab2HMPzv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Aug 2012 11:55:51 -0400
In-Reply-To: <5029219C.20305@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This reports in one rtattr message all the other scalar values, that can be
set on a packet socket with setsockopt.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

---
 include/linux/packet_diag.h |   23 +++++++++++++++++++++++
 net/packet/diag.c           |   33 +++++++++++++++++++++++++++++++++
 2 files changed, 56 insertions(+), 0 deletions(-)

diff --git a/include/linux/packet_diag.h b/include/linux/packet_diag.h
index fa19300..3781ea4 100644
--- a/include/linux/packet_diag.h
+++ b/include/linux/packet_diag.h
@@ -12,6 +12,8 @@ struct packet_diag_req {
 	__u32	pdiag_cookie[2];
 };
 
+#define PACKET_SHOW_INFO	0x00000001 /* Basic packet_sk information */
+
 struct packet_diag_msg {
 	__u8	pdiag_family;
 	__u8	pdiag_type;
@@ -21,4 +23,25 @@ struct packet_diag_msg {
 	__u32	pdiag_cookie[2];
 };
 
+enum {
+	PACKET_DIAG_INFO,
+
+	PACKET_DIAG_MAX,
+};
+
+struct packet_diag_info {
+	__u32	pdi_index;
+	__u32	pdi_version;
+	__u32	pdi_reserve;
+	__u32	pdi_copy_thresh;
+	__u32	pdi_tstamp;
+	__u32	pdi_flags;
+
+#define PDI_RUNNING	0x1
+#define PDI_AUXDATA	0x2
+#define PDI_ORIGDEV	0x4
+#define PDI_VNETHDR	0x8
+#define PDI_LOSS	0x10
+};
+
 #endif
diff --git a/net/packet/diag.c b/net/packet/diag.c
index ff2f7f5..d5bd037 100644
--- a/net/packet/diag.c
+++ b/net/packet/diag.c
@@ -7,6 +7,31 @@
 
 #include "internal.h"
 
+static int pdiag_put_info(const struct packet_sock *po, struct sk_buff *nlskb)
+{
+	struct packet_diag_info pinfo;
+
+	pinfo.pdi_index = po->ifindex;
+	pinfo.pdi_version = po->tp_version;
+	pinfo.pdi_reserve = po->tp_reserve;
+	pinfo.pdi_copy_thresh = po->copy_thresh;
+	pinfo.pdi_tstamp = po->tp_tstamp;
+
+	pinfo.pdi_flags = 0;
+	if (po->running)
+		pinfo.pdi_flags |= PDI_RUNNING;
+	if (po->auxdata)
+		pinfo.pdi_flags |= PDI_AUXDATA;
+	if (po->origdev)
+		pinfo.pdi_flags |= PDI_ORIGDEV;
+	if (po->has_vnet_hdr)
+		pinfo.pdi_flags |= PDI_VNETHDR;
+	if (po->tp_loss)
+		pinfo.pdi_flags |= PDI_LOSS;
+
+	return nla_put(nlskb, PACKET_DIAG_INFO, sizeof(pinfo), &pinfo);
+}
+
 static int sk_diag_fill(struct sock *sk, struct sk_buff *skb, struct packet_diag_req *req,
 		u32 pid, u32 seq, u32 flags, int sk_ino)
 {
@@ -25,7 +50,15 @@ static int sk_diag_fill(struct sock *sk, struct sk_buff *skb, struct packet_diag
 	rp->pdiag_ino = sk_ino;
 	sock_diag_save_cookie(sk, rp->pdiag_cookie);
 
+	if ((req->pdiag_show & PACKET_SHOW_INFO) &&
+			pdiag_put_info(po, skb))
+		goto out_nlmsg_trim;
+
 	return nlmsg_end(skb, nlh);
+
+out_nlmsg_trim:
+	nlmsg_cancel(skb, nlh);
+	return -EMSGSIZE;
 }
 
 static int packet_diag_dump(struct sk_buff *skb, struct netlink_callback *cb)
-- 
1.7.6.5
