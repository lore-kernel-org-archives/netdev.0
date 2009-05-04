From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: tun: add tun_flags, owner, group attributes in sysfs
Date: Mon, 4 May 2009 07:47:53 -0700
Message-ID: <20090504074753.6d1c5bcd@nehalam>
References: <1241433136.6126.70.camel@macbook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Mark McLoughlin <markmc@redhat.com>
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:53896 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751837AbZEDOr7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 May 2009 10:47:59 -0400
In-Reply-To: <1241433136.6126.70.camel@macbook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 04 May 2009 11:32:16 +0100
David Woodhouse <dwmw2@infradead.org> wrote:

> This patch adds three attribute files in /sys/class/net/$dev/ for tun
> devices; allowing userspace to obtain the information which TUNGETIFF
> offers, and more, but without having to attach to the device in question
> (which may not be possible if it's in use).
> 
> It also fixes a bug which has been present in the TUNGETIFF ioctl since
> its inception, where it would never set IFF_TUN or IFF_TAP according to
> the device type. (Look carefully at the code which I remove from
> tun_get_iff() and how the new tun_flags() helper is subtly different).
> 
> Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>
> ---
> I don't have to explicitly remove the files, do I? They go away
> naturally when the device is unregistered?
> 
> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> index 94622e5..4cda69b 100644
> --- a/drivers/net/tun.c
> +++ b/drivers/net/tun.c
> @@ -865,6 +865,52 @@ static struct proto tun_proto = {
>  	.obj_size	= sizeof(struct tun_sock),
>  };
>  
> +static int tun_flags(struct tun_struct *tun)
> +{
> +	int flags = 0;
> +
> +	if (tun->flags & TUN_TUN_DEV)
> +		flags |= IFF_TUN;
> +	else
> +		flags |= IFF_TAP;
> +
> +	if (tun->flags & TUN_NO_PI)
> +		flags |= IFF_NO_PI;
> +
> +	if (tun->flags & TUN_ONE_QUEUE)
> +		flags |= IFF_ONE_QUEUE;
> +
> +	if (tun->flags & TUN_VNET_HDR)
> +		flags |= IFF_VNET_HDR;
> +
> +	return flags;
> +}
> +
> +static ssize_t tun_show_flags(struct device *dev, struct device_attribute *attr,
> +			      char *buf)
> +{
> +	struct tun_struct *tun = netdev_priv(to_net_dev(dev));
> +	return sprintf(buf, "0x%x\n", tun_flags(tun));
> +}
> +
> +static ssize_t tun_show_owner(struct device *dev, struct device_attribute *attr,
> +			      char *buf)
> +{
> +	struct tun_struct *tun = netdev_priv(to_net_dev(dev));
> +	return sprintf(buf, "%d\n", tun->owner);
> +}
> +
> +static ssize_t tun_show_group(struct device *dev, struct device_attribute *attr,
> +			      char *buf)
> +{
> +	struct tun_struct *tun = netdev_priv(to_net_dev(dev));
> +	return sprintf(buf, "%d\n", tun->group);
> +}
> +
> +static DEVICE_ATTR(tun_flags, 0444, tun_show_flags, NULL);
> +static DEVICE_ATTR(owner, 0444, tun_show_owner, NULL);
> +static DEVICE_ATTR(group, 0444, tun_show_group, NULL);
> +
>  static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
>  {
>  	struct sock *sk;
> @@ -950,6 +996,11 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
>  		if (err < 0)
>  			goto err_free_sk;
>  
> +		if (device_create_file(&tun->dev->dev, &dev_attr_tun_flags) ||
> +		    device_create_file(&tun->dev->dev, &dev_attr_owner) ||
> +		    device_create_file(&tun->dev->dev, &dev_attr_group))
> +			printk(KERN_ERR "Failed to create tun sysfs files\n");
> +
>  		sk->sk_destruct = tun_sock_destruct;
>  
>  		err = tun_attach(tun, file);
> @@ -1002,21 +1053,7 @@ static int tun_get_iff(struct net *net, struct file *file, struct ifreq *ifr)
>  
>  	strcpy(ifr->ifr_name, tun->dev->name);
>  
> -	ifr->ifr_flags = 0;
> -
> -	if (ifr->ifr_flags & TUN_TUN_DEV)
> -		ifr->ifr_flags |= IFF_TUN;
> -	else
> -		ifr->ifr_flags |= IFF_TAP;
> -
> -	if (tun->flags & TUN_NO_PI)
> -		ifr->ifr_flags |= IFF_NO_PI;
> -
> -	if (tun->flags & TUN_ONE_QUEUE)
> -		ifr->ifr_flags |= IFF_ONE_QUEUE;
> -
> -	if (tun->flags & TUN_VNET_HDR)
> -		ifr->ifr_flags |= IFF_VNET_HDR;
> +	ifr->ifr_flags = tun_flags(tun);
>  
>  	tun_put(tun);
>  	return 0;

Netlink please not sysfs. also, any sysfs attributes have to handle unregistration
issues.
      ( sleep 900; read owner ) </sys/class/net/tun0/owner &
      rmmod tun
