From: sfeldma@gmail.com
Subject: [PATCH net-next 3/4] bridge: push bridge setting ageing_time down to switchdev
Date: Thu, 24 Sep 2015 13:59:29 -0700
Message-ID: <1443128370-27353-4-git-send-email-sfeldma@gmail.com>
References: <1443128370-27353-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, siva.mannem.lnx@gmail.com, pjonnala@broadcom.com,
	stephen@networkplumber.org, roopa@cumulusnetworks.com,
	andrew@lunn.ch, f.fainelli@gmail.com,
	vivien.didelot@savoirfairelinux.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:36729 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754109AbbIXU4h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Sep 2015 16:56:37 -0400
Received: by pacgz1 with SMTP id gz1so672811pac.3
        for <netdev@vger.kernel.org>; Thu, 24 Sep 2015 13:56:37 -0700 (PDT)
In-Reply-To: <1443128370-27353-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

Use SWITCHDEV_F_SKIP_EOPNOTSUPP to skip over ports in bridge that don't
support setting ageing_time (or setting bridge attrs in general).

If push fails, don't update ageing_time in bridge and return err to user.

If push succeeds, update ageing_time in bridge and run gc_timer now to
recalabrate when to run gc_timer next, based on new ageing_time.

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 net/bridge/br_ioctl.c    |    3 +--
 net/bridge/br_netlink.c  |    6 +++---
 net/bridge/br_private.h  |    1 +
 net/bridge/br_stp.c      |   24 ++++++++++++++++++++++++
 net/bridge/br_sysfs_br.c |    3 +--
 5 files changed, 30 insertions(+), 7 deletions(-)

diff --git a/net/bridge/br_ioctl.c b/net/bridge/br_ioctl.c
index 8d423bc..263b4de 100644
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
diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index ea748c9..6dbdd4d 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -774,9 +774,9 @@ static int br_changelink(struct net_device *brdev, struct nlattr *tb[],
 	}
 
 	if (data[IFLA_BR_AGEING_TIME]) {
-		u32 ageing_time = nla_get_u32(data[IFLA_BR_AGEING_TIME]);
-
-		br->ageing_time = clock_t_to_jiffies(ageing_time);
+		err = br_set_ageing_time(br, nla_get_u32(data[IFLA_BR_AGEING_TIME]));
+		if (err)
+			return err;
 	}
 
 	if (data[IFLA_BR_STP_STATE]) {
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 74e99c7..dc4b390 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -808,6 +808,7 @@ void __br_set_forward_delay(struct net_bridge *br, unsigned long t);
 int br_set_forward_delay(struct net_bridge *br, unsigned long x);
 int br_set_hello_time(struct net_bridge *br, unsigned long x);
 int br_set_max_age(struct net_bridge *br, unsigned long x);
+int br_set_ageing_time(struct net_bridge *br, u32 ageing_time);
 
 
 /* br_stp_if.c */
diff --git a/net/bridge/br_stp.c b/net/bridge/br_stp.c
index ed74ffa..6241bab 100644
--- a/net/bridge/br_stp.c
+++ b/net/bridge/br_stp.c
@@ -566,6 +566,30 @@ int br_set_max_age(struct net_bridge *br, unsigned long val)
 
 }
 
+int br_set_ageing_time(struct net_bridge *br, u32 ageing_time)
+{
+	struct switchdev_attr attr = {
+		.id = SWITCHDEV_ATTR_BRIDGE,
+		.flags = SWITCHDEV_F_SKIP_EOPNOTSUPP,
+		.u.bridge.attr = IFLA_BR_AGEING_TIME,
+		.u.bridge.val = ageing_time,
+	};
+	unsigned long t = clock_t_to_jiffies(ageing_time);
+	int err;
+
+	if (t < BR_MIN_AGEING_TIME || t > BR_MAX_AGEING_TIME)
+		return -ERANGE;
+
+	err = switchdev_port_attr_set(br->dev, &attr);
+	if (err)
+		return err;
+
+	br->ageing_time = t;
+	mod_timer(&br->gc_timer, jiffies);
+
+	return 0;
+}
+
 void __br_set_forward_delay(struct net_bridge *br, unsigned long t)
 {
 	br->bridge_forward_delay = t;
diff --git a/net/bridge/br_sysfs_br.c b/net/bridge/br_sysfs_br.c
index 4c97fc5..04ef192 100644
--- a/net/bridge/br_sysfs_br.c
+++ b/net/bridge/br_sysfs_br.c
@@ -102,8 +102,7 @@ static ssize_t ageing_time_show(struct device *d,
 
 static int set_ageing_time(struct net_bridge *br, unsigned long val)
 {
-	br->ageing_time = clock_t_to_jiffies(val);
-	return 0;
+	return br_set_ageing_time(br, val);
 }
 
 static ssize_t ageing_time_store(struct device *d,
-- 
1.7.10.4
