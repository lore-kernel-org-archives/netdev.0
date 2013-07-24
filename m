From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH 2/3 net-next] team: cleanup netpoll clode
Date: Wed, 24 Jul 2013 11:52:44 -0700
Message-ID: <20130724115244.3fd7a43d@nehalam.linuxnetplumber.net>
References: <20130724115141.63bba894@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Neil Horman <nhorman@tuxdriver.com>,
	Jiri Pirko <jiri@resnulli.us>, Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f47.google.com ([209.85.160.47]:42731 "EHLO
	mail-pb0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753924Ab3GXSyJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jul 2013 14:54:09 -0400
Received: by mail-pb0-f47.google.com with SMTP id rr13so10069858pbb.6
        for <netdev@vger.kernel.org>; Wed, 24 Jul 2013 11:54:08 -0700 (PDT)
In-Reply-To: <20130724115141.63bba894@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This started out with fixing a sparse warning, then I realized that
the wrapper function team_netpoll_info could just be collapsed away
by rolling it into the enable code.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

--- a/drivers/net/team/team.c	2013-07-24 08:34:05.257987576 -0700
+++ b/drivers/net/team/team.c	2013-07-24 08:34:10.357931582 -0700
@@ -1037,6 +1037,9 @@ static int team_port_enable_netpoll(stru
 	struct netpoll *np;
 	int err;
 
+	if (!team->dev->npinfo)
+		return 0;
+
 	np = kzalloc(sizeof(*np), gfp);
 	if (!np)
 		return -ENOMEM;
@@ -1063,12 +1066,6 @@ static void team_port_disable_netpoll(st
 	__netpoll_cleanup(np);
 	kfree(np);
 }
-
-static struct netpoll_info *team_netpoll_info(struct team *team)
-{
-	return team->dev->npinfo;
-}
-
 #else
 static int team_port_enable_netpoll(struct team *team, struct team_port *port,
 				    gfp_t gfp)
@@ -1078,10 +1075,6 @@ static int team_port_enable_netpoll(stru
 static void team_port_disable_netpoll(struct team_port *port)
 {
 }
-static struct netpoll_info *team_netpoll_info(struct team *team)
-{
-	return NULL;
-}
 #endif
 
 static void __team_port_change_port_added(struct team_port *port, bool linkup);
@@ -1163,13 +1156,11 @@ static int team_port_add(struct team *te
 		goto err_vids_add;
 	}
 
-	if (team_netpoll_info(team)) {
-		err = team_port_enable_netpoll(team, port, GFP_KERNEL);
-		if (err) {
-			netdev_err(dev, "Failed to enable netpoll on device %s\n",
-				   portname);
-			goto err_enable_netpoll;
-		}
+	err = team_port_enable_netpoll(team, port, GFP_KERNEL);
+	if (err) {
+		netdev_err(dev, "Failed to enable netpoll on device %s\n",
+			   portname);
+		goto err_enable_netpoll;
 	}
 
 	err = netdev_master_upper_dev_link(port_dev, dev);
