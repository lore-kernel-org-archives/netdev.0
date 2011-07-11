From: "Skidmore, Donald C" <donald.c.skidmore@intel.com>
Subject: RE: [net-next 5/5] ixgbe: convert to ndo_fix_features
Date: Mon, 11 Jul 2011 16:53:57 -0700
Message-ID: <C0716E470783B24A8178C9E38CD2F34505DF1B3F@orsmsx509.amr.corp.intel.com>
References: <1310212240-24623-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1310212240-24623-6-git-send-email-jeffrey.t.kirsher@intel.com>
 <20110709121108.GA7720@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>
To: Michal Miroslaw <mirq-linux@rere.qmqm.pl>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:5662 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753165Ab1GKXyU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jul 2011 19:54:20 -0400
In-Reply-To: <20110709121108.GA7720@rere.qmqm.pl>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: Michal Miroslaw [mailto:mirq-linux@rere.qmqm.pl]
>Sent: Saturday, July 09, 2011 5:11 AM
>To: Kirsher, Jeffrey T
>Cc: davem@davemloft.net; Skidmore, Donald C; netdev@vger.kernel.org;
>gospo@redhat.com
>Subject: Re: [net-next 5/5] ixgbe: convert to ndo_fix_features
>
>On Sat, Jul 09, 2011 at 04:50:40AM -0700, Jeff Kirsher wrote:
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
>[...]
>> --- a/drivers/net/ixgbe/ixgbe_main.c
>> +++ b/drivers/net/ixgbe/ixgbe_main.c
>> @@ -7188,6 +7188,88 @@ int ixgbe_setup_tc(struct net_device *dev, u8
>tc)
>[...]
>> +static int ixgbe_set_features(struct net_device *netdev, u32 data)
>> +{
>> +	struct ixgbe_adapter *adapter =3D netdev_priv(netdev);
>> +	bool need_reset =3D false;
>> +
>> +#ifdef CONFIG_DCB
>> +	if ((adapter->flags & IXGBE_FLAG_DCB_ENABLED) &&
>> +	    !(data &  NETIF_F_HW_VLAN_RX))
>> +		return -EINVAL;
>> +#endif
>> +	/* return error if RXHASH is being enabled when RSS is not
>supported */
>> +	if (!(adapter->flags & IXGBE_FLAG_RSS_ENABLED) &&
>> +	     (data &  NETIF_F_RXHASH))
>> +		return -EINVAL;
>> +
>> +	/* If Rx checksum is disabled, then RSC/LRO should also be
>disabled */
>> +	if (!(data & NETIF_F_RXCSUM)) {
>> +		data &=3D ~NETIF_F_LRO;
>> +		adapter->flags &=3D ~IXGBE_FLAG_RX_CSUM_ENABLED;
>> +	} else {
>> +		adapter->flags |=3D IXGBE_FLAG_RX_CSUM_ENABLED;
>> +	}
>
>The checks above should be done in ndo_fix_features callback. The chec=
k
>for
>RSS_ENABLED for RXHASH is redundant, as the feature is removed in
>probe()
>in this case (see [MARK] below).

Thanks for the comments Michal, it clears up a lot in my mind. :)

So in ndo_fix_features we would just turn off feature flags rather than=
 return an error?  For example:

	if (!(data & NETIF_F_RXCSUM))=20
		data &=3D ~NETIF_F_LRO;

As for RSS_ENABLED/RXHASH check it was to cover the cases where RSS_ENA=
BLED might have changed since probe.  This could happen with a resume w=
ere we don't get enough MSI-X vectors.  There are also paths in FCoE an=
d DCB that get into code that could clear IXGBE_FLAG_RSS_ENABLED.

>
>> +
>> +	/* if state changes we need to update adapter->flags and reset */
>> +	if ((adapter->flags2 & IXGBE_FLAG2_RSC_CAPABLE) &&
>> +	    (!!(data & NETIF_F_LRO) !=3D
>> +	     !!(adapter->flags2 & IXGBE_FLAG2_RSC_ENABLED))) {
>> +		if ((data &  NETIF_F_LRO) &&
>> +		    adapter->rx_itr_setting !=3D 1 &&
>> +		    adapter->rx_itr_setting > IXGBE_MAX_RSC_INT_RATE) {
>> +			e_info(probe, "rx-usecs set too low, "
>> +			       "not enabling RSC\n");
>> +		} else {
>> +			adapter->flags2 ^=3D IXGBE_FLAG2_RSC_ENABLED;
>> +			switch (adapter->hw.mac.type) {
>> +			case ixgbe_mac_X540:
>> +			case ixgbe_mac_82599EB:
>> +				need_reset =3D true;
>> +				break;
>> +			default:
>> +				break;
>> +			}
>> +		}
>> +	}
>> +
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
>Part of the checks above should be in ndo_fix_features, too.
>ndo_set_features
>should just enable what it has been passed. What ndo_fix_features
>callback
>returns is further limited by generic checks, and then (if the resulti=
ng
>set
>is different than current dev->features) ndo_set_features is called.

I'm a little confused here.  From your comments I get the idea that ndo=
_fix_features() just modifies and error checks our feature set.  The re=
sult of this would then be just a change to the feature set (data varia=
ble in my case above).  Is that a correct assumption?  If so I'm confus=
ed as none of the two checks above change the feature set.  They do cha=
nge driver flags to indicate the new state and mark whether we need a r=
eset.  I don't believe we would want to do the reset until ndo_set_feat=
ure is called and if we broke up the setting of the driver flags into n=
do_fix_features we would lose some state (i.e. if the IXGBE_FLAG2_RSC_E=
NABLED changed) that we need to decide if a reset is needed in ndo_set_=
features. =20

Am I just missing something here?

Thanks
-Don

>
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
>> @@ -7219,6 +7301,7 @@ static const struct net_device_ops
>ixgbe_netdev_ops =3D {
>>  	.ndo_fcoe_disable =3D ixgbe_fcoe_disable,
>>  	.ndo_fcoe_get_wwn =3D ixgbe_fcoe_get_wwn,
>>  #endif /* IXGBE_FCOE */
>> +	.ndo_set_features =3D ixgbe_set_features,
>>  };
>>
>>  static void __devinit ixgbe_probe_vf(struct ixgbe_adapter *adapter,
>> @@ -7486,20 +7569,24 @@ static int __devinit ixgbe_probe(struct
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
>>
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
>>  		break;
>>  	default:
>>  		break;
>> @@ -7538,6 +7625,8 @@ static int __devinit ixgbe_probe(struct pci_de=
v
>*pdev,
>>  		netdev->vlan_features |=3D NETIF_F_HIGHDMA;
>>  	}
>>
>> +	if (adapter->flags2 & IXGBE_FLAG2_RSC_CAPABLE)
>> +		netdev->hw_features |=3D NETIF_F_LRO;
>>  	if (adapter->flags2 & IXGBE_FLAG2_RSC_ENABLED)
>>  		netdev->features |=3D NETIF_F_LRO;
>>
>> @@ -7574,8 +7663,10 @@ static int __devinit ixgbe_probe(struct pci_d=
ev
>*pdev,
>>  	if (err)
>>  		goto err_sw_init;
>>
>> -	if (!(adapter->flags & IXGBE_FLAG_RSS_ENABLED))
>> +	if (!(adapter->flags & IXGBE_FLAG_RSS_ENABLED)) {
>> +		netdev->hw_features &=3D ~NETIF_F_RXHASH;
>>  		netdev->features &=3D ~NETIF_F_RXHASH;
>> +	}
>>
>
>[MARK here]
>
>Best Regards,
>Micha=B3 Miros=B3aw
