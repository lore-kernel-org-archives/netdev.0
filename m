From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH 2/2] sky2: convert to new VLAN model
Date: Fri, 7 Jan 2011 12:14:51 -0500
Message-ID: <AANLkTikwGQFByOZGgCCjTJySPa8QYndZ903CFmOkS1Ha@mail.gmail.com>
References: <20110106204146.16b3a328@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:45628 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754934Ab1AGROz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Jan 2011 12:14:55 -0500
Received: by gyb11 with SMTP id 11so6639027gyb.19
        for <netdev@vger.kernel.org>; Fri, 07 Jan 2011 09:14:54 -0800 (PST)
In-Reply-To: <20110106204146.16b3a328@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 6, 2011 at 11:41 PM, Stephen Hemminger
<shemminger@vyatta.com> wrote:
> +/* Features available on VLAN with transmit tag stripped */
> +#define VLAN_FEAT (NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_TSO)
> +
> +static void sky2_vlan_mode(struct net_device *dev)
> =A0{
> - =A0 =A0 =A0 if (onoff) {
> + =A0 =A0 =A0 struct sky2_port *sky2 =3D netdev_priv(dev);
> + =A0 =A0 =A0 struct sky2_hw *hw =3D sky2->hw;
> + =A0 =A0 =A0 u16 port =3D sky2->port;
> +
> + =A0 =A0 =A0 if (dev->features & NETIF_F_HW_VLAN_RX)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sky2_write32(hw, SK_REG(port, RX_GMF_C=
TRL_T),
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 RX_VLAN_STRIP=
_ON);
> + =A0 =A0 =A0 else
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 sky2_write32(hw, SK_REG(port, RX_GMF_CT=
RL_T),
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0RX_VLAN_STRI=
P_OFF);
> +
> + =A0 =A0 =A0 if (dev->features & NETIF_F_HW_VLAN_TX) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sky2_write32(hw, SK_REG(port, TX_GMF_C=
TRL_T),
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 TX_VLAN_TAG_O=
N);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev->vlan_features =3D dev->features & =
VLAN_FEAT;
> =A0 =A0 =A0 =A0} else {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 sky2_write32(hw, SK_REG(port, RX_GMF_CT=
RL_T),
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0RX_VLAN_STRI=
P_OFF);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sky2_write32(hw, SK_REG(port, TX_GMF_C=
TRL_T),
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 TX_VLAN_TAG_O=
=46F);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev->vlan_features =3D dev->features & =
NETIF_F_HIGHDMA;

Hmm, the chip supports SG only when TX vlan is on and HIGHDMA only
when it is off?  Currently skb_needs_linearize() assumes that when not
using vlan acceleration, the DMA engine doesn't care about the
presence of a vlan tag and directly uses dev->features.

Also, can't we enable NETIF_F_GRO in vlan_features?  It will be set
initially by register_netdevice() but if we change the flags it gets
blown away.
