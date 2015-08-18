From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH] bridge: Enable configuration of ageing interval for
 bridges and switch devices.
Date: Tue, 18 Aug 2015 00:17:52 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1508172358470.13562@rocker1.rocker.net>
References: <77EF4405DD4BB54AACCE7DB593DF6A9A9E1E8D@SJEXCHMB14.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Premkumar Jonnala <pjonnala@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:33010 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751161AbbHRHPA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Aug 2015 03:15:00 -0400
Received: by pdrh1 with SMTP id h1so65602593pdr.0
        for <netdev@vger.kernel.org>; Tue, 18 Aug 2015 00:15:00 -0700 (PDT)
In-Reply-To: <77EF4405DD4BB54AACCE7DB593DF6A9A9E1E8D@SJEXCHMB14.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Fri, 14 Aug 2015, Premkumar Jonnala wrote:

> Bridge devices have ageing interval used to age out MAC addresses
> from FDB.  This ageing interval was not configuratble.
>
> Enable netlink based configuration of ageing interval for bridges and
> switch devices.  The ageing interval changes the timer used to purge
> inactive FDB entries in bridges.  The ageing interval config is
> propagated to switch devices, so that platform or hardware based
> ageing works according to configuration.
>
> Signed-off-by: Premkumar Jonnala <pjonnala@broadcom.com>

Hi Premkumar,

I agree with Roopa that we should use existing IFLA_BR_AGEING_TIME.

I hope you don't mind if share a patch for setting bridge-level attributes 
down to the switch hardware ports.  It uses the switchdev_port_attr_set() 
call on the bridge interface itself when any IFLA_BR_xxx attribute is set 
via netlink.   switchdev_port_attr_set() will do a recursive walk of all 
lower devs from the bridge, stopping at each to set the attribute.  I 
added one small tweak to switchdev_port_attr_set() to allow skipping over 
ports that return -EOPNOTSUPP.  The advantage to using 
switchdev_port_attr_set() is it automatically knows how to find the leaf 
ports in a stacked driver setup, and it uses the prepare/commit 
transaction model to make sure all ports can support new attr setting 
before committing setting to hardware.

I gave an example using rocker to set IFLA_BR_AGEING_TIME.  It's stubbed 
out, but you get the idea.  Other IFLA_BR_xxx attrs can be added to this 
model.

Does this look like something that would work?  If so, would you mind 
running with this patch and maybe even extending it for other IFLA_BR_xxx 
attrs?

Again, I hope I'm not stepping on toes here by rewriting your patch, but 
it was the best way to communicate the idea of how to use the switchdev 
frame work for these bridge attrs.

-scott




diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index 0cc9e8f..830f8e6 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -4680,6 +4680,24 @@ static int rocker_port_brport_flags_set(struct rocker_port *rocker_port,
  	return err;
  }

+static int rocker_port_bridge_set(struct rocker_port *rocker_port,
+				  enum switchdev_trans trans,
+				  struct switchdev_attr_bridge *bridge)
+{
+	switch (bridge->attr) {
+	case IFLA_BR_AGEING_TIME:
+		{
+			u32 ageing_time = bridge->val;
+			/* XXX push ageing_time down to device */
+		}
+		break;
+	default:
+		return -EOPNOTSUPP;
+	}
+
+	return 0;
+}
+
  static int rocker_port_attr_set(struct net_device *dev,
  				struct switchdev_attr *attr)
  {
@@ -4707,6 +4725,10 @@ static int rocker_port_attr_set(struct net_device *dev,
  		err = rocker_port_brport_flags_set(rocker_port, attr->trans,
  						   attr->u.brport_flags);
  		break;
+	case SWITCHDEV_ATTR_BRIDGE:
+		err = rocker_port_bridge_set(rocker_port, attr->trans,
+					     &attr->u.bridge);
+		break;
  	default:
  		err = -EOPNOTSUPP;
  		break;
diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index 319baab..22a6dbe 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -15,6 +15,7 @@
  #include <linux/notifier.h>

  #define SWITCHDEV_F_NO_RECURSE		BIT(0)
+#define SWITCHDEV_F_SKIP_EOPNOTSUPP	BIT(1)

  enum switchdev_trans {
  	SWITCHDEV_TRANS_NONE,
@@ -28,6 +29,7 @@ enum switchdev_attr_id {
  	SWITCHDEV_ATTR_PORT_PARENT_ID,
  	SWITCHDEV_ATTR_PORT_STP_STATE,
  	SWITCHDEV_ATTR_PORT_BRIDGE_FLAGS,
+	SWITCHDEV_ATTR_BRIDGE,
  };

  struct switchdev_attr {
@@ -38,6 +40,10 @@ struct switchdev_attr {
  		struct netdev_phys_item_id ppid;	/* PORT_PARENT_ID */
  		u8 stp_state;				/* PORT_STP_STATE */
  		unsigned long brport_flags;		/* PORT_BRIDGE_FLAGS */
+		struct switchdev_attr_bridge {		/* BRIDGE */
+			enum ifla_br attr;
+			u32 val;
+		} bridge;
  	} u;
  };

diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index ff659f0..0630053 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -222,7 +222,7 @@ enum in6_addr_gen_mode {

  /* Bridge section */

-enum {
+enum ifla_br {
  	IFLA_BR_UNSPEC,
  	IFLA_BR_FORWARD_DELAY,
  	IFLA_BR_HELLO_TIME,
diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index 0f2408f..01401ea 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -759,9 +759,9 @@ static int br_changelink(struct net_device *brdev, struct nlattr *tb[],
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
index 3d95647..9807a6f 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -807,6 +807,7 @@ void __br_set_forward_delay(struct net_bridge *br, unsigned long t);
  int br_set_forward_delay(struct net_bridge *br, unsigned long x);
  int br_set_hello_time(struct net_bridge *br, unsigned long x);
  int br_set_max_age(struct net_bridge *br, unsigned long x);
+int br_set_ageing_time(struct net_bridge *br, u32 ageing_time);


  /* br_stp_if.c */
diff --git a/net/bridge/br_stp.c b/net/bridge/br_stp.c
index ed74ffa..5de27bc 100644
--- a/net/bridge/br_stp.c
+++ b/net/bridge/br_stp.c
@@ -566,6 +566,25 @@ int br_set_max_age(struct net_bridge *br, unsigned long val)

  }

+int br_set_ageing_time(struct net_bridge *br, u32 ageing_time)
+{
+	struct switchdev_attr attr = {
+		.id = SWITCHDEV_ATTR_BRIDGE,
+		.flags = SWITCHDEV_F_SKIP_EOPNOTSUPP,
+		.u.bridge.attr = IFLA_BR_AGEING_TIME,
+		.u.bridge.val = ageing_time,
+	};
+	int err;
+
+	err = switchdev_port_attr_set(br->dev, &attr);
+	if (err)
+		return err;
+
+	br->ageing_time = clock_t_to_jiffies(ageing_time);
+
+	return 0;
+}
+
  void __br_set_forward_delay(struct net_bridge *br, unsigned long t)
  {
  	br->bridge_forward_delay = t;
diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index 16c1c43..b990301 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -73,7 +73,7 @@ static int __switchdev_port_attr_set(struct net_device *dev,
  		return ops->switchdev_port_attr_set(dev, attr);

  	if (attr->flags & SWITCHDEV_F_NO_RECURSE)
-		return err;
+		goto done;

  	/* Switch device port(s) may be stacked under
  	 * bond/team/vlan dev, so recurse down to set attr on
@@ -82,10 +82,17 @@ static int __switchdev_port_attr_set(struct net_device *dev,

  	netdev_for_each_lower_dev(dev, lower_dev, iter) {
  		err = __switchdev_port_attr_set(lower_dev, attr);
+		if (err == -EOPNOTSUPP &&
+		    attr->flags & SWITCHDEV_F_SKIP_EOPNOTSUPP)
+			continue;
  		if (err)
  			break;
  	}

+done:
+	if (err == -EOPNOTSUPP && attr->flags & SWITCHDEV_F_SKIP_EOPNOTSUPP)
+		err = 0;
+
  	return err;
  }
