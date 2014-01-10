From: "Williams, Mitch A" <mitch.a.williams@intel.com>
Subject: RE: [net-next 05/15] i40e: add a comment on barrier and fix panic
 on reset
Date: Fri, 10 Jan 2014 17:34:39 +0000
Message-ID: <AAEA33E297BCAC4B9BB20A7C2DF0AB8D654F03A0@FMSMSX113.amr.corp.intel.com>
References: <1389271944-26227-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1389271944-26227-6-git-send-email-jeffrey.t.kirsher@intel.com>
 <5B8599B2-AE3C-4E03-8EDF-8F35894E9CC3@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>,
	"Rose, Gregory V" <gregory.v.rose@intel.com>,
	Netdev <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>
To: Scott Feldman <sfeldma@cumulusnetworks.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:40073 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751208AbaAJRfI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jan 2014 12:35:08 -0500
In-Reply-To: <5B8599B2-AE3C-4E03-8EDF-8F35894E9CC3@cumulusnetworks.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: Scott Feldman [mailto:sfeldma@cumulusnetworks.com]
> Sent: Thursday, January 09, 2014 2:17 PM
> To: Kirsher, Jeffrey T
> Cc: David Miller; Rose, Gregory V; Netdev; gospo@redhat.com;
> sassmann@redhat.com; Williams, Mitch A; Brandeburg, Jesse
> Subject: Re: [net-next 05/15] i40e: add a comment on barrier and fix panic
> on reset
> 
> 
> On Jan 9, 2014, at 4:52 AM, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> wrote:
> 
> > From: Greg Rose <gregory.v.rose@intel.com>
> >
> > diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c
> b/drivers/net/ethernet/intel/i40e/i40e_main.c
> > index ea76134..5cdc67c 100644
> > --- a/drivers/net/ethernet/intel/i40e/i40e_main.c
> > +++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
> > @@ -422,7 +422,7 @@ void i40e_vsi_reset_stats(struct i40e_vsi *vsi)
> > 	memset(&vsi->net_stats_offsets, 0, sizeof(vsi->net_stats_offsets));
> > 	memset(&vsi->eth_stats, 0, sizeof(vsi->eth_stats));
> > 	memset(&vsi->eth_stats_offsets, 0, sizeof(vsi->eth_stats_offsets));
> > -	if (vsi->rx_rings)
> > +	if (vsi->rx_rings && vsi->rx_rings[0]) {
> 
> Any reason why just [0] is checked for !NULL here...
> 
> > 		for (i = 0; i < vsi->num_queue_pairs; i++) {
> > 			memset(&vsi->rx_rings[i]->stats, 0 ,
> > 			       sizeof(vsi->rx_rings[i]->stats));
> > @@ -433,6 +433,7 @@ void i40e_vsi_reset_stats(struct i40e_vsi *vsi)
> > 			memset(&vsi->tx_rings[i]->tx_stats, 0,
> > 			       sizeof(vsi->tx_rings[i]->tx_stats));
> > 		}
> > +	}
> > 	vsi->stat_offsets_loaded = false;
> > }
> >
> > @@ -2101,8 +2105,11 @@ static void i40e_vsi_free_rx_resources(struct
> i40e_vsi *vsi)
> > {
> > 	int i;
> >
> > +	if (!vsi->rx_rings)
> > +		return;
> > +
> > 	for (i = 0; i < vsi->num_queue_pairs; i++)
> > -		if (vsi->rx_rings[i]->desc)
> > +		if (vsi->rx_rings[i] && vsi->rx_rings[i]->desc)
> 
> but here every [i] is checked for !NULL here?
> 
> > 			i40e_free_rx_resources(vsi->rx_rings[i]);
> > }
> >
> 
> If [0] check is sufficient to know if array members are allocated, maybe an
> wrapper func would help document intent:
> 
> static bool i40e_vsi_rings_allocated(struct i40e_ring *ring)
> {
> 	return (ring && ring[0]);
> }
> 
> -scott
The assumption in vsi_reset_stats() is that the device is up and running normally, in which case all of the rings will be allocated, so we only need to check the first one.

OTOH, in free_rx_resources can be called in case of an allocation failure, in which case you could conceivably have some rings allocated and some not.

-Mitch
