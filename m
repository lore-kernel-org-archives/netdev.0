From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 4/4] ehea: show physical port state
Date: Sat, 25 Aug 2007 00:36:38 -0400
Message-ID: <46CFB1D6.5030609@garzik.org>
References: <200708221621.32549.ossthema@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Christoph Raisch <raisch@de.ibm.com>,
	Jan-Bernd Themann <themann@de.ibm.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linux-ppc <linuxppc-dev@ozlabs.org>,
	Marcus Eder <meder@de.ibm.com>,
	Thomas Klein <tklein@de.ibm.com>,
	Stefan Roscher <stefan.roscher@de.ibm.com>
To: Jan-Bernd Themann <ossthema@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:56056 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751674AbXHYEgo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Aug 2007 00:36:44 -0400
In-Reply-To: <200708221621.32549.ossthema@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jan-Bernd Themann wrote:
> Introduces a module parameter to decide whether the physical
> port link state is propagated to the network stack or not.
> It makes sense not to take the physical port state into account
> on machines with more logical partitions that communicate
> with each other. This is always possible no matter what the physical
> port state is. Thus eHEA can be considered as a switch there.
> 
> Signed-off-by: Jan-Bernd Themann <themann@de.ibm.com>
> 
> ---
>  drivers/net/ehea/ehea.h      |    5 ++++-
>  drivers/net/ehea/ehea_main.c |   14 +++++++++++++-
>  2 files changed, 17 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/ehea/ehea.h b/drivers/net/ehea/ehea.h
> index d67f97b..8d58be5 100644
> --- a/drivers/net/ehea/ehea.h
> +++ b/drivers/net/ehea/ehea.h
> @@ -39,7 +39,7 @@
>  #include <asm/io.h>
>  
>  #define DRV_NAME	"ehea"
> -#define DRV_VERSION	"EHEA_0073"
> +#define DRV_VERSION	"EHEA_0074"
>  
>  /* eHEA capability flags */
>  #define DLPAR_PORT_ADD_REM 1
> @@ -402,6 +402,8 @@ struct ehea_mc_list {
>  
>  #define EHEA_PORT_UP 1
>  #define EHEA_PORT_DOWN 0
> +#define EHEA_PHY_LINK_UP 1
> +#define EHEA_PHY_LINK_DOWN 0
>  #define EHEA_MAX_PORT_RES 16
>  struct ehea_port {
>  	struct ehea_adapter *adapter;	 /* adapter that owns this port */
> @@ -427,6 +429,7 @@ struct ehea_port {
>  	u32 msg_enable;
>  	u32 sig_comp_iv;
>  	u32 state;
> +	u8 phy_link;
>  	u8 full_duplex;
>  	u8 autoneg;
>  	u8 num_def_qps;
> diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c
> index db57474..1804c99 100644
> --- a/drivers/net/ehea/ehea_main.c
> +++ b/drivers/net/ehea/ehea_main.c
> @@ -53,17 +53,21 @@ static int rq3_entries = EHEA_DEF_ENTRIES_RQ3;
>  static int sq_entries = EHEA_DEF_ENTRIES_SQ;
>  static int use_mcs = 0;
>  static int num_tx_qps = EHEA_NUM_TX_QP;
> +static int show_phys_link = 0;
>  
>  module_param(msg_level, int, 0);
>  module_param(rq1_entries, int, 0);
>  module_param(rq2_entries, int, 0);
>  module_param(rq3_entries, int, 0);
>  module_param(sq_entries, int, 0);
> +module_param(show_phys_link, int, 0);
>  module_param(use_mcs, int, 0);
>  module_param(num_tx_qps, int, 0);
>  
>  MODULE_PARM_DESC(num_tx_qps, "Number of TX-QPS");
>  MODULE_PARM_DESC(msg_level, "msg_level");
> +MODULE_PARM_DESC(show_phys_link, "Show link state of external port"
> +		 "1:yes, 0: no.  Default = 0 ");
>  MODULE_PARM_DESC(rq3_entries, "Number of entries for Receive Queue 3 "
>  		 "[2^x - 1], x = [6..14]. Default = "
>  		 __MODULE_STRING(EHEA_DEF_ENTRIES_RQ3) ")");
> @@ -814,7 +818,9 @@ int ehea_set_portspeed(struct ehea_port *port, u32 port_speed)
>  			ehea_error("Failed setting port speed");
>  		}
>  	}
> -	netif_carrier_on(port->netdev);
> +	if (!show_phys_link || (port->phy_link == EHEA_PHY_LINK_UP))
> +		netif_carrier_on(port->netdev);
> +
>  	kfree(cb4);
>  out:
>  	return ret;
> @@ -869,13 +875,19 @@ static void ehea_parse_eqe(struct ehea_adapter *adapter, u64 eqe)
>  			}
>  
>  		if (EHEA_BMASK_GET(NEQE_EXTSWITCH_PORT_UP, eqe)) {
> +			port->phy_link = EHEA_PHY_LINK_UP;
>  			if (netif_msg_link(port))
>  				ehea_info("%s: Physical port up",
>  					  port->netdev->name);
> +			if (show_phys_link)
> +				netif_carrier_on(port->netdev);
>  		} else {
> +			port->phy_link = EHEA_PHY_LINK_DOWN;
>  			if (netif_msg_link(port))
>  				ehea_info("%s: Physical port down",
>  					  port->netdev->name);
> +			if (show_phys_link)
> +				netif_carrier_off(port->netdev);

I think it's misnamed, calling it "show_xxx", because this (as the 
change description notes) controls propagation of carrier to the network 
stack.

	Jeff



