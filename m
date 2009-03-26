From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: [PATCH] af_rose/x25: Sanity check the maximum user frame size
Date: Thu, 26 Mar 2009 21:58:51 +0000
Message-ID: <20090326215826.18836.86957.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from earthlight.etchedpixels.co.uk ([81.2.110.250]:56891 "EHLO
	www.etchedpixels.co.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757424AbZCZV5u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2009 17:57:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Otherwise we can wrap the sizes and end up sending garbage.

Closes #10423

Signed-off-by: Alan Cox <alan@lxorguk.ukuu.org.uk>
---

 net/netrom/af_netrom.c |    6 +++++-
 net/rose/af_rose.c     |    4 ++++
 net/x25/af_x25.c       |    6 ++++++
 3 files changed, 15 insertions(+), 1 deletions(-)


diff --git a/net/netrom/af_netrom.c b/net/netrom/af_netrom.c
index e9c05b8..29953b0 100644
--- a/net/netrom/af_netrom.c
+++ b/net/netrom/af_netrom.c
@@ -1082,7 +1082,11 @@ static int nr_sendmsg(struct kiocb *iocb, struct socket *sock,
 
 	SOCK_DEBUG(sk, "NET/ROM: sendto: Addresses built.\n");
 
-	/* Build a packet */
+	/* Build a packet - the conventional user limit is 236 bytes. We can
+	   do ludicrously large NetROM frames but must not overflow */
+	if (len > 65536)
+		return -EMSGSIZE;
+	
 	SOCK_DEBUG(sk, "NET/ROM: sendto: building packet.\n");
 	size = len + NR_NETWORK_LEN + NR_TRANSPORT_LEN;
 
diff --git a/net/rose/af_rose.c b/net/rose/af_rose.c
index 0139264..5e75bbf 100644
--- a/net/rose/af_rose.c
+++ b/net/rose/af_rose.c
@@ -1124,6 +1124,10 @@ static int rose_sendmsg(struct kiocb *iocb, struct socket *sock,
 
 	/* Build a packet */
 	SOCK_DEBUG(sk, "ROSE: sendto: building packet.\n");
+	/* Sanity check the packet size */
+	if (len > 65535)
+		return -EMSGSIZE;
+
 	size = len + AX25_BPQ_HEADER_LEN + AX25_MAX_HEADER_LEN + ROSE_MIN_LEN;
 
 	if ((skb = sock_alloc_send_skb(sk, size, msg->msg_flags & MSG_DONTWAIT, &err)) == NULL)
diff --git a/net/x25/af_x25.c b/net/x25/af_x25.c
index 9fc5b02..88d80f5 100644
--- a/net/x25/af_x25.c
+++ b/net/x25/af_x25.c
@@ -1037,6 +1037,12 @@ static int x25_sendmsg(struct kiocb *iocb, struct socket *sock,
 		sx25.sx25_addr   = x25->dest_addr;
 	}
 
+	/* Sanity check the packet size */
+	if (len > 65535) {
+		rc = -EMSGSIZE;
+		goto out;
+	}
+
 	SOCK_DEBUG(sk, "x25_sendmsg: sendto: Addresses built.\n");
 
 	/* Build a packet */

