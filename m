From: Ido Schimmel <idosch@mellanox.com>
Subject: Re: [RFC PATCH net-next 1/2] net: bridge: add switchdev attr for
 port bridging
Date: Wed, 9 Mar 2016 23:42:14 +0200
Message-ID: <20160309214214.GA4865@colbert.idosch.org>
References: <1457545368-20647-1-git-send-email-vivien.didelot@savoirfairelinux.com>
 <1457545368-20647-2-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<kernel@savoirfairelinux.com>,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	"Scott Feldman" <sfeldma@gmail.com>, Jiri Pirko <jiri@resnulli.us>,
	<nikolay@cumulusnetworks.com>, Elad Raz <eladr@mellanox.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db3on0094.outbound.protection.outlook.com ([157.55.234.94]:60608
	"EHLO emea01-db3-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750819AbcCIVn0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Mar 2016 16:43:26 -0500
Content-Disposition: inline
In-Reply-To: <1457545368-20647-2-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Vivien,

Wed, Mar 09, 2016 at 07:42:47PM IST, vivien.didelot@savoirfairelinux.com wrote:
>Add a new SWITCHDEV_ATTR_ID_PORT_BRIDGE_IF switchdev attribute which is
>set before adding a port to a bridge and deleting a port from a bridge.
>
>The main purpose for this attribute is to provide switchdev users a
>simple and common way to retrieve bridging information, instead of
>implementing complex notifier blocks to listen to global netdev events.
>
>We can also imagine a switchdev user returning an error different from
>-EOPNOTSUPP in the prepare phase to prevent a port from being bridged.

I don't really understand the motivation for this change. We are already
doing all these stuff with the notifiers and it's pretty
straight-forward.

In fact, I believe using an existing mechanism instead of introducing
more switchdev hooks is more elegant. This RFC only deals with bridge,
but you'll have to do the same for team, bond and vlan devices. And
you'll probably place the hooks in the exact locations where the
notifiers are called from anyway.

>
>Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
>---
> include/net/switchdev.h |  2 ++
> net/bridge/br_if.c      | 27 +++++++++++++++++++++++++++
> 2 files changed, 29 insertions(+)
>
>diff --git a/include/net/switchdev.h b/include/net/switchdev.h
>index d451122..65f8514 100644
>--- a/include/net/switchdev.h
>+++ b/include/net/switchdev.h
>@@ -46,6 +46,7 @@ enum switchdev_attr_id {
> 	SWITCHDEV_ATTR_ID_PORT_PARENT_ID,
> 	SWITCHDEV_ATTR_ID_PORT_STP_STATE,
> 	SWITCHDEV_ATTR_ID_PORT_BRIDGE_FLAGS,
>+	SWITCHDEV_ATTR_ID_PORT_BRIDGE_IF,
> 	SWITCHDEV_ATTR_ID_BRIDGE_AGEING_TIME,
> 	SWITCHDEV_ATTR_ID_BRIDGE_VLAN_FILTERING,
> };
>@@ -58,6 +59,7 @@ struct switchdev_attr {
> 		struct netdev_phys_item_id ppid;	/* PORT_PARENT_ID */
> 		u8 stp_state;				/* PORT_STP_STATE */
> 		unsigned long brport_flags;		/* PORT_BRIDGE_FLAGS */
>+		bool join;				/* PORT_BRIDGE_IF */
> 		u32 ageing_time;			/* BRIDGE_AGEING_TIME */
> 		bool vlan_filtering;			/* BRIDGE_VLAN_FILTERING */
> 	} u;
>diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
>index a73df33..105b9fd 100644
>--- a/net/bridge/br_if.c
>+++ b/net/bridge/br_if.c
>@@ -28,6 +28,24 @@
> 
> #include "br_private.h"
> 
>+static int switchdev_bridge_if(struct net_device *dev, struct net_bridge *br,
>+			       bool join)
>+{
>+	struct switchdev_attr attr = {
>+		.orig_dev = br->dev,

This should be just 'dev', since you need to know for which stacked
device on top of the port this was called for. This also means you'll
have to call netdev_master_upper_dev_get() from within your driver if
you want to limit the number of VLAN filtering bridges (for example).
However, since this is called before bridge dev and dev itself are
linked, you'll get NULL.

>+		.id = SWITCHDEV_ATTR_ID_PORT_BRIDGE_IF,
>+		.flags = SWITCHDEV_F_SKIP_EOPNOTSUPP,
>+		.u.join = join,
>+	};
>+	int err;
>+
>+	err = switchdev_port_attr_set(dev, &attr);
>+	if (err && err != -EOPNOTSUPP)
>+		return err;
>+
>+	return 0;
>+}
>+
> /*
>  * Determine initial path cost based on speed.
>  * using recommendations from 802.1d standard
>@@ -297,6 +315,10 @@ static void del_nbp(struct net_bridge_port *p)
> 	br_netpoll_disable(p);
> 
> 	call_rcu(&p->rcu, destroy_nbp_rcu);
>+
>+	if (switchdev_bridge_if(dev, br, false))
>+		br_warn(br, "error unbridging port %u(%s)\n",
>+			(unsigned int) p->port_no, dev->name);
> }
> 
> /* Delete bridge device */
>@@ -347,6 +369,11 @@ static struct net_bridge_port *new_nbp(struct net_bridge *br,
> {
> 	int index;
> 	struct net_bridge_port *p;
>+	int err;
>+
>+	err = switchdev_bridge_if(dev, br, true);

If you look at br_add_if() - where new_nbp() is called from - then
you'll see that you aren't rollbacking this operation in case of error.
Same for subsequent errors in this function I believe.

>+	if (err)
>+		return ERR_PTR(err);
> 
> 	index = find_portno(br);
> 	if (index < 0)
>-- 
>2.7.2
>

Maybe this is something we'll have to do in the future, but for now I
think we are OK with the notifiers. :)

Thanks Vivien!
