From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 2/2] ebpf: add helper to retrieve net_cls's classid cookie
Date: Wed, 15 Jul 2015 14:21:42 +0200
Message-ID: <9862a6b8778d344e8e10380060f09b161caac12f.1436961536.git.daniel@iogearbox.net>
References: <cover.1436961536.git.daniel@iogearbox.net>
Cc: ast@plumgrid.com, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>,
	Thomas Graf <tgraf@suug.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:37690 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752900AbbGOMVr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jul 2015 08:21:47 -0400
In-Reply-To: <cover.1436961536.git.daniel@iogearbox.net>
In-Reply-To: <cover.1436961536.git.daniel@iogearbox.net>
References: <cover.1436961536.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It would be very useful to retrieve the net_cls's classid from an eBPF
program to allow for a more fine-grained classification, it could be
directly used or in conjunction with additional policies. I.e. docker,
but also tooling such as cgexec, can easily run applications via net_cls
cgroups:

  cgcreate -g net_cls:/foo
  echo 42 > foo/net_cls.classid
  cgexec -g net_cls:foo <prog>

Thus, their respecitve classid cookie of foo can then be looked up on
the egress path to apply further policies. The helper is desigend such
that a non-zero value returns the cgroup id.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Cc: Thomas Graf <tgraf@suug.ch>
---
 include/uapi/linux/bpf.h |  7 +++++++
 net/core/filter.c        | 15 +++++++++++++++
 2 files changed, 22 insertions(+)

diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 29ef6f9..2de87e5 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -249,6 +249,13 @@ enum bpf_func_id {
 	 * Return: 0 on success
 	 */
 	BPF_FUNC_get_current_comm,
+
+	/**
+	 * bpf_get_cgroup_classid(skb) - retrieve a proc's classid
+	 * @skb: pointer to skb
+	 * Return: classid if != 0
+	 */
+	BPF_FUNC_get_cgroup_classid,
 	__BPF_FUNC_MAX_ID,
 };
 
diff --git a/net/core/filter.c b/net/core/filter.c
index be3098f..247450a 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -47,6 +47,7 @@
 #include <linux/if_vlan.h>
 #include <linux/bpf.h>
 #include <net/sch_generic.h>
+#include <net/cls_cgroup.h>
 
 /**
  *	sk_filter - run a packet through a socket filter
@@ -1424,6 +1425,18 @@ const struct bpf_func_proto bpf_clone_redirect_proto = {
 	.arg3_type      = ARG_ANYTHING,
 };
 
+static u64 bpf_get_cgroup_classid(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
+{
+	return task_get_classid((struct sk_buff *) (unsigned long) r1);
+}
+
+static const struct bpf_func_proto bpf_get_cgroup_classid_proto = {
+	.func           = bpf_get_cgroup_classid,
+	.gpl_only       = false,
+	.ret_type       = RET_INTEGER,
+	.arg1_type      = ARG_PTR_TO_CTX,
+};
+
 static const struct bpf_func_proto *
 sk_filter_func_proto(enum bpf_func_id func_id)
 {
@@ -1461,6 +1474,8 @@ tc_cls_act_func_proto(enum bpf_func_id func_id)
 		return &bpf_l4_csum_replace_proto;
 	case BPF_FUNC_clone_redirect:
 		return &bpf_clone_redirect_proto;
+	case BPF_FUNC_get_cgroup_classid:
+		return &bpf_get_cgroup_classid_proto;
 	default:
 		return sk_filter_func_proto(func_id);
 	}
-- 
1.9.3
