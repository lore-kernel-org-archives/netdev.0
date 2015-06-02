From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH net 1/2] s390/bpf: fix stack allocation
Date: Mon,  1 Jun 2015 22:48:34 -0700
Message-ID: <1433224115-28411-1-git-send-email-ast@plumgrid.com>
Cc: Michael Holzheu <holzheu@linux.vnet.ibm.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:35054 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755045AbbFBFsn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2015 01:48:43 -0400
Received: by pdbnf5 with SMTP id nf5so64025880pdb.2
        for <netdev@vger.kernel.org>; Mon, 01 Jun 2015 22:48:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Holzheu <holzheu@linux.vnet.ibm.com>

On s390x we have to provide 160 bytes stack space before we can call
the next function. From the 160 bytes that we got from the previous
function we only use 11 * 8 bytes and have 160 - 11 * 8 bytes left.
Currently for BPF we allocate additional 160 - 11 * 8 bytes for the
next function. This is wrong because then the next function only gets:

 (160 - 11 * 8) + (160 - 11 * 8) = 2 * 72 = 144 bytes

Fix this and allocate enough memory for the next function.

Fixes: 054623105728 ("s390/bpf: Add s390x eBPF JIT compiler backend")
Signed-off-by: Michael Holzheu <holzheu@linux.vnet.ibm.com>
Acked-by: Heiko Carstens <heiko.carstens@de.ibm.com>
Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---

Resubmitting against 'net' with proper 'Fixes' tag.

 arch/s390/net/bpf_jit.h |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/arch/s390/net/bpf_jit.h b/arch/s390/net/bpf_jit.h
index ba8593a515ba..de156ba3bd71 100644
--- a/arch/s390/net/bpf_jit.h
+++ b/arch/s390/net/bpf_jit.h
@@ -48,7 +48,9 @@ extern u8 sk_load_word[], sk_load_half[], sk_load_byte[];
  * We get 160 bytes stack space from calling function, but only use
  * 11 * 8 byte (old backchain + r15 - r6) for storing registers.
  */
-#define STK_OFF (MAX_BPF_STACK + 8 + 4 + 4 + (160 - 11 * 8))
+#define STK_SPACE	(MAX_BPF_STACK + 8 + 4 + 4 + 160)
+#define STK_160_UNUSED	(160 - 11 * 8)
+#define STK_OFF		(STK_SPACE - STK_160_UNUSED)
 #define STK_OFF_TMP	160	/* Offset of tmp buffer on stack */
 #define STK_OFF_HLEN	168	/* Offset of SKB header length on stack */
 
-- 
1.7.9.5
