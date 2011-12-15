From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH 6/13] unix_diag: Dumping all sockets core
Date: Thu, 15 Dec 2011 16:44:52 +0400
Message-ID: <4EE9EBC4.4010602@parallels.com>
References: <4EE9EB2A.4040909@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:20941 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758441Ab1LOMo6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Dec 2011 07:44:58 -0500
In-Reply-To: <4EE9EB2A.4040909@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Walk the unix sockets table and fill the core response structure,
which includes type, state and inode.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

---
 net/unix/diag.c |   76 ++++++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 75 insertions(+), 1 deletions(-)

diff --git a/net/unix/diag.c b/net/unix/diag.c
index 6be16c0..86d85ab 100644
--- a/net/unix/diag.c
+++ b/net/unix/diag.c
@@ -10,9 +10,83 @@
 #define UNIX_DIAG_PUT(skb, attrtype, attrlen) \
 	RTA_DATA(__RTA_PUT(skb, attrtype, attrlen))
 
+static int sk_diag_fill(struct sock *sk, struct sk_buff *skb, struct unix_diag_req *req,
+		u32 pid, u32 seq, u32 flags, int sk_ino)
+{
+	unsigned char *b = skb_tail_pointer(skb);
+	struct nlmsghdr *nlh;
+	struct unix_diag_msg *rep;
+
+	nlh = NLMSG_PUT(skb, pid, seq, SOCK_DIAG_BY_FAMILY, sizeof(*rep));
+	nlh->nlmsg_flags = flags;
+
+	rep = NLMSG_DATA(nlh);
+
+	rep->udiag_family = AF_UNIX;
+	rep->udiag_type = sk->sk_type;
+	rep->udiag_state = sk->sk_state;
+	rep->udiag_ino = sk_ino;
+	sock_diag_save_cookie(sk, rep->udiag_cookie);
+
+	nlh->nlmsg_len = skb_tail_pointer(skb) - b;
+	return skb->len;
+
+nlmsg_failure:
+	nlmsg_trim(skb, b);
+	return -EMSGSIZE;
+}
+
+static int sk_diag_dump(struct sock *sk, struct sk_buff *skb, struct unix_diag_req *req,
+		u32 pid, u32 seq, u32 flags)
+{
+	int sk_ino;
+
+	unix_state_lock(sk);
+	sk_ino = sock_i_ino(sk);
+	unix_state_unlock(sk);
+
+	if (!sk_ino)
+		return 0;
+
+	return sk_diag_fill(sk, skb, req, pid, seq, flags, sk_ino);
+}
+
 static int unix_diag_dump(struct sk_buff *skb, struct netlink_callback *cb)
 {
-	return 0;
+	struct unix_diag_req *req;
+	int num, s_num, slot, s_slot;
+
+	req = NLMSG_DATA(cb->nlh);
+
+	s_slot = cb->args[0];
+	num = s_num = cb->args[1];
+
+	spin_lock(&unix_table_lock);
+	for (slot = s_slot; slot <= UNIX_HASH_SIZE; s_num = 0, slot++) {
+		struct sock *sk;
+		struct hlist_node *node;
+
+		num = 0;
+		sk_for_each(sk, node, &unix_socket_table[slot]) {
+			if (num < s_num)
+				goto next;
+			if (!(req->udiag_states & (1 << sk->sk_state)))
+				goto next;
+			if (sk_diag_dump(sk, skb, req,
+						NETLINK_CB(cb->skb).pid,
+						cb->nlh->nlmsg_seq,
+						NLM_F_MULTI) < 0)
+				goto done;
+next:
+			num++;
+		}
+	}
+done:
+	spin_unlock(&unix_table_lock);
+	cb->args[0] = slot;
+	cb->args[1] = num;
+
+	return skb->len;
 }
 
 static int unix_diag_get_exact(struct sk_buff *in_skb,
-- 
1.5.5.6
