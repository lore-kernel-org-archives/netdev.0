From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [RFC PATCH 5/5] geneve: add initial netdev driver for GENEVE
 tunnels
Date: Thu, 2 Apr 2015 22:20:02 +0200
Message-ID: <20150402202002.GG2613@nanopsycho.orion>
References: <1428002227-11636-1-git-send-email-linville@tuxdriver.com>
 <1428002227-11636-6-git-send-email-linville@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Jesse Gross <jesse@nicira.com>, Andy Zhou <azhou@nicira.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Alexander Duyck <alexander.h.duyck@redhat.com>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f182.google.com ([209.85.212.182]:36478 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750942AbbDBUUG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2015 16:20:06 -0400
Received: by wizk4 with SMTP id k4so26849199wiz.1
        for <netdev@vger.kernel.org>; Thu, 02 Apr 2015 13:20:05 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1428002227-11636-6-git-send-email-linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Apr 02, 2015 at 09:17:06PM CEST, linville@tuxdriver.com wrote:
>This is an initial implementation of a netdev driver for GENEVE
>tunnels.  This implementation uses a fixed UDP port, and only supports
>a single tunnel (and therefore only a single VNI) per net namespace.
>Only IPv4 links are supported at this time.


Thanks for doing this John!


>
>Signed-off-by: John W. Linville <linville@tuxdriver.com>
>---
> drivers/net/Kconfig          |  14 ++
> drivers/net/Makefile         |   1 +
> drivers/net/geneve.c         | 451 +++++++++++++++++++++++++++++++++++++++++++
> include/uapi/linux/if_link.h |   9 +
> 4 files changed, 475 insertions(+)
> create mode 100644 drivers/net/geneve.c
>

...

>+/* Initialize the device structure. */
>+static void geneve_setup(struct net_device *dev)
>+{
>+	struct geneve_dev *geneve = netdev_priv(dev);
>+
>+	ether_setup(dev);
>+
>+	dev->netdev_ops = &geneve_netdev_ops;
>+	dev->destructor = free_netdev;
>+	SET_NETDEV_DEVTYPE(dev, &geneve_type);
>+
>+	INIT_WORK(&geneve->sock_work, geneve_sock_work);

I would push work initialization into geneve_newlink. Seems odd to have
it here in setup.

>+
>+	dev->tx_queue_len = 0;
>+	dev->features = 0;
>+
>+	dev->vlan_features = dev->features;
>+	dev->hw_features = 0;
>+
>+	geneve->dev = dev;
>+}
>+
>+static const struct nla_policy geneve_policy[IFLA_GENEVE_MAX + 1] = {
>+	[IFLA_GENEVE_ID]		= { .type = NLA_U32 },
>+	[IFLA_GENEVE_REMOTE]		= { .len = FIELD_SIZEOF(struct iphdr, daddr) },
>+};
>+
>+static int geneve_validate(struct nlattr *tb[], struct nlattr *data[])
>+{
>+	if (tb[IFLA_ADDRESS]) {
>+		if (nla_len(tb[IFLA_ADDRESS]) != ETH_ALEN)
>+			return -EINVAL;
>+
>+		if (!is_valid_ether_addr(nla_data(tb[IFLA_ADDRESS])))
>+			return -EADDRNOTAVAIL;
>+	}
>+
>+	if (!data)
>+		return -EINVAL;
>+
>+	if (data[IFLA_GENEVE_ID]) {
>+		__u32 vni =  nla_get_u32(data[IFLA_GENEVE_ID]);

missing newline

>+		if (vni >= GENEVE_VID_MASK)
>+			return -ERANGE;
>+	}
>+
>+	return 0;
>+}
>+
>+static void geneve_get_drvinfo(struct net_device *dev,
>+			       struct ethtool_drvinfo *drvinfo)
>+{
>+	strlcpy(drvinfo->version, GENEVE_NETDEV_VER, sizeof(drvinfo->version));
>+	strlcpy(drvinfo->driver, "geneve", sizeof(drvinfo->driver));
>+}
>+
>+static const struct ethtool_ops geneve_ethtool_ops = {
>+	.get_drvinfo	= geneve_get_drvinfo,
>+	.get_link	= ethtool_op_get_link,
>+};
>+
>+static int geneve_newlink(struct net *net, struct net_device *dev,
>+			 struct nlattr *tb[], struct nlattr *data[])
>+{
>+	struct geneve_net *gn = net_generic(net, geneve_net_id);
>+	struct geneve_dev *geneve = netdev_priv(dev);
>+	__u32 vni;

why not "u32" ?

>+	int err;
>+
>+	/* TODO: need to support multiple tunnels in a namespace */
>+	if (!list_empty(&gn->geneve_list))
>+		return -EBUSY;

Interesting limitation :)

...

>+static void __net_exit geneve_exit_net(struct net *net)
>+{
>+	struct geneve_net *gn = net_generic(net, geneve_net_id);
>+	struct geneve_dev *geneve, *next;
>+	struct net_device *dev, *aux;
>+	LIST_HEAD(list);
>+
>+	rtnl_lock();
>+	for_each_netdev_safe(net, dev, aux)
>+		if (dev->rtnl_link_ops == &geneve_link_ops)
>+			unregister_netdevice_queue(dev, &list);
>+
>+	list_for_each_entry_safe(geneve, next, &gn->geneve_list, next) {
>+		/* If geneve->dev is in the same netns, it was already added
>+		 * to the list by the previous loop.
>+		 */
>+		if (!net_eq(dev_net(geneve->dev), net))
>+			unregister_netdevice_queue(dev, &list);
>+	}

I know this is c&p of vxlan, but I do not understand why the first loop
is there. The second loop will take care of all since all devs are
listed in ->geneve_list, right?

Also you do not need _safe variant since you traverse through
->geneve_list, which is not modified.

>+
>+	unregister_netdevice_many(&list);
>+	rtnl_unlock();
>+}
