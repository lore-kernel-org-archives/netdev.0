From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: RFC - document network device carrier management
Date: Mon, 20 Aug 2012 22:34:25 +0100
Message-ID: <1345498465.2659.41.camel@bwh-desktop.uk.solarflarecom.com>
References: <20120815085827.2b252094@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:54437 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751836Ab2HTVe2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Aug 2012 17:34:28 -0400
In-Reply-To: <20120815085827.2b252094@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-08-15 at 08:58 -0700, Stephen Hemminger wrote:
> Since carrier handling is often done incorrectly by new device drivers
> be explicit about carrier handling API.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> ---
> This is a meant as starting point for discussion, it's probably wrong as is.
> Since this isn't code, it could be applied for 3.6 and doesn't need for net-next.
> 
> 
> --- a/Documentation/networking/netdevices.txt	2012-06-22 08:27:46.729168196 -0700
> +++ b/Documentation/networking/netdevices.txt	2012-08-15 08:56:31.120429994 -0700
> @@ -45,6 +45,36 @@ drop, truncate, or pass up oversize pack
>  packets is preferred.
>  
> 
> +CARRIER
> +=======
> +Most network devices have an operational state that the device
> +monitors. The Linux kernel uses the name "carrier" for this flag which
> +is a historical reference to old modems. Carrier is reported to
> +userspace via the IFF_RUNNING flag from SIOCGIFFLAGS ioctl.
> +Carrier is controlled in the device driver
> +by the functions netif_carrier_on and netif_carrier_off. These
> +functions trigger the necessary netlink and userspace API changes;
> +device drivers must not change netdevice->flags directly.
> +
> +The carrier defaults to ON when the device is created and registered.
> +Simple devices (such as dummy) do not need to do anything.
> +Ethernet style devices should:
> +   * alloc_etherdev in probe routine
> +   * call netif_carrier_off
> +   * register network device
> +   * start auto negotiation with phy in open routine

Auto-negotiation is only one of several stages of link setup, and of
course is not used in all Ethernet physical layers.  I think the
important point is that once the ndo_open method returns the hardware
and driver should be ready to set up the link and report this state
whenever a suitable partner is physically connected.

> +   * call netif_carrier_on when link is up
> +
> +More complex RFC2863 style operational state is also possible
> +but not required (see operstates.txt).

Drivers are not allowed to set operstate directly.

> +The monitoring of link state is the responsibility of the network
> +device driver. It can be done by polling, interrupt, or any other
> +mechanism. netif_carrier_on/netif_carrier_off are atomic and can
> +safely be called by an interrupt routine. Carrier events are
> +managed by the linkwatch work queue and limited to one per second
> +to avoid overwhelming management applications.
> +
>  struct net_device synchronization rules
>  =======================================
>  ndo_open:

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
