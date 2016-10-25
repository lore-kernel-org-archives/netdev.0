From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 1/3] bpf: Refactor cgroups code in prep for new type
Date: Tue, 25 Oct 2016 15:30:11 -0700
Message-ID: <1477434613-3169-2-git-send-email-dsa@cumulusnetworks.com>
References: <1477434613-3169-1-git-send-email-dsa@cumulusnetworks.com>
Cc: daniel@zonque.org, ast@fb.com, daniel@iogearbox.net,
        David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:36824 "EHLO
        mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S942120AbcJYWb0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Oct 2016 18:31:26 -0400
Received: by mail-pf0-f171.google.com with SMTP id e6so126364396pfk.3
        for <netdev@vger.kernel.org>; Tue, 25 Oct 2016 15:31:25 -0700 (PDT)
In-Reply-To: <1477434613-3169-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Code move only; no functional change intended.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 kernel/bpf/cgroup.c  | 27 ++++++++++++++++++++++-----
 kernel/bpf/syscall.c | 28 +++++++++++++++-------------
 2 files changed, 37 insertions(+), 18 deletions(-)

diff --git a/kernel/bpf/cgroup.c b/kernel/bpf/cgroup.c
index a0ab43f264b0..918c01a6f129 100644
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
+	ret = bpf_prog_run_clear_cb(prog, skb) == 1 ? 0 : -EPERM;
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
index 1814c010ace6..9abc88deabbc 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -828,6 +828,7 @@ static int bpf_obj_get(const union bpf_attr *attr)
 
 static int bpf_prog_attach(const union bpf_attr *attr)
 {
+	enum bpf_prog_type ptype = BPF_PROG_TYPE_UNSPEC;
 	struct bpf_prog *prog;
 	struct cgroup *cgrp;
 
@@ -840,25 +841,26 @@ static int bpf_prog_attach(const union bpf_attr *attr)
 	switch (attr->attach_type) {
 	case BPF_CGROUP_INET_INGRESS:
 	case BPF_CGROUP_INET_EGRESS:
-		prog = bpf_prog_get_type(attr->attach_bpf_fd,
-					 BPF_PROG_TYPE_CGROUP_SKB);
-		if (IS_ERR(prog))
-			return PTR_ERR(prog);
-
-		cgrp = cgroup_get_from_fd(attr->target_fd);
-		if (IS_ERR(cgrp)) {
-			bpf_prog_put(prog);
-			return PTR_ERR(cgrp);
-		}
-
-		cgroup_bpf_update(cgrp, prog, attr->attach_type);
-		cgroup_put(cgrp);
+		ptype = BPF_PROG_TYPE_CGROUP_SKB;
 		break;
 
 	default:
 		return -EINVAL;
 	}
 
+	prog = bpf_prog_get_type(attr->attach_bpf_fd, ptype);
+	if (IS_ERR(prog))
+		return PTR_ERR(prog);
+
+	cgrp = cgroup_get_from_fd(attr->target_fd);
+	if (IS_ERR(cgrp)) {
+		bpf_prog_put(prog);
+		return PTR_ERR(cgrp);
+	}
+
+	cgroup_bpf_update(cgrp, prog, attr->attach_type);
+	cgroup_put(cgrp);
+
 	return 0;
 }
 
-- 
2.1.4
