From: Siva Mannem <siva.mannem.lnx@gmail.com>
Subject: [PATCH net-next v3 1/2] Configure bridge FDB ageing time using netlink.
Date: Mon, 16 Mar 2015 12:00:04 +0530
Message-ID: <1426487405-9792-2-git-send-email-siva.mannem.lnx@gmail.com>
References: <1426487405-9792-1-git-send-email-siva.mannem.lnx@gmail.com>
Cc: sfeldma@gmail.com, Siva Mannem <siva.mannem.lnx@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:33984 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751318AbbCPGaZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2015 02:30:25 -0400
Received: by pacwe9 with SMTP id we9so55586577pac.1
        for <netdev@vger.kernel.org>; Sun, 15 Mar 2015 23:30:25 -0700 (PDT)
In-Reply-To: <1426487405-9792-1-git-send-email-siva.mannem.lnx@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch allows user to configure bridge's FDB ageing using
netlink(for ex, iproute2). Allowed range is 10 seconds to 1000000 seconds
as per ieee8021QBridgeFdbAgingTime.

Signed-off-by: Siva Mannem <siva.mannem.lnx@gmail.com>
---
 include/uapi/linux/if_link.h |  1 +
 net/bridge/br_device.c       | 13 +++++++++++++
 net/bridge/br_netlink.c      | 14 ++++++++++++--
 net/bridge/br_private.h      |  5 +++++
 4 files changed, 31 insertions(+), 2 deletions(-)

diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index 756436e..4a59232 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -224,6 +224,7 @@ enum {
 	IFLA_BR_FORWARD_DELAY,
 	IFLA_BR_HELLO_TIME,
 	IFLA_BR_MAX_AGE,
+	IFLA_BR_AGEING_TIME,
 	__IFLA_BR_MAX,
 };
 
diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index 294cbcc..1a665aa 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -392,3 +392,16 @@ void br_dev_setup(struct net_device *dev)
 	br_stp_timer_init(br);
 	br_multicast_init(br);
 }
+
+int br_set_ageing_time(struct net_bridge *br, unsigned long val)
+{
+	unsigned long t = clock_t_to_jiffies(val);
+
+	if (t < BR_MIN_AGEING_TIME || t > BR_MAX_AGEING_TIME)
+		return -ERANGE;
+
+	spin_lock_bh(&br->lock);
+	br->ageing_time = t;
+	spin_unlock_bh(&br->lock);
+	return 0;
+}
diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index 8bc6b67..d80e802 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -733,6 +733,7 @@ static const struct nla_policy br_policy[IFLA_BR_MAX + 1] = {
 	[IFLA_BR_FORWARD_DELAY]	= { .type = NLA_U32 },
 	[IFLA_BR_HELLO_TIME]	= { .type = NLA_U32 },
 	[IFLA_BR_MAX_AGE]	= { .type = NLA_U32 },
+	[IFLA_BR_AGEING_TIME]	= { .type = NLA_U32 },
 };
 
 static int br_changelink(struct net_device *brdev, struct nlattr *tb[],
@@ -762,6 +763,12 @@ static int br_changelink(struct net_device *brdev, struct nlattr *tb[],
 			return err;
 	}
 
+	if (data[IFLA_BR_AGEING_TIME]) {
+		err = br_set_ageing_time(br, nla_get_u32(data[IFLA_BR_AGEING_TIME]));
+		if (err)
+			return err;
+	}
+
 	return 0;
 }
 
@@ -770,6 +777,7 @@ static size_t br_get_size(const struct net_device *brdev)
 	return nla_total_size(sizeof(u32)) +	/* IFLA_BR_FORWARD_DELAY  */
 	       nla_total_size(sizeof(u32)) +	/* IFLA_BR_HELLO_TIME */
 	       nla_total_size(sizeof(u32)) +	/* IFLA_BR_MAX_AGE */
+	       nla_total_size(sizeof(u32)) +	/* IFLA_BR_AGEING_TIME */
 	       0;
 }
 
@@ -778,11 +786,13 @@ static int br_fill_info(struct sk_buff *skb, const struct net_device *brdev)
 	struct net_bridge *br = netdev_priv(brdev);
 	u32 forward_delay = jiffies_to_clock_t(br->forward_delay);
 	u32 hello_time = jiffies_to_clock_t(br->hello_time);
-	u32 age_time = jiffies_to_clock_t(br->max_age);
+	u32 max_age = jiffies_to_clock_t(br->max_age);
+	u32 ageing_time = jiffies_to_clock_t(br->ageing_time);
 
 	if (nla_put_u32(skb, IFLA_BR_FORWARD_DELAY, forward_delay) ||
 	    nla_put_u32(skb, IFLA_BR_HELLO_TIME, hello_time) ||
-	    nla_put_u32(skb, IFLA_BR_MAX_AGE, age_time))
+	    nla_put_u32(skb, IFLA_BR_MAX_AGE, max_age) ||
+	    nla_put_u32(skb, IFLA_BR_AGEING_TIME, ageing_time))
 		return -EMSGSIZE;
 
 	return 0;
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index f0a0438..325883c 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -25,6 +25,10 @@
 
 #define BR_HOLD_TIME (1*HZ)
 
+/* values as per ieee8021QBridgeFdbAgingTime */
+#define BR_MIN_AGEING_TIME  (10 * HZ)
+#define BR_MAX_AGEING_TIME  (1000000 * HZ)
+
 #define BR_PORT_BITS	10
 #define BR_MAX_PORTS	(1<<BR_PORT_BITS)
 #define BR_VLAN_BITMAP_LEN	BITS_TO_LONGS(VLAN_N_VID)
@@ -345,6 +349,7 @@ static inline int br_is_root_bridge(const struct net_bridge *br)
 void br_dev_setup(struct net_device *dev);
 void br_dev_delete(struct net_device *dev, struct list_head *list);
 netdev_tx_t br_dev_xmit(struct sk_buff *skb, struct net_device *dev);
+int br_set_ageing_time(struct net_bridge *br, unsigned long val);
 #ifdef CONFIG_NET_POLL_CONTROLLER
 static inline void br_netpoll_send_skb(const struct net_bridge_port *p,
 				       struct sk_buff *skb)
-- 
2.1.0
