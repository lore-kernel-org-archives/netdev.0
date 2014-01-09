From: Scott Feldman <sfeldma@cumulusnetworks.com>
Subject: Re: [net-next 05/15] i40e: add a comment on barrier and fix panic on reset
Date: Thu, 9 Jan 2014 14:16:57 -0800
Message-ID: <5B8599B2-AE3C-4E03-8EDF-8F35894E9CC3@cumulusnetworks.com>
References: <1389271944-26227-1-git-send-email-jeffrey.t.kirsher@intel.com> <1389271944-26227-6-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0 (Mac OS X Mail 7.1 \(1827\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>,
	Greg Rose <gregory.v.rose@intel.com>,
	Netdev <netdev@vger.kernel.org>, gospo@redhat.com,
	sassmann@redhat.com, Mitch Williams <mitch.a.williams@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:36320 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752072AbaAIWRP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jan 2014 17:17:15 -0500
In-Reply-To: <1389271944-26227-6-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Jan 9, 2014, at 4:52 AM, Jeff Kirsher <jeffrey.t.kirsher@intel.com> wrote:

> From: Greg Rose <gregory.v.rose@intel.com>
> 
> diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
> index ea76134..5cdc67c 100644
> --- a/drivers/net/ethernet/intel/i40e/i40e_main.c
> +++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
> @@ -422,7 +422,7 @@ void i40e_vsi_reset_stats(struct i40e_vsi *vsi)
> 	memset(&vsi->net_stats_offsets, 0, sizeof(vsi->net_stats_offsets));
> 	memset(&vsi->eth_stats, 0, sizeof(vsi->eth_stats));
> 	memset(&vsi->eth_stats_offsets, 0, sizeof(vsi->eth_stats_offsets));
> -	if (vsi->rx_rings)
> +	if (vsi->rx_rings && vsi->rx_rings[0]) {

Any reason why just [0] is checked for !NULL here...

> 		for (i = 0; i < vsi->num_queue_pairs; i++) {
> 			memset(&vsi->rx_rings[i]->stats, 0 ,
> 			       sizeof(vsi->rx_rings[i]->stats));
> @@ -433,6 +433,7 @@ void i40e_vsi_reset_stats(struct i40e_vsi *vsi)
> 			memset(&vsi->tx_rings[i]->tx_stats, 0,
> 			       sizeof(vsi->tx_rings[i]->tx_stats));
> 		}
> +	}
> 	vsi->stat_offsets_loaded = false;
> }
> 
> @@ -2101,8 +2105,11 @@ static void i40e_vsi_free_rx_resources(struct i40e_vsi *vsi)
> {
> 	int i;
> 
> +	if (!vsi->rx_rings)
> +		return;
> +
> 	for (i = 0; i < vsi->num_queue_pairs; i++)
> -		if (vsi->rx_rings[i]->desc)
> +		if (vsi->rx_rings[i] && vsi->rx_rings[i]->desc)

but here every [i] is checked for !NULL here?

> 			i40e_free_rx_resources(vsi->rx_rings[i]);
> }
> 

If [0] check is sufficient to know if array members are allocated, maybe an wrapper func would help document intent:

static bool i40e_vsi_rings_allocated(struct i40e_ring *ring)
{
	return (ring && ring[0]);
}

-scott
