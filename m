From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp/dccp: add SLAB_DESTROY_BY_RCU flag for request
 sockets
Date: Sat, 03 Oct 2015 06:27:28 -0700
Message-ID: <1443878848.32531.70.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:35264 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752609AbbJCN1a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Oct 2015 09:27:30 -0400
Received: by pacfv12 with SMTP id fv12so134614369pac.2
        for <netdev@vger.kernel.org>; Sat, 03 Oct 2015 06:27:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Before letting request sockets being put in TCP/DCCP regular
ehash table, we need to add either :

- SLAB_DESTROY_BY_RCU flag to their kmem_cache
- add RCU grace period before freeing them.

Since we carefully respected the SLAB_DESTROY_BY_RCU protocol
like ESTABLISH and TIMEWAIT sockets, use it here.

req_prot_init() being only used by TCP and DCCP, I did not add
a new slab_flags into their rsk_prot, but reuse prot->slab_flags

Since all reqsk_alloc() users are correctly dealing with a failure,
add the __GFP_NOWARN flag to avoid traces under pressure.

Fixes: 079096f103fa ("tcp/dccp: install syn_recv requests into ehash table")
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/request_sock.h |    4 +++-
 net/core/sock.c            |    2 +-
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/include/net/request_sock.h b/include/net/request_sock.h
index bae6936d75c4..dd423d840852 100644
--- a/include/net/request_sock.h
+++ b/include/net/request_sock.h
@@ -82,7 +82,9 @@ static inline struct sock *req_to_sk(struct request_sock *req)
 static inline struct request_sock *
 reqsk_alloc(const struct request_sock_ops *ops, struct sock *sk_listener)
 {
-	struct request_sock *req = kmem_cache_alloc(ops->slab, GFP_ATOMIC);
+	struct request_sock *req;
+
+	req = kmem_cache_alloc(ops->slab, GFP_ATOMIC | __GFP_NOWARN);
 
 	if (req) {
 		req->rsk_ops = ops;
diff --git a/net/core/sock.c b/net/core/sock.c
index 3307c02244d3..7dd1263e4c24 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -2758,7 +2758,7 @@ static int req_prot_init(const struct proto *prot)
 
 	rsk_prot->slab = kmem_cache_create(rsk_prot->slab_name,
 					   rsk_prot->obj_size, 0,
-					   0, NULL);
+					   prot->slab_flags, NULL);
 
 	if (!rsk_prot->slab) {
 		pr_crit("%s: Can't create request sock SLAB cache!\n",
