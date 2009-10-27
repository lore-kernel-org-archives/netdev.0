From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] net: fold network name hash
Date: Tue, 27 Oct 2009 10:22:51 -0700
Message-ID: <20091027102251.244ee681@nehalam>
References: <9986527.24561256620662709.JavaMail.root@tahiti.vyatta.com>
 <19864844.24581256620784317.JavaMail.root@tahiti.vyatta.com>
 <20091026.222428.80364204.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	eric.dumazet@gmail.com, akpm@linux-foundation.org,
	torvalds@linux-foundation.org, opurdila@ixiacom.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	viro@zeniv.linux.org.uk
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:54287 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751884AbZJ0RWx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Oct 2009 13:22:53 -0400
In-Reply-To: <20091026.222428.80364204.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The full_name_hash does not produce a value that is evenly distributed
over the lower 8 bits. This causes name hash to be unbalanced with large
number of names.  A simple fix is to just fold in the higher bits
with XOR.

This is independent of possible improvements to full_name_hash()
in future.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/net/core/dev.c	2009-10-27 09:21:46.127252547 -0700
+++ b/net/core/dev.c	2009-10-27 09:25:14.593313378 -0700
@@ -199,7 +199,11 @@ EXPORT_SYMBOL(dev_base_lock);
 static inline struct hlist_head *dev_name_hash(struct net *net, const char *name)
 {
 	unsigned hash = full_name_hash(name, strnlen(name, IFNAMSIZ));
-	return &net->dev_name_head[hash & ((1 << NETDEV_HASHBITS) - 1)];
+
+	hash ^= (hash >> NETDEV_HASHBITS);
+	hash &= NETDEV_HASHENTRIES - 1;
+
+	return &net->dev_name_head[hash];
 }
 
 static inline struct hlist_head *dev_index_hash(struct net *net, int ifindex)
