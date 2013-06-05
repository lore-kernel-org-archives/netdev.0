From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [PATCH] net/ti davinci_mdio: don't hold a spin lock while calling
 pm_runtime
Date: Wed, 5 Jun 2013 22:31:18 +0530
Message-ID: <51AF6EDE.8020905@ti.com>
References: <1370451240-30153-1-git-send-email-bigeasy@linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([192.94.94.41]:55707 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755881Ab3FERDL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Jun 2013 13:03:11 -0400
In-Reply-To: <1370451240-30153-1-git-send-email-bigeasy@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/5/2013 10:24 PM, Sebastian Andrzej Siewior wrote:
> was playing with suspend and run into this:
>
> |BUG: sleeping function called from invalid context at drivers/base/power/runtime.c:891
> |in_atomic(): 1, irqs_disabled(): 0, pid: 1963, name: bash
> |6 locks held by bash/1963:
> |CPU: 0 PID: 1963 Comm: bash Not tainted 3.10.0-rc4+ #50
> |[<c0014fdc>] (unwind_backtrace+0x0/0xf8) from [<c0011da4>] (show_stack+0x10/0x14)
> |[<c0011da4>] (show_stack+0x10/0x14) from [<c02e8680>] (__pm_runtime_idle+0xa4/0xac)
> |[<c02e8680>] (__pm_runtime_idle+0xa4/0xac) from [<c0341158>] (davinci_mdio_suspend+0x6c/0x9c)
> |[<c0341158>] (davinci_mdio_suspend+0x6c/0x9c) from [<c02e0628>] (platform_pm_suspend+0x2c/0x54)
> |[<c02e0628>] (platform_pm_suspend+0x2c/0x54) from [<c02e52bc>] (dpm_run_callback.isra.3+0x2c/0x64)
> |[<c02e52bc>] (dpm_run_callback.isra.3+0x2c/0x64) from [<c02e57e4>] (__device_suspend+0x100/0x22c)
> |[<c02e57e4>] (__device_suspend+0x100/0x22c) from [<c02e67e8>] (dpm_suspend+0x68/0x230)
> |[<c02e67e8>] (dpm_suspend+0x68/0x230) from [<c0072a20>] (suspend_devices_and_enter+0x68/0x350)
> |[<c0072a20>] (suspend_devices_and_enter+0x68/0x350) from [<c0072f18>] (pm_suspend+0x210/0x24c)
> |[<c0072f18>] (pm_suspend+0x210/0x24c) from [<c0071c74>] (state_store+0x6c/0xbc)
> |[<c0071c74>] (state_store+0x6c/0xbc) from [<c02714dc>] (kobj_attr_store+0x14/0x20)
> |[<c02714dc>] (kobj_attr_store+0x14/0x20) from [<c01341a0>] (sysfs_write_file+0x16c/0x19c)
> |[<c01341a0>] (sysfs_write_file+0x16c/0x19c) from [<c00ddfe4>] (vfs_write+0xb4/0x190)
> |[<c00ddfe4>] (vfs_write+0xb4/0x190) from [<c00de3a4>] (SyS_write+0x3c/0x70)
> |[<c00de3a4>] (SyS_write+0x3c/0x70) from [<c000e2c0>] (ret_fast_syscall+0x0/0x48)
>
> I don't see a reason why the pm_runtime call must be under the lock.
> Further I don't understand why this is a spinlock and not mutex.
>
> Cc: Mugunthan V N <mugunthanvnm@ti.com>
> Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
> ---
>   drivers/net/ethernet/ti/davinci_mdio.c |    5 ++---
>   1 file changed, 2 insertions(+), 3 deletions(-)
>
> diff --git a/drivers/net/ethernet/ti/davinci_mdio.c b/drivers/net/ethernet/ti/davinci_mdio.c
> index 12aec17..b2275d1 100644
> --- a/drivers/net/ethernet/ti/davinci_mdio.c
> +++ b/drivers/net/ethernet/ti/davinci_mdio.c
> @@ -449,10 +449,9 @@ static int davinci_mdio_suspend(struct device *dev)
>   	__raw_writel(ctrl, &data->regs->control);
>   	wait_for_idle(data);
>   
> -	pm_runtime_put_sync(data->dev);
> -
>   	data->suspended = true;
>   	spin_unlock(&data->lock);
> +	pm_runtime_put_sync(data->dev);
>   
>   	return 0;
>   }
> @@ -462,9 +461,9 @@ static int davinci_mdio_resume(struct device *dev)
>   	struct davinci_mdio_data *data = dev_get_drvdata(dev);
>   	u32 ctrl;
>   
> -	spin_lock(&data->lock);
>   	pm_runtime_get_sync(data->dev);
>   
> +	spin_lock(&data->lock);
>   	/* restart the scan state machine */
>   	ctrl = __raw_readl(&data->regs->control);
>   	ctrl |= CONTROL_ENABLE;
Acked-by: Mugunthan V N <mugunthanvnm@ti.com>

Regards
Mugunthan V N
