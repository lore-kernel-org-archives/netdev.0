From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next 2/2] x86: bpf_jit_comp: add vlan tag support
Date: Sat, 27 Oct 2012 14:26:22 +0200
Message-ID: <1351340782.30380.274.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ani Sinha <ani@aristanetworks.com>,
	netdev <netdev@vger.kernel.org>,
	Daniel Borkmann <danborkmann@iogearbox.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f174.google.com ([209.85.215.174]:34713 "EHLO
	mail-ea0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752459Ab2J0M00 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Oct 2012 08:26:26 -0400
Received: by mail-ea0-f174.google.com with SMTP id c13so1147382eaa.19
        for <netdev@vger.kernel.org>; Sat, 27 Oct 2012 05:26:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

This patch is a follow-up for patch "net: filter: add vlan tag access"
to support the new VLAN_TAG/VLAN_TAG_PRESENT accessors in BPF JIT.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Ani Sinha <ani@aristanetworks.com>
Cc: Daniel Borkmann <danborkmann@iogearbox.net>
---
 arch/x86/net/bpf_jit_comp.c |   21 +++++++++++++++++++++
 1 file changed, 21 insertions(+)

diff --git a/arch/x86/net/bpf_jit_comp.c b/arch/x86/net/bpf_jit_comp.c
index 520d2bd..d11a470 100644
--- a/arch/x86/net/bpf_jit_comp.c
+++ b/arch/x86/net/bpf_jit_comp.c
@@ -11,6 +11,7 @@
 #include <asm/cacheflush.h>
 #include <linux/netdevice.h>
 #include <linux/filter.h>
+#include <linux/if_vlan.h>
 
 /*
  * Conventions :
@@ -212,6 +213,8 @@ void bpf_jit_compile(struct sk_filter *fp)
 		case BPF_S_ANC_MARK:
 		case BPF_S_ANC_RXHASH:
 		case BPF_S_ANC_CPU:
+		case BPF_S_ANC_VLAN_TAG:
+		case BPF_S_ANC_VLAN_TAG_PRESENT:
 		case BPF_S_ANC_QUEUE:
 		case BPF_S_LD_W_ABS:
 		case BPF_S_LD_H_ABS:
@@ -515,6 +518,24 @@ void bpf_jit_compile(struct sk_filter *fp)
 				CLEAR_A();
 #endif
 				break;
+			case BPF_S_ANC_VLAN_TAG:
+			case BPF_S_ANC_VLAN_TAG_PRESENT:
+				BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, vlan_tci) != 2);
+				if (is_imm8(offsetof(struct sk_buff, vlan_tci))) {
+					/* movzwl off8(%rdi),%eax */
+					EMIT4(0x0f, 0xb7, 0x47, offsetof(struct sk_buff, vlan_tci));
+				} else {
+					EMIT3(0x0f, 0xb7, 0x87); /* movzwl off32(%rdi),%eax */
+					EMIT(offsetof(struct sk_buff, vlan_tci), 4);
+				}
+				BUILD_BUG_ON(VLAN_TAG_PRESENT != 0x1000);
+				if (filter[i].code == BPF_S_ANC_VLAN_TAG) {
+					EMIT3(0x80, 0xe4, 0xef); /* and    $0xef,%ah */
+				} else {
+					EMIT3(0xc1, 0xe8, 0x0c); /* shr    $0xc,%eax */
+					EMIT3(0x83, 0xe0, 0x01); /* and    $0x1,%eax */
+				}
+				break;
 			case BPF_S_LD_W_ABS:
 				func = CHOOSE_LOAD_FUNC(K, sk_load_word);
 common_load:			seen |= SEEN_DATAREF;
