From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next v3 1/3] bpf: Refactor cgroups code in prep for new type
Date: Mon, 28 Nov 2016 07:48:48 -0800
Message-ID: <1480348130-31354-2-git-send-email-dsa@cumulusnetworks.com>
References: <1480348130-31354-1-git-send-email-dsa@cumulusnetworks.com>
Cc: daniel@zonque.org, ast@fb.com, daniel@iogearbox.net,
        maheshb@google.com, tgraf@suug.ch,
        David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:35168 "EHLO
        mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754549AbcK1Ps5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 10:48:57 -0500
Received: by mail-pf0-f173.google.com with SMTP id i88so25535202pfk.2
        for <netdev@vger.kernel.org>; Mon, 28 Nov 2016 07:48:57 -0800 (PST)
In-Reply-To: <1480348130-31354-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Code move only; no functional change intended.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
v3
- dropped the rename

v2
- fix bpf_prog_run_clear_cb to bpf_prog_run_save_cb as caught by Daniel

- rename BPF_PROG_TYPE_CGROUP_SKB and its cg_skb functions to
  BPF_PROG_TYPE_CGROUP and cgroup

 kernel/bpf/cgroup.c  | 27 ++++++++++++++++++++++-----
 kernel/bpf/syscall.c | 28 +++++++++++++++-------------
 2 files changed, 37 insertions(+), 18 deletions(-)

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
index 1090d16a31c1..c2bce596e842 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -843,6 +843,7 @@ static int bpf_prog_attach(const union bpf_attr *attr)
 {
 	struct bpf_prog *prog;
 	struct cgroup *cgrp;
+	enum bpf_prog_type ptype;
 
 	if (!capable(CAP_NET_ADMIN))
 		return -EPERM;
@@ -853,25 +854,26 @@ static int bpf_prog_attach(const union bpf_attr *attr)
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
