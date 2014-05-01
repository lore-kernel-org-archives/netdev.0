From: Chema Gonzalez <chema@google.com>
Subject: [PATCH net-next v2] net: filter: add insn for loading internal transport header offset
Date: Thu,  1 May 2014 11:44:40 -0700
Message-ID: <1398969880-8007-1-git-send-email-chema@google.com>
References: <1398882591-30422-1-git-send-email-chema@google.com>
Cc: netdev@vger.kernel.org, Chema Gonzalez <chema@google.com>
To: David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f201.google.com ([209.85.192.201]:58699 "EHLO
	mail-pd0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751505AbaEASon (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 May 2014 14:44:43 -0400
Received: by mail-pd0-f201.google.com with SMTP id fp1so553573pdb.0
        for <netdev@vger.kernel.org>; Thu, 01 May 2014 11:44:42 -0700 (PDT)
In-Reply-To: <1398882591-30422-1-git-send-email-chema@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patch adds an ANC_TRA_OFFSET insn that loads the internal transport
header of a packet ("internal" meaning after decapsulation by the
flow dissector).

Signed-off-by: Chema Gonzalez <chema@google.com>
---
 include/linux/filter.h      |  1 +
 include/uapi/linux/filter.h |  3 ++-
 net/core/filter.c           | 17 +++++++++++++++++
 tools/net/bpf_exp.l         |  1 +
 tools/net/bpf_exp.y         | 11 ++++++++++-
 5 files changed, 31 insertions(+), 2 deletions(-)

diff --git a/include/linux/filter.h b/include/linux/filter.h
index 759abf7..b76ae2b 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -224,6 +224,7 @@ enum {
 	BPF_S_ANC_VLAN_TAG_PRESENT,
 	BPF_S_ANC_PAY_OFFSET,
 	BPF_S_ANC_RANDOM,
+	BPF_S_ANC_TRA_OFFSET,
 };
 
 #endif /* __LINUX_FILTER_H__ */
diff --git a/include/uapi/linux/filter.h b/include/uapi/linux/filter.h
index 253b4d4..9f1b8f1 100644
--- a/include/uapi/linux/filter.h
+++ b/include/uapi/linux/filter.h
@@ -131,7 +131,8 @@ struct sock_fprog {	/* Required for SO_ATTACH_FILTER. */
 #define SKF_AD_VLAN_TAG_PRESENT 48
 #define SKF_AD_PAY_OFFSET	52
 #define SKF_AD_RANDOM	56
-#define SKF_AD_MAX	60
+#define SKF_AD_TRA_OFFSET	60
+#define SKF_AD_MAX	64
 #define SKF_NET_OFF   (-0x100000)
 #define SKF_LL_OFF    (-0x200000)
 
diff --git a/net/core/filter.c b/net/core/filter.c
index 7c4db3d..8264c79 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -601,6 +601,17 @@ static u64 __skb_get_pay_offset(u64 ctx, u64 A, u64 X, u64 r4, u64 r5)
 	return __skb_get_poff(skb);
 }
 
+static u64 __skb_get_tra_offset(u64 ctx, u64 A, u64 X, u64 r4, u64 r5)
+{
+	struct sk_buff *skb = (struct sk_buff *)(unsigned long) ctx;
+	struct flow_keys keys;
+
+	if (!skb_flow_dissect(skb, &keys))
+		return 0;
+
+	return keys.thoff;
+}
+
 static u64 __skb_get_nlattr(u64 ctx, u64 A, u64 X, u64 r4, u64 r5)
 {
 	struct sk_buff *skb = (struct sk_buff *)(long) ctx;
@@ -788,6 +799,7 @@ static bool convert_bpf_extensions(struct sock_filter *fp,
 	case SKF_AD_OFF + SKF_AD_NLATTR_NEST:
 	case SKF_AD_OFF + SKF_AD_CPU:
 	case SKF_AD_OFF + SKF_AD_RANDOM:
+	case SKF_AD_OFF + SKF_AD_TRA_OFFSET:
 		/* arg1 = ctx */
 		insn->code = BPF_ALU64 | BPF_MOV | BPF_X;
 		insn->a_reg = ARG1_REG;
@@ -824,6 +836,9 @@ static bool convert_bpf_extensions(struct sock_filter *fp,
 		case SKF_AD_OFF + SKF_AD_RANDOM:
 			insn->imm = __get_random_u32 - __bpf_call_base;
 			break;
+		case SKF_AD_OFF + SKF_AD_TRA_OFFSET:
+			insn->imm = __skb_get_tra_offset - __bpf_call_base;
+			break;
 		}
 		break;
 
@@ -1375,6 +1390,7 @@ int sk_chk_filter(struct sock_filter *filter, unsigned int flen)
 			ANCILLARY(VLAN_TAG_PRESENT);
 			ANCILLARY(PAY_OFFSET);
 			ANCILLARY(RANDOM);
+			ANCILLARY(TRA_OFFSET);
 			}
 
 			/* ancillary operation unknown or unsupported */
@@ -1760,6 +1776,7 @@ void sk_decode_filter(struct sock_filter *filt, struct sock_filter *to)
 		[BPF_S_ANC_VLAN_TAG_PRESENT] = BPF_LD|BPF_B|BPF_ABS,
 		[BPF_S_ANC_PAY_OFFSET]	= BPF_LD|BPF_B|BPF_ABS,
 		[BPF_S_ANC_RANDOM]	= BPF_LD|BPF_B|BPF_ABS,
+		[BPF_S_ANC_TRA_OFFSET]	= BPF_LD|BPF_B|BPF_ABS,
 		[BPF_S_LD_W_LEN]	= BPF_LD|BPF_W|BPF_LEN,
 		[BPF_S_LD_W_IND]	= BPF_LD|BPF_W|BPF_IND,
 		[BPF_S_LD_H_IND]	= BPF_LD|BPF_H|BPF_IND,
diff --git a/tools/net/bpf_exp.l b/tools/net/bpf_exp.l
index 833a966..4e72934 100644
--- a/tools/net/bpf_exp.l
+++ b/tools/net/bpf_exp.l
@@ -93,6 +93,7 @@ extern void yyerror(const char *str);
 "#"?("vlan_tci") { return K_VLANT; }
 "#"?("vlan_pr")	{ return K_VLANP; }
 "#"?("rand")	{ return K_RAND; }
+"#"?("toff")	{ return K_TOFF; }
 
 ":"		{ return ':'; }
 ","		{ return ','; }
diff --git a/tools/net/bpf_exp.y b/tools/net/bpf_exp.y
index e6306c5..ced6949 100644
--- a/tools/net/bpf_exp.y
+++ b/tools/net/bpf_exp.y
@@ -56,7 +56,7 @@ static void bpf_set_jmp_label(char *label, enum jmp_type type);
 %token OP_LDXI
 
 %token K_PKT_LEN K_PROTO K_TYPE K_NLATTR K_NLATTR_NEST K_MARK K_QUEUE K_HATYPE
-%token K_RXHASH K_CPU K_IFIDX K_VLANT K_VLANP K_POFF K_RAND
+%token K_RXHASH K_CPU K_IFIDX K_VLANT K_VLANP K_POFF K_RAND K_TOFF
 
 %token ':' ',' '[' ']' '(' ')' 'x' 'a' '+' 'M' '*' '&' '#' '%'
 
@@ -167,6 +167,9 @@ ldb
 	| OP_LDB K_RAND {
 		bpf_set_curr_instr(BPF_LD | BPF_B | BPF_ABS, 0, 0,
 				   SKF_AD_OFF + SKF_AD_RANDOM); }
+	| OP_LDB K_TOFF {
+		bpf_set_curr_instr(BPF_LD | BPF_B | BPF_ABS, 0, 0,
+				   SKF_AD_OFF + SKF_AD_TRA_OFFSET); }
 	;
 
 ldh
@@ -218,6 +221,9 @@ ldh
 	| OP_LDH K_RAND {
 		bpf_set_curr_instr(BPF_LD | BPF_H | BPF_ABS, 0, 0,
 				   SKF_AD_OFF + SKF_AD_RANDOM); }
+	| OP_LDH K_TOFF {
+		bpf_set_curr_instr(BPF_LD | BPF_H | BPF_ABS, 0, 0,
+				   SKF_AD_OFF + SKF_AD_TRA_OFFSET); }
 	;
 
 ldi
@@ -274,6 +280,9 @@ ld
 	| OP_LD K_RAND {
 		bpf_set_curr_instr(BPF_LD | BPF_W | BPF_ABS, 0, 0,
 				   SKF_AD_OFF + SKF_AD_RANDOM); }
+	| OP_LD K_TOFF {
+		bpf_set_curr_instr(BPF_LD | BPF_W | BPF_ABS, 0, 0,
+				   SKF_AD_OFF + SKF_AD_TRA_OFFSET); }
 	| OP_LD 'M' '[' number ']' {
 		bpf_set_curr_instr(BPF_LD | BPF_MEM, 0, 0, $4); }
 	| OP_LD '[' 'x' '+' number ']' {
-- 
1.9.1.423.g4596e3a
