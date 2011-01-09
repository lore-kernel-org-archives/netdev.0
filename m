From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH 2/2] sky2: convert to new VLAN model
Date: Sun, 9 Jan 2011 10:50:36 -0500
Message-ID: <AANLkTimMHxOVTDm7+8qnoRjHb1BOvDOjDqyHCgHKocTD@mail.gmail.com>
References: <20110106204146.16b3a328@nehalam>
	<AANLkTikwGQFByOZGgCCjTJySPa8QYndZ903CFmOkS1Ha@mail.gmail.com>
	<20110107092758.7dc1152f@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:64585 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751800Ab1AIPuh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Jan 2011 10:50:37 -0500
Received: by yxt3 with SMTP id 3so7278490yxt.19
        for <netdev@vger.kernel.org>; Sun, 09 Jan 2011 07:50:36 -0800 (PST)
In-Reply-To: <20110107092758.7dc1152f@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 7, 2011 at 12:27 PM, Stephen Hemminger
<shemminger@vyatta.com> wrote:
> On Fri, 7 Jan 2011 12:14:51 -0500
> Jesse Gross <jesse@nicira.com> wrote:
>
>> On Thu, Jan 6, 2011 at 11:41 PM, Stephen Hemminger
>> <shemminger@vyatta.com> wrote:
>> > +/* Features available on VLAN with transmit tag stripped */
>> > +#define VLAN_FEAT (NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_TSO)
>> > +
>> > +static void sky2_vlan_mode(struct net_device *dev)
>> > =A0{
>> > - =A0 =A0 =A0 if (onoff) {
>> > + =A0 =A0 =A0 struct sky2_port *sky2 =3D netdev_priv(dev);
>> > + =A0 =A0 =A0 struct sky2_hw *hw =3D sky2->hw;
>> > + =A0 =A0 =A0 u16 port =3D sky2->port;
>> > +
>> > + =A0 =A0 =A0 if (dev->features & NETIF_F_HW_VLAN_RX)
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sky2_write32(hw, SK_REG(port, RX_GM=
=46_CTRL_T),
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 RX_VLAN_ST=
RIP_ON);
>> > + =A0 =A0 =A0 else
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 sky2_write32(hw, SK_REG(port, RX_GMF=
_CTRL_T),
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0RX_VLAN_S=
TRIP_OFF);
>> > +
>> > + =A0 =A0 =A0 if (dev->features & NETIF_F_HW_VLAN_TX) {
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sky2_write32(hw, SK_REG(port, TX_GM=
=46_CTRL_T),
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 TX_VLAN_TA=
G_ON);
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev->vlan_features =3D dev->features=
 & VLAN_FEAT;
>> > =A0 =A0 =A0 =A0} else {
>> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 sky2_write32(hw, SK_REG(port, RX_GMF=
_CTRL_T),
>> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0RX_VLAN_S=
TRIP_OFF);
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sky2_write32(hw, SK_REG(port, TX_GM=
=46_CTRL_T),
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 TX_VLAN_TA=
G_OFF);
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev->vlan_features =3D dev->features=
 & NETIF_F_HIGHDMA;
>>
>> Hmm, the chip supports SG only when TX vlan is on and HIGHDMA only
>> when it is off? =A0Currently skb_needs_linearize() assumes that when=
 not
>> using vlan acceleration, the DMA engine doesn't care about the
>> presence of a vlan tag and directly uses dev->features.
>
> The chip supports checksum offload only if TX_VLAN is enabled.
> Scatter/gather without checksum offload is not allowed by kernel
> because checksum offload is needed for sendfile.

OK, it sounds like skb_needs_linearize() needs to be more intelligent.
 I will send a patch for that shortly.
