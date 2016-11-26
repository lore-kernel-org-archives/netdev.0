From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 1/6] bpf: drop unnecessary context cast from BPF_PROG_RUN
Date: Sat, 26 Nov 2016 01:28:04 +0100
Message-ID: <6a4f36605f8bd5a7322311d846623cf775367f14.1480119396.git.daniel@iogearbox.net>
References: <cover.1480119395.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:42842 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751613AbcKZA2o (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Nov 2016 19:28:44 -0500
In-Reply-To: <cover.1480119395.git.daniel@iogearbox.net>
In-Reply-To: <cover.1480119395.git.daniel@iogearbox.net>
References: <cover.1480119395.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since long already bpf_func is not only about struct sk_buff * as
input anymore. Make it generic as void *, so that callers don't
need to cast for it each time they call BPF_PROG_RUN().

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 drivers/net/ethernet/netronome/nfp/nfp_net_common.c | 2 +-
 include/linux/filter.h                              | 6 +++---
 kernel/events/core.c                                | 2 +-
 kernel/seccomp.c                                    | 2 +-
 4 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index eb37157..876ab3a 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -1518,7 +1518,7 @@ static int nfp_net_run_xdp(struct bpf_prog *prog, void *data, unsigned int len)
 	xdp.data = data;
 	xdp.data_end = data + len;
 
-	return BPF_PROG_RUN(prog, (void *)&xdp);
+	return BPF_PROG_RUN(prog, &xdp);
 }
 
 /**
diff --git a/include/linux/filter.h b/include/linux/filter.h
index 1f09c52..7f246a2 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -408,8 +408,8 @@ struct bpf_prog {
 	enum bpf_prog_type	type;		/* Type of BPF program */
 	struct bpf_prog_aux	*aux;		/* Auxiliary fields */
 	struct sock_fprog_kern	*orig_prog;	/* Original BPF program */
-	unsigned int		(*bpf_func)(const struct sk_buff *skb,
-					    const struct bpf_insn *filter);
+	unsigned int		(*bpf_func)(const void *ctx,
+					    const struct bpf_insn *insn);
 	/* Instructions for interpreter */
 	union {
 		struct sock_filter	insns[0];
@@ -504,7 +504,7 @@ static inline u32 bpf_prog_run_xdp(const struct bpf_prog *prog,
 	u32 ret;
 
 	rcu_read_lock();
-	ret = BPF_PROG_RUN(prog, (void *)xdp);
+	ret = BPF_PROG_RUN(prog, xdp);
 	rcu_read_unlock();
 
 	return ret;
diff --git a/kernel/events/core.c b/kernel/events/core.c
index 0e29213..19237c2 100644
--- a/kernel/events/core.c
+++ b/kernel/events/core.c
@@ -7715,7 +7715,7 @@ static void bpf_overflow_handler(struct perf_event *event,
 	if (unlikely(__this_cpu_inc_return(bpf_prog_active) != 1))
 		goto out;
 	rcu_read_lock();
-	ret = BPF_PROG_RUN(event->prog, (void *)&ctx);
+	ret = BPF_PROG_RUN(event->prog, &ctx);
 	rcu_read_unlock();
 out:
 	__this_cpu_dec(bpf_prog_active);
diff --git a/kernel/seccomp.c b/kernel/seccomp.c
index 0db7c8a..bff9c77 100644
--- a/kernel/seccomp.c
+++ b/kernel/seccomp.c
@@ -195,7 +195,7 @@ static u32 seccomp_run_filters(const struct seccomp_data *sd)
 	 * value always takes priority (ignoring the DATA).
 	 */
 	for (; f; f = f->prev) {
-		u32 cur_ret = BPF_PROG_RUN(f->prog, (void *)sd);
+		u32 cur_ret = BPF_PROG_RUN(f->prog, sd);
 
 		if ((cur_ret & SECCOMP_RET_ACTION) < (ret & SECCOMP_RET_ACTION))
 			ret = cur_ret;
-- 
1.9.3
