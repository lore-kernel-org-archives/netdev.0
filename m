From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 1/3] bpf: use skb_to_full_sk helper in bpf_skb_under_cgroup
Date: Fri, 23 Sep 2016 01:28:35 +0200
Message-ID: <6240d4a6e0a810999c06b7dc169cccde98806897.1474586162.git.daniel@iogearbox.net>
References: <cover.1474586162.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:42482 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757295AbcIVX2y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Sep 2016 19:28:54 -0400
In-Reply-To: <cover.1474586162.git.daniel@iogearbox.net>
In-Reply-To: <cover.1474586162.git.daniel@iogearbox.net>
References: <cover.1474586162.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We need to use skb_to_full_sk() helper introduced in commit bd5eb35f16a9
("xfrm: take care of request sockets") as otherwise we miss tcp synack
messages, since ownership is on request socket and therefore it would
miss the sk_fullsock() check. Use skb_to_full_sk() as also done similarly
in the bpf_get_cgroup_classid() helper via 2309236c13fe ("cls_cgroup:
get sk_classid only from full sockets") fix to not let this fall through.

Fixes: 4a482f34afcc ("cgroup: bpf: Add bpf_skb_in_cgroup_proto")
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 net/core/filter.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/filter.c b/net/core/filter.c
index 0920c2a..e5d9977 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -2408,7 +2408,7 @@ BPF_CALL_3(bpf_skb_under_cgroup, struct sk_buff *, skb, struct bpf_map *, map,
 	struct cgroup *cgrp;
 	struct sock *sk;
 
-	sk = skb->sk;
+	sk = skb_to_full_sk(skb);
 	if (!sk || !sk_fullsock(sk))
 		return -ENOENT;
 	if (unlikely(idx >= array->map.max_entries))
-- 
1.9.3
