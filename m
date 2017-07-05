From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next RFC 04/12] net: dsa: Add ordered workqueue
Date: Wed, 5 Jul 2017 12:37:06 -0700
Message-ID: <6db9cee1-8f2c-e086-55e6-d70b69c3824e@gmail.com>
References: <1499268990-19251-1-git-send-email-arkadis@mellanox.com>
 <1499268990-19251-5-git-send-email-arkadis@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jiri@resnulli.us, ivecera@redhat.com,
        andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        Woojung.Huh@microchip.com, stephen@networkplumber.org,
        mlxsw@mellanox.com
To: Arkadi Sharshevsky <arkadis@mellanox.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:33052 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752156AbdGEThP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Jul 2017 15:37:15 -0400
Received: by mail-wr0-f195.google.com with SMTP id x23so51106873wrb.0
        for <netdev@vger.kernel.org>; Wed, 05 Jul 2017 12:37:14 -0700 (PDT)
In-Reply-To: <1499268990-19251-5-git-send-email-arkadis@mellanox.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/05/2017 08:36 AM, Arkadi Sharshevsky wrote:
> This workqueue will be used for FDB add/del processing. It should
> be destroyed after all devices unregistered successfully.
> 
> Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
> ---
>  include/net/dsa.h |  1 +
>  net/dsa/dsa.c     | 13 +++++++++++++
>  2 files changed, 14 insertions(+)
> 
> diff --git a/include/net/dsa.h b/include/net/dsa.h
> index f054d41..4835b0e 100644
> --- a/include/net/dsa.h
> +++ b/include/net/dsa.h
> @@ -451,6 +451,7 @@ void unregister_switch_driver(struct dsa_switch_driver *type);
>  struct mii_bus *dsa_host_dev_to_mii_bus(struct device *dev);
>  
>  struct net_device *dsa_dev_to_net_device(struct device *dev);
> +bool dsa_schedule_work(struct work_struct *work);

I'd move this to dsa_priv.h in net/dsa/ because it is not supposed to be
used by DSA drivers.

You may also consider squashing this into the next patch since in itself
it's not used just yet.

>  
>  /* Keep inline for faster access in hot path */
>  static inline bool netdev_uses_dsa(struct net_device *dev)
> diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
> index 416ac4e..9abe6dc 100644
> --- a/net/dsa/dsa.c
> +++ b/net/dsa/dsa.c
> @@ -271,10 +271,22 @@ static struct packet_type dsa_pack_type __read_mostly = {
>  	.func	= dsa_switch_rcv,
>  };
>  
> +static struct workqueue_struct *dsa_owq;
> +
> +bool dsa_schedule_work(struct work_struct *work)
> +{
> +	return queue_work(dsa_owq, work);
> +}
> +
>  static int __init dsa_init_module(void)
>  {
>  	int rc;
>  
> +	dsa_owq = alloc_ordered_workqueue("dsa_ordered",
> +					  WQ_MEM_RECLAIM);
> +	if (!dsa_owq)
> +		return -ENOMEM;
> +
>  	rc = dsa_slave_register_notifier();
>  	if (rc)
>  		return rc;
> @@ -294,6 +306,7 @@ static void __exit dsa_cleanup_module(void)
>  	dsa_slave_unregister_notifier();
>  	dev_remove_pack(&dsa_pack_type);
>  	dsa_legacy_unregister();
> +	destroy_workqueue(dsa_owq);
>  }
>  module_exit(dsa_cleanup_module);
>  
> 


-- 
Florian
