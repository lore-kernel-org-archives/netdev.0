From: Lin Zhang <xiaolou4617@gmail.com>
Subject: [PATCH] net: llc: add lock_sock in llc_ui_bind to avoid a race condition
Date: Thu, 25 May 2017 14:07:18 +0800
Message-ID: <1495692438-9781-1-git-send-email-xiaolou4617@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Lin Zhang <xiaolou4617@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:36674 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1162203AbdEYGH0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 May 2017 02:07:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is a race condition in llc_ui_bind if two or more processes/threads 
try to bind a same socket.

If more processes/threads bind a same socket success that will lead to 
two problems, one is this action is not what we expected, another is 
will lead to kernel in unstable status or oops(in my simple test case, 
cause llc2.ko can't unload).

The current code is test SOCK_ZAPPED bit to avoid a process to 
bind a same socket twice but that is can't avoid more processes/threads 
try to bind a same socket at the same time.

So, add lock_sock in llc_ui_bind like others, such as llc_ui_connect.

Signed-off-by: Lin Zhang <xiaolou4617@gmail.com>
---
 net/llc/af_llc.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/llc/af_llc.c b/net/llc/af_llc.c
index 8364fe5..c38d16f 100644
--- a/net/llc/af_llc.c
+++ b/net/llc/af_llc.c
@@ -311,6 +311,8 @@ static int llc_ui_bind(struct socket *sock, struct sockaddr *uaddr, int addrlen)
 	int rc = -EINVAL;
 
 	dprintk("%s: binding %02X\n", __func__, addr->sllc_sap);
+
+	lock_sock(sk);
 	if (unlikely(!sock_flag(sk, SOCK_ZAPPED) || addrlen != sizeof(*addr)))
 		goto out;
 	rc = -EAFNOSUPPORT;
@@ -382,6 +384,7 @@ static int llc_ui_bind(struct socket *sock, struct sockaddr *uaddr, int addrlen)
 out_put:
 	llc_sap_put(sap);
 out:
+	release_sock(sk);
 	return rc;
 }
 
-- 
1.8.3.1
