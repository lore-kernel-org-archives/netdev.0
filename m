From: Rodolfo Giometti <giometti@linux.it>
Subject: [PATCH] net dsa: add new option "master_netdev_autoup"
Date: Mon, 15 Oct 2012 15:33:26 +0200
Message-ID: <1350308008-17189-2-git-send-email-giometti@linux.it>
References: <1350308008-17189-1-git-send-email-giometti@linux.it>
Cc: Lennert Buytenhek <buytenh@wantstofly.org>,
	Rodolfo Giometti <giometti@linux.it>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ip-196-116.sn1.eutelia.it ([62.94.196.116]:13951 "EHLO
	goldrake.enneenne.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753352Ab2JONym (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Oct 2012 09:54:42 -0400
In-Reply-To: <1350308008-17189-1-git-send-email-giometti@linux.it>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

By using this option the user can decide if the master device should
be turned on when one of the slave devices is opened.

This functionality is needed if RootFS over NFS is used throught the
DSA.

Signed-off-by: Rodolfo Giometti <giometti@linux.it>
---
 include/net/dsa.h |    8 ++++++++
 net/dsa/slave.c   |    7 ++++++-
 2 files changed, 14 insertions(+), 1 deletion(-)

diff --git a/include/net/dsa.h b/include/net/dsa.h
index ff07a86..bd3c8b8 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -63,6 +63,14 @@ struct dsa_platform_data {
 	struct device	*netdev;
 
 	/*
+	 * Enable the auto-up of the master device when a slave is
+	 * open.
+	 * This functionality is needed if RootFS over NFS is used
+	 * throught the DSA.
+	 */
+	unsigned long	master_netdev_autoup:1;
+
+	/*
 	 * Info structs describing each of the switch chips
 	 * connected via this network interface.
 	 */
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 4286964..6e9e4546 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -66,9 +66,14 @@ static int dsa_slave_open(struct net_device *dev)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
 	struct net_device *master = p->parent->dst->master_netdev;
+	struct dsa_platform_data *pd = p->parent->dst->pd;
 	int err;
 
-	if (!(master->flags & IFF_UP))
+	if (pd->master_netdev_autoup)
+		err = dev_open(master);
+	else
+		err = !(master->flags & IFF_UP);
+	if (err)
 		return -ENETDOWN;
 
 	if (!ether_addr_equal(dev->dev_addr, master->dev_addr)) {
-- 
1.7.9.5
