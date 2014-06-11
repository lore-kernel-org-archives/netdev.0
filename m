From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH net-next] net: filter: fix warning on 32-bit arch
Date: Wed, 11 Jun 2014 13:16:44 -0700
Message-ID: <1402517804-4301-1-git-send-email-ast@plumgrid.com>
Cc: Daniel Borkmann <dborkman@redhat.com>,
	Fengguang Wu <fengguang.wu@intel.com>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:53454 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751236AbaFKUQt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jun 2014 16:16:49 -0400
Received: by mail-pd0-f171.google.com with SMTP id ft15so168223pdb.16
        for <netdev@vger.kernel.org>; Wed, 11 Jun 2014 13:16:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fix compiler warning on 32-bit architectures:

net/core/filter.c: In function '__sk_run_filter':
net/core/filter.c:540:22: warning: cast to pointer from integer of different size [-Wint-to-pointer-cast]
net/core/filter.c:550:22: warning: cast to pointer from integer of different size [-Wint-to-pointer-cast]
net/core/filter.c:560:22: warning: cast to pointer from integer of different size [-Wint-to-pointer-cast]

Reported-by: Fengguang Wu <fengguang.wu@intel.com>
Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---

tested on qemu-arm32

 net/core/filter.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/core/filter.c b/net/core/filter.c
index b3f21751b238..735fad897496 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -537,7 +537,7 @@ load_word:
 		 *   BPF_R0 - 8/16/32-bit skb data converted to cpu endianness
 		 */
 
-		ptr = load_pointer((struct sk_buff *) CTX, off, 4, &tmp);
+		ptr = load_pointer((struct sk_buff *) (unsigned long) CTX, off, 4, &tmp);
 		if (likely(ptr != NULL)) {
 			BPF_R0 = get_unaligned_be32(ptr);
 			CONT;
@@ -547,7 +547,7 @@ load_word:
 	LD_ABS_H: /* BPF_R0 = ntohs(*(u16 *) (skb->data + imm32)) */
 		off = IMM;
 load_half:
-		ptr = load_pointer((struct sk_buff *) CTX, off, 2, &tmp);
+		ptr = load_pointer((struct sk_buff *) (unsigned long) CTX, off, 2, &tmp);
 		if (likely(ptr != NULL)) {
 			BPF_R0 = get_unaligned_be16(ptr);
 			CONT;
@@ -557,7 +557,7 @@ load_half:
 	LD_ABS_B: /* BPF_R0 = *(u8 *) (skb->data + imm32) */
 		off = IMM;
 load_byte:
-		ptr = load_pointer((struct sk_buff *) CTX, off, 1, &tmp);
+		ptr = load_pointer((struct sk_buff *) (unsigned long) CTX, off, 1, &tmp);
 		if (likely(ptr != NULL)) {
 			BPF_R0 = *(u8 *)ptr;
 			CONT;
-- 
1.7.9.5
