From: Siva Mannem <siva.mannem.lnx@gmail.com>
Subject: [PATCH net-next v4 2/3] newly configured FDB ageing time becomes effective immediately
Date: Tue, 17 Mar 2015 04:32:43 +0530
Message-ID: <80d2d6e6efcafd636712f8bf91c8f002d1d7692d.1426509272.git.siva.mannem.lnx@gmail.com>
References: <cover.1426509272.git.siva.mannem.lnx@gmail.com>
Cc: davem@davemloft.net, sfeldma@gmail.com,
	Siva Mannem <siva.mannem.lnx@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:34303 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964797AbbCPXDV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2015 19:03:21 -0400
Received: by pacwe9 with SMTP id we9so78201674pac.1
        for <netdev@vger.kernel.org>; Mon, 16 Mar 2015 16:03:20 -0700 (PDT)
In-Reply-To: <cover.1426509272.git.siva.mannem.lnx@gmail.com>
In-Reply-To: <cover.1426509272.git.siva.mannem.lnx@gmail.com>
References: <cover.1426509272.git.siva.mannem.lnx@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch ensures that the newly configured FDB ageing time becomes effective
immediately. It also makes the behavior consistent when the ageing_timer is set 
using any of the three existing mechanisms(sysfs, ioctl, netlink).

Signed-off-by: Siva Mannem <siva.mannem.lnx@gmail.com>
Suggested-by: Scott Feldman <sfeldma@gmail.com>
---
 net/bridge/br_device.c   | 4 ++++
 net/bridge/br_ioctl.c    | 3 +--
 net/bridge/br_sysfs_br.c | 8 +-------
 3 files changed, 6 insertions(+), 9 deletions(-)

diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index 1a665aa..293a113 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -396,12 +396,16 @@ void br_dev_setup(struct net_device *dev)
 int br_set_ageing_time(struct net_bridge *br, unsigned long val)
 {
 	unsigned long t = clock_t_to_jiffies(val);
+	unsigned long old_ageing_time;
 
 	if (t < BR_MIN_AGEING_TIME || t > BR_MAX_AGEING_TIME)
 		return -ERANGE;
 
 	spin_lock_bh(&br->lock);
+	old_ageing_time =  br->ageing_time;
 	br->ageing_time = t;
+	if (br->ageing_time < old_ageing_time)
+		mod_timer(&br->gc_timer, jiffies);
 	spin_unlock_bh(&br->lock);
 	return 0;
 }
diff --git a/net/bridge/br_ioctl.c b/net/bridge/br_ioctl.c
index a9a4a1b..4f836e2 100644
--- a/net/bridge/br_ioctl.c
+++ b/net/bridge/br_ioctl.c
@@ -200,8 +200,7 @@ static int old_dev_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 		if (!ns_capable(dev_net(dev)->user_ns, CAP_NET_ADMIN))
 			return -EPERM;
 
-		br->ageing_time = clock_t_to_jiffies(args[1]);
-		return 0;
+		return br_set_ageing_time(br, args[1]);
 
 	case BRCTL_GET_PORT_INFO:
 	{
diff --git a/net/bridge/br_sysfs_br.c b/net/bridge/br_sysfs_br.c
index 4c97fc5..1fc2857 100644
--- a/net/bridge/br_sysfs_br.c
+++ b/net/bridge/br_sysfs_br.c
@@ -100,17 +100,11 @@ static ssize_t ageing_time_show(struct device *d,
 	return sprintf(buf, "%lu\n", jiffies_to_clock_t(br->ageing_time));
 }
 
-static int set_ageing_time(struct net_bridge *br, unsigned long val)
-{
-	br->ageing_time = clock_t_to_jiffies(val);
-	return 0;
-}
-
 static ssize_t ageing_time_store(struct device *d,
 				 struct device_attribute *attr,
 				 const char *buf, size_t len)
 {
-	return store_bridge_parm(d, buf, len, set_ageing_time);
+	return store_bridge_parm(d, buf, len, br_set_ageing_time);
 }
 static DEVICE_ATTR_RW(ageing_time);
 
-- 
2.1.0
