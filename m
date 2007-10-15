From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH] Ensure that pneigh_lookup is protected with RTNL
Date: Mon, 15 Oct 2007 17:38:57 +0400
Message-ID: <47136D71.4000108@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:38681 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756984AbXJONlt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Oct 2007 09:41:49 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The pnigh_lookup is used to lookup proxy entries and to 
create them in case lookup failed. 

However, the "creation" code does not perform the re-lookup
after GFP_KERNEL allocation. This is done because the code
is expected to be protected with the RTNL lock, so add the 
assertion (mainly to address future questions from new network 
developers like me :) ).

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index c52df85..cd3af59 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -481,6 +481,8 @@ struct pneigh_entry * pneigh_lookup(struct neigh_table *tbl, const void *pkey,
 	if (!creat)
 		goto out;
 
+	ASSERT_RTNL();
+
 	n = kmalloc(sizeof(*n) + key_len, GFP_KERNEL);
 	if (!n)
 		goto out;

