From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [RFC PATCH 5/6] ppp: define reusable device creation functions
Date: Tue, 5 Apr 2016 08:28:32 -0700
Message-ID: <20160405082832.534257df@xeon-e3>
References: <cover.1459807527.git.g.nault@alphalink.fr>
	<522658eb90148cb670fb4f5db1429c41788aa4d8.1459807527.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-ppp@vger.kernel.org,
	Paul Mackerras <paulus@samba.org>,
	David Miller <davem@davemloft.net>
To: Guillaume Nault <g.nault@alphalink.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:35874 "EHLO
	mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752613AbcDEP2S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2016 11:28:18 -0400
Received: by mail-pf0-f174.google.com with SMTP id e128so12811232pfe.3
        for <netdev@vger.kernel.org>; Tue, 05 Apr 2016 08:28:18 -0700 (PDT)
In-Reply-To: <522658eb90148cb670fb4f5db1429c41788aa4d8.1459807527.git.g.nault@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 5 Apr 2016 02:56:29 +0200
Guillaume Nault <g.nault@alphalink.fr> wrote:

> Move PPP device initialisation and registration out of
> ppp_create_interface().
> This prepares code for device registration with rtnetlink.
> 
> Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>
> ---
>  drivers/net/ppp/ppp_generic.c | 185 ++++++++++++++++++++++++------------------
>  1 file changed, 106 insertions(+), 79 deletions(-)
> 
> diff --git a/drivers/net/ppp/ppp_generic.c b/drivers/net/ppp/ppp_generic.c
> index 8aaedb8..516f8dc 100644
> --- a/drivers/net/ppp/ppp_generic.c
> +++ b/drivers/net/ppp/ppp_generic.c
> @@ -183,6 +183,11 @@ struct channel {
>  #endif /* CONFIG_PPP_MULTILINK */
>  };
>  
> +struct ppp_config {
> +	struct file *file;
> +	s32 unit;
> +};
> +
>  /*
>   * SMP locking issues:
>   * Both the ppp.rlock and ppp.wlock locks protect the ppp.channels
> @@ -984,6 +989,87 @@ static struct pernet_operations ppp_net_ops = {
>  	.size = sizeof(struct ppp_net),
>  };
>  
> +static int ppp_unit_register(struct ppp *ppp, int unit)
> +{
> +	struct ppp_net *pn = ppp_pernet(ppp->ppp_net);
> +	int ret;
> +
> +	mutex_lock(&pn->all_ppp_mutex);
> +
> +	if (unit < 0) {
> +		ret = unit_get(&pn->units_idr, ppp);
> +		if (ret < 0)
> +			goto err;
> +	} else {
> +		/* Caller asked for a specific unit number. Fail with -EEXIST
> +		 * if unavailable. For backward compatibility, return -EEXIST
> +		 * too if idr allocation fails; this makes pppd retry without
> +		 * requesting a specific unit number.
> +		 */
> +		if (unit_find(&pn->units_idr, unit)) {
> +			ret = -EEXIST;
> +			goto err;
> +		}
> +		ret = unit_set(&pn->units_idr, ppp, unit);
> +		if (ret < 0) {
> +			/* Rewrite error for backward compatibility */
> +			ret = -EEXIST;
> +			goto err;
> +		}
> +	}
> +	ppp->file.index = ret;
> +
> +	snprintf(ppp->dev->name, IFNAMSIZ, "ppp%i", ppp->file.index);
> +
> +	ret = register_netdevice(ppp->dev);
> +	if (ret < 0)
> +		goto err_unit;
> +
> +	atomic_inc(&ppp_unit_count);
> +
> +	mutex_unlock(&pn->all_ppp_mutex);
> +
> +	return 0;
> +
> +err_unit:
> +	unit_put(&pn->units_idr, ppp->file.index);
> +err:
> +	mutex_unlock(&pn->all_ppp_mutex);
> +
> +	return ret;
> +}
> +
> +static int ppp_dev_configure(struct net *src_net, struct net_device *dev,
> +			     const struct ppp_config *conf)
> +{
> +	struct ppp *ppp = netdev_priv(dev);
> +	int indx;
> +
> +	ppp->dev = dev;
> +	ppp->mru = PPP_MRU;
> +	ppp->ppp_net = src_net;
> +	ppp->owner = conf->file;
> +
> +	init_ppp_file(&ppp->file, INTERFACE);
> +	ppp->file.hdrlen = PPP_HDRLEN - 2; /* don't count proto bytes */
> +
> +	for (indx = 0; indx < NUM_NP; ++indx)
> +		ppp->npmode[indx] = NPMODE_PASS;
> +	INIT_LIST_HEAD(&ppp->channels);
> +	spin_lock_init(&ppp->rlock);
> +	spin_lock_init(&ppp->wlock);
> +#ifdef CONFIG_PPP_MULTILINK
> +	ppp->minseq = -1;
> +	skb_queue_head_init(&ppp->mrq);
> +#endif /* CONFIG_PPP_MULTILINK */
> +#ifdef CONFIG_PPP_FILTER
> +	ppp->pass_filter = NULL;
> +	ppp->active_filter = NULL;
> +#endif /* CONFIG_PPP_FILTER */
> +
> +	return ppp_unit_register(ppp, conf->unit);
> +}
> +
>  #define PPP_MAJOR	108
>  
>  /* Called at boot time if ppp is compiled into the kernel,
> @@ -2758,107 +2844,48 @@ ppp_get_stats(struct ppp *ppp, struct ppp_stats *st)
>   */
>  static int ppp_create_interface(struct net *net, struct file *file, int *unit)
>  {
> +	struct ppp_config conf = {
> +		.file = file,
> +		.unit = *unit,
> +	};
> +	struct net_device *dev;
>  	struct ppp *ppp;
> -	struct ppp_net *pn;
> -	struct net_device *dev = NULL;
> -	int ret = -ENOMEM;
> -	int i;
> +	int err;
>  
>  	dev = alloc_netdev(sizeof(struct ppp), "", NET_NAME_ENUM, ppp_setup);
> -	if (!dev)
> -		goto out1;
> -
> -	pn = ppp_pernet(net);
> -
> -	ppp = netdev_priv(dev);
> -	ppp->dev = dev;
> -	ppp->mru = PPP_MRU;
> -	init_ppp_file(&ppp->file, INTERFACE);
> -	ppp->file.hdrlen = PPP_HDRLEN - 2;	/* don't count proto bytes */
> -	ppp->owner = file;
> -	for (i = 0; i < NUM_NP; ++i)
> -		ppp->npmode[i] = NPMODE_PASS;
> -	INIT_LIST_HEAD(&ppp->channels);
> -	spin_lock_init(&ppp->rlock);
> -	spin_lock_init(&ppp->wlock);
> -#ifdef CONFIG_PPP_MULTILINK
> -	ppp->minseq = -1;
> -	skb_queue_head_init(&ppp->mrq);
> -#endif /* CONFIG_PPP_MULTILINK */
> -#ifdef CONFIG_PPP_FILTER
> -	ppp->pass_filter = NULL;
> -	ppp->active_filter = NULL;
> -#endif /* CONFIG_PPP_FILTER */
> +	if (!dev) {
> +		err = -ENOMEM;
> +		goto err;
> +	}
>  
> -	/*
> -	 * drum roll: don't forget to set
> -	 * the net device is belong to
> -	 */
>  	dev_net_set(dev, net);
>  
>  	rtnl_lock();
>  	mutex_lock(&ppp_mutex);
> -	mutex_lock(&pn->all_ppp_mutex);
> -
>  	if (file->private_data) {
> -		ret = -ENOTTY;
> -		goto out2;
> -	}
> -
> -	if (*unit < 0) {
> -		ret = unit_get(&pn->units_idr, ppp);
> -		if (ret < 0)
> -			goto out2;
> -	} else {
> -		ret = -EEXIST;
> -		if (unit_find(&pn->units_idr, *unit))
> -			goto out2; /* unit already exists */
> -		/*
> -		 * if caller need a specified unit number
> -		 * lets try to satisfy him, otherwise --
> -		 * he should better ask us for new unit number
> -		 *
> -		 * NOTE: yes I know that returning EEXIST it's not
> -		 * fair but at least pppd will ask us to allocate
> -		 * new unit in this case so user is happy :)
> -		 */
> -		ret = unit_set(&pn->units_idr, ppp, *unit);
> -		if (ret < 0) {
> -			ret = -EEXIST;
> -			goto out2;
> -		}
> +		err = -ENOTTY;
> +		goto err_dev;
>  	}
>  
> -	/* Initialize the new ppp unit */
> -	ppp->file.index = ret;
> -	sprintf(dev->name, "ppp%d", ret);
> +	err = ppp_dev_configure(net, dev, &conf);
> +	if (err < 0)
> +		goto err_dev;
>  
> -	ret = register_netdevice(dev);
> -	if (ret != 0) {
> -		unit_put(&pn->units_idr, ppp->file.index);
> -		netdev_err(ppp->dev, "PPP: couldn't register device %s (%d)\n",
> -			   dev->name, ret);
> -		goto out2;
> -	}
> -
> -	ppp->ppp_net = net;
> -	file->private_data = &ppp->file;
> +	ppp = netdev_priv(dev);
>  	*unit = ppp->file.index;
> -	atomic_inc(&ppp_unit_count);
> +	file->private_data = &ppp->file;
>  
> -	mutex_unlock(&pn->all_ppp_mutex);
>  	mutex_unlock(&ppp_mutex);
>  	rtnl_unlock();
>  
>  	return 0;
>  
> -out2:
> -	mutex_unlock(&pn->all_ppp_mutex);
> +err_dev:
>  	mutex_unlock(&ppp_mutex);
>  	rtnl_unlock();
>  	free_netdev(dev);
> -out1:
> -	return ret;
> +err:
> +	return err;
>  }
>  
>  /*

Does PPP module autoload correctly based on the netlink attributes?
