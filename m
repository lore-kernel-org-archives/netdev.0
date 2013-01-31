From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] x86: bpf_jit_comp: add pkt_type support
Date: Wed, 30 Jan 2013 17:51:44 -0800
Message-ID: <1359597104.30177.24.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Maciej =?UTF-8?Q?=C5=BBenczykowski?= <maze@google.com>,
	Willem de Bruijn <willemb@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f54.google.com ([209.85.160.54]:44802 "EHLO
	mail-pb0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753470Ab3AaBvr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jan 2013 20:51:47 -0500
Received: by mail-pb0-f54.google.com with SMTP id rr4so1322227pbb.41
        for <netdev@vger.kernel.org>; Wed, 30 Jan 2013 17:51:46 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <edumazet@google.com>

Supporting access to skb->pkt_type is a bit tricky if we want
to have a generic code, allowing pkt_type to be moved in struct sk_buff

pkt_type is a bit field, so compiler cannot really help us to find
its offset. Let's use a helper for this : It will throw a one time
message if pkt_type no longer starts at a byte boundary or is
no longer a 3bit field.

Reported-by: Willem de Bruijn <willemb@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Maciej =C5=BBenczykowski <maze@google.com>
---
 arch/x86/net/bpf_jit_comp.c |   40 +++++++++++++++++++++++++++++++++-
 1 file changed, 39 insertions(+), 1 deletion(-)

diff --git a/arch/x86/net/bpf_jit_comp.c b/arch/x86/net/bpf_jit_comp.c
index d11a470..3cbe4538 100644
--- a/arch/x86/net/bpf_jit_comp.c
+++ b/arch/x86/net/bpf_jit_comp.c
@@ -1,6 +1,6 @@
 /* bpf_jit_comp.c : BPF JIT compiler
  *
- * Copyright (C) 2011 Eric Dumazet (eric.dumazet@gmail.com)
+ * Copyright (C) 2011-2013 Eric Dumazet (eric.dumazet@gmail.com)
  *
  * This program is free software; you can redistribute it and/or
  * modify it under the terms of the GNU General Public License
@@ -124,6 +124,26 @@ static inline void bpf_flush_icache(void *start, v=
oid *end)
 #define CHOOSE_LOAD_FUNC(K, func) \
 	((int)K < 0 ? ((int)K >=3D SKF_LL_OFF ? func##_negative_offset : func=
) : func##_positive_offset)
=20
+/* Helper to find the offset of pkt_type in sk_buff
+ * We want to make sure its still a 3bit field starting at a byte boun=
dary.
+ */
+#define PKT_TYPE_MAX 7
+static int pkt_type_offset(void)
+{
+	struct sk_buff skb_probe =3D {
+		.pkt_type =3D ~0,
+	};
+	char *ct =3D (char *)&skb_probe;
+	unsigned int off;
+
+	for (off =3D 0; off < sizeof(struct sk_buff); off++) {
+		if (ct[off] =3D=3D PKT_TYPE_MAX)
+			return off;
+	}
+	pr_err_once("Please fix pkt_type_offset(), as pkt_type couldn't be fo=
und\n");
+	return -1;
+}
+
 void bpf_jit_compile(struct sk_filter *fp)
 {
 	u8 temp[64];
@@ -216,6 +236,7 @@ void bpf_jit_compile(struct sk_filter *fp)
 		case BPF_S_ANC_VLAN_TAG:
 		case BPF_S_ANC_VLAN_TAG_PRESENT:
 		case BPF_S_ANC_QUEUE:
+		case BPF_S_ANC_PKTTYPE:
 		case BPF_S_LD_W_ABS:
 		case BPF_S_LD_H_ABS:
 		case BPF_S_LD_B_ABS:
@@ -536,6 +557,23 @@ void bpf_jit_compile(struct sk_filter *fp)
 					EMIT3(0x83, 0xe0, 0x01); /* and    $0x1,%eax */
 				}
 				break;
+			case BPF_S_ANC_PKTTYPE:
+			{
+				int off =3D pkt_type_offset();
+
+				if (off < 0)
+					goto out;
+				if (is_imm8(off)) {
+					/* movzbl off8(%rdi),%eax */
+					EMIT4(0x0f, 0xb6, 0x47, off);
+				} else {
+					/* movbl off32(%rdi),%eax */
+					EMIT3(0x0f, 0xb6, 0x87);
+					EMIT(off, 4);
+				}
+				EMIT3(0x83, 0xe0, PKT_TYPE_MAX); /* and    $0x7,%eax */
+				break;
+			}
 			case BPF_S_LD_W_ABS:
 				func =3D CHOOSE_LOAD_FUNC(K, sk_load_word);
 common_load:			seen |=3D SEEN_DATAREF;
