From: Yevgeny Petrilin <yevgenyp-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
Subject: RE: "mlx4_en: Enabling new steering" brokenness
Date: Fri, 29 Jul 2011 04:34:48 +0000
Message-ID: <953B660C027164448AE903364AC447D21399BC2F@MTLDAG01.mtl.com>
References: <1311887099-14339-1-git-send-email-roland@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1311887099-14339-1-git-send-email-roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Content-Language: en-US
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello Roland,

I'll check this ASAP.

Thanks,
Yevgeny

> -----Original Message-----
> From: Roland Dreier [mailto:roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org] On Behalf Of Roland
> Dreier
> Sent: Friday, July 29, 2011 12:05 AM
> To: Yevgeny Petrilin
> Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> Subject: "mlx4_en: Enabling new steering" brokenness
> 
> Hi Yevgeny!
> 
> So I have a system with an mlx4_en device with pretty old FW (version
> 2.7.700), old enough that the firmware doesn't have the capability
> MLX4_DEV_CAP_FLAG_VEP_UC_STEER set.  And it looks like mlx4_en is
> completely broken in this case, at least since your commit
> 1679200f91da ("mlx4_en: Enabling new steering").  If I try to bring up
> the interface, I just see:
> 
>     mlx4_en: eth1: Failed to allocate RSS indirection QP
> 
> And this is failing because the QPN in 0.
> 
> The problem is in drivers/net/mlx4/port.c:mlx4_register_mac():
> 
> 	if (!(dev->caps.flags & MLX4_DEV_CAP_FLAG_VEP_UC_STEER))
> 		*qpn = info->base_qpn + free;
> 
> but absolutely nothing ever initializes info->base_qpn.  It looks like
> the intention of the code is to initialize this in
> mlx4_init_port_info(); however even the below hack doesn't seem to fix
> things completely -- I still seem to have problems on the RX side
> unless I enable promiscuous mode by running tcpdump:
> 
> diff --git a/drivers/net/mlx4/main.c b/drivers/net/mlx4/main.c
> index c94b342..38092c7 100644
> --- a/drivers/net/mlx4/main.c
> +++ b/drivers/net/mlx4/main.c
> @@ -1125,6 +1125,13 @@ static int mlx4_init_port_info(struct mlx4_dev
> *dev, int port)
>  	info->port_attr.store     = set_port_type;
>  	sysfs_attr_init(&info->port_attr.attr);
> 
> +	err = mlx4_qp_reserve_range(dev, 1, 1, &info->base_qpn);
> +	if (err) {
> +		mlx4_err(dev, "Failed to reserve QP range for port %d\n",
> port);
> +		info->port = -1;
> +		return err;
> +	}
> +
>  	err = device_create_file(&dev->pdev->dev, &info->port_attr);
>  	if (err) {
>  		mlx4_err(dev, "Failed to create file for port %d\n", port);
> 
> Could you take a look at getting this working?  (Or update the driver
> so it immediately fails with an informative message if you want to
> rely on certain FW versions; and then strip out the old broken
> compatibility code)
> 
> Thanks!
>   Roland
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
