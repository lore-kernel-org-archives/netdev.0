From: Chema Gonzalez <chema@google.com>
Subject: [PATCH v5 net-next 3/3] net: filter: add insn for loading internal transport header proto
Date: Fri, 16 May 2014 11:41:52 -0700
Message-ID: <1400265712-10423-1-git-send-email-chema@google.com>
References: <1398882591-30422-1-git-send-email-chema@google.com>
Cc: netdev@vger.kernel.org, Chema Gonzalez <chema@google.com>
To: David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Alexei Starovoitov <ast@plumgrid.com>, dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f201.google.com ([209.85.216.201]:59979 "EHLO
	mail-qc0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757903AbaEPSly (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2014 14:41:54 -0400
Received: by mail-qc0-f201.google.com with SMTP id l6so505708qcy.2
        for <netdev@vger.kernel.org>; Fri, 16 May 2014 11:41:54 -0700 (PDT)
In-Reply-To: <1398882591-30422-1-git-send-email-chema@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patch adds an ANC_TRA_PROTOCOL insn that loads the protocol of
the internal transport header of a packet ("internal" meaning after
decapsulation by the flow dissector).

Signed-off-by: Chema Gonzalez <chema@google.com>
---
 include/linux/filter.h      |  1 +
 include/uapi/linux/filter.h |  3 ++-
 net/core/filter.c           | 20 ++++++++++++++++++++
 tools/net/bpf_exp.l         |  1 +
 tools/net/bpf_exp.y         | 11 ++++++++++-
 5 files changed, 34 insertions(+), 2 deletions(-)

diff --git a/include/linux/filter.h b/include/linux/filter.h
index 7af9410..1d7d68e 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -310,6 +310,7 @@ enum {
 	BPF_S_ANC_PAY_OFFSET,
 	BPF_S_ANC_RANDOM,
 	BPF_S_ANC_TRA_OFFSET,
+	BPF_S_ANC_TRA_PROTOCOL,
 };
 
 #endif /* __LINUX_FILTER_H__ */
diff --git a/include/uapi/linux/filter.h b/include/uapi/linux/filter.h
index 9f1b8f1..e34d608 100644
--- a/include/uapi/linux/filter.h
+++ b/include/uapi/linux/filter.h
@@ -132,7 +132,8 @@ struct sock_fprog {	/* Required for SO_ATTACH_FILTER. */
 #define SKF_AD_PAY_OFFSET	52
 #define SKF_AD_RANDOM	56
 #define SKF_AD_TRA_OFFSET	60
-#define SKF_AD_MAX	64
+#define SKF_AD_TRA_PROTOCOL	64
+#define SKF_AD_MAX	68
 #define SKF_NET_OFF   (-0x100000)
 #define SKF_LL_OFF    (-0x200000)
 
diff --git a/net/core/filter.c b/net/core/filter.c
index edaf03f..7245a0d 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -639,6 +639,20 @@ static u64 __skb_get_tra_offset(u64 ctx, u64 a, u64 x, u64 r4, u64 r5)
 	return context->flow.thoff;
 }
 
+static u64 __skb_get_tra_protocol(u64 ctx, u64 a, u64 x, u64 r4, u64 r5)
+{
+	struct sk_run_filter_ctx *context = (void *) r4 - BPF_MEMWORDS * 4 -
+			sizeof(*context);
+	/* check whether the flow dissector has already been run */
+	if (!context->flow_initted) {
+		if (!skb_flow_dissect((struct sk_buff *)(unsigned long) ctx,
+				&context->flow))
+			return 0;
+		context->flow_initted = true;
+	}
+	return context->flow.ip_proto;
+}
+
 static u64 __skb_get_nlattr(u64 ctx, u64 a, u64 x, u64 r4, u64 r5)
 {
 	struct sk_buff *skb = (struct sk_buff *)(unsigned long) ctx;
@@ -806,6 +820,7 @@ static bool convert_bpf_extensions(struct sock_filter *fp,
 	case SKF_AD_OFF + SKF_AD_CPU:
 	case SKF_AD_OFF + SKF_AD_RANDOM:
 	case SKF_AD_OFF + SKF_AD_TRA_OFFSET:
+	case SKF_AD_OFF + SKF_AD_TRA_PROTOCOL:
 		/* arg1 = ctx */
 		*insn = BPF_ALU64_REG(BPF_MOV, BPF_REG_ARG1, BPF_REG_CTX);
 		insn++;
@@ -843,6 +858,9 @@ static bool convert_bpf_extensions(struct sock_filter *fp,
 		case SKF_AD_OFF + SKF_AD_TRA_OFFSET:
 			insn->imm = __skb_get_tra_offset - __bpf_call_base;
 			break;
+		case SKF_AD_OFF + SKF_AD_TRA_PROTOCOL:
+			insn->imm = __skb_get_tra_protocol - __bpf_call_base;
+			break;
 		}
 		break;
 
@@ -1381,6 +1399,7 @@ int sk_chk_filter(struct sock_filter *filter, unsigned int flen)
 			ANCILLARY(PAY_OFFSET);
 			ANCILLARY(RANDOM);
 			ANCILLARY(TRA_OFFSET);
+			ANCILLARY(TRA_PROTOCOL);
 			}
 
 			/* ancillary operation unknown or unsupported */
@@ -1774,6 +1793,7 @@ void sk_decode_filter(struct sock_filter *filt, struct sock_filter *to)
 		[BPF_S_ANC_PAY_OFFSET]	= BPF_LD|BPF_B|BPF_ABS,
 		[BPF_S_ANC_RANDOM]	= BPF_LD|BPF_B|BPF_ABS,
 		[BPF_S_ANC_TRA_OFFSET]	= BPF_LD|BPF_B|BPF_ABS,
+		[BPF_S_ANC_TRA_PROTOCOL]	= BPF_LD|BPF_B|BPF_ABS,
 		[BPF_S_LD_W_LEN]	= BPF_LD|BPF_W|BPF_LEN,
 		[BPF_S_LD_W_IND]	= BPF_LD|BPF_W|BPF_IND,
 		[BPF_S_LD_H_IND]	= BPF_LD|BPF_H|BPF_IND,
diff --git a/tools/net/bpf_exp.l b/tools/net/bpf_exp.l
index 4e72934..c1b5958 100644
--- a/tools/net/bpf_exp.l
+++ b/tools/net/bpf_exp.l
@@ -94,6 +94,7 @@ extern void yyerror(const char *str);
 "#"?("vlan_pr")	{ return K_VLANP; }
 "#"?("rand")	{ return K_RAND; }
 "#"?("toff")	{ return K_TOFF; }
+"#"?("tproto")	{ return K_TPROTO; }
 
 ":"		{ return ':'; }
 ","		{ return ','; }
diff --git a/tools/net/bpf_exp.y b/tools/net/bpf_exp.y
index ced6949..71fef72 100644
--- a/tools/net/bpf_exp.y
+++ b/tools/net/bpf_exp.y
@@ -56,7 +56,7 @@ static void bpf_set_jmp_label(char *label, enum jmp_type type);
 %token OP_LDXI
 
 %token K_PKT_LEN K_PROTO K_TYPE K_NLATTR K_NLATTR_NEST K_MARK K_QUEUE K_HATYPE
-%token K_RXHASH K_CPU K_IFIDX K_VLANT K_VLANP K_POFF K_RAND K_TOFF
+%token K_RXHASH K_CPU K_IFIDX K_VLANT K_VLANP K_POFF K_RAND K_TOFF K_TPROTO
 
 %token ':' ',' '[' ']' '(' ')' 'x' 'a' '+' 'M' '*' '&' '#' '%'
 
@@ -170,6 +170,9 @@ ldb
 	| OP_LDB K_TOFF {
 		bpf_set_curr_instr(BPF_LD | BPF_B | BPF_ABS, 0, 0,
 				   SKF_AD_OFF + SKF_AD_TRA_OFFSET); }
+	| OP_LDB K_TPROTO {
+		bpf_set_curr_instr(BPF_LD | BPF_B | BPF_ABS, 0, 0,
+				   SKF_AD_OFF + SKF_AD_TRA_PROTOCOL); }
 	;
 
 ldh
@@ -224,6 +227,9 @@ ldh
 	| OP_LDH K_TOFF {
 		bpf_set_curr_instr(BPF_LD | BPF_H | BPF_ABS, 0, 0,
 				   SKF_AD_OFF + SKF_AD_TRA_OFFSET); }
+	| OP_LDH K_TPROTO {
+		bpf_set_curr_instr(BPF_LD | BPF_H | BPF_ABS, 0, 0,
+				   SKF_AD_OFF + SKF_AD_TRA_PROTOCOL); }
 	;
 
 ldi
@@ -283,6 +289,9 @@ ld
 	| OP_LD K_TOFF {
 		bpf_set_curr_instr(BPF_LD | BPF_W | BPF_ABS, 0, 0,
 				   SKF_AD_OFF + SKF_AD_TRA_OFFSET); }
+	| OP_LD K_TPROTO {
+		bpf_set_curr_instr(BPF_LD | BPF_W | BPF_ABS, 0, 0,
+				   SKF_AD_OFF + SKF_AD_TRA_PROTOCOL); }
 	| OP_LD 'M' '[' number ']' {
 		bpf_set_curr_instr(BPF_LD | BPF_MEM, 0, 0, $4); }
 	| OP_LD '[' 'x' '+' number ']' {
-- 
1.9.1.423.g4596e3a
