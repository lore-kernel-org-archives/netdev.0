From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH 7/13] unix_diag: Dumping exact socket core
Date: Thu, 15 Dec 2011 16:45:07 +0400
Message-ID: <4EE9EBD3.8010103@parallels.com>
References: <4EE9EB2A.4040909@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:48345 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758441Ab1LOMpO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Dec 2011 07:45:14 -0500
In-Reply-To: <4EE9EB2A.4040909@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The socket inode is used as a key for lookup. This is effectively
the only really unique ID of a unix socket, but using this for
search currently has one problem -- it is O(number of sockets) :(

Does it worth fixing this lookup or inventing some other ID for
unix sockets?

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

---
 net/unix/diag.c |   67 ++++++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 66 insertions(+), 1 deletions(-)

diff --git a/net/unix/diag.c b/net/unix/diag.c
index 86d85ab..d7bd48c 100644
--- a/net/unix/diag.c
+++ b/net/unix/diag.c
@@ -89,11 +89,76 @@ done:
 	return skb->len;
 }
 
+static struct sock *unix_lookup_by_ino(int ino)
+{
+	int i;
+	struct sock *sk;
+
+	spin_lock(&unix_table_lock);
+	for (i = 0; i <= UNIX_HASH_SIZE; i++) {
+		struct hlist_node *node;
+
+		sk_for_each(sk, node, &unix_socket_table[i])
+			if (ino == sock_i_ino(sk)) {
+				sock_hold(sk);
+				spin_unlock(&unix_table_lock);
+
+				return sk;
+			}
+	}
+
+	spin_unlock(&unix_table_lock);
+	return NULL;
+}
+
 static int unix_diag_get_exact(struct sk_buff *in_skb,
 			       const struct nlmsghdr *nlh,
 			       struct unix_diag_req *req)
 {
-	return -EAFNOSUPPORT;
+	int err = -EINVAL;
+	struct sock *sk;
+	struct sk_buff *rep;
+	unsigned int extra_len;
+
+	if (req->udiag_ino == 0)
+		goto out_nosk;
+
+	sk = unix_lookup_by_ino(req->udiag_ino);
+	err = -ENOENT;
+	if (sk == NULL)
+		goto out_nosk;
+
+	err = sock_diag_check_cookie(sk, req->udiag_cookie);
+	if (err)
+		goto out;
+
+	extra_len = 256;
+again:
+	err = -ENOMEM;
+	rep = alloc_skb(NLMSG_SPACE((sizeof(struct unix_diag_msg) + extra_len)),
+			GFP_KERNEL);
+	if (!rep)
+		goto out;
+
+	err = sk_diag_fill(sk, rep, req, NETLINK_CB(in_skb).pid,
+			   nlh->nlmsg_seq, 0, req->udiag_ino);
+	if (err < 0) {
+		kfree_skb(rep);
+		extra_len += 256;
+		if (extra_len >= PAGE_SIZE)
+			goto out;
+
+		goto again;
+	}
+	err = netlink_unicast(sock_diag_nlsk, rep, NETLINK_CB(in_skb).pid,
+			      MSG_DONTWAIT);
+	if (err > 0)
+		err = 0;
+out:
+	if (sk)
+		sock_put(sk);
+out_nosk:
+	return err;
 }
 
 static int unix_diag_handler_dump(struct sk_buff *skb, struct nlmsghdr *h)
-- 
1.5.5.6
