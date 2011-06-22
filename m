From: Flavio Leitner <fbl@redhat.com>
Subject: Re: [PATCH net-next] bonding: add min links parameter to 802.3ad
Date: Wed, 22 Jun 2011 18:35:25 -0300
Message-ID: <4E02601D.1010406@redhat.com>
References: <20110622105408.06fd4788@nehalam.ftrdhcpuser.net>	<4E02452E.2030307@redhat.com> <20110622125439.44e47a2c@nehalam.ftrdhcpuser.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39134 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758574Ab1FVVfl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jun 2011 17:35:41 -0400
In-Reply-To: <20110622125439.44e47a2c@nehalam.ftrdhcpuser.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/22/2011 04:54 PM, Stephen Hemminger wrote:
> This adds support for a configuring the minimum number of links that
> must be active before asserting carrier. It is similar to the Cisco
> EtherChannel min-links feature. This allows setting the minimum number
> of member ports that must be up (link-up state) before marking the
> bond device as up (carrier on). This is useful for situations where
> higher level services such as clustering want to ensure a minimum
> number of low bandwidth links are active before switchover.
> 
> See:
>    http://bugzilla.vyatta.com/show_bug.cgi?id=7196
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> ---
> v2 - need to transition to carrier_off if insufficient number of links
>      and whitespace cleanup
> 
>  drivers/net/bonding/bond_3ad.c    |    8 ++++++--
>  drivers/net/bonding/bond_main.c   |    5 +++++
>  drivers/net/bonding/bond_procfs.c |    1 +
>  drivers/net/bonding/bond_sysfs.c  |   35 +++++++++++++++++++++++++++++++++++
>  drivers/net/bonding/bonding.h     |    1 +
>  5 files changed, 48 insertions(+), 2 deletions(-)
[...]
> --- a/drivers/net/bonding/bond_3ad.c	2011-06-22 08:43:25.599999586 -0700
> +++ b/drivers/net/bonding/bond_3ad.c	2011-06-22 12:51:43.431614028 -0700
> @@ -2342,8 +2342,17 @@ void bond_3ad_handle_link_change(struct
>   */
>  int bond_3ad_set_carrier(struct bonding *bond)
>  {
> -	if (__get_active_agg(&(SLAVE_AD_INFO(bond->first_slave).aggregator))) {
> -		if (!netif_carrier_ok(bond->dev)) {
> +	struct aggregator *active;
> +
> +	active = __get_active_agg(&(SLAVE_AD_INFO(bond->first_slave).aggregator));
> +	if (active) {
> +		/* are enough slaves available to consider link up? */
> +		if (active->num_of_ports < bond->params.min_links) {
> +			if (netif_carrier_ok(bond->dev)) {
> +				netif_carrier_off(bond->dev);
> +				return 1;
> +			}
> +		} else if (!netif_carrier_ok(bond->dev)) {
>  			netif_carrier_on(bond->dev);
>  			return 1;
>  		}

Looks good and works here, thanks!

Signed-off-by: Flavio Leitner <fbl@redhat.com>

fbl
