From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net] bpf: fix method of PTR_TO_PACKET reg id generation
Date: Tue,  2 Aug 2016 16:12:14 +0100
Message-ID: <1470150734-24022-1-git-send-email-jakub.kicinski@netronome.com>
Cc: Daniel Borkmann <daniel@iogearbox.net>, <netdev@vger.kernel.org>,
	Jakub Kicinski <jakub.kicinski@netronome.com>
To: Alexei Starovoitov <ast@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:38691 "EHLO
	mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932920AbcHBPSX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Aug 2016 11:18:23 -0400
Received: by mail-wm0-f48.google.com with SMTP id o80so295530581wme.1
        for <netdev@vger.kernel.org>; Tue, 02 Aug 2016 08:18:21 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Using per-register incrementing ID can lead to
find_good_pkt_pointers() confusing registers which
have completely different values.  Consider example:

0: (bf) r6 = r1
1: (61) r8 = *(u32 *)(r6 +76)
2: (61) r0 = *(u32 *)(r6 +80)
3: (bf) r7 = r8
4: (07) r8 += 32
5: (2d) if r8 > r0 goto pc+9
 R0=pkt_end R1=ctx R6=ctx R7=pkt(id=0,off=0,r=32) R8=pkt(id=0,off=32,r=32) R10=fp
6: (bf) r8 = r7
7: (bf) r9 = r7
8: (71) r1 = *(u8 *)(r7 +0)
9: (0f) r8 += r1
10: (71) r1 = *(u8 *)(r7 +1)
11: (0f) r9 += r1
12: (07) r8 += 32
13: (2d) if r8 > r0 goto pc+1
 R0=pkt_end R1=inv56 R6=ctx R7=pkt(id=0,off=0,r=32) R8=pkt(id=1,off=32,r=32) R9=pkt(id=1,off=0,r=32) R10=fp
14: (71) r1 = *(u8 *)(r9 +16)
15: (b7) r7 = 0
16: (bf) r0 = r7
17: (95) exit

We need to get a UNKNOWN_VALUE with imm to force id
generation so lines 0-5 make r7 a valid packet pointer.
We then read two different bytes from the packet and
add them to copies of the constructed packet pointer.
r8 (line 9) and r9 (line 11) will get the same id of 1,
independently.  When either of them is validated (line
13) - find_good_pkt_pointers() will also mark the other
as safe.  This leads to access on line 14 being mistakenly
considered safe.

Fixes: 969bf05eb3ce ("bpf: direct packet access")
Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 kernel/bpf/verifier.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index f72f23b8fdab..7094c69ac199 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -194,6 +194,7 @@ struct verifier_env {
 	struct verifier_state_list **explored_states; /* search pruning optimization */
 	struct bpf_map *used_maps[MAX_USED_MAPS]; /* array of map's used by eBPF program */
 	u32 used_map_cnt;		/* number of used maps */
+	u32 id_gen;			/* used to generate unique reg IDs */
 	bool allow_ptr_leaks;
 };
 
@@ -1301,7 +1302,7 @@ add_imm:
 		/* dst_reg stays as pkt_ptr type and since some positive
 		 * integer value was added to the pointer, increment its 'id'
 		 */
-		dst_reg->id++;
+		dst_reg->id = ++env->id_gen;
 
 		/* something was added to pkt_ptr, set range and off to zero */
 		dst_reg->off = 0;
-- 
1.9.1
