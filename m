From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH] team: add support to get speed via ethtool
Date: Fri, 6 Mar 2015 08:16:17 +0100
Message-ID: <20150306071617.GA2011@nanopsycho.orion>
References: <1425592115-1750-1-git-send-email-sridhar.samudrala@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Sridhar Samudrala <sridhar.samudrala@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f49.google.com ([74.125.82.49]:42953 "EHLO
	mail-wg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751828AbbCFHQU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Mar 2015 02:16:20 -0500
Received: by wggz12 with SMTP id z12so21080466wgg.9
        for <netdev@vger.kernel.org>; Thu, 05 Mar 2015 23:16:19 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1425592115-1750-1-git-send-email-sridhar.samudrala@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Mar 05, 2015 at 10:48:35PM CET, sridhar.samudrala@intel.com wrote:
>With this patch ethtool <team> OR cat /sys/class/net/<team>/speed
>returns the speed of team based on member ports speed and state.
>
>Based on get speed support in bonding driver.
>
>Signed-off-by: Sridhar Samudrala <sridhar.samudrala@intel.com>
>---
> drivers/net/team/team.c | 25 +++++++++++++++++++++++++
> 1 file changed, 25 insertions(+)
>
>diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
>index 9d3366f..e822803 100644
>--- a/drivers/net/team/team.c
>+++ b/drivers/net/team/team.c
>@@ -1954,6 +1954,30 @@ static int team_change_carrier(struct net_device *dev, bool new_carrier)
> 	return 0;
> }
> 
>+static int team_ethtool_get_settings(struct net_device *dev,
>+				     struct ethtool_cmd *ecmd)
>+{
>+	struct team *team = netdev_priv(dev);
>+	struct team_port *port;
>+	unsigned long speed = 0;
>+
>+	ecmd->duplex = DUPLEX_UNKNOWN;
>+	ecmd->port = PORT_OTHER;
>+
>+	mutex_lock(&team->lock);
>+	list_for_each_entry(port, &team->port_list, list) {
>+		if (port->linkup)
>+			speed += port->state.speed;
>+		if (ecmd->duplex == DUPLEX_UNKNOWN &&
>+		    port->state.duplex != 0)
>+			ecmd->duplex = port->state.duplex;
>+	}
>+	ethtool_cmd_speed_set(ecmd, speed);
>+	mutex_unlock(&team->lock);
>+
>+	return 0;
>+}

Sridar, what exactly you are trying to achieve? I agree with DaveM that
this make no sense for soft devices. The fact bonding has it is a
mistake.


>+
> static const struct net_device_ops team_netdev_ops = {
> 	.ndo_init		= team_init,
> 	.ndo_uninit		= team_uninit,
>@@ -1995,6 +2019,7 @@ static void team_ethtool_get_drvinfo(struct net_device *dev,
> static const struct ethtool_ops team_ethtool_ops = {
> 	.get_drvinfo		= team_ethtool_get_drvinfo,
> 	.get_link		= ethtool_op_get_link,
>+	.get_settings		= team_ethtool_get_settings,
> };
> 
> /***********************
>-- 
>1.8.4.2
>
