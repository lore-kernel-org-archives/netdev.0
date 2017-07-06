From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Patch net] tap: convert a mutex to a spinlock
Date: Thu, 06 Jul 2017 01:24:22 -0700
Message-ID: <1499329462.16045.11.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1499287800-10634-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, borntraeger@de.ibm.com,
        Sainath Grandhi <sainath.grandhi@intel.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:33369 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752042AbdGFIY0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Jul 2017 04:24:26 -0400
Received: by mail-wr0-f194.google.com with SMTP id x23so3261955wrb.0
        for <netdev@vger.kernel.org>; Thu, 06 Jul 2017 01:24:26 -0700 (PDT)
In-Reply-To: <1499287800-10634-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-07-05 at 13:50 -0700, Cong Wang wrote:
> We are not allowed to block on the RCU reader side, so can't
> just hold the mutex as before. As a quick fix, convert it to
> a spinlock.
> 
> Fixes: d9f1f61c0801 ("tap: Extending tap device create/destroy APIs")
> Reported-by: Christian Borntraeger <borntraeger@de.ibm.com>
> Cc: Sainath Grandhi <sainath.grandhi@intel.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> ---
>  drivers/net/tap.c | 18 +++++++++---------
>  1 file changed, 9 insertions(+), 9 deletions(-)
> 
> diff --git a/drivers/net/tap.c b/drivers/net/tap.c
> index 4d4173d..d88ae3c 100644
> --- a/drivers/net/tap.c
> +++ b/drivers/net/tap.c
> @@ -106,7 +106,7 @@ struct major_info {
>  	struct rcu_head rcu;
>  	dev_t major;
>  	struct idr minor_idr;
> -	struct mutex minor_lock;
> +	spinlock_t minor_lock;
>  	const char *device_name;
>  	struct list_head next;
>  };
> @@ -416,15 +416,15 @@ int tap_get_minor(dev_t major, struct tap_dev *tap)
>  		goto unlock;
>  	}
>  
> -	mutex_lock(&tap_major->minor_lock);
> -	retval = idr_alloc(&tap_major->minor_idr, tap, 1, TAP_NUM_DEVS, GFP_KERNEL);

	idr_preload(GFP_KERNEL);

> +	spin_lock(&tap_major->minor_lock);
> +	retval = idr_alloc(&tap_major->minor_idr, tap, 1, TAP_NUM_DEVS, GFP_ATOMIC);
>  	if (retval >= 0) {
>  		tap->minor = retval;
>  	} else if (retval == -ENOSPC) {
>  		netdev_err(tap->dev, "Too many tap devices\n");
>  		retval = -EINVAL;
>  	}
> -	mutex_unlock(&tap_major->minor_lock);
> +	spin_unlock(&tap_major->minor_lock);

	idr_preload_end();

>  
>  unlock:


Thanks.
