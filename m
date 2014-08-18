From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v2] ethernet: arc: Add support for specific SoC glue layer
 device tree bindings
Date: Mon, 18 Aug 2014 12:46:21 -0700
Message-ID: <53F2580D.60908@gmail.com>
References: <1408286882-10186-1-git-send-email-romain.perier@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: heiko@sntech.de, tklauser@distanz.ch, b.galvani@gmail.com,
	eric.dumazet@gmail.com, yongjun_wei@trendmicro.com.cn,
	netdev@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>
To: Romain Perier <romain.perier@gmail.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:37305 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751258AbaHRTqt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Aug 2014 15:46:49 -0400
Received: by mail-pa0-f47.google.com with SMTP id kx10so8460636pab.20
        for <netdev@vger.kernel.org>; Mon, 18 Aug 2014 12:46:48 -0700 (PDT)
In-Reply-To: <1408286882-10186-1-git-send-email-romain.perier@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/17/2014 07:48 AM, Romain Perier wrote:
> Some platforms have special bank registers which might be used to select
> the correct clock or the right mode for Media Indepent Interface controllers.
> Sometimes, it is also required to activate vcc regulators in the right order to supply
> the ethernet controller at the right time. This patch is a refactoring of the arc-emac
> device driver, it adds a new software architecture design which allows to add specific
> platform glue layer. Each platform has now its own module which performs custom initialization
> and remove for the target and then calls to the core driver.

Most of the changes are made largely harder to read because you renamed
a struct device pointer variable, so what I would suggest you do is:

- use the same struct device pointer variable throughout
arc_emac_probe() as a preliminary change, that will be easier to read

- allow for specifying custom platform data and make this intermediate
struct device pointer variable point to the newly added struct device
pointer (which would make the changes much less intrusive)

Thanks!

> 
> Signed-off-by: Romain Perier <romain.perier@gmail.com>
> ---
>  drivers/net/ethernet/arc/Kconfig     |  13 ++--
>  drivers/net/ethernet/arc/Makefile    |   3 +-
>  drivers/net/ethernet/arc/emac.h      |  21 ++++-
>  drivers/net/ethernet/arc/emac_arc.c  |  77 +++++++++++++++++++
>  drivers/net/ethernet/arc/emac_main.c | 145 +++++++++++++++--------------------
>  drivers/net/ethernet/arc/emac_mdio.c |  11 ++-
>  6 files changed, 170 insertions(+), 100 deletions(-)
>  create mode 100644 drivers/net/ethernet/arc/emac_arc.c
> 
> diff --git a/drivers/net/ethernet/arc/Kconfig b/drivers/net/ethernet/arc/Kconfig
> index 514c57f..ecaff9c 100644
> --- a/drivers/net/ethernet/arc/Kconfig
> +++ b/drivers/net/ethernet/arc/Kconfig
> @@ -3,8 +3,11 @@
>  #
>  
>  config NET_VENDOR_ARC
> -	bool "ARC devices"
> -	default y
> +	tristate "ARC devices"
> +	select MII
> +	select PHYLIB
> +	depends on OF_IRQ
> +	depends on OF_NET

NET_VENDOR_ARC is a Kconfig symbol that should remain default y, it is
just there such that there is a submenu for all ARC devices, if you need
to factor some Kconfig options into a generic place, you should probably
introduce a new Kconfig option such as ARC_EMAC_GLUE or something like that.

>  	---help---
>  	  If you have a network (Ethernet) card belonging to this class, say Y
>  	  and read the Ethernet-HOWTO, available from
> @@ -18,11 +21,7 @@ config NET_VENDOR_ARC
>  if NET_VENDOR_ARC
>  
>  config ARC_EMAC
> -	tristate "ARC EMAC support"
> -	select MII
> -	select PHYLIB
> -	depends on OF_IRQ
> -	depends on OF_NET
> +	tristate "ARC EMAC support
>  	---help---
>  	  On some legacy ARC (Synopsys) FPGA boards such as ARCAngel4/ML50x
>  	  non-standard on-chip ethernet device ARC EMAC 10/100 is used.
> diff --git a/drivers/net/ethernet/arc/Makefile b/drivers/net/ethernet/arc/Makefile
--
Florian
