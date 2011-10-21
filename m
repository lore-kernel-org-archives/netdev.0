From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [patch net-next V2] net: introduce ethernet teaming device
Date: Fri, 21 Oct 2011 11:27:01 -0700
Message-ID: <3128.1319221621@death>
References: <1319200747-2508-1-git-send-email-jpirko@redhat.com>
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	eric.dumazet@gmail.com, bhutchings@solarflare.com,
	shemminger@vyatta.com, andy@greyhouse.net, tgraf@infradead.org,
	ebiederm@xmission.com, mirqus@gmail.com, kaber@trash.net,
	greearb@candelatech.com, jesse@nicira.com, fbl@redhat.com,
	benjamin.poirier@gmail.com, jzupka@redhat.com
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:46649 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751165Ab1JUS1d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Oct 2011 14:27:33 -0400
Received: from /spool/local
	by e33.co.us.ibm.com with XMail ESMTP
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Fri, 21 Oct 2011 12:27:32 -0600
Received: from d03av05.boulder.ibm.com (d03av05.boulder.ibm.com [9.17.195.85])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p9LIR6cT130002
	for <netdev@vger.kernel.org>; Fri, 21 Oct 2011 12:27:06 -0600
Received: from d03av05.boulder.ibm.com (loopback [127.0.0.1])
	by d03av05.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p9LIR4jR028278
	for <netdev@vger.kernel.org>; Fri, 21 Oct 2011 12:27:06 -0600
In-reply-to: <1319200747-2508-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Pirko <jpirko@redhat.com> wrote:

>This patch introduces new network device called team. It supposes to be
>very fast, simple, userspace-driven alternative to existing bonding
>driver.
>
>Userspace library called libteam with couple of demo apps is available
>here:
>https://github.com/jpirko/libteam
>Note it's still in its dipers atm.
>
>team<->libteam use generic netlink for communication. That and rtnl
>suppose to be the only way to configure team device, no sysfs etc.
>
>Python binding basis for libteam was recently introduced (some need
>still need to be done on it though). Daemon providing arpmon/miimon
>active-backup functionality will be introduced shortly.
>All what's necessary is already implemented in kernel team driver.
>
>Signed-off-by: Jiri Pirko <jpirko@redhat.com>
>
>v1->v2:
>	- modes are made as modules. Makes team more modular and
>	  extendable.
>	- several commenters' nitpicks found on v1 were fixed
>	- several other bugs were fixed.
>	- note I ignored Eric's comment about roundrobin port selector
>	  as Eric's way may be easily implemented as another mode (mode
>	  "random") in future.
>---

[...]

>+static int team_port_add(struct team *team, struct net_device *port_dev)
>+{
>+	struct net_device *dev = team->dev;
>+	struct team_port *port;
>+	char *portname = port_dev->name;
>+	char tmp_addr[ETH_ALEN];
>+	int err;
>+
>+	if (port_dev->flags & IFF_LOOPBACK ||
>+	    port_dev->type != ARPHRD_ETHER) {
>+		netdev_err(dev, "Device %s is of an unsupported type\n",
>+			   portname);
>+		return -EINVAL;
>+	}
>+
>+	if (team_port_exists(port_dev)) {
>+		netdev_err(dev, "Device %s is already a port "
>+				"of a team device\n", portname);
>+		return -EBUSY;
>+	}
>+
>+	if (port_dev->flags & IFF_UP) {
>+		netdev_err(dev, "Device %s is up. Set it down before adding it as a team port\n",
>+			   portname);
>+		return -EBUSY;
>+	}
>+
>+	port = kzalloc(sizeof(struct team_port), GFP_KERNEL);
>+	if (!port)
>+		return -ENOMEM;
>+
>+	port->dev = port_dev;
>+	port->team = team;
>+
>+	port->orig.mtu = port_dev->mtu;
>+	err = dev_set_mtu(port_dev, dev->mtu);
>+	if (err) {
>+		netdev_dbg(dev, "Error %d calling dev_set_mtu\n", err);
>+		goto err_set_mtu;
>+	}
>+
>+	memcpy(port->orig.dev_addr, port_dev->dev_addr, ETH_ALEN);
>+	random_ether_addr(tmp_addr);
>+	err = __set_port_mac(port_dev, tmp_addr);
>+	if (err) {
>+		netdev_dbg(dev, "Device %s mac addr set failed\n",
>+			   portname);
>+		goto err_set_mac_rand;
>+	}
>+
>+	err = dev_open(port_dev);
>+	if (err) {
>+		netdev_dbg(dev, "Device %s opening failed\n",
>+			   portname);
>+		goto err_dev_open;
>+	}
>+
>+	err = team_port_set_orig_mac(port);
>+	if (err) {
>+		netdev_dbg(dev, "Device %s mac addr set failed - Device does not support addr change when it's opened\n",
>+			   portname);
>+		goto err_set_mac_opened;
>+	}

	This will exclude a number of devices that bonding currently
provides at least partial support for.

	Most of those are older 10 or 10/100 Ethernet drivers (anything
that uses eth_mac_addr for its ndo_set_mac_address, I think; there look
to be about 140 or so of those), but it also includes Infiniband (which
is excluded explicitly elsewhere).

	Another small set of Ethernet devices (those that currently need
bonding's fail_over_mac option) do permit setting the MAC while open,
but will misbehave if multiple ports are set to the same MAC.  The usual
suspects here are ehea and qeth, which are partition-aware devices for
IBM's pseries and zseries hardware, but there may be others I'm not
familiar with.

	If these will be permanent limitations of the team driver, then
this should (eventually) be in the documentation.

	Also, from looking at the code, it's not obvious if nesting of
teams is supported or not.  I'm not seeing anything in the code that
would prohibit adding a team device as a port to another team.  If
nesting of teams is undesirable, it should probably be explicitly tested
for and disallowed.

[...]

>+static int __init team_module_init(void)
>+{
>+	int err;
>+
>+	register_netdevice_notifier(&team_notifier_block);
>+
>+	err = rtnl_link_register(&team_link_ops);
>+	if (err)
>+		goto err_rtln_reg;
>+
>+	err = team_nl_init();
>+	if (err)
>+		goto err_nl_init;
>+
>+	return 0;
>+
>+err_nl_init:
>+	rtnl_link_unregister(&team_link_ops);
>+
>+err_rtln_reg:
>+	unregister_netdevice_notifier(&team_notifier_block);

	Minor nit: I suspect you meant "err_rtnl_reg" here, and in the
goto above.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
