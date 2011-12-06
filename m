From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH 2/11] sock_diag: Introduce new message type
Date: Tue, 06 Dec 2011 21:57:06 +0400
Message-ID: <4EDE5772.5020204@parallels.com>
References: <4EDE573A.6040607@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:36104 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751967Ab1LFR5M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Dec 2011 12:57:12 -0500
In-Reply-To: <4EDE573A.6040607@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This type will run the family+protocol based socket dumping.
Also prepare the stub function for it.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

---
 include/linux/inet_diag.h |    1 +
 net/ipv4/inet_diag.c      |   17 +++++++++++++++--
 2 files changed, 16 insertions(+), 2 deletions(-)

diff --git a/include/linux/inet_diag.h b/include/linux/inet_diag.h
index abf5028..f7baaf6 100644
--- a/include/linux/inet_diag.h
+++ b/include/linux/inet_diag.h
@@ -6,6 +6,7 @@
 /* Just some random number */
 #define TCPDIAG_GETSOCK 18
 #define DCCPDIAG_GETSOCK 19
+#define SOCK_DIAG_BY_FAMILY 20
 
 #define INET_DIAG_GETSOCK_MAX 24
 
diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index a5f3c40..e106e3b 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -850,7 +850,7 @@ unlock:
 	return skb->len;
 }
 
-static int inet_diag_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
+static int inet_diag_rcv_msg_compat(struct sk_buff *skb, struct nlmsghdr *nlh)
 {
 	int hdrlen = sizeof(struct inet_diag_req);
 
@@ -877,9 +877,22 @@ static int inet_diag_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 	return inet_diag_get_exact(skb, nlh);
 }
 
+static int __sock_diag_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
+{
+	return -EOPNOTSUPP;
+}
+
 static int sock_diag_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 {
-	return inet_diag_rcv_msg(skb, nlh);
+	switch (nlh->nlmsg_type) {
+	case TCPDIAG_GETSOCK:
+	case DCCPDIAG_GETSOCK:
+		return inet_diag_rcv_msg_compat(skb, nlh);
+	case SOCK_DIAG_BY_FAMILY:
+		return __sock_diag_rcv_msg(skb, nlh);
+	default:
+		return -EINVAL;
+	}
 }
 
 static DEFINE_MUTEX(sock_diag_mutex);
-- 
1.5.5.6
