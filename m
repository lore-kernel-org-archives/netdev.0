From: Jeremy Linton <jeremy.linton@arm.com>
Subject: Re: [PATCH] net: smsc911x: Synchronize the runtime PM status during
 system suspend
Date: Fri, 28 Oct 2016 10:33:12 -0500
Message-ID: <6a87415f-0ff8-a352-cff5-65806509a981@arm.com>
References: <1477567434-5128-1-git-send-email-ulf.hansson@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Len Brown <len.brown@intel.com>, Pavel Machek <pavel@ucw.cz>,
        Kevin Hilman <khilman@kernel.org>,
        Geert Uytterhoeven <geert@linux-m68k.org>,
        Lina Iyer <lina.iyer@linaro.org>,
        Jon Hunter <jonathanh@nvidia.com>,
        Marek Szyprowski <m.szyprowski@samsung.com>,
        Linus Walleij <linus.walleij@linaro.org>,
        Steve Glendinning <steve.glendinning@shawell.net>
To: Ulf Hansson <ulf.hansson@linaro.org>,
        "Rafael J. Wysocki" <rjw@rjwysocki.net>,
        Alan Stern <stern@rowland.harvard.edu>,
        linux-pm@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from foss.arm.com ([217.140.101.70]:33580 "EHLO foss.arm.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932740AbcJ1PdT (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 28 Oct 2016 11:33:19 -0400
In-Reply-To: <1477567434-5128-1-git-send-email-ulf.hansson@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On 10/27/2016 06:23 AM, Ulf Hansson wrote:
> The smsc911c driver puts its device into low power state when entering
> system suspend. Although it doesn't update the device's runtime PM status
> to RPM_SUSPENDED, which causes problems for a parent device.
>
> In particular, when the runtime PM status of the parent is requested to be
> updated to RPM_SUSPENDED, the runtime PM core prevent this, because it's
> forbidden to runtime suspend a device, which has an active child.
>
> Fix this by updating the runtime PM status of the smsc911x device to
> RPM_SUSPENDED during system suspend. In system resume, let's reverse that
> action by runtime resuming the device and thus also the parent.
>
> Signed-off-by: Ulf Hansson <ulf.hansson@linaro.org>
> Tested-by: Geert Uytterhoeven <geert+renesas@glider.be>
> Cc: Steve Glendinning <steve.glendinning@shawell.net>
> Fixes: 8b1107b85efd ("PM / Runtime: Don't allow to suspend a device with an active child")
> ---
>
> Note that the commit this change fixes is currently queued for 4.10 via
> Rafael's linux-pm tree. So this fix should go via that tree as well.
>
> ---
>  drivers/net/ethernet/smsc/smsc911x.c | 6 ++++++
>  1 file changed, 6 insertions(+)
>
> diff --git a/drivers/net/ethernet/smsc/smsc911x.c b/drivers/net/ethernet/smsc/smsc911x.c
> index e9b8579..65fca9c 100644
> --- a/drivers/net/ethernet/smsc/smsc911x.c
> +++ b/drivers/net/ethernet/smsc/smsc911x.c
> @@ -2584,6 +2584,9 @@ static int smsc911x_suspend(struct device *dev)
>  		PMT_CTRL_PM_MODE_D1_ | PMT_CTRL_WOL_EN_ |
>  		PMT_CTRL_ED_EN_ | PMT_CTRL_PME_EN_);
>
> +	pm_runtime_disable(dev);
> +	pm_runtime_set_suspended(dev);

> +
>  	return 0;
>  }
>
> @@ -2593,6 +2596,9 @@ static int smsc911x_resume(struct device *dev)
>  	struct smsc911x_data *pdata = netdev_priv(ndev);
>  	unsigned int to = 100;
>
> +	pm_runtime_enable(dev);
> +	pm_runtime_resume(dev);
> +
>  	/* Note 3.11 from the datasheet:
>  	 * 	"When the LAN9220 is in a power saving state, a write of any
>  	 * 	 data to the BYTE_TEST register will wake-up the device."
>

This seems an unusual change/sequence. I thought a successful return 
from the suspend callback would set the device state to suspended.

I just checked a few other ethernet drivers suspend/resume sequences and 
directly calling the pm_runtime seems a little unusual. Most of the 
other drivers are checking to see if the interface is running then doing 
a netif_device_detach()/attach() sequence which is missing from this 
drivers suspend/resume path. Could that be part of the problem?

Of course my knowledge of the power management system is a little thin 
so I could be really off base.
