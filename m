From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 1/4] bpf: minor cleanups in helpers
Date: Fri,  9 Sep 2016 02:45:28 +0200
Message-ID: <e928bf94947f204bae6ccc1a0391f077854dc69d.1473381476.git.daniel@iogearbox.net>
References: <cover.1473381476.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, tgraf@suug.ch,
        netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:33171 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751269AbcIIApo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Sep 2016 20:45:44 -0400
In-Reply-To: <cover.1473381476.git.daniel@iogearbox.net>
In-Reply-To: <cover.1473381476.git.daniel@iogearbox.net>
References: <cover.1473381476.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some minor misc cleanups, f.e. use sizeof(__u32) instead of hardcoding
and in __bpf_skb_max_len(), I missed that we always have skb->dev valid
anyway, so we can drop the unneeded test for dev; also few more other
misc bits addressed here.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 kernel/bpf/helpers.c | 6 +++---
 net/core/filter.c    | 7 +++----
 2 files changed, 6 insertions(+), 7 deletions(-)

diff --git a/kernel/bpf/helpers.c b/kernel/bpf/helpers.c
index 1ea3afb..6df73bd 100644
--- a/kernel/bpf/helpers.c
+++ b/kernel/bpf/helpers.c
@@ -126,7 +126,7 @@ static u64 bpf_get_current_pid_tgid(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
 {
 	struct task_struct *task = current;
 
-	if (!task)
+	if (unlikely(!task))
 		return -EINVAL;
 
 	return (u64) task->tgid << 32 | task->pid;
@@ -144,12 +144,12 @@ static u64 bpf_get_current_uid_gid(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
 	kuid_t uid;
 	kgid_t gid;
 
-	if (!task)
+	if (unlikely(!task))
 		return -EINVAL;
 
 	current_uid_gid(&uid, &gid);
 	return (u64) from_kgid(&init_user_ns, gid) << 32 |
-		from_kuid(&init_user_ns, uid);
+		     from_kuid(&init_user_ns, uid);
 }
 
 const struct bpf_func_proto bpf_get_current_uid_gid_proto = {
diff --git a/net/core/filter.c b/net/core/filter.c
index a83766b..628ed8c 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -2010,8 +2010,7 @@ static u32 __bpf_skb_min_len(const struct sk_buff *skb)
 
 static u32 __bpf_skb_max_len(const struct sk_buff *skb)
 {
-	return skb->dev ? skb->dev->mtu + skb->dev->hard_header_len :
-	       65536;
+	return skb->dev->mtu + skb->dev->hard_header_len;
 }
 
 static int bpf_skb_grow_rcsum(struct sk_buff *skb, unsigned int new_len)
@@ -2605,7 +2604,7 @@ static bool __is_valid_xdp_access(int off, int size,
 		return false;
 	if (off % size != 0)
 		return false;
-	if (size != 4)
+	if (size != sizeof(__u32))
 		return false;
 
 	return true;
@@ -2727,7 +2726,7 @@ static u32 bpf_net_convert_ctx_access(enum bpf_access_type type, int dst_reg,
 					  dst_reg, src_reg, insn);
 
 	case offsetof(struct __sk_buff, cb[0]) ...
-		offsetof(struct __sk_buff, cb[4]):
+	     offsetof(struct __sk_buff, cb[4]):
 		BUILD_BUG_ON(FIELD_SIZEOF(struct qdisc_skb_cb, data) < 20);
 
 		prog->cb_access = 1;
-- 
1.9.3
