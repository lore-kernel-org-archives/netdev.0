From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH net-next 3/3] bpf: Append prog->aux->name in bpf_get_prog_name()
Date: Thu, 5 Oct 2017 21:52:13 -0700
Message-ID: <20171006045213.752372-4-kafai@fb.com>
References: <20171006045213.752372-1-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>, <kernel-team@fb.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:55746 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750863AbdJFEw3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Oct 2017 00:52:29 -0400
Received: from pps.filterd (m0109333.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v964oMaK000957
        for <netdev@vger.kernel.org>; Thu, 5 Oct 2017 21:52:29 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 2de2thr2b1-2
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 05 Oct 2017 21:52:29 -0700
In-Reply-To: <20171006045213.752372-1-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch makes the bpf_prog's name available
in kallsyms.

The new format is bpf_prog_tag[_name].

Sample kallsyms from running selftests/bpf/test_progs:
[root@arch-fb-vm1 ~]# egrep ' bpf_prog_[0-9a-fA-F]{16}' /proc/kallsyms
ffffffffa0048000 t bpf_prog_dabf0207d1992486_test_obj_id
ffffffffa0038000 t bpf_prog_a04f5eef06a7f555__123456789ABCDE
ffffffffa0050000 t bpf_prog_a04f5eef06a7f555

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@fb.com>
---
 kernel/bpf/core.c | 17 +++++++++++++++--
 1 file changed, 15 insertions(+), 2 deletions(-)

diff --git a/kernel/bpf/core.c b/kernel/bpf/core.c
index c6be15ae83ee..248961af2421 100644
--- a/kernel/bpf/core.c
+++ b/kernel/bpf/core.c
@@ -309,12 +309,25 @@ bpf_get_prog_addr_region(const struct bpf_prog *prog,
 
 static void bpf_get_prog_name(const struct bpf_prog *prog, char *sym)
 {
+	const char *end = sym + KSYM_NAME_LEN;
+
 	BUILD_BUG_ON(sizeof("bpf_prog_") +
-		     sizeof(prog->tag) * 2 + 1 > KSYM_NAME_LEN);
+		     sizeof(prog->tag) * 2 +
+		     /* name has been null terminated.
+		      * We should need +1 for the '_' preceding
+		      * the name.  However, the null character
+		      * is double counted between the name and the
+		      * sizeof("bpf_prog_") above, so we omit
+		      * the +1 here.
+		      */
+		     sizeof(prog->aux->name) > KSYM_NAME_LEN);
 
 	sym += snprintf(sym, KSYM_NAME_LEN, "bpf_prog_");
 	sym  = bin2hex(sym, prog->tag, sizeof(prog->tag));
-	*sym = 0;
+	if (prog->aux->name[0])
+		snprintf(sym, (size_t)(end - sym), "_%s", prog->aux->name);
+	else
+		*sym = 0;
 }
 
 static __always_inline unsigned long
-- 
2.9.5
