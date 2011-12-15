From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH 10/13] unix_diag: Unix peer inode NLA
Date: Thu, 15 Dec 2011 16:45:58 +0400
Message-ID: <4EE9EC06.2060802@parallels.com>
References: <4EE9EB2A.4040909@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:5430 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756117Ab1LOMqE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Dec 2011 07:46:04 -0500
In-Reply-To: <4EE9EB2A.4040909@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Report the peer socket inode ID as NLA. With this it's finally
possible to find out the other end of an interesting unix connection.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

---
 include/linux/unix_diag.h |    2 ++
 net/unix/diag.c           |   24 ++++++++++++++++++++++++
 2 files changed, 26 insertions(+), 0 deletions(-)

diff --git a/include/linux/unix_diag.h b/include/linux/unix_diag.h
index 3e53adb..2d74a86 100644
--- a/include/linux/unix_diag.h
+++ b/include/linux/unix_diag.h
@@ -13,6 +13,7 @@ struct unix_diag_req {
 
 #define UDIAG_SHOW_NAME		0x00000001	/* show name (not path) */
 #define UDIAG_SHOW_VFS		0x00000002	/* show VFS inode info */
+#define UDIAG_SHOW_PEER		0x00000004	/* show peer socket info */
 
 struct unix_diag_msg {
 	__u8	udiag_family;
@@ -27,6 +28,7 @@ struct unix_diag_msg {
 enum {
 	UNIX_DIAG_NAME,
 	UNIX_DIAG_VFS,
+	UNIX_DIAG_PEER,
 
 	UNIX_DIAG_MAX,
 };
diff --git a/net/unix/diag.c b/net/unix/diag.c
index 83799ef..0e0fda7 100644
--- a/net/unix/diag.c
+++ b/net/unix/diag.c
@@ -43,6 +43,26 @@ rtattr_failure:
 	return -EMSGSIZE;
 }
 
+static int sk_diag_dump_peer(struct sock *sk, struct sk_buff *nlskb)
+{
+	struct sock *peer;
+	int ino;
+
+	peer = unix_peer_get(sk);
+	if (peer) {
+		unix_state_lock(peer);
+		ino = sock_i_ino(peer);
+		unix_state_unlock(peer);
+		sock_put(peer);
+
+		RTA_PUT_U32(nlskb, UNIX_DIAG_PEER, ino);
+	}
+
+	return 0;
+rtattr_failure:
+	return -EMSGSIZE;
+}
+
 static int sk_diag_fill(struct sock *sk, struct sk_buff *skb, struct unix_diag_req *req,
 		u32 pid, u32 seq, u32 flags, int sk_ino)
 {
@@ -69,6 +89,10 @@ static int sk_diag_fill(struct sock *sk, struct sk_buff *skb, struct unix_diag_r
 			sk_diag_dump_vfs(sk, skb))
 		goto nlmsg_failure;
 
+	if ((req->udiag_show & UDIAG_SHOW_PEER) &&
+			sk_diag_dump_peer(sk, skb))
+		goto nlmsg_failure;
+
 	nlh->nlmsg_len = skb_tail_pointer(skb) - b;
 	return skb->len;
 
-- 
1.5.5.6
