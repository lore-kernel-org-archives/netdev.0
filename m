From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: Re: Gianfar : Drop a long frame
Date: Thu, 31 Jan 2013 10:50:14 +0200
Message-ID: <510A3046.2090406@freescale.com>
References: <001a01cdfeef$cdc5bee0$69513ca0$@acksys.fr> <51094280.8060701@freescale.com> <001e01cdff06$ae4de6c0$0ae9b440$@acksys.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>
To: voncken <cedric.voncken@acksys.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from db3ehsobe005.messaging.microsoft.com ([213.199.154.143]:46949
	"EHLO db3outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751248Ab3AaIut convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Jan 2013 03:50:49 -0500
In-Reply-To: <001e01cdff06$ae4de6c0$0ae9b440$@acksys.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/30/2013 6:27 PM, voncken wrote:
> -----Message d'origine-----
> De : Claudiu Manoil [mailto:claudiu.manoil@freescale.com]
> Envoy=E9 : mercredi 30 janvier 2013 16:56
> =C0 : voncken
> Cc : netdev@vger.kernel.org
> Objet : Re: Gianfar : Drop a long frame
>
> On 1/30/2013 3:43 PM, voncken wrote:
>> 	Hi Claudiu,
>>
>> 	I have a problem with the gianfar driver.
>>
>> 	My test conditions are:
>> 		- Disable rxvlan hardware acceleration (ethtool -K ethx
> rxvlan off)
>> 		- Receive frame contains a VLAN tag and with a frame len set
> to the
>> MTU (1500 bytes).
>>
>> 	In this condition, when I received a long frame the bdp->length is
>> set to 1538 bytes.
>> 	I guess it is composed of:
>> 		1500 bytes: L3 data bytes
>> 		 + 14 bytes:  Ethernet header
>> 		 + 4 bytes:  Vlan Tag header
>> 		 + 8 bytes: FCB structure size GMAC_FCB_LEN
>> 		 + 8 bytes: eTSEC padding
>> 		 + 4 bytes: Frames CRC (FCS)
>>
>> 	The Maximum frame len is set to 1536 because the function
>> gfar_change_mtu does not integrate the FCS in the computed frame siz=
e.
>> 	In this condition this frame is dropped with the test line 2792
>> function gfar_clean_rx_ring
>> 		if (unlikely(!(bdp->status & RXBD_ERR) &&
>> 				bdp->length > priv->rx_buffer_size))
>> 			bdp->status =3D RXBD_LARGE;
>> =09
>> 	How I can receive this frame correctly?
>> =09
>> 	Best regards
>>
>> Cedric Voncken | R&d Engineer
>
> Hi Cedric Voncken,
> Is the 802.1Q support activated on the receiving host? (see
> CONFIG_VLAN_8021Q)
>
> Hi Claudiu,
>
> YEs the CONFIG_VLAN_8021Q is enable on the receiving host, that work
> correctly if RXVLAN is set to on (ethtool -K ethx rxvlan off)
> I try with the linux kernel 3.3.8.
>
> Regards.
>

Ok, at fist glance it seems that the DEFAULT_RX_BUFFER_SIZE of 1536
bytes is not enough to accommodate VLAN_HLEN.
Apparently, the reason why it works with rxvlan 'on' and it doesn't
when set to 'off' is because by changing the NETIF_F_HW_VLAN_* feature=20
flags the gfar_change_mtu() gets called, which in turn has the followin=
g
issue:
gfar_change_mtu():
=2E..
	if (gfar_is_vlan_on(priv))
		frame_size +=3D VLAN_HLEN;
=2E..
where,
gfar_is_vlan_on():
{
	return (priv->ndev->features & NETIF_F_HW_VLAN_RX) ||
	       (priv->ndev->features & NETIF_F_HW_VLAN_TX);
}

and it's odd that the rx_buffer_size is conditioned by the HW VLAN=20
acceleration feature being turned on or off.
But I'll have to run some tests too to confirm this.

Regards,
Claudiu
