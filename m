From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v3] switchdev: fix stp update API to work with
 layered netdevices
Date: Mon, 16 Mar 2015 16:42:10 +0100
Message-ID: <20150316154210.GC2058@nanopsycho.orion>
References: <1426518099-3203-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, sfeldma@gmail.com, netdev@vger.kernel.org
To: roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f182.google.com ([74.125.82.182]:36328 "EHLO
	mail-we0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934653AbbCPPmP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2015 11:42:15 -0400
Received: by wetk59 with SMTP id k59so41327157wet.3
        for <netdev@vger.kernel.org>; Mon, 16 Mar 2015 08:42:14 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1426518099-3203-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Mar 16, 2015 at 04:01:39PM CET, roopa@cumulusnetworks.com wrote:
>From: Roopa Prabhu <roopa@cumulusnetworks.com>
>
>make it same as the netdev_switch_port_bridge_setlink/dellink
>api (ie traverse lowerdevs to get to the switch port).
>
>removes "WARN_ON(!ops->ndo_switch_parent_id_get)" because
>direct bridge ports can be stacked netdevices (like bonds
>and team of switch ports) which may not imeplement this ndo.
>
>v2 to v3:
>	- remove changes to bond and team. Bring back the
>	transparently following lowerdevs like i initially
>	had for setlink/getlink
>	(http://www.spinics.net/lists/netdev/msg313436.html)
>	dave and scott feldman also seem to prefer it be that
>	way and move to non-transparent way of doing things
>	if we see a problem down the lane.
>
>Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
>---
> net/switchdev/switchdev.c |   20 ++++++++++++++++----
> 1 file changed, 16 insertions(+), 4 deletions(-)
>
>diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
>index c9bfa00..5c53951 100644
>--- a/net/switchdev/switchdev.c
>+++ b/net/switchdev/switchdev.c
>@@ -47,11 +47,23 @@ EXPORT_SYMBOL_GPL(netdev_switch_parent_id_get);
> int netdev_switch_port_stp_update(struct net_device *dev, u8 state)
> {
> 	const struct swdev_ops *ops = dev->swdev_ops;
>+	struct net_device *lower_dev;
>+	struct list_head *iter;
>+	int ret = 0, err = -EOPNOTSUPP;

	No need to initialize err.

> 
>-	if (!ops || !ops->swdev_port_stp_update)
>-		return -EOPNOTSUPP;
>-	WARN_ON(!ops->swdev_parent_id_get);
>-	return ops->swdev_port_stp_update(dev, state);
>+	if (!(dev->features & NETIF_F_HW_SWITCH_OFFLOAD))
>+		return ret;
		Just flat "0" might be nicer here.

>+
>+	if (ops && ops->swdev_port_stp_update)
>+		return ops->swdev_port_stp_update(dev, state);
>+
>+	netdev_for_each_lower_dev(dev, lower_dev, iter) {
>+		err = netdev_switch_port_stp_update(lower_dev, state);
>+		if (err && err != -EOPNOTSUPP)
>+			ret = err;
>+	}
>+
>+	return ret;


Do we want to return 0 in case no lower dev is there? -EOPNOTSUPP seems
to make more sense to me in that case.



> }
> EXPORT_SYMBOL_GPL(netdev_switch_port_stp_update);
> 
>-- 
>1.7.10.4
>
