From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH v2 net-next 3/5] bpf: Add new cgroup attach type to enable sock modifications
Date: Wed, 26 Oct 2016 17:58:40 -0700
Message-ID: <1477529922-4806-4-git-send-email-dsa@cumulusnetworks.com>
References: <1477529922-4806-1-git-send-email-dsa@cumulusnetworks.com>
Cc: daniel@zonque.org, ast@fb.com, daniel@iogearbox.net,
        maheshb@google.com, tgraf@suug.ch,
        David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:36815 "EHLO
        mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932388AbcJ0A6w (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Oct 2016 20:58:52 -0400
Received: by mail-pf0-f174.google.com with SMTP id e6so6032545pfk.3
        for <netdev@vger.kernel.org>; Wed, 26 Oct 2016 17:58:52 -0700 (PDT)
In-Reply-To: <1477529922-4806-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow BPF_PROG_TYPE_CGROUP programs with cgroup.sock subtype to modify
sk_bound_dev_if for newly created AF_INET or AF_INET6 sockets. The program
can be attached to a cgroup using attach type BPF_CGROUP_INET_SOCK. The
cgroup verifier ops are updated to handle the sock offsets as well as the
existing skb accesses.

This allows a cgroup to be configured such that AF_INET{6} sockets opened
by processes are automatically bound to a specific device. In turn, this
enables the running of programs that do not support SO_BINDTODEVICE in a
specific VRF context / L3 domain.

v2
- dropped the bpf_sock_store_u32 helper
- dropped the new prog type BPF_PROG_TYPE_CGROUP_SOCK
- moved valid access and context conversion to use subtype
- dropped CREATE from BPF_CGROUP_INET_SOCK and related function names
- moved running of filter from sk_alloc to inet{6}_create

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 include/linux/filter.h   |  2 +-
 include/uapi/linux/bpf.h |  5 ++++
 kernel/bpf/cgroup.c      |  9 ++++++
 kernel/bpf/syscall.c     |  2 ++
 net/core/filter.c        | 77 ++++++++++++++++++++++++++++++++++++++++++++++--
 net/ipv4/af_inet.c       |  4 +++
 net/ipv6/af_inet6.c      |  3 ++
 7 files changed, 99 insertions(+), 3 deletions(-)

diff --git a/include/linux/filter.h b/include/linux/filter.h
index 88470cdd3ee1..ffde714f3a98 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -409,7 +409,7 @@ struct bpf_prog {
 	union bpf_prog_subtype	subtype;	/* For fine-grained verifications */
 	struct bpf_prog_aux	*aux;		/* Auxiliary fields */
 	struct sock_fprog_kern	*orig_prog;	/* Original BPF program */
-	unsigned int		(*bpf_func)(const struct sk_buff *skb,
+	unsigned int		(*bpf_func)(const void *ctx,
 					    const struct bpf_insn *filter);
 	/* Instructions for interpreter */
 	union {
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 160c24ffdce2..546e84b1792f 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -104,6 +104,7 @@ enum bpf_prog_type {
 enum bpf_attach_type {
 	BPF_CGROUP_INET_INGRESS,
 	BPF_CGROUP_INET_EGRESS,
+	BPF_CGROUP_INET_SOCK,
 	__MAX_BPF_ATTACH_TYPE
 };
 
@@ -532,6 +533,10 @@ struct bpf_tunnel_key {
 	__u32 tunnel_label;
 };
 
+struct bpf_sock {
+	__u32 bound_dev_if;
+};
+
 /* User return codes for XDP prog type.
  * A valid XDP program must return one of these defined values. All other
  * return codes are reserved for future use. Unknown return codes will result
diff --git a/kernel/bpf/cgroup.c b/kernel/bpf/cgroup.c
index d5746aec8f34..796e39aa28f5 100644
--- a/kernel/bpf/cgroup.c
+++ b/kernel/bpf/cgroup.c
@@ -117,6 +117,12 @@ void __cgroup_bpf_update(struct cgroup *cgrp,
 	}
 }
 
+static int __cgroup_bpf_run_filter_sock(struct sock *sk,
+					struct bpf_prog *prog)
+{
+	return prog->bpf_func(sk, prog->insnsi) == 1 ? 0 : -EPERM;
+}
+
 static int __cgroup_bpf_run_filter_skb(struct sk_buff *skb,
 				       struct bpf_prog *prog)
 {
@@ -171,6 +177,9 @@ int __cgroup_bpf_run_filter(struct sock *sk,
 		case BPF_CGROUP_INET_EGRESS:
 			ret = __cgroup_bpf_run_filter_skb(skb, prog);
 			break;
+		case BPF_CGROUP_INET_SOCK:
+			ret = __cgroup_bpf_run_filter_sock(sk, prog);
+			break;
 		/* make gcc happy else complains about missing enum value */
 		default:
 			return 0;
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index fbf81156e49d..bc3be0b19b57 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -843,6 +843,7 @@ static int bpf_prog_attach(const union bpf_attr *attr)
 	switch (attr->attach_type) {
 	case BPF_CGROUP_INET_INGRESS:
 	case BPF_CGROUP_INET_EGRESS:
+	case BPF_CGROUP_INET_SOCK:
 		prog = bpf_prog_get_type(attr->attach_bpf_fd,
 					 BPF_PROG_TYPE_CGROUP);
 		if (IS_ERR(prog))
@@ -880,6 +881,7 @@ static int bpf_prog_detach(const union bpf_attr *attr)
 	switch (attr->attach_type) {
 	case BPF_CGROUP_INET_INGRESS:
 	case BPF_CGROUP_INET_EGRESS:
+	case BPF_CGROUP_INET_SOCK:
 		cgrp = cgroup_get_from_fd(attr->target_fd);
 		if (IS_ERR(cgrp))
 			return PTR_ERR(cgrp);
diff --git a/net/core/filter.c b/net/core/filter.c
index 4207ab2e56ba..7193eb7fe892 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -2634,6 +2634,40 @@ static bool sk_filter_is_valid_access(int off, int size,
 	return __is_valid_access(off, size, type);
 }
 
+static bool sock_filter_is_valid_access(int off, int size,
+					enum bpf_access_type type)
+{
+	if (type == BPF_WRITE) {
+		switch (off) {
+		case offsetof(struct bpf_sock, bound_dev_if):
+			break;
+		default:
+			return false;
+		}
+	}
+
+	if (off < 0 || off + size > sizeof(struct bpf_sock))
+		return false;
+
+	/* The verifier guarantees that size > 0. */
+	if (off % size != 0)
+		return false;
+
+	return true;
+}
+
+static bool cgroup_is_valid_access(int off, int size,
+				   enum bpf_access_type type,
+				   enum bpf_reg_type *reg_type,
+				   union bpf_prog_subtype *prog_subtype)
+{
+	if (prog_subtype->cgroup.sock)
+		return sock_filter_is_valid_access(off, size, type);
+
+	return sk_filter_is_valid_access(off, size, type, reg_type,
+					 prog_subtype);
+}
+
 static int tc_cls_act_prologue(struct bpf_insn *insn_buf, bool direct_write,
 			       const struct bpf_prog *prog)
 {
@@ -2894,6 +2928,45 @@ static u32 sk_filter_convert_ctx_access(enum bpf_access_type type, int dst_reg,
 	return insn - insn_buf;
 }
 
+static u32 sock_filter_convert_ctx_access(enum bpf_access_type type,
+					  int dst_reg, int src_reg,
+					  int ctx_off,
+					  struct bpf_insn *insn_buf,
+					  struct bpf_prog *prog)
+{
+	struct bpf_insn *insn = insn_buf;
+
+	switch (ctx_off) {
+	case offsetof(struct bpf_sock, bound_dev_if):
+		BUILD_BUG_ON(FIELD_SIZEOF(struct sock, sk_bound_dev_if) != 4);
+
+		if (type == BPF_WRITE)
+			*insn++ = BPF_STX_MEM(BPF_W, dst_reg, src_reg,
+					offsetof(struct sock, sk_bound_dev_if));
+		else
+			*insn++ = BPF_LDX_MEM(BPF_W, dst_reg, src_reg,
+				      offsetof(struct sock, sk_bound_dev_if));
+		break;
+	}
+
+	return insn - insn_buf;
+}
+
+static u32 cgroup_convert_ctx_access(enum bpf_access_type type, int dst_reg,
+				     int src_reg, int ctx_off,
+				     struct bpf_insn *insn_buf,
+				     struct bpf_prog *prog)
+{
+	union bpf_prog_subtype *prog_subtype = &prog->subtype;
+
+	if (prog_subtype->cgroup.sock)
+		return sock_filter_convert_ctx_access(type, dst_reg, src_reg,
+						      ctx_off, insn_buf, prog);
+
+	return sk_filter_convert_ctx_access(type, dst_reg, src_reg, ctx_off,
+					    insn_buf, prog);
+}
+
 static u32 tc_cls_act_convert_ctx_access(enum bpf_access_type type, int dst_reg,
 					 int src_reg, int ctx_off,
 					 struct bpf_insn *insn_buf,
@@ -2963,8 +3036,8 @@ static const struct bpf_verifier_ops xdp_ops = {
 
 static const struct bpf_verifier_ops cgroup_ops = {
 	.get_func_proto		= cgroup_func_proto,
-	.is_valid_access	= sk_filter_is_valid_access,
-	.convert_ctx_access	= sk_filter_convert_ctx_access,
+	.is_valid_access	= cgroup_is_valid_access,
+	.convert_ctx_access	= cgroup_convert_ctx_access,
 };
 
 static struct bpf_prog_type_list sk_filter_type __read_mostly = {
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 1effc986739e..c0934f7483cb 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -377,6 +377,10 @@ static int inet_create(struct net *net, struct socket *sock, int protocol,
 		if (err)
 			sk_common_release(sk);
 	}
+
+	if (!kern)
+		cgroup_bpf_run_filter(sk, NULL, BPF_CGROUP_INET_SOCK);
+
 out:
 	return err;
 out_rcu_unlock:
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 46ad699937fd..c499ae3c472e 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -257,6 +257,9 @@ static int inet6_create(struct net *net, struct socket *sock, int protocol,
 			goto out;
 		}
 	}
+
+	if (!kern)
+		cgroup_bpf_run_filter(sk, NULL, BPF_CGROUP_INET_SOCK);
 out:
 	return err;
 out_rcu_unlock:
-- 
2.1.4
