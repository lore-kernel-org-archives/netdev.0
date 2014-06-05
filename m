From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH net] net: filter: fix SKF_AD_PKTTYPE extension on big-endian
Date: Thu,  5 Jun 2014 14:39:36 -0700
Message-ID: <1402004376-1814-1-git-send-email-ast@plumgrid.com>
Cc: Daniel Borkmann <dborkman@redhat.com>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:55678 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751466AbaFEVju (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2014 17:39:50 -0400
Received: by mail-pd0-f178.google.com with SMTP id v10so1639221pde.9
        for <netdev@vger.kernel.org>; Thu, 05 Jun 2014 14:39:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

BPF classic->internal converter broke SKF_AD_PKTTYPE extension, since
pkt_type_offset() was failing to find skb->pkt_type field which is defined as:
__u8 pkt_type:3,
     fclone:2,
     ipvs_property:1,
     peeked:1,
     nf_trace:1;

Fix it by searching for 3 most significant bits and shift them by 5 at run-time

Fixes: bd4cf0ed331a ("net: filter: rework/optimize internal BPF interpreter's instruction set")
Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
Acked-by: Daniel Borkmann <dborkman@redhat.com>
Tested-by: Daniel Borkmann <dborkman@redhat.com>
---

backported BPF testsuite to 'net' and tested with qemu-sparc64.
Daniel tested it on s390.

Dave,
The fix doesn't apply cleanly to 'net-next'.
There 2nd hunk needs to be:
               insn++;
               *insn = BPF_ALU32_IMM(BPF_RSH, BPF_REG_A, 5);
I have 'net-next' patch ready and tested as well. Let me know if I should
send it or you'll take care of it while doing the merge of 'net'.

 net/core/filter.c |   11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/net/core/filter.c b/net/core/filter.c
index 4aec7b9..ab3c74e 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -578,7 +578,11 @@ EXPORT_SYMBOL_GPL(sk_run_filter_int_skb);
  * to make sure its still a 3bit field starting at a byte boundary;
  * taken from arch/x86/net/bpf_jit_comp.c.
  */
+#ifdef __BIG_ENDIAN_BITFIELD
+#define PKT_TYPE_MAX	(7 << 5)
+#else
 #define PKT_TYPE_MAX	7
+#endif
 static unsigned int pkt_type_offset(void)
 {
 	struct sk_buff skb_probe = { .pkt_type = ~0, };
@@ -685,6 +689,13 @@ static bool convert_bpf_extensions(struct sock_filter *fp,
 		insn->code = BPF_ALU | BPF_AND | BPF_K;
 		insn->a_reg = A_REG;
 		insn->imm = PKT_TYPE_MAX;
+#ifdef __BIG_ENDIAN_BITFIELD
+		insn++;
+
+		insn->code = BPF_ALU | BPF_RSH | BPF_K;
+		insn->a_reg = A_REG;
+		insn->imm = 5;
+#endif
 		break;
 
 	case SKF_AD_OFF + SKF_AD_IFINDEX:
-- 
1.7.9.5
