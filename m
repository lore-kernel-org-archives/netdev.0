From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH net-next] sock-diag: Report shutdown for inet and unix sockets
 (v2)
Date: Tue, 23 Oct 2012 22:29:56 +0400
Message-ID: <5086E224.4030103@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:10432 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756657Ab2JWSaF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Oct 2012 14:30:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make it simple -- just put new nlattr with just sk->sk_shutdown bits.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

---
 include/uapi/linux/inet_diag.h |    3 ++-
 include/uapi/linux/unix_diag.h |    1 +
 net/ipv4/inet_diag.c           |    3 +++
 net/unix/diag.c                |    3 +++
 4 files changed, 9 insertions(+), 1 deletions(-)

diff --git a/include/uapi/linux/inet_diag.h b/include/uapi/linux/inet_diag.h
index 8c469af..bbde90f 100644
--- a/include/uapi/linux/inet_diag.h
+++ b/include/uapi/linux/inet_diag.h
@@ -109,9 +109,10 @@ enum {
 	INET_DIAG_TOS,
 	INET_DIAG_TCLASS,
 	INET_DIAG_SKMEMINFO,
+	INET_DIAG_SHUTDOWN,
 };
 
-#define INET_DIAG_MAX INET_DIAG_SKMEMINFO
+#define INET_DIAG_MAX INET_DIAG_SHUTDOWN
 
 
 /* INET_DIAG_MEM */
diff --git a/include/uapi/linux/unix_diag.h b/include/uapi/linux/unix_diag.h
index b1d2bf1..b8a2494 100644
--- a/include/uapi/linux/unix_diag.h
+++ b/include/uapi/linux/unix_diag.h
@@ -37,6 +37,7 @@ enum {
 	UNIX_DIAG_ICONS,
 	UNIX_DIAG_RQLEN,
 	UNIX_DIAG_MEMINFO,
+	UNIX_DIAG_SHUTDOWN,
 
 	UNIX_DIAG_MAX,
 };
diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index 535584c..e5bad82 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -105,6 +105,9 @@ int inet_sk_diag_fill(struct sock *sk, struct inet_connection_sock *icsk,
 	r->id.idiag_src[0] = inet->inet_rcv_saddr;
 	r->id.idiag_dst[0] = inet->inet_daddr;
 
+	if (nla_put_u8(skb, INET_DIAG_SHUTDOWN, sk->sk_shutdown))
+		goto errout;
+
 	/* IPv6 dual-stack sockets use inet->tos for IPv4 connections,
 	 * hence this needs to be included regardless of socket family.
 	 */
diff --git a/net/unix/diag.c b/net/unix/diag.c
index 06748f1..5ac19dc 100644
--- a/net/unix/diag.c
+++ b/net/unix/diag.c
@@ -151,6 +151,9 @@ static int sk_diag_fill(struct sock *sk, struct sk_buff *skb, struct unix_diag_r
 	    sock_diag_put_meminfo(sk, skb, UNIX_DIAG_MEMINFO))
 		goto out_nlmsg_trim;
 
+	if (nla_put_u8(skb, UNIX_DIAG_SHUTDOWN, sk->sk_shutdown))
+		goto out_nlmsg_trim;
+
 	return nlmsg_end(skb, nlh);
 
 out_nlmsg_trim:
-- 
1.7.6.5
