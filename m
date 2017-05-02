From: David Miller <davem@davemloft.net>
Subject: remaining sparc bpf hacks...
Date: Tue, 02 May 2017 12:04:23 -0400 (EDT)
Message-ID: <20170502.120423.475636847240486813.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, netdev@vger.kernel.org
To: ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50548 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751014AbdEBQE3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 2 May 2017 12:04:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


So I just have two issues remaining for test_progs to run properly
on sparc.  We've discussed them before.

The first is the clang Makefile hack:

diff --git a/tools/testing/selftests/bpf/Makefile b/tools/testing/selftests/bpf/Makefile
index d8d94b9..2ed63b6 100644
--- a/tools/testing/selftests/bpf/Makefile
+++ b/tools/testing/selftests/bpf/Makefile
@@ -35,5 +35,5 @@ CLANG ?= clang
 
 %.o: %.c
 	$(CLANG) -I../../../include/uapi -I../../../../samples/bpf/ \
-		-D__x86_64__ -Wno-compare-distinct-pointer-types \
+		-D__sparc__ -Wno-compare-distinct-pointer-types \
 		-O2 -target bpf -c $< -o $@

which should be reasonably easy to deal with.

The second is more difficult:

diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index c2ff608..bb99677 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -801,8 +801,12 @@ static int check_ptr_alignment(const struct bpf_reg_state *reg,
 {
 	switch (reg->type) {
 	case PTR_TO_PACKET:
+#if 1
+		return 0;
+#else
 		return IS_ENABLED(CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS) ? 0 :
 		       check_pkt_ptr_alignment(reg, off, size);
+#endif
 	case PTR_TO_MAP_VALUE_ADJ:
 		return IS_ENABLED(CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS) ? 0 :
 		       check_val_ptr_alignment(reg, size);

Studying over the verifier yesterday I figure we can add an
"alignment" attribute to registers, and track this.

The packet pointer entering a function starts with a weird "modulo
NET_IP_ALIGN" relative alignment, so we have to take that into
consideration.

Then for operations like shift left and multiply by constants, we can
record a known minimum alignment.  The most common case is, of course,
"iph->ihl << 2"

And later when registers with known alignment are added to a packet
pointer, we can constrain the alignment of the destination register.
