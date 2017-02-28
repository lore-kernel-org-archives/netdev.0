From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net] sctp: call rcu_read_lock before checking for duplicate transport nodes
Date: Tue, 28 Feb 2017 12:41:29 +0800
Message-ID: <d239fb1c1f86e3421de4a891f8a704d37b236cbf.1488256889.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        Vlad Yasevich <vyasevich@gmail.com>,
        Andrey Konovalov <andreyknvl@google.com>
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:36747 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751356AbdB1Eyk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Feb 2017 23:54:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit cd2b70875058 ("sctp: check duplicate node before inserting a
new transport") called rhltable_lookup() to check for the duplicate
transport node in transport rhashtable.

But rhltable_lookup() doesn't call rcu_read_lock inside, it could cause
a use-after-free issue if it tries to dereference the node that another
cpu has freed it. Note that sock lock can not avoid this as it is per
sock.

This patch is to fix it by calling rcu_read_lock before checking for
duplicate transport nodes.

Fixes: cd2b70875058 ("sctp: check duplicate node before inserting a new transport")
Reported-by: Andrey Konovalov <andreyknvl@google.com>
Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 net/sctp/input.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/sctp/input.c b/net/sctp/input.c
index fc45896..2a28ab2 100644
--- a/net/sctp/input.c
+++ b/net/sctp/input.c
@@ -884,14 +884,17 @@ int sctp_hash_transport(struct sctp_transport *t)
 	arg.paddr = &t->ipaddr;
 	arg.lport = htons(t->asoc->base.bind_addr.port);
 
+	rcu_read_lock();
 	list = rhltable_lookup(&sctp_transport_hashtable, &arg,
 			       sctp_hash_params);
 
 	rhl_for_each_entry_rcu(transport, tmp, list, node)
 		if (transport->asoc->ep == t->asoc->ep) {
+			rcu_read_unlock();
 			err = -EEXIST;
 			goto out;
 		}
+	rcu_read_unlock();
 
 	err = rhltable_insert_key(&sctp_transport_hashtable, &arg,
 				  &t->node, sctp_hash_params);
-- 
2.1.0
