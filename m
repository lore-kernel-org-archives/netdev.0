From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 22/53] netfilter: ecache: Refine the nf_ct_deliver_cached_events
Date: Mon,  1 May 2017 12:46:49 +0200
Message-ID: <1493635640-24325-23-git-send-email-pablo@netfilter.org>
References: <1493635640-24325-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:49700 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S376821AbdEAKsB (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 1 May 2017 06:48:01 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 6D6AE20991F
        for <netdev@vger.kernel.org>; Mon,  1 May 2017 12:47:47 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 5A49DFF145
        for <netdev@vger.kernel.org>; Mon,  1 May 2017 12:47:47 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 2F60FFF2D5
        for <netdev@vger.kernel.org>; Mon,  1 May 2017 12:47:45 +0200 (CEST)
In-Reply-To: <1493635640-24325-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao Feng <fgao@ikuai8.com>

1. Remove single !events condition check to deliver the missed event
even though there is no new event happened.

Consider this case:
1) nf_ct_deliver_cached_events is invoked at the first time, the
event is failed to deliver, then the missed is set.
2) nf_ct_deliver_cached_events is invoked again, but there is no
any new event happened.
The missed event is lost really.

It would try to send the missed event again after remove this check.
And it is ok if there is no missed event because the latter check
!((events | missed) & e->ctmask) could avoid it.

2. Correct the return value check of notify->fcn.
When send the event successfully, it returns 0, not postive value.

Signed-off-by: Gao Feng <fgao@ikuai8.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_ecache.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/nf_conntrack_ecache.c b/net/netfilter/nf_conntrack_ecache.c
index 22fc32143e9c..6161e92d2980 100644
--- a/net/netfilter/nf_conntrack_ecache.c
+++ b/net/netfilter/nf_conntrack_ecache.c
@@ -195,7 +195,7 @@ void nf_ct_deliver_cached_events(struct nf_conn *ct)
 
 	events = xchg(&e->cache, 0);
 
-	if (!nf_ct_is_confirmed(ct) || nf_ct_is_dying(ct) || !events)
+	if (!nf_ct_is_confirmed(ct) || nf_ct_is_dying(ct))
 		goto out_unlock;
 
 	/* We make a copy of the missed event cache without taking
@@ -212,7 +212,7 @@ void nf_ct_deliver_cached_events(struct nf_conn *ct)
 
 	ret = notify->fcn(events | missed, &item);
 
-	if (likely(ret >= 0 && !missed))
+	if (likely(ret == 0 && !missed))
 		goto out_unlock;
 
 	spin_lock_bh(&ct->lock);
-- 
2.1.4
