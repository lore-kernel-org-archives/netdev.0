From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [RFC 06/12] cls_bpf: allow attaching programs loaded for specific device
Date: Tue, 31 Oct 2017 18:52:11 -0700
Message-ID: <20171101015217.10666-7-jakub.kicinski@netronome.com>
References: <20171101015217.10666-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com, alexei.starovoitov@gmail.com,
        daniel@iogearbox.net, bblanco@gmail.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:52818 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932849AbdKABxE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 21:53:04 -0400
Received: by mail-pg0-f67.google.com with SMTP id a192so790257pge.9
        for <netdev@vger.kernel.org>; Tue, 31 Oct 2017 18:53:04 -0700 (PDT)
In-Reply-To: <20171101015217.10666-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If TC program is loaded with skip_sw flag, we should allow
the device-specific programs to be accepted.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
Reviewed-by: Quentin Monnet <quentin.monnet@netronome.com>
---
 kernel/bpf/syscall.c |  1 +
 net/sched/cls_bpf.c  | 10 +++++++---
 2 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index 8c988025c8d3..efbcd87b029f 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -1115,6 +1115,7 @@ struct bpf_prog *bpf_prog_get_type_dev(u32 ufd, enum bpf_prog_type type,
 		trace_bpf_prog_get_type(prog);
 	return prog;
 }
+EXPORT_SYMBOL_GPL(bpf_prog_get_type_dev);
 
 /* last field in 'union bpf_attr' used by this command */
 #define	BPF_PROG_LOAD_LAST_FIELD prog_ifindex
diff --git a/net/sched/cls_bpf.c b/net/sched/cls_bpf.c
index 5f701c8670a2..30442a20fe11 100644
--- a/net/sched/cls_bpf.c
+++ b/net/sched/cls_bpf.c
@@ -374,7 +374,7 @@ static int cls_bpf_prog_from_ops(struct nlattr **tb, struct cls_bpf_prog *prog)
 }
 
 static int cls_bpf_prog_from_efd(struct nlattr **tb, struct cls_bpf_prog *prog,
-				 const struct tcf_proto *tp)
+				 u32 gen_flags, const struct tcf_proto *tp)
 {
 	struct bpf_prog *fp;
 	char *name = NULL;
@@ -382,7 +382,11 @@ static int cls_bpf_prog_from_efd(struct nlattr **tb, struct cls_bpf_prog *prog,
 
 	bpf_fd = nla_get_u32(tb[TCA_BPF_FD]);
 
-	fp = bpf_prog_get_type(bpf_fd, BPF_PROG_TYPE_SCHED_CLS);
+	if (gen_flags & TCA_CLS_FLAGS_SKIP_SW)
+		fp = bpf_prog_get_type_dev(bpf_fd, BPF_PROG_TYPE_SCHED_CLS,
+					   qdisc_dev(tp->q));
+	else
+		fp = bpf_prog_get_type(bpf_fd, BPF_PROG_TYPE_SCHED_CLS);
 	if (IS_ERR(fp))
 		return PTR_ERR(fp);
 
@@ -440,7 +444,7 @@ static int cls_bpf_set_parms(struct net *net, struct tcf_proto *tp,
 	prog->gen_flags = gen_flags;
 
 	ret = is_bpf ? cls_bpf_prog_from_ops(tb, prog) :
-		       cls_bpf_prog_from_efd(tb, prog, tp);
+		       cls_bpf_prog_from_efd(tb, prog, gen_flags, tp);
 	if (ret < 0)
 		return ret;
 
-- 
2.14.1
