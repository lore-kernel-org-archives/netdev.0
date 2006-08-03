From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] llc: SOCK_DGRAM interface fixes
Date: Thu, 3 Aug 2006 09:21:17 -0700
Message-ID: <20060803092117.5726b4d7@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stable@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:35468 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932567AbWHCQWQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2006 12:22:16 -0400
To: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	"David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The datagram interface of LLC is broken in a couple of ways.
These were discovered when trying to use it to build an out-of-kernel
version of STP.

First it didn't pass the source address of the received packet
in recvfrom(). It needs to copy the source address of received LLC packets
into the socket control block. At the same time fix a security issue
because there was uninitialized data leakage. Every recvfrom call
was just copying out old data.

Second, LLC should not merge multiple packets in one receive call
on datagram sockets. LLC should preserve packet boundaries on
SOCK_DGRAM. 

This fix goes against the old historical comments about UNIX98 semantics
but without this fix SOCK_DGRAM is broken and useless. So either ANK's
interpretation was incorect or UNIX98 standard was wrong.


Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
---
 net/llc/af_llc.c  |   20 ++++++++------------
 net/llc/llc_sap.c |    4 ++--
 2 files changed, 10 insertions(+), 14 deletions(-)

diff --git a/net/llc/af_llc.c b/net/llc/af_llc.c
index d6cfe84..2652ead 100644
--- a/net/llc/af_llc.c
+++ b/net/llc/af_llc.c
@@ -784,24 +784,20 @@ static int llc_ui_recvmsg(struct kiocb *
 		copied += used;
 		len -= used;
 
-		if (used + offset < skb->len)
-			continue;
-
 		if (!(flags & MSG_PEEK)) {
 			sk_eat_skb(sk, skb, 0);
 			*seq = 0;
 		}
+
+		/* For non stream protcols we get one packet per recvmsg call */
+		if (sk->sk_type != SOCK_STREAM)
+			goto copy_uaddr;
+
+		/* Partial read */
+		if (used + offset < skb->len)
+			continue;
 	} while (len > 0);
 
-	/* 
-	 * According to UNIX98, msg_name/msg_namelen are ignored
-	 * on connected socket. -ANK
-	 * But... af_llc still doesn't have separate sets of methods for
-	 * SOCK_DGRAM and SOCK_STREAM :-( So we have to do this test, will
-	 * eventually fix this tho :-) -acme
-	 */
-	if (sk->sk_type == SOCK_DGRAM)
-		goto copy_uaddr;
 out:
 	release_sock(sk);
 	return copied;
diff --git a/net/llc/llc_sap.c b/net/llc/llc_sap.c
index 20c4eb5..42eb0c3 100644
--- a/net/llc/llc_sap.c
+++ b/net/llc/llc_sap.c
@@ -51,10 +51,10 @@ void llc_save_primitive(struct sock *sk,
 {
 	struct sockaddr_llc *addr;
 
-	if (skb->sk->sk_type == SOCK_STREAM) /* See UNIX98 */
-		return;
        /* save primitive for use by the user. */
 	addr		  = llc_ui_skb_cb(skb);
+
+	memset(addr, 0, sizeof(*addr));
 	addr->sllc_family = sk->sk_family;
 	addr->sllc_arphrd = skb->dev->type;
 	addr->sllc_test   = prim == LLC_TEST_PRIM;
-- 
1.4.0

