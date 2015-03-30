From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next 04/18] switchdev: convert STP update to swdev
 attr set
Date: Mon, 30 Mar 2015 13:54:18 +0200
Message-ID: <20150330115417.GC2045@nanopsycho.orion>
References: <1427704836-8776-1-git-send-email-sfeldma@gmail.com>
 <1427704836-8776-5-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	linux@roeck-us.net, f.fainelli@gmail.com
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f46.google.com ([74.125.82.46]:35438 "EHLO
	mail-wg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751398AbbC3LyV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Mar 2015 07:54:21 -0400
Received: by wgdm6 with SMTP id m6so171647085wgd.2
        for <netdev@vger.kernel.org>; Mon, 30 Mar 2015 04:54:20 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1427704836-8776-5-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Mar 30, 2015 at 10:40:22AM CEST, sfeldma@gmail.com wrote:
>From: Scott Feldman <sfeldma@gmail.com>
>
>STP update is just a writable port attribute, so convert swdev_port_stp_update
>to an attr set.
>
>Signed-off-by: Scott Feldman <sfeldma@gmail.com>
>---
> drivers/net/ethernet/rocker/rocker.c |   16 +++++++++++++---
> include/net/switchdev.h              |   13 ++-----------
> net/bridge/br_stp.c                  |    6 +++++-
> net/dsa/slave.c                      |   19 ++++++++++++++++++-
> net/switchdev/switchdev.c            |   28 ----------------------------
> 5 files changed, 38 insertions(+), 44 deletions(-)
>
>diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
>index 4bcc555..224f91d 100644
>--- a/drivers/net/ethernet/rocker/rocker.c
>+++ b/drivers/net/ethernet/rocker/rocker.c
>@@ -4237,11 +4237,21 @@ static int rocker_port_attr_get(struct net_device *dev, struct swdev_attr *attr)
> 	return 0;
> }
> 
>-static int rocker_port_swdev_port_stp_update(struct net_device *dev, u8 state)
>+static int rocker_port_attr_set(struct net_device *dev, struct swdev_attr *attr)
> {
> 	struct rocker_port *rocker_port = netdev_priv(dev);
>+	int err = 0;
>+
>+	switch (attr->attr) {
>+	case SWDEV_ATTR_PORT_STP_STATE:
>+		err = rocker_port_stp_update(rocker_port, attr->stp_state);
>+		break;
>+	default:
>+		err = -EOPNOTSUPP;
>+		break;
>+	}
> 
>-	return rocker_port_stp_update(rocker_port, state);
>+	return err;
> }
> 
> static int rocker_port_swdev_fib_ipv4_add(struct net_device *dev,
>@@ -4271,7 +4281,7 @@ static int rocker_port_swdev_fib_ipv4_del(struct net_device *dev,
> 
> static const struct swdev_ops rocker_port_swdev_ops = {
> 	.swdev_port_attr_get		= rocker_port_attr_get,
>-	.swdev_port_stp_update		= rocker_port_swdev_port_stp_update,
>+	.swdev_port_attr_set		= rocker_port_attr_set,
> 	.swdev_fib_ipv4_add		= rocker_port_swdev_fib_ipv4_add,
> 	.swdev_fib_ipv4_del		= rocker_port_swdev_fib_ipv4_del,
> };
>diff --git a/include/net/switchdev.h b/include/net/switchdev.h
>index fd36b5c..99050b0 100644
>--- a/include/net/switchdev.h
>+++ b/include/net/switchdev.h
>@@ -17,6 +17,7 @@
> enum swdev_attr_id {
> 	SWDEV_ATTR_UNDEFINED,
> 	SWDEV_ATTR_PORT_PARENT_ID,
>+	SWDEV_ATTR_PORT_STP_STATE,
> };
> 
> #define SWDEV_ATTR_F_NO_RECURSE		BIT(0)
>@@ -27,6 +28,7 @@ struct swdev_attr {
> 	u32 flags;
> 	union {
> 		struct netdev_phys_item_id ppid;	/* PORT_PARENT_ID */
>+		u8 stp_state;				/* PORT_STP_STATE */
> 	};
> };
> 
>@@ -39,9 +41,6 @@ struct fib_info;
>  *
>  * @swdev_port_attr_set: Set a port attribute (see swdev_attr).
>  *
>- * @swdev_port_stp_update: Called to notify switch device port of bridge
>- *   port STP state change.
>- *
>  * @swdev_fib_ipv4_add: Called to add/modify IPv4 route to switch device.
>  *
>  * @swdev_fib_ipv4_del: Called to delete IPv4 route from switch device.
>@@ -51,7 +50,6 @@ struct swdev_ops {
> 				       struct swdev_attr *attr);
> 	int	(*swdev_port_attr_set)(struct net_device *dev,
> 				       struct swdev_attr *attr);
>-	int	(*swdev_port_stp_update)(struct net_device *dev, u8 state);
> 	int	(*swdev_fib_ipv4_add)(struct net_device *dev, __be32 dst,
> 				      int dst_len, struct fib_info *fi,
> 				      u8 tos, u8 type, u32 nlflags,
>@@ -86,7 +84,6 @@ netdev_switch_notifier_info_to_dev(const struct netdev_switch_notifier_info *inf
> 
> int swdev_port_attr_get(struct net_device *dev, struct swdev_attr *attr);
> int swdev_port_attr_set(struct net_device *dev, struct swdev_attr *attr);
>-int netdev_switch_port_stp_update(struct net_device *dev, u8 state);
> int register_netdev_switch_notifier(struct notifier_block *nb);
> int unregister_netdev_switch_notifier(struct notifier_block *nb);
> int call_netdev_switch_notifiers(unsigned long val, struct net_device *dev,
>@@ -119,12 +116,6 @@ static inline int swdev_port_attr_set(struct net_device *dev,
> 	return -EOPNOTSUPP;
> }
> 
>-static inline int netdev_switch_port_stp_update(struct net_device *dev,
>-						u8 state)
>-{
>-	return -EOPNOTSUPP;
>-}
>-
> static inline int register_netdev_switch_notifier(struct notifier_block *nb)
> {
> 	return 0;
>diff --git a/net/bridge/br_stp.c b/net/bridge/br_stp.c
>index fb3ebe6..8b2ef23 100644
>--- a/net/bridge/br_stp.c
>+++ b/net/bridge/br_stp.c
>@@ -39,10 +39,14 @@ void br_log_state(const struct net_bridge_port *p)
> 
> void br_set_state(struct net_bridge_port *p, unsigned int state)
> {
>+	struct swdev_attr attr = {
>+		.attr = SWDEV_ATTR_PORT_STP_STATE,
>+		.stp_state = state,
>+	};
> 	int err;
> 
> 	p->state = state;
>-	err = netdev_switch_port_stp_update(p->dev, state);
>+	err = swdev_port_attr_set(p->dev, &attr);

Seems nicer to me to provide a wrapper for callers so they don't call
directly swdev_port_attr_set and have no knowledge of swdev_attr.


> 	if (err && err != -EOPNOTSUPP)
> 		br_warn(p->br, "error setting offload STP state on port %u(%s)\n",
> 				(unsigned int) p->port_no, p->dev->name);
>diff --git a/net/dsa/slave.c b/net/dsa/slave.c
>index 2a5bfde..317bb38 100644
>--- a/net/dsa/slave.c
>+++ b/net/dsa/slave.c
>@@ -347,6 +347,23 @@ static int dsa_slave_stp_update(struct net_device *dev, u8 state)
> 	return ret;
> }
> 
>+static int dsa_slave_port_attr_set(struct net_device *dev,
>+				   struct swdev_attr *attr)
>+{
>+	int ret = 0;
>+
>+	switch (attr->attr) {
>+	case SWDEV_ATTR_PORT_STP_STATE:
>+		ret = dsa_slave_stp_update(dev, attr->stp_state);
>+		break;
>+	default:
>+		ret = -EOPNOTSUPP;
>+		break;
>+	}
>+
>+	return ret;
>+}
>+
> static int dsa_slave_bridge_port_join(struct net_device *dev,
> 				      struct net_device *br)
> {
>@@ -685,7 +702,7 @@ static const struct net_device_ops dsa_slave_netdev_ops = {
> 
> static const struct swdev_ops dsa_slave_swdev_ops = {
> 	.swdev_port_attr_get = dsa_slave_port_attr_get,
>-	.swdev_port_stp_update = dsa_slave_stp_update,
>+	.swdev_port_attr_set = dsa_slave_port_attr_set,
> };
> 
> static void dsa_slave_adjust_link(struct net_device *dev)
>diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
>index 24440c5..162b011 100644
>--- a/net/switchdev/switchdev.c
>+++ b/net/switchdev/switchdev.c
>@@ -109,34 +109,6 @@ int swdev_port_attr_set(struct net_device *dev, struct swdev_attr *attr)
> }
> EXPORT_SYMBOL_GPL(swdev_port_attr_set);
> 
>-/**
>- *	netdev_switch_port_stp_update - Notify switch device port of STP
>- *					state change
>- *	@dev: port device
>- *	@state: port STP state
>- *
>- *	Notify switch device port of bridge port STP state change.
>- */
>-int netdev_switch_port_stp_update(struct net_device *dev, u8 state)
>-{
>-	const struct swdev_ops *ops = dev->swdev_ops;
>-	struct net_device *lower_dev;
>-	struct list_head *iter;
>-	int err = -EOPNOTSUPP;
>-
>-	if (ops && ops->swdev_port_stp_update)
>-		return ops->swdev_port_stp_update(dev, state);
>-
>-	netdev_for_each_lower_dev(dev, lower_dev, iter) {
>-		err = netdev_switch_port_stp_update(lower_dev, state);
>-		if (err && err != -EOPNOTSUPP)
>-			return err;
>-	}
>-
>-	return err;
>-}
>-EXPORT_SYMBOL_GPL(netdev_switch_port_stp_update);
>-
> static DEFINE_MUTEX(netdev_switch_mutex);
> static RAW_NOTIFIER_HEAD(netdev_switch_notif_chain);
> 
>-- 
>1.7.10.4
>
