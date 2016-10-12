From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH iproute2] tc: cls_bpf: handle skip_sw and skip_hw flags
Date: Wed, 12 Oct 2016 16:46:36 +0100
Message-ID: <1476287196-28931-1-git-send-email-jakub.kicinski@netronome.com>
Cc: daniel@iogearbox.net, Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f53.google.com ([209.85.213.53]:32793 "EHLO
        mail-vk0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933503AbcJLPq6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Oct 2016 11:46:58 -0400
Received: by mail-vk0-f53.google.com with SMTP id 83so25914100vkd.0
        for <netdev@vger.kernel.org>; Wed, 12 Oct 2016 08:46:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for controling hardware offload using (now standard)
skip_sw and skip_hw flags in cls_bpf.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
Hi Stephen!

This requires header rebase to get TCA_BPF_FLAGS_GEN in pkt_cls.h.
The patch is for 4.9 release so it is targeted at master branch.

Thanks!

 man/man8/tc-bpf.8 | 14 ++++++++++++++
 tc/f_bpf.c        | 21 +++++++++++++++++++--
 2 files changed, 33 insertions(+), 2 deletions(-)

diff --git a/man/man8/tc-bpf.8 b/man/man8/tc-bpf.8
index c8d5c5f94da8..e371964d06ab 100644
--- a/man/man8/tc-bpf.8
+++ b/man/man8/tc-bpf.8
@@ -14,6 +14,10 @@ CLS_NAME ] [
 UDS_FILE ] [
 .B verbose
 ] [
+.B skip_hw
+|
+.B skip_sw
+] [
 .B police
 POLICE_SPEC ] [
 .B action
@@ -137,6 +141,16 @@ if set, it will dump the eBPF verifier output, even if loading the eBPF
 program was successful. By default, only on error, the verifier log is
 being emitted to the user.
 
+.SS skip_hw | skip_sw
+hardware offload control flags. By default TC will try to offload
+filters to hardware if possible.
+.B skip_hw
+explicitly disables the attempt to offload.
+.B skip_sw
+forces the offload and disables running the eBPF program in the kernel.
+If hardware offload is not possible and this flag was set kernel will
+report an error and filter will not be installed at all.
+
 .SS police
 is an optional parameter for an eBPF/cBPF classifier that specifies a
 police in
diff --git a/tc/f_bpf.c b/tc/f_bpf.c
index 5c97c863d15a..665bc6612eeb 100644
--- a/tc/f_bpf.c
+++ b/tc/f_bpf.c
@@ -37,8 +37,8 @@ static void explain(void)
 	fprintf(stderr, "\n");
 	fprintf(stderr, "eBPF use case:\n");
 	fprintf(stderr, " object-file FILE [ section CLS_NAME ] [ export UDS_FILE ]");
-	fprintf(stderr, " [ verbose ] [ direct-action ]\n");
-	fprintf(stderr, " object-pinned FILE [ direct-action ]\n");
+	fprintf(stderr, " [ verbose ] [ direct-action ] [ skip_hw | skip_sw ]\n");
+	fprintf(stderr, " object-pinned FILE [ direct-action ] [ skip_hw | skip_sw ]\n");
 	fprintf(stderr, "\n");
 	fprintf(stderr, "Common remaining options:\n");
 	fprintf(stderr, " [ action ACTION_SPEC ]\n");
@@ -66,6 +66,7 @@ static int bpf_parse_opt(struct filter_util *qu, char *handle,
 {
 	const char *bpf_obj = NULL, *bpf_uds_name = NULL;
 	struct tcmsg *t = NLMSG_DATA(n);
+	unsigned int bpf_gen_flags = 0;
 	unsigned int bpf_flags = 0;
 	bool seen_run = false;
 	struct rtattr *tail;
@@ -107,6 +108,10 @@ static int bpf_parse_opt(struct filter_util *qu, char *handle,
 		} else if (matches(*argv, "direct-action") == 0 ||
 			   matches(*argv, "da") == 0) {
 			bpf_flags |= TCA_BPF_FLAG_ACT_DIRECT;
+		} else if (matches(*argv, "skip_hw") == 0) {
+			bpf_gen_flags |= TCA_CLS_FLAGS_SKIP_HW;
+		} else if (matches(*argv, "skip_sw") == 0) {
+			bpf_gen_flags |= TCA_CLS_FLAGS_SKIP_SW;
 		} else if (matches(*argv, "action") == 0) {
 			NEXT_ARG();
 			if (parse_action(&argc, &argv, TCA_BPF_ACT, n)) {
@@ -136,6 +141,8 @@ static int bpf_parse_opt(struct filter_util *qu, char *handle,
 		NEXT_ARG_FWD();
 	}
 
+	if (bpf_gen_flags)
+		addattr32(n, MAX_MSG, TCA_BPF_FLAGS_GEN, bpf_gen_flags);
 	if (bpf_obj && bpf_flags)
 		addattr32(n, MAX_MSG, TCA_BPF_FLAGS, bpf_flags);
 
@@ -178,6 +185,16 @@ static int bpf_print_opt(struct filter_util *qu, FILE *f,
 			fprintf(f, "direct-action ");
 	}
 
+	if (tb[TCA_BPF_FLAGS_GEN]) {
+		unsigned int flags =
+			rta_getattr_u32(tb[TCA_BPF_FLAGS_GEN]);
+
+		if (flags & TCA_CLS_FLAGS_SKIP_HW)
+			fprintf(f, "skip_hw ");
+		if (flags & TCA_CLS_FLAGS_SKIP_SW)
+			fprintf(f, "skip_sw ");
+	}
+
 	if (tb[TCA_BPF_OPS] && tb[TCA_BPF_OPS_LEN]) {
 		bpf_print_ops(f, tb[TCA_BPF_OPS],
 			      rta_getattr_u16(tb[TCA_BPF_OPS_LEN]));
-- 
1.9.1
