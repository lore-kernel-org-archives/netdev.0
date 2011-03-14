From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] Fix overflow of name in struct net_device, replaced
 str* and sprintf with strn* and snprintf respectivly.
Date: Mon, 14 Mar 2011 20:29:36 +0000
Message-ID: <1300134576.2584.66.camel@bwh-desktop>
References: <1300133248-2927-1-git-send-email-sasikanth.v19@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Sasikanth V <sasikanth.v19@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:1608 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751245Ab1CNU3k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2011 16:29:40 -0400
In-Reply-To: <1300133248-2927-1-git-send-email-sasikanth.v19@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-03-15 at 01:37 +0530, Sasikanth V wrote:
> Signed-off-by: Sasikanth V <sasikanth.v19@gmail.com>
> ---
>  net/core/dev.c |   14 +++++++-------
>  1 files changed, 7 insertions(+), 7 deletions(-)
> 
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 6561021..9d06c1e 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -510,7 +510,7 @@ int netdev_boot_setup_check(struct net_device *dev)
>  
>  	for (i = 0; i < NETDEV_BOOT_SETUP_MAX; i++) {
>  		if (s[i].name[0] != '\0' && s[i].name[0] != ' ' &&
> -		    !strcmp(dev->name, s[i].name)) {
> +		    !strncmp(dev->name, s[i].name, IFNAMSIZ)) {

If s[i].name is too long, so what?  No change is required here.

>  			dev->irq 	= s[i].map.irq;
>  			dev->base_addr 	= s[i].map.base_addr;
>  			dev->mem_start 	= s[i].map.mem_start;
> @@ -539,7 +539,7 @@ unsigned long netdev_boot_base(const char *prefix, int unit)
>  	char name[IFNAMSIZ];
>  	int i;
>  
> -	sprintf(name, "%s%d", prefix, unit);
> +	snprintf(name, IFNAMSIZ, "%s%d", prefix, unit);

This looks reasonable.

>  	/*
>  	 * If device already registered then return base of 1
> @@ -549,7 +549,7 @@ unsigned long netdev_boot_base(const char *prefix, int unit)
>  		return 1;
>  
>  	for (i = 0; i < NETDEV_BOOT_SETUP_MAX; i++)
> -		if (!strcmp(name, s[i].name))
> +		if (!strncmp(name, s[i].name, IFNAMSIZ))

Not required.

>  			return s[i].map.base_addr;
>  	return 0;
>  }
> @@ -836,7 +836,7 @@ EXPORT_SYMBOL(dev_get_by_flags_rcu);
>   */
>  int dev_valid_name(const char *name)
>  {
> -	if (*name == '\0')
> +	if (!name || *name == '\0')

Not required; passing NULL is a bug.

>  		return 0;
>  	if (strlen(name) >= IFNAMSIZ)
>  		return 0;
> @@ -3834,7 +3834,7 @@ static int dev_ifname(struct net *net, struct ifreq __user *arg)
>  		return -ENODEV;
>  	}
>  
> -	strcpy(ifr.ifr_name, dev->name);
> +	strncpy(ifr.ifr_name, dev->name, IFNAMSIZ);

If dev->name is longer than IFNAMSIZ (including null terminator) than we
already failed.  This change is not required.

>  	rcu_read_unlock();
>  
>  	if (copy_to_user(arg, &ifr, sizeof(struct ifreq)))
> @@ -4821,7 +4821,7 @@ int dev_ioctl(struct net *net, unsigned int cmd, void __user *arg)
>  	if (copy_from_user(&ifr, arg, sizeof(struct ifreq)))
>  		return -EFAULT;
>  
> -	ifr.ifr_name[IFNAMSIZ-1] = 0;
> +	ifr.ifr_name[IFNAMSIZ-1] = '\0';

This is just noise.
 
>  	colon = strchr(ifr.ifr_name, ':');
>  	if (colon)
> @@ -5694,7 +5694,7 @@ struct net_device *alloc_netdev_mqs(int sizeof_priv, const char *name,
>  		goto free_all;
>  #endif
>  
> -	strcpy(dev->name, name);
> +	strncpy(dev->name, name, IFNAMSIZ);

This doesn't help, as strncpy() does not ensure null termination.  And I
don't think truncating the name is helpful either.  Perhaps we should do
this right at the beginning of the function:

	if (WARN_ON(strlen(name) >= IFNAMSIZ))
		return NULL;

Ben.

>  	return dev;
>  
>  free_all:

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

