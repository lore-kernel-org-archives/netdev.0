From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v3 08/12] ipv4: fib: Allow for consistent FIB dumping
Date: Wed, 30 Nov 2016 11:09:02 +0100
Message-ID: <1480500546-2544-9-git-send-email-jiri@resnulli.us>
References: <1480500546-2544-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, arkadis@mellanox.com,
        ogerlitz@mellanox.com, roopa@cumulusnetworks.com,
        dsa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
        andy@greyhouse.net, vivien.didelot@savoirfairelinux.com,
        andrew@lunn.ch, f.fainelli@gmail.com, alexander.h.duyck@intel.com,
        hannes@stressinduktion.org, kaber@trash.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f194.google.com ([209.85.210.194]:33522 "EHLO
        mail-wj0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755401AbcK3KJT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 05:09:19 -0500
Received: by mail-wj0-f194.google.com with SMTP id kp2so21492689wjc.0
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2016 02:09:18 -0800 (PST)
In-Reply-To: <1480500546-2544-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

The next patch will enable listeners of the FIB notification chain to
request a dump of the FIB tables. However, since RTNL isn't taken during
the dump, it's possible for the FIB tables to change mid-dump, which
will result in inconsistency between the listener's table and the
kernel's.

Allow listeners to know about changes that occurred mid-dump, by adding
a change sequence counter to each net namespace. The counter is
incremented just before a notification is sent in the FIB chain.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/net/netns/ipv4.h | 3 +++
 net/ipv4/fib_frontend.c  | 2 ++
 net/ipv4/fib_trie.c      | 1 +
 3 files changed, 6 insertions(+)

diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index 7adf438..f0cf5a1 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -135,6 +135,9 @@ struct netns_ipv4 {
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
 	int sysctl_fib_multipath_use_neigh;
 #endif
+
+	unsigned int	fib_seq;	/* protected by rtnl_mutex */
+
 	atomic_t	rt_genid;
 };
 #endif
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 121384b..dbad5a1 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -1219,6 +1219,8 @@ static int __net_init ip_fib_net_init(struct net *net)
 	int err;
 	size_t size = sizeof(struct hlist_head) * FIB_TABLE_HASHSZ;
 
+	net->ipv4.fib_seq = 0;
+
 	/* Avoid false sharing : Use at least a full cache line */
 	size = max_t(size_t, size, L1_CACHE_BYTES);
 
diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 9bfce0d..2891356 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -101,6 +101,7 @@ EXPORT_SYMBOL(unregister_fib_notifier);
 int call_fib_notifiers(struct net *net, enum fib_event_type event_type,
 		       struct fib_notifier_info *info)
 {
+	net->ipv4.fib_seq++;
 	info->net = net;
 	return atomic_notifier_call_chain(&fib_chain, event_type, info);
 }
-- 
2.7.4
