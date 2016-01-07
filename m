From: "Nelson, Shannon" <shannon.nelson@intel.com>
Subject: RE: [PATCH V2 5/5] i40e/ethtool: support coalesce setting by queue
Date: Thu, 7 Jan 2016 22:25:58 +0000
Message-ID: <FC41C24E35F18A40888AACA1A36F3E418AFE2A3B@fmsmsx115.amr.corp.intel.com>
References: <1451912041-8860-1-git-send-email-kan.liang@intel.com>
 <1451912041-8860-5-git-send-email-kan.liang@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"andi@firstfloor.org" <andi@firstfloor.org>,
	"f.fainelli@gmail.com" <f.fainelli@gmail.com>,
	"alexander.duyck@gmail.com" <alexander.duyck@gmail.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Wyborny, Carolyn" <carolyn.wyborny@intel.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"Williams, Mitch A" <mitch.a.williams@intel.com>,
	"ogerlitz@mellanox.com" <ogerlitz@mellanox.com>,
	"edumazet@google.com" <edumazet@google.com>,
	"jiri@mellanox.com" <jiri@mellanox.com>,
	"sfeldma@gmail.com" <sfeldma@gmail.com>,
	"gospo@cumulusnetworks.com" <gospo@cumulusnetworks.com>,
	"sasha.levin@oracle.com" <sasha.levin@oracle.com>,
	"dsahern@gmail.com" <dsahern@gmail.com>,
	"tj@kernel.org" <tj@kernel.org>,
	"cascardo@redhat.com" <cascardo@redhat.com>,
	"corbet@lwn.net" <corbet@lwn.net>,
	"ben@decadent.org.uk" <ben@decadent.org
To: "Liang, Kan" <kan.liang@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"bwh@kernel.org" <bwh@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:55696 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753366AbcAGW0A convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2016 17:26:00 -0500
In-Reply-To: <1451912041-8860-5-git-send-email-kan.liang@intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -	for (i = 0; i < vsi->num_q_vectors; i++, vector++) {
> -		u16 intrl = INTRL_USEC_TO_REG(vsi->int_rate_limit);
> +	if (queue < 0) {
> +		for (i = 0; i < vsi->num_q_vectors; i++, vector++) {
> +			intrl = INTRL_USEC_TO_REG(vsi->int_rate_limit);
> +
> +			q_vector = vsi->q_vectors[i];
> +			q_vector->rx.itr = ITR_TO_REG(vsi->rx_itr_setting);
> +			wr32(hw, I40E_PFINT_ITRN(0, vector - 1), q_vector-
> >rx.itr);
> +			q_vector->tx.itr = ITR_TO_REG(vsi->tx_itr_setting);
> +			wr32(hw, I40E_PFINT_ITRN(1, vector - 1), q_vector-
> >tx.itr);

Use I40E_RX_ITR and I40E_TX_ITR rather than the hardcoded 0 and 1

> +			wr32(hw, I40E_PFINT_RATEN(vector - 1), intrl);
> +			i40e_flush(hw);
> +		}
> +	} else {
> +		if (queue >= vsi->num_queue_pairs) {
> +			netif_info(pf, drv, netdev, "Invalid queue value, queue
> range is 0 - %d\n", vsi->num_queue_pairs - 1);
> +			return -EINVAL;
> +		}
> +		intrl = INTRL_USEC_TO_REG(vsi->int_rate_limit);
> 
> -		q_vector = vsi->q_vectors[i];
> +		q_vector = vsi->rx_rings[queue]->q_vector;
> +		vector = vsi->base_vector + q_vector->v_idx;
>  		q_vector->rx.itr = ITR_TO_REG(vsi->rx_itr_setting);
>  		wr32(hw, I40E_PFINT_ITRN(0, vector - 1), q_vector->rx.itr);
> +
> +		q_vector = vsi->tx_rings[queue]->q_vector;
> +		vector = vsi->base_vector + q_vector->v_idx;
>  		q_vector->tx.itr = ITR_TO_REG(vsi->tx_itr_setting);
>  		wr32(hw, I40E_PFINT_ITRN(1, vector - 1), q_vector->tx.itr);

Of course, we should have had the I40E_RX_ITR and I40E_TX_ITR here to begin with.

This looks reasonable, but be aware that since there's no concept of queue-specific settings in the driver proper, these settings will get lost on the next reset - see i40e_vsi_configure_msix().  A reset can be driven by a number of things such as MTU changes, LLDP events, tx timeout recovery, promiscuous on/off, and various other configuration changes.  This might not be acceptable for your needs.

sln
