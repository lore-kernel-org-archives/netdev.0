From: David Miller <davem@davemloft.net>
Subject: Re: bridge netpoll support: mismatch between net core and bridge
 headers
Date: Wed, 01 Dec 2010 16:33:19 -0800 (PST)
Message-ID: <20101201.163319.193705748.davem@davemloft.net>
References: <AANLkTimbf+yfJFU29rNWAc-hXBxj92J=dNaShM04GNZ7@mail.gmail.com>
	<20101201.114201.245392768.davem@davemloft.net>
	<AANLkTi=hq6S_NvPEkTovkceUe9Orcitj_oHN1mVUW7+A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: vapier.adi@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38425
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753704Ab0LBAcx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Dec 2010 19:32:53 -0500
In-Reply-To: <AANLkTi=hq6S_NvPEkTovkceUe9Orcitj_oHN1mVUW7+A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike Frysinger <vapier.adi@gmail.com>
Date: Wed, 1 Dec 2010 16:53:31 -0500

> can you post a patch i can try in my randconfig tree ?

Attached.  Also please provide one of the failing ".config" files,
and please test if simply going "make oldconfig" unbreaks things.
It may be that randconfig allows configurations that the config
system normally does not allow.

>From 2212481a102ab53f485ddf76cb1be21e4ace5b7e Mon Sep 17 00:00:00 2001
From: David S. Miller <davem@davemloft.net>
Date: Wed, 1 Dec 2010 11:28:48 -0800
Subject: [PATCH] bridge: Fix randconfig builds.

Currently it is possible to turn on NET_POLL_CONTROLLER
without NETPOLL.

The bridging netpoll support code doesn't make any real
sense unless both options are enabled because the netdev's
->npinfo has to be present for the code to operate properly.

So for now just require that both config options are enabled.

Longer term it's probably a good idea to just get rid of
NET_POLL_CONTROLLER and have everything hinge upon just the
NETPOLL option.

Reported-by: Mike Frysinger <vapier.adi@gmail.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/bridge/br_device.c  |    4 ++--
 net/bridge/br_private.h |    4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index 17cb0b6..96ecb02 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -217,7 +217,7 @@ static int br_set_flags(struct net_device *netdev, u32 data)
 	return ethtool_op_set_flags(netdev, data, ETH_FLAG_TXVLAN);
 }
 
-#ifdef CONFIG_NET_POLL_CONTROLLER
+#if defined(CONFIG_NETPOLL) && defined(CONFIG_NET_POLL_CONTROLLER)
 static void br_poll_controller(struct net_device *br_dev)
 {
 }
@@ -321,7 +321,7 @@ static const struct net_device_ops br_netdev_ops = {
 	.ndo_set_multicast_list	 = br_dev_set_multicast_list,
 	.ndo_change_mtu		 = br_change_mtu,
 	.ndo_do_ioctl		 = br_dev_ioctl,
-#ifdef CONFIG_NET_POLL_CONTROLLER
+#if defined(CONFIG_NETPOLL) && defined(CONFIG_NET_POLL_CONTROLLER)
 	.ndo_netpoll_setup	 = br_netpoll_setup,
 	.ndo_netpoll_cleanup	 = br_netpoll_cleanup,
 	.ndo_poll_controller	 = br_poll_controller,
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 75c90ed..ad1bec6 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -146,7 +146,7 @@ struct net_bridge_port
 	char				sysfs_name[IFNAMSIZ];
 #endif
 
-#ifdef CONFIG_NET_POLL_CONTROLLER
+#if defined(CONFIG_NETPOLL) && defined(CONFIG_NET_POLL_CONTROLLER)
 	struct netpoll			*np;
 #endif
 };
@@ -287,7 +287,7 @@ static inline int br_is_root_bridge(const struct net_bridge *br)
 extern void br_dev_setup(struct net_device *dev);
 extern netdev_tx_t br_dev_xmit(struct sk_buff *skb,
 			       struct net_device *dev);
-#ifdef CONFIG_NET_POLL_CONTROLLER
+#if defined(CONFIG_NETPOLL) && defined(CONFIG_NET_POLL_CONTROLLER)
 static inline struct netpoll_info *br_netpoll_info(struct net_bridge *br)
 {
 	return br->dev->npinfo;
-- 
1.7.3.2


