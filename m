From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH 8/13] unix_diag: Unix socket name NLA
Date: Thu, 15 Dec 2011 16:45:24 +0400
Message-ID: <4EE9EBE4.70303@parallels.com>
References: <4EE9EB2A.4040909@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:11862 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758441Ab1LOMp3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Dec 2011 07:45:29 -0500
In-Reply-To: <4EE9EB2A.4040909@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Report the sun_path when requested as NLA. With leading '\0' if
present but without the leading AF_UNIX bits.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

---
 include/linux/unix_diag.h |    8 ++++++++
 net/unix/diag.c           |   20 ++++++++++++++++++++
 2 files changed, 28 insertions(+), 0 deletions(-)

diff --git a/include/linux/unix_diag.h b/include/linux/unix_diag.h
index 445184a..cc4df34 100644
--- a/include/linux/unix_diag.h
+++ b/include/linux/unix_diag.h
@@ -11,6 +11,8 @@ struct unix_diag_req {
 	__u32	udiag_cookie[2];
 };
 
+#define UDIAG_SHOW_NAME		0x00000001	/* show name (not path) */
+
 struct unix_diag_msg {
 	__u8	udiag_family;
 	__u8	udiag_type;
@@ -21,4 +23,10 @@ struct unix_diag_msg {
 	__u32	udiag_cookie[2];
 };
 
+enum {
+	UNIX_DIAG_NAME,
+
+	UNIX_DIAG_MAX,
+};
+
 #endif
diff --git a/net/unix/diag.c b/net/unix/diag.c
index d7bd48c..161ce6c 100644
--- a/net/unix/diag.c
+++ b/net/unix/diag.c
@@ -10,6 +10,22 @@
 #define UNIX_DIAG_PUT(skb, attrtype, attrlen) \
 	RTA_DATA(__RTA_PUT(skb, attrtype, attrlen))
 
+static int sk_diag_dump_name(struct sock *sk, struct sk_buff *nlskb)
+{
+	struct unix_address *addr = unix_sk(sk)->addr;
+	char *s;
+
+	if (addr) {
+		s = UNIX_DIAG_PUT(nlskb, UNIX_DIAG_NAME, addr->len - sizeof(short));
+		memcpy(s, addr->name->sun_path, addr->len - sizeof(short));
+	}
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
@@ -28,6 +44,10 @@ static int sk_diag_fill(struct sock *sk, struct sk_buff *skb, struct unix_diag_r
 	rep->udiag_ino = sk_ino;
 	sock_diag_save_cookie(sk, rep->udiag_cookie);
 
+	if ((req->udiag_show & UDIAG_SHOW_NAME) &&
+			sk_diag_dump_name(sk, skb))
+		goto nlmsg_failure;
+
 	nlh->nlmsg_len = skb_tail_pointer(skb) - b;
 	return skb->len;
 
-- 
1.5.5.6
