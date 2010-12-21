From: Flavio Leitner <fleitner@redhat.com>
Subject: Re: [PATCH net-2.6 2/3] bonding: Change active slave quietly when
 bond is down
Date: Tue, 21 Dec 2010 00:46:08 -0200
Message-ID: <20101221024608.GA5944@redhat.com>
References: <1292264216.9860.11.camel@bwh-desktop>
 <1292264396.9860.14.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Jay Vosburgh <fubar@us.ibm.com>, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:28356 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933446Ab0LUCqP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Dec 2010 21:46:15 -0500
Content-Disposition: inline
In-Reply-To: <1292264396.9860.14.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 13, 2010 at 06:19:56PM +0000, Ben Hutchings wrote:
> bond_change_active_slave() may be called when a slave is added, even
> if the bond has not been brought up yet.  It may then attempt to send
> packets, and further it may use mcast_work which is uninitialised
> before the bond is brought up.  Add the necessary checks for
> netif_running(bond->dev).
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> ---
>  drivers/net/bonding/bond_main.c |   15 +++++++++------
>  1 files changed, 9 insertions(+), 6 deletions(-)
> 
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> index ef370c9..3b16c34 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -1178,11 +1178,13 @@ void bond_change_active_slave(struct bonding *bond, struct slave *new_active)
>  				bond_do_fail_over_mac(bond, new_active,
>  						      old_active);
>  
> -			bond->send_grat_arp = bond->params.num_grat_arp;
> -			bond_send_gratuitous_arp(bond);
> +			if (netif_running(bond->dev)) {
> +				bond->send_grat_arp = bond->params.num_grat_arp;
> +				bond_send_gratuitous_arp(bond);
>  
> -			bond->send_unsol_na = bond->params.num_unsol_na;
> -			bond_send_unsolicited_na(bond);
> +				bond->send_unsol_na = bond->params.num_unsol_na;
> +				bond_send_unsolicited_na(bond);
> +			}
>  
>  			write_unlock_bh(&bond->curr_slave_lock);
>  			read_unlock(&bond->lock);
> @@ -1196,8 +1198,9 @@ void bond_change_active_slave(struct bonding *bond, struct slave *new_active)
>  
>  	/* resend IGMP joins since active slave has changed or
>  	 * all were sent on curr_active_slave */
> -	if ((USES_PRIMARY(bond->params.mode) && new_active) ||
> -	    bond->params.mode == BOND_MODE_ROUNDROBIN) {
> +	if (((USES_PRIMARY(bond->params.mode) && new_active) ||
> +	     bond->params.mode == BOND_MODE_ROUNDROBIN) &&
> +	    netif_running(bond->dev)) {
>  		bond->igmp_retrans = bond->params.resend_igmp;
>  		queue_delayed_work(bond->wq, &bond->mcast_work, 0);
>  	}
> -- 
> 1.7.3.2

I had a script randomly adding/removing slaves and setting
the bonding device up and down to test that commit, so
I'm surprised that it didn't catch this combination before.

Acked-by: Flavio Leitner <fleitner@redhat.com>

Thanks,
-- 
Flavio
