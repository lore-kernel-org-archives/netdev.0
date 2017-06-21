From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next] bpf: expose prog id for cls_bpf and act_bpf
Date: Wed, 21 Jun 2017 20:16:11 +0200
Message-ID: <66b50f95666de97e7f067471d409fce8d316ad43.1498068442.git.daniel@iogearbox.net>
Cc: john.fastabend@gmail.com, kafai@fb.com, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:58737 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751754AbdFUSQW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Jun 2017 14:16:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In order to be able to retrieve the attached programs from cls_bpf
and act_bpf, we need to expose the prog ids via netlink so that
an application can later on get an fd based on the id through the
BPF_PROG_GET_FD_BY_ID command, and dump related prog info via
BPF_OBJ_GET_INFO_BY_FD command for bpf(2).

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 include/uapi/linux/pkt_cls.h       | 1 +
 include/uapi/linux/tc_act/tc_bpf.h | 1 +
 net/sched/act_bpf.c                | 3 +++
 net/sched/cls_bpf.c                | 3 +++
 4 files changed, 8 insertions(+)

diff --git a/include/uapi/linux/pkt_cls.h b/include/uapi/linux/pkt_cls.h
index 2055783..d5e2bf6 100644
--- a/include/uapi/linux/pkt_cls.h
+++ b/include/uapi/linux/pkt_cls.h
@@ -369,6 +369,7 @@ enum {
 	TCA_BPF_FLAGS,
 	TCA_BPF_FLAGS_GEN,
 	TCA_BPF_TAG,
+	TCA_BPF_ID,
 	__TCA_BPF_MAX,
 };
 
diff --git a/include/uapi/linux/tc_act/tc_bpf.h b/include/uapi/linux/tc_act/tc_bpf.h
index 975b50d..8dc2ac0 100644
--- a/include/uapi/linux/tc_act/tc_bpf.h
+++ b/include/uapi/linux/tc_act/tc_bpf.h
@@ -28,6 +28,7 @@ enum {
 	TCA_ACT_BPF_NAME,
 	TCA_ACT_BPF_PAD,
 	TCA_ACT_BPF_TAG,
+	TCA_ACT_BPF_ID,
 	__TCA_ACT_BPF_MAX,
 };
 #define TCA_ACT_BPF_MAX (__TCA_ACT_BPF_MAX - 1)
diff --git a/net/sched/act_bpf.c b/net/sched/act_bpf.c
index d33947d..9afe133 100644
--- a/net/sched/act_bpf.c
+++ b/net/sched/act_bpf.c
@@ -123,6 +123,9 @@ static int tcf_bpf_dump_ebpf_info(const struct tcf_bpf *prog,
 	    nla_put_string(skb, TCA_ACT_BPF_NAME, prog->bpf_name))
 		return -EMSGSIZE;
 
+	if (nla_put_u32(skb, TCA_ACT_BPF_ID, prog->filter->aux->id))
+		return -EMSGSIZE;
+
 	nla = nla_reserve(skb, TCA_ACT_BPF_TAG, sizeof(prog->filter->tag));
 	if (nla == NULL)
 		return -EMSGSIZE;
diff --git a/net/sched/cls_bpf.c b/net/sched/cls_bpf.c
index be0cfdf..f57bd53 100644
--- a/net/sched/cls_bpf.c
+++ b/net/sched/cls_bpf.c
@@ -566,6 +566,9 @@ static int cls_bpf_dump_ebpf_info(const struct cls_bpf_prog *prog,
 	    nla_put_string(skb, TCA_BPF_NAME, prog->bpf_name))
 		return -EMSGSIZE;
 
+	if (nla_put_u32(skb, TCA_BPF_ID, prog->filter->aux->id))
+		return -EMSGSIZE;
+
 	nla = nla_reserve(skb, TCA_BPF_TAG, sizeof(prog->filter->tag));
 	if (nla == NULL)
 		return -EMSGSIZE;
-- 
1.9.3
