From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [patch net-next V2] net: introduce ethernet teaming device
Date: Sat, 22 Oct 2011 17:55:40 +0200
Message-ID: <20111022155540.GB2028@minipsycho.orion>
References: <1319200747-2508-1-git-send-email-jpirko@redhat.com>
 <3128.1319221621@death>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	eric.dumazet@gmail.com, bhutchings@solarflare.com,
	shemminger@vyatta.com, andy@greyhouse.net, tgraf@infradead.org,
	ebiederm@xmission.com, mirqus@gmail.com, kaber@trash.net,
	greearb@candelatech.com, jesse@nicira.com, fbl@redhat.com,
	benjamin.poirier@gmail.com, jzupka@redhat.com
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:64386 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753562Ab1JVPz4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 22 Oct 2011 11:55:56 -0400
Content-Disposition: inline
In-Reply-To: <3128.1319221621@death>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Oct 21, 2011 at 08:27:01PM CEST, fubar@us.ibm.com wrote:
>Jiri Pirko <jpirko@redhat.com> wrote:
>
>>This patch introduces new network device called team. It supposes to be
>>very fast, simple, userspace-driven alternative to existing bonding
>>driver.
>>
>>Userspace library called libteam with couple of demo apps is available
>>here:
>>https://github.com/jpirko/libteam
>>Note it's still in its dipers atm.
>>
>>team<->libteam use generic netlink for communication. That and rtnl
>>suppose to be the only way to configure team device, no sysfs etc.
>>
>>Python binding basis for libteam was recently introduced (some need
>>still need to be done on it though). Daemon providing arpmon/miimon
>>active-backup functionality will be introduced shortly.
>>All what's necessary is already implemented in kernel team driver.
>>
>>Signed-off-by: Jiri Pirko <jpirko@redhat.com>
>>
>>v1->v2:
>>	- modes are made as modules. Makes team more modular and
>>	  extendable.
>>	- several commenters' nitpicks found on v1 were fixed
>>	- several other bugs were fixed.
>>	- note I ignored Eric's comment about roundrobin port selector
>>	  as Eric's way may be easily implemented as another mode (mode
>>	  "random") in future.
>>---
>
>[...]
>
>>+static int team_port_add(struct team *team, struct net_device *port_dev)
>>+{
>>+	struct net_device *dev = team->dev;
>>+	struct team_port *port;
>>+	char *portname = port_dev->name;
>>+	char tmp_addr[ETH_ALEN];
>>+	int err;
>>+
>>+	if (port_dev->flags & IFF_LOOPBACK ||
>>+	    port_dev->type != ARPHRD_ETHER) {
>>+		netdev_err(dev, "Device %s is of an unsupported type\n",
>>+			   portname);
>>+		return -EINVAL;
>>+	}
>>+
>>+	if (team_port_exists(port_dev)) {
>>+		netdev_err(dev, "Device %s is already a port "
>>+				"of a team device\n", portname);
>>+		return -EBUSY;
>>+	}
>>+
>>+	if (port_dev->flags & IFF_UP) {
>>+		netdev_err(dev, "Device %s is up. Set it down before adding it as a team port\n",
>>+			   portname);
>>+		return -EBUSY;
>>+	}
>>+
>>+	port = kzalloc(sizeof(struct team_port), GFP_KERNEL);
>>+	if (!port)
>>+		return -ENOMEM;
>>+
>>+	port->dev = port_dev;
>>+	port->team = team;
>>+
>>+	port->orig.mtu = port_dev->mtu;
>>+	err = dev_set_mtu(port_dev, dev->mtu);
>>+	if (err) {
>>+		netdev_dbg(dev, "Error %d calling dev_set_mtu\n", err);
>>+		goto err_set_mtu;
>>+	}
>>+
>>+	memcpy(port->orig.dev_addr, port_dev->dev_addr, ETH_ALEN);
>>+	random_ether_addr(tmp_addr);
>>+	err = __set_port_mac(port_dev, tmp_addr);
>>+	if (err) {
>>+		netdev_dbg(dev, "Device %s mac addr set failed\n",
>>+			   portname);
>>+		goto err_set_mac_rand;
>>+	}
>>+
>>+	err = dev_open(port_dev);
>>+	if (err) {
>>+		netdev_dbg(dev, "Device %s opening failed\n",
>>+			   portname);
>>+		goto err_dev_open;
>>+	}
>>+
>>+	err = team_port_set_orig_mac(port);
>>+	if (err) {
>>+		netdev_dbg(dev, "Device %s mac addr set failed - Device does not support addr change when it's opened\n",
>>+			   portname);
>>+		goto err_set_mac_opened;
>>+	}
>
>	This will exclude a number of devices that bonding currently
>provides at least partial support for.
>
>	Most of those are older 10 or 10/100 Ethernet drivers (anything
>that uses eth_mac_addr for its ndo_set_mac_address, I think; there look
>to be about 140 or so of those), but it also includes Infiniband (which
>is excluded explicitly elsewhere).

Team supports only ETH atm. I think it can be easily extended to support
Infiniband in future. But that's not priority now.

The "life mac change" check can be easily moved into port_enter mode
callback to let the mode decide. Then FOM active can be easily implemented
as another mode.

>
>	Another small set of Ethernet devices (those that currently need
>bonding's fail_over_mac option) do permit setting the MAC while open,
>but will misbehave if multiple ports are set to the same MAC.  The usual
>suspects here are ehea and qeth, which are partition-aware devices for
>IBM's pseries and zseries hardware, but there may be others I'm not
>familiar with.

Actually this (FOM2) is very close to the behaviour "activebackup" team
mode has now.


>
>	If these will be permanent limitations of the team driver, then
>this should (eventually) be in the documentation.
>
>	Also, from looking at the code, it's not obvious if nesting of
>teams is supported or not.  I'm not seeing anything in the code that
>would prohibit adding a team device as a port to another team.  If
>nesting of teams is undesirable, it should probably be explicitly tested
>for and disallowed.

Nesting is allowed.



>
>[...]
>
>>+static int __init team_module_init(void)
>>+{
>>+	int err;
>>+
>>+	register_netdevice_notifier(&team_notifier_block);
>>+
>>+	err = rtnl_link_register(&team_link_ops);
>>+	if (err)
>>+		goto err_rtln_reg;
>>+
>>+	err = team_nl_init();
>>+	if (err)
>>+		goto err_nl_init;
>>+
>>+	return 0;
>>+
>>+err_nl_init:
>>+	rtnl_link_unregister(&team_link_ops);
>>+
>>+err_rtln_reg:
>>+	unregister_netdevice_notifier(&team_notifier_block);
>
>	Minor nit: I suspect you meant "err_rtnl_reg" here, and in the
>goto above.

Corrected.

Thanks Jay.


Jirka

>
>	-J
>
>---
>	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
>
