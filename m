From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] net: fold network name hash (v2)
Date: Tue, 27 Oct 2009 15:04:36 -0700
Message-ID: <20091027150436.56e673cd@nehalam>
References: <9986527.24561256620662709.JavaMail.root@tahiti.vyatta.com>
	<19864844.24581256620784317.JavaMail.root@tahiti.vyatta.com>
	<20091026.222428.80364204.davem@davemloft.net>
	<20091027102251.244ee681@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, eric.dumazet@gmail.com,
	akpm@linux-foundation.org, torvalds@linux-foundation.org,
	opurdila@ixiacom.com, viro@zeniv.linux.org.uk
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756820AbZJ0WEn@vger.kernel.org>
In-Reply-To: <20091027102251.244ee681@nehalam>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The full_name_hash does not produce a value that is evenly distributed
over the lower 8 bits. This causes name hash to be unbalanced with large
number of names. There is a standard function to fold in upper bits
so use that.

This is independent of possible improvements to full_name_hash()
in future.
 
Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/core/dev.c	2009-10-27 14:54:21.922563076 -0700
+++ b/net/core/dev.c	2009-10-27 15:04:16.733813459 -0700
@@ -86,6 +86,7 @@
 #include <linux/socket.h>
 #include <linux/sockios.h>
 #include <linux/errno.h>
+#include <linux/hash.h>
 #include <linux/interrupt.h>
 #include <linux/if_ether.h>
 #include <linux/netdevice.h>
@@ -199,7 +200,7 @@ EXPORT_SYMBOL(dev_base_lock);
 static inline struct hlist_head *dev_name_hash(struct net *net, const char *name)
 {
 	unsigned hash = full_name_hash(name, strnlen(name, IFNAMSIZ));
-	return &net->dev_name_head[hash & ((1 << NETDEV_HASHBITS) - 1)];
+	return &net->dev_name_head[hash_long(hash, NETDEV_HASHBITS)];
 }
 
 static inline struct hlist_head *dev_index_hash(struct net *net, int ifindex)
