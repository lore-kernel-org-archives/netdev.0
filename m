From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 2/3] Add support for RX packet classification in a
	network device
Date: Mon, 22 Dec 2008 19:27:13 +0000
Message-ID: <1229974033.3077.14.camel@achroite>
References: <494FE060.8020600@Sun.COM>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, jeff@garzik.org,
	gkernel-commit@lists.sourceforge.net,
	Matheos Worku <Matheos.Worku@Sun.COM>,
	Mehdi Bonyadi <Mehdi.Bonyadi@Sun.COM>
To: Santwona.Behera@Sun.COM
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost02.mail.zen.net.uk ([212.23.3.141]:60152 "EHLO
	smarthost02.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753317AbYLVT1b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Dec 2008 14:27:31 -0500
In-Reply-To: <494FE060.8020600@Sun.COM>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2008-12-22 at 10:45 -0800, Santwona.Behera@Sun.COM wrote:
> diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
> index b4b038b..d3289b0 100644
> --- a/include/linux/ethtool.h
> +++ b/include/linux/ethtool.h
> @@ -55,12 +55,13 @@ struct ethtool_drvinfo {
>         char    bus_info[ETHTOOL_BUSINFO_LEN];  /* Bus info for this IF. */
>                                 /* For PCI devices, use pci_name(pci_dev). */
>         char    reserved1[32];
> -       char    reserved2[12];
> +       char    reserved2[8];
>         __u32   n_priv_flags;   /* number of flags valid in ETHTOOL_GPFLAGS */
>         __u32   n_stats;        /* number of u64's from ETHTOOL_GSTATS */
>         __u32   testinfo_len;
>         __u32   eedump_len;     /* Size of data from ETHTOOL_GEEPROM (bytes) */
>         __u32   regdump_len;    /* Size of data from ETHTOOL_GREGS (bytes) */
> +       __u32   n_rx_rules;     /* number of rx classification rules */
>  };

This shifts all the fields between n_priv_flags and regdump_len
inclusive.  What is the point of reserving space in the structure if we
then go and move fields around elsewhere?

Also, why do you think n_rx_rules is driver or hardware information?
The maximum number of RX filters is not necessarily a static property.
Consider hardware that has separate limited-size sets of layer-2 and
layer-3 filters, or that has a single set but needs more storage for
some types of filters.

The important value is the current number of rules which is dynamic and
does not belong here.

[...]
> @@ -558,14 +626,16 @@ struct ethtool_ops {
>  #define        TCP_V4_FLOW     0x01
>  #define        UDP_V4_FLOW     0x02
>  #define        SCTP_V4_FLOW    0x03
> -#define        AH_ESP_V4_FLOW  0x04
> -#define        TCP_V6_FLOW     0x05
> -#define        UDP_V6_FLOW     0x06
> -#define        SCTP_V6_FLOW    0x07
> -#define        AH_ESP_V6_FLOW  0x08
> +#define        AH_V4_FLOW      0x04
> +#define        ESP_V4_FLOW     0x05
> +#define        TCP_V6_FLOW     0x06
> +#define        UDP_V6_FLOW     0x07
> +#define        SCTP_V6_FLOW    0x08
> +#define        AH_V6_FLOW      0x09
> +#define        ESP_V6_FLOW     0x0a
> +#define        IP_USER_FLOW    0x0b
>  
>  /* L3-L4 network traffic flow hash options */
> -#define        RXH_DEV_PORT    (1 << 0)
>  #define        RXH_L2DA        (1 << 1)
>  #define        RXH_VLAN        (1 << 2)
>  #define        RXH_L3_PROTO    (1 << 3)
[...]

No, you can't do this.  Leave the existing definitions unchanged and
only add new ones.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

