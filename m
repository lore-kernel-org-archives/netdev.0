From: "Jan-Bernd Themann" <ossthema@de.ibm.com>
Subject: Re: [PATCH] eHEA: Don't do memory allocation under lock if not necessary
Date: Wed, 11 Mar 2009 10:37:42 +0100
Message-ID: <200903111037.42736.ossthema@de.ibm.com>
References: <20090311084456.9190.52805.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: raisch@de.ibm.com, themann@de.ibm.com, tklein@de.ibm.com,
	linuxppc-dev@ozlabs.org, netdev@vger.kernel.org
To: David Howells <dhowells@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.uk.ibm.com ([195.212.29.136]:61146 "EHLO
	mtagate3.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753771AbZCKJi2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2009 05:38:28 -0400
Received: from d06nrmr1806.portsmouth.uk.ibm.com (d06nrmr1806.portsmouth.uk.ibm.com [9.149.39.193])
	by mtagate3.uk.ibm.com (8.14.3/8.13.8) with ESMTP id n2B9cQM4077344
	for <netdev@vger.kernel.org>; Wed, 11 Mar 2009 09:38:26 GMT
Received: from d06av04.portsmouth.uk.ibm.com (d06av04.portsmouth.uk.ibm.com [9.149.37.216])
	by d06nrmr1806.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n2B9cPaw3170344
	for <netdev@vger.kernel.org>; Wed, 11 Mar 2009 09:38:26 GMT
Received: from d06av04.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av04.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n2B9cPce003476
	for <netdev@vger.kernel.org>; Wed, 11 Mar 2009 09:38:25 GMT
In-Reply-To: <20090311084456.9190.52805.stgit@warthog.procyon.org.uk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

thanks for your patch. Coincidentally we have been working on a patch that 
does some locking rework and also touches this particular lock. 
So your patch finnally won't be required anymore. Thanks anyway for trying
to improve the eHEA driver!

I'm going to post our patch later today. 

Regards,
Jan-Bernd

On Wednesday 11 March 2009 09:44:57 David Howells wrote:
> In ehea_probe_adapter() the initial memory allocation and initialisation does
> not need to be done with the ehea_fw_handles.lock semaphore held.  Doing so
> extends the amount of time the lock is held unnecessarily.
> 
> Signed-off-by: David Howells <dhowells@redhat.com>
> ---
> 
>  drivers/net/ehea/ehea_main.c |   13 ++++++-------
>  1 files changed, 6 insertions(+), 7 deletions(-)
> 
> 
> diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c
> index dfe9226..34480ae 100644
> --- a/drivers/net/ehea/ehea_main.c
> +++ b/drivers/net/ehea/ehea_main.c
> @@ -3370,18 +3370,19 @@ static int __devinit ehea_probe_adapter(struct of_device *dev,
>  		ehea_error("Invalid ibmebus device probed");
>  		return -EINVAL;
>  	}
> -	mutex_lock(&ehea_fw_handles.lock);
> 
>  	adapter = kzalloc(sizeof(*adapter), GFP_KERNEL);
>  	if (!adapter) {
> -		ret = -ENOMEM;
>  		dev_err(&dev->dev, "no mem for ehea_adapter\n");
> -		goto out;
> +		return -ENOMEM;
>  	}
> 
> -	list_add(&adapter->list, &adapter_list);
> -
>  	adapter->ofdev = dev;
> +	adapter->pd = EHEA_PD_ID;
> +
> +	mutex_lock(&ehea_fw_handles.lock);
> +
> +	list_add(&adapter->list, &adapter_list);
> 
>  	adapter_handle = of_get_property(dev->node, "ibm,hea-handle",
>  					 NULL);
> @@ -3395,8 +3396,6 @@ static int __devinit ehea_probe_adapter(struct of_device *dev,
>  		goto out_free_ad;
>  	}
> 
> -	adapter->pd = EHEA_PD_ID;
> -
>  	dev->dev.driver_data = adapter;
> 
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 


