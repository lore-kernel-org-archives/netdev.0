From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH net-next v2] bpf: pass sk to helper functions
Date: Tue, 11 Apr 2017 14:08:08 -0400
Message-ID: <20170411180808.109636-1-willemdebruijn.kernel@gmail.com>
Cc: ast@fb.com, daniel@iogearbox.net, davem@davemloft.net,
        fengc@google.com, lorenzo@google.com,
        Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f194.google.com ([209.85.216.194]:33741 "EHLO
        mail-qt0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752626AbdDKSIM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Apr 2017 14:08:12 -0400
Received: by mail-qt0-f194.google.com with SMTP id c45so726186qtb.0
        for <netdev@vger.kernel.org>; Tue, 11 Apr 2017 11:08:12 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

BPF helper functions access socket fields through skb->sk. This is not
set in ingress cgroup and socket filters. The association is only made
in skb_set_owner_r once the filter has accepted the packet. Sk is
available as socket lookup has taken place.

Temporarily set skb->sk to sk in these cases.

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 kernel/bpf/cgroup.c | 5 ++++-
 net/core/filter.c   | 7 ++++++-
 2 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/kernel/bpf/cgroup.c b/kernel/bpf/cgroup.c
index da0f53690295..ea6033cba947 100644
--- a/kernel/bpf/cgroup.c
+++ b/kernel/bpf/cgroup.c
@@ -154,7 +154,7 @@ int __cgroup_bpf_update(struct cgroup *cgrp, struct cgroup *parent,
 
 /**
  * __cgroup_bpf_run_filter_skb() - Run a program for packet filtering
- * @sk: The socken sending or receiving traffic
+ * @sk: The socket sending or receiving traffic
  * @skb: The skb that is being sent or received
  * @type: The type of program to be exectuted
  *
@@ -189,10 +189,13 @@ int __cgroup_bpf_run_filter_skb(struct sock *sk,
 	prog = rcu_dereference(cgrp->bpf.effective[type]);
 	if (prog) {
 		unsigned int offset = skb->data - skb_network_header(skb);
+		struct sock *save_sk = skb->sk;
 
+		skb->sk = sk;
 		__skb_push(skb, offset);
 		ret = bpf_prog_run_save_cb(prog, skb) == 1 ? 0 : -EPERM;
 		__skb_pull(skb, offset);
+		skb->sk = save_sk;
 	}
 
 	rcu_read_unlock();
diff --git a/net/core/filter.c b/net/core/filter.c
index 15e9a81ffebe..9b767cde602c 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -92,8 +92,13 @@ int sk_filter_trim_cap(struct sock *sk, struct sk_buff *skb, unsigned int cap)
 	rcu_read_lock();
 	filter = rcu_dereference(sk->sk_filter);
 	if (filter) {
-		unsigned int pkt_len = bpf_prog_run_save_cb(filter->prog, skb);
+		struct sock *save_sk = skb->sk;
+		unsigned int pkt_len;
+
+		skb->sk = sk;
+		pkt_len = bpf_prog_run_save_cb(filter->prog, skb);
 		err = pkt_len ? pskb_trim(skb, max(cap, pkt_len)) : -EPERM;
+		skb->sk = save_sk;
 	}
 	rcu_read_unlock();
 
-- 
2.12.2.715.g7642488e1d-goog
