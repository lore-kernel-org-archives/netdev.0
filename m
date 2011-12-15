From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH 12/13] unix_diag: Receive queue lenght NLA
Date: Thu, 15 Dec 2011 16:46:31 +0400
Message-ID: <4EE9EC27.9080107@parallels.com>
References: <4EE9EB2A.4040909@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:43707 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756011Ab1LOMqh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Dec 2011 07:46:37 -0500
In-Reply-To: <4EE9EB2A.4040909@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

---
 include/linux/unix_diag.h |    2 ++
 net/unix/diag.c           |   13 +++++++++++++
 2 files changed, 15 insertions(+), 0 deletions(-)

diff --git a/include/linux/unix_diag.h b/include/linux/unix_diag.h
index 03ffb7d..3f7afb0 100644
--- a/include/linux/unix_diag.h
+++ b/include/linux/unix_diag.h
@@ -15,6 +15,7 @@ struct unix_diag_req {
 #define UDIAG_SHOW_VFS		0x00000002	/* show VFS inode info */
 #define UDIAG_SHOW_PEER		0x00000004	/* show peer socket info */
 #define UDIAG_SHOW_ICONS	0x00000008	/* show pending connections */
+#define UDIAG_SHOW_RQLEN	0x00000010	/* show skb receive queue len */
 
 struct unix_diag_msg {
 	__u8	udiag_family;
@@ -31,6 +32,7 @@ enum {
 	UNIX_DIAG_VFS,
 	UNIX_DIAG_PEER,
 	UNIX_DIAG_ICONS,
+	UNIX_DIAG_RQLEN,
 
 	UNIX_DIAG_MAX,
 };
diff --git a/net/unix/diag.c b/net/unix/diag.c
index 9d9e808..53b4833 100644
--- a/net/unix/diag.c
+++ b/net/unix/diag.c
@@ -98,6 +98,15 @@ rtattr_failure:
 	return -EMSGSIZE;
 }
 
+static int sk_diag_show_rqlen(struct sock *sk, struct sk_buff *nlskb)
+{
+	RTA_PUT_U32(nlskb, UNIX_DIAG_RQLEN, sk->sk_receive_queue.qlen);
+	return 0;
+
+rtattr_failure:
+	return -EMSGSIZE;
+}
+
 static int sk_diag_fill(struct sock *sk, struct sk_buff *skb, struct unix_diag_req *req,
 		u32 pid, u32 seq, u32 flags, int sk_ino)
 {
@@ -132,6 +141,10 @@ static int sk_diag_fill(struct sock *sk, struct sk_buff *skb, struct unix_diag_r
 			sk_diag_dump_icons(sk, skb))
 		goto nlmsg_failure;
 
+	if ((req->udiag_show & UDIAG_SHOW_RQLEN) &&
+			sk_diag_show_rqlen(sk, skb))
+		goto nlmsg_failure;
+
 	nlh->nlmsg_len = skb_tail_pointer(skb) - b;
 	return skb->len;
 
-- 
1.5.5.6
