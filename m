From: Vitaly Kuznetsov <vkuznets@redhat.com>
Subject: Re: [PATCH net-next 1/1] netvsc: fix rtnl deadlock on unregister of vf
Date: Mon, 07 Aug 2017 15:08:08 +0200
Message-ID: <874ltjedaf.fsf@vitty.brq.redhat.com>
References: <20170804191400.22471-1-sthemmin@microsoft.com>
 <20170804191400.22471-2-sthemmin@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@linuxdriverproject.org, haiyangz@microsoft.com,
 sthemmin@microsoft.com, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20170804191400.22471-2-sthemmin@microsoft.com> (Stephen
 Hemminger's message of "Fri, 4 Aug 2017 12:14:00 -0700")
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

Stephen Hemminger <stephen@networkplumber.org> writes:

> With new transparent VF support, it is possible to get a deadlock
> when some of the deferred work is running and the unregister_vf
> is trying to cancel the work element. The solution is to use
> trylock and reschedule (similar to bonding and team device).
>
> Reported-by: Vitaly Kuznetsov <vkuznets@redhat.com>
> Fixes: 0c195567a8f6 ("netvsc: transparent VF management")
> Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
> ---
>  drivers/net/hyperv/netvsc_drv.c | 12 ++++++++++--
>  1 file changed, 10 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
> index c71728d82049..e75c0f852a63 100644
> --- a/drivers/net/hyperv/netvsc_drv.c
> +++ b/drivers/net/hyperv/netvsc_drv.c
> @@ -1601,7 +1601,11 @@ static void netvsc_vf_setup(struct work_struct *w)
>  	struct net_device *ndev = hv_get_drvdata(ndev_ctx->device_ctx);
>  	struct net_device *vf_netdev;
>
> -	rtnl_lock();
> +	if (!rtnl_trylock()) {
> +		schedule_work(w);
> +		return;
> +	}
> +
>  	vf_netdev = rtnl_dereference(ndev_ctx->vf_netdev);
>  	if (vf_netdev)
>  		__netvsc_vf_setup(ndev, vf_netdev);
> @@ -1655,7 +1659,11 @@ static void netvsc_vf_update(struct work_struct *w)
>  	struct net_device *vf_netdev;
>  	bool vf_is_up;
>
> -	rtnl_lock();
> +	if (!rtnl_trylock()) {
> +		schedule_work(w);
> +		return;
> +	}
> +

So in the situation when we're currently in netvsc_unregister_vf() and
trying to do
        cancel_work_sync(&net_device_ctx->vf_takeover);
	cancel_work_sync(&net_device_ctx->vf_notify);

we'll end up not executing netvsc_vf_update() at all, right? Wouldn't it
create an issue as nobody is switching the datapath back to netvsc?

>  	vf_netdev = rtnl_dereference(ndev_ctx->vf_netdev);
>  	if (!vf_netdev)
>  		goto unlock;

-- 
  Vitaly
