From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH v2 net-next 1/5] bpf: Refactor cgroups code in prep for new type
Date: Wed, 26 Oct 2016 17:58:38 -0700
Message-ID: <1477529922-4806-2-git-send-email-dsa@cumulusnetworks.com>
References: <1477529922-4806-1-git-send-email-dsa@cumulusnetworks.com>
Cc: daniel@zonque.org, ast@fb.com, daniel@iogearbox.net,
        maheshb@google.com, tgraf@suug.ch,
        David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:36806 "EHLO
        mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932465AbcJ0A6u (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Oct 2016 20:58:50 -0400
Received: by mail-pf0-f177.google.com with SMTP id e6so6032097pfk.3
        for <netdev@vger.kernel.org>; Wed, 26 Oct 2016 17:58:50 -0700 (PDT)
In-Reply-To: <1477529922-4806-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Code move only and rename only; no functional change intended.

v2
- fix bpf_prog_run_clear_cb to bpf_prog_run_save_cb as caught by Daniel

- rename BPF_PROG_TYPE_CGROUP_SKB and its cg_skb functions to
  BPF_PROG_TYPE_CGROUP and cgroup

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 include/uapi/linux/bpf.h        |  2 +-
 kernel/bpf/cgroup.c             | 27 ++++++++++++++++++++++-----
 kernel/bpf/syscall.c            |  2 +-
 net/core/filter.c               | 14 +++++++-------
 samples/bpf/test_cgrp2_attach.c |  4 ++--
 5 files changed, 33 insertions(+), 16 deletions(-)

diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 6b62ee9a2f78..73da296c2125 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -98,7 +98,7 @@ enum bpf_prog_type {
 	BPF_PROG_TYPE_TRACEPOINT,
 	BPF_PROG_TYPE_XDP,
 	BPF_PROG_TYPE_PERF_EVENT,
-	BPF_PROG_TYPE_CGROUP_SKB,
+	BPF_PROG_TYPE_CGROUP,
 };
 
 enum bpf_attach_type {
diff --git a/kernel/bpf/cgroup.c b/kernel/bpf/cgroup.c
index a0ab43f264b0..d5746aec8f34 100644
--- a/kernel/bpf/cgroup.c
+++ b/kernel/bpf/cgroup.c
@@ -117,6 +117,19 @@ void __cgroup_bpf_update(struct cgroup *cgrp,
 	}
 }
 
+static int __cgroup_bpf_run_filter_skb(struct sk_buff *skb,
+				       struct bpf_prog *prog)
+{
+	unsigned int offset = skb->data - skb_network_header(skb);
+	int ret;
+
+	__skb_push(skb, offset);
+	ret = bpf_prog_run_save_cb(prog, skb) == 1 ? 0 : -EPERM;
+	__skb_pull(skb, offset);
+
+	return ret;
+}
+
 /**
  * __cgroup_bpf_run_filter() - Run a program for packet filtering
  * @sk: The socken sending or receiving traffic
@@ -153,11 +166,15 @@ int __cgroup_bpf_run_filter(struct sock *sk,
 
 	prog = rcu_dereference(cgrp->bpf.effective[type]);
 	if (prog) {
-		unsigned int offset = skb->data - skb_network_header(skb);
-
-		__skb_push(skb, offset);
-		ret = bpf_prog_run_save_cb(prog, skb) == 1 ? 0 : -EPERM;
-		__skb_pull(skb, offset);
+		switch (type) {
+		case BPF_CGROUP_INET_INGRESS:
+		case BPF_CGROUP_INET_EGRESS:
+			ret = __cgroup_bpf_run_filter_skb(skb, prog);
+			break;
+		/* make gcc happy else complains about missing enum value */
+		default:
+			return 0;
+		}
 	}
 
 	rcu_read_unlock();
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index 1814c010ace6..3c4c9ed2d576 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -841,7 +841,7 @@ static int bpf_prog_attach(const union bpf_attr *attr)
 	case BPF_CGROUP_INET_INGRESS:
 	case BPF_CGROUP_INET_EGRESS:
 		prog = bpf_prog_get_type(attr->attach_bpf_fd,
-					 BPF_PROG_TYPE_CGROUP_SKB);
+					 BPF_PROG_TYPE_CGROUP);
 		if (IS_ERR(prog))
 			return PTR_ERR(prog);
 
diff --git a/net/core/filter.c b/net/core/filter.c
index 4552b8c93b99..61e229c3a862 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -2583,7 +2583,7 @@ xdp_func_proto(enum bpf_func_id func_id)
 }
 
 static const struct bpf_func_proto *
-cg_skb_func_proto(enum bpf_func_id func_id)
+cgroup_func_proto(enum bpf_func_id func_id)
 {
 	switch (func_id) {
 	case BPF_FUNC_skb_load_bytes:
@@ -2955,8 +2955,8 @@ static const struct bpf_verifier_ops xdp_ops = {
 	.convert_ctx_access	= xdp_convert_ctx_access,
 };
 
-static const struct bpf_verifier_ops cg_skb_ops = {
-	.get_func_proto		= cg_skb_func_proto,
+static const struct bpf_verifier_ops cgroup_ops = {
+	.get_func_proto		= cgroup_func_proto,
 	.is_valid_access	= sk_filter_is_valid_access,
 	.convert_ctx_access	= sk_filter_convert_ctx_access,
 };
@@ -2981,9 +2981,9 @@ static struct bpf_prog_type_list xdp_type __read_mostly = {
 	.type	= BPF_PROG_TYPE_XDP,
 };
 
-static struct bpf_prog_type_list cg_skb_type __read_mostly = {
-	.ops	= &cg_skb_ops,
-	.type	= BPF_PROG_TYPE_CGROUP_SKB,
+static struct bpf_prog_type_list cgroup_type __read_mostly = {
+	.ops	= &cgroup_ops,
+	.type	= BPF_PROG_TYPE_CGROUP,
 };
 
 static int __init register_sk_filter_ops(void)
@@ -2992,7 +2992,7 @@ static int __init register_sk_filter_ops(void)
 	bpf_register_prog_type(&sched_cls_type);
 	bpf_register_prog_type(&sched_act_type);
 	bpf_register_prog_type(&xdp_type);
-	bpf_register_prog_type(&cg_skb_type);
+	bpf_register_prog_type(&cgroup_type);
 
 	return 0;
 }
diff --git a/samples/bpf/test_cgrp2_attach.c b/samples/bpf/test_cgrp2_attach.c
index 63ef2083f766..468e68e6d511 100644
--- a/samples/bpf/test_cgrp2_attach.c
+++ b/samples/bpf/test_cgrp2_attach.c
@@ -69,8 +69,8 @@ static int prog_load(int map_fd, int verdict)
 		BPF_EXIT_INSN(),
 	};
 
-	return bpf_prog_load(BPF_PROG_TYPE_CGROUP_SKB,
-			     prog, sizeof(prog), "GPL", 0);
+	return bpf_prog_load(BPF_PROG_TYPE_CGROUP,
+			     prog, sizeof(prog), "GPL", 0, NULL);
 }
 
 static int usage(const char *argv0)
-- 
2.1.4
