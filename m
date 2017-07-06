From: Christian Borntraeger <borntraeger@de.ibm.com>
Subject: Re: [Patch net] tap: convert a mutex to a spinlock
Date: Thu, 6 Jul 2017 09:14:01 +0200
Message-ID: <a9c5e37d-e160-cbcd-b4c9-8e2126b25c8c@de.ibm.com>
References: <1499287800-10634-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Sainath Grandhi <sainath.grandhi@intel.com>
To: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:60997 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1753093AbdGFHOJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Jul 2017 03:14:09 -0400
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v667DdsQ094005
        for <netdev@vger.kernel.org>; Thu, 6 Jul 2017 03:14:08 -0400
Received: from e37.co.us.ibm.com (e37.co.us.ibm.com [32.97.110.158])
        by mx0b-001b2d01.pphosted.com with ESMTP id 2bgvqkqrqr-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 06 Jul 2017 03:14:08 -0400
Received: from localhost
        by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <borntraeger@de.ibm.com>;
        Thu, 6 Jul 2017 01:14:07 -0600
In-Reply-To: <1499287800-10634-1-git-send-email-xiyou.wangcong@gmail.com>
Content-Language: en-IE
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/05/2017 10:50 PM, Cong Wang wrote:
> We are not allowed to block on the RCU reader side, so can't
> just hold the mutex as before. As a quick fix, convert it to
> a spinlock.
> 
> Fixes: d9f1f61c0801 ("tap: Extending tap device create/destroy APIs")
> Reported-by: Christian Borntraeger <borntraeger@de.ibm.com>
> Cc: Sainath Grandhi <sainath.grandhi@intel.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Tested-by: Christian Borntraeger <borntraeger@de.ibm.com>


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
> 
>  unlock:
>  	rcu_read_unlock();
> @@ -442,12 +442,12 @@ void tap_free_minor(dev_t major, struct tap_dev *tap)
>  		goto unlock;
>  	}
> 
> -	mutex_lock(&tap_major->minor_lock);
> +	spin_lock(&tap_major->minor_lock);
>  	if (tap->minor) {
>  		idr_remove(&tap_major->minor_idr, tap->minor);
>  		tap->minor = 0;
>  	}
> -	mutex_unlock(&tap_major->minor_lock);
> +	spin_unlock(&tap_major->minor_lock);
> 
>  unlock:
>  	rcu_read_unlock();
> @@ -467,13 +467,13 @@ static struct tap_dev *dev_get_by_tap_file(int major, int minor)
>  		goto unlock;
>  	}
> 
> -	mutex_lock(&tap_major->minor_lock);
> +	spin_lock(&tap_major->minor_lock);
>  	tap = idr_find(&tap_major->minor_idr, minor);
>  	if (tap) {
>  		dev = tap->dev;
>  		dev_hold(dev);
>  	}
> -	mutex_unlock(&tap_major->minor_lock);
> +	spin_unlock(&tap_major->minor_lock);
> 
>  unlock:
>  	rcu_read_unlock();
> @@ -1227,7 +1227,7 @@ static int tap_list_add(dev_t major, const char *device_name)
>  	tap_major->major = MAJOR(major);
> 
>  	idr_init(&tap_major->minor_idr);
> -	mutex_init(&tap_major->minor_lock);
> +	spin_lock_init(&tap_major->minor_lock);
> 
>  	tap_major->device_name = device_name;
> 
