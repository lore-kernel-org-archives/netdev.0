From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 1/4 net-next] tg3: PTP - Add header definitions,
 initialization and hw access functions.
Date: Mon, 3 Dec 2012 19:23:39 +0100
Message-ID: <20121203182338.GA2531@netboy.at.omicron.at>
References: <1354506171-1646-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, nsujir@broadcom.com
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f174.google.com ([209.85.215.174]:48234 "EHLO
	mail-ea0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751142Ab2LCSXx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Dec 2012 13:23:53 -0500
Received: by mail-ea0-f174.google.com with SMTP id e13so1262845eaa.19
        for <netdev@vger.kernel.org>; Mon, 03 Dec 2012 10:23:52 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1354506171-1646-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please put me on CC for any PTP related patches.
I have a few comments, below.

On Sun, Dec 02, 2012 at 07:42:48PM -0800, Michael Chan wrote:
> From: Matt Carlson <mcarlson@broadcom.com>
> 
> This patch adds code to register/unregister the ptp clock and write
> the reference clock. If a chip reset is performed, the hwclock is
> reinitialized with the adjusted kernel time
> 
> Signed-off-by: Nithin Nayak Sujir <nsujir@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>
> ---
>  drivers/net/ethernet/broadcom/Kconfig |    1 +
>  drivers/net/ethernet/broadcom/tg3.c   |   84 +++++++++++++++++++++++++++++++--
>  drivers/net/ethernet/broadcom/tg3.h   |   60 ++++++++++++++++++++++-
>  3 files changed, 137 insertions(+), 8 deletions(-)
> 
> diff --git a/drivers/net/ethernet/broadcom/Kconfig b/drivers/net/ethernet/broadcom/Kconfig
> index 4bd416b..f552673 100644
> --- a/drivers/net/ethernet/broadcom/Kconfig
> +++ b/drivers/net/ethernet/broadcom/Kconfig
> @@ -102,6 +102,7 @@ config TIGON3
>  	depends on PCI
>  	select PHYLIB
>  	select HWMON
> +	select PTP_1588_CLOCK
>  	---help---
>  	  This driver supports Broadcom Tigon3 based gigabit Ethernet cards.
>  
> diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
> index 5cc976d..38047a9 100644
> --- a/drivers/net/ethernet/broadcom/tg3.c
> +++ b/drivers/net/ethernet/broadcom/tg3.c
> @@ -54,6 +54,9 @@
>  #include <asm/byteorder.h>
>  #include <linux/uaccess.h>
>  
> +#include <uapi/linux/net_tstamp.h>
> +#include <linux/ptp_clock_kernel.h>
> +
>  #ifdef CONFIG_SPARC
>  #include <asm/idprom.h>
>  #include <asm/prom.h>
> @@ -5516,6 +5519,57 @@ static int tg3_setup_phy(struct tg3 *tp, int force_reset)
>  	return err;
>  }
>  
> +static void tg3_refclk_write(struct tg3 *tp, u64 newval)
> +{
> +	tw32(TG3_EAV_REF_CLCK_CTL, TG3_EAV_REF_CLCK_CTL_STOP);
> +	tw32(TG3_EAV_REF_CLCK_LSB, newval & 0xffffffff);
> +	tw32(TG3_EAV_REF_CLCK_MSB, newval >> 32);
> +	tw32_f(TG3_EAV_REF_CLCK_CTL, TG3_EAV_REF_CLCK_CTL_RESUME);
> +}
> +
> +static const struct ptp_clock_info tg3_ptp_caps = {
> +	.owner		= THIS_MODULE,
> +	.name		= "",

Please use a static name here, something related to the driver, like
"tigon3 clock" perhaps. There used to be drivers doing other things
with this, but now the kernel doc from ptp_clock_kernel.h says:

  @name:      A short "friendly name" to identify the clock and to
              help distinguish PHY based devices from MAC based ones.
              The string is not meant to be a unique id.

> +	.max_adj	= 0,
> +	.n_alarm	= 0,
> +	.n_ext_ts	= 0,
> +	.n_per_out	= 0,
> +	.pps		= 0,

You have left the methods as a bunch of NULL pointers. This will not
fly, since someone might land on this commit during a bisect. In
general, every patch in a series should result in a working kernel.

> +};
> +
> +static void tg3_ptp_init(struct tg3 *tp)
> +{
> +	if (!tg3_flag(tp, PTP_CAPABLE))
> +		return;
> +
> +	/* Initialize the hardware clock to the system time. */
> +	tg3_refclk_write(tp, ktime_to_ns(ktime_get_real()));
> +	tp->ptp_adjust = 0;
> +
> +	tp->ptp_info = tg3_ptp_caps;
> +	strncpy(tp->ptp_info.name, tp->dev->name, IFNAMSIZ);
> +}
> +
> +static void tg3_ptp_resume(struct tg3 *tp)
> +{
> +	if (!tg3_flag(tp, PTP_CAPABLE))
> +		return;
> +
> +	tg3_refclk_write(tp, ktime_to_ns(ktime_get_real()) + tp->ptp_adjust);
> +	tp->ptp_adjust = 0;
> +}
> +
> +static void tg3_ptp_fini(struct tg3 *tp)
> +{
> +	if (!tg3_flag(tp, PTP_CAPABLE) ||
> +	    !tp->ptp_clock)

Overzealous line break.

> +		return;
> +
> +	ptp_clock_unregister(tp->ptp_clock);
> +	tp->ptp_clock = NULL;
> +	tp->ptp_adjust = 0;
> +}
> +
>  static inline int tg3_irq_sync(struct tg3 *tp)
>  {
>  	return tp->irq_sync;
> @@ -6527,6 +6581,8 @@ static inline void tg3_netif_stop(struct tg3 *tp)
>  
>  static inline void tg3_netif_start(struct tg3 *tp)
>  {
> +	tg3_ptp_resume(tp);
> +
>  	/* NOTE: unconditional netif_tx_wake_all_queues is only
>  	 * appropriate so long as all callers are assured to
>  	 * have free tx slots (such as after tg3_init_hw)
> @@ -10364,7 +10420,8 @@ static void tg3_ints_fini(struct tg3 *tp)
>  	tg3_flag_clear(tp, ENABLE_TSS);
>  }
>  
> -static int tg3_start(struct tg3 *tp, bool reset_phy, bool test_irq)
> +static int tg3_start(struct tg3 *tp, bool reset_phy, bool test_irq,
> +		     bool init)
>  {
>  	struct net_device *dev = tp->dev;
>  	int i, err;
> @@ -10443,6 +10500,12 @@ static int tg3_start(struct tg3 *tp, bool reset_phy, bool test_irq)
>  	tg3_flag_set(tp, INIT_COMPLETE);
>  	tg3_enable_ints(tp);
>  
> +	if (init)
> +		tg3_ptp_init(tp);
> +	else
> +		tg3_ptp_resume(tp);
> +
> +
>  	tg3_full_unlock(tp);
>  
>  	netif_tx_start_all_queues(dev);
> @@ -10540,11 +10603,19 @@ static int tg3_open(struct net_device *dev)
>  
>  	tg3_full_unlock(tp);
>  
> -	err = tg3_start(tp, true, true);
> +	err = tg3_start(tp, true, true, true);
>  	if (err) {
>  		tg3_frob_aux_power(tp, false);
>  		pci_set_power_state(tp->pdev, PCI_D3hot);
>  	}
> +
> +	if (tg3_flag(tp, PTP_CAPABLE)) {
> +		tp->ptp_clock = ptp_clock_register(&tp->ptp_info,
> +						   &tp->pdev->dev);
> +		if (IS_ERR(tp->ptp_clock))
> +			tp->ptp_clock = NULL;
> +	}
> +
>  	return err;
>  }
>  
> @@ -10552,6 +10623,8 @@ static int tg3_close(struct net_device *dev)
>  {
>  	struct tg3 *tp = netdev_priv(dev);
>  
> +	tg3_ptp_fini(tp);
> +
>  	tg3_stop(tp);
>  
>  	/* Clear stats across close / open calls */
> @@ -11454,7 +11527,7 @@ static int tg3_set_channels(struct net_device *dev,
>  
>  	tg3_carrier_off(tp);
>  
> -	tg3_start(tp, true, false);
> +	tg3_start(tp, true, false, false);
>  
>  	return 0;
>  }
> @@ -12507,7 +12580,6 @@ static void tg3_self_test(struct net_device *dev, struct ethtool_test *etest,
>  		}
>  
>  		tg3_full_lock(tp, irq_sync);
> -
>  		tg3_halt(tp, RESET_KIND_SUSPEND, 1);
>  		err = tg3_nvram_lock(tp);
>  		tg3_halt_cpu(tp, RX_CPU_BASE);
> @@ -16598,8 +16670,8 @@ static void tg3_io_resume(struct pci_dev *pdev)
>  	tg3_full_lock(tp, 0);
>  	tg3_flag_set(tp, INIT_COMPLETE);
>  	err = tg3_restart_hw(tp, 1);
> -	tg3_full_unlock(tp);
>  	if (err) {
> +		tg3_full_unlock(tp);

This is hunk or the next one somehow related to the PTP code?
If not, they it should go into their own patch.

>  		netdev_err(netdev, "Cannot restart hardware after reset.\n");
>  		goto done;
>  	}
> @@ -16610,6 +16682,8 @@ static void tg3_io_resume(struct pci_dev *pdev)
>  
>  	tg3_netif_start(tp);
>  
> +	tg3_full_unlock(tp);
> +
>  	tg3_phy_start(tp);
>  
>  done:

Thanks,
Richard
