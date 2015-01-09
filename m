From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH net-next RFC 2/5] net-timestamp: no-payload only sysctl
Date: Fri,  9 Jan 2015 12:31:56 -0500
Message-ID: <1420824719-28848-3-git-send-email-willemb@google.com>
References: <1420824719-28848-1-git-send-email-willemb@google.com>
Cc: davem@davemloft.net, richardcochran@gmail.com,
	eric.dumazet@gmail.com, luto@amacapital.net,
	Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f44.google.com ([209.85.213.44]:61122 "EHLO
	mail-yh0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752308AbbAIRcH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2015 12:32:07 -0500
Received: by mail-yh0-f44.google.com with SMTP id c41so4711108yho.3
        for <netdev@vger.kernel.org>; Fri, 09 Jan 2015 09:32:06 -0800 (PST)
In-Reply-To: <1420824719-28848-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

Tx timestamps are looped onto the error queue on top of an skb. This
mechanism leaks packet headers to processes unless the no-payload
options SOF_TIMESTAMPING_OPT_TSONLY is set.

Add a sysctl that optionally drops looped timestamps with data for
unprivileged users.

The policy is checked when timestamps are generated in the stack.
It is possible for timestamps with data to be reported after the
sysctl is set, if these were queued internally earlier.

No vulnerability is immediately known that exploits knowledge
gleaned from packet headers, but it may still be preferable to allow
administrators to lock down this path at the cost of possible
breakage of legacy applications.

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 include/net/sock.h         |  1 +
 net/core/skbuff.c          | 11 ++++++++++-
 net/core/sock.c            |  3 +++
 net/core/sysctl_net_core.c |  9 +++++++++
 4 files changed, 23 insertions(+), 1 deletion(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 2210fec..9729171 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -2262,6 +2262,7 @@ bool sk_net_capable(const struct sock *sk, int cap);
 extern __u32 sysctl_wmem_max;
 extern __u32 sysctl_rmem_max;
 
+extern int sysctl_tstamp_allow_data;
 extern int sysctl_optmem_max;
 
 extern __u32 sysctl_wmem_default;
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index ece2bb8..e5f4c06 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -3690,11 +3690,20 @@ static void __skb_complete_tx_timestamp(struct sk_buff *skb,
 		kfree_skb(skb);
 }
 
+static bool skb_may_tx_timestamp(struct sock *sk)
+{
+	return sysctl_tstamp_allow_data || capable(CAP_NET_RAW) ||
+	       sk->sk_tsflags & SOF_TIMESTAMPING_OPT_TSONLY;
+}
+
 void skb_complete_tx_timestamp(struct sk_buff *skb,
 			       struct skb_shared_hwtstamps *hwtstamps)
 {
 	struct sock *sk = skb->sk;
 
+	if (!skb_may_tx_timestamp(sk))
+		return;
+
 	/* take a reference to prevent skb_orphan() from freeing the socket */
 	sock_hold(sk);
 
@@ -3712,7 +3721,7 @@ void __skb_tstamp_tx(struct sk_buff *orig_skb,
 	struct sk_buff *skb;
 	bool tsonly = sk->sk_tsflags & SOF_TIMESTAMPING_OPT_TSONLY;
 
-	if (!sk)
+	if (!sk || !skb_may_tx_timestamp(sk))
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
