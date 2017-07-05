From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next RFC 05/12] net: dsa: Add support for learning FDB
 through notification
Date: Wed, 5 Jul 2017 12:35:46 -0700
Message-ID: <424fbf9a-f060-87d1-cad2-36e2ef732bd6@gmail.com>
References: <1499268990-19251-1-git-send-email-arkadis@mellanox.com>
 <1499268990-19251-6-git-send-email-arkadis@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jiri@resnulli.us, ivecera@redhat.com,
        andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        Woojung.Huh@microchip.com, stephen@networkplumber.org,
        mlxsw@mellanox.com
To: Arkadi Sharshevsky <arkadis@mellanox.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:34040 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751692AbdGETfx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Jul 2017 15:35:53 -0400
Received: by mail-wr0-f195.google.com with SMTP id k67so50900692wrc.1
        for <netdev@vger.kernel.org>; Wed, 05 Jul 2017 12:35:52 -0700 (PDT)
In-Reply-To: <1499268990-19251-6-git-send-email-arkadis@mellanox.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/05/2017 08:36 AM, Arkadi Sharshevsky wrote:
> Add support for learning FDB through notification. The driver defers
> the hardware update via ordered work queue. In case of a successful
> FDB add a notification is sent back to bridge.
> 
> Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
> ---
>  net/dsa/slave.c | 124 +++++++++++++++++++++++++++++++++++++++++++++++++++++++-
>  1 file changed, 122 insertions(+), 2 deletions(-)
> 
> diff --git a/net/dsa/slave.c b/net/dsa/slave.c
> index 19395cc..d0592f2 100644
> --- a/net/dsa/slave.c
> +++ b/net/dsa/slave.c
> @@ -1263,19 +1263,139 @@ static int dsa_slave_netdevice_event(struct notifier_block *nb,
>  	return NOTIFY_DONE;
>  }
>  
> +struct dsa_switchdev_event_work {
> +	struct work_struct work;
> +	struct switchdev_notifier_fdb_info fdb_info;
> +	struct net_device *dev;
> +	unsigned long event;
> +};
> +
> +static void dsa_switchdev_event_work(struct work_struct *work)
> +{
> +	struct dsa_switchdev_event_work *switchdev_work =
> +		container_of(work, struct dsa_switchdev_event_work, work);
> +	struct net_device *dev = switchdev_work->dev;
> +	struct switchdev_notifier_fdb_info *fdb_info;
> +	struct dsa_slave_priv *p = netdev_priv(dev);
> +	int err;
> +
> +	rtnl_lock();
> +	switch (switchdev_work->event) {
> +	case SWITCHDEV_FDB_ADD_TO_DEVICE:
> +		fdb_info = &switchdev_work->fdb_info;

You could probably move this assignment outside of the switch()/case
statement since it is repeated

> +		err = dsa_port_fdb_add(p->dp, fdb_info->addr, fdb_info->vid);
> +		if (err) {
> +			netdev_dbg(dev, "fdb add failed err=%d\n", err);
> +			break;
> +		}
> +		call_switchdev_notifiers(SWITCHDEV_FDB_OFFLOADED, dev,
> +					 &fdb_info->info);
> +		break;
> +
> +	case SWITCHDEV_FDB_DEL_TO_DEVICE:
> +		fdb_info = &switchdev_work->fdb_info;
> +		err = dsa_port_fdb_del(p->dp, fdb_info->addr, fdb_info->vid);
> +		if (err)
> +			netdev_dbg(dev, "fdb del failed err=%d\n", err);

OK I must have missed from the off-list discussion why we are not
calling the switchdev notifier here?

> +		break;
> +	}
> +	rtnl_unlock();
> +
> +	kfree(switchdev_work->fdb_info.addr);
> +	kfree(switchdev_work);
> +	dev_put(dev);
> +}
> +
> +static int
> +dsa_slave_switchdev_fdb_work_init(struct dsa_switchdev_event_work *
> +				  switchdev_work,
> +				  const struct switchdev_notifier_fdb_info *
> +				  fdb_info)
> +{
> +	memcpy(&switchdev_work->fdb_info, fdb_info,
> +	       sizeof(switchdev_work->fdb_info));
> +	switchdev_work->fdb_info.addr = kzalloc(ETH_ALEN, GFP_ATOMIC);
> +	if (!switchdev_work->fdb_info.addr)
> +		return -ENOMEM;

Can't we have the fdb_info structure contain pre-allocated 6 bytes
storage for address, it's really silly to do this here and every time we
need to offload an FDB entry.

> +	ether_addr_copy((u8 *)switchdev_work->fdb_info.addr,
> +			fdb_info->addr);
> +	return 0;
> +}
> +
> +/* Called under rcu_read_lock() */
> +static int dsa_slave_switchdev_event(struct notifier_block *unused,
> +				     unsigned long event, void *ptr)
> +{
> +	struct net_device *dev = switchdev_notifier_info_to_dev(ptr);
> +	struct dsa_switchdev_event_work *switchdev_work;
> +
> +	if (!dsa_slave_dev_check(dev))
> +		return NOTIFY_DONE;
> +
> +	switchdev_work = kzalloc(sizeof(*switchdev_work), GFP_ATOMIC);
> +	if (!switchdev_work)
> +		return NOTIFY_BAD;

Same here, can we try to re-use a heap allocated workqueue item and we
just re-initialize it when we have to?

> +
> +	INIT_WORK(&switchdev_work->work, dsa_switchdev_event_work);
> +	switchdev_work->dev = dev;
> +	switchdev_work->event = event;
> +
> +	switch (event) {
> +	case SWITCHDEV_FDB_ADD_TO_DEVICE: /* fall through */
> +	case SWITCHDEV_FDB_DEL_TO_DEVICE:
> +		if (dsa_slave_switchdev_fdb_work_init(switchdev_work,
> +						      ptr))
> +			goto err_fdb_work_init;
> +		dev_hold(dev);
> +		break;
> +	default:
> +		kfree(switchdev_work);
> +		return NOTIFY_DONE;
> +	}
> +
> +	dsa_schedule_work(&switchdev_work->work);
> +	return NOTIFY_OK;
> +
> +err_fdb_work_init:
> +	kfree(switchdev_work);
> +	return NOTIFY_BAD;
> +}
> +
>  static struct notifier_block dsa_slave_nb __read_mostly = {
> -	.notifier_call	= dsa_slave_netdevice_event,
> +	.notifier_call  = dsa_slave_netdevice_event,
> +};
> +
> +static struct notifier_block dsa_slave_switchdev_notifier = {
> +	.notifier_call = dsa_slave_switchdev_event,
>  };
>  
>  int dsa_slave_register_notifier(void)
>  {
> -	return register_netdevice_notifier(&dsa_slave_nb);
> +	int err;
> +
> +	err = register_netdevice_notifier(&dsa_slave_nb);
> +	if (err)
> +		return err;
> +
> +	err = register_switchdev_notifier(&dsa_slave_switchdev_notifier);
> +	if (err)
> +		goto err_register_switchdev;

this label is a bit misnamed since it really deals with the slave dsa
notifier, how about no label or just renaming it "error_slave_nb"?

> +
> +	return 0;
> +
> +err_register_switchdev:
> +	unregister_netdevice_notifier(&dsa_slave_nb);
> +	return err;
>  }
>  
>  void dsa_slave_unregister_notifier(void)
>  {
>  	int err;
>  
> +	err = unregister_netdevice_notifier(&dsa_slave_switchdev_notifier);
> +	if (err)
> +		pr_err("DSA: failed to unregister switchdev notifier (%d)\n", err);
> +
>  	err = unregister_netdevice_notifier(&dsa_slave_nb);
>  	if (err)
>  		pr_err("DSA: failed to unregister slave notifier (%d)\n", err);
> 


-- 
Florian
