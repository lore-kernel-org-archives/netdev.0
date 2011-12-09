From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH 3/13] inet_diag: Export inet diag cookie checking routine
Date: Fri, 09 Dec 2011 20:21:53 +0400
Message-ID: <4EE235A1.9010908@parallels.com>
References: <4EE23561.5020804@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:43398 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750798Ab1LIQV6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Dec 2011 11:21:58 -0500
In-Reply-To: <4EE23561.5020804@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The netlink diag susbsys stores sk address bits in the nl message
as a "cookie" and uses one when dumps details about particular
socket.

The same will be required for udp diag module, so introduce a heler
in inet_diag module

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

---
 include/linux/inet_diag.h |    2 ++
 net/ipv4/inet_diag.c      |   19 ++++++++++++++-----
 2 files changed, 16 insertions(+), 5 deletions(-)

diff --git a/include/linux/inet_diag.h b/include/linux/inet_diag.h
index 851feff..5036747 100644
--- a/include/linux/inet_diag.h
+++ b/include/linux/inet_diag.h
@@ -144,6 +144,8 @@ struct inet_diag_handler {
 	__u16                   idiag_type;
 };
 
+int inet_diag_check_cookie(struct sock *sk, struct inet_diag_req *req);
+
 extern int  inet_diag_register(const struct inet_diag_handler *handler);
 extern void inet_diag_unregister(const struct inet_diag_handler *handler);
 #endif /* __KERNEL__ */
diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index bd3f661..ba3ae1f 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -246,6 +246,18 @@ static int sk_diag_fill(struct sock *sk, struct sk_buff *skb,
 	return inet_csk_diag_fill(sk, skb, r, pid, seq, nlmsg_flags, unlh);
 }
 
+int inet_diag_check_cookie(struct sock *sk, struct inet_diag_req *req)
+{
+	if ((req->id.idiag_cookie[0] != INET_DIAG_NOCOOKIE ||
+	     req->id.idiag_cookie[1] != INET_DIAG_NOCOOKIE) &&
+	    ((u32)(unsigned long)sk != req->id.idiag_cookie[0] ||
+	     (u32)((((unsigned long)sk) >> 31) >> 1) != req->id.idiag_cookie[1]))
+		return -ESTALE;
+	else
+		return 0;
+}
+EXPORT_SYMBOL_GPL(inet_diag_check_cookie);
+
 static int inet_diag_get_exact(struct sk_buff *in_skb,
 			       const struct nlmsghdr *nlh,
 			       struct inet_diag_req *req)
@@ -288,11 +300,8 @@ static int inet_diag_get_exact(struct sk_buff *in_skb,
 	if (sk == NULL)
 		goto unlock;
 
-	err = -ESTALE;
-	if ((req->id.idiag_cookie[0] != INET_DIAG_NOCOOKIE ||
-	     req->id.idiag_cookie[1] != INET_DIAG_NOCOOKIE) &&
-	    ((u32)(unsigned long)sk != req->id.idiag_cookie[0] ||
-	     (u32)((((unsigned long)sk) >> 31) >> 1) != req->id.idiag_cookie[1]))
+	err = inet_diag_check_cookie(sk, req);
+	if (err)
 		goto out;
 
 	err = -ENOMEM;
-- 
1.5.5.6
