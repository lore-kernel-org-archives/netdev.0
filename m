From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH next v4 3/6] bonding: Implement port churn-machine (AD
 standard 43.4.17).
Date: Wed, 18 Feb 2015 13:41:07 +0100
Message-ID: <54E48863.9050809@redhat.com>
References: <1424243872-27071-1-git-send-email-maheshb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Maciej Zenczykowski <maze@google.com>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>
To: Mahesh Bandewar <maheshb@google.com>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Veaceslav Falico <vfalico@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52857 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751649AbbBRMlT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Feb 2015 07:41:19 -0500
In-Reply-To: <1424243872-27071-1-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/18/2015 08:17 AM, Mahesh Bandewar wrote:
> The Churn Detection machines detect the situation where a port is operable,
> but the Actor and Partner have not attached the link to an Aggregator and
> brought the link into operation within a bound time period. Under normal
> operation of the LACP, agreement between Actor and Partner should be reached
> very rapidly. Continued failure to reach agreement can be symptomatic of
> device failure.
> 
> Actor-churn-detection state-machine
> ===================================
> 
> BEGIN=True + PortEnable=False
>            |
>            v
>  +------------------------+   ActorPort.Sync=True  +------------------+
>  |   ACTOR_CHURN_MONITOR  | ---------------------> |  NO_ACTOR_CHURN  |
>  |========================|                        |==================|
>  |    ActorChurn=False    |  ActorPort.Sync=False  | ActorChurn=False |
>  | ActorChurn.Timer=Start | <--------------------- |                  |
>  +------------------------+                        +------------------+
>            |                                                ^
>            |                                                |
>   ActorChurn.Timer=Expired                                  |
>            |                                       ActorPort.Sync=True
>            |                                                |
>            |                +-----------------+             |
>            |                |   ACTOR_CHURN   |             |
>            |                |=================|             |
>            +--------------> | ActorChurn=True | ------------+
>                             |                 |
>                             +-----------------+
> 
> Similar for the Partner-churn-detection.
> 
> Signed-off-by: Mahesh Bandewar <maheshb@google.com>
> ---
> v1:
>   Initial version
> v2-v4:
>   Rebase
> 
>  drivers/net/bonding/bond_3ad.c    | 56 +++++++++++++++++++++++++++++++++++++--
>  drivers/net/bonding/bond_procfs.c | 40 +++++++++++++++++++++++++---
>  include/net/bond_3ad.h            | 29 ++++++++++++++++++++
>  3 files changed, 119 insertions(+), 6 deletions(-)
> 
> diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
> index 9b436696b95e..c728ece78154 100644
> --- a/drivers/net/bonding/bond_3ad.c
> +++ b/drivers/net/bonding/bond_3ad.c
> @@ -38,6 +38,7 @@
>  #define AD_STANDBY                 0x2
>  #define AD_MAX_TX_IN_SECOND        3
>  #define AD_COLLECTOR_MAX_DELAY     0
> +#define AD_MONITOR_CHURNED         0x1000
>  
>  /* Timer definitions (43.4.4 in the 802.3ad standard) */
>  #define AD_FAST_PERIODIC_TIME      1
> @@ -1013,16 +1014,19 @@ static void ad_rx_machine(struct lacpdu *lacpdu, struct port *port)
>  	/* check if state machine should change state */
>  
>  	/* first, check if port was reinitialized */
> -	if (port->sm_vars & AD_PORT_BEGIN)
> +	if (port->sm_vars & AD_PORT_BEGIN) {
>  		port->sm_rx_state = AD_RX_INITIALIZE;
> +		port->sm_vars |= AD_MONITOR_CHURNED;
>  	/* check if port is not enabled */
> -	else if (!(port->sm_vars & AD_PORT_BEGIN)
> +	} else if (!(port->sm_vars & AD_PORT_BEGIN)
>  		 && !port->is_enabled && !(port->sm_vars & AD_PORT_MOVED))
>  		port->sm_rx_state = AD_RX_PORT_DISABLED;
>  	/* check if new lacpdu arrived */
>  	else if (lacpdu && ((port->sm_rx_state == AD_RX_EXPIRED) ||
>  		 (port->sm_rx_state == AD_RX_DEFAULTED) ||
>  		 (port->sm_rx_state == AD_RX_CURRENT))) {
> +		if (port->sm_rx_state != AD_RX_CURRENT)
> +			port->sm_vars |= AD_MONITOR_CHURNED;
>  		port->sm_rx_timer_counter = 0;
>  		port->sm_rx_state = AD_RX_CURRENT;
>  	} else {
> @@ -1100,9 +1104,11 @@ static void ad_rx_machine(struct lacpdu *lacpdu, struct port *port)
>  			 */
>  			port->partner_oper.port_state &= ~AD_STATE_SYNCHRONIZATION;
>  			port->sm_vars &= ~AD_PORT_MATCHED;
> +			port->partner_oper.port_state |= AD_STATE_LACP_TIMEOUT;
>  			port->partner_oper.port_state |= AD_STATE_LACP_ACTIVITY;
>  			port->sm_rx_timer_counter = __ad_timer_to_ticks(AD_CURRENT_WHILE_TIMER, (u16)(AD_SHORT_TIMEOUT));
>  			port->actor_oper_port_state |= AD_STATE_EXPIRED;
> +			port->sm_vars |= AD_MONITOR_CHURNED;
>  			break;
>  		case AD_RX_DEFAULTED:
>  			__update_default_selected(port);
> @@ -1131,6 +1137,44 @@ static void ad_rx_machine(struct lacpdu *lacpdu, struct port *port)
>  	}
>  }
>  
> +/* ad_churn_machine - handle port churn's state machine
> + * @port: the port we're looking at
> + *
> + */
> +static void ad_churn_machine(struct port *port)
> +{
> +	if (port->sm_vars & AD_MONITOR_CHURNED) {
> +		port->sm_vars &= ~AD_MONITOR_CHURNED;
> +		port->sm_churn_actor_state = AD_CHURN_MONITOR;
> +		port->sm_churn_partner_state = AD_CHURN_MONITOR;
> +		port->sm_churn_actor_timer_counter =
> +			__ad_timer_to_ticks(AD_ACTOR_CHURN_TIMER, 0);
> +		 port->sm_churn_partner_timer_counter =
> +			 __ad_timer_to_ticks(AD_PARTNER_CHURN_TIMER, 0);
> +		return;
> +	}
> +	if (port->sm_churn_actor_timer_counter &&
> +		!(--port->sm_churn_actor_timer_counter) &&
> +		(port->sm_churn_actor_state == AD_CHURN_MONITOR)) {
^^^^^^^
These are too indented, also you can drop the () around:
(port->sm_churn_actor_state == AD_CHURN_MONITOR)

> +		if (port->actor_oper_port_state & AD_STATE_SYNCHRONIZATION) {
> +			port->sm_churn_actor_state = AD_NO_CHURN;
> +		} else {
> +			port->churn_actor_count++;
> +			port->sm_churn_actor_state = AD_CHURN;
> +		}
> +	}
> +	if (port->sm_churn_partner_timer_counter &&
> +		!(--port->sm_churn_partner_timer_counter) &&
> +		(port->sm_churn_partner_state == AD_CHURN_MONITOR)) {
^^^^^^^
Same here.

> +		if (port->partner_oper.port_state & AD_STATE_SYNCHRONIZATION) {
> +			port->sm_churn_partner_state = AD_NO_CHURN;
> +		} else {
> +			port->churn_partner_count++;
> +			port->sm_churn_partner_state = AD_CHURN;
> +		}
> +	}
> +}
> +
>  /**
>   * ad_tx_machine - handle a port's tx state machine
>   * @port: the port we're looking at
> @@ -1745,6 +1789,13 @@ static void ad_initialize_port(struct port *port, int lacp_fast)
>  		port->next_port_in_aggregator = NULL;
>  		port->transaction_id = 0;
>  
> +		port->sm_churn_actor_timer_counter = 0;
> +		port->sm_churn_actor_state = 0;
> +		port->churn_actor_count = 0;
> +		port->sm_churn_partner_timer_counter = 0;
> +		port->sm_churn_partner_state = 0;
> +		port->churn_partner_count = 0;
> +
>  		memcpy(&port->lacpdu, &lacpdu, sizeof(lacpdu));
>  	}
>  }
> @@ -2164,6 +2215,7 @@ void bond_3ad_state_machine_handler(struct work_struct *work)
>  		ad_port_selection_logic(port, &update_slave_arr);
>  		ad_mux_machine(port, &update_slave_arr);
>  		ad_tx_machine(port);
> +		ad_churn_machine(port);
>  
>  		/* turn off the BEGIN bit, since we already handled it */
>  		if (port->sm_vars & AD_PORT_BEGIN)
> diff --git a/drivers/net/bonding/bond_procfs.c b/drivers/net/bonding/bond_procfs.c
> index 976f5ad2a0f2..83095a0b4b90 100644
> --- a/drivers/net/bonding/bond_procfs.c
> +++ b/drivers/net/bonding/bond_procfs.c
> @@ -178,13 +178,45 @@ static void bond_info_show_slave(struct seq_file *seq,
>  	seq_printf(seq, "Permanent HW addr: %pM\n", slave->perm_hwaddr);
>  
>  	if (BOND_MODE(bond) == BOND_MODE_8023AD) {
> -		const struct aggregator *agg
> -			= SLAVE_AD_INFO(slave)->port.aggregator;
> +		const struct port *port = &SLAVE_AD_INFO(slave)->port;
> +		const struct aggregator *agg = port->aggregator;
>  
> -		if (agg)
> +		if (agg) {
>  			seq_printf(seq, "Aggregator ID: %d\n",
>  				   agg->aggregator_identifier);
> -		else
> +			seq_printf(seq, "Actor Churn State: %s\n",
> +				   bond_3ad_churn_desc(port->sm_churn_actor_state));
> +			seq_printf(seq, "Partner Churn State: %s\n",
> +				   bond_3ad_churn_desc(port->sm_churn_partner_state));
> +			seq_printf(seq, "Actor Churned Count: %d\n",
> +				   port->churn_actor_count);
> +			seq_printf(seq, "Partner Churned Count: %d\n",
> +				   port->churn_partner_count);
> +
> +			seq_puts(seq, "details actor lacp pdu:\n");
> +			seq_printf(seq, "    system priority: %d\n",
> +				   port->actor_system_priority);
> +			seq_printf(seq, "    port key: %d\n",
> +				   port->actor_oper_port_key);
> +			seq_printf(seq, "    port priority: %d\n",
> +				   port->actor_port_priority);
> +			seq_printf(seq, "    port number: %d\n",
> +				   port->actor_port_number);
> +			seq_printf(seq, "    port state: %d\n",
> +				   port->actor_oper_port_state);
> +
> +			seq_puts(seq, "details partner lacp pdu:\n");
> +			seq_printf(seq, "    system priority: %d\n",
> +				   port->partner_oper.system_priority);
> +			seq_printf(seq, "    oper key: %d\n",
> +				   port->partner_oper.key);
> +			seq_printf(seq, "    port priority: %d\n",
> +				   port->partner_oper.port_priority);
> +			seq_printf(seq, "    port number: %d\n",
> +				   port->partner_oper.port_number);
> +			seq_printf(seq, "    port state: %d\n",
> +				   port->partner_oper.port_state);
> +		} else
>  			seq_puts(seq, "Aggregator ID: N/A\n");
^^^^^^^^^^^^^^^^^^^^
"else" part should also have curly braces.

>  	}
>  	seq_printf(seq, "Slave queue ID: %d\n", slave->queue_id);
> diff --git a/include/net/bond_3ad.h b/include/net/bond_3ad.h
> index f04cdbb7848e..22ac75dd8bd5 100644
> --- a/include/net/bond_3ad.h
> +++ b/include/net/bond_3ad.h
> @@ -82,6 +82,13 @@ typedef enum {
>  	AD_TRANSMIT		/* tx Machine */
>  } tx_states_t;
>  
> +/* churn machine states(43.4.17 in the 802.3ad standard) */
> +typedef enum {
> +	 AD_CHURN_MONITOR, /* monitoring for churn */
> +	 AD_CHURN,         /* churn detected (error) */
> +	 AD_NO_CHURN       /* no churn (no error) */
> +} churn_state_t;
> +
>  /* rx indication types */
>  typedef enum {
>  	AD_TYPE_LACPDU = 1,	/* type lacpdu */
> @@ -229,6 +236,12 @@ typedef struct port {
>  	u16 sm_mux_timer_counter;	/* state machine mux timer counter */
>  	tx_states_t sm_tx_state;	/* state machine tx state */
>  	u16 sm_tx_timer_counter;	/* state machine tx timer counter(allways on - enter to transmit state 3 time per second) */
> +	u16 sm_churn_actor_timer_counter;
> +	u16 sm_churn_partner_timer_counter;
> +	u32 churn_actor_count;
> +	u32 churn_partner_count;
> +	churn_state_t sm_churn_actor_state;
> +	churn_state_t sm_churn_partner_state;
>  	struct slave *slave;		/* pointer to the bond slave that this port belongs to */
>  	struct aggregator *aggregator;	/* pointer to an aggregator that this port related to */
>  	struct port *next_port_in_aggregator;	/* Next port on the linked list of the parent aggregator */
> @@ -262,6 +275,22 @@ struct ad_slave_info {
>  	u16 id;
>  };
>  
> +static inline const char *bond_3ad_churn_desc(churn_state_t state)
> +{
> +	static const char *const churn_description[] =
> +		{ "monitoring",
> +		  "churned",
> +		  "none",
> +		  "unknown"
> +		};
> +	int max_size = sizeof(churn_description) / sizeof(churn_description[0]);
> +
> +	if (state >= max_size)
> +		state = max_size - 1;
> +
> +	return churn_description[state];
> +}
> +
>  /* ========== AD Exported functions to the main bonding code ========== */
>  void bond_3ad_initialize(struct bonding *bond, u16 tick_resolution);
>  void bond_3ad_bind_slave(struct slave *slave);
> 
