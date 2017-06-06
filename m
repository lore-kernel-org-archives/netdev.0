From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next] bpf: cgroup skb progs cannot access ld_abs/ind
Date: Tue,  6 Jun 2017 18:38:04 +0200
Message-ID: <1851c3df45588eb96803995a3ceff32819612386.1496766858.git.daniel@iogearbox.net>
Cc: netdev@vger.kernel.org, fengc@google.com, ast@kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:55687 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751200AbdFFQid (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Jun 2017 12:38:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit fb9a307d11d6 ("bpf: Allow CGROUP_SKB eBPF program to
access sk_buff") enabled programs of BPF_PROG_TYPE_CGROUP_SKB
type to use ld_abs/ind instructions. However, at this point,
we cannot use them, since offsets relative to SKF_LL_OFF will
end up pointing skb_mac_header(skb) out of bounds since in the
egress path it is not yet set at that point in time, but only
after __dev_queue_xmit() did a general reset on the mac header.
bpf_internal_load_pointer_neg_helper() will then end up reading
data from a wrong offset.

BPF_PROG_TYPE_CGROUP_SKB programs can use bpf_skb_load_bytes()
already to access packet data, which is also more flexible than
the insns carried over from cBPF.

Fixes: fb9a307d11d6 ("bpf: Allow CGROUP_SKB eBPF program to access sk_buff")
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
Cc: Chenbo Feng <fengc@google.com>
---
 kernel/bpf/verifier.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 8acae64..14ccb07 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -2426,7 +2426,6 @@ static bool may_access_skb(enum bpf_prog_type type)
 	case BPF_PROG_TYPE_SOCKET_FILTER:
 	case BPF_PROG_TYPE_SCHED_CLS:
 	case BPF_PROG_TYPE_SCHED_ACT:
-	case BPF_PROG_TYPE_CGROUP_SKB:
 		return true;
 	default:
 		return false;
-- 
1.9.3
