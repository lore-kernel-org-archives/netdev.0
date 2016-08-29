From: Sargun Dhillon <sargun@sargun.me>
Subject: [net-next RFC v2 1/9] net: Make cgroup sk data present when calling
 security_sk_(alloc/free)
Date: Mon, 29 Aug 2016 04:45:59 -0700
Message-ID: <20160829114557.GA20842@ircssh.c.rugged-nimbus-611.internal>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: cgroups@vger.kernel.org, linux-security-module@vger.kernel.org,
        daniel@iogearbox.net, ast@fb.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f52.google.com ([209.85.214.52]:36329 "EHLO
        mail-it0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932642AbcH2LqB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 29 Aug 2016 07:46:01 -0400
Received: by mail-it0-f52.google.com with SMTP id e63so97689076ith.1
        for <netdev@vger.kernel.org>; Mon, 29 Aug 2016 04:46:01 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch changes the order of allocations / calls to allocate the
sock_cgroup_data before calling security_sk_alloc. In addition, this
patch also reorders the deallocation when calling security_sk_free
so that LSMs can examine the cgroup that a particular sk belongs to.

Signed-off-by: Sarguun Dhillon <sargun@sargun.me>
---
 net/core/sock.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/core/sock.c b/net/core/sock.c
index 51a7304..3f12f4d 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1333,6 +1333,7 @@ static struct sock *sk_prot_alloc(struct proto *prot, gfp_t priority,
 
 	if (sk != NULL) {
 		kmemcheck_annotate_bitfield(sk, flags);
+		cgroup_sk_alloc(&sk->sk_cgrp_data);
 
 		if (security_sk_alloc(sk, family, priority))
 			goto out_free;
@@ -1340,7 +1341,6 @@ static struct sock *sk_prot_alloc(struct proto *prot, gfp_t priority,
 		if (!try_module_get(prot->owner))
 			goto out_free_sec;
 		sk_tx_queue_clear(sk);
-		cgroup_sk_alloc(&sk->sk_cgrp_data);
 	}
 
 	return sk;
@@ -1348,6 +1348,7 @@ static struct sock *sk_prot_alloc(struct proto *prot, gfp_t priority,
 out_free_sec:
 	security_sk_free(sk);
 out_free:
+	cgroup_sk_free(&sk->sk_cgrp_data);
 	if (slab != NULL)
 		kmem_cache_free(slab, sk);
 	else
@@ -1363,8 +1364,8 @@ static void sk_prot_free(struct proto *prot, struct sock *sk)
 	owner = prot->owner;
 	slab = prot->slab;
 
-	cgroup_sk_free(&sk->sk_cgrp_data);
 	security_sk_free(sk);
+	cgroup_sk_free(&sk->sk_cgrp_data);
 	if (slab != NULL)
 		kmem_cache_free(slab, sk);
 	else
-- 
2.7.4
