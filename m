From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v2 1/4] net: dsa: Add plumbing for port mirroring
Date: Sat, 28 Jan 2017 10:14:49 +0100
Message-ID: <20170128091449.GA2033@nanopsycho>
References: <20170128012528.30524-1-f.fainelli@gmail.com>
 <20170128012528.30524-2-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, cphealy@gmail.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:32967 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750824AbdA1JXO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 28 Jan 2017 04:23:14 -0500
Received: by mail-wm0-f65.google.com with SMTP id v77so2478095wmv.0
        for <netdev@vger.kernel.org>; Sat, 28 Jan 2017 01:21:46 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20170128012528.30524-2-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sat, Jan 28, 2017 at 02:25:25AM CET, f.fainelli@gmail.com wrote:
>Add necessary plumbing at the slave network device level to have switch
>drivers implement ndo_setup_tc() and most particularly the cls_matchall
>classifier. We add support for two switch operations:
>
>port_add_mirror and port_del_mirror() which configure, on a per-port
>basis the mirror parameters requested from the cls_matchall classifier.
>
>Code is largely borrowed from the Mellanox Spectrum switch driver.
>
>Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
>---

[...]


>+/*
>+ * Mirroring TC entry
>+ */
>+struct dsa_mall_mirror_tc_entry {
>+	u8 to_local_port;
>+	bool ingress;
>+};
>+
>+/*
>+ * TC matchall entry
>+ */

Why are you using multiline comment format for single line comments?


>+struct dsa_mall_tc_entry {
>+	struct list_head list;
>+	unsigned long cookie;
>+	enum dsa_port_mall_action_type type;
>+	union {
>+		struct dsa_mall_mirror_tc_entry mirror;
>+	};
>+};
>+
>+
> struct dsa_port {
> 	struct net_device	*netdev;
> 	struct device_node	*dn;
>@@ -370,6 +397,15 @@ struct dsa_switch_ops {
> 	int	(*port_mdb_dump)(struct dsa_switch *ds, int port,
> 				 struct switchdev_obj_port_mdb *mdb,
> 				 int (*cb)(struct switchdev_obj *obj));
>+
>+	/*
>+	 * TC integration
>+	 */
>+	int	(*port_mirror_add)(struct dsa_switch *ds, int port,
>+				   struct dsa_mall_mirror_tc_entry *mirror,
>+				   bool ingress);
>+	void	(*port_mirror_del)(struct dsa_switch *ds, int port,
>+				   struct dsa_mall_mirror_tc_entry *mirror);
> };

[...]


>+static int dsa_slave_add_cls_matchall(struct net_device *dev,
>+				      __be16 protocol,
>+				      struct tc_cls_matchall_offload *cls,
>+				      bool ingress)
>+{
>+	struct dsa_slave_priv *p = netdev_priv(dev);
>+	struct dsa_mall_tc_entry *mall_tc_entry;
>+	struct dsa_switch *ds = p->parent;
>+	struct net *net = dev_net(dev);
>+	struct dsa_slave_priv *to_p;
>+	struct net_device *to_dev;
>+	const struct tc_action *a;
>+	int err = -EOPNOTSUPP;
>+	LIST_HEAD(actions);
>+	int ifindex;
>+
>+	if (!ds->ops->port_mirror_add)
>+		return err;
>+
>+	if (!tc_single_action(cls->exts)) {
>+		netdev_err(dev, "only singular actions are supported\n");

Why you note the user in this case, but in case he tries to add
non-supported action you don't note him?


>+		return err;
>+	}
>+
>+	mall_tc_entry = kzalloc(sizeof(*mall_tc_entry), GFP_KERNEL);
>+	if (!mall_tc_entry)
>+		return -ENOMEM;
>+	mall_tc_entry->cookie = cls->cookie;

Hmm, I believe that this allocation and initialization should go into
the "is_mirred if". You can do the checks in advance. That would also
make the error path simplier.


>+
>+	tcf_exts_to_list(cls->exts, &actions);
>+	a = list_first_entry(&actions, struct tc_action, list);
>+
>+	if (is_tcf_mirred_egress_mirror(a) && protocol == htons(ETH_P_ALL)) {
>+		struct dsa_mall_mirror_tc_entry *mirror;
>+
>+		mall_tc_entry->type = DSA_PORT_MALL_MIRROR;
>+		mirror = &mall_tc_entry->mirror;
>+
>+		ifindex = tcf_mirred_ifindex(a);
>+		to_dev = __dev_get_by_index(net, ifindex);
>+		if (!to_dev) {
>+			err = -EINVAL;
>+			goto err_add_action;
>+		}
>+
>+		if (!dsa_slave_dev_check(to_dev)) {
>+			err = -EOPNOTSUPP;
>+			goto err_add_action;
>+		}
>+
>+		to_p = netdev_priv(to_dev);
>+
>+		mirror->to_local_port = to_p->port;
>+		mirror->ingress = ingress;
>+
>+		err = ds->ops->port_mirror_add(ds, p->port, mirror, ingress);
>+	}
>+
>+	if (err)
>+		goto err_add_action;
>+
>+	list_add_tail(&mall_tc_entry->list, &p->mall_tc_list);
>+	return 0;
>+
>+err_add_action:
>+	kfree(mall_tc_entry);
>+	return err;
>+}
