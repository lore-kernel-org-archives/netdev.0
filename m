From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [patch net-next V2] net: introduce ethernet teaming device
Date: Fri, 21 Oct 2011 17:02:51 +0200
Message-ID: <20111021150250.GB10076@minipsycho>
References: <1319200747-2508-1-git-send-email-jpirko@redhat.com>
 <1319208237.32161.14.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	bhutchings@solarflare.com, shemminger@vyatta.com, fubar@us.ibm.com,
	andy@greyhouse.net, tgraf@infradead.org, ebiederm@xmission.com,
	mirqus@gmail.com, kaber@trash.net, greearb@candelatech.com,
	jesse@nicira.com, fbl@redhat.com, benjamin.poirier@gmail.com,
	jzupka@redhat.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42415 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751670Ab1JUPDG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Oct 2011 11:03:06 -0400
Content-Disposition: inline
In-Reply-To: <1319208237.32161.14.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46ri, Oct 21, 2011 at 04:43:57PM CEST, eric.dumazet@gmail.com wrote:
>Le vendredi 21 octobre 2011 =E0 14:39 +0200, Jiri Pirko a =E9crit :
>> This patch introduces new network device called team. It supposes to=
 be
>> very fast, simple, userspace-driven alternative to existing bonding
>> driver.
>>=20
>> Userspace library called libteam with couple of demo apps is availab=
le
>> here:
>> https://github.com/jpirko/libteam
>> Note it's still in its dipers atm.
>>=20
>> team<->libteam use generic netlink for communication. That and rtnl
>> suppose to be the only way to configure team device, no sysfs etc.
>>=20
>> Python binding basis for libteam was recently introduced (some need
>> still need to be done on it though). Daemon providing arpmon/miimon
>> active-backup functionality will be introduced shortly.
>> All what's necessary is already implemented in kernel team driver.
>>=20
>> Signed-off-by: Jiri Pirko <jpirko@redhat.com>
>>=20
>> v1->v2:
>> 	- modes are made as modules. Makes team more modular and
>> 	  extendable.
>> 	- several commenters' nitpicks found on v1 were fixed
>> 	- several other bugs were fixed.
>> 	- note I ignored Eric's comment about roundrobin port selector
>> 	  as Eric's way may be easily implemented as another mode (mode
>> 	  "random") in future.
>> ---
>
>Very nice work !
>
>> +
>> +
>> +/*
>> + * We can benefit from the fact that it's ensured no port is presen=
t
>> + * at the time of mode change.
>> + */
>> +static int __team_change_mode(struct team *team,
>> +			      const struct team_mode *new_mode)
>> +{
>> +	/* Check if mode was previously set and do cleanup if so */
>> +	if (team->mode_kind) {
>> +		void (*exit_op)(struct team *team) =3D team->mode_ops.exit;
>> +
>> +		/* Clear ops area so no callback is called any longer */
>> +		memset(&team->mode_ops, 0, sizeof(struct team_mode_ops));
>
>	Hmm, memset() has no atomicity guarantee about 'longs' or 'pointers'.
>
>	You must make sure mode_ops.receive (and other pointers) is set not
>byte per byte, but in one go.

:( What do you suggest? Set these pointers one-by-one?

>
>> +
>> +		synchronize_rcu();
>> +
>> +		if (exit_op)
>> +			exit_op(team);
>> +		team_mode_put(team->mode_kind);
>> +		team->mode_kind =3D NULL;
>> +		/* zero private data area */
>> +		memset(&team->mode_priv, 0,
>> +		       sizeof(struct team) - offsetof(struct team, mode_priv));
>> +	}
>> +
>> +	if (!new_mode)
>> +		return 0;
>> +
>> +	if (new_mode->ops->init) {
>> +		int err;
>> +
>> +		err =3D new_mode->ops->init(team);
>> +		if (err)
>> +			return err;
>> +	}
>> +
>> +	team->mode_kind =3D new_mode->kind;
>> +	memcpy(&team->mode_ops, new_mode->ops, sizeof(struct team_mode_ops=
));
>> +
>> +	return 0;
>> +}
>> +
>
>> +
>> +/************************
>> + * Rx path frame handler
>> + ************************/
>> +
>> +/* note: already called with rcu_read_lock */
>> +static rx_handler_result_t team_handle_frame(struct sk_buff **pskb)
>> +{
>> +	struct sk_buff *skb =3D *pskb;
>> +	struct team_port *port;
>> +	struct team *team;
>> +	rx_handler_result_t res =3D RX_HANDLER_ANOTHER;
>> +
>> +	skb =3D skb_share_check(skb, GFP_ATOMIC);
>> +	if (!skb)
>> +		return RX_HANDLER_CONSUMED;
>> +
>> +	*pskb =3D skb;
>> +
>> +	port =3D team_port_get_rcu(skb->dev);
>> +	team =3D port->team;
>> +
>> +	if (team->mode_ops.receive)
>
>Hmm, you need ACCESS_ONCE() here or rcu_dereference()
>
>See commit 4d97480b1806e883eb (bonding: use local function pointer of
>bond->recv_probe in bond_handle_frame) for reference

Will do

>
>> +		res =3D team->mode_ops.receive(team, port, skb);
>> +
>> +	if (res =3D=3D RX_HANDLER_ANOTHER) {
>> +		struct team_pcpu_stats *pcpu_stats;
>> +
>> +		pcpu_stats =3D this_cpu_ptr(team->pcpu_stats);
>> +		u64_stats_update_begin(&pcpu_stats->syncp);
>> +		pcpu_stats->rx_packets++;
>> +		pcpu_stats->rx_bytes +=3D skb->len;
>> +		if (skb->pkt_type =3D=3D PACKET_MULTICAST)
>> +			pcpu_stats->rx_multicast++;
>> +		u64_stats_update_end(&pcpu_stats->syncp);
>> +
>> +		skb->dev =3D team->dev;
>> +	} else {
>> +		this_cpu_inc(team->pcpu_stats->rx_dropped);
>> +	}
>> +
>> +	return res;
>> +}
>> +
>
>
>> +
>> +static int team_port_enter(struct team *team, struct team_port *por=
t)
>> +{
>> +	int err =3D 0;
>> +
>> +	dev_hold(team->dev);
>> +	port->dev->priv_flags |=3D IFF_TEAM_PORT;
>> +	if (team->mode_ops.port_enter) {
>> +		err =3D team->mode_ops.port_enter(team, port);
>> +		if (err)
>> +			netdev_err(team->dev, "Device %s failed to enter team mode\n",
>> +				   port->dev->name);
>
>		Not sure if you need to unset IFF_TEAM_PORT;

I do. I will add it.

>
>> +	}
>> +	return err;
>> +}
>> +
>
>
>> diff --git a/include/linux/if_team.h b/include/linux/if_team.h
>> new file mode 100644
>> index 0000000..21581a7
>> --- /dev/null
>> +++ b/include/linux/if_team.h
>> @@ -0,0 +1,233 @@
>> +/*
>> + * include/linux/if_team.h - Network team device driver header
>> + * Copyright (c) 2011 Jiri Pirko <jpirko@redhat.com>
>> + *
>> + * This program is free software; you can redistribute it and/or mo=
dify
>> + * it under the terms of the GNU General Public License as publishe=
d by
>> + * the Free Software Foundation; either version 2 of the License, o=
r
>> + * (at your option) any later version.
>> + */
>> +
>> +#ifndef _LINUX_IF_TEAM_H_
>> +#define _LINUX_IF_TEAM_H_
>> +
>> +#ifdef __KERNEL__
>> +
>> +struct team_pcpu_stats {
>> +	u64			rx_packets;
>> +	u64			rx_bytes;
>> +	u64			rx_multicast;
>> +	u64			tx_packets;
>> +	u64			tx_bytes;
>> +	struct u64_stats_sync	syncp;
>> +	u32			rx_dropped;
>> +	u32			tx_dropped;
>
>	"unsigned long" for these two fields ?

I copied these from some other driver (macvlan I think). I will change
this to unsigned long.

>
>> +};
>> +
>> +struct team;
>> +
>> +struct team_port {
>> +	struct net_device *dev;
>> +	struct hlist_node hlist; /* node in hash list */
>> +	struct list_head list; /* node in ordinary list */
>> +	struct team *team;
>> +	int index;
>> +
>> +	/*
>> +	 * A place for storing original values of the device before it
>> +	 * become a port.
>> +	 */
>> +	struct {
>> +		unsigned char dev_addr[MAX_ADDR_LEN];
>> +		unsigned int mtu;
>> +	} orig;
>> +
>> +	bool linkup;
>> +	u32 speed;
>> +	u8 duplex;
>> +
>> +	struct rcu_head rcu;
>> +};
>> +
>> +struct team_mode_ops {
>> +	int (*init)(struct team *team);
>> +	void (*exit)(struct team *team);
>> +	rx_handler_result_t (*receive)(struct team *team,
>> +				       struct team_port *port,
>> +				       struct sk_buff *skb);
>> +	bool (*transmit)(struct team *team, struct sk_buff *skb);
>> +	int (*port_enter)(struct team *team, struct team_port *port);
>> +	void (*port_leave)(struct team *team, struct team_port *port);
>> +	void (*port_change_mac)(struct team *team, struct team_port *port)=
;
>> +};
>> +
>> +enum team_option_type {
>> +	TEAM_OPTION_TYPE_U32,
>> +	TEAM_OPTION_TYPE_STRING,
>> +};
>> +
>> +struct team_option {
>> +	struct list_head list;
>> +	const char *name;
>> +	enum team_option_type type;
>> +	int (*getter)(struct team *team, void *arg);
>> +	int (*setter)(struct team *team, void *arg);
>> +};
>> +
>> +struct team_mode {
>> +	struct list_head list;
>> +	const char *kind;
>> +	struct module *owner;
>> +	size_t priv_size;
>> +	const struct team_mode_ops *ops;
>> +};
>> +
>> +#define TEAM_MODE_PRIV_LONGS 4
>> +#define TEAM_MODE_PRIV_SIZE (sizeof(long) * TEAM_MODE_PRIV_LONGS)
>> +
>> +struct team {
>> +	struct net_device *dev; /* associated netdevice */
>
>
>> +	struct team_pcpu_stats __percpu *pcpu_stats;
>
>	I believe you can use net_device->anonymous_union, the one with
>ml_priv :
>	struct pcpu_lstats __percpu *lstats; /* loopback stats */
>	struct pcpu_tstats __percpu *tstats; /* tunnel stats */
>	struct pcpu_dstats __percpu *dstats; /* dummy stats */
>and add here
>	struct team_pcpu_stats __percpu *team_stats;

I this the right way? I must say I do not like it too much :(


>
>> +
>> +	spinlock_t lock; /* used for overall locking, e.g. port lists writ=
e */
>> +
>> +	/*
>> +	 * port lists with port count
>> +	 */
>> +	int port_count;
>> +	struct hlist_head *port_hlist;
>
>	I am not sure why you want an external hash table, with 16 pointers..=
=2E
>This could be embedded here to remove one dereference ?

Good point! Will change this.


Thanks Eric!

Jirka

>
>> +	struct list_head port_list;
>> +
>> +	struct list_head option_list;
>> +
>> +	const char *mode_kind;
>> +	struct team_mode_ops mode_ops;
>> +	long mode_priv[TEAM_MODE_PRIV_LONGS];
>> +};
>> +
>
>
