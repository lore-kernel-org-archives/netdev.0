From: Daniel Borkmann <dxchgb@gmail.com>
Subject: [PATCH net-next] sparc: bpf_jit_comp: add VLAN instructions for
 BPF JIT
Date: Mon, 5 Nov 2012 03:59:30 +0100
Message-ID: <20121105025930.GA5197@thinkbox>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f174.google.com ([209.85.215.174]:57645 "EHLO
	mail-ea0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752024Ab2KEC7g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Nov 2012 21:59:36 -0500
Received: by mail-ea0-f174.google.com with SMTP id c13so2085730eaa.19
        for <netdev@vger.kernel.org>; Sun, 04 Nov 2012 18:59:34 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is a follow-up for patch "net: filter: add vlan tag access"
to support the new VLAN_TAG/VLAN_TAG_PRESENT accessors in BPF JIT.

Signed-off-by: Daniel Borkmann <daniel.borkmann@tik.ee.ethz.ch>
---
 Disclaimer: uncompiled and untested, since I don't have a SPARC machine,
 but it should (hopefully) integrate cleanly. ;)

 arch/sparc/net/bpf_jit_comp.c |   19 +++++++++++++++++++
 1 files changed, 19 insertions(+), 0 deletions(-)

diff --git a/arch/sparc/net/bpf_jit_comp.c b/arch/sparc/net/bpf_jit_comp.c
index 2836870..3109ca6 100644
--- a/arch/sparc/net/bpf_jit_comp.c
+++ b/arch/sparc/net/bpf_jit_comp.c
@@ -3,6 +3,7 @@
 #include <linux/netdevice.h>
 #include <linux/filter.h>
 #include <linux/cache.h>
+#include <linux/if_vlan.h>
 
 #include <asm/cacheflush.h>
 #include <asm/ptrace.h>
@@ -312,6 +313,12 @@ do {	*prog++ = BR_OPC | WDISP22(OFF);		\
 #define emit_addi(R1, IMM, R3) \
 	*prog++ = (ADD | IMMED | RS1(R1) | S13(IMM) | RD(R3))
 
+#define emit_and(R1, R2, R3) \
+	*prog++ = (AND | RS1(R1) | RS2(R2) | RD(R3))
+
+#define emit_andi(R1, IMM, R3) \
+	*prog++ = (AND | IMMED | RS1(R1) | S13(IMM) | RD(R3))
+
 #define emit_alloc_stack(SZ) \
 	*prog++ = (SUB | IMMED | RS1(SP) | S13(SZ) | RD(SP))
 
@@ -415,6 +422,8 @@ void bpf_jit_compile(struct sk_filter *fp)
 		case BPF_S_ANC_IFINDEX:
 		case BPF_S_ANC_MARK:
 		case BPF_S_ANC_RXHASH:
+		case BPF_S_ANC_VLAN_TAG:
+		case BPF_S_ANC_VLAN_TAG_PRESENT:
 		case BPF_S_ANC_CPU:
 		case BPF_S_ANC_QUEUE:
 		case BPF_S_LD_W_ABS:
@@ -600,6 +609,16 @@ void bpf_jit_compile(struct sk_filter *fp)
 			case BPF_S_ANC_RXHASH:
 				emit_skb_load32(rxhash, r_A);
 				break;
+			case BPF_S_ANC_VLAN_TAG:
+			case BPF_S_ANC_VLAN_TAG_PRESENT:
+				emit_skb_load16(vlan_tci, r_A);
+				if (filter[i].code == BPF_S_ANC_VLAN_TAG) {
+					emit_andi(r_A, VLAN_VID_MASK, r_A);
+				} else {
+					emit_loadimm(VLAN_TAG_PRESENT, r_TMP);
+					emit_and(r_A, r_TMP, r_A);
+				}
+				break;
 
 			case BPF_S_LD_IMM:
 				emit_loadimm(K, r_A);
