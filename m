From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 2/2] decnet: convert dndev_lock to spinlock
Date: Wed, 11 Nov 2009 09:40:36 -0800
Message-ID: <20091111094036.736762da@nehalam>
References: <20091110175446.280423729@vyatta.com>
	<20091110175647.615305929@vyatta.com>
	<4AF9B449.6040708@gmail.com>
	<20091110105053.16687e93@nehalam>
	<20091110182436.GA13374@fogou.chygwyn.com>
	<20091111093927.4a08999d@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Christine Caulfield <christine.caulfield@googlemail.com>,
	Hannes Eder <hannes@hanneseder.net>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Steven Whitehouse <swhiteho@redhat.com>,
	netdev@vger.kernel.org, linux-decnet-users@lists.sourceforge.net
To: steve@chygwyn.com, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:57004 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758373AbZKKRlL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Nov 2009 12:41:11 -0500
In-Reply-To: <20091111093927.4a08999d@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is no reason for this lock to be reader/writer since
the reader only has lock held for a very brief period.
The overhead of read_lock is more expensive than spinlock.

Compile tested only, I am not a decnet user.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/decnet/dn_dev.c	2009-11-10 17:39:53.652984752 -0800
+++ b/net/decnet/dn_dev.c	2009-11-10 17:41:15.942736073 -0800
@@ -68,7 +68,7 @@ extern struct neigh_table dn_neigh_table
  */
 __le16 decnet_address = 0;
 
-static DEFINE_RWLOCK(dndev_lock);
+static DEFINE_SPINLOCK(dndev_lock);
 static struct net_device *decnet_default_device;
 static BLOCKING_NOTIFIER_HEAD(dnaddr_chain);
 
@@ -557,7 +557,8 @@ rarok:
 struct net_device *dn_dev_get_default(void)
 {
 	struct net_device *dev;
-	read_lock(&dndev_lock);
+
+	spin_lock(&dndev_lock);
 	dev = decnet_default_device;
 	if (dev) {
 		if (dev->dn_ptr)
@@ -565,7 +566,8 @@ struct net_device *dn_dev_get_default(vo
 		else
 			dev = NULL;
 	}
-	read_unlock(&dndev_lock);
+	spin_unlock(&dndev_lock);
+
 	return dev;
 }
 
@@ -575,13 +577,15 @@ int dn_dev_set_default(struct net_device
 	int rv = -EBUSY;
 	if (!dev->dn_ptr)
 		return -ENODEV;
-	write_lock(&dndev_lock);
+
+	spin_lock(&dndev_lock);
 	if (force || decnet_default_device == NULL) {
 		old = decnet_default_device;
 		decnet_default_device = dev;
 		rv = 0;
 	}
-	write_unlock(&dndev_lock);
+	spin_unlock(&dndev_lock);
+
 	if (old)
 		dev_put(old);
 	return rv;
@@ -589,13 +593,14 @@ int dn_dev_set_default(struct net_device
 
 static void dn_dev_check_default(struct net_device *dev)
 {
-	write_lock(&dndev_lock);
+	spin_lock(&dndev_lock);
 	if (dev == decnet_default_device) {
 		decnet_default_device = NULL;
 	} else {
 		dev = NULL;
 	}
-	write_unlock(&dndev_lock);
+	spin_unlock(&dndev_lock);
+
 	if (dev)
 		dev_put(dev);
 }

