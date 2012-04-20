From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 09/16] tipc: Ensure network address change doesn't impact new port
Date: Fri, 20 Apr 2012 17:05:17 -0400
Message-ID: <1334955924-907-10-git-send-email-paul.gortmaker@windriver.com>
References: <1334955924-907-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <allan.stephens@windriver.com>,
	<ying.xue@windriver.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:65459 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754285Ab2DTVFh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Apr 2012 17:05:37 -0400
In-Reply-To: <1334955924-907-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Re-orders port creation logic so that the initialization of a new
port's message header template occurs while the port list lock is
held. This ensures that a change to the node's network address that
occurs at the same time as the port is being created does not result
in the template identifying the sender using the former network
address. The new approach guarantees that the new port's template is
using the current network address or that it will be updated when
the address changes.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/port.c |   15 +++++++++++----
 1 file changed, 11 insertions(+), 4 deletions(-)

diff --git a/net/tipc/port.c b/net/tipc/port.c
index 6156c67..3b7162c 100644
--- a/net/tipc/port.c
+++ b/net/tipc/port.c
@@ -221,18 +221,25 @@ struct tipc_port *tipc_createport_raw(void *usr_handle,
 	p_ptr->usr_handle = usr_handle;
 	p_ptr->max_pkt = MAX_PKT_DEFAULT;
 	p_ptr->ref = ref;
-	msg = &p_ptr->phdr;
-	tipc_msg_init(msg, importance, TIPC_NAMED_MSG, NAMED_H_SIZE, 0);
-	msg_set_origport(msg, ref);
 	INIT_LIST_HEAD(&p_ptr->wait_list);
 	INIT_LIST_HEAD(&p_ptr->subscription.nodesub_list);
 	p_ptr->dispatcher = dispatcher;
 	p_ptr->wakeup = wakeup;
 	p_ptr->user_port = NULL;
 	k_init_timer(&p_ptr->timer, (Handler)port_timeout, ref);
-	spin_lock_bh(&tipc_port_list_lock);
 	INIT_LIST_HEAD(&p_ptr->publications);
 	INIT_LIST_HEAD(&p_ptr->port_list);
+
+	/*
+	 * Must hold port list lock while initializing message header template
+	 * to ensure a change to node's own network address doesn't result
+	 * in template containing out-dated network address information
+	 */
+
+	spin_lock_bh(&tipc_port_list_lock);
+	msg = &p_ptr->phdr;
+	tipc_msg_init(msg, importance, TIPC_NAMED_MSG, NAMED_H_SIZE, 0);
+	msg_set_origport(msg, ref);
 	list_add_tail(&p_ptr->port_list, &ports);
 	spin_unlock_bh(&tipc_port_list_lock);
 	return p_ptr;
-- 
1.7.9.3
