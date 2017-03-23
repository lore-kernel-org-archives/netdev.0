From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH net-next 2/2] net: bridge: allow to add externally learned entries from user-space
Date: Thu, 23 Mar 2017 12:27:13 +0200
Message-ID: <1490264833-28867-3-git-send-email-nikolay@cumulusnetworks.com>
References: <1490264833-28867-1-git-send-email-nikolay@cumulusnetworks.com>
Cc: idosch@mellanox.com, jiri@resnulli.us, stephen@networkplumber.org,
        bridge@lists.linux-foundation.org, roopa@cumulusnetworks.com,
        davem@davemloft.net,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f175.google.com ([209.85.128.175]:34101 "EHLO
        mail-wr0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754642AbdCWK3A (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 23 Mar 2017 06:29:00 -0400
Received: by mail-wr0-f175.google.com with SMTP id l37so144315038wrc.1
        for <netdev@vger.kernel.org>; Thu, 23 Mar 2017 03:28:59 -0700 (PDT)
In-Reply-To: <1490264833-28867-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The NTF_EXT_LEARNED flag was added for switchdev and externally learned
entries, but it can also be used for entries learned via a software
in user-space which requires dynamic entries that do not expire.
One such case that we have is with quagga and evpn which need dynamic
entries but also require to age them themselves.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 net/bridge/br_fdb.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index e4c8adf517ea..7e5902e69f85 100644
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@ -857,6 +857,8 @@ static int __br_fdb_add(struct ndmsg *ndm, struct net_bridge *br,
 		br_fdb_update(br, p, addr, vid, true);
 		rcu_read_unlock();
 		local_bh_enable();
+	} else if (ndm->ndm_flags & NTF_EXT_LEARNED) {
+		err = br_fdb_external_learn_add(br, p, addr, vid);
 	} else {
 		spin_lock_bh(&br->hash_lock);
 		err = fdb_add_entry(br, p, addr, ndm->ndm_state,
-- 
2.1.4
