From: Daniel Mack <daniel@zonque.org>
Subject: [PATCH v8 4/6] net: filter: run cgroup eBPF ingress programs
Date: Thu, 17 Nov 2016 19:27:07 +0100
Message-ID: <1479407229-14861-5-git-send-email-daniel@zonque.org>
References: <1479407229-14861-1-git-send-email-daniel@zonque.org>
Cc: davem@davemloft.net, kafai@fb.com, fw@strlen.de,
        pablo@netfilter.org, harald@redhat.com, netdev@vger.kernel.org,
        sargun@sargun.me, cgroups@vger.kernel.org,
        Daniel Mack <daniel@zonque.org>
To: htejun@fb.com, daniel@iogearbox.net, ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from svenfoo.org ([82.94.215.22]:55756 "EHLO mail.zonque.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754272AbcKQS1Y (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 17 Nov 2016 13:27:24 -0500
In-Reply-To: <1479407229-14861-1-git-send-email-daniel@zonque.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the cgroup associated with the receiving socket has an eBPF
programs installed, run them from sk_filter_trim_cap().

eBPF programs used in this context are expected to either return 1 to
let the packet pass, or != 1 to drop them. The programs have access to
the skb through bpf_skb_load_bytes(), and the payload starts at the
network headers (L3).

Note that cgroup_bpf_run_filter() is stubbed out as static inline nop
for !CONFIG_CGROUP_BPF, and is otherwise guarded by a static key if
the feature is unused.

Signed-off-by: Daniel Mack <daniel@zonque.org>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 net/core/filter.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/core/filter.c b/net/core/filter.c
index e3813d6..474b486 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -78,6 +78,10 @@ int sk_filter_trim_cap(struct sock *sk, struct sk_buff *skb, unsigned int cap)
 	if (skb_pfmemalloc(skb) && !sock_flag(sk, SOCK_MEMALLOC))
 		return -ENOMEM;
 
+	err = BPF_CGROUP_RUN_PROG_INET_INGRESS(sk, skb);
+	if (err)
+		return err;
+
 	err = security_sock_rcv_skb(sk, skb);
 	if (err)
 		return err;
-- 
2.7.4
