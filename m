From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 17/53] netfilter: nat: remove rcu_read_lock in __nf_nat_decode_session.
Date: Mon,  1 May 2017 12:46:44 +0200
Message-ID: <1493635640-24325-18-git-send-email-pablo@netfilter.org>
References: <1493635640-24325-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:49772 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S378880AbdEAKsE (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 1 May 2017 06:48:04 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 5BA331F4B9D
        for <netdev@vger.kernel.org>; Mon,  1 May 2017 12:47:43 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 4CDFFFF2D1
        for <netdev@vger.kernel.org>; Mon,  1 May 2017 12:47:43 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 336F3DA870
        for <netdev@vger.kernel.org>; Mon,  1 May 2017 12:47:41 +0200 (CEST)
In-Reply-To: <1493635640-24325-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Taehee Yoo <ap420073@gmail.com>

__nf_nat_decode_session is called from nf_nat_decode_session as decodefn.
before calling decodefn, it already set rcu_read_lock. so rcu_read_lock in
__nf_nat_decode_session can be removed.

Signed-off-by: Taehee Yoo <ap420073@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_nat_core.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/net/netfilter/nf_nat_core.c b/net/netfilter/nf_nat_core.c
index 376c1b36f222..fb0e65411785 100644
--- a/net/netfilter/nf_nat_core.c
+++ b/net/netfilter/nf_nat_core.c
@@ -71,11 +71,10 @@ static void __nf_nat_decode_session(struct sk_buff *skb, struct flowi *fl)
 	if (ct == NULL)
 		return;
 
-	family = ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple.src.l3num;
-	rcu_read_lock();
+	family = nf_ct_l3num(ct);
 	l3proto = __nf_nat_l3proto_find(family);
 	if (l3proto == NULL)
-		goto out;
+		return;
 
 	dir = CTINFO2DIR(ctinfo);
 	if (dir == IP_CT_DIR_ORIGINAL)
@@ -84,8 +83,6 @@ static void __nf_nat_decode_session(struct sk_buff *skb, struct flowi *fl)
 		statusbit = IPS_SRC_NAT;
 
 	l3proto->decode_session(skb, ct, dir, statusbit, fl);
-out:
-	rcu_read_unlock();
 }
 
 int nf_xfrm_me_harder(struct net *net, struct sk_buff *skb, unsigned int family)
-- 
2.1.4
