From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH 4/5] unix_diag: Report memory usage info
Date: Wed, 28 Dec 2011 17:39:26 +0400
Message-ID: <4EFB1C0E.4060004@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:48267 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753770Ab1L1Njc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Dec 2011 08:39:32 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Symmetrical to inet sockets, but unix only have two meaningful
values -- the wmem allocation and sndbuf.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

---
 include/linux/unix_diag.h |    7 +++++++
 net/unix/diag.c           |   18 ++++++++++++++++++
 2 files changed, 25 insertions(+), 0 deletions(-)

diff --git a/include/linux/unix_diag.h b/include/linux/unix_diag.h
index 3f7afb0..d62e562 100644
--- a/include/linux/unix_diag.h
+++ b/include/linux/unix_diag.h
@@ -16,6 +16,7 @@ struct unix_diag_req {
 #define UDIAG_SHOW_PEER		0x00000004	/* show peer socket info */
 #define UDIAG_SHOW_ICONS	0x00000008	/* show pending connections */
 #define UDIAG_SHOW_RQLEN	0x00000010	/* show skb receive queue len */
+#define UDIAG_SHOW_MEMINFO	0x00000020
 
 struct unix_diag_msg {
 	__u8	udiag_family;
@@ -33,6 +34,7 @@ enum {
 	UNIX_DIAG_PEER,
 	UNIX_DIAG_ICONS,
 	UNIX_DIAG_RQLEN,
+	UNIX_DIAG_MEMINFO,
 
 	UNIX_DIAG_MAX,
 };
@@ -42,4 +44,9 @@ struct unix_diag_vfs {
 	__u32	udiag_vfs_dev;
 };
 
+struct unix_diag_meminfo {
+	__u32	udiag_len;
+	__u32	udiag_limit;
+};
+
 #endif
diff --git a/net/unix/diag.c b/net/unix/diag.c
index c5bdbcb..dbae8a4 100644
--- a/net/unix/diag.c
+++ b/net/unix/diag.c
@@ -108,6 +108,20 @@ rtattr_failure:
 	return -EMSGSIZE;
 }
 
+static int sk_diag_show_meminfo(struct sock *sk, struct sk_buff *nlskb)
+{
+	struct unix_diag_meminfo *mi;
+
+	mi = UNIX_DIAG_PUT(nlskb, UNIX_DIAG_MEMINFO, sizeof(*mi));
+	mi->udiag_len = sk_wmem_alloc_get(sk);
+	mi->udiag_limit = sk->sk_sndbuf;
+
+	return 0;
+
+rtattr_failure:
+	return -EMSGSIZE;
+}
+
 static int sk_diag_fill(struct sock *sk, struct sk_buff *skb, struct unix_diag_req *req,
 		u32 pid, u32 seq, u32 flags, int sk_ino)
 {
@@ -146,6 +160,10 @@ static int sk_diag_fill(struct sock *sk, struct sk_buff *skb, struct unix_diag_r
 			sk_diag_show_rqlen(sk, skb))
 		goto nlmsg_failure;
 
+	if ((req->udiag_show & UDIAG_SHOW_MEMINFO) &&
+			sk_diag_show_meminfo(sk, skb))
+		goto nlmsg_failure;
+
 	nlh->nlmsg_len = skb_tail_pointer(skb) - b;
 	return skb->len;
 
-- 
1.5.5.6
