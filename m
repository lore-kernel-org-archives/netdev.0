From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] net: fix dev_seq_next()
Date: Thu, 27 Jan 2011 05:08:02 +0100
Message-ID: <1296101282.1783.54.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:51331 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752639Ab1A0EII (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jan 2011 23:08:08 -0500
Received: by wyb28 with SMTP id 28so1684935wyb.19
        for <netdev@vger.kernel.org>; Wed, 26 Jan 2011 20:08:06 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Paul, the following comment in include/linux/rculist.h is misleading :

"Why is there no list_empty_rcu()?  Because list_empty() serves this
purpose..."

This is probably why I made the error ;)

list_empty() has a meaning only if state cannot change right after its
use.

In an rcu_read_lock() section, state _can_ change, so there is no way
list_empty() can be used at all.

Thanks

[PATCH net-next-2.6] net: fix dev_seq_next()

Commit c6d14c84566d (net: Introduce for_each_netdev_rcu() iterator)
added a race in dev_seq_next().

The rcu_dereference() call should be done _before_ testing the end of
list, or we might return a wrong net_device if a concurrent thread
changes net_device list under us.

Note : discovered thanks to a sparse warning :

net/core/dev.c:3919:9: error: incompatible types in comparison expression
(different address spaces)

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
---
Given this was discovered by code analysis rather than a bug report, I
prepared a patch for net-next-2.6. Once fully tested, this could be
backported to 2.6.33

 include/linux/netdevice.h |    9 ++++++++-
 net/core/dev.c            |   11 +++++++----
 2 files changed, 15 insertions(+), 5 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 8858422..c7d7074 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1447,7 +1447,7 @@ static inline struct net_device *next_net_device_rcu(struct net_device *dev)
 	struct net *net;
 
 	net = dev_net(dev);
-	lh = rcu_dereference(dev->dev_list.next);
+	lh = rcu_dereference(list_next_rcu(&dev->dev_list));
 	return lh == &net->dev_base_head ? NULL : net_device_entry(lh);
 }
 
@@ -1457,6 +1457,13 @@ static inline struct net_device *first_net_device(struct net *net)
 		net_device_entry(net->dev_base_head.next);
 }
 
+static inline struct net_device *first_net_device_rcu(struct net *net)
+{
+	struct list_head *lh = rcu_dereference(list_next_rcu(&net->dev_base_head));
+
+	return lh == &net->dev_base_head ? NULL : net_device_entry(lh);
+}
+
 extern int 			netdev_boot_setup_check(struct net_device *dev);
 extern unsigned long		netdev_boot_base(const char *prefix, int unit);
 extern struct net_device *dev_getbyhwaddr_rcu(struct net *net, unsigned short type,
diff --git a/net/core/dev.c b/net/core/dev.c
index 1b4c07f..ddd5df2 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4051,12 +4051,15 @@ void *dev_seq_start(struct seq_file *seq, loff_t *pos)
 
 void *dev_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 {
-	struct net_device *dev = (v == SEQ_START_TOKEN) ?
-				  first_net_device(seq_file_net(seq)) :
-				  next_net_device((struct net_device *)v);
+	struct net_device *dev = v;
+
+	if (v == SEQ_START_TOKEN)
+		dev = first_net_device_rcu(seq_file_net(seq));
+	else
+		dev = next_net_device_rcu(dev);
 
 	++*pos;
-	return rcu_dereference(dev);
+	return dev;
 }
 
 void dev_seq_stop(struct seq_file *seq, void *v)


