From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [RFC PATCH 14/16] net: dsa: Add new binding implementation
Date: Fri, 27 May 2016 16:39:05 -0400
Message-ID: <8737p3z15i.fsf@ketchup.mtl.sfl>
References: <1464312050-23023-1-git-send-email-andrew@lunn.ch> <1464312050-23023-15-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	John Crispin <john@phrozen.org>, Bryan.Whitehead@microchip.com,
	Andrew Lunn <andrew@lunn.ch>
To: Andrew Lunn <andrew@lunn.ch>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:38724 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933156AbcE0UjL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 May 2016 16:39:11 -0400
In-Reply-To: <1464312050-23023-15-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi Andrew, Florian,

Here again, I'd suggested an implicit namespace for functions taking a
dsa_switch_tree structure as first argument, i.e. dsa_tree_do_foo().

Since we are likely to spend some time in net/dsa, it'd be great to
introduce the new bindings and an intuitive API at the same time ;-)

Examples below.

> +void dsa_unregister_switch(struct dsa_switch *ds);
> +int dsa_register_switch(struct dsa_switch *ds, struct device_node *np);

    void dsa_switch_unregister(struct dsa_switch *ds);
    int dsa_switch_register(struct dsa_switch *ds, struct device_node *np);

> +static struct dsa_switch_tree *dsa_get_dst(u32 tree)
> +static void dsa_free_dst(struct kref *ref)

static struct dsa_switch_tree *dsa_get_tree(u32 tree)
dsa_free_tree()

> +static void dsa_put_dst(struct dsa_switch_tree *dst)

static void dsa_tree_put(struct dsa_switch_tree *dst)

> +static struct dsa_switch_tree *dsa_add_dst(u32 tree)

dsa_add_tree(u32 tree)

> +static void dsa_dst_add_ds(struct dsa_switch_tree *dst,
> +			   struct dsa_switch *ds, u32 index)

static void dsa_tree_add_switch(struct dsa_switch_tree *dst, u32 index,
			        struct dsa_switch *ds)

> +static void dsa_dst_del_ds(struct dsa_switch_tree *dst,
> +			   struct dsa_switch *ds, u32 index)

static void dsa_tree_del_switch(struct dsa_switch_tree *dst, u32 index)

> +static bool dsa_port_is_dsa(struct device_node *port)
> +static bool dsa_port_is_cpu(struct device_node *port)

It would be consistent to have public helpers like:

    bool dsa_port_is_cpu(struct dsa_port *dp);
    bool dsa_port_is_dsa(struct dsa_port *dp);

> +static bool dsa_ds_find_port(struct dsa_switch *ds,
> +			     struct device_node *port)

dsa_switch_find_port_node()

> +static struct dsa_switch *dsa_dst_find_port(struct dsa_switch_tree *dst,
> +					    struct device_node *port)

dsa_tree_find_port_node()

> +static int dsa_port_complete(struct dsa_switch_tree *dst,
> +			     struct dsa_switch *src_ds,
> +			     struct device_node *port,
> +			     u32 src_port)

> +static int dsa_ds_complete(struct dsa_switch_tree *dst, struct dsa_switch *ds)

> +static int dsa_dst_complete(struct dsa_switch_tree *dst)

static int dsa_tree_complete_port(struct dsa_switch_tree *dst,
                                  struct dsa_port *dp)

static int dsa_tree_complete_switch(struct dsa_switch_tree *dst,
                                    struct dsa_switch *ds)

static int dsa_tree_complete(struct dsa_switch_tree *dst)

> +static int dsa_dsa_port_apply(struct device_node *port, u32 index,
> +			      struct dsa_switch *ds)
> +static void dsa_dsa_port_unapply(struct device_node *port, u32 index,
> +				 struct dsa_switch *ds)
> +static int dsa_cpu_port_apply(struct device_node *port, u32 index,
> +			      struct dsa_switch *ds)
> +static void dsa_cpu_port_unapply(struct device_node *port, u32 index,
> +				 struct dsa_switch *ds)
> +static int dsa_user_port_apply(struct device_node *port, u32 index,
> +			       struct dsa_switch *ds)
> +static void dsa_user_port_unapply(struct device_node *port, u32 index,
> +				  struct dsa_switch *ds)

dsa_switch_{un,}apply_{cpu,dsa,user}_port(struct dsa_switch *ds,
                                          struct dsa_port *dp)

> +static int dsa_ds_apply(struct dsa_switch_tree *dst, struct dsa_switch *ds)
> +static void dsa_ds_unapply(struct dsa_switch_tree *dst, struct dsa_switch *ds)

dsa_tree_{un,}apply_switch(dst, ds)

> +static int dsa_dst_apply(struct dsa_switch_tree *dst)
> +static void dsa_dst_unapply(struct dsa_switch_tree *dst)

dsa_tree_{un,}apply(dst)

> +static int dsa_cpu_parse(struct device_node *port, u32 index,
> +			 struct dsa_switch_tree *dst,
> +			 struct dsa_switch *ds)
> +static int dsa_ds_parse(struct dsa_switch_tree *dst, struct dsa_switch *ds)
> +static int dsa_dst_parse(struct dsa_switch_tree *dst)

dsa_tree_parse(dst)
dsa_tree_parse_switch(dst, ds)
dsa_tree_parse_cpu_port(dst, dp)

> +static int dsa_parse_ports_dn(struct device_node *ports, struct dsa_switch *ds)

dsa_switch_parse_port_nodes(struct dsa_switch *ds, struct device_node *ports)

> +static struct device_node *dsa_get_ports(struct dsa_switch *ds,
> +					 struct device_node *np)

dsa_switch_get_port_nodes(struct dsa_switch *ds, struct device_node *np)

> +static int _dsa_register_switch(struct dsa_switch *ds, struct device_node *np)


                                                     
I think it would be great to introduce the following in
include/net/dsa.h:

    enum dsa_port_type {
        DSA_PORT_TYPE_CPU,
        DSA_PORT_TYPE_DSA,
        DSA_PORT_TYPE_USER,
    };

    struct dsa_port {
        struct dsa_switch       *ds;
        unsigned int            index;
        enum dsa_port_type      type;
        ...
    };

and have port helpers and simpler functions for the framework like:

    bool dsa_port_is_{cpu,dsa,user}(struct dsa_port *dp);
    int dsa_switch_{apply,setup}_port(struct dsa_switch *ds,
                                      struct dsa_port *dp);

Also, since most of the content of this file is tree-wide, why not name
it net/dsa/tree.c instead of dsa2.c?

These are just suggestions. What do you think?

Thanks,

        Vivien
