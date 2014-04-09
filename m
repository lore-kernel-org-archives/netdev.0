From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [PATCH v2] net: cpsw: fix dual_emac VLAN issue
Date: Wed, 9 Apr 2014 18:39:38 +0530
Message-ID: <53454692.309@ti.com>
References: <1397048023-10522-1-git-send-email-yegorslists@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
To: <yegorslists@googlemail.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:60731 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932674AbaDINJl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Apr 2014 09:09:41 -0400
In-Reply-To: <1397048023-10522-1-git-send-email-yegorslists@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 09 April 2014 06:23 PM, yegorslists@googlemail.com wrote:
> From: Yegor Yefremov <yegorslists@googlemail.com>
>
> dual_emac mode was first introduced in TI's PSP kernel 3.2.
> See repository git://arago-project.org/git/projects/linux-am33x.git
> commit 6afa003a0b06a0376c941436b38204ba2edc4a98.
>
> Since commit d9ba8f9e6298af71ec1c1fd3d88c3ef68abd0ec3 dual_emac
> feature was upstreamed, but with some changes compared to the original
> source, that led to following behavior:
>
> Some stations in LAN don't answer CPSW's ARP request. PSP kernel 3.2
> could talk to all stations in the same LAN.
>
> Use the same cpsw_ale_add_vlan procedure as in PSP kernel 3.2 to fix
> this regression.
>
> Signed-off-by: Yegor Yefremov <yegorslists@googlemail.com>
> CC: Mugunthan V N <mugunthanvnm@ti.com>
> ---
> Changes:
> 	v2: make more detailed description
>
>  drivers/net/ethernet/ti/cpsw.c |    4 +++-
>  1 files changed, 3 insertions(+), 1 deletions(-)
>
> diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
> index 5d5fec6..aa06370 100644
> --- a/drivers/net/ethernet/ti/cpsw.c
> +++ b/drivers/net/ethernet/ti/cpsw.c
> @@ -1040,11 +1040,13 @@ static inline void cpsw_add_dual_emac_def_ale_entries(
>  	else
>  		slave_write(slave, slave->port_vlan, CPSW2_PORT_VLAN);
>  	cpsw_ale_add_vlan(priv->ale, slave->port_vlan, port_mask,
> -			  port_mask, port_mask, 0);
> +			  0, port_mask, port_mask);

Dual EMAC VLAN must be untagged on egress and why you need unregistered
multicast packet to be passed to CPU?

>  	cpsw_ale_add_mcast(priv->ale, priv->ndev->broadcast,
>  			   port_mask, ALE_VLAN, slave->port_vlan, 0);
>  	cpsw_ale_add_ucast(priv->ale, priv->mac_addr,
>  		priv->host_port, ALE_VLAN, slave->port_vlan);
> +	cpsw_ale_add_vlan(priv->ale, 0, ALE_ALL_PORTS << priv->host_port,
> +		ALE_ALL_PORTS << priv->host_port, priv->host_port, 0);

Vlan ID 0 must not be used, cpsw default vlan id should be used,
currently 0 is used as default VLAN for internal packet switching, in
case some one using different default vlan id, then this fix will break.

I have fixed the issue already and submitted a patch.
http://patchwork.ozlabs.org/patch/337769/

Regards
Mugunthan V N
