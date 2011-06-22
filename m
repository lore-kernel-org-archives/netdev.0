From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [PATCH net-next] bonding: add min links parameter to 802.3ad
Date: Wed, 22 Jun 2011 15:50:05 -0400
Message-ID: <20110622195004.GN21309@gospo.rdu.redhat.com>
References: <20110622105408.06fd4788@nehalam.ftrdhcpuser.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:28957 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758594Ab1FVTuM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jun 2011 15:50:12 -0400
Content-Disposition: inline
In-Reply-To: <20110622105408.06fd4788@nehalam.ftrdhcpuser.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 22, 2011 at 10:54:08AM -0700, Stephen Hemminger wrote:
> This adds support for a configuring the minimum number of links that
> must be active before asserting carrier. It is similar to the Cisco
> EtherChannel min-links feature. This allows setting the minimum number
> of member ports that must be up (link-up state) before marking the
> bond device as up (carrier on). This is useful for situations where
> higher level services such as clustering want to ensure a minimum
> number of low bandwidth links are active before switchover.
> 
> This is a prototype, did some basic testing but has not been
> tested with other switches.
> 
> See:
>    http://bugzilla.vyatta.com/show_bug.cgi?id=7196
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
[...]
> --- a/drivers/net/bonding/bond_3ad.c	2011-06-22 08:43:25.599999586 -0700
> +++ b/drivers/net/bonding/bond_3ad.c	2011-06-22 09:44:11.815997557 -0700
> @@ -2342,8 +2342,12 @@ void bond_3ad_handle_link_change(struct
>   */
>  int bond_3ad_set_carrier(struct bonding *bond)
>  {
> -	if (__get_active_agg(&(SLAVE_AD_INFO(bond->first_slave).aggregator))) {
> -		if (!netif_carrier_ok(bond->dev)) {
> +	struct aggregator *active;
> +
> +	active = __get_active_agg(&(SLAVE_AD_INFO(bond->first_slave).aggregator));
> +	if (active) {
> +		if (active->num_of_ports >= bond->params.min_links &&
> +		    !netif_carrier_ok(bond->dev)) {
>  			netif_carrier_on(bond->dev);
>  			return 1;
>  		}
> 

I agree with Flavio that it feels like there is a problem here.  I was
just wrestling with my switch and trying to get LACP working there so I
could test this.

