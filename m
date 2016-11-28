From: Michael Holzheu <holzheu@linux.vnet.ibm.com>
Subject: [PATCH]  bpf/samples: Fix PT_REGS_IP on s390x and use it
Date: Mon, 28 Nov 2016 13:48:30 +0100
Message-ID: <20161128134830.44cd7c1f@TP-holzheu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <ast@kernel.org>, netdev@vger.kernel.org,
        Heiko Carstens <heiko.carstens@de.ibm.com>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:55090 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S932362AbcK1Msi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 07:48:38 -0500
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uASCiCF5053001
        for <netdev@vger.kernel.org>; Mon, 28 Nov 2016 07:48:38 -0500
Received: from e06smtp08.uk.ibm.com (e06smtp08.uk.ibm.com [195.75.94.104])
        by mx0a-001b2d01.pphosted.com with ESMTP id 270he4dsvp-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 28 Nov 2016 07:48:37 -0500
Received: from localhost
        by e06smtp08.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <holzheu@linux.vnet.ibm.com>;
        Mon, 28 Nov 2016 12:48:35 -0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The files "sampleip_kern.c" and "trace_event_kern.c" directly access
"ctx->regs.ip" which is not available on s390x. Fix this and use the
PT_REGS_IP() macro instead.

Also fix the macro for s390x and use "psw.addr" from "pt_regs".

Reported-by: Zvonko Kosic <zvonko.kosic@de.ibm.com>
Signed-off-by: Michael Holzheu <holzheu@linux.vnet.ibm.com>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 samples/bpf/bpf_helpers.h      | 2 +-
 samples/bpf/sampleip_kern.c    | 2 +-
 samples/bpf/trace_event_kern.c | 2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/samples/bpf/bpf_helpers.h b/samples/bpf/bpf_helpers.h
index 90f44bd..dadd516 100644
--- a/samples/bpf/bpf_helpers.h
+++ b/samples/bpf/bpf_helpers.h
@@ -113,7 +113,7 @@ static int (*bpf_skb_under_cgroup)(void *ctx, void *map, int index) =
 #define PT_REGS_FP(x) ((x)->gprs[11]) /* Works only with CONFIG_FRAME_POINTER */
 #define PT_REGS_RC(x) ((x)->gprs[2])
 #define PT_REGS_SP(x) ((x)->gprs[15])
-#define PT_REGS_IP(x) ((x)->ip)
+#define PT_REGS_IP(x) ((x)->psw.addr)
 
 #elif defined(__aarch64__)
 
diff --git a/samples/bpf/sampleip_kern.c b/samples/bpf/sampleip_kern.c
index 774a681..ceabf31 100644
--- a/samples/bpf/sampleip_kern.c
+++ b/samples/bpf/sampleip_kern.c
@@ -25,7 +25,7 @@ int do_sample(struct bpf_perf_event_data *ctx)
 	u64 ip;
 	u32 *value, init_val = 1;
 
-	ip = ctx->regs.ip;
+	ip = PT_REGS_IP(&ctx->regs);
 	value = bpf_map_lookup_elem(&ip_map, &ip);
 	if (value)
 		*value += 1;
diff --git a/samples/bpf/trace_event_kern.c b/samples/bpf/trace_event_kern.c
index 71a8ed3..41b6115 100644
--- a/samples/bpf/trace_event_kern.c
+++ b/samples/bpf/trace_event_kern.c
@@ -50,7 +50,7 @@ int bpf_prog1(struct bpf_perf_event_data *ctx)
 	key.userstack = bpf_get_stackid(ctx, &stackmap, USER_STACKID_FLAGS);
 	if ((int)key.kernstack < 0 && (int)key.userstack < 0) {
 		bpf_trace_printk(fmt, sizeof(fmt), cpu, ctx->sample_period,
-				 ctx->regs.ip);
+				 PT_REGS_IP(&ctx->regs));
 		return 0;
 	}
 
-- 
2.8.4
