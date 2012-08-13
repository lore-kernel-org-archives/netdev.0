From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH 4/4] packet: Report socket mclist info via diag module
Date: Mon, 13 Aug 2012 19:57:44 +0400
Message-ID: <502923F8.9080301@parallels.com>
References: <5029219C.20305@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:44129 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751431Ab2HMP5u (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Aug 2012 11:57:50 -0400
In-Reply-To: <5029219C.20305@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The info is reported as an array of packet_diag_mclist structures. Each
includes not only the directly configured values (index, type, etc), but
also the "count".

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

---
 include/linux/packet_diag.h |   10 ++++++++++
 net/packet/diag.c           |   39 +++++++++++++++++++++++++++++++++++++++
 2 files changed, 49 insertions(+), 0 deletions(-)

diff --git a/include/linux/packet_diag.h b/include/linux/packet_diag.h
index 3781ea4..ea2e8923 100644
--- a/include/linux/packet_diag.h
+++ b/include/linux/packet_diag.h
@@ -13,6 +13,7 @@ struct packet_diag_req {
 };
 
 #define PACKET_SHOW_INFO	0x00000001 /* Basic packet_sk information */
+#define PACKET_SHOW_MCLIST	0x00000002 /* A set of packet_diag_mclist-s */
 
 struct packet_diag_msg {
 	__u8	pdiag_family;
@@ -25,6 +26,7 @@ struct packet_diag_msg {
 
 enum {
 	PACKET_DIAG_INFO,
+	PACKET_DIAG_MCLIST,
 
 	PACKET_DIAG_MAX,
 };
@@ -44,4 +46,12 @@ struct packet_diag_info {
 #define PDI_LOSS	0x10
 };
 
+struct packet_diag_mclist {
+	__u32	pdmc_index;
+	__u32	pdmc_count;
+	__u16	pdmc_type;
+	__u16	pdmc_alen;
+	__u8	pdmc_addr[MAX_ADDR_LEN];
+};
+
 #endif
diff --git a/net/packet/diag.c b/net/packet/diag.c
index d5bd037..3dda4ec 100644
--- a/net/packet/diag.c
+++ b/net/packet/diag.c
@@ -1,6 +1,7 @@
 #include <linux/module.h>
 #include <linux/sock_diag.h>
 #include <linux/net.h>
+#include <linux/netdevice.h>
 #include <linux/packet_diag.h>
 #include <net/net_namespace.h>
 #include <net/sock.h>
@@ -32,6 +33,40 @@ static int pdiag_put_info(const struct packet_sock *po, struct sk_buff *nlskb)
 	return nla_put(nlskb, PACKET_DIAG_INFO, sizeof(pinfo), &pinfo);
 }
 
+static int pdiag_put_mclist(const struct packet_sock *po, struct sk_buff *nlskb)
+{
+	struct nlattr *mca;
+	struct packet_mclist *ml;
+
+	mca = nla_nest_start(nlskb, PACKET_DIAG_MCLIST);
+	if (!mca)
+		return -EMSGSIZE;
+
+	rtnl_lock();
+	for (ml = po->mclist; ml; ml = ml->next) {
+		struct packet_diag_mclist *dml;
+
+		dml = nla_reserve_nohdr(nlskb, sizeof(*dml));
+		if (!dml) {
+			rtnl_unlock();
+			nla_nest_cancel(nlskb, mca);
+			return -EMSGSIZE;
+		}
+
+		dml->pdmc_index = ml->ifindex;
+		dml->pdmc_type = ml->type;
+		dml->pdmc_alen = ml->alen;
+		dml->pdmc_count = ml->count;
+		BUILD_BUG_ON(sizeof(dml->pdmc_addr) != sizeof(ml->addr));
+		memcpy(dml->pdmc_addr, ml->addr, sizeof(ml->addr));
+	}
+
+	rtnl_unlock();
+	nla_nest_end(nlskb, mca);
+
+	return 0;
+}
+
 static int sk_diag_fill(struct sock *sk, struct sk_buff *skb, struct packet_diag_req *req,
 		u32 pid, u32 seq, u32 flags, int sk_ino)
 {
@@ -54,6 +89,10 @@ static int sk_diag_fill(struct sock *sk, struct sk_buff *skb, struct packet_diag
 			pdiag_put_info(po, skb))
 		goto out_nlmsg_trim;
 
+	if ((req->pdiag_show & PACKET_SHOW_MCLIST) &&
+			pdiag_put_mclist(po, skb))
+		goto out_nlmsg_trim;
+
 	return nlmsg_end(skb, nlh);
 
 out_nlmsg_trim:
-- 
1.7.6.5
