From: David Howells <dhowells@redhat.com>
Subject: [PATCH] AF_NETLINK: Support MSG_TRUNC passed to recvmsg()
Date: Fri, 13 Apr 2007 20:17:08 +0100
Message-ID: <20070413191708.19621.91658.stgit@warthog.cambridge.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:41283 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932129AbXDMTRT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Apr 2007 15:17:19 -0400
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.13.1/8.13.1) with ESMTP id l3DJHG0h003027
	for <netdev@vger.kernel.org>; Fri, 13 Apr 2007 15:17:16 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Support MSG_TRUNC when passed to recvmsg() as an argument on an AF_NETLINK
socket.  In such a case, the full size of the packet at the front of the Rx
queue should be returned, including any of it discarded when MSG_TRUNC is set
by recvmsg() on return.

If MSG_TRUNC is not set, then only the amount of data read into the buffer is
returned, and any discarded data goes uncounted.

This is according to the recvmsg() manual page.  AFS will make use of this
feature to work out the buffer size required to receive a netlink message by
combining MSG_TRUNC with MSG_PEEK.

This feature is useful on netlink sockets as recvmsg() there just discards any
of the packet that won't fit in the buffer.

Signed-Off-By: David Howells <dhowells@redhat.com>
---

 net/netlink/af_netlink.c |   15 +++++++++------
 1 files changed, 9 insertions(+), 6 deletions(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index e73d8f5..6288dd1 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1194,7 +1194,7 @@ static int netlink_recvmsg(struct kiocb *kiocb, struct socket *sock,
 	struct sock *sk = sock->sk;
 	struct netlink_sock *nlk = nlk_sk(sk);
 	int noblock = flags&MSG_DONTWAIT;
-	size_t copied;
+	size_t copy, copied;
 	struct sk_buff *skb;
 	int err;
 
@@ -1209,14 +1209,17 @@ static int netlink_recvmsg(struct kiocb *kiocb, struct socket *sock,
 
 	msg->msg_namelen = 0;
 
-	copied = skb->len;
-	if (len < copied) {
-		msg->msg_flags |= MSG_TRUNC;
-		copied = len;
+	copied = copy = skb->len;
+	if (len < copy) {
+		copy = len;
+		if (!(flags & MSG_TRUNC)) {
+			copied = len;
+			msg->msg_flags |= MSG_TRUNC;
+		}
 	}
 
 	skb->h.raw = skb->data;
-	err = skb_copy_datagram_iovec(skb, 0, msg->msg_iov, copied);
+	err = skb_copy_datagram_iovec(skb, 0, msg->msg_iov, copy);
 
 	if (msg->msg_name) {
 		struct sockaddr_nl *addr = (struct sockaddr_nl*)msg->msg_name;

