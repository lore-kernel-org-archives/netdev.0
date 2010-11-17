From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC PATCH] ethtool: allow setting MDI-X state
Date: Wed, 17 Nov 2010 23:53:10 +0000
Message-ID: <1290037990.30433.82.camel@localhost>
References: <20101117231655.30673.37157.stgit@jbrandeb-ich9b.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jesse Brandeburg <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:44146 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752255Ab0KQXxQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Nov 2010 18:53:16 -0500
In-Reply-To: <20101117231655.30673.37157.stgit@jbrandeb-ich9b.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-11-17 at 15:16 -0800, Jesse Brandeburg wrote:
> ethtool recently added support for reading MDI-X state, this
> patch finishes the implementation, adding the complementary write
> command.
> 
> Add support to ethtool for controlling the MDI-X (crossover)
> state of a network port.  Most adapters correctly negotiate
> MDI-X, but some ill-behaved switches have trouble and end up
> picking the wrong MDI setting, which results in complete loss of
> link.  Usually this error condition can be observed with multiple
> ethtool -r ethX required before link is achieved.
> 
> usage is ethtool -s eth0 mdix [auto|on|off]
>
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> ---
> 
>  ethtool.8 |    8 ++++++++
>  ethtool.c |   34 ++++++++++++++++++++++++++++++++++
>  2 files changed, 42 insertions(+), 0 deletions(-)
> 
> diff --git a/ethtool.8 b/ethtool.8
> index 1760924..c96e35d 100644
> --- a/ethtool.8
> +++ b/ethtool.8
> @@ -196,6 +196,7 @@ ethtool \- Display or change ethernet card settings
>  .BI speed \ N
>  .B2 duplex half full
>  .B4 port tp aui bnc mii fibre
> +.B3 mdix auto on off
>  .B2 autoneg on off
>  .RB [ advertise
>  .IR N ]
> @@ -452,6 +453,13 @@ Sets full or half duplex mode.
>  .A4 port tp aui bnc mii fibre
>  Selects device port.
>  .TP
> +.A3 mdix auto on off
> +Selects MDI-X mode for port. May be used to override the automatic detection
> +feature of most adapters.  Auto means automatic detection of MDI status, on
> +forces MDI-X (crossover) mode, while off means MDI (straight through) mode.
> +Depending on implementation an ethtool -r ethX command may be necessary to
> +cause the change to take effect.

This is stupid, we should specify whether this should trigger
renegotiation or not.  (And that should be done in ethtool.h as well,
since that's the specification that driver writers look at.)

> +.TP
>  .A2 autoneg on off
>  Specifies whether autonegotiation should be enabled. Autonegotiation 
>  is enabled by deafult, but in some network devices may have trouble
> diff --git a/ethtool.c b/ethtool.c
> index 239912b..fcc7998 100644
> --- a/ethtool.c
> +++ b/ethtool.c
> @@ -157,6 +157,7 @@ static struct option {
>  		"		[ speed %d ]\n"
>  		"		[ duplex half|full ]\n"
>  		"		[ port tp|aui|bnc|mii|fibre ]\n"
> +		"		[ mdix auto|on|off ]\n"
>  		"		[ autoneg on|off ]\n"
>  		"		[ advertise %x ]\n"
>  		"		[ phyad %d ]\n"
> @@ -353,6 +354,7 @@ static s32 coal_tx_frames_high_wanted = -1;
>  static int speed_wanted = -1;
>  static int duplex_wanted = -1;
>  static int port_wanted = -1;
> +static int mdix_wanted = -1;
>  static int autoneg_wanted = -1;
>  static int phyad_wanted = -1;
>  static int xcvr_wanted = -1;
> @@ -1048,6 +1050,20 @@ static void parse_cmdline(int argc, char **argp)
>  				else
>  					show_usage(1);
>  				break;
> +			} else if (!strcmp(argp[i], "mdix")) {
> +				gset_changed = 1;
> +				i += 1;
> +				if (i >= argc)
> +					show_usage(1);
> +				if (!strcmp(argp[i], "auto"))
> +					mdix_wanted = ETH_TP_MDI_INVALID;
> +				else if (!strcmp(argp[i], "on"))
> +					mdix_wanted = ETH_TP_MDI_X;
> +				else if (!strcmp(argp[i], "off"))
> +					mdix_wanted = ETH_TP_MDI;
> +				else
> +					show_usage(1);
> +				break;
>  			} else if (!strcmp(argp[i], "autoneg")) {
>  				i += 1;
>  				if (i >= argc)
> @@ -1124,6 +1140,20 @@ static void parse_cmdline(int argc, char **argp)
>  					i = argc;
>  				}
>  				break;
> +			} else if (!strcmp(argp[i], "mdix")) {
> +				gset_changed = 1;
> +				i += 1;
> +				if (i >= argc)
> +					show_usage(1);
> +				if (!strcmp(argp[i], "auto"))
> +					mdix_wanted = ETH_TP_MDI_INVALID;
> +				else if (!strcmp(argp[i], "on"))
> +					mdix_wanted = ETH_TP_MDI_X;
> +				else if (!strcmp(argp[i], "off"))
> +					mdix_wanted = ETH_TP_MDI;
> +				else
> +					show_usage(1);
> +				break;
>  			}
>  			show_usage(1);
>  		}

I'm seeing double!

> @@ -2525,6 +2555,8 @@ static int do_sset(int fd, struct ifreq *ifr)
>  				ecmd.duplex = duplex_wanted;
>  			if (port_wanted != -1)
>  				ecmd.port = port_wanted;
> +			if (mdix_wanted != -1)
> +				ecmd.eth_tp_mdix = mdix_wanted;

There are two serious problems with this:
1. All existing drivers will silently ignore this.
2. If the user doesn't specify it, the MDI-X setting will be forced to
whatever was last automatically selected.

There needs to be some way for ethtool (or other client) to detect
whether the driver actually supports forcing MDI-X, and for the driver
to detect whether the client is trying to do it.  And I would suggest
using a second field for this:

--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -31,9 +31,9 @@ struct ethtool_cmd {
 	__u32	maxtxpkt;	/* Tx pkts before generating tx int */
 	__u32	maxrxpkt;	/* Rx pkts before generating rx int */
 	__u16	speed_hi;
-	__u8	eth_tp_mdix;
-	__u8	reserved2;
+	__u8	eth_tp_mdix;	/* Twisted-pair MDI-X status */
+	__u8	eth_tp_mdix_ctrl; /* Twisted-pair MDI-X control */
 	__u32	lp_advertising;	/* Features the link partner advertises */
 	__u32	reserved[2];
 };
@@ -653,10 +653,11 @@ struct ethtool_ops {
 #define AUTONEG_DISABLE		0x00
 #define AUTONEG_ENABLE		0x01
 
-/* Mode MDI or MDI-X */
-#define ETH_TP_MDI_INVALID	0x00
-#define ETH_TP_MDI		0x01
-#define ETH_TP_MDI_X		0x02
+/* MDI or MDI-X status/control */
+#define ETH_TP_MDI_INVALID	0x00	/* status: unknown; control: unsupported */
+#define ETH_TP_MDI		0x01	/* status: MDI;     control: force MDI */
+#define ETH_TP_MDI_X		0x02	/* status: MDI-X;   control: force MDI-X */
+#define ETH_TP_MDI_AUTO		0x03	/*                  control: auto-select */
 
 /* Wake-On-Lan options. */
 #define WAKE_PHY		(1 << 0)
--- END ---

ethtool should then fail if the user attempts to control MDI-X and
ETHTOOL_GSET yields eth_tp_mdix_ctrl == ETH_TP_MDI_INVALID.

Ben.

>  			if (autoneg_wanted != -1)
>  				ecmd.autoneg = autoneg_wanted;
>  			if (phyad_wanted != -1)
> @@ -2566,6 +2598,8 @@ static int do_sset(int fd, struct ifreq *ifr)
>  				fprintf(stderr, "  not setting phy_address\n");
>  			if (xcvr_wanted != -1)
>  				fprintf(stderr, "  not setting transceiver\n");
> +			if (mdix_wanted != -1)
> +				fprintf(stderr, "  not setting mdix\n");
>  		}
>  	}
>  
> 

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

