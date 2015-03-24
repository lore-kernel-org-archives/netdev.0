From: Michal Sekletar <msekleta@redhat.com>
Subject: [PATCH net-next v3] filter: introduce SKF_AD_VLAN_TPID BPF extension
Date: Tue, 24 Mar 2015 14:48:41 +0100
Message-ID: <1427204921-14535-1-git-send-email-msekleta@redhat.com>
Cc: Michal Sekletar <msekleta@redhat.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Jiri Pirko <jpirko@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45177 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752194AbbCXNtS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Mar 2015 09:49:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If vlan offloading takes place then vlan header is removed from frame
and its contents, both vlan_tci and vlan_proto, is available to user
space via TPACKET interface. However, only vlan_tci can be used in BPF
filters.

This commit introduces a new BPF extension. It makes possible to load
the value of vlan_proto (vlan TPID) to register A. Support for classic
BPF and eBPF is being added, analogous to skb->protocol.

Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: Alexei Starovoitov <ast@plumgrid.com>
Cc: Jiri Pirko <jpirko@redhat.com>

Signed-off-by: Michal Sekletar <msekleta@redhat.com>
---

* Changes in v3:
  - changes for JIT implementations are left out
  - support for eBPF was added
  - polish, whitespace fixes

 Documentation/networking/filter.txt |  3 ++-
 include/linux/filter.h              |  1 +
 include/uapi/linux/bpf.h            |  1 +
 include/uapi/linux/filter.h         |  3 ++-
 net/core/filter.c                   | 17 +++++++++++++++++
 tools/net/bpf_exp.l                 |  2 ++
 tools/net/bpf_exp.y                 | 11 ++++++++++-
 7 files changed, 35 insertions(+), 3 deletions(-)

diff --git a/Documentation/networking/filter.txt b/Documentation/networking/filter.txt
index 9930ecfb..135581f 100644
--- a/Documentation/networking/filter.txt
+++ b/Documentation/networking/filter.txt
@@ -280,7 +280,8 @@ Possible BPF extensions are shown in the following table:
   rxhash                                skb->hash
   cpu                                   raw_smp_processor_id()
   vlan_tci                              skb_vlan_tag_get(skb)
-  vlan_pr                               skb_vlan_tag_present(skb)
+  vlan_avail                            skb_vlan_tag_present(skb)
+  vlan_tpid                             skb->vlan_proto
   rand                                  prandom_u32()
 
 These extensions can also be prefixed with '#'.
diff --git a/include/linux/filter.h b/include/linux/filter.h
index 9ee8c67..fa11b3a 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -454,6 +454,7 @@ static inline u16 bpf_anc_helper(const struct sock_filter *ftest)
 		BPF_ANCILLARY(VLAN_TAG_PRESENT);
 		BPF_ANCILLARY(PAY_OFFSET);
 		BPF_ANCILLARY(RANDOM);
+		BPF_ANCILLARY(VLAN_TPID);
 		}
 		/* Fallthrough. */
 	default:
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 3dd314a..27dc4ec 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -182,6 +182,7 @@ struct __sk_buff {
 	__u32 protocol;
 	__u32 vlan_present;
 	__u32 vlan_tci;
+	__u32 vlan_proto;
 };
 
 #endif /* _UAPI__LINUX_BPF_H__ */
diff --git a/include/uapi/linux/filter.h b/include/uapi/linux/filter.h
index 47785d5..34c7936 100644
--- a/include/uapi/linux/filter.h
+++ b/include/uapi/linux/filter.h
@@ -77,7 +77,8 @@ struct sock_fprog {	/* Required for SO_ATTACH_FILTER. */
 #define SKF_AD_VLAN_TAG_PRESENT 48
 #define SKF_AD_PAY_OFFSET	52
 #define SKF_AD_RANDOM	56
-#define SKF_AD_MAX	60
+#define SKF_AD_VLAN_TPID	60
+#define SKF_AD_MAX	64
 #define SKF_NET_OFF   (-0x100000)
 #define SKF_LL_OFF    (-0x200000)
 
diff --git a/net/core/filter.c b/net/core/filter.c
index 084eacc..32f43c5 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -272,6 +272,16 @@ static bool convert_bpf_extensions(struct sock_filter *fp,
 		insn += cnt - 1;
 		break;
 
+	case SKF_AD_OFF + SKF_AD_VLAN_TPID:
+		BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, vlan_proto) != 2);
+
+		/* A = *(u16 *) (CTX + offsetof(vlan_proto)) */
+		*insn++ = BPF_LDX_MEM(BPF_H, BPF_REG_A, BPF_REG_CTX,
+				      offsetof(struct sk_buff, vlan_proto));
+		/* A = ntohs(A) [emitting a nop or swap16] */
+		*insn = BPF_ENDIAN(BPF_FROM_BE, BPF_REG_A, 16);
+		break;
+
 	case SKF_AD_OFF + SKF_AD_PAY_OFFSET:
 	case SKF_AD_OFF + SKF_AD_NLATTR:
 	case SKF_AD_OFF + SKF_AD_NLATTR_NEST:
@@ -1226,6 +1236,13 @@ static u32 sk_filter_convert_ctx_access(int dst_reg, int src_reg, int ctx_off,
 				      offsetof(struct sk_buff, protocol));
 		break;
 
+	case offsetof(struct __sk_buff, vlan_proto):
+		BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, vlan_proto) != 2);
+
+		*insn++ = BPF_LDX_MEM(BPF_H, dst_reg, src_reg,
+				      offsetof(struct sk_buff, vlan_proto));
+		break;
+
 	case offsetof(struct __sk_buff, mark):
 		return convert_skb_access(SKF_AD_MARK, dst_reg, src_reg, insn);
 
diff --git a/tools/net/bpf_exp.l b/tools/net/bpf_exp.l
index 833a966..c83af3f 100644
--- a/tools/net/bpf_exp.l
+++ b/tools/net/bpf_exp.l
@@ -92,6 +92,8 @@ extern void yyerror(const char *str);
 "#"?("cpu")	{ return K_CPU; }
 "#"?("vlan_tci") { return K_VLANT; }
 "#"?("vlan_pr")	{ return K_VLANP; }
+"#"?("vlan_avail")	{ return K_VLANP; }
+"#"?("vlan_tpid")	{ return K_VLANTPID; }
 "#"?("rand")	{ return K_RAND; }
 
 ":"		{ return ':'; }
diff --git a/tools/net/bpf_exp.y b/tools/net/bpf_exp.y
index e6306c5..f833274 100644
--- a/tools/net/bpf_exp.y
+++ b/tools/net/bpf_exp.y
@@ -56,7 +56,7 @@ static void bpf_set_jmp_label(char *label, enum jmp_type type);
 %token OP_LDXI
 
 %token K_PKT_LEN K_PROTO K_TYPE K_NLATTR K_NLATTR_NEST K_MARK K_QUEUE K_HATYPE
-%token K_RXHASH K_CPU K_IFIDX K_VLANT K_VLANP K_POFF K_RAND
+%token K_RXHASH K_CPU K_IFIDX K_VLANT K_VLANP K_VLANTPID K_POFF K_RAND
 
 %token ':' ',' '[' ']' '(' ')' 'x' 'a' '+' 'M' '*' '&' '#' '%'
 
@@ -167,6 +167,9 @@ ldb
 	| OP_LDB K_RAND {
 		bpf_set_curr_instr(BPF_LD | BPF_B | BPF_ABS, 0, 0,
 				   SKF_AD_OFF + SKF_AD_RANDOM); }
+	| OP_LDB K_VLANTPID {
+		bpf_set_curr_instr(BPF_LD | BPF_B | BPF_ABS, 0, 0,
+				   SKF_AD_OFF + SKF_AD_VLAN_TPID); }
 	;
 
 ldh
@@ -218,6 +221,9 @@ ldh
 	| OP_LDH K_RAND {
 		bpf_set_curr_instr(BPF_LD | BPF_H | BPF_ABS, 0, 0,
 				   SKF_AD_OFF + SKF_AD_RANDOM); }
+	| OP_LDH K_VLANTPID {
+		bpf_set_curr_instr(BPF_LD | BPF_H | BPF_ABS, 0, 0,
+				   SKF_AD_OFF + SKF_AD_VLAN_TPID); }
 	;
 
 ldi
@@ -274,6 +280,9 @@ ld
 	| OP_LD K_RAND {
 		bpf_set_curr_instr(BPF_LD | BPF_W | BPF_ABS, 0, 0,
 				   SKF_AD_OFF + SKF_AD_RANDOM); }
+	| OP_LD K_VLANTPID {
+		bpf_set_curr_instr(BPF_LD | BPF_W | BPF_ABS, 0, 0,
+				   SKF_AD_OFF + SKF_AD_VLAN_TPID); }
 	| OP_LD 'M' '[' number ']' {
 		bpf_set_curr_instr(BPF_LD | BPF_MEM, 0, 0, $4); }
 	| OP_LD '[' 'x' '+' number ']' {
-- 
2.3.4
