From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 49/53] netfilter: evict stale entries when user reads /proc/net/nf_conntrack
Date: Mon, 26 Sep 2016 01:06:59 +0200
Message-ID: <1474844823-2026-50-git-send-email-pablo@netfilter.org>
References: <1474844823-2026-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:54830 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1034905AbcIYXIK (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 25 Sep 2016 19:08:10 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id C3FAEDA914
        for <netdev@vger.kernel.org>; Mon, 26 Sep 2016 01:08:08 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id B2387DA817
        for <netdev@vger.kernel.org>; Mon, 26 Sep 2016 01:08:08 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 9617ADA81A
        for <netdev@vger.kernel.org>; Mon, 26 Sep 2016 01:08:06 +0200 (CEST)
In-Reply-To: <1474844823-2026-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

Fabian reports a possible conntrack memory leak (could not reproduce so
far), however, one minor issue can be easily resolved:

> cat /proc/net/nf_conntrack | wc -l = 5
> 4 minutes required to clean up the table.

We should not report those timed-out entries to the user in first place.
And instead of just skipping those timed-out entries while iterating over
the table we can also zap them (we already do this during ctnetlink
walks, but I forgot about the /proc interface).

Fixes: f330a7fdbe16 ("netfilter: conntrack: get rid of conntrack timer")
Reported-by: Fabian Frederick <fabf@skynet.be>
Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_standalone.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/net/netfilter/nf_conntrack_standalone.c b/net/netfilter/nf_conntrack_standalone.c
index 7d52f8401afd..5f446cd9f3fd 100644
--- a/net/netfilter/nf_conntrack_standalone.c
+++ b/net/netfilter/nf_conntrack_standalone.c
@@ -212,6 +212,11 @@ static int ct_seq_show(struct seq_file *s, void *v)
 	if (unlikely(!atomic_inc_not_zero(&ct->ct_general.use)))
 		return 0;
 
+	if (nf_ct_should_gc(ct)) {
+		nf_ct_kill(ct);
+		goto release;
+	}
+
 	/* we only want to print DIR_ORIGINAL */
 	if (NF_CT_DIRECTION(hash))
 		goto release;
-- 
2.1.4
