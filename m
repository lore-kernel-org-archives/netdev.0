From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [RFC: -mm patch] improve the SSB dependencies
Date: Sun, 12 Aug 2007 14:00:26 +0200
Message-ID: <200708121400.28297.mb@bu3sch.de>
References: <200708110208.21624.mb@bu3sch.de> <200708111642.39348.mb@bu3sch.de> <20070811230855.GA8907@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Adrian Bunk <bunk@kernel.org>,
	Johannes Berg <johannes@sipsolutions.net>,
	John Linville <linville@tuxdriver.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Adrian Bunk <bunk@stusta.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:53629
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757608AbXHLMBY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Aug 2007 08:01:24 -0400
In-Reply-To: <20070811230855.GA8907@stusta.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ok, I'll give it a try, with small modifications.

On Sunday 12 August 2007, Adrian Bunk wrote:
> Additional changes in this patch:
> - small help text changes
> - B44_PCI is no longer usr visible (automatically enabled when possible)

I think we want that to be selectable, as it's not needed
on some embedded devices. And we need to save memory there.

> - let SSB_SILENT depend on EMBEDDED (unless you are in a very
>   space restricted environment you don't need to enable it)

Good idea.

> - make the following options no longer user visible
>   (they are select'ed when required):
>   - SSB_PCIHOST

>   - SSB_DRIVER_PCICORE

No, we need that to be selectable.

>   - SSB_PCMCIAHOST
> 
> 
> Signed-off-by: Adrian Bunk <bunk@kernel.org>
> 
> ---
> 
>  drivers/net/Kconfig                           |   12 ---
>  drivers/net/wireless/bcm43xx-mac80211/Kconfig |   10 +-
>  drivers/ssb/Kconfig                           |   72 ++++++++++--------
>  drivers/usb/host/Kconfig                      |    4 -
>  4 files changed, 51 insertions(+), 47 deletions(-)
> 
> 6ed573214282b96e7714b33b89a7221c01efbb86 
> diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
> index cea1979..a4f0c2f 100644
> --- a/drivers/net/Kconfig
> +++ b/drivers/net/Kconfig
> @@ -1435,6 +1435,7 @@ config APRICOT
>  config B44
>  	tristate "Broadcom 440x/47xx ethernet support"
>  	depends on HAS_IOMEM
> +	depends on SSB_POSSIBLE
>  	select SSB
>  	select MII
>  	help
> @@ -1452,17 +1453,10 @@ config B44
>  	  called b44.
>  
>  config B44_PCI
> -	bool "Broadcom 440x PCI device support"
> -	depends on B44 && NET_PCI
> -	select SSB_PCIHOST
> +	bool
> +	depends on B44 && SSB_DRIVER_PCICORE_POSSIBLE
>  	select SSB_DRIVER_PCICORE
>  	default y
> -	help
> -	  Support for Broadcom 440x PCI devices.
> -
> -	  Say Y, unless you know what you are doing.
> -	  If you say N here I will _not_ listen to your
> -	  bugreports!
>  
>  config FORCEDETH
>  	tristate "nForce Ethernet support"
> diff --git a/drivers/net/wireless/bcm43xx-mac80211/Kconfig b/drivers/net/wireless/bcm43xx-mac80211/Kconfig
> index 8f9df0e..8af8535 100644
> --- a/drivers/net/wireless/bcm43xx-mac80211/Kconfig
> +++ b/drivers/net/wireless/bcm43xx-mac80211/Kconfig
> @@ -1,6 +1,6 @@
>  config BCM43XX_MAC80211
>  	tristate "Broadcom BCM43xx wireless support (mac80211 stack)"
> -	depends on MAC80211 && WLAN_80211 && EXPERIMENTAL
> +	depends on MAC80211 && WLAN_80211 && SSB_POSSIBLE && EXPERIMENTAL
>  	select FW_LOADER
>  	select SSB
>  	select HW_RANDOM
> @@ -10,8 +10,8 @@ config BCM43XX_MAC80211
>  
>  config BCM43XX_MAC80211_PCI
>  	bool "BCM43xx PCI device support"
> -	depends on BCM43XX_MAC80211 && PCI
> -	select SSB_PCIHOST
> +	depends on BCM43XX_MAC80211
> +	depends on SSB_DRIVER_PCICORE_POSSIBLE
>  	select SSB_DRIVER_PCICORE
>  	default y
>  	---help---
> @@ -24,7 +24,7 @@ config BCM43XX_MAC80211_PCI
>  
>  config BCM43XX_MAC80211_PCMCIA
>  	bool "BCM43xx PCMCIA device support"
> -	depends on BCM43XX_MAC80211 && PCMCIA
> +	depends on BCM43XX_MAC80211 && SSB_PCMCIAHOST_POSSIBLE
>  	select SSB_PCMCIAHOST
>  	---help---
>  	  Broadcom 43xx PCMCIA device support.
> @@ -45,7 +45,7 @@ config BCM43XX_MAC80211_PCMCIA
>  config BCM43XX_MAC80211_DEBUG
>  	bool "Broadcom BCM43xx debugging (RECOMMENDED)"
>  	depends on BCM43XX_MAC80211
> -	select SSB_DEBUG if !SSB_SILENT
> +	select SSB_DEBUG if SSB_DEBUG_POSSIBLE
>  	default y
>  	---help---
>  	  Broadcom 43xx debugging messages.
> diff --git a/drivers/ssb/Kconfig b/drivers/ssb/Kconfig
> index 094703c..366c888 100644
> --- a/drivers/ssb/Kconfig
> +++ b/drivers/ssb/Kconfig
> @@ -1,37 +1,42 @@
>  menu "Sonics Silicon Backplane"
>  
> +config SSB_POSSIBLE
> +	bool
> +	depends on EXPERIMENTAL && HAS_IOMEM
> +	default y
> +
>  config SSB
>  	tristate "Sonics Silicon Backplane support"
> -	depends on EXPERIMENTAL && HAS_IOMEM
> +	depends on SSB_POSSIBLE
>  	help
> -	  Support for the Sonics Silicon Backplane bus
> +	  Support for the Sonics Silicon Backplane bus.
> +	  You only need to enable this option if you are
> +	  configuring a kernel for an embedded system with
> +	  this bus.
>  
> -	  The module will be called ssb
> +	  The module will be called ssb.
>  
> -	  If unsure, say M
> +	  If unsure, say N.
>  
> -config SSB_PCIHOST
> -	bool "Support for SSB on PCI-bus host"
> -	depends on SSB && PCI
> +config SSB_PCIHOST_POSSIBLE
> +	bool
> +	depends on SSB_POSSIBLE && PCI
>  	default y
> -	help
> -	  Support for a Sonics Silicon Backplane on top
> -	  of a PCI device.
>  
> -	  If unsure, say Y
> +config SSB_PCIHOST
> +	bool
>  
> -config SSB_PCMCIAHOST
> -	bool "Support for SSB on PCMCIA-bus host"
> -	depends on SSB && PCMCIA
> -	help
> -	  Support for a Sonics Silicon Backplane on top
> -	  of a PCMCIA device.
> +config SSB_PCMCIAHOST_POSSIBLE
> +	bool
> +	depends on SSB_POSSIBLE && PCMCIA
> +	default y
>  
> -	  If unsure, say N
> +config SSB_PCMCIAHOST
> +	bool
>  
>  config SSB_SILENT
>  	bool "No SSB kernel messages"
> -	depends on SSB
> +	depends on SSB && EMBEDDED
>  	help
>  	  This option turns off all Sonics Silicon Backplane printks.
>  	  Note that you won't be able to identify problems, once
> @@ -39,30 +44,35 @@ config SSB_SILENT
>  	  This might only be desired for production kernels on
>  	  embedded devices to reduce the kernel size.
>  
> -	  Say N
> +	  If unsure, say N.
> +
> +config SSB_DEBUG_POSSIBLE
> +	bool
> +	depends on SSB && !SSB_SILENT
> +	default y
>  
>  config SSB_DEBUG
>  	bool "SSB debugging"
> -	depends on SSB && !SSB_SILENT
> +	depends on SSB_DEBUG_POSSIBLE
>  	help
>  	  This turns on additional runtime checks and debugging
>  	  messages. Turn this on for SSB troubleshooting.
>  
> -	  If unsure, say N
> +	  If unsure, say N.
>  
>  config SSB_SERIAL
>  	bool
>  	depends on SSB
>  	# ChipCommon and ExtIf serial support routines.
>  
> -config SSB_DRIVER_PCICORE
> -	bool "SSB PCI core driver"
> -	depends on SSB && SSB_PCIHOST
> -	help
> -	  Driver for the Sonics Silicon Backplane attached
> -	  Broadcom PCI core.
> +config SSB_DRIVER_PCICORE_POSSIBLE
> +	bool
> +	depends on SSB_PCIHOST_POSSIBLE
> +	default y
>  
> -	  If unsure, say Y
> +config SSB_DRIVER_PCICORE
> +	bool
> +	select SSB_PCIHOST
>  
>  config SSB_PCICORE_HOSTMODE
>  	bool "Hostmode support for SSB PCI core"
> @@ -78,7 +88,7 @@ config SSB_DRIVER_MIPS
>  	  Driver for the Sonics Silicon Backplane attached
>  	  Broadcom MIPS core.
>  
> -	  If unsure, say N
> +	  If unsure, say N.
>  
>  config SSB_DRIVER_EXTIF
>  	bool "SSB Broadcom EXTIF core driver"
> @@ -87,6 +97,6 @@ config SSB_DRIVER_EXTIF
>  	  Driver for the Sonics Silicon Backplane attached
>  	  Broadcom EXTIF core.
>  
> -	  If unsure, say N
> +	  If unsure, say N.
>  
>  endmenu
> diff --git a/drivers/usb/host/Kconfig b/drivers/usb/host/Kconfig
> index dc3b7fe..d7f5328 100644
> --- a/drivers/usb/host/Kconfig
> +++ b/drivers/usb/host/Kconfig
> @@ -101,6 +101,7 @@ config USB_OHCI_HCD
>  	depends on USB && USB_ARCH_HAS_OHCI
>  	select ISP1301_OMAP if MACH_OMAP_H2 || MACH_OMAP_H3
>  	select I2C if ARCH_PNX4008
> +	select SSB if USB_OHCI_HCD_SSB
>  	---help---
>  	  The Open Host Controller Interface (OHCI) is a standard for accessing
>  	  USB 1.1 host controller hardware.  It does more in hardware than Intel's
> @@ -156,8 +157,7 @@ config USB_OHCI_HCD_PCI
>  
>  config USB_OHCI_HCD_SSB
>  	bool "OHCI support for the Broadcom SSB OHCI core (embedded systems only)"
> -	depends on USB_OHCI_HCD && ((USB_OHCI_HCD=m && SSB) || (USB_OHCI_HCD=y && SSB=y)) && EXPERIMENTAL
> -	default n
> +	depends on USB_OHCI_HCD && SSB_POSSIBLE && EXPERIMENTAL
>  	---help---
>  	  Support for the Sonics Silicon Backplane (SSB) attached
>  	  Broadcom USB OHCI core.
> 
> 
> 


