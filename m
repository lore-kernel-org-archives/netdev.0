From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [patch net-next 04/12] ipmr: Send FIB notifications on MFC and
 VIF entries
Date: Thu, 21 Sep 2017 14:48:58 +0300
Message-ID: <9886cf14-78e7-f23f-75ed-79fbcd2e3dcf@cumulusnetworks.com>
References: <20170921064338.1282-1-jiri@resnulli.us>
 <20170921064338.1282-5-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, yotamg@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:45050 "EHLO
        mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751387AbdIULtC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2017 07:49:02 -0400
Received: by mail-wm0-f48.google.com with SMTP id m127so501352wmm.1
        for <netdev@vger.kernel.org>; Thu, 21 Sep 2017 04:49:01 -0700 (PDT)
In-Reply-To: <20170921064338.1282-5-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 21/09/17 09:43, Jiri Pirko wrote:
> From: Yotam Gigi <yotamg@mellanox.com>
> 
> Use the newly introduced notification chain to send events upon VIF and MFC
> addition and deletion. The MFC notifications are sent only on resolved MFC
> entries, as unresolved cannot be offloaded.
> 
> Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
> Reviewed-by: Ido Schimmel <idosch@mellanox.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> ---
>  net/ipv4/ipmr.c | 53 +++++++++++++++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 53 insertions(+)
> 

LGTM, I only wish we could consolidate all of these call_ipmr_mfc_entry_notifiers()
calls inside mroute_netlink_event() but it will need an additional argument for the
ADD vs REPLACE cases. Anyway,

Reviewed-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

> diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
> index 9d331a74..7891d95 100644
> --- a/net/ipv4/ipmr.c
> +++ b/net/ipv4/ipmr.c
> @@ -627,6 +627,27 @@ static int call_ipmr_vif_entry_notifier(struct notifier_block *nb,
>  	return call_fib_notifier(nb, net, event_type, &info.info);
>  }
>  
> +static int call_ipmr_vif_entry_notifiers(struct net *net,
> +					 enum fib_event_type event_type,
> +					 struct vif_device *vif,
> +					 vifi_t vif_index, u32 tb_id)
> +{
> +	struct vif_entry_notifier_info info = {
> +		.info = {
> +			.family = RTNL_FAMILY_IPMR,
> +			.net = net,
> +		},
> +		.dev = vif->dev,
> +		.vif_index = vif_index,
> +		.vif_flags = vif->flags,
> +		.tb_id = tb_id,
> +	};
> +
> +	ASSERT_RTNL();
> +	net->ipv4.ipmr_seq++;
> +	return call_fib_notifiers(net, event_type, &info.info);
> +}
> +
>  static int call_ipmr_mfc_entry_notifier(struct notifier_block *nb,
>  					struct net *net,
>  					enum fib_event_type event_type,
> @@ -644,6 +665,24 @@ static int call_ipmr_mfc_entry_notifier(struct notifier_block *nb,
>  	return call_fib_notifier(nb, net, event_type, &info.info);
>  }
>  
> +static int call_ipmr_mfc_entry_notifiers(struct net *net,
> +					 enum fib_event_type event_type,
> +					 struct mfc_cache *mfc, u32 tb_id)
> +{
> +	struct mfc_entry_notifier_info info = {
> +		.info = {
> +			.family = RTNL_FAMILY_IPMR,
> +			.net = net,
> +		},
> +		.mfc = mfc,
> +		.tb_id = tb_id
> +	};
> +
> +	ASSERT_RTNL();
> +	net->ipv4.ipmr_seq++;
> +	return call_fib_notifiers(net, event_type, &info.info);
> +}
> +
>  /**
>   *	vif_delete - Delete a VIF entry
>   *	@notify: Set to 1, if the caller is a notifier_call
> @@ -651,6 +690,7 @@ static int call_ipmr_mfc_entry_notifier(struct notifier_block *nb,
>  static int vif_delete(struct mr_table *mrt, int vifi, int notify,
>  		      struct list_head *head)
>  {
> +	struct net *net = read_pnet(&mrt->net);
>  	struct vif_device *v;
>  	struct net_device *dev;
>  	struct in_device *in_dev;
> @@ -660,6 +700,10 @@ static int vif_delete(struct mr_table *mrt, int vifi, int notify,
>  
>  	v = &mrt->vif_table[vifi];
>  
> +	if (VIF_EXISTS(mrt, vifi))
> +		call_ipmr_vif_entry_notifiers(net, FIB_EVENT_VIF_DEL, v, vifi,
> +					      mrt->id);
> +
>  	write_lock_bh(&mrt_lock);
>  	dev = v->dev;
>  	v->dev = NULL;
> @@ -909,6 +953,7 @@ static int vif_add(struct net *net, struct mr_table *mrt,
>  	if (vifi+1 > mrt->maxvif)
>  		mrt->maxvif = vifi+1;
>  	write_unlock_bh(&mrt_lock);
> +	call_ipmr_vif_entry_notifiers(net, FIB_EVENT_VIF_ADD, v, vifi, mrt->id);
>  	return 0;
>  }
>  
> @@ -1209,6 +1254,7 @@ static int ipmr_cache_unresolved(struct mr_table *mrt, vifi_t vifi,
>  
>  static int ipmr_mfc_delete(struct mr_table *mrt, struct mfcctl *mfc, int parent)
>  {
> +	struct net *net = read_pnet(&mrt->net);
>  	struct mfc_cache *c;
>  
>  	/* The entries are added/deleted only under RTNL */
> @@ -1220,6 +1266,7 @@ static int ipmr_mfc_delete(struct mr_table *mrt, struct mfcctl *mfc, int parent)
>  		return -ENOENT;
>  	rhltable_remove(&mrt->mfc_hash, &c->mnode, ipmr_rht_params);
>  	list_del_rcu(&c->list);
> +	call_ipmr_mfc_entry_notifiers(net, FIB_EVENT_ENTRY_DEL, c, mrt->id);
>  	mroute_netlink_event(mrt, c, RTM_DELROUTE);
>  	ipmr_cache_put(c);
>  
> @@ -1248,6 +1295,8 @@ static int ipmr_mfc_add(struct net *net, struct mr_table *mrt,
>  		if (!mrtsock)
>  			c->mfc_flags |= MFC_STATIC;
>  		write_unlock_bh(&mrt_lock);
> +		call_ipmr_mfc_entry_notifiers(net, FIB_EVENT_ENTRY_REPLACE, c,
> +					      mrt->id);
>  		mroute_netlink_event(mrt, c, RTM_NEWROUTE);
>  		return 0;
>  	}
> @@ -1297,6 +1346,7 @@ static int ipmr_mfc_add(struct net *net, struct mr_table *mrt,
>  		ipmr_cache_resolve(net, mrt, uc, c);
>  		ipmr_cache_free(uc);
>  	}
> +	call_ipmr_mfc_entry_notifiers(net, FIB_EVENT_ENTRY_ADD, c, mrt->id);
>  	mroute_netlink_event(mrt, c, RTM_NEWROUTE);
>  	return 0;
>  }
> @@ -1304,6 +1354,7 @@ static int ipmr_mfc_add(struct net *net, struct mr_table *mrt,
>  /* Close the multicast socket, and clear the vif tables etc */
>  static void mroute_clean_tables(struct mr_table *mrt, bool all)
>  {
> +	struct net *net = read_pnet(&mrt->net);
>  	struct mfc_cache *c, *tmp;
>  	LIST_HEAD(list);
>  	int i;
> @@ -1322,6 +1373,8 @@ static void mroute_clean_tables(struct mr_table *mrt, bool all)
>  			continue;
>  		rhltable_remove(&mrt->mfc_hash, &c->mnode, ipmr_rht_params);
>  		list_del_rcu(&c->list);
> +		call_ipmr_mfc_entry_notifiers(net, FIB_EVENT_ENTRY_DEL, c,
> +					      mrt->id);
>  		mroute_netlink_event(mrt, c, RTM_DELROUTE);
>  		ipmr_cache_put(c);
>  	}
> 
