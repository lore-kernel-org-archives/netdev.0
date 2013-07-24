From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH 1/3 net-next] bridge: cleanup netpoll code
Date: Wed, 24 Jul 2013 11:51:41 -0700
Message-ID: <20130724115141.63bba894@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@resnulli.us>, Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f42.google.com ([209.85.160.42]:36603 "EHLO
	mail-pb0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753605Ab3GXSyH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jul 2013 14:54:07 -0400
Received: by mail-pb0-f42.google.com with SMTP id un1so10149513pbc.1
        for <netdev@vger.kernel.org>; Wed, 24 Jul 2013 11:54:06 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This started out with fixing a sparse warning, then I realized that
the wrapper function br_netpoll_info could just be collapsed away
by rolling it into the enable code.

Also, eliminate unnecessary goto's

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

--- a/net/bridge/br_private.h	2013-07-24 08:34:05.289987225 -0700
+++ b/net/bridge/br_private.h	2013-07-24 08:34:09.581940104 -0700
@@ -333,11 +333,6 @@ extern void br_dev_delete(struct net_dev
 extern netdev_tx_t br_dev_xmit(struct sk_buff *skb,
 			       struct net_device *dev);
 #ifdef CONFIG_NET_POLL_CONTROLLER
-static inline struct netpoll_info *br_netpoll_info(struct net_bridge *br)
-{
-	return br->dev->npinfo;
-}
-
 static inline void br_netpoll_send_skb(const struct net_bridge_port *p,
 				       struct sk_buff *skb)
 {
@@ -350,11 +345,6 @@ static inline void br_netpoll_send_skb(c
 extern int br_netpoll_enable(struct net_bridge_port *p, gfp_t gfp);
 extern void br_netpoll_disable(struct net_bridge_port *p);
 #else
-static inline struct netpoll_info *br_netpoll_info(struct net_bridge *br)
-{
-	return NULL;
-}
-
 static inline void br_netpoll_send_skb(const struct net_bridge_port *p,
 				       struct sk_buff *skb)
 {
--- a/net/bridge/br_device.c	2013-07-24 08:34:05.289987225 -0700
+++ b/net/bridge/br_device.c	2013-07-24 08:34:09.581940104 -0700
@@ -244,22 +244,22 @@ fail:
 int br_netpoll_enable(struct net_bridge_port *p, gfp_t gfp)
 {
 	struct netpoll *np;
-	int err = 0;
+	int err;
+
+	if (!p->br->dev->npinfo)
+		return 0;
 
 	np = kzalloc(sizeof(*p->np), gfp);
-	err = -ENOMEM;
 	if (!np)
-		goto out;
+		return -ENOMEM;
 
 	err = __netpoll_setup(np, p->dev, gfp);
 	if (err) {
 		kfree(np);
-		goto out;
+		return err;
 	}
 
 	p->np = np;
-
-out:
 	return err;
 }
 
--- a/net/bridge/br_if.c	2013-07-24 08:34:05.289987225 -0700
+++ b/net/bridge/br_if.c	2013-07-24 08:34:09.581940104 -0700
@@ -363,7 +363,8 @@ int br_add_if(struct net_bridge *br, str
 	if (err)
 		goto err2;
 
-	if (br_netpoll_info(br) && ((err = br_netpoll_enable(p, GFP_KERNEL))))
+	err = br_netpoll_enable(p, GFP_KERNEL);
+	if (err)
 		goto err3;
 
 	err = netdev_master_upper_dev_link(dev, br->dev);
