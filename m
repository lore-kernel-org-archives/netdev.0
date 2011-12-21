From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 2/3] netlink: use vzalloc()
Date: Wed, 21 Dec 2011 13:48:33 -0800
Message-ID: <20111221134833.76af35e6@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:50866 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752501Ab1LUVt4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Dec 2011 16:49:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The netlink pid hash can be allocated using vzalloc() rather than direct
access to get_free_pages. It is also safe for nl_pid_hash_zalloc to use
GFP_KERNEL since it is only called from netlink_proto_init and
nl_pid_hash_rehash. The former is already allocating table with GFP_KERNEL,
and the latter is called from netlink_insert() which already could 
sleep in netlink_table_grab()

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/netlink/af_netlink.c	2011-12-20 10:20:33.356914405 -0800
+++ b/net/netlink/af_netlink.c	2011-12-20 10:25:19.364247598 -0800
@@ -251,11 +251,9 @@ found:
 static struct hlist_head *nl_pid_hash_zalloc(size_t size)
 {
 	if (size <= PAGE_SIZE)
-		return kzalloc(size, GFP_ATOMIC);
+		return kzalloc(size, GFP_KERNEL);
 	else
-		return (struct hlist_head *)
-			__get_free_pages(GFP_ATOMIC | __GFP_ZERO,
-					 get_order(size));
+		return vzalloc(size);
 }
 
 static void nl_pid_hash_free(struct hlist_head *table, size_t size)
@@ -263,7 +261,7 @@ static void nl_pid_hash_free(struct hlis
 	if (size <= PAGE_SIZE)
 		kfree(table);
 	else
-		free_pages((unsigned long)table, get_order(size));
+		vfree(table);
 }
 
 static int nl_pid_hash_rehash(struct nl_pid_hash *hash, int grow)
