From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 2/3] [IPV6]: inet_sk(sk)->cork.opt leak
Date: Wed,  4 Jun 2008 15:49:07 +0400
Message-ID: <1212580148-9885-2-git-send-email-den@openvz.org>
References: <1212580148-9885-1-git-send-email-den@openvz.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org, kaber@trash.net,
	"Denis V. Lunev" <den@openvz.org>
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:27680 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753367AbYFDLtP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Jun 2008 07:49:15 -0400
In-Reply-To: <1212580148-9885-1-git-send-email-den@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IPv6 UDP sockets wth IPv4 mapped address use udp_sendmsg to send the data
actually. In this case ip_flush_pending_frames should be called instead
of ip6_flush_pending_frames.

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 include/net/udp.h |    1 +
 net/ipv4/udp.c    |    3 ++-
 net/ipv6/udp.c    |    4 +++-
 3 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/include/net/udp.h b/include/net/udp.h
index 3e55a99..ccce837 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -135,6 +135,7 @@ extern void	udp_err(struct sk_buff *, u32);
 
 extern int	udp_sendmsg(struct kiocb *iocb, struct sock *sk,
 			    struct msghdr *msg, size_t len);
+extern void	udp_flush_pending_frames(struct sock *sk);
 
 extern int	udp_rcv(struct sk_buff *skb);
 extern int	udp_ioctl(struct sock *sk, int cmd, unsigned long arg);
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index db1cb7c..56fcda3 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -420,7 +420,7 @@ void udp_err(struct sk_buff *skb, u32 info)
 /*
  * Throw away all pending data and cancel the corking. Socket is locked.
  */
-static void udp_flush_pending_frames(struct sock *sk)
+void udp_flush_pending_frames(struct sock *sk)
 {
 	struct udp_sock *up = udp_sk(sk);
 
@@ -430,6 +430,7 @@ static void udp_flush_pending_frames(struct sock *sk)
 		ip_flush_pending_frames(sk);
 	}
 }
+EXPORT_SYMBOL(udp_flush_pending_frames);
 
 /**
  * 	udp4_hwcsum_outgoing  -  handle outgoing HW checksumming
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 1fd784f..b0be4b5 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -534,7 +534,9 @@ static void udp_v6_flush_pending_frames(struct sock *sk)
 {
 	struct udp_sock *up = udp_sk(sk);
 
-	if (up->pending) {
+	if (up->pending == AF_INET)
+		udp_flush_pending_frames(sk);
+	else if (up->pending) {
 		up->len = 0;
 		up->pending = 0;
 		ip6_flush_pending_frames(sk);
-- 
1.5.3.rc5

