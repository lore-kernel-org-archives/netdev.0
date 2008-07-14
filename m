From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: Re: v3 [PATCH net-next 5/7] ipv4: Check return of dev_set_allmulti
Date: Mon, 14 Jul 2008 09:14:24 +0800
Message-ID: <487AA870.30309@cn.fujitsu.com>
References: <48718014.4030009@cn.fujitsu.com> <48718172.8070404@cn.fujitsu.com> <4871FC5C.9030106@trash.net> <487334B9.4040600@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	NETDEV <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:64059 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753217AbYGNBTX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Jul 2008 21:19:23 -0400
In-Reply-To: <487334B9.4040600@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wang Chen said the following on 2008-7-8 17:34:
> Patrick McHardy said the following on 2008-7-7 19:22:
>> Wang Chen wrote:
>>>      case VIFF_TUNNEL:
>>>          dev = ipmr_new_tunnel(vifc);
>>>          if (!dev)
>>>              return -ENOBUFS;
>>> +        err = dev_set_allmulti(dev, 1);
>>> +        if (err) {
>>> +            dev_close(dev);
>>> +            return err;
>>> +        }
>> ipmr_new_tunnel creates a new tunnel device that you're not removing.
>>
> 
> OK. Remove the created tunnel.
> 
> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
> ---
> diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
> index 11700a4..a55a23a 100644
> --- a/net/ipv4/ipmr.c
> +++ b/net/ipv4/ipmr.c
> @@ -120,6 +120,31 @@ static struct timer_list ipmr_expire_timer;
>  
>  /* Service routines creating virtual interfaces: DVMRP tunnels and PIMREG */
>  
> +static void ipmr_del_tunnel(struct net_device *dev, struct vifctl *v)
> +{
> +	dev_close(dev);
> +
> +	dev = __dev_get_by_name(&init_net, "tunl0");
> +	if (dev) {
> +		struct ifreq ifr;
> +		mm_segment_t	oldfs;
> +		struct ip_tunnel_parm p;
> +
> +		memset(&p, 0, sizeof(p));
> +		p.iph.daddr = v->vifc_rmt_addr.s_addr;
> +		p.iph.saddr = v->vifc_lcl_addr.s_addr;
> +		p.iph.version = 4;
> +		p.iph.ihl = 5;
> +		p.iph.protocol = IPPROTO_IPIP;
> +		sprintf(p.name, "dvmrp%d", v->vifc_vifi);
> +		ifr.ifr_ifru.ifru_data = (__force void __user *)&p;
> +
> +		oldfs = get_fs(); set_fs(KERNEL_DS);
> +		dev->do_ioctl(dev, &ifr, SIOCDELTUNNEL);
> +		set_fs(oldfs);
> +	}
> +}
> +
>  static
>  struct net_device *ipmr_new_tunnel(struct vifctl *v)
>  {
> @@ -398,6 +423,7 @@ static int vif_add(struct vifctl *vifc, int mrtsock)
>  	struct vif_device *v = &vif_table[vifi];
>  	struct net_device *dev;
>  	struct in_device *in_dev;
> +	int err;
>  
>  	/* Is vif busy ? */
>  	if (VIF_EXISTS(vifi))
> @@ -415,18 +441,31 @@ static int vif_add(struct vifctl *vifc, int mrtsock)
>  		dev = ipmr_reg_vif();
>  		if (!dev)
>  			return -ENOBUFS;
> +		err = dev_set_allmulti(dev, 1);
> +		if (err) {
> +			unregister_netdevice(dev);
> +			return err;
> +		}
>  		break;
>  #endif
>  	case VIFF_TUNNEL:
>  		dev = ipmr_new_tunnel(vifc);
>  		if (!dev)
>  			return -ENOBUFS;
> +		err = dev_set_allmulti(dev, 1);
> +		if (err) {
> +			ipmr_del_tunnel(dev, vifc);
> +			return err;
> +		}
>  		break;
>  	case 0:
>  		dev = ip_dev_find(&init_net, vifc->vifc_lcl_addr.s_addr);
>  		if (!dev)
>  			return -EADDRNOTAVAIL;
>  		dev_put(dev);
> +		err = dev_set_allmulti(dev, 1);
> +		if (err)
> +			return err;
>  		break;
>  	default:
>  		return -EINVAL;
> @@ -435,7 +474,6 @@ static int vif_add(struct vifctl *vifc, int mrtsock)
>  	if ((in_dev = __in_dev_get_rtnl(dev)) == NULL)
>  		return -EADDRNOTAVAIL;
>  	IPV4_DEVCONF(in_dev->cnf, MC_FORWARDING)++;
> -	dev_set_allmulti(dev, +1);
>  	ip_rt_multicast_event(in_dev);
>  
>  	/*
> 
> 

Patrick, would you  please review this patch.
If you ack, I will resend whole series of patch to David again.

