From: Vitaly Kuznetsov <vkuznets@redhat.com>
Subject: Re: [PATCH net-next 0/1] netvsc: another VF datapath fix
Date: Wed, 09 Aug 2017 11:03:05 +0200
Message-ID: <87r2wlxgdy.fsf@vitty.brq.redhat.com>
References: <20170807183000.10827-1-sthemmin@microsoft.com>
        <87ziba9mwj.fsf@vitty.brq.redhat.com>
        <20170808081506.38bea86c@xeon-e3>
        <87shh29j70.fsf@vitty.brq.redhat.com>
        <20170808082927.128362aa@xeon-e3>
        <87mv7a9ict.fsf@vitty.brq.redhat.com>
        <20170808085354.4208a612@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain
Cc: devel@linuxdriverproject.org, haiyangz@microsoft.com,
        sthemmin@microsoft.com, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36864 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752333AbdHIJDI (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 9 Aug 2017 05:03:08 -0400
In-Reply-To: <20170808085354.4208a612@xeon-e3> (Stephen Hemminger's message of
        "Tue, 8 Aug 2017 08:53:54 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger <stephen@networkplumber.org> writes:

> The following would allow udev a chance at the device.
>

This would of course work but the approach is a bit hackish and can
still fail on a loaded system. Raising the pause interval would be an
option, but again, probably not the best one.

Let me try to send an RFC removing the check it dev_change_name() and if
it turns out that it can't be removed we can go back to your patch. But
in case it can we can leave without it.

Thanks,

> From 37fb240a6107834c3dd3f57caede9d73b807f414 Mon Sep 17 00:00:00 2001
> From: Stephen Hemminger <sthemmin@microsoft.com>
> Date: Tue, 8 Aug 2017 08:39:24 -0700
> Subject: [PATCH] netvsc: delay setup of VF device
>
> When VF device is discovered, delay bring it automatically up in
> order to allow userspace to some simple changes (like renaming).
>
> Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
> ---
>  drivers/net/hyperv/hyperv_net.h |  2 +-
>  drivers/net/hyperv/netvsc_drv.c | 11 ++++++-----
>  2 files changed, 7 insertions(+), 6 deletions(-)
>
> diff --git a/drivers/net/hyperv/hyperv_net.h b/drivers/net/hyperv/hyperv_net.h
> index d1ea99a12cf2..f620c90307ed 100644
> --- a/drivers/net/hyperv/hyperv_net.h
> +++ b/drivers/net/hyperv/hyperv_net.h
> @@ -723,7 +723,7 @@ struct net_device_context {
>  	/* State to manage the associated VF interface. */
>  	struct net_device __rcu *vf_netdev;
>  	struct netvsc_vf_pcpu_stats __percpu *vf_stats;
> -	struct work_struct vf_takeover;
> +	struct delayed_work vf_takeover;
>
>  	/* 1: allocated, serial number is valid. 0: not allocated */
>  	u32 vf_alloc;
> diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
> index 7ebf0e10e62b..1dff160368a3 100644
> --- a/drivers/net/hyperv/netvsc_drv.c
> +++ b/drivers/net/hyperv/netvsc_drv.c
> @@ -47,6 +47,7 @@
>
>  #define RING_SIZE_MIN 64
>  #define LINKCHANGE_INT (2 * HZ)
> +#define VF_TAKEOVER_INT (HZ / 10)
>
>  static int ring_size = 128;
>  module_param(ring_size, int, S_IRUGO);
> @@ -1570,7 +1571,7 @@ static int netvsc_vf_join(struct net_device *vf_netdev,
>  	/* set slave flag before open to prevent IPv6 addrconf */
>  	vf_netdev->flags |= IFF_SLAVE;
>
> -	schedule_work(&ndev_ctx->vf_takeover);
> +	schedule_delayed_work(&ndev_ctx->vf_takeover, VF_TAKEOVER_INT);
>
>  	netdev_info(vf_netdev, "joined to %s\n", ndev->name);
>  	return 0;
> @@ -1608,12 +1609,12 @@ static void __netvsc_vf_setup(struct net_device *ndev,
>  static void netvsc_vf_setup(struct work_struct *w)
>  {
>  	struct net_device_context *ndev_ctx
> -		= container_of(w, struct net_device_context, vf_takeover);
> +		= container_of(w, struct net_device_context, vf_takeover.work);
>  	struct net_device *ndev = hv_get_drvdata(ndev_ctx->device_ctx);
>  	struct net_device *vf_netdev;
>
>  	if (!rtnl_trylock()) {
> -		schedule_work(w);
> +		schedule_delayed_work(&ndev_ctx->vf_takeover, 0);
>  		return;
>  	}
>
> @@ -1717,7 +1718,7 @@ static int netvsc_unregister_vf(struct net_device *vf_netdev)
>  		return NOTIFY_DONE;
>
>  	net_device_ctx = netdev_priv(ndev);
> -	cancel_work_sync(&net_device_ctx->vf_takeover);
> +	cancel_delayed_work_sync(&net_device_ctx->vf_takeover);
>
>  	netdev_info(ndev, "VF unregistering: %s\n", vf_netdev->name);
>
> @@ -1759,7 +1760,7 @@ static int netvsc_probe(struct hv_device *dev,
>
>  	spin_lock_init(&net_device_ctx->lock);
>  	INIT_LIST_HEAD(&net_device_ctx->reconfig_events);
> -	INIT_WORK(&net_device_ctx->vf_takeover, netvsc_vf_setup);
> +	INIT_DELAYED_WORK(&net_device_ctx->vf_takeover, netvsc_vf_setup);
>
>  	net_device_ctx->vf_stats
>  		= netdev_alloc_pcpu_stats(struct netvsc_vf_pcpu_stats);

-- 
  Vitaly
