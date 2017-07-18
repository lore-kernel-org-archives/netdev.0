From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 5/5] netfilter: expect: fix crash when putting uninited expectation
Date: Tue, 18 Jul 2017 12:13:59 +0200
Message-ID: <1500372839-6735-6-git-send-email-pablo@netfilter.org>
References: <1500372839-6735-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:44366 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751434AbdGRKOT (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 18 Jul 2017 06:14:19 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id B65B4A417F
        for <netdev@vger.kernel.org>; Tue, 18 Jul 2017 12:14:03 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id A69F1D1CAF
        for <netdev@vger.kernel.org>; Tue, 18 Jul 2017 12:14:03 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 01661CA6C1
        for <netdev@vger.kernel.org>; Tue, 18 Jul 2017 12:14:00 +0200 (CEST)
In-Reply-To: <1500372839-6735-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

We crash in __nf_ct_expect_check, it calls nf_ct_remove_expect on the
uninitialised expectation instead of existing one, so del_timer chokes
on random memory address.

Fixes: ec0e3f01114ad32711243 ("netfilter: nf_ct_expect: Add nf_ct_remove_expect()")
Reported-by: Sergey Kvachonok <ravenexp@gmail.com>
Tested-by: Sergey Kvachonok <ravenexp@gmail.com>
Cc: Gao Feng <fgao@ikuai8.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_expect.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/nf_conntrack_expect.c b/net/netfilter/nf_conntrack_expect.c
index e03d16ed550d..899c2c36da13 100644
--- a/net/netfilter/nf_conntrack_expect.c
+++ b/net/netfilter/nf_conntrack_expect.c
@@ -422,7 +422,7 @@ static inline int __nf_ct_expect_check(struct nf_conntrack_expect *expect)
 	h = nf_ct_expect_dst_hash(net, &expect->tuple);
 	hlist_for_each_entry_safe(i, next, &nf_ct_expect_hash[h], hnode) {
 		if (expect_matches(i, expect)) {
-			if (nf_ct_remove_expect(expect))
+			if (nf_ct_remove_expect(i))
 				break;
 		} else if (expect_clash(i, expect)) {
 			ret = -EBUSY;
-- 
2.1.4
