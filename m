From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: [PATCH v3 07/18] ip: stash a pointer to msghdr in struct ping_fakehdr
Date: Wed,  4 Feb 2015 06:39:58 +0000
Message-ID: <1423032009-18367-7-git-send-email-viro@ZenIV.linux.org.uk>
References: <20150204063730.GG29656@ZenIV.linux.org.uk>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:43087 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751483AbbBDGkL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2015 01:40:11 -0500
In-Reply-To: <20150204063730.GG29656@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Al Viro <viro@zeniv.linux.org.uk>

... instead of storing its ->mgs_iter.iov there

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
 include/net/ping.h | 2 +-
 net/ipv4/ping.c    | 7 +++----
 net/ipv6/ping.c    | 3 +--
 3 files changed, 5 insertions(+), 7 deletions(-)

diff --git a/include/net/ping.h b/include/net/ping.h
index f074060..cc16d41 100644
--- a/include/net/ping.h
+++ b/include/net/ping.h
@@ -59,7 +59,7 @@ extern struct pingv6_ops pingv6_ops;
 
 struct pingfakehdr {
 	struct icmphdr icmph;
-	struct iovec *iov;
+	struct msghdr *msg;
 	sa_family_t family;
 	__wsum wcheck;
 };
diff --git a/net/ipv4/ping.c b/net/ipv4/ping.c
index 2a3720f..9e15ba7 100644
--- a/net/ipv4/ping.c
+++ b/net/ipv4/ping.c
@@ -602,14 +602,14 @@ int ping_getfrag(void *from, char *to,
 		if (fraglen < sizeof(struct icmphdr))
 			BUG();
 		if (csum_partial_copy_fromiovecend(to + sizeof(struct icmphdr),
-			    pfh->iov, 0, fraglen - sizeof(struct icmphdr),
+			    pfh->msg->msg_iter.iov, 0, fraglen - sizeof(struct icmphdr),
 			    &pfh->wcheck))
 			return -EFAULT;
 	} else if (offset < sizeof(struct icmphdr)) {
 			BUG();
 	} else {
 		if (csum_partial_copy_fromiovecend
-				(to, pfh->iov, offset - sizeof(struct icmphdr),
+				(to, pfh->msg->msg_iter.iov, offset - sizeof(struct icmphdr),
 				 fraglen, &pfh->wcheck))
 			return -EFAULT;
 	}
@@ -811,8 +811,7 @@ back_from_confirm:
 	pfh.icmph.checksum = 0;
 	pfh.icmph.un.echo.id = inet->inet_sport;
 	pfh.icmph.un.echo.sequence = user_icmph.un.echo.sequence;
-	/* XXX: stripping const */
-	pfh.iov = (struct iovec *)msg->msg_iter.iov;
+	pfh.msg = msg;
 	pfh.wcheck = 0;
 	pfh.family = AF_INET;
 
diff --git a/net/ipv6/ping.c b/net/ipv6/ping.c
index 2d31483..bd46f73 100644
--- a/net/ipv6/ping.c
+++ b/net/ipv6/ping.c
@@ -163,8 +163,7 @@ int ping_v6_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	pfh.icmph.checksum = 0;
 	pfh.icmph.un.echo.id = inet->inet_sport;
 	pfh.icmph.un.echo.sequence = user_icmph.icmp6_sequence;
-	/* XXX: stripping const */
-	pfh.iov = (struct iovec *)msg->msg_iter.iov;
+	pfh.msg = msg;
 	pfh.wcheck = 0;
 	pfh.family = AF_INET6;
 
-- 
2.1.4
