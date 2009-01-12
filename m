From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 07/09: simplify nf_conntrack_alloc() error handling
Date: Mon, 12 Jan 2009 11:06:08 +0100 (MET)
Message-ID: <20090112100608.9280.46239.sendpatchset@x2.localnet>
References: <20090112100559.9280.23431.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:60695 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752865AbZALKGJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2009 05:06:09 -0500
In-Reply-To: <20090112100559.9280.23431.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 74259cac7b03c2db8d046aa70aa53f4633290fd9
Author: Julia Lawall <julia@diku.dk>
Date:   Mon Jan 12 10:50:52 2009 +0100

    netfilter: simplify nf_conntrack_alloc() error handling
    
    nf_conntrack_alloc cannot return NULL, so there is no need to check for
    NULL before using the value.  I have also removed the initialization of ct
    to NULL in nf_conntrack_alloc, since the value is never used, and since
    perhaps it might lead one to think that return ct at the end might return
    NULL.
    
    The semantic patch that finds this problem is as follows:
    (http://www.emn.fr/x-info/coccinelle/)
    
    // <smpl>
    @match exists@
    expression x, E;
    position p1,p2;
    statement S1, S2;
    @@
    
    x@p1 = nf_conntrack_alloc(...)
    ... when != x = E
    (
      if (x@p2 == NULL || ...) S1 else S2
    |
      if (x@p2 == NULL && ...) S1 else S2
    )
    
    @other_match exists@
    expression match.x, E1, E2;
    position p1!=match.p1,match.p2;
    @@
    
    x@p1 = E1
    ... when != x = E2
    x@p2
    
    @ script:python depends on !other_match@
    p1 << match.p1;
    p2 << match.p2;
    @@
    
    print "%s: call to nf_conntrack_alloc %s bad test %s" % (p1[0].file,p1[0].line,p2[0].line)
    // </smpl>
    
    Signed-off-by: Julia Lawall <julia@diku.dk>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 7e83f74..90ce9dd 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -469,7 +469,7 @@ struct nf_conn *nf_conntrack_alloc(struct net *net,
 				   const struct nf_conntrack_tuple *repl,
 				   gfp_t gfp)
 {
-	struct nf_conn *ct = NULL;
+	struct nf_conn *ct;
 
 	if (unlikely(!nf_conntrack_hash_rnd_initted)) {
 		get_random_bytes(&nf_conntrack_hash_rnd, 4);
@@ -551,7 +551,7 @@ init_conntrack(struct net *net,
 	}
 
 	ct = nf_conntrack_alloc(net, tuple, &repl_tuple, GFP_ATOMIC);
-	if (ct == NULL || IS_ERR(ct)) {
+	if (IS_ERR(ct)) {
 		pr_debug("Can't allocate conntrack.\n");
 		return (struct nf_conntrack_tuple_hash *)ct;
 	}
diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 00e8c27..3dddec6 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -1134,7 +1134,7 @@ ctnetlink_create_conntrack(struct nlattr *cda[],
 	struct nf_conntrack_helper *helper;
 
 	ct = nf_conntrack_alloc(&init_net, otuple, rtuple, GFP_ATOMIC);
-	if (ct == NULL || IS_ERR(ct))
+	if (IS_ERR(ct))
 		return -ENOMEM;
 
 	if (!cda[CTA_TIMEOUT])
