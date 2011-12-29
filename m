From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH 1/5] sock_diag: Introduce the meminfo nla core
Date: Thu, 29 Dec 2011 18:12:29 +0400
Message-ID: <4EFC754D.6000803@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:43585 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750890Ab1L2OMi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Dec 2011 09:12:38 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a routine that dumps memory-related values of a socket.
It's made as an array to make it possible to add more stuff
here later without breaking compatibility.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

---
 include/linux/sock_diag.h |   15 +++++++++++++++
 net/core/sock_diag.c      |   23 +++++++++++++++++++++++
 2 files changed, 38 insertions(+), 0 deletions(-)

diff --git a/include/linux/sock_diag.h b/include/linux/sock_diag.h
index 379d5dc..309dddc 100644
--- a/include/linux/sock_diag.h
+++ b/include/linux/sock_diag.h
@@ -5,6 +5,7 @@
 
 struct sk_buff;
 struct nlmsghdr;
+struct sock;
 
 struct sock_diag_req {
 	__u8	sdiag_family;
@@ -25,5 +26,19 @@ void sock_diag_unregister_inet_compat(int (*fn)(struct sk_buff *skb, struct nlms
 int sock_diag_check_cookie(void *sk, __u32 *cookie);
 void sock_diag_save_cookie(void *sk, __u32 *cookie);
 
+int sock_diag_put_meminfo(struct sock *sk, struct sk_buff *skb, int attr);
+
+enum {
+	SK_MEMINFO_RMEM_ALLOC,
+	SK_MEMINFO_RCVBUF,
+	SK_MEMINFO_WMEM_ALLOC,
+	SK_MEMINFO_SNDBUF,
+	SK_MEMINFO_FWD_ALLOC,
+	SK_MEMINFO_WMEM_QUEUED,
+	SK_MEMINFO_OPTMEM,
+
+	SK_MEMINFO_VARS,
+};
+
 extern struct sock *sock_diag_nlsk;
 #endif
diff --git a/net/core/sock_diag.c b/net/core/sock_diag.c
index 711bdef..b9868e1 100644
--- a/net/core/sock_diag.c
+++ b/net/core/sock_diag.c
@@ -4,6 +4,8 @@
 #include <net/netlink.h>
 #include <net/net_namespace.h>
 #include <linux/module.h>
+#include <linux/rtnetlink.h>
+#include <net/sock.h>
 
 #include <linux/inet_diag.h>
 #include <linux/sock_diag.h>
@@ -31,6 +33,27 @@ void sock_diag_save_cookie(void *sk, __u32 *cookie)
 }
 EXPORT_SYMBOL_GPL(sock_diag_save_cookie);
 
+int sock_diag_put_meminfo(struct sock *sk, struct sk_buff *skb, int attrtype)
+{
+	__u32 *mem;
+
+	mem = RTA_DATA(__RTA_PUT(skb, attrtype, SK_MEMINFO_VARS * sizeof(__u32)));
+
+	mem[SK_MEMINFO_RMEM_ALLOC] = sk_rmem_alloc_get(sk);
+	mem[SK_MEMINFO_RCVBUF] = sk->sk_rcvbuf;
+	mem[SK_MEMINFO_WMEM_ALLOC] = sk_wmem_alloc_get(sk);
+	mem[SK_MEMINFO_SNDBUF] = sk->sk_sndbuf;
+	mem[SK_MEMINFO_FWD_ALLOC] = sk->sk_forward_alloc;
+	mem[SK_MEMINFO_WMEM_QUEUED] = sk->sk_wmem_queued;
+	mem[SK_MEMINFO_OPTMEM] = atomic_read(&sk->sk_omem_alloc);
+
+	return 0;
+
+rtattr_failure:
+	return -EMSGSIZE;
+}
+EXPORT_SYMBOL_GPL(sock_diag_put_meminfo);
+
 void sock_diag_register_inet_compat(int (*fn)(struct sk_buff *skb, struct nlmsghdr *nlh))
 {
 	mutex_lock(&sock_diag_table_mutex);
-- 
1.5.5.6
