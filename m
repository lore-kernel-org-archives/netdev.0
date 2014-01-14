From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next 03/10] eql: use __dev_get_by_name instead of dev_get_by_name to find interface
Date: Tue, 14 Jan 2014 15:41:02 +0800
Message-ID: <1389685269-18600-4-git-send-email-ying.xue@windriver.com>
References: <1389685269-18600-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <vfalico@redhat.com>, <john.r.fastabend@intel.com>,
	<stephen@networkplumber.org>, <antonio@meshcoding.com>,
	<dmitry.tarnyagin@lockless.no>, <socketcan@hartkopp.net>,
	<johannes@sipsolutions.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:41285 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752066AbaANHlw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jan 2014 02:41:52 -0500
In-Reply-To: <1389685269-18600-1-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following call chain indicates that eql_ioctl(), eql_enslave(),
eql_emancipate(), eql_g_slave_cfg() and eql_s_slave_cfg() are
protected under rtnl_lock. So if we use __dev_get_by_name() instead
of dev_get_by_name() to find interface handlers in them, this would
help us avoid to change interface reference counters.

dev_ioctl()
  rtnl_lock()
    dev_ifsioc()
      eql_ioctl()
        eql_enslave()
	eql_emancipate()
	eql_g_slave_cfg()
	eql_s_slave_cfg()
  rtnl_unlock()

Additionally we also change their return values from -EINVAL to
-ENODEV in case that interfaces are no found.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
---
 drivers/net/eql.c |   95 +++++++++++++++++++++++------------------------------
 1 file changed, 42 insertions(+), 53 deletions(-)

diff --git a/drivers/net/eql.c b/drivers/net/eql.c
index f219d38..7a79b60 100644
--- a/drivers/net/eql.c
+++ b/drivers/net/eql.c
@@ -395,6 +395,7 @@ static int __eql_insert_slave(slave_queue_t *queue, slave_t *slave)
 		if (duplicate_slave)
 			eql_kill_one_slave(queue, duplicate_slave);
 
+		dev_hold(slave->dev);
 		list_add(&slave->list, &queue->all_slaves);
 		queue->num_slaves++;
 		slave->dev->flags |= IFF_SLAVE;
@@ -413,39 +414,35 @@ static int eql_enslave(struct net_device *master_dev, slaving_request_t __user *
 	if (copy_from_user(&srq, srqp, sizeof (slaving_request_t)))
 		return -EFAULT;
 
-	slave_dev  = dev_get_by_name(&init_net, srq.slave_name);
-	if (slave_dev) {
-		if ((master_dev->flags & IFF_UP) == IFF_UP) {
-			/* slave is not a master & not already a slave: */
-			if (!eql_is_master(slave_dev) &&
-			    !eql_is_slave(slave_dev)) {
-				slave_t *s = kmalloc(sizeof(*s), GFP_KERNEL);
-				equalizer_t *eql = netdev_priv(master_dev);
-				int ret;
-
-				if (!s) {
-					dev_put(slave_dev);
-					return -ENOMEM;
-				}
-
-				memset(s, 0, sizeof(*s));
-				s->dev = slave_dev;
-				s->priority = srq.priority;
-				s->priority_bps = srq.priority;
-				s->priority_Bps = srq.priority / 8;
-
-				spin_lock_bh(&eql->queue.lock);
-				ret = __eql_insert_slave(&eql->queue, s);
-				if (ret) {
-					dev_put(slave_dev);
-					kfree(s);
-				}
-				spin_unlock_bh(&eql->queue.lock);
-
-				return ret;
-			}
+	slave_dev = __dev_get_by_name(&init_net, srq.slave_name);
+	if (!slave_dev)
+		return -ENODEV;
+
+	if ((master_dev->flags & IFF_UP) == IFF_UP) {
+		/* slave is not a master & not already a slave: */
+		if (!eql_is_master(slave_dev) && !eql_is_slave(slave_dev)) {
+			slave_t *s = kmalloc(sizeof(*s), GFP_KERNEL);
+			equalizer_t *eql = netdev_priv(master_dev);
+			int ret;
+
+			if (!s)
+				return -ENOMEM;
+
+			memset(s, 0, sizeof(*s));
+			s->dev = slave_dev;
+			s->priority = srq.priority;
+			s->priority_bps = srq.priority;
+			s->priority_Bps = srq.priority / 8;
+
+			spin_lock_bh(&eql->queue.lock);
+			ret = __eql_insert_slave(&eql->queue, s);
+			if (ret)
+				kfree(s);
+
+			spin_unlock_bh(&eql->queue.lock);
+
+			return ret;
 		}
-		dev_put(slave_dev);
 	}
 
 	return -EINVAL;
@@ -461,24 +458,20 @@ static int eql_emancipate(struct net_device *master_dev, slaving_request_t __use
 	if (copy_from_user(&srq, srqp, sizeof (slaving_request_t)))
 		return -EFAULT;
 
-	slave_dev = dev_get_by_name(&init_net, srq.slave_name);
-	ret = -EINVAL;
-	if (slave_dev) {
-		spin_lock_bh(&eql->queue.lock);
-
-		if (eql_is_slave(slave_dev)) {
-			slave_t *slave = __eql_find_slave_dev(&eql->queue,
-							      slave_dev);
+	slave_dev = __dev_get_by_name(&init_net, srq.slave_name);
+	if (!slave_dev)
+		return -ENODEV;
 
-			if (slave) {
-				eql_kill_one_slave(&eql->queue, slave);
-				ret = 0;
-			}
+	ret = -EINVAL;
+	spin_lock_bh(&eql->queue.lock);
+	if (eql_is_slave(slave_dev)) {
+		slave_t *slave = __eql_find_slave_dev(&eql->queue, slave_dev);
+		if (slave) {
+			eql_kill_one_slave(&eql->queue, slave);
+			ret = 0;
 		}
-		dev_put(slave_dev);
-
-		spin_unlock_bh(&eql->queue.lock);
 	}
+	spin_unlock_bh(&eql->queue.lock);
 
 	return ret;
 }
@@ -494,7 +487,7 @@ static int eql_g_slave_cfg(struct net_device *dev, slave_config_t __user *scp)
 	if (copy_from_user(&sc, scp, sizeof (slave_config_t)))
 		return -EFAULT;
 
-	slave_dev = dev_get_by_name(&init_net, sc.slave_name);
+	slave_dev = __dev_get_by_name(&init_net, sc.slave_name);
 	if (!slave_dev)
 		return -ENODEV;
 
@@ -510,8 +503,6 @@ static int eql_g_slave_cfg(struct net_device *dev, slave_config_t __user *scp)
 	}
 	spin_unlock_bh(&eql->queue.lock);
 
-	dev_put(slave_dev);
-
 	if (!ret && copy_to_user(scp, &sc, sizeof (slave_config_t)))
 		ret = -EFAULT;
 
@@ -529,7 +520,7 @@ static int eql_s_slave_cfg(struct net_device *dev, slave_config_t __user *scp)
 	if (copy_from_user(&sc, scp, sizeof (slave_config_t)))
 		return -EFAULT;
 
-	slave_dev = dev_get_by_name(&init_net, sc.slave_name);
+	slave_dev = __dev_get_by_name(&init_net, sc.slave_name);
 	if (!slave_dev)
 		return -ENODEV;
 
@@ -548,8 +539,6 @@ static int eql_s_slave_cfg(struct net_device *dev, slave_config_t __user *scp)
 	}
 	spin_unlock_bh(&eql->queue.lock);
 
-	dev_put(slave_dev);
-
 	return ret;
 }
 
-- 
1.7.9.5
