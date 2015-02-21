From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next 1/2] dsa: bonding: implement HW bonding
Date: Sat, 21 Feb 2015 17:57:15 +0100
Message-ID: <20150221165715.GE2092@nanopsycho.orion>
References: <1424429473-4601-1-git-send-email-jonasj76@gmail.com>
 <1424429473-4601-2-git-send-email-jonasj76@gmail.com>
 <54E763A6.4020505@gmail.com>
 <alpine.LNX.2.03.1502201952190.11645@hellgate.skynet>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org,
	Jonas Johansson <jonas.johansson@westermo.se>,
	Scott Feldman <sfeldma@gmail.com>
To: Jonas Johansson <jonasj76@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f43.google.com ([74.125.82.43]:49326 "EHLO
	mail-wg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750980AbbBUQ5V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Feb 2015 11:57:21 -0500
Received: by mail-wg0-f43.google.com with SMTP id z12so18486864wgg.2
        for <netdev@vger.kernel.org>; Sat, 21 Feb 2015 08:57:19 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.03.1502201952190.11645@hellgate.skynet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Feb 20, 2015 at 08:28:48PM CET, jonasj76@gmail.com wrote:
>
>
>On Fri, 20 Feb 2015, Florian Fainelli wrote:
>
>>On 20/02/15 02:51, Jonas Johansson wrote:
>>>From: Jonas Johansson <jonas.johansson@westermo.se>
>>>
>>>This patch will implement hooks for hardware bonding support for the DSA
>>>driver. When the team driver adds a DSA slave port the port will be assigned
>>>a bond group id and the DSA slave driver can setup the hardware. When team
>>>changes the port state (enabled/disabled) the DSA slave driver is able to
>>>use the attach/detach callback which will allow the hardware to change the
>>>hardware settings to reflect the state.
>>>
>>>Added DSA hooks:
>>> bond_add_group: To add a port to a bond group
>>> bond_del_group: To remove a port from a bond group
>>> bond_attach: To mark the port in a bond group as attached/active
>>> bond_detach: To unmark the port in a bond group as detach/inactive
>>>
>>>Added new network device hooks:
>>> ndo_bond_attach: To attach a device to a bond group.
>>> ndo_bond_detach: To detach a device from a bond group.
>>>
>>>Team:
>>> Added callback to ndo_bond_attach when port is enabled.
>>> Added callback to ndo_bond_detach when port is disabled.
>>>
>>>Added DSA notifier:
>>> Listening on NETDEV_CHANGEUPPER to add or deleta a port to/from a bond group.
>>>
>>>Signed-off-by: Jonas Johansson <jonas.johansson@westermo.se>
>>>---
>>> drivers/net/team/team.c   |  4 ++++
>>> include/linux/netdevice.h |  8 +++++++
>>> include/net/dsa.h         |  8 +++++++
>>> net/dsa/dsa.c             | 60 +++++++++++++++++++++++++++++++++++++++++++++++
>>> net/dsa/dsa_priv.h        |  6 +++++
>>> net/dsa/slave.c           | 23 ++++++++++++++++++
>>> 6 files changed, 109 insertions(+)
>>>
>>>diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
>>>index 0e62274..f7b2afb 100644
>>>--- a/drivers/net/team/team.c
>>>+++ b/drivers/net/team/team.c
>>>@@ -934,6 +934,8 @@ static void team_port_enable(struct team *team,
>>> 		team->ops.port_enabled(team, port);
>>> 	team_notify_peers(team);
>>> 	team_mcast_rejoin(team);
>>>+	if (port->dev->netdev_ops->ndo_bond_attach)
>>>+		port->dev->netdev_ops->ndo_bond_attach(port->dev);
>>> }
>>>
>>> static void __reconstruct_port_hlist(struct team *team, int rm_index)
>>>@@ -965,6 +967,8 @@ static void team_port_disable(struct team *team,
>>> 	team_adjust_ops(team);
>>> 	team_notify_peers(team);
>>> 	team_mcast_rejoin(team);
>>>+	if (port->dev->netdev_ops->ndo_bond_detach)
>>>+		port->dev->netdev_ops->ndo_bond_detach(port->dev);
>>> }
>>
>>Do we really need new ndos here? Cannot we learn this via
>>NETDEV_CHANGEUPPER?
>>
>If team e.g. uses LACP as runner, a number of ports can be configured as a
>bond group, but only the ports of the same physical type will be enabled and
>used for bonding. team_port_enable() and team_port_disable() are the
>functions to set the ports which should be included for bonding.

Hmm, I'm not sure I understand correctly what the marvel hw is capable of.
Would you care to explain it a bit ? (or maybe I should read the
datasheet)

If we want to offload bond functionality (tx, rx), we need to be careful
about the features, mainly mode/runner tx function which should not be
different in hw to what we have in kernel. That might be pretty hard for
example in case of loadbalance team mode, where bpf is used to get tx
port.

Also, switchdev ndos and notifier propagation needs to be implemented in
team/bond.

But maybe I'm getting your usecase wrong. Please help me to understand
it.

Thanks.


>
>>
>>[snip]
>>
>>>
>>> /* platform driver init and cleanup *****************************************/
>>> static int dev_is_class(struct device *dev, void *class)
>>>@@ -778,6 +835,9 @@ static int dsa_probe(struct platform_device *pdev)
>>> 		add_timer(&dst->link_poll_timer);
>>> 	}
>>>
>>>+	/* Setup notifier */
>>>+	register_netdevice_notifier(&dsa_nb);
>>
>>I do not think we need to register the netdevice_notifier for every DSA
>>platform_device we might instantiate, a single one, global, whenever the
>>DSA driver gets inserted should be enough.
>>
>>Also, I would prefer if we moved this to net/dsa/slave.c where the other
>>netdevice_ops are layered, very much like this patch:
>>
>>[1]: http://patchwork.ozlabs.org/patch/440696/
>>
>I agree.
>
>>>+
>>> 	return 0;
>>>
>>> out:
>>>diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
>>>index dc9756d..6a1456a 100644
>>>--- a/net/dsa/dsa_priv.h
>>>+++ b/net/dsa/dsa_priv.h
>>>@@ -45,6 +45,11 @@ struct dsa_slave_priv {
>>> 	int			old_link;
>>> 	int			old_pause;
>>> 	int			old_duplex;
>>>+
>>>+	/*
>>>+	 * Bond group id, or 0 if port is not bonded.
>>>+	 */
>>>+	int			bond_gid;
>>> };
>>>
>>> /* dsa.c */
>>>@@ -58,6 +63,7 @@ struct net_device *dsa_slave_create(struct dsa_switch *ds,
>>> 				    int port, char *name);
>>> int dsa_slave_suspend(struct net_device *slave_dev);
>>> int dsa_slave_resume(struct net_device *slave_dev);
>>>+bool dsa_slave_check(struct net_device *dev);
>>>
>>> /* tag_dsa.c */
>>> extern const struct dsa_device_ops dsa_netdev_ops;
>>>diff --git a/net/dsa/slave.c b/net/dsa/slave.c
>>>index f23dead..88c84bf 100644
>>>--- a/net/dsa/slave.c
>>>+++ b/net/dsa/slave.c
>>>@@ -441,6 +441,22 @@ static int dsa_slave_get_eee(struct net_device *dev, struct ethtool_eee *e)
>>> 	return ret;
>>> }
>>>
>>>+static int dsa_slave_bond_attach(struct net_device *dev)
>>>+{
>>>+	struct dsa_slave_priv *p = netdev_priv(dev);
>>>+	struct dsa_switch *ds = p->parent;
>>>+
>>>+	return ds->drv->bond_attach(ds, p->port);
>>
>>You need to test for the callback implementation in the driver, since it
>>is optional and likely not to be implemented immediately.
>>-- 
>>Florian
>>
>Thanks, I missed that.
