From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 2/6] bpf: drop useless bpf_fd member from cls/act
Date: Sat, 26 Nov 2016 01:28:05 +0100
Message-ID: <60f45678dfc817f6d265bbd08ebaf882b3c749da.1480119396.git.daniel@iogearbox.net>
References: <cover.1480119395.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:42847 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751634AbcKZA2o (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Nov 2016 19:28:44 -0500
In-Reply-To: <cover.1480119395.git.daniel@iogearbox.net>
In-Reply-To: <cover.1480119395.git.daniel@iogearbox.net>
References: <cover.1480119395.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After setup we don't need to keep user space fd number around anymore, as
it also has no useful meaning for anyone, just remove it.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 net/sched/act_bpf.c | 7 -------
 net/sched/cls_bpf.c | 9 +--------
 2 files changed, 1 insertion(+), 15 deletions(-)

diff --git a/net/sched/act_bpf.c b/net/sched/act_bpf.c
index 1aa4ecf..84c1d2d 100644
--- a/net/sched/act_bpf.c
+++ b/net/sched/act_bpf.c
@@ -28,7 +28,6 @@ struct tcf_bpf_cfg {
 	struct bpf_prog *filter;
 	struct sock_filter *bpf_ops;
 	const char *bpf_name;
-	u32 bpf_fd;
 	u16 bpf_num_ops;
 	bool is_ebpf;
 };
@@ -118,9 +117,6 @@ static int tcf_bpf_dump_bpf_info(const struct tcf_bpf *prog,
 static int tcf_bpf_dump_ebpf_info(const struct tcf_bpf *prog,
 				  struct sk_buff *skb)
 {
-	if (nla_put_u32(skb, TCA_ACT_BPF_FD, prog->bpf_fd))
-		return -EMSGSIZE;
-
 	if (prog->bpf_name &&
 	    nla_put_string(skb, TCA_ACT_BPF_NAME, prog->bpf_name))
 		return -EMSGSIZE;
@@ -233,7 +229,6 @@ static int tcf_bpf_init_from_efd(struct nlattr **tb, struct tcf_bpf_cfg *cfg)
 		}
 	}
 
-	cfg->bpf_fd = bpf_fd;
 	cfg->bpf_name = name;
 	cfg->filter = fp;
 	cfg->is_ebpf = true;
@@ -332,8 +327,6 @@ static int tcf_bpf_init(struct net *net, struct nlattr *nla,
 
 	if (cfg.bpf_num_ops)
 		prog->bpf_num_ops = cfg.bpf_num_ops;
-	if (cfg.bpf_fd)
-		prog->bpf_fd = cfg.bpf_fd;
 
 	prog->tcf_action = parm->action;
 	rcu_assign_pointer(prog->filter, cfg.filter);
diff --git a/net/sched/cls_bpf.c b/net/sched/cls_bpf.c
index 52dc85a..28cb5fa 100644
--- a/net/sched/cls_bpf.c
+++ b/net/sched/cls_bpf.c
@@ -45,10 +45,7 @@ struct cls_bpf_prog {
 	u32 gen_flags;
 	struct tcf_exts exts;
 	u32 handle;
-	union {
-		u32 bpf_fd;
-		u16 bpf_num_ops;
-	};
+	u16 bpf_num_ops;
 	struct sock_filter *bpf_ops;
 	const char *bpf_name;
 	struct tcf_proto *tp;
@@ -377,7 +374,6 @@ static int cls_bpf_prog_from_efd(struct nlattr **tb, struct cls_bpf_prog *prog,
 	}
 
 	prog->bpf_ops = NULL;
-	prog->bpf_fd = bpf_fd;
 	prog->bpf_name = name;
 	prog->filter = fp;
 
@@ -561,9 +557,6 @@ static int cls_bpf_dump_bpf_info(const struct cls_bpf_prog *prog,
 static int cls_bpf_dump_ebpf_info(const struct cls_bpf_prog *prog,
 				  struct sk_buff *skb)
 {
-	if (nla_put_u32(skb, TCA_BPF_FD, prog->bpf_fd))
-		return -EMSGSIZE;
-
 	if (prog->bpf_name &&
 	    nla_put_string(skb, TCA_BPF_NAME, prog->bpf_name))
 		return -EMSGSIZE;
-- 
1.9.3
