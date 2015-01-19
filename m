From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH net-next 3/5] bonding: fix incorrect lacp mux state when
 agg not active
Date: Mon, 19 Jan 2015 20:26:11 +0100
Message-ID: <54BD5A53.8050609@redhat.com>
References: <1421423848-414-1-git-send-email-jtoppins@cumulusnetworks.com> <1421423848-414-4-git-send-email-jtoppins@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Andy Gospodarek <gospo@cumulusnetworks.com>,
	Wilson Kok <wkok@cumulusnetworks.com>
To: Jonathan Toppins <jtoppins@cumulusnetworks.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35385 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751341AbbAST0S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Jan 2015 14:26:18 -0500
In-Reply-To: <1421423848-414-4-git-send-email-jtoppins@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/16/2015 04:57 PM, Jonathan Toppins wrote:
> From: Wilson Kok <wkok@cumulusnetworks.com>
> 
> This patch attempts to fix the following problems when an actor or
> partner's aggregator is not active:
>     1. a slave's lacp port state is marked as AD_STATE_SYNCHRONIZATION
>        even if it is attached to an inactive aggregator. LACP advertises
>        this state to the partner, making the partner think he can move
>        into COLLECTING_DISTRIBUTING state even though this link will not
>        pass traffic on the local side
> 
>     2. a slave goes into COLLECTING_DISTRIBUTING state without checking
>        if the aggregator is actually active
> 
>     3. when in COLLECTING_DISTRIBUTING state, the partner parameters may
>        change, e.g. the partner_oper_port_state.SYNCHRONIZATION. The
>        local mux machine is not reacting to the change and continue to
>        keep the slave and bond up
> 
>     4. When bond slave leaves an inactive aggregator and joins an active
>        aggregator, the actor oper port state need to update to SYNC state.
> 
> Cc: Andy Gospodarek <gospo@cumulusnetworks.com>
> Signed-off-by: Wilson Kok <wkok@cumulusnetworks.com>
> Signed-off-by: Jonathan Toppins <jtoppins@cumulusnetworks.com>
> ---
>  drivers/net/bonding/bond_3ad.c |   44 ++++++++++++++++++++++++++++++++--------
>  1 file changed, 35 insertions(+), 9 deletions(-)
> 
> diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
> index e9b706f..52a8772 100644
> --- a/drivers/net/bonding/bond_3ad.c
> +++ b/drivers/net/bonding/bond_3ad.c
> @@ -471,10 +471,13 @@ static void __record_pdu(struct lacpdu *lacpdu, struct port *port)
>  		 * and the port is matched
>  		 */
>  		if ((port->sm_vars & AD_PORT_MATCHED)
> -		    && (lacpdu->actor_state & AD_STATE_SYNCHRONIZATION))
> +			&& (lacpdu->actor_state & AD_STATE_SYNCHRONIZATION)) {
In net/ it's preferred to have the logical operators at the end of the
previous line. It'd be nice if we start fixing these in bond_3ad.c since
they're being touched by the patch anyhow.

>  			partner->port_state |= AD_STATE_SYNCHRONIZATION;
> -		else
> +			pr_debug("%s partner sync=1\n", port->slave->dev->name);
> +		} else {
>  			partner->port_state &= ~AD_STATE_SYNCHRONIZATION;
> +			pr_debug("%s partner sync=0\n", port->slave->dev->name);
> +		}
>  	}
>  }
>  
> @@ -729,6 +732,8 @@ static inline void __update_lacpdu_from_port(struct port *port)
>  	lacpdu->actor_port_priority = htons(port->actor_port_priority);
>  	lacpdu->actor_port = htons(port->actor_port_number);
>  	lacpdu->actor_state = port->actor_oper_port_state;
> +	pr_debug("update lacpdu: %s, actor port state %x\n",
> +		 port->slave->dev->name, port->actor_oper_port_state);
>  
>  	/* lacpdu->reserved_3_1              initialized
>  	 * lacpdu->tlv_type_partner_info     initialized
> @@ -901,7 +906,9 @@ static void ad_mux_machine(struct port *port, bool *update_slave_arr)
>  			if ((port->sm_vars & AD_PORT_SELECTED) &&
>  			    (port->partner_oper.port_state & AD_STATE_SYNCHRONIZATION) &&
>  			    !__check_agg_selection_timer(port)) {
> -				port->sm_mux_state = AD_MUX_COLLECTING_DISTRIBUTING;
> +				if (port->aggregator->is_active)
> +					port->sm_mux_state =
> +					    AD_MUX_COLLECTING_DISTRIBUTING;
>  			} else if (!(port->sm_vars & AD_PORT_SELECTED) ||
>  				   (port->sm_vars & AD_PORT_STANDBY)) {
>  				/* if UNSELECTED or STANDBY */
> @@ -913,12 +920,18 @@ static void ad_mux_machine(struct port *port, bool *update_slave_arr)
>  				 */
>  				__set_agg_ports_ready(port->aggregator, __agg_ports_are_ready(port->aggregator));
>  				port->sm_mux_state = AD_MUX_DETACHED;
> +			} else if (port->aggregator->is_active) {
> +				port->actor_oper_port_state |=
> +				    AD_STATE_SYNCHRONIZATION;
>  			}
>  			break;
>  		case AD_MUX_COLLECTING_DISTRIBUTING:
>  			if (!(port->sm_vars & AD_PORT_SELECTED) ||
>  			    (port->sm_vars & AD_PORT_STANDBY) ||
> -			    !(port->partner_oper.port_state & AD_STATE_SYNCHRONIZATION)) {
> +			    !(port->partner_oper.port_state &
> +				AD_STATE_SYNCHRONIZATION) ||
> +			    !(port->actor_oper_port_state &
> +				AD_STATE_SYNCHRONIZATION)) {
IMO this one looks a bit confusing when broken up like that.

>  				port->sm_mux_state = AD_MUX_ATTACHED;
>  			} else {
>  				/* if port state hasn't changed make
> @@ -940,8 +953,10 @@ static void ad_mux_machine(struct port *port, bool *update_slave_arr)
>  
>  	/* check if the state machine was changed */
>  	if (port->sm_mux_state != last_state) {
> -		pr_debug("Mux Machine: Port=%d, Last State=%d, Curr State=%d\n",
> -			 port->actor_port_number, last_state,
> +		pr_debug("Mux Machine: Port=%d (%s), Last State=%d, Curr State=%d\n",
> +			 port->actor_port_number,
> +			 port->slave->dev->name,
> +			 last_state,
>  			 port->sm_mux_state);
>  		switch (port->sm_mux_state) {
>  		case AD_MUX_DETACHED:
> @@ -956,7 +971,12 @@ static void ad_mux_machine(struct port *port, bool *update_slave_arr)
>  			port->sm_mux_timer_counter = __ad_timer_to_ticks(AD_WAIT_WHILE_TIMER, 0);
>  			break;
>  		case AD_MUX_ATTACHED:
> -			port->actor_oper_port_state |= AD_STATE_SYNCHRONIZATION;
> +			if (port->aggregator->is_active)
> +				port->actor_oper_port_state |=
> +				    AD_STATE_SYNCHRONIZATION;
> +			else
> +				port->actor_oper_port_state &=
> +				    ~AD_STATE_SYNCHRONIZATION;
>  			port->actor_oper_port_state &= ~AD_STATE_COLLECTING;
>  			port->actor_oper_port_state &= ~AD_STATE_DISTRIBUTING;
>  			ad_disable_collecting_distributing(port,
> @@ -966,6 +986,7 @@ static void ad_mux_machine(struct port *port, bool *update_slave_arr)
>  		case AD_MUX_COLLECTING_DISTRIBUTING:
>  			port->actor_oper_port_state |= AD_STATE_COLLECTING;
>  			port->actor_oper_port_state |= AD_STATE_DISTRIBUTING;
> +			port->actor_oper_port_state |= AD_STATE_SYNCHRONIZATION;
>  			ad_enable_collecting_distributing(port,
>  							  update_slave_arr);
>  			port->ntt = true;
> @@ -1047,8 +1068,10 @@ static void ad_rx_machine(struct lacpdu *lacpdu, struct port *port)
>  
>  	/* check if the State machine was changed or new lacpdu arrived */
>  	if ((port->sm_rx_state != last_state) || (lacpdu)) {
> -		pr_debug("Rx Machine: Port=%d, Last State=%d, Curr State=%d\n",
> -			 port->actor_port_number, last_state,
> +		pr_debug("Rx Machine: Port=%d (%s), Last State=%d, Curr State=%d\n",
> +			 port->actor_port_number,
> +			 port->slave->dev->name,
> +			 last_state,
>  			 port->sm_rx_state);
>  		switch (port->sm_rx_state) {
>  		case AD_RX_INITIALIZE:
> @@ -1397,6 +1420,9 @@ static void ad_port_selection_logic(struct port *port, bool *update_slave_arr)
>  
>  	aggregator = __get_first_agg(port);
>  	ad_agg_selection_logic(aggregator, update_slave_arr);
> +
> +	if (!port->aggregator->is_active)
> +		port->actor_oper_port_state &= ~AD_STATE_SYNCHRONIZATION;
>  }
>  
>  /* Decide if "agg" is a better choice for the new active aggregator that
> 
