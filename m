From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next] bpf: add napi_id read access to __sk_buff
Date: Wed, 19 Apr 2017 23:01:17 +0200
Message-ID: <9f477418c0db1091bfb119ef8c159f18384d6100.1492635441.git.daniel@iogearbox.net>
Cc: edumazet@google.com, alexei.starovoitov@gmail.com,
        netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:34118 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965641AbdDSVB3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Apr 2017 17:01:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add napi_id access to __sk_buff for socket filter program types, tc
program types and other bpf_convert_ctx_access() users. Having access
to skb->napi_id is useful for per RX queue listener siloing, f.e.
in combination with SO_ATTACH_REUSEPORT_EBPF and when busy polling is
used, meaning SO_REUSEPORT enabled listeners can then select the
corresponding socket at SYN time already [1]. The skb is marked via
skb_mark_napi_id() early in the receive path (e.g., napi_gro_receive()).

Currently, sockets can only use SO_INCOMING_NAPI_ID from 6d4339028b35
("net: Introduce SO_INCOMING_NAPI_ID") as a socket option to look up
the NAPI ID associated with the queue for steering, which requires a
prior sk_mark_napi_id() after the socket was looked up.

Semantics for the __sk_buff napi_id access are similar, meaning if
skb->napi_id is < MIN_NAPI_ID (e.g. outgoing packets using sender_cpu),
then an invalid napi_id of 0 is returned to the program, otherwise a
valid non-zero napi_id.

  [1] http://netdevconf.org/2.1/slides/apr6/dumazet-BUSY-POLLING-Netdev-2.1.pdf

Suggested-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 include/uapi/linux/bpf.h                    |  1 +
 net/core/filter.c                           | 14 ++++++++++++++
 tools/include/uapi/linux/bpf.h              |  1 +
 tools/testing/selftests/bpf/test_verifier.c |  3 +++
 4 files changed, 19 insertions(+)

diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 1e062bb..e553529 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -603,6 +603,7 @@ struct __sk_buff {
 	__u32 tc_classid;
 	__u32 data;
 	__u32 data_end;
+	__u32 napi_id;
 };
 
 struct bpf_tunnel_key {
diff --git a/net/core/filter.c b/net/core/filter.c
index 19be954..70ff8c0 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -53,6 +53,7 @@
 #include <net/dst_metadata.h>
 #include <net/dst.h>
 #include <net/sock_reuseport.h>
+#include <net/busy_poll.h>
 
 /**
  *	sk_filter_trim_cap - run a packet through a socket filter
@@ -3202,6 +3203,19 @@ static u32 bpf_convert_ctx_access(enum bpf_access_type type,
 			*insn++ = BPF_MOV64_IMM(si->dst_reg, 0);
 #endif
 		break;
+
+	case offsetof(struct __sk_buff, napi_id):
+#if defined(CONFIG_NET_RX_BUSY_POLL)
+		BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, napi_id) != 4);
+
+		*insn++ = BPF_LDX_MEM(BPF_W, si->dst_reg, si->src_reg,
+				      offsetof(struct sk_buff, napi_id));
+		*insn++ = BPF_JMP_IMM(BPF_JGE, si->dst_reg, MIN_NAPI_ID, 1);
+		*insn++ = BPF_MOV64_IMM(si->dst_reg, 0);
+#else
+		*insn++ = BPF_MOV64_IMM(si->dst_reg, 0);
+#endif
+		break;
 	}
 
 	return insn - insn_buf;
diff --git a/tools/include/uapi/linux/bpf.h b/tools/include/uapi/linux/bpf.h
index 1e062bb..e553529 100644
--- a/tools/include/uapi/linux/bpf.h
+++ b/tools/include/uapi/linux/bpf.h
@@ -603,6 +603,7 @@ struct __sk_buff {
 	__u32 tc_classid;
 	__u32 data;
 	__u32 data_end;
+	__u32 napi_id;
 };
 
 struct bpf_tunnel_key {
diff --git a/tools/testing/selftests/bpf/test_verifier.c b/tools/testing/selftests/bpf/test_verifier.c
index 6178b65..95a8d5f 100644
--- a/tools/testing/selftests/bpf/test_verifier.c
+++ b/tools/testing/selftests/bpf/test_verifier.c
@@ -772,6 +772,9 @@ struct test_val {
 			BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_1,
 				    offsetof(struct __sk_buff, vlan_tci)),
 			BPF_JMP_IMM(BPF_JGE, BPF_REG_0, 0, 0),
+			BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_1,
+				    offsetof(struct __sk_buff, napi_id)),
+			BPF_JMP_IMM(BPF_JGE, BPF_REG_0, 0, 0),
 			BPF_EXIT_INSN(),
 		},
 		.result = ACCEPT,
-- 
1.9.3
