From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH net-next v3 2/3] net-timestamp: no-payload only sysctl
Date: Fri, 30 Jan 2015 13:29:32 -0500
Message-ID: <1422642573-6126-3-git-send-email-willemb@google.com>
References: <1422642573-6126-1-git-send-email-willemb@google.com>
Cc: davem@davemloft.net, richardcochran@gmail.com, luto@amacapital.net,
	Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f170.google.com ([209.85.160.170]:54295 "EHLO
	mail-yk0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751798AbbA3S3w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jan 2015 13:29:52 -0500
Received: by mail-yk0-f170.google.com with SMTP id q9so17830483ykb.1
        for <netdev@vger.kernel.org>; Fri, 30 Jan 2015 10:29:52 -0800 (PST)
In-Reply-To: <1422642573-6126-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

Tx timestamps are looped onto the error queue on top of an skb. This
mechanism leaks packet headers to processes unless the no-payload
options SOF_TIMESTAMPING_OPT_TSONLY is set.

Add a sysctl that optionally drops looped timestamp with data. This
only affects processes without CAP_NET_RAW.

The policy is checked when timestamps are generated in the stack.
It is possible for timestamps with data to be reported after the
sysctl is set, if these were queued internally earlier.

No vulnerability is immediately known that exploits knowledge
gleaned from packet headers, but it may still be preferable to allow
administrators to lock down this path at the cost of possible
breakage of legacy applications.

Signed-off-by: Willem de Bruijn <willemb@google.com>

----

Changes
  (v1 -> v2)
  - test socket CAP_NET_RAW instead of capable(CAP_NET_RAW)
  (rfc -> v1)
  - document the sysctl in Documentation/sysctl/net.txt
  - fix access control race: read .._OPT_TSONLY only once,
        use same value for permission check and skb generation.
---
 Documentation/sysctl/net.txt |  8 ++++++++
 include/net/sock.h           |  1 +
 net/core/skbuff.c            | 21 ++++++++++++++++++++-
 net/core/sock.c              |  3 +++
 net/core/sysctl_net_core.c   |  9 +++++++++
 5 files changed, 41 insertions(+), 1 deletion(-)

diff --git a/Documentation/sysctl/net.txt b/Documentation/sysctl/net.txt
index 666594b..6294b51 100644
--- a/Documentation/sysctl/net.txt
+++ b/Documentation/sysctl/net.txt
@@ -97,6 +97,14 @@ rmem_max
 
 The maximum receive socket buffer size in bytes.
 
+tstamp_allow_data
+-----------------
+Allow processes to receive tx timestamps looped together with the original
+packet contents. If disabled, transmit timestamp requests from unprivileged
+processes are dropped unless socket option SOF_TIMESTAMPING_OPT_TSONLY is set.
+Default: 1 (on)
+
+
 wmem_default
 ------------
 
diff --git a/include/net/sock.h b/include/net/sock.h
index 1534149..511ef7c8 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -2239,6 +2239,7 @@ bool sk_net_capable(const struct sock *sk, int cap);
 extern __u32 sysctl_wmem_max;
 extern __u32 sysctl_rmem_max;
 
+extern int sysctl_tstamp_allow_data;
 extern int sysctl_optmem_max;
 
 extern __u32 sysctl_wmem_default;
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 65a3798..a5bff27 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -74,6 +74,8 @@
 #include <asm/uaccess.h>
 #include <trace/events/skb.h>
 #include <linux/highmem.h>
+#include <linux/capability.h>
+#include <linux/user_namespace.h>
 
 struct kmem_cache *skbuff_head_cache __read_mostly;
 static struct kmem_cache *skbuff_fclone_cache __read_mostly;
@@ -3690,11 +3692,28 @@ static void __skb_complete_tx_timestamp(struct sk_buff *skb,
 		kfree_skb(skb);
 }
 
+static bool skb_may_tx_timestamp(struct sock *sk, bool tsonly)
+{
+	bool ret;
+
+	if (likely(sysctl_tstamp_allow_data || tsonly))
+		return true;
+
+	read_lock_bh(&sk->sk_callback_lock);
+	ret = sk->sk_socket && sk->sk_socket->file &&
+	      file_ns_capable(sk->sk_socket->file, &init_user_ns, CAP_NET_RAW);
+	read_unlock_bh(&sk->sk_callback_lock);
+	return ret;
+}
+
 void skb_complete_tx_timestamp(struct sk_buff *skb,
 			       struct skb_shared_hwtstamps *hwtstamps)
 {
 	struct sock *sk = skb->sk;
 
+	if (!skb_may_tx_timestamp(sk, false))
+		return;
+
 	/* take a reference to prevent skb_orphan() from freeing the socket */
 	sock_hold(sk);
 
@@ -3712,7 +3731,7 @@ void __skb_tstamp_tx(struct sk_buff *orig_skb,
 	struct sk_buff *skb;
 	bool tsonly = sk->sk_tsflags & SOF_TIMESTAMPING_OPT_TSONLY;
 
-	if (!sk)
+	if (!sk || !skb_may_tx_timestamp(sk, tsonly))
 		return;
 
 	if (tsonly)
diff --git a/net/core/sock.c b/net/core/sock.c
index 1c7a33d..93c8b20 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -325,6 +325,8 @@ __u32 sysctl_rmem_default __read_mostly = SK_RMEM_MAX;
 int sysctl_optmem_max __read_mostly = sizeof(unsigned long)*(2*UIO_MAXIOV+512);
 EXPORT_SYMBOL(sysctl_optmem_max);
 
+int sysctl_tstamp_allow_data __read_mostly = 1;
+
 struct static_key memalloc_socks = STATIC_KEY_INIT_FALSE;
 EXPORT_SYMBOL_GPL(memalloc_socks);
 
@@ -840,6 +842,7 @@ set_rcvbuf:
 			ret = -EINVAL;
 			break;
 		}
+
 		if (val & SOF_TIMESTAMPING_OPT_ID &&
 		    !(sk->sk_tsflags & SOF_TIMESTAMPING_OPT_ID)) {
 			if (sk->sk_protocol == IPPROTO_TCP) {
diff --git a/net/core/sysctl_net_core.c b/net/core/sysctl_net_core.c
index 31baba2..fde21d1 100644
--- a/net/core/sysctl_net_core.c
+++ b/net/core/sysctl_net_core.c
@@ -321,6 +321,15 @@ static struct ctl_table net_core_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec
 	},
+	{
+		.procname	= "tstamp_allow_data",
+		.data		= &sysctl_tstamp_allow_data,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_minmax,
+		.extra1		= &zero,
+		.extra2		= &one
+	},
 #ifdef CONFIG_RPS
 	{
 		.procname	= "rps_sock_flow_entries",
-- 
2.2.0.rc0.207.ga3a616c
