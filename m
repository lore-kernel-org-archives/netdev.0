From: John Fastabend <john.r.fastabend@gmail.com>
Subject: [net PATCH 3/5] bpf: remove mark access for SK_SKB program types
Date: Wed, 18 Oct 2017 07:10:58 -0700
Message-ID: <150833585867.3588.14935777843137354788.stgit@john-XPS-13-9360>
References: <150833522977.3588.14633565129152334098.stgit@john-XPS-13-9360>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, borkmann@iogearbox.net
To: alexei.starovoitov@gmail.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:49493 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750942AbdJROLP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2017 10:11:15 -0400
Received: by mail-pf0-f193.google.com with SMTP id i5so4050983pfe.6
        for <netdev@vger.kernel.org>; Wed, 18 Oct 2017 07:11:15 -0700 (PDT)
In-Reply-To: <150833522977.3588.14633565129152334098.stgit@john-XPS-13-9360>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.fastabend@gmail.com>

The skb->mark field is a union with reserved_tailroom which is used
in the TCP code paths from stream memory allocation. Allowing SK_SKB
programs to set this field creates a conflict with future code
optimizations, such as "gifting" the skb to the egress path instead
of creating a new skb and doing a memcpy.

Because we do not have a released version of SK_SKB yet lets just
remove it for now. A more appropriate scratch pad to use at the
socket layer is dev_scratch, but lets add that in future kernels
when needed.

Signed-off-by: John Fastabend <john.fastabend@gmail.com>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
---
 net/core/filter.c                           |    2 +-
 tools/testing/selftests/bpf/test_verifier.c |   16 ++++++++++++++--
 2 files changed, 15 insertions(+), 3 deletions(-)

diff --git a/net/core/filter.c b/net/core/filter.c
index ca1ba0b..aa02659 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -3684,7 +3684,6 @@ static bool sk_skb_is_valid_access(int off, int size,
 {
 	if (type == BPF_WRITE) {
 		switch (off) {
-		case bpf_ctx_range(struct __sk_buff, mark):
 		case bpf_ctx_range(struct __sk_buff, tc_index):
 		case bpf_ctx_range(struct __sk_buff, priority):
 			break;
@@ -3694,6 +3693,7 @@ static bool sk_skb_is_valid_access(int off, int size,
 	}
 
 	switch (off) {
+	case bpf_ctx_range(struct __sk_buff, mark):
 	case bpf_ctx_range(struct __sk_buff, tc_classid):
 		return false;
 	case bpf_ctx_range(struct __sk_buff, data):
diff --git a/tools/testing/selftests/bpf/test_verifier.c b/tools/testing/selftests/bpf/test_verifier.c
index 26f3250..16cca57 100644
--- a/tools/testing/selftests/bpf/test_verifier.c
+++ b/tools/testing/selftests/bpf/test_verifier.c
@@ -1130,15 +1130,27 @@ static struct bpf_test tests[] = {
 		.errstr = "invalid bpf_context access",
 	},
 	{
-		"check skb->mark is writeable by SK_SKB",
+		"invalid access of skb->mark for SK_SKB",
+		.insns = {
+			BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_1,
+				    offsetof(struct __sk_buff, mark)),
+			BPF_EXIT_INSN(),
+		},
+		.result =  REJECT,
+		.prog_type = BPF_PROG_TYPE_SK_SKB,
+		.errstr = "invalid bpf_context access",
+	},
+	{
+		"check skb->mark is not writeable by SK_SKB",
 		.insns = {
 			BPF_MOV64_IMM(BPF_REG_0, 0),
 			BPF_STX_MEM(BPF_W, BPF_REG_1, BPF_REG_0,
 				    offsetof(struct __sk_buff, mark)),
 			BPF_EXIT_INSN(),
 		},
-		.result = ACCEPT,
+		.result =  REJECT,
 		.prog_type = BPF_PROG_TYPE_SK_SKB,
+		.errstr = "invalid bpf_context access",
 	},
 	{
 		"check skb->tc_index is writeable by SK_SKB",
