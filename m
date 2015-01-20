From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 3/3] netlink: Lock out table resizes while dumping Netlink sockets
Date: Tue, 20 Jan 2015 14:20:27 +0100
Message-ID: <e164edeacaeffee43be64d4ed6a5b5e7e8923bd1.1421759056.git.tgraf@suug.ch>
References: <cover.1421759056.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: davem@davemloft.net, kaber@trash.net, herbert@gondor.apana.org.au,
	paulmck@linux.vnet.ibm.com, ying.xue@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:49340 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755111AbbATNUk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2015 08:20:40 -0500
In-Reply-To: <cover.1421759056.git.tgraf@suug.ch>
In-Reply-To: <cover.1421759056.git.tgraf@suug.ch>
References: <cover.1421759056.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Lock out table resizes while dumping Netlink sockets to user space.
This keeps disruptions to a minimum for readers which don't handle
the NLM_F_DUMP_INTR flag.

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 net/netlink/diag.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/netlink/diag.c b/net/netlink/diag.c
index 50aa385..be4ea6e 100644
--- a/net/netlink/diag.c
+++ b/net/netlink/diag.c
@@ -114,6 +114,8 @@ static int __netlink_diag_dump(struct sk_buff *skb, struct netlink_callback *cb,
 	req = nlmsg_data(cb->nlh);
 	cb->seq = atomic_read(&nl_table_seq);
 
+	mutex_lock(&ht->mutex);
+
 	for (i = 0; i < htbl->size; i++) {
 		struct rhash_head *pos;
 
@@ -161,6 +163,7 @@ static int __netlink_diag_dump(struct sk_buff *skb, struct netlink_callback *cb,
 		num++;
 	}
 done:
+	mutex_unlock(&ht->mutex);
 	cb->args[0] = num;
 	cb->args[1] = protocol;
 
-- 
1.9.3
