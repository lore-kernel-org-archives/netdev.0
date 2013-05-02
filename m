From: Dan Williams <dcbw@redhat.com>
Subject: Re: [GIT] Networking
Date: Thu, 02 May 2013 11:27:36 -0500
Message-ID: <1367512056.4000.3.camel@dcbw.foobar.com>
References: <20130502.041625.412316202038784117.davem@davemloft.net>
	 <20130502083619.GA22010@macbook.localnet> <87d2t9bvj1.fsf@nemi.mork.no>
	 <20130502.051727.949429506738234701.davem@davemloft.net>
	 <1367490491.5106.137.camel@deadeye.wl.decadent.org.uk>
	 <87zjwda9bl.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>, kaber@trash.net,
	torvalds@linux-foundation.org, hayeswang@realtek.com,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87zjwda9bl.fsf@nemi.mork.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2013-05-02 at 13:51 +0200, Bj=C3=B8rn Mork wrote:
> Ben Hutchings <bhutchings@solarflare.com> writes:
> > On Thu, 2013-05-02 at 05:17 -0400, David Miller wrote:
> >> From: Bj=C3=B8rn Mork <bjorn@mork.no>
> >> Date: Thu, 02 May 2013 11:06:42 +0200
> >>=20
> >> > Adding the new netdev features will make it go from 1 to 2:
> >>=20
> >> We already had more than 31 feature bits before Patrick's
> >> changes, and I'm pretty sure this was the case when we added
> >> that ethtool API.
> >
> > It wasn't, but this should be OK.  Userland is supposed to query th=
e
> > number of features using ETHTOOL_GSSET_INFO and then work out the n=
umber
> > of words/blocks using FEATURE_BITS_TO_BLOCKS(). =20
>=20
>=20
> Looking at
> http://cgit.freedesktop.org/NetworkManager/NetworkManager/tree/src/pl=
atform/nm-linux-platform.c#n1025
> there seems to be a couple of bugs in this area. This is certainly
> abusing the exported API, but it does mean that NM breaks if you ever
> move NETIF_F_VLAN_CHALLENGED (like the 802.1ad patch did):

NM doesn't actually use any of the code in src/platform/ yet, so it
wouldn't be affecting anything NM does at this time.  However, comments
like this are quite useful so we can fix it before NM does start to
depend on the code :)

Dan

> ----
> #define NETIF_F_VLAN_CHALLENGED (1 << 10)
>=20
> static gboolean
> link_supports_vlans (NMPlatform *platform, int ifindex)
> {
> 	auto_nl_object struct rtnl_link *rtnllink =3D link_get (platform, if=
index);
> 	const char *name =3D nm_platform_link_get_name (ifindex);
> 	struct {
> 		struct ethtool_gfeatures features;
> 		struct ethtool_get_features_block features_block;
> 	} edata =3D { .features =3D { .cmd =3D ETHTOOL_GFEATURES, .size =3D =
1 } };
>=20
> 	/* Only ARPHRD_ETHER links can possibly support VLANs. */
> 	if (!rtnllink || rtnl_link_get_arptype (rtnllink) !=3D ARPHRD_ETHER)
> 		return FALSE;
>=20
> 	if (!name || !ethtool_get (name, &edata))
> 		return FALSE;
>=20
> 	return !(edata.features.features[0].active & NETIF_F_VLAN_CHALLENGED=
);
> }
> ----
>=20
>=20
> Not that I see how this particular bug matters unless you need VLAN
> support in NM.  But there could be similar issues around.  I guess
> avoiding unnecessary renumbering of the NETIF_F bits can save us some
> trouble.  Although you can certainly argue that those bits never were
> intended to be part of the API, and that using them like this is a us=
er
> application bug.
>=20
>=20
>=20
> Bj=C3=B8rn
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
