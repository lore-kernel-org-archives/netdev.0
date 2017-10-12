From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 01/12] bpf: verifier: set reg_type on context accesses in second pass
Date: Thu, 12 Oct 2017 10:34:07 -0700
Message-ID: <20171012173418.4029-2-jakub.kicinski@netronome.com>
References: <20171012173418.4029-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>,
        alexei.starovoitov@gmail.com, daniel@iogearbox.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:54261 "EHLO
        mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752673AbdJLReu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2017 13:34:50 -0400
Received: by mail-pf0-f179.google.com with SMTP id t188so3330122pfd.10
        for <netdev@vger.kernel.org>; Thu, 12 Oct 2017 10:34:49 -0700 (PDT)
In-Reply-To: <20171012173418.4029-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use a simplified is_valid_access() callback when verifier
is used for program analysis by non-host JITs.  This allows
us to teach the verifier about packet start and packet end
offsets for direct packet access.

We can extend the callback as needed but for most packet
processing needs there isn't much more the offloads may
require.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
---
CC: alexei.starovoitov@gmail.com
CC: daniel@iogearbox.net

 kernel/bpf/verifier.c | 43 +++++++++++++++++++++++++++++++++++++------
 1 file changed, 37 insertions(+), 6 deletions(-)

diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 2cdbcc4f8f6b..9755279d94cb 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -813,6 +813,36 @@ static int check_packet_access(struct bpf_verifier_env *env, u32 regno, int off,
 	return err;
 }
 
+static bool analyzer_is_valid_access(struct bpf_verifier_env *env, int off,
+				     struct bpf_insn_access_aux *info)
+{
+	switch (env->prog->type) {
+	case BPF_PROG_TYPE_XDP:
+		switch (off) {
+		case offsetof(struct xdp_buff, data):
+			info->reg_type = PTR_TO_PACKET;
+			return true;
+		case offsetof(struct xdp_buff, data_end):
+			info->reg_type = PTR_TO_PACKET_END;
+			return true;
+		}
+		return false;
+	case BPF_PROG_TYPE_SCHED_CLS:
+		switch (off) {
+		case offsetof(struct sk_buff, data):
+			info->reg_type = PTR_TO_PACKET;
+			return true;
+		case offsetof(struct sk_buff, cb) +
+		     offsetof(struct bpf_skb_data_end, data_end):
+			info->reg_type = PTR_TO_PACKET_END;
+			return true;
+		}
+		return false;
+	default:
+		return false;
+	}
+}
+
 /* check access to 'struct bpf_context' fields.  Supports fixed offsets only */
 static int check_ctx_access(struct bpf_verifier_env *env, int insn_idx, int off, int size,
 			    enum bpf_access_type t, enum bpf_reg_type *reg_type)
@@ -821,12 +851,13 @@ static int check_ctx_access(struct bpf_verifier_env *env, int insn_idx, int off,
 		.reg_type = *reg_type,
 	};
 
-	/* for analyzer ctx accesses are already validated and converted */
-	if (env->analyzer_ops)
-		return 0;
-
-	if (env->prog->aux->ops->is_valid_access &&
-	    env->prog->aux->ops->is_valid_access(off, size, t, &info)) {
+	if (env->analyzer_ops) {
+		if (analyzer_is_valid_access(env, off, &info)) {
+			*reg_type = info.reg_type;
+			return 0;
+		}
+	} else if (env->prog->aux->ops->is_valid_access &&
+		   env->prog->aux->ops->is_valid_access(off, size, t, &info)) {
 		/* A non zero info.ctx_field_size indicates that this field is a
 		 * candidate for later verifier transformation to load the whole
 		 * field and then apply a mask when accessed with a narrower
-- 
2.14.1
