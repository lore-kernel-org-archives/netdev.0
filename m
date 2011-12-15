From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH 9/13] unix_diag: Unix inode info NLA
Date: Thu, 15 Dec 2011 16:45:43 +0400
Message-ID: <4EE9EBF7.6010700@parallels.com>
References: <4EE9EB2A.4040909@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:2289 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751089Ab1LOMpt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Dec 2011 07:45:49 -0500
In-Reply-To: <4EE9EB2A.4040909@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Actually, the socket path if it's not anonymous doesn't give
a clue to which file the socket is bound to. Even if the path
is absolute, it can be unlinked and then new socket can be
bound to it.

With this NLA it's possible to check which file a particular
socket is really bound to.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

---
 include/linux/unix_diag.h |    7 +++++++
 net/unix/diag.c           |   21 +++++++++++++++++++++
 2 files changed, 28 insertions(+), 0 deletions(-)

diff --git a/include/linux/unix_diag.h b/include/linux/unix_diag.h
index cc4df34..3e53adb 100644
--- a/include/linux/unix_diag.h
+++ b/include/linux/unix_diag.h
@@ -12,6 +12,7 @@ struct unix_diag_req {
 };
 
 #define UDIAG_SHOW_NAME		0x00000001	/* show name (not path) */
+#define UDIAG_SHOW_VFS		0x00000002	/* show VFS inode info */
 
 struct unix_diag_msg {
 	__u8	udiag_family;
@@ -25,8 +26,14 @@ struct unix_diag_msg {
 
 enum {
 	UNIX_DIAG_NAME,
+	UNIX_DIAG_VFS,
 
 	UNIX_DIAG_MAX,
 };
 
+struct unix_diag_vfs {
+	__u32	udiag_vfs_ino;
+	__u32	udiag_vfs_dev;
+};
+
 #endif
diff --git a/net/unix/diag.c b/net/unix/diag.c
index 161ce6c..83799ef 100644
--- a/net/unix/diag.c
+++ b/net/unix/diag.c
@@ -26,6 +26,23 @@ rtattr_failure:
 	return -EMSGSIZE;
 }
 
+static int sk_diag_dump_vfs(struct sock *sk, struct sk_buff *nlskb)
+{
+	struct dentry *dentry = unix_sk(sk)->dentry;
+	struct unix_diag_vfs *uv;
+
+	if (dentry) {
+		uv = UNIX_DIAG_PUT(nlskb, UNIX_DIAG_VFS, sizeof(*uv));
+		uv->udiag_vfs_ino = dentry->d_inode->i_ino;
+		uv->udiag_vfs_dev = dentry->d_sb->s_dev;
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
@@ -48,6 +65,10 @@ static int sk_diag_fill(struct sock *sk, struct sk_buff *skb, struct unix_diag_r
 			sk_diag_dump_name(sk, skb))
 		goto nlmsg_failure;
 
+	if ((req->udiag_show & UDIAG_SHOW_VFS) &&
+			sk_diag_dump_vfs(sk, skb))
+		goto nlmsg_failure;
+
 	nlh->nlmsg_len = skb_tail_pointer(skb) - b;
 	return skb->len;
 
-- 
1.5.5.6
