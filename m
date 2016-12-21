From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: Re: [PATCH net 3/3] cpsw/netcp: work around reverse cpts dependency
Date: Wed, 21 Dec 2016 12:23:53 -0600
Message-ID: <625fda9e-5768-4d0d-c52e-d40368e20d2e@ti.com>
References: <20161216092017.2560717-1-arnd@arndb.de>
 <20161216092017.2560717-3-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Thomas Gleixner <tglx@linutronix.de>,
        Nicolas Pitre <nicolas.pitre@linaro.org>,
        =?UTF-8?Q?Uwe_Kleine-K=c3=b6nig?= <u.kleine-koenig@pengutronix.de>,
        "Kwok, WingMan" <w-kwok2@ti.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Arnd Bergmann <arnd@arndb.de>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161216092017.2560717-3-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 12/16/2016 03:19 AM, Arnd Bergmann wrote:
> The dependency is reversed: cpsw and netcp call into cpts,
> but cpts depends on the other two in Kconfig. This can lead
> to cpts being a loadable module and its callers built-in:
>
> drivers/net/ethernet/ti/cpsw.o: In function `cpsw_remove':
> cpsw.c:(.text.cpsw_remove+0xd0): undefined reference to `cpts_release'
> drivers/net/ethernet/ti/cpsw.o: In function `cpsw_rx_handler':
> cpsw.c:(.text.cpsw_rx_handler+0x2dc): undefined reference to `cpts_rx_timestamp'
> drivers/net/ethernet/ti/cpsw.o: In function `cpsw_tx_handler':
> cpsw.c:(.text.cpsw_tx_handler+0x7c): undefined reference to `cpts_tx_timestamp'
> drivers/net/ethernet/ti/cpsw.o: In function `cpsw_ndo_stop':
>
> As a workaround, I'm introducing another Kconfig symbol to
> control the compilation of cpts, while making the actual
> module controlled by a silent symbol that is =y when necessary.
>
> Fixes: 6246168b4a38 ("net: ethernet: ti: netcp: add support of cpts")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Thanks for the fix.
  I've tried to test as much combination as possible,
but seems not of them:(

Reviewed-by: Grygorii Strashko <grygorii.strashko@ti.com>

> ---
>  drivers/net/ethernet/ti/Kconfig | 10 ++++++++--
>  1 file changed, 8 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/ethernet/ti/Kconfig b/drivers/net/ethernet/ti/Kconfig
> index 366e29ff8605..c114efcd1575 100644
> --- a/drivers/net/ethernet/ti/Kconfig
> +++ b/drivers/net/ethernet/ti/Kconfig
> @@ -73,8 +73,8 @@ config TI_CPSW
>  	  To compile this driver as a module, choose M here: the module
>  	  will be called cpsw.
>
> -config TI_CPTS
> -	tristate "TI Common Platform Time Sync (CPTS) Support"
> +config TI_CPTS_ENABLE
> +	bool "TI Common Platform Time Sync (CPTS) Support"
>  	depends on TI_CPSW || TI_KEYSTONE_NETCP
>  	depends on POSIX_TIMERS
>  	select PTP_1588_CLOCK
> @@ -84,6 +84,12 @@ config TI_CPTS
>  	  The unit can time stamp PTP UDP/IPv4 and Layer 2 packets, and the
>  	  driver offers a PTP Hardware Clock.
>
> +config TI_CPTS
> +	tristate
> +	depends on TI_CPTS_ENABLE
> +	default y if TI_CPSW=y || TI_KEYSTONE_NETCP=y
> +	default m
> +
>  config TI_KEYSTONE_NETCP
>  	tristate "TI Keystone NETCP Core Support"
>  	select TI_CPSW_ALE
>

-- 
regards,
-grygorii
