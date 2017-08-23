From: David Ahern <dsahern@gmail.com>
Subject: [PATCH net-next 8/8] samples/bpf: Update cgroup socket examples to use uid gid helper
Date: Tue, 22 Aug 2017 17:20:21 -0700
Message-ID: <1503447621-27997-9-git-send-email-dsahern@gmail.com>
References: <1503447621-27997-1-git-send-email-dsahern@gmail.com>
Cc: David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org, daniel@iogearbox.net, ast@kernel.org,
        tj@kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:33662 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752875AbdHWAUg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2017 20:20:36 -0400
Received: by mail-pg0-f67.google.com with SMTP id u191so227081pgc.0
        for <netdev@vger.kernel.org>; Tue, 22 Aug 2017 17:20:36 -0700 (PDT)
In-Reply-To: <1503447621-27997-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: David Ahern <dsahern@gmail.com>
---
 samples/bpf/sock_flags_kern.c |  5 +++++
 samples/bpf/test_cgrp2_sock.c | 12 +++++++++++-
 2 files changed, 16 insertions(+), 1 deletion(-)

diff --git a/samples/bpf/sock_flags_kern.c b/samples/bpf/sock_flags_kern.c
index 533dd11a6baa..05dcdf8a4baa 100644
--- a/samples/bpf/sock_flags_kern.c
+++ b/samples/bpf/sock_flags_kern.c
@@ -9,8 +9,13 @@ SEC("cgroup/sock1")
 int bpf_prog1(struct bpf_sock *sk)
 {
 	char fmt[] = "socket: family %d type %d protocol %d\n";
+	char fmt2[] = "socket: uid %u gid %u\n";
+	__u64 gid_uid = bpf_get_current_uid_gid();
+	__u32 uid = gid_uid & 0xffffffff;
+	__u32 gid = gid_uid >> 32;
 
 	bpf_trace_printk(fmt, sizeof(fmt), sk->family, sk->type, sk->protocol);
+	bpf_trace_printk(fmt2, sizeof(fmt2), uid, gid);
 
 	/* block PF_INET6, SOCK_RAW, IPPROTO_ICMPV6 sockets
 	 * ie., make ping6 fail
diff --git a/samples/bpf/test_cgrp2_sock.c b/samples/bpf/test_cgrp2_sock.c
index 5e3f605ed3b3..580d4d573826 100644
--- a/samples/bpf/test_cgrp2_sock.c
+++ b/samples/bpf/test_cgrp2_sock.c
@@ -46,8 +46,18 @@ static int prog_load(__u32 idx, __u32 mark, __u32 prio)
 
 	/* set mark on socket */
 	struct bpf_insn prog_mark[] = {
-		BPF_MOV64_REG(BPF_REG_1, BPF_REG_6),
+		/* get uid of process */
+		BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0,
+			     BPF_FUNC_get_current_uid_gid),
+		BPF_ALU64_IMM(BPF_AND, BPF_REG_0, 0xffffffff),
+
+		/* if uid is 0, use given mark, else use the uid as the mark */
+		BPF_MOV64_REG(BPF_REG_3, BPF_REG_0),
+		BPF_JMP_IMM(BPF_JNE, BPF_REG_0, 0, 1),
 		BPF_MOV64_IMM(BPF_REG_3, mark),
+
+		/* set the mark on the new socket */
+		BPF_MOV64_REG(BPF_REG_1, BPF_REG_6),
 		BPF_MOV64_IMM(BPF_REG_2, offsetof(struct bpf_sock, mark)),
 		BPF_STX_MEM(BPF_W, BPF_REG_1, BPF_REG_3, offsetof(struct bpf_sock, mark)),
 	};
-- 
2.1.4
