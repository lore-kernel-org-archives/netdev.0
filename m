From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [PATCH] net: cxgb4{,vf}: convert to hw_features
Date: Sat, 16 Apr 2011 18:56:51 +0200
Message-ID: <20110416165651.GA29966@rere.qmqm.pl>
References: <20110415145050.6A43913A6A@rere.qmqm.pl> <4DA895DF.1090809@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Casey Leedom <leedom@chelsio.com>
To: Dimitris Michailidis <dm@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:37591 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750908Ab1DPQ4w (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 16 Apr 2011 12:56:52 -0400
Content-Disposition: inline
In-Reply-To: <4DA895DF.1090809@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 15, 2011 at 12:00:47PM -0700, Dimitris Michailidis wrote:
> Micha=B3 Miros=B3aw wrote:
[...]
>> +		netdev->hw_features =3D NETIF_F_SG | TSO_FLAGS |
>> +			NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
>> +			NETIF_F_RXCSUM | NETIF_F_RXHASH |
>> +			NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
>> +		netdev->features |=3D netdev->hw_features | highdma;
>>  		netdev->vlan_features =3D netdev->features & VLAN_FEAT;
> Here vlan_features does not include NETIF_F_RXCSUM but the cxgb4vf bi=
ts =20
> below do include it.  I looked at some other drivers and saw again so=
me =20
> include it and some don't.  The core VLAN code handles NETIF_F_RXCSUM=
 on=20
> its own.  Is there some rule for whether drivers should set it in the=
ir =20
> vlan_features or not?

Since NETIF_F_RXCSUM is ignored in vlan_features I'd rather see it not =
set.
(fixed in v2)

>> diff --git a/drivers/net/cxgb4/sge.c b/drivers/net/cxgb4/sge.c
>> index 311471b..e8f6f8e 100644
>> --- a/drivers/net/cxgb4/sge.c
>> +++ b/drivers/net/cxgb4/sge.c
>> @@ -1587,7 +1587,7 @@ int t4_ethrx_handler(struct sge_rspq *q, const=
 __be64 *rsp,
>>  	pi =3D netdev_priv(skb->dev);
>>  	rxq->stats.pkts++;
>>  -	if (csum_ok && (pi->rx_offload & RX_CSO) &&
>> +	if (csum_ok && (q->netdev->features & NETIF_F_RXCSUM) &&
>>  	    (pkt->l2info & htonl(RXF_UDP | RXF_TCP))) {
>>  		if (!pkt->ip_frag) {
>>  			skb->ip_summed =3D CHECKSUM_UNNECESSARY;
> With this change variable 'pi' can be removed but I can do this clean=
up =20
> after this patch goes in.

I've included it in v2.

>> diff --git a/drivers/net/cxgb4vf/cxgb4vf_main.c b/drivers/net/cxgb4v=
f/cxgb4vf_main.c
>> index c662679..04a5c2d 100644
>> --- a/drivers/net/cxgb4vf/cxgb4vf_main.c
>> +++ b/drivers/net/cxgb4vf/cxgb4vf_main.c
>> @@ -2638,14 +2597,13 @@ static int __devinit cxgb4vf_pci_probe(struc=
t pci_dev *pdev,
>>  		 * it.
>>  		 */
>>  		pi->xact_addr_filt =3D -1;
>> -		pi->rx_offload =3D RX_CSO;
>>  		netif_carrier_off(netdev);
>>  		netdev->irq =3D pdev->irq;
>>  -		netdev->features =3D (NETIF_F_SG | TSO_FLAGS |
>> -				    NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
>> -				    NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX |
>> -				    NETIF_F_GRO);
>> +		netdev->hw_features =3D NETIF_F_SG | TSO_FLAGS | NETIF_F_RXCSUM |
>> +			NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
>> +			NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
>> +		netdev->features =3D netdev->hw_features;
>>  		if (pci_using_dac)
>>  			netdev->features |=3D NETIF_F_HIGHDMA;
>>  		netdev->vlan_features =3D
> cxgb4vf does not implement toggling of NETIF_F_HW_VLAN_RX so I think =
the =20
> flag should be set in features but not hw_features or maybe the drive=
r=20
> needs to handle it in fix_features?

=46ixed in v2.

Best Regards,
Micha=B3 Miros=B3aw
