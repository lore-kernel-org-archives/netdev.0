From: Daniel Mack <daniel-cYrQPVfZoowdnm+yROfE0A@public.gmane.org>
Subject: [PATCH v9 4/6] net: filter: run cgroup eBPF ingress programs
Date: Wed, 23 Nov 2016 16:52:28 +0100
Message-ID: <1479916350-28462-5-git-send-email-daniel@zonque.org>
References: <1479916350-28462-1-git-send-email-daniel@zonque.org>
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, kafai-b10kYP2dOMg@public.gmane.org, fw-HFFVJYpyMKqzQB+pC5nmwQ@public.gmane.org,
        pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org, harald-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Daniel Mack <daniel-cYrQPVfZoowdnm+yROfE0A@public.gmane.org>
To: htejun-b10kYP2dOMg@public.gmane.org, daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org, ast-b10kYP2dOMg@public.gmane.org
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1479916350-28462-1-git-send-email-daniel-cYrQPVfZoowdnm+yROfE0A@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

If the cgroup associated with the receiving socket has an eBPF
programs installed, run them from sk_filter_trim_cap().

eBPF programs used in this context are expected to either return 1 to
let the packet pass, or != 1 to drop them. The programs have access to
the skb through bpf_skb_load_bytes(), and the payload starts at the
network headers (L3).

Note that cgroup_bpf_run_filter() is stubbed out as static inline nop
for !CONFIG_CGROUP_BPF, and is otherwise guarded by a static key if
the feature is unused.

Signed-off-by: Daniel Mack <daniel-cYrQPVfZoowdnm+yROfE0A@public.gmane.org>
Acked-by: Alexei Starovoitov <ast-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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
