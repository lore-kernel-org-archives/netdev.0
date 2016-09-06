From: Daniel Mack <daniel@zonque.org>
Subject: [PATCH v4 4/6] net: filter: run cgroup eBPF ingress programs
Date: Tue,  6 Sep 2016 15:46:06 +0200
Message-ID: <1473169568-30525-5-git-send-email-daniel@zonque.org>
References: <1473169568-30525-1-git-send-email-daniel@zonque.org>
Cc: davem@davemloft.net, kafai@fb.com, fw@strlen.de,
        pablo@netfilter.org, harald@redhat.com, netdev@vger.kernel.org,
        sargun@sargun.me, cgroups@vger.kernel.org,
        Daniel Mack <daniel@zonque.org>
To: htejun@fb.com, daniel@iogearbox.net, ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from svenfoo.org ([82.94.215.22]:38336 "EHLO mail.zonque.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756157AbcIFNqT (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 6 Sep 2016 09:46:19 -0400
In-Reply-To: <1473169568-30525-1-git-send-email-daniel@zonque.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the cgroup associated with the receiving socket has an eBPF
programs installed, run them from sk_filter_trim_cap().

eBPF programs used in this context are expected to either return 1 to
let the packet pass, or != 1 to drop them. The programs have access to
the full skb, including the MAC headers.

Note that cgroup_bpf_run_filter() is stubbed out as static inline nop
for !CONFIG_CGROUP_BPF, and is otherwise guarded by a static key if
the feature is unused.

Signed-off-by: Daniel Mack <daniel@zonque.org>
---
 net/core/filter.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/core/filter.c b/net/core/filter.c
index 176b6f2..3662c1a 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -78,6 +78,10 @@ int sk_filter_trim_cap(struct sock *sk, struct sk_buff *skb, unsigned int cap)
 	if (skb_pfmemalloc(skb) && !sock_flag(sk, SOCK_MEMALLOC))
 		return -ENOMEM;
 
+	err = cgroup_bpf_run_filter(sk, skb, BPF_CGROUP_INET_INGRESS);
+	if (err)
+		return err;
+
 	err = security_sock_rcv_skb(sk, skb);
 	if (err)
 		return err;
-- 
2.5.5
