From: bernard pidoux <f6bvp@free.fr>
Subject: [PATCH 3/3] [NETROM] zero length frame filtering in NetRom
Date: Thu, 19 Mar 2009 19:18:52 +0100
Message-ID: <1237486732.30285.18.camel@f6bvp-11>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: Linux netdev <netdev@vger.kernel.org>,
	Linux Hams <linux-hams@vger.kernel.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2-g21.free.fr ([212.27.42.2]:44369 "EHLO smtp2-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754946AbZCSSfs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Mar 2009 14:35:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A zero length frame filter was recently introduced in ROSE protocole.
Previous commit makes the same at AX25 protocole level.
This patch has the same purpose for NetRom  protocole.
The reason is that empty frames have no meaning in NetRom protocole.

Signed-off-by: Bernard Pidoux <f6bvp@amsat.org>
---
 net/netrom/af_netrom.c |   11 ++++++++++-
 1 files changed, 10 insertions(+), 1 deletions(-)

diff --git a/net/netrom/af_netrom.c b/net/netrom/af_netrom.c
index e9c05b8..ec6c898 100644
--- a/net/netrom/af_netrom.c
+++ b/net/netrom/af_netrom.c
@@ -1037,6 +1037,10 @@ static int nr_sendmsg(struct kiocb *iocb, struct socket *sock,
 	unsigned char *asmptr;
 	int size;
 
+	/* Netrom empty data frame has no meaning : don't send */
+	if (len == 0)
+		return 0;
+
 	if (msg->msg_flags & ~(MSG_DONTWAIT|MSG_EOR|MSG_CMSG_COMPAT))
 		return -EINVAL;
 
@@ -1167,6 +1171,11 @@ static int nr_recvmsg(struct kiocb *iocb, struct socket *sock,
 	skb_reset_transport_header(skb);
 	copied     = skb->len;
 
+	/* NetRom empty data frame has no meaning : ignore it */
+	if (copied == 0) {
+		goto out;
+	}
+
 	if (copied > size) {
 		copied = size;
 		msg->msg_flags |= MSG_TRUNC;
@@ -1182,7 +1191,7 @@ static int nr_recvmsg(struct kiocb *iocb, struct socket *sock,
 
 	msg->msg_namelen = sizeof(*sax);
 
-	skb_free_datagram(sk, skb);
+out:	skb_free_datagram(sk, skb);
 
 	release_sock(sk);
 	return copied;
-- 
1.6.0.6

