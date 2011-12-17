From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net: bpf_jit: fix an off-one bug in x86_64 cond jump target
Date: Sat, 17 Dec 2011 22:39:08 +0100
Message-ID: <1324157948.3323.36.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>, Markus <nepenthesdev@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:61653 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752423Ab1LQVjN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Dec 2011 16:39:13 -0500
Received: by wgbdr13 with SMTP id dr13so8421463wgb.1
        for <netdev@vger.kernel.org>; Sat, 17 Dec 2011 13:39:12 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Markus K=C3=B6tter <nepenthesdev@gmail.com>

x86 jump instruction size is 2 or 5 bytes (near/long jump), not 2 or 6
bytes.

In case a conditional jump is followed by a long jump, conditional jump
target is one byte past the start of target instruction.

Signed-off-by: Markus K=C3=B6tter <nepenthesdev@gmail.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---

libpcap expression to reproduce the bug :

"(tcp and portrange 0-1024) or (udp and portrange 1025-2048)"

 arch/x86/net/bpf_jit_comp.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/x86/net/bpf_jit_comp.c b/arch/x86/net/bpf_jit_comp.c
index bfab3fa..7b65f75 100644
--- a/arch/x86/net/bpf_jit_comp.c
+++ b/arch/x86/net/bpf_jit_comp.c
@@ -568,8 +568,8 @@ cond_branch:			f_offset =3D addrs[i + filter[i].jf]=
 - addrs[i];
 					break;
 				}
 				if (filter[i].jt !=3D 0) {
-					if (filter[i].jf)
-						t_offset +=3D is_near(f_offset) ? 2 : 6;
+					if (filter[i].jf && f_offset)
+						t_offset +=3D is_near(f_offset) ? 2 : 5;
 					EMIT_COND_JMP(t_op, t_offset);
 					if (filter[i].jf)
 						EMIT_JMP(f_offset);
