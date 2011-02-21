From: Andrey Vagin <avagin@openvz.org>
Subject: [PATCH] netlink: handle errors from netlink_dump()
Date: Mon, 21 Feb 2011 15:40:47 +0300
Message-ID: <1298292047-25025-1-git-send-email-avagin@openvz.org>
Cc: netdev@vger.kernel.org, avagin@openvz.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:19044 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752427Ab1BUMk5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Feb 2011 07:40:57 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netlink_dump() may failed, but nobody handle its error.
It generates output data, when a previous portion has been returned to
user space. This mechanism works when all data isn't go in skb. If we
enter in netlink_recvmsg() and skb is absent in the recv queue, the
netlink_dump() will not been executed. So if netlink_dump() is failed
one time, the new data never appear and the reader will sleep forever.

netlink_dump() is called from two places:

1. from netlink_sendmsg->...->netlink_dump_start().
   In this place we can report error directly and it will be returned
   by sendmsg().

2. from netlink_recvmsg
   There we can't report error directly, because we have a portion of
   valid output data and call netlink_dump() for prepare the next portion.
   If netlink_dump() is failed, the socket will be mark as error and the
   next recvmsg will be failed.

Signed-off-by: Andrey Vagin <avagin@openvz.org>
---
 net/netlink/af_netlink.c |   18 ++++++++++++++----
 1 files changed, 14 insertions(+), 4 deletions(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 478181d..1f92459 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1407,7 +1407,7 @@ static int netlink_recvmsg(struct kiocb *kiocb, struct socket *sock,
 	int noblock = flags&MSG_DONTWAIT;
 	size_t copied;
 	struct sk_buff *skb, *data_skb;
-	int err;
+	int err, ret;
 
 	if (flags&MSG_OOB)
 		return -EOPNOTSUPP;
@@ -1470,8 +1470,13 @@ static int netlink_recvmsg(struct kiocb *kiocb, struct socket *sock,
 
 	skb_free_datagram(sk, skb);
 
-	if (nlk->cb && atomic_read(&sk->sk_rmem_alloc) <= sk->sk_rcvbuf / 2)
-		netlink_dump(sk);
+	if (nlk->cb && atomic_read(&sk->sk_rmem_alloc) <= sk->sk_rcvbuf / 2) {
+		ret = netlink_dump(sk);
+		if (ret) {
+			sk->sk_err = ret;
+			sk->sk_error_report(sk);
+		}
+	}
 
 	scm_recv(sock, msg, siocb->scm, flags);
 out:
@@ -1736,6 +1741,7 @@ int netlink_dump_start(struct sock *ssk, struct sk_buff *skb,
 	struct netlink_callback *cb;
 	struct sock *sk;
 	struct netlink_sock *nlk;
+	int ret;
 
 	cb = kzalloc(sizeof(*cb), GFP_KERNEL);
 	if (cb == NULL)
@@ -1764,9 +1770,13 @@ int netlink_dump_start(struct sock *ssk, struct sk_buff *skb,
 	nlk->cb = cb;
 	mutex_unlock(nlk->cb_mutex);
 
-	netlink_dump(sk);
+	ret = netlink_dump(sk);
+
 	sock_put(sk);
 
+	if (ret)
+		return ret;
+
 	/* We successfully started a dump, by returning -EINTR we
 	 * signal not to send ACK even if it was requested.
 	 */
-- 
1.7.2.1

