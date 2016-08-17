From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 4/4] bpf: get rid of cgroup helper related ifdefs
Date: Thu, 18 Aug 2016 01:00:41 +0200
Message-ID: <49688216ec989ebc78c6a30043ad659f2b53293e.1471473110.git.daniel@iogearbox.net>
References: <cover.1471473110.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, tgraf@suug.ch,
	netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:34700 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753376AbcHQXCA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Aug 2016 19:02:00 -0400
In-Reply-To: <cover.1471473110.git.daniel@iogearbox.net>
In-Reply-To: <cover.1471473110.git.daniel@iogearbox.net>
References: <cover.1471473110.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As recently discussed during the task_under_cgroup_hierarchy() addition,
we should get rid of the ifdefs surrounding the bpf_skb_under_cgroup()
helper. If related functionality is not built-in, the helper cannot be
used anyway, which is also in line with what we do for all other helpers.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 include/net/sock.h | 10 ++++++++++
 net/core/filter.c  |  6 +-----
 2 files changed, 11 insertions(+), 5 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index ff5be7e..2aab9b6 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1114,6 +1114,16 @@ static inline bool sk_stream_is_writeable(const struct sock *sk)
 	       sk_stream_memory_free(sk);
 }
 
+static inline int sk_under_cgroup_hierarchy(struct sock *sk,
+					    struct cgroup *ancestor)
+{
+#ifdef CONFIG_SOCK_CGROUP_DATA
+	return cgroup_is_descendant(sock_cgroup_ptr(&sk->sk_cgrp_data),
+				    ancestor);
+#else
+	return -ENOTSUPP;
+#endif
+}
 
 static inline bool sk_has_memory_pressure(const struct sock *sk)
 {
diff --git a/net/core/filter.c b/net/core/filter.c
index 3b60dfd..a83766b 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -2374,7 +2374,6 @@ bpf_get_skb_set_tunnel_proto(enum bpf_func_id which)
 	}
 }
 
-#ifdef CONFIG_SOCK_CGROUP_DATA
 static u64 bpf_skb_under_cgroup(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
 {
 	struct sk_buff *skb = (struct sk_buff *)(long)r1;
@@ -2395,7 +2394,7 @@ static u64 bpf_skb_under_cgroup(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
 	if (unlikely(!cgrp))
 		return -EAGAIN;
 
-	return cgroup_is_descendant(sock_cgroup_ptr(&sk->sk_cgrp_data), cgrp);
+	return sk_under_cgroup_hierarchy(sk, cgrp);
 }
 
 static const struct bpf_func_proto bpf_skb_under_cgroup_proto = {
@@ -2406,7 +2405,6 @@ static const struct bpf_func_proto bpf_skb_under_cgroup_proto = {
 	.arg2_type	= ARG_CONST_MAP_PTR,
 	.arg3_type	= ARG_ANYTHING,
 };
-#endif
 
 static unsigned long bpf_xdp_copy(void *dst_buff, const void *src_buff,
 				  unsigned long off, unsigned long len)
@@ -2515,10 +2513,8 @@ tc_cls_act_func_proto(enum bpf_func_id func_id)
 		return &bpf_skb_event_output_proto;
 	case BPF_FUNC_get_smp_processor_id:
 		return &bpf_get_smp_processor_id_proto;
-#ifdef CONFIG_SOCK_CGROUP_DATA
 	case BPF_FUNC_skb_under_cgroup:
 		return &bpf_skb_under_cgroup_proto;
-#endif
 	default:
 		return sk_filter_func_proto(func_id);
 	}
-- 
1.9.3
