From: Ivan Vecera <ivecera@redhat.com>
Subject: Re: [patch net-next v2 05/19] net: bridge: Add support for notifying
 devices about FDB add/del
Date: Thu, 8 Jun 2017 11:30:46 +0200
Message-ID: <57d0c0d6-7da2-faa0-4064-33554f3a4146@redhat.com>
References: <20170608064428.4785-1-jiri@resnulli.us>
 <20170608064428.4785-6-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, idosch@mellanox.com, arkadis@mellanox.com,
        mlxsw@mellanox.com, roopa@cumulusnetworks.com,
        stephen@networkplumber.org, nikolay@cumulusnetworks.com
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50438 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751619AbdFHJay (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 8 Jun 2017 05:30:54 -0400
In-Reply-To: <20170608064428.4785-6-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8.6.2017 08:44, Jiri Pirko wrote:
> From: Arkadi Sharshevsky <arkadis@mellanox.com>
> 
> Currently the bridge doesn't notify the underlying devices about new
> FDBs learned. The FDB sync is placed on the switchdev notifier chain
> because devices may potentially learn FDB that are not directly related
> to their ports, for example:
> 
> 1. Mixed SW/HW bridge - FDBs that point to the ASICs external devices
>                         should be offloaded as CPU traps in order to
> 			perform forwarding in slow path.
> 2. EVPN - Externally learned FDBs for the vtep device.
> 
> Notification is sent only about static FDB add/del. This is done due
> to fact that currently this is the only scenario supported by switch
> drivers.
> 
> Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
> Reviewed-by: Ido Schimmel <idosch@mellanox.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> ---
>  .../ethernet/mellanox/mlxsw/spectrum_switchdev.c   |  2 +-
>  drivers/net/ethernet/rocker/rocker_ofdpa.c         |  4 +--
>  include/net/switchdev.h                            |  6 ++--
>  net/bridge/br.c                                    |  4 +--
>  net/bridge/br_fdb.c                                |  2 ++
>  net/bridge/br_private.h                            |  7 +++++
>  net/bridge/br_switchdev.c                          | 33 ++++++++++++++++++++++
>  7 files changed, 51 insertions(+), 7 deletions(-)
> 
> diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
> index edcc273..0111a77 100644
> --- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
> +++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
> @@ -1867,7 +1867,7 @@ static void mlxsw_sp_fdb_call_notifiers(bool learning_sync, bool adding,
>  	if (learning_sync) {
>  		info.addr = mac;
>  		info.vid = vid;
> -		notifier_type = adding ? SWITCHDEV_FDB_ADD : SWITCHDEV_FDB_DEL;
> +		notifier_type = adding ? SWITCHDEV_FDB_ADD_TO_BRIDGE : SWITCHDEV_FDB_DEL_TO_BRIDGE;
>  		call_switchdev_notifiers(notifier_type, dev, &info.info);
>  	}
>  }
> diff --git a/drivers/net/ethernet/rocker/rocker_ofdpa.c b/drivers/net/ethernet/rocker/rocker_ofdpa.c
> index 2ae8524..f659dad 100644
> --- a/drivers/net/ethernet/rocker/rocker_ofdpa.c
> +++ b/drivers/net/ethernet/rocker/rocker_ofdpa.c
> @@ -1939,10 +1939,10 @@ static void ofdpa_port_fdb_learn_work(struct work_struct *work)
>  
>  	rtnl_lock();
>  	if (learned && removing)
> -		call_switchdev_notifiers(SWITCHDEV_FDB_DEL,
> +		call_switchdev_notifiers(SWITCHDEV_FDB_DEL_TO_BRIDGE,
>  					 lw->ofdpa_port->dev, &info.info);
>  	else if (learned && !removing)
> -		call_switchdev_notifiers(SWITCHDEV_FDB_ADD,
> +		call_switchdev_notifiers(SWITCHDEV_FDB_ADD_TO_BRIDGE,
>  					 lw->ofdpa_port->dev, &info.info);
>  	rtnl_unlock();
>  
> diff --git a/include/net/switchdev.h b/include/net/switchdev.h
> index 63a754d..8165ed9 100644
> --- a/include/net/switchdev.h
> +++ b/include/net/switchdev.h
> @@ -155,8 +155,10 @@ struct switchdev_ops {
>  };
>  
>  enum switchdev_notifier_type {
> -	SWITCHDEV_FDB_ADD = 1,
> -	SWITCHDEV_FDB_DEL,
> +	SWITCHDEV_FDB_ADD_TO_BRIDGE = 1,
> +	SWITCHDEV_FDB_DEL_TO_BRIDGE,
> +	SWITCHDEV_FDB_ADD_TO_DEVICE,
> +	SWITCHDEV_FDB_DEL_TO_DEVICE,
>  };
>  
>  struct switchdev_notifier_info {
> diff --git a/net/bridge/br.c b/net/bridge/br.c
> index e962fff..96d209c 100644
> --- a/net/bridge/br.c
> +++ b/net/bridge/br.c
> @@ -138,14 +138,14 @@ static int br_switchdev_event(struct notifier_block *unused,
>  	br = p->br;
>  
>  	switch (event) {
> -	case SWITCHDEV_FDB_ADD:
> +	case SWITCHDEV_FDB_ADD_TO_BRIDGE:
>  		fdb_info = ptr;
>  		err = br_fdb_external_learn_add(br, p, fdb_info->addr,
>  						fdb_info->vid);
>  		if (err)
>  			err = notifier_from_errno(err);
>  		break;
> -	case SWITCHDEV_FDB_DEL:
> +	case SWITCHDEV_FDB_DEL_TO_BRIDGE:
>  		fdb_info = ptr;
>  		err = br_fdb_external_learn_del(br, p, fdb_info->addr,
>  						fdb_info->vid);
> diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
> index 5c780cd..26a1dae 100644
> --- a/net/bridge/br_fdb.c
> +++ b/net/bridge/br_fdb.c
> @@ -690,6 +690,8 @@ static void fdb_notify(struct net_bridge *br,
>  	struct sk_buff *skb;
>  	int err = -ENOBUFS;
>  
> +	br_switchdev_fdb_notify(fdb, type);
> +
>  	skb = nlmsg_new(fdb_nlmsg_size(), GFP_ATOMIC);
>  	if (skb == NULL)
>  		goto errout;
> diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
> index a122684..98410ea 100644
> --- a/net/bridge/br_private.h
> +++ b/net/bridge/br_private.h
> @@ -1085,6 +1085,8 @@ bool nbp_switchdev_allowed_egress(const struct net_bridge_port *p,
>  int br_switchdev_set_port_flag(struct net_bridge_port *p,
>  			       unsigned long flags,
>  			       unsigned long mask);
> +void br_switchdev_fdb_notify(const struct net_bridge_fdb_entry *fdb,
> +			     int type);
>  #else
>  static inline int nbp_switchdev_mark_set(struct net_bridge_port *p)
>  {
> @@ -1108,6 +1110,11 @@ static inline int br_switchdev_set_port_flag(struct net_bridge_port *p,
>  {
>  	return 0;
>  }
> +
> +static inline void
> +br_switchdev_fdb_notify(const struct net_bridge_fdb_entry *fdb, int type)
> +{
> +}
>  #endif /* CONFIG_NET_SWITCHDEV */
>  
>  #endif
> diff --git a/net/bridge/br_switchdev.c b/net/bridge/br_switchdev.c
> index b975959..181a44d 100644
> --- a/net/bridge/br_switchdev.c
> +++ b/net/bridge/br_switchdev.c
> @@ -98,3 +98,36 @@ int br_switchdev_set_port_flag(struct net_bridge_port *p,
>  
>  	return 0;
>  }
> +
> +static void
> +br_switchdev_fdb_call_notifiers(bool adding, const unsigned char *mac,
> +				u16 vid, struct net_device *dev)
> +{
> +	struct switchdev_notifier_fdb_info info;
> +	unsigned long notifier_type;
> +
> +	info.addr = mac;
> +	info.vid = vid;
> +	notifier_type = adding ? SWITCHDEV_FDB_ADD_TO_DEVICE : SWITCHDEV_FDB_DEL_TO_DEVICE;
> +	call_switchdev_notifiers(notifier_type, dev, &info.info);
> +}
> +
> +void
> +br_switchdev_fdb_notify(const struct net_bridge_fdb_entry *fdb, int type)
> +{
> +	if (!fdb->added_by_user)
> +		return;
> +
> +	switch (type) {
> +	case RTM_DELNEIGH:
> +		br_switchdev_fdb_call_notifiers(false, fdb->addr.addr,
> +						fdb->vlan_id,
> +						fdb->dst->dev);
> +		break;
> +	case RTM_NEWNEIGH:
> +		br_switchdev_fdb_call_notifiers(true, fdb->addr.addr,
> +						fdb->vlan_id,
> +						fdb->dst->dev);
> +		break;
> +	}
> +}
> 

Reviewed-by: Ivan Vecera <ivecera@redhat.com>
