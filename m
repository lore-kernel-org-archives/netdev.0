From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH] sock_diag: fix filter code sent to userspace
Date: Wed,  5 Jun 2013 15:30:55 +0200
Message-ID: <1370439055-4239-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:54924 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755273Ab3FENbA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Jun 2013 09:31:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Filters need to be translated to real BPF code for userland, like SO_GETFILTER.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 include/linux/filter.h | 1 +
 net/core/filter.c      | 2 +-
 net/core/sock_diag.c   | 9 +++++++--
 3 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/include/linux/filter.h b/include/linux/filter.h
index c050dcc..f65f5a6 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -46,6 +46,7 @@ extern int sk_attach_filter(struct sock_fprog *fprog, struct sock *sk);
 extern int sk_detach_filter(struct sock *sk);
 extern int sk_chk_filter(struct sock_filter *filter, unsigned int flen);
 extern int sk_get_filter(struct sock *sk, struct sock_filter __user *filter, unsigned len);
+extern void sk_decode_filter(struct sock_filter *filt, struct sock_filter *to);
 
 #ifdef CONFIG_BPF_JIT
 #include <stdarg.h>
diff --git a/net/core/filter.c b/net/core/filter.c
index dad2a17..6438f29 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -778,7 +778,7 @@ int sk_detach_filter(struct sock *sk)
 }
 EXPORT_SYMBOL_GPL(sk_detach_filter);
 
-static void sk_decode_filter(struct sock_filter *filt, struct sock_filter *to)
+void sk_decode_filter(struct sock_filter *filt, struct sock_filter *to)
 {
 	static const u16 decodes[] = {
 		[BPF_S_ALU_ADD_K]	= BPF_ALU|BPF_ADD|BPF_K,
diff --git a/net/core/sock_diag.c b/net/core/sock_diag.c
index d5bef0b0..a0e9cf6 100644
--- a/net/core/sock_diag.c
+++ b/net/core/sock_diag.c
@@ -73,8 +73,13 @@ int sock_diag_put_filterinfo(struct user_namespace *user_ns, struct sock *sk,
 		goto out;
 	}
 
-	if (filter)
-		memcpy(nla_data(attr), filter->insns, len);
+	if (filter) {
+		struct sock_filter *fb = (struct sock_filter *)nla_data(attr);
+		int i;
+
+		for (i = 0; i < filter->len; i++, fb++)
+			sk_decode_filter(&filter->insns[i], fb);
+	}
 
 out:
 	rcu_read_unlock();
-- 
1.8.2.1
