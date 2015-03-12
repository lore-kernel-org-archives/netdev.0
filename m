From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v2 net-next 4/8] inet: add rsk_refcnt/ireq_refcnt to request socks
Date: Thu, 12 Mar 2015 16:44:06 -0700
Message-ID: <1426203850-11034-5-git-send-email-edumazet@google.com>
References: <1426203850-11034-1-git-send-email-edumazet@google.com>
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f202.google.com ([209.85.220.202]:35005 "EHLO
	mail-vc0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755347AbbCLXow (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2015 19:44:52 -0400
Received: by mail-vc0-f202.google.com with SMTP id hy10so3218776vcb.1
        for <netdev@vger.kernel.org>; Thu, 12 Mar 2015 16:44:51 -0700 (PDT)
In-Reply-To: <1426203850-11034-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When request socks will be in ehash, they'll need to be refcounted.

This patch adds rsk_refcnt/ireq_refcnt macros, and adds
reqsk_put() function, but nothing yet use them.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/inet_sock.h    | 1 +
 include/net/request_sock.h | 8 ++++++++
 2 files changed, 9 insertions(+)

diff --git a/include/net/inet_sock.h b/include/net/inet_sock.h
index b31f01de5cd6..9d6470c16a27 100644
--- a/include/net/inet_sock.h
+++ b/include/net/inet_sock.h
@@ -81,6 +81,7 @@ struct inet_request_sock {
 #define ir_cookie		req.__req_common.skc_cookie
 #define ireq_net		req.__req_common.skc_net
 #define ireq_state		req.__req_common.skc_state
+#define ireq_refcnt		req.__req_common.skc_refcnt
 
 	kmemcheck_bitfield_begin(flags);
 	u16			snd_wscale : 4,
diff --git a/include/net/request_sock.h b/include/net/request_sock.h
index 7f830ff67f08..e255ecf8bb40 100644
--- a/include/net/request_sock.h
+++ b/include/net/request_sock.h
@@ -49,6 +49,8 @@ int inet_rtx_syn_ack(struct sock *parent, struct request_sock *req);
  */
 struct request_sock {
 	struct sock_common		__req_common;
+#define rsk_refcnt			__req_common.skc_refcnt
+
 	struct request_sock		*dl_next;
 	u16				mss;
 	u8				num_retrans; /* number of retransmits */
@@ -86,6 +88,12 @@ static inline void reqsk_free(struct request_sock *req)
 	__reqsk_free(req);
 }
 
+static inline void reqsk_put(struct request_sock *req)
+{
+	if (atomic_dec_and_test(&req->rsk_refcnt))
+		reqsk_free(req);
+}
+
 extern int sysctl_max_syn_backlog;
 
 /** struct listen_sock - listen state
-- 
2.2.0.rc0.207.ga3a616c
