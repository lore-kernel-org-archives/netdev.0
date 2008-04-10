From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [PATCH] net/bonding: Send more than one gratuitous ARP when slave takes over
Date: Thu, 10 Apr 2008 12:51:26 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC32904DEAE99@orsmsx414.amr.corp.intel.com>
References: <47FE2D2D.2040504@voltaire.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev" <netdev@vger.kernel.org>,
	"Olga Stern" <olgas@voltaire.com>,
	"Or Gerlitz" <ogerlitz@voltaire.com>
To: <monis@voltaire.com>, "Jay Vosburgh" <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:28063 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754605AbYDJT73 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Apr 2008 15:59:29 -0400
Content-class: urn:content-classes:message
In-Reply-To: <47FE2D2D.2040504@voltaire.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> @@ -104,6 +105,8 @@ struct bond_params bonding_defaults;
>  
> module_param(max_bonds, int, 0);
> MODULE_PARM_DESC(max_bonds, "Max number of bonded devices");
> +module_param(num_grat_arp, int, 0644);
> +MODULE_PARM_DESC(num_grat_arp, "Number of gratuitous ARP packet to
sned on failover");

Check your spelling here.  s/sned/send/

Also, num_grat_arp is declared int, where send_grat_arp is s8.  What
happens if you overflow send_grat_arp?  Either your module parameter
needs to change to match what's in the bonding struct, or you needs some
bounds checking to validate your inputs.

> @@ -1109,14 +1112,16 @@ void bond_change_active_slave(struct bon
> 		if (new_active && bond->params.fail_over_mac)
> 			memcpy(bond->dev->dev_addr,
new_active->dev->dev_addr,
> 				new_active->dev->addr_len);
> +		bond->send_grat_arp = num_grat_arp;
> 		if (bond->curr_active_slave &&
>  			test_bit(__LINK_STATE_LINKWATCH_PENDING,
> -
&bond->curr_active_slave->dev->state)) {
> +
&bond->curr_active_slave->dev->state))
> 			dprintk("delaying gratuitous arp on %s\n",
> 				bond->curr_active_slave->dev->name);
> -			bond->send_grat_arp = 1;
> -		} else
> +		else {
> 			bond_send_gratuitous_arp(bond);
> +			bond->send_grat_arp--;
> +		}

Don't modify the if () else () formatting here.  Kernel coding
guidelines read if any part of your if/else statement requires braces,
all sections need braces.  So it still should be, with your changes:

		if (bond->curr_active_slave &&
			test_bit(__LINK_STATE_LINKWATCH_PENDING,
	
&bond->curr_active_slave->dev->state)) {
			dprintk("delaying gratuitous arp on %s\n",
				bond->curr_active_slave->dev->name);
		} else {
			bond_send_gratuitious_arp(bond);
			bond->send_grat_arp--;
		}

> @@ -2144,7 +2149,7 @@ static int __bond_mii_monitor(struct bon
>  			dprintk("sending delayed gratuitous arp on on
%s\n",
>  				bond->curr_active_slave->dev->name);
>  			bond_send_gratuitous_arp(bond);
> -			bond->send_grat_arp = 0;
> +			bond->send_grat_arp--;

Can this ever cause send_grat_arp to become less than zero?  What will
happen if it does drop below zero?  I think some bounds checking might
be needed here.

Cheers,
-PJ Waskiewicz
