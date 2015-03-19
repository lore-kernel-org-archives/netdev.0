From: Michal Sekletar <msekleta@redhat.com>
Subject: [PATCH net-next v2] filter: introduce SKF_AD_VLAN_TPID BPF extension
Date: Thu, 19 Mar 2015 12:10:14 +0100
Message-ID: <1426763414-10091-1-git-send-email-msekleta@redhat.com>
Cc: Michal Sekletar <msekleta@redhat.com>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Jiri Pirko <jpirko@redhat.com>,
	Ralf Baechle <ralf@linux-mips.org>,
	Russell King <linux@arm.linux.org.uk>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44822 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750951AbbCSLKf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Mar 2015 07:10:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If vlan offloading takes place then vlan header is removed from frame
and its contents, both vlan_tci and vlan_proto, is available to userspace via
TPACKET interface. However, only vlan_tci can be used in BPF filters.

This commit introduces new BPF extension. It makes possible to load value of
vlan_proto (vlan TPID) to register A.

Cc: Alexei Starovoitov <ast@plumgrid.com>
Cc: Jiri Pirko <jpirko@redhat.com>
Cc: Ralf Baechle <ralf@linux-mips.org>
Cc: Russell King <linux@arm.linux.org.uk>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: David S. Miller <davem@davemloft.net>

Signed-off-by: Michal Sekletar <msekleta@redhat.com>
---

Changes in v2:
        * extension renamed to SKF_AD_VLAN_TPID
        * alias vlan_avail maybe used in bpf_asm programs instead of vlan_pr
        * fixes for jit compilers, vlan_proto is 16 bit not 32 bit wide

 Documentation/networking/filter.txt |  3 ++-
 arch/arm/net/bpf_jit_32.c           |  6 ++++++
 arch/mips/net/bpf_jit.c             |  6 ++++++
 arch/powerpc/net/bpf_jit_comp.c     |  5 +++++
 arch/s390/net/bpf_jit_comp.c        |  5 +++++
 arch/sparc/net/bpf_jit_comp.c       |  3 +++
 include/linux/filter.h              |  1 +
 include/uapi/linux/filter.h         |  3 ++-
 net/core/filter.c                   | 10 ++++++++++
 tools/net/bpf_exp.l                 |  2 ++
 tools/net/bpf_exp.y                 | 11 ++++++++++-
 11 files changed, 52 insertions(+), 3 deletions(-)

diff --git a/Documentation/networking/filter.txt b/Documentation/networking/filter.txt
index 9930ecfb..234577d 100644
--- a/Documentation/networking/filter.txt
+++ b/Documentation/networking/filter.txt
@@ -280,8 +280,9 @@ Possible BPF extensions are shown in the following table:
   rxhash                                skb->hash
   cpu                                   raw_smp_processor_id()
   vlan_tci                              skb_vlan_tag_get(skb)
-  vlan_pr                               skb_vlan_tag_present(skb)
+  vlan_avail                            skb_vlan_tag_present(skb)
   rand                                  prandom_u32()
+  vlan_tpid                             skb->vlan_proto
 
 These extensions can also be prefixed with '#'.
 Examples for low-level BPF:
diff --git a/arch/arm/net/bpf_jit_32.c b/arch/arm/net/bpf_jit_32.c
index e1268f9..e057074 100644
--- a/arch/arm/net/bpf_jit_32.c
+++ b/arch/arm/net/bpf_jit_32.c
@@ -843,6 +843,12 @@ b_epilogue:
 			else
 				OP_IMM3(ARM_AND, r_A, r_A, VLAN_TAG_PRESENT, ctx);
 			break;
+		case BPF_ANC | SKF_AD_VLAN_TPID:
+			ctx->seen |= SEEN_SKB;
+			BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, vlan_proto) != 2);
+			off = offsetof(struct sk_buff, vlan_proto);
+			emit(ARM_LDRH_I(r_A, r_skb, off), ctx);
+			break;
 		case BPF_ANC | SKF_AD_QUEUE:
 			ctx->seen |= SEEN_SKB;
 			BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff,
diff --git a/arch/mips/net/bpf_jit.c b/arch/mips/net/bpf_jit.c
index 5d61393..ab902a6 100644
--- a/arch/mips/net/bpf_jit.c
+++ b/arch/mips/net/bpf_jit.c
@@ -1295,6 +1295,12 @@ jmp_cmp:
 				emit_sltu(r_A, r_zero, r_A, ctx);
 			}
 			break;
+		case BPF_ANC | SKF_AD_VLAN_TPID:
+			ctx->flags |= SEEN_SKB | SEEN_A;
+			BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, vlan_proto) != 2);
+			off = offsetof(struct sk_buff, vlan_proto);
+			emit_half_load(r_A, r_skb, off, ctx);
+			break;
 		case BPF_ANC | SKF_AD_PKTTYPE:
 			ctx->flags |= SEEN_SKB;
 
diff --git a/arch/powerpc/net/bpf_jit_comp.c b/arch/powerpc/net/bpf_jit_comp.c
index 17cea18..5f18542 100644
--- a/arch/powerpc/net/bpf_jit_comp.c
+++ b/arch/powerpc/net/bpf_jit_comp.c
@@ -399,6 +399,11 @@ static int bpf_jit_build_body(struct bpf_prog *fp, u32 *image,
 				PPC_SRWI(r_A, r_A, 12);
 			}
 			break;
+		case BPF_ANC | SKF_AD_VLAN_TPID:
+			BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, vlan_proto) != 2);
+			PPC_LHZ_OFFS(r_A, r_skb, offsetof(struct sk_buff,
+							  vlan_proto));
+			break;
 		case BPF_ANC | SKF_AD_QUEUE:
 			BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff,
 						  queue_mapping) != 2);
diff --git a/arch/s390/net/bpf_jit_comp.c b/arch/s390/net/bpf_jit_comp.c
index bbd1981..f5281ab 100644
--- a/arch/s390/net/bpf_jit_comp.c
+++ b/arch/s390/net/bpf_jit_comp.c
@@ -722,6 +722,11 @@ call_fn:	/* lg %r1,<d(function)>(%r13) */
 			EMIT4_DISP(0x88500000, 12);
 		}
 		break;
+	case BPF_ANC | SKF_AD_VLAN_TPID: /* A = skb->vlan_proto */
+		BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, vlan_proto) != 2);
+		/* icm	%r5,3,<d(vlan_proto)>(%r2) */
+		EMIT4_DISP(0xbf532000, offsetof(struct sk_buff, vlan_proto));
+		break;
 	case BPF_ANC | SKF_AD_PKTTYPE:
 		/* lhi %r5,0 */
 		EMIT4(0xa7580000);
diff --git a/arch/sparc/net/bpf_jit_comp.c b/arch/sparc/net/bpf_jit_comp.c
index 7931eee..d71b6fc 100644
--- a/arch/sparc/net/bpf_jit_comp.c
+++ b/arch/sparc/net/bpf_jit_comp.c
@@ -624,6 +624,9 @@ void bpf_jit_compile(struct bpf_prog *fp)
 					emit_and(r_A, r_TMP, r_A);
 				}
 				break;
+			case BPF_ANC | SKF_AD_VLAN_TPID:
+				emit_skb_load16(vlan_proto, r_A);
+				break;
 			case BPF_LD | BPF_W | BPF_LEN:
 				emit_skb_load32(len, r_A);
 				break;
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
index b95ae7f..30229f8 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -277,6 +277,16 @@ static bool convert_bpf_extensions(struct sock_filter *fp,
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
diff --git a/tools/net/bpf_exp.l b/tools/net/bpf_exp.l
index 833a966..5795f0b 100644
--- a/tools/net/bpf_exp.l
+++ b/tools/net/bpf_exp.l
@@ -92,7 +92,9 @@ extern void yyerror(const char *str);
 "#"?("cpu")	{ return K_CPU; }
 "#"?("vlan_tci") { return K_VLANT; }
 "#"?("vlan_pr")	{ return K_VLANP; }
+"#"?("vlan_avail")	{ return K_VLANP; }
 "#"?("rand")	{ return K_RAND; }
+"#"?("vlan_tpid")	{ return K_VLANTPID; }
 
 ":"		{ return ':'; }
 ","		{ return ','; }
diff --git a/tools/net/bpf_exp.y b/tools/net/bpf_exp.y
index e6306c5..82728f1 100644
--- a/tools/net/bpf_exp.y
+++ b/tools/net/bpf_exp.y
@@ -56,7 +56,7 @@ static void bpf_set_jmp_label(char *label, enum jmp_type type);
 %token OP_LDXI
 
 %token K_PKT_LEN K_PROTO K_TYPE K_NLATTR K_NLATTR_NEST K_MARK K_QUEUE K_HATYPE
-%token K_RXHASH K_CPU K_IFIDX K_VLANT K_VLANP K_POFF K_RAND
+%token K_RXHASH K_CPU K_IFIDX K_VLANT K_VLANP K_POFF K_RAND K_VLANTPID
 
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
1.8.3.1
