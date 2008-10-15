From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 3/7] netns ebtables: more cleanup during
	ebt_unregister_table()
Date: Wed, 15 Oct 2008 08:22:46 +0400
Message-ID: <20081015042246.GG24058@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	containers@osdl.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.24]:43170 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751098AbYJOETu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Oct 2008 00:19:50 -0400
Received: by ey-out-2122.google.com with SMTP id 6so914662eyi.37
        for <netdev@vger.kernel.org>; Tue, 14 Oct 2008 21:19:48 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that ebt_unregister_table() can be called during netns stop, and module
pinning scheme can't prevent netns stop, do table cleanup by hand.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 net/bridge/netfilter/ebtables.c |    4 ++++
 1 file changed, 4 insertions(+)

--- a/net/bridge/netfilter/ebtables.c
+++ b/net/bridge/netfilter/ebtables.c
@@ -1216,6 +1216,10 @@ void ebt_unregister_table(struct ebt_table *table)
 	mutex_lock(&ebt_mutex);
 	list_del(&table->list);
 	mutex_unlock(&ebt_mutex);
+	EBT_ENTRY_ITERATE(table->private->entries, table->private->entries_size,
+			  ebt_cleanup_entry, NULL);
+	if (table->private->nentries)
+		module_put(table->me);
 	vfree(table->private->entries);
 	if (table->private->chainstack) {
 		for_each_possible_cpu(i)
