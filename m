From: "Rose, Gregory V" <gregory.v.rose@intel.com>
Subject: RE: [RFC PATCH v2 04/12] ixgbevf: Driver main and ethool interface
 module and main header
Date: Tue, 22 Dec 2009 16:05:59 -0800
Message-ID: <43F901BD926A4E43B106BF17856F07559A5CD51D@orsmsx508.amr.corp.intel.com>
References: <20091218225043.10698.58897.stgit@localhost.localdomain>
 <20091218225158.10698.67726.stgit@localhost.localdomain>
 <20091221075951.GD21782@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>
To: Simon Horman <horms@verge.net.au>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:32364 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750901AbZLWAGE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Dec 2009 19:06:04 -0500
In-Reply-To: <20091221075951.GD21782@verge.net.au>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: Simon Horman [mailto:horms@verge.net.au]
>Sent: Monday, December 21, 2009 12:00 AM
>To: Kirsher, Jeffrey T
>Cc: netdev@vger.kernel.org; gospo@redhat.com; Rose, Gregory V
>Subject: Re: [RFC PATCH v2 04/12] ixgbevf: Driver main and ethool
>interface module and main header

[snip]

>
>> +
>> +static int ixgbevf_set_ringparam(struct net_device *netdev,
>> +				 struct ethtool_ringparam *ring)
>> +{
>> +	struct ixgbevf_adapter *adapter = netdev_priv(netdev);
>> +	struct ixgbevf_ring *tx_ring, *rx_ring;
>> +	int i, err;
>> +	u32 new_rx_count, new_tx_count;
>> +	bool need_update = false;
>> +
>> +	if ((ring->rx_mini_pending) || (ring->rx_jumbo_pending))
>> +		return -EINVAL;
>> +
>> +	new_rx_count = max(ring->rx_pending, (u32)IXGBEVF_MIN_RXD);
>> +	new_rx_count = min(new_rx_count, (u32)IXGBEVF_MAX_RXD);
>> +	new_rx_count = ALIGN(new_rx_count,
>IXGBE_REQ_RX_DESCRIPTOR_MULTIPLE);
>> +
>> +	new_tx_count = max(ring->tx_pending, (u32)IXGBEVF_MIN_TXD);
>> +	new_tx_count = min(new_tx_count, (u32)IXGBEVF_MAX_TXD);
>> +	new_tx_count = ALIGN(new_tx_count,
>IXGBE_REQ_TX_DESCRIPTOR_MULTIPLE);
>> +
>> +	if ((new_tx_count == adapter->tx_ring->count) &&
>> +	    (new_rx_count == adapter->rx_ring->count)) {
>> +		/* nothing to do */
>> +		return 0;
>> +	}
>> +
>> +	while (test_and_set_bit(__IXGBEVF_RESETTING, &adapter->state))
>> +		msleep(1);
>> +
>> +	tx_ring = kcalloc(adapter->num_tx_queues,
>> +			       sizeof(struct ixgbevf_ring), GFP_KERNEL);
>> +	if (!tx_ring) {
>> +		err = -ENOMEM;
>> +		goto err_setup;
>> +	}
>> +
>> +	if (new_tx_count != adapter->tx_ring_count) {
>> +		memcpy(tx_ring, adapter->tx_ring,
>> +		       adapter->num_tx_queues * sizeof(struct
>ixgbevf_ring));
>> +		for (i = 0; i < adapter->num_tx_queues; i++) {
>> +			tx_ring[i].count = new_tx_count;
>> +			err = ixgbevf_setup_tx_resources(adapter,
>> +							 &tx_ring[i]);
>> +			if (err) {
>> +				while (i) {
>> +					i--;
>> +					ixgbevf_free_tx_resources(adapter,
>> +								  &tx_ring[i]);
>> +				}
>> +				goto err_setup;
>> +			}
>> +			tx_ring[i].v_idx = adapter->tx_ring[i].v_idx;
>> +		}
>> +		need_update = true;
>> +	}
>
>> +
>> +	rx_ring = kcalloc(adapter->num_rx_queues,
>> +			       sizeof(struct ixgbevf_ring), GFP_KERNEL);
>> +	if ((!rx_ring) && (need_update)) {
>> +		for (i = 0; i < adapter->num_tx_queues; i++)
>> +			ixgbevf_free_tx_resources(adapter, &tx_ring[i]);
>> +		kfree(tx_ring);
>> +		err = -ENOMEM;
>> +		goto err_setup;
>> +	}
>> +
>> +	if (new_rx_count != adapter->rx_ring_count) {
>> +		memcpy(rx_ring, adapter->rx_ring,
>> +		       adapter->num_rx_queues * sizeof(struct
>ixgbevf_ring));
>> +		for (i = 0; i < adapter->num_rx_queues; i++) {
>> +			rx_ring[i].count = new_rx_count;
>> +			err = ixgbevf_setup_rx_resources(adapter,
>> +							 &rx_ring[i]);
>> +			if (err) {
>> +				while (i) {
>> +					i--;
>> +					ixgbevf_free_rx_resources(adapter,
>> +								  &rx_ring[i]);
>> +				}
>> +				goto err_setup;
>
>				Are some calls to ixgbevf_free_tx_resources()
>				needed here? Perhaps the ones for
>				on rx_ring failure could be moved down
>				to an err_tx_clear or similar?
>				(sorry for the shoddy name)
>
>
>> +			}
>> +			rx_ring[i].v_idx = adapter->rx_ring[i].v_idx;
>> +		}
>> +		need_update = true;
>> +	}
>> +
>> +	/* if rings need to be updated, here's the place to do it in one
>shot */
>> +	if (need_update) {
>> +		if (netif_running(netdev))
>> +			ixgbevf_down(adapter);
>> +
>> +		/* tx */
>> +		if (new_tx_count != adapter->tx_ring_count) {
>> +			kfree(adapter->tx_ring);
>> +			adapter->tx_ring = tx_ring;
>> +			tx_ring = NULL;
>> +			adapter->tx_ring_count = new_tx_count;
>> +		}
>> +
>> +		/* rx */
>> +		if (new_rx_count != adapter->rx_ring_count) {
>> +			kfree(adapter->rx_ring);
>> +			adapter->rx_ring = rx_ring;
>> +			rx_ring = NULL;
>> +			adapter->rx_ring_count = new_rx_count;
>> +		}
>> +	}
>
>	Can tx_ring and rx_ring leak here?

Most definitely.  I'm fixing this up and will have it straightened out for the next revision of the driver patches.  Good catch again.

Regards,

- Greg

