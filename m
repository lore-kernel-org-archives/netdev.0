From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 2/2] sky2: convert to new VLAN model
Date: Fri, 7 Jan 2011 09:27:58 -0800
Message-ID: <20110107092758.7dc1152f@nehalam>
References: <20110106204146.16b3a328@nehalam>
	<AANLkTikwGQFByOZGgCCjTJySPa8QYndZ903CFmOkS1Ha@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:44778 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754617Ab1AGR2C convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Jan 2011 12:28:02 -0500
In-Reply-To: <AANLkTikwGQFByOZGgCCjTJySPa8QYndZ903CFmOkS1Ha@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 7 Jan 2011 12:14:51 -0500
Jesse Gross <jesse@nicira.com> wrote:

> On Thu, Jan 6, 2011 at 11:41 PM, Stephen Hemminger
> <shemminger@vyatta.com> wrote:
> > +/* Features available on VLAN with transmit tag stripped */
> > +#define VLAN_FEAT (NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_TSO)
> > +
> > +static void sky2_vlan_mode(struct net_device *dev)
> > =A0{
> > - =A0 =A0 =A0 if (onoff) {
> > + =A0 =A0 =A0 struct sky2_port *sky2 =3D netdev_priv(dev);
> > + =A0 =A0 =A0 struct sky2_hw *hw =3D sky2->hw;
> > + =A0 =A0 =A0 u16 port =3D sky2->port;
> > +
> > + =A0 =A0 =A0 if (dev->features & NETIF_F_HW_VLAN_RX)
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sky2_write32(hw, SK_REG(port, RX_GMF=
_CTRL_T),
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 RX_VLAN_STR=
IP_ON);
> > + =A0 =A0 =A0 else
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 sky2_write32(hw, SK_REG(port, RX_GMF_=
CTRL_T),
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0RX_VLAN_ST=
RIP_OFF);
> > +
> > + =A0 =A0 =A0 if (dev->features & NETIF_F_HW_VLAN_TX) {
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sky2_write32(hw, SK_REG(port, TX_GMF=
_CTRL_T),
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 TX_VLAN_TAG=
_ON);
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev->vlan_features =3D dev->features =
& VLAN_FEAT;
> > =A0 =A0 =A0 =A0} else {
> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 sky2_write32(hw, SK_REG(port, RX_GMF_=
CTRL_T),
> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0RX_VLAN_ST=
RIP_OFF);
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sky2_write32(hw, SK_REG(port, TX_GMF=
_CTRL_T),
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 TX_VLAN_TAG=
_OFF);
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev->vlan_features =3D dev->features =
& NETIF_F_HIGHDMA;
>=20
> Hmm, the chip supports SG only when TX vlan is on and HIGHDMA only
> when it is off?  Currently skb_needs_linearize() assumes that when no=
t
> using vlan acceleration, the DMA engine doesn't care about the
> presence of a vlan tag and directly uses dev->features.

The chip supports checksum offload only if TX_VLAN is enabled.
Scatter/gather without checksum offload is not allowed by kernel
because checksum offload is needed for sendfile.

highdma should always be on

> Also, can't we enable NETIF_F_GRO in vlan_features?  It will be set
> initially by register_netdevice() but if we change the flags it gets
> blown away.

I will revise. GRO is independent of all this.


--=20
