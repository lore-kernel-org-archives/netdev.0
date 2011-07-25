From: "Skidmore, Donald C" <donald.c.skidmore@intel.com>
Subject: RE: [net-next 10/10] ixgbe: convert to ndo_fix_features
Date: Mon, 25 Jul 2011 15:42:09 -0700
Message-ID: <C0716E470783B24A8178C9E38CD2F34506137894@orsmsx509.amr.corp.intel.com>
References: <1311314951-11142-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1311314951-11142-11-git-send-email-jeffrey.t.kirsher@intel.com>
 <20110722080255.GA10125@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: Michal Miroslaw <mirq-linux@rere.qmqm.pl>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:43158 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751223Ab1GYWmh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jul 2011 18:42:37 -0400
In-Reply-To: <20110722080255.GA10125@rere.qmqm.pl>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.or=
g]
>On Behalf Of Michal Miroslaw
>Sent: Friday, July 22, 2011 1:03 AM
>To: Kirsher, Jeffrey T
>Cc: davem@davemloft.net; Skidmore, Donald C; netdev@vger.kernel.org;
>gospo@redhat.com; sassmann@redhat.com
>Subject: Re: [net-next 10/10] ixgbe: convert to ndo_fix_features
>
>On Thu, Jul 21, 2011 at 11:09:11PM -0700, Jeff Kirsher wrote:
>> From: Don Skidmore <donald.c.skidmore@intel.com>
>>
>> Private rx_csum flags are now duplicate of netdev->features &
>> NETIF_F_RXCSUM.  We remove those duplicates and now use the
>net_device_ops
>> ndo_set_features.  This was based on the original patch submitted by
>> Michal Miroslaw <mirq-linux@rere.qmqm.pl>.  I also removed the speci=
al
>> case not requiring a reset for X540 hardware.  It is needed just as =
it
>is
>> in 82599 hardware.
>
>Looks mostly good now. Minor hints below.
>
>[...]
>> +static u32 ixgbe_fix_features(struct net_device *netdev, u32 data)
>> +{
>[...]
>> +	/* Turn off LRO if not RSC capable or invalid ITR settings */
>> +	if (!(adapter->flags2 & IXGBE_FLAG2_RSC_CAPABLE)) {
>> +		data &=3D ~NETIF_F_LRO;
>> +	} else if (!(adapter->flags2 & IXGBE_FLAG2_RSC_ENABLED) &&
>> +		   (adapter->rx_itr_setting !=3D 1 &&
>> +		    adapter->rx_itr_setting > IXGBE_MAX_RSC_INT_RATE)) {
>> +		data &=3D ~NETIF_F_LRO;
>> +		e_info(probe, "rx-usecs set too low, not enabling RSC\n");
>> +	}
>
>Better:
>
>... else if (data & NETIF_F_LRO && adapter->rx_itr_setting !=3D 1 &&
>adapter->rx_itr_setting > IXGBE_MAX_RSC_INT_RATE) {
>	e_info(...)
>	data &=3D ~NETIF_F_LRO;
>}
>

I see your point here, the added complexity (checking IXGBE_FLAG2_RSC_E=
NABLED) is there to cover cases that come up in our out of tree driver'=
s kcompat code.  This is why we mirror these feature flags to begin wit=
h.  I would like to modify the driver to use only the feature flags but=
 that will require some interesting kcompat code as well as touch large=
 parts of the driver so I was thinking would probably be best as anothe=
r patch. =20

My concern in this conditional is when RSC is not just possible but act=
ually turned on.  Currently the NETIF_F_LRO flag is enabled in probe if=
 we are RSC capable.  But it is possible to be RSC capable but not have=
 it enabled due to setting interrupts throttling rates too high.

>> +
>> +	return data;
>> +}
>> +
>> +static int ixgbe_set_features(struct net_device *netdev, u32 data)
>> +{
>> +	struct ixgbe_adapter *adapter =3D netdev_priv(netdev);
>> +	bool need_reset =3D false;
>> +
>> +	/* If Rx checksum is disabled, then RSC/LRO should also be
>disabled */
>> +	if (!(data & NETIF_F_RXCSUM))
>> +		adapter->flags &=3D ~IXGBE_FLAG_RX_CSUM_ENABLED;
>> +	else
>> +		adapter->flags |=3D IXGBE_FLAG_RX_CSUM_ENABLED;
>
>This exactly mirrors NETIF_F_RXCSUM. Waiting for later cleanup?

That's pretty much it, I would like to clean up all of these after figu=
ring out the best way to create the kcompat code for the out of tree dr=
iver that has to support old kernel versions.  Seems like that would be=
 worthy of its own patch.

>
>[...]
>> +	/*
>> +	 * Check if Flow Director n-tuple support was enabled or disabled.
>If
>> +	 * the state changed, we need to reset.
>> +	 */
>> +	if (!(adapter->flags & IXGBE_FLAG_FDIR_PERFECT_CAPABLE)) {
>> +		/* turn off ATR, enable perfect filters and reset */
>> +		if (data & NETIF_F_NTUPLE) {
>> +			adapter->flags &=3D ~IXGBE_FLAG_FDIR_HASH_CAPABLE;
>> +			adapter->flags |=3D IXGBE_FLAG_FDIR_PERFECT_CAPABLE;
>> +			need_reset =3D true;
>> +		}
>> +	} else if (!(data & NETIF_F_NTUPLE)) {
>> +		/* turn off Flow Director, set ATR and reset */
>> +		adapter->flags &=3D ~IXGBE_FLAG_FDIR_PERFECT_CAPABLE;
>> +		if ((adapter->flags &  IXGBE_FLAG_RSS_ENABLED) &&
>> +		    !(adapter->flags &  IXGBE_FLAG_DCB_ENABLED))
>> +			adapter->flags |=3D IXGBE_FLAG_FDIR_HASH_CAPABLE;
>> +		need_reset =3D true;
>> +	}
>
>You could make this more readable:
>
>old =3D adapter->flags;
>if (data & NETIF_F_NTUPLE) {
>	adapter->flags |=3D IXGBE_FLAG_FDIR_PERFECT_CAPABLE;
>	adapter->flags &=3D ~IXGBE_FLAG_FDIR_HASH_CAPABLE;
>} else {
>	adapter->flags &=3D ~IXGBE_FLAG_FDIR_PERFECT_CAPABLE;
>	if ((adapter->flags &  IXGBE_FLAG_RSS_ENABLED) &&
>	    !(adapter->flags &  IXGBE_FLAG_DCB_ENABLED))
>		adapter->flags |=3D IXGBE_FLAG_FDIR_HASH_CAPABLE;
>}
>if (old !=3D adapter->flags)
>	need_reset =3D true;
>

I agree this is a lot more readable.  Wish I would have thought of it. =
:)

I'll send out a new patch with at least this modification.

>> +
>> +	if (need_reset)
>> +		ixgbe_do_reset(netdev);
>> +
>> +	return 0;
>> +
>> +}
>> +
>>  static const struct net_device_ops ixgbe_netdev_ops =3D {
>>  	.ndo_open		=3D ixgbe_open,
>>  	.ndo_stop		=3D ixgbe_close,
>> @@ -7153,6 +7228,8 @@ static const struct net_device_ops
>ixgbe_netdev_ops =3D {
>>  	.ndo_fcoe_disable =3D ixgbe_fcoe_disable,
>>  	.ndo_fcoe_get_wwn =3D ixgbe_fcoe_get_wwn,
>>  #endif /* IXGBE_FCOE */
>> +	.ndo_set_features =3D ixgbe_set_features,
>> +	.ndo_fix_features =3D ixgbe_fix_features,
>>  };
>>
>>  static void __devinit ixgbe_probe_vf(struct ixgbe_adapter *adapter,
>> @@ -7420,20 +7497,24 @@ static int __devinit ixgbe_probe(struct
>pci_dev *pdev,
>>
>>  	netdev->features =3D NETIF_F_SG |
>>  			   NETIF_F_IP_CSUM |
>> +			   NETIF_F_IPV6_CSUM |
>>  			   NETIF_F_HW_VLAN_TX |
>>  			   NETIF_F_HW_VLAN_RX |
>> -			   NETIF_F_HW_VLAN_FILTER;
>> +			   NETIF_F_HW_VLAN_FILTER |
>> +			   NETIF_F_TSO |
>> +			   NETIF_F_TSO6 |
>> +			   NETIF_F_GRO |
>> +			   NETIF_F_RXHASH |
>> +			   NETIF_F_RXCSUM;
>
>Drop NETIF_F_GRO here, as its always set by network core now.
>

Will do.=20

>> -	netdev->features |=3D NETIF_F_IPV6_CSUM;
>> -	netdev->features |=3D NETIF_F_TSO;
>> -	netdev->features |=3D NETIF_F_TSO6;
>> -	netdev->features |=3D NETIF_F_GRO;
>> -	netdev->features |=3D NETIF_F_RXHASH;
>> +	netdev->hw_features =3D netdev->features;
>>
>>  	switch (adapter->hw.mac.type) {
>>  	case ixgbe_mac_82599EB:
>>  	case ixgbe_mac_X540:
>>  		netdev->features |=3D NETIF_F_SCTP_CSUM;
>> +		netdev->hw_features |=3D NETIF_F_SCTP_CSUM |
>> +				       NETIF_F_NTUPLE;
>
>NTUPLE disabled by default. That's the idea?

We default with ATR on which disables perfect filters (NETIF_F_NTUPLE).=
=20

>
>Best Regards,
>Micha=B3 Miros=B3aw
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
