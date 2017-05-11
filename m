From: David Miller <davem@davemloft.net>
Subject: [PATCH v2 6/7] bpf: Make use of alignment information in
 check_val_ptr_alignment().
Date: Thu, 11 May 2017 12:06:08 -0400 (EDT)
Message-ID: <20170511.120608.248672395765712270.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@fb.com, alexei.starovoitov@gmail.com, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51590 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933901AbdEKQGK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 11 May 2017 12:06:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


We can validate PTR_TO_MAP_VALUE_ADJ accesses in the same way that we
do for PTR_TO_PACKET.  The only difference is that we don't plug
NET_IP_ALIGN into the equation.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 kernel/bpf/verifier.c | 25 +++++++++++++++++++++----
 1 file changed, 21 insertions(+), 4 deletions(-)

diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index e74fb1b..cdbf282 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -823,10 +823,27 @@ static int check_pkt_ptr_alignment(const struct bpf_reg_state *reg,
 }
 
 static int check_val_ptr_alignment(const struct bpf_reg_state *reg,
-				   int size, bool strict)
+				   int off, int size, bool strict)
 {
-	if (strict && size != 1) {
-		verbose("Unknown alignment. Only byte-sized access allowed in value access.\n");
+	int reg_off;
+
+	/* Byte size accesses are always allowed. */
+	if (!strict || size == 1)
+		return 0;
+
+	reg_off = reg->off;
+	if (reg->id) {
+		if (reg->aux_off_align % size) {
+			verbose("Value access is only %u byte aligned, %d byte access not allowed\n",
+				reg->aux_off_align, size);
+			return -EACCES;
+		}
+		reg_off += reg->aux_off;
+	}
+
+	if ((reg_off + off) % size != 0) {
+		verbose("misaligned value access off %d+%d size %d\n",
+			reg_off, off, size);
 		return -EACCES;
 	}
 
@@ -846,7 +863,7 @@ static int check_ptr_alignment(struct bpf_verifier_env *env,
 	case PTR_TO_PACKET:
 		return check_pkt_ptr_alignment(reg, off, size, strict);
 	case PTR_TO_MAP_VALUE_ADJ:
-		return check_val_ptr_alignment(reg, size, strict);
+		return check_val_ptr_alignment(reg, off, size, strict);
 	default:
 		if (off % size != 0) {
 			verbose("misaligned access off %d size %d\n",
-- 
2.1.2.532.g19b5d50
