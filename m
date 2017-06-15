From: Jakub Kicinski <kubakici@wp.pl>
Subject: Re: [PATCH net-next] nfp: add VLAN filtering support
Date: Thu, 15 Jun 2017 12:23:45 -0700
Message-ID: <20170615122345.1360b1c1@cakuba.netronome.com>
References: <20170615062307.10153-1-jakub.kicinski@netronome.com>
        <BLUPR0701MB2004A321103E707B6F6A63918DC00@BLUPR0701MB2004.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "oss-drivers@netronome.com" <oss-drivers@netronome.com>,
        Pablo =?UTF-8?B?Q2FzY8Ozbg==?= <pablo.cascon@netronome.com>
To: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx4.wp.pl ([212.77.101.11]:22403 "EHLO mx4.wp.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750803AbdFOTXx (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 15 Jun 2017 15:23:53 -0400
In-Reply-To: <BLUPR0701MB2004A321103E707B6F6A63918DC00@BLUPR0701MB2004.namprd07.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 15 Jun 2017 12:50:57 +0000, Mintz, Yuval wrote:
> > From: Pablo Casc=C3=B3n <pablo.cascon@netronome.com>
> >=20
> > Add general use per-vNIC mailbox area and use it for VLAN filtering sup=
port.
> > Initially proto is hardcoded to 802.1q.
> >  =20
> ...
> > +static int
> > +nfp_net_vlan_rx_add_vid(struct net_device *netdev, __be16 proto, u16
> > +vid) {
> > +	struct nfp_net *nn =3D netdev_priv(netdev);
> > +
> > +	/* Priority tagged packets with vlan id 0 are processed by the
> > +	 * NFP as untagged packets
> > +	 */
> > +	if (!vid)
> > +		return 0;
> > +
> > +	nn_writew(nn, NFP_NET_CFG_VLAN_FILTER_VID, vid);
> > +	nn_writew(nn, NFP_NET_CFG_VLAN_FILTER_PROTO, ETH_P_8021Q); =20
>=20
> If it's hard-coded, don't you want to fail the request in case proto is d=
ifferent?

We have NETIF_F_HW_VLAN_CTAG_FILTER and NETIF_F_HW_VLAN_STAG_FILTER as
separate features exactly for that reason.  If we don't advertise STAG
support, VLAN ndos will never be called with non-802.1q proto.  See
vlan_hw_filter_capable(), called from __vlan_vid_add().  You can also
find multiple drivers in the tree which depend on the same behaviour
(e.g. Intel drivers).

So we considered checking proto, but we realized we don't have to,
because the stack is nice enough to do it for us.
