From: Andrey Vagin <avagin@openvz.org>
Subject: [PATCH 1/3] netlink: allow to set peeking offset for sockets
Date: Sun, 12 Jun 2016 23:07:19 -0700
Message-ID: <1465798041-6783-2-git-send-email-avagin@openvz.org>
References: <1465798041-6783-1-git-send-email-avagin@openvz.org>
Cc: criu@openvz.org, Andrey Vagin <avagin@openvz.org>,
	Pavel Emelyanov <xemul@virtuozzo.com>,
	"David S. Miller" <davem@davemloft.net>,
	Ken-ichirou MATSUZAWA <chamaken@gmail.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Florian Westphal <fw@strlen.de>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	David Herrmann <dh.herrmann@gmail.com>,
	Christophe Ricard <christophe.ricard@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:36080 "EHLO
	mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932630AbcFMGIa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 02:08:30 -0400
Received: by mail-pa0-f68.google.com with SMTP id fg1so9754870pad.3
        for <netdev@vger.kernel.org>; Sun, 12 Jun 2016 23:08:30 -0700 (PDT)
In-Reply-To: <1465798041-6783-1-git-send-email-avagin@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This allows us to read socket's queue without removing skbs from it.

The same logic was implemented for unix and inet sockets and we use this
to dump and restore sockets in CRIU.

Here is a question whether sk_peek_off has to be protected by locks.
Currently it isn't protected and an user who uses sk_peek_off has to be
sure that nobody calls recvmsg for a socket except him.

Signed-off-by: Andrey Vagin <avagin@openvz.org>
---
 net/netlink/af_netlink.c | 25 ++++++++++++++++++++-----
 1 file changed, 20 insertions(+), 5 deletions(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 627f898..d334ffc 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1796,17 +1796,18 @@ static int netlink_recvmsg(struct socket *sock, struct msghdr *msg, size_t len,
 	struct scm_cookie scm;
 	struct sock *sk = sock->sk;
 	struct netlink_sock *nlk = nlk_sk(sk);
-	int noblock = flags&MSG_DONTWAIT;
 	size_t copied;
 	struct sk_buff *skb, *data_skb;
+	int peeked, skip;
 	int err, ret;
 
 	if (flags&MSG_OOB)
 		return -EOPNOTSUPP;
 
 	copied = 0;
+	skip = sk_peek_offset(sk, flags);
 
-	skb = skb_recv_datagram(sk, flags, noblock, &err);
+	skb = __skb_recv_datagram(sk, flags, &peeked, &skip, &err);
 	if (skb == NULL)
 		goto out;
 
@@ -1834,14 +1835,20 @@ static int netlink_recvmsg(struct socket *sock, struct msghdr *msg, size_t len,
 	nlk->max_recvmsg_len = min_t(size_t, nlk->max_recvmsg_len,
 				     16384);
 
-	copied = data_skb->len;
+	copied = data_skb->len - skip;
 	if (len < copied) {
 		msg->msg_flags |= MSG_TRUNC;
 		copied = len;
 	}
 
 	skb_reset_transport_header(data_skb);
-	err = skb_copy_datagram_msg(data_skb, 0, msg, copied);
+	err = skb_copy_datagram_msg(data_skb, skip, msg, copied);
+
+	if (flags & MSG_PEEK)
+		sk_peek_offset_fwd(sk, copied);
+	else
+		sk_peek_offset_bwd(sk, skb->len);
+
 
 	if (msg->msg_name) {
 		DECLARE_SOCKADDR(struct sockaddr_nl *, addr, msg->msg_name);
@@ -1860,7 +1867,7 @@ static int netlink_recvmsg(struct socket *sock, struct msghdr *msg, size_t len,
 	memset(&scm, 0, sizeof(scm));
 	scm.creds = *NETLINK_CREDS(skb);
 	if (flags & MSG_TRUNC)
-		copied = data_skb->len;
+		copied = data_skb->len - skip;
 
 	skb_free_datagram(sk, skb);
 
@@ -2496,6 +2503,13 @@ int netlink_unregister_notifier(struct notifier_block *nb)
 }
 EXPORT_SYMBOL(netlink_unregister_notifier);
 
+static int netlink_set_peek_off(struct sock *sk, int val)
+{
+	sk->sk_peek_off = val;
+
+	return 0;
+}
+
 static const struct proto_ops netlink_ops = {
 	.family =	PF_NETLINK,
 	.owner =	THIS_MODULE,
@@ -2515,6 +2529,7 @@ static const struct proto_ops netlink_ops = {
 	.recvmsg =	netlink_recvmsg,
 	.mmap =		sock_no_mmap,
 	.sendpage =	sock_no_sendpage,
+	.set_peek_off = netlink_set_peek_off,
 };
 
 static const struct net_proto_family netlink_family_ops = {
-- 
2.5.5
