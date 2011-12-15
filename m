From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH 11/13] unix_diag: Pending connections IDs NLA
Date: Thu, 15 Dec 2011 16:46:14 +0400
Message-ID: <4EE9EC16.7070701@parallels.com>
References: <4EE9EB2A.4040909@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:18223 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756117Ab1LOMqW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Dec 2011 07:46:22 -0500
In-Reply-To: <4EE9EB2A.4040909@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When establishing a unix connection on stream sockets the
server end receives an skb with socket in its receive queue.

Report who is waiting for these ends to be accepted for
listening sockets via NLA.


There's a lokcing issue with this -- the unix sk state lock is
required to access the peer, and it is taken under the listening
sk's queue lock. Strictly speaking the queue lock should be taken
inside the state lock, but since in this case these two sockets
are different it shouldn't lead to deadlock.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

---
 include/linux/unix_diag.h |    2 ++
 net/unix/diag.c           |   39 +++++++++++++++++++++++++++++++++++++++
 2 files changed, 41 insertions(+), 0 deletions(-)

diff --git a/include/linux/unix_diag.h b/include/linux/unix_diag.h
index 2d74a86..03ffb7d 100644
--- a/include/linux/unix_diag.h
+++ b/include/linux/unix_diag.h
@@ -14,6 +14,7 @@ struct unix_diag_req {
 #define UDIAG_SHOW_NAME		0x00000001	/* show name (not path) */
 #define UDIAG_SHOW_VFS		0x00000002	/* show VFS inode info */
 #define UDIAG_SHOW_PEER		0x00000004	/* show peer socket info */
+#define UDIAG_SHOW_ICONS	0x00000008	/* show pending connections */
 
 struct unix_diag_msg {
 	__u8	udiag_family;
@@ -29,6 +30,7 @@ enum {
 	UNIX_DIAG_NAME,
 	UNIX_DIAG_VFS,
 	UNIX_DIAG_PEER,
+	UNIX_DIAG_ICONS,
 
 	UNIX_DIAG_MAX,
 };
diff --git a/net/unix/diag.c b/net/unix/diag.c
index 0e0fda7..9d9e808 100644
--- a/net/unix/diag.c
+++ b/net/unix/diag.c
@@ -63,6 +63,41 @@ rtattr_failure:
 	return -EMSGSIZE;
 }
 
+static int sk_diag_dump_icons(struct sock *sk, struct sk_buff *nlskb)
+{
+	struct sk_buff *skb;
+	u32 *buf;
+	int i;
+
+	if (sk->sk_state == TCP_LISTEN) {
+		spin_lock(&sk->sk_receive_queue.lock);
+		buf = UNIX_DIAG_PUT(nlskb, UNIX_DIAG_ICONS, sk->sk_receive_queue.qlen);
+		i = 0;
+		skb_queue_walk(&sk->sk_receive_queue, skb) {
+			struct sock *req, *peer;
+
+			req = skb->sk;
+			/*
+			 * The state lock is outer for the same sk's
+			 * queue lock. With the other's queue locked it's
+			 * OK to lock the state.
+			 */
+			unix_state_lock_nested(req);
+			peer = unix_sk(req)->peer;
+			if (peer)
+				buf[i++] = sock_i_ino(peer);
+			unix_state_unlock(req);
+		}
+		spin_unlock(&sk->sk_receive_queue.lock);
+	}
+
+	return 0;
+
+rtattr_failure:
+	spin_unlock(&sk->sk_receive_queue.lock);
+	return -EMSGSIZE;
+}
+
 static int sk_diag_fill(struct sock *sk, struct sk_buff *skb, struct unix_diag_req *req,
 		u32 pid, u32 seq, u32 flags, int sk_ino)
 {
@@ -93,6 +128,10 @@ static int sk_diag_fill(struct sock *sk, struct sk_buff *skb, struct unix_diag_r
 			sk_diag_dump_peer(sk, skb))
 		goto nlmsg_failure;
 
+	if ((req->udiag_show & UDIAG_SHOW_ICONS) &&
+			sk_diag_dump_icons(sk, skb))
+		goto nlmsg_failure;
+
 	nlh->nlmsg_len = skb_tail_pointer(skb) - b;
 	return skb->len;
 
-- 
1.5.5.6
