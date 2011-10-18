From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] filter: use unsigned int to silence static checker warning
Date: Tue, 18 Oct 2011 10:04:20 +0300
Message-ID: <20111018070420.GR27732@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Changli Gao <xiaosuo@gmail.com>,
	kernel-janitors@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet15.oracle.com ([148.87.113.117]:31078 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753243Ab1JRHEZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2011 03:04:25 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is just a cleanup.

My testing version of Smatch warns about this:
net/core/filter.c +380 check_load_and_stores(6)
	warn: check 'flen' for negative values

flen comes from the user.  We try to clamp the values here between 1
and BPF_MAXINSNS but the clamp doesn't work because it could be
negative.  This is a bug, but it's not exploitable.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/include/linux/filter.h b/include/linux/filter.h
index 741956f..8eeb205 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -155,7 +155,7 @@ extern unsigned int sk_run_filter(const struct sk_buff *skb,
 				  const struct sock_filter *filter);
 extern int sk_attach_filter(struct sock_fprog *fprog, struct sock *sk);
 extern int sk_detach_filter(struct sock *sk);
-extern int sk_chk_filter(struct sock_filter *filter, int flen);
+extern int sk_chk_filter(struct sock_filter *filter, unsigned int flen);
 
 #ifdef CONFIG_BPF_JIT
 extern void bpf_jit_compile(struct sk_filter *fp);
diff --git a/net/core/filter.c b/net/core/filter.c
index 8fcc2d7..5dea452 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -436,7 +436,7 @@ error:
  *
  * Returns 0 if the rule set is legal or -EINVAL if not.
  */
-int sk_chk_filter(struct sock_filter *filter, int flen)
+int sk_chk_filter(struct sock_filter *filter, unsigned int flen)
 {
 	/*
 	 * Valid instructions are initialized to non-0.
