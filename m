From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: [PATCH 2/2] udp: remove redundant variable
Date: Thu, 11 Feb 2010 07:26:19 +0100
Message-ID: <1265869579-5829-3-git-send-email-gerrit@erg.abdn.ac.uk>
References: <udp_dccp_msg_trunc>
 <1265869579-5829-1-git-send-email-gerrit@erg.abdn.ac.uk>
 <1265869579-5829-2-git-send-email-gerrit@erg.abdn.ac.uk>
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org,
	Gerrit Renker <gerrit@erg.abdn.ac.uk>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:51478 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751650Ab0BKG0k (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Feb 2010 01:26:40 -0500
In-Reply-To: <1265869579-5829-2-git-send-email-gerrit@erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The variable 'copied' is used in udp_recvmsg() to emphasize that the passed
'len' is adjusted to fit the actual datagram length. But the same can be
done by adjusting 'len' directly. This patch thus removes the indirection.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/ipv4/udp.c |   15 +++++++--------
 net/ipv6/udp.c |   15 +++++++--------
 2 files changed, 14 insertions(+), 16 deletions(-)

--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1117,7 +1117,7 @@ int udp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	struct inet_sock *inet = inet_sk(sk);
 	struct sockaddr_in *sin = (struct sockaddr_in *)msg->msg_name;
 	struct sk_buff *skb;
-	unsigned int ulen, copied;
+	unsigned int ulen;
 	int peeked;
 	int err;
 	int is_udplite = IS_UDPLITE(sk);
@@ -1138,10 +1138,9 @@ try_again:
 		goto out;
 
 	ulen = skb->len - sizeof(struct udphdr);
-	copied = len;
-	if (copied > ulen)
-		copied = ulen;
-	else if (copied < ulen)
+	if (len > ulen)
+		len = ulen;
+	else if (len < ulen)
 		msg->msg_flags |= MSG_TRUNC;
 
 	/*
@@ -1150,14 +1149,14 @@ try_again:
 	 * coverage checksum (UDP-Lite), do it before the copy.
 	 */
 
-	if (copied < ulen || UDP_SKB_CB(skb)->partial_cov) {
+	if (len < ulen || UDP_SKB_CB(skb)->partial_cov) {
 		if (udp_lib_checksum_complete(skb))
 			goto csum_copy_err;
 	}
 
 	if (skb_csum_unnecessary(skb))
 		err = skb_copy_datagram_iovec(skb, sizeof(struct udphdr),
-					      msg->msg_iov, copied);
+					      msg->msg_iov, len);
 	else {
 		err = skb_copy_and_csum_datagram_iovec(skb,
 						       sizeof(struct udphdr),
@@ -1186,7 +1185,7 @@ try_again:
 	if (inet->cmsg_flags)
 		ip_cmsg_recv(msg, skb);
 
-	err = copied;
+	err = len;
 	if (flags & MSG_TRUNC)
 		err = ulen;
 
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -322,7 +322,7 @@ int udpv6_recvmsg(struct kiocb *iocb, struct sock *sk,
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct inet_sock *inet = inet_sk(sk);
 	struct sk_buff *skb;
-	unsigned int ulen, copied;
+	unsigned int ulen;
 	int peeked;
 	int err;
 	int is_udplite = IS_UDPLITE(sk);
@@ -341,10 +341,9 @@ try_again:
 		goto out;
 
 	ulen = skb->len - sizeof(struct udphdr);
-	copied = len;
-	if (copied > ulen)
-		copied = ulen;
-	else if (copied < ulen)
+	if (len > ulen)
+		len = ulen;
+	else if (len < ulen)
 		msg->msg_flags |= MSG_TRUNC;
 
 	is_udp4 = (skb->protocol == htons(ETH_P_IP));
@@ -355,14 +354,14 @@ try_again:
 	 * coverage checksum (UDP-Lite), do it before the copy.
 	 */
 
-	if (copied < ulen || UDP_SKB_CB(skb)->partial_cov) {
+	if (len < ulen || UDP_SKB_CB(skb)->partial_cov) {
 		if (udp_lib_checksum_complete(skb))
 			goto csum_copy_err;
 	}
 
 	if (skb_csum_unnecessary(skb))
 		err = skb_copy_datagram_iovec(skb, sizeof(struct udphdr),
-					      msg->msg_iov, copied       );
+					      msg->msg_iov,len);
 	else {
 		err = skb_copy_and_csum_datagram_iovec(skb, sizeof(struct udphdr), msg->msg_iov);
 		if (err == -EINVAL)
@@ -411,7 +410,7 @@ try_again:
 			datagram_recv_ctl(sk, msg, skb);
 	}
 
-	err = copied;
+	err = len;
 	if (flags & MSG_TRUNC)
 		err = ulen;
 
