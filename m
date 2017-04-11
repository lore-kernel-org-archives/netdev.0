From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH net-next] bpf: pass sk to helper functions
Date: Tue, 11 Apr 2017 12:22:52 -0400
Message-ID: <20170411162252.84985-1-willemdebruijn.kernel@gmail.com>
Cc: ast@fb.com, daniel@iogearbox.net, davem@davemloft.net,
        Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f196.google.com ([209.85.220.196]:34016 "EHLO
        mail-qk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751875AbdDKQWz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Apr 2017 12:22:55 -0400
Received: by mail-qk0-f196.google.com with SMTP id p68so306843qke.1
        for <netdev@vger.kernel.org>; Tue, 11 Apr 2017 09:22:55 -0700 (PDT)
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
 kernel/bpf/cgroup.c | 4 +++-
 net/core/filter.c   | 6 +++++-
 2 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/kernel/bpf/cgroup.c b/kernel/bpf/cgroup.c
index da0f53690295..a2c387e433a4 100644
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
@@ -190,9 +190,11 @@ int __cgroup_bpf_run_filter_skb(struct sock *sk,
 	if (prog) {
 		unsigned int offset = skb->data - skb_network_header(skb);
 
+		swap(skb->sk, sk);
 		__skb_push(skb, offset);
 		ret = bpf_prog_run_save_cb(prog, skb) == 1 ? 0 : -EPERM;
 		__skb_pull(skb, offset);
+		swap(skb->sk, sk);
 	}
 
 	rcu_read_unlock();
diff --git a/net/core/filter.c b/net/core/filter.c
index 15e9a81ffebe..979cb508302a 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -92,8 +92,12 @@ int sk_filter_trim_cap(struct sock *sk, struct sk_buff *skb, unsigned int cap)
 	rcu_read_lock();
 	filter = rcu_dereference(sk->sk_filter);
 	if (filter) {
-		unsigned int pkt_len = bpf_prog_run_save_cb(filter->prog, skb);
+		unsigned int pkt_len;
+
+		swap(skb->sk, sk);
+		pkt_len = bpf_prog_run_save_cb(filter->prog, skb);
 		err = pkt_len ? pskb_trim(skb, max(cap, pkt_len)) : -EPERM;
+		swap(skb->sk, sk);
 	}
 	rcu_read_unlock();
 
-- 
2.12.2.715.g7642488e1d-goog
