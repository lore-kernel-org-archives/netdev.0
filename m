From: Pavel Simerda <psimerda@redhat.com>
Subject: Re: [GIT] Networking
Date: Fri, 3 May 2013 19:35:35 -0400 (EDT)
Message-ID: <1925922763.4087858.1367624135286.JavaMail.root@redhat.com>
References: <20130502.041625.412316202038784117.davem@davemloft.net> <20130502083619.GA22010@macbook.localnet> <87d2t9bvj1.fsf@nemi.mork.no> <20130502.051727.949429506738234701.davem@davemloft.net> <1367490491.5106.137.camel@deadeye.wl.decadent.org.uk> <87zjwda9bl.fsf@nemi.mork.no> <CAHXqBF+S3mSbktoDzuHkzvEQkfxa6-2R-sYpqVsZBzMDTjUifQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?utf-8?Q?Bj=C3=B8rn?= Mork <bjorn@mork.no>,
	Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>, kaber@trash.net,
	torvalds@linux-foundation.org, hayeswang@realtek.com,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Dan Williams <dcbw@redhat.com>,
	Jiri Pirko <jpirko@redhat.com>
To: =?utf-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirqus@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAHXqBF+S3mSbktoDzuHkzvEQkfxa6-2R-sYpqVsZBzMDTjUifQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

----- Original Message -----
> From: "Micha=C5=82 Miros=C5=82aw" <mirqus@gmail.com>
> To: "Bj=C3=B8rn Mork" <bjorn@mork.no>, "Pavel =C5=A0imerda" <psimerda=
@redhat.com>
> Cc: "Ben Hutchings" <bhutchings@solarflare.com>, "David Miller" <dave=
m@davemloft.net>, kaber@trash.net,
> torvalds@linux-foundation.org, hayeswang@realtek.com, akpm@linux-foun=
dation.org, netdev@vger.kernel.org,
> linux-kernel@vger.kernel.org
> Sent: Thursday, May 2, 2013 6:22:47 PM
> Subject: Re: [GIT] Networking
>=20
> 2013/5/2 Bj=C3=B8rn Mork <bjorn@mork.no>:
> > Ben Hutchings <bhutchings@solarflare.com> writes:
> >> On Thu, 2013-05-02 at 05:17 -0400, David Miller wrote:
> >>> From: Bj=C3=B8rn Mork <bjorn@mork.no>
> >>> Date: Thu, 02 May 2013 11:06:42 +0200
> >>>
> >>> > Adding the new netdev features will make it go from 1 to 2:
> >>>
> >>> We already had more than 31 feature bits before Patrick's
> >>> changes, and I'm pretty sure this was the case when we added
> >>> that ethtool API.
> >>
> >> It wasn't, but this should be OK.  Userland is supposed to query t=
he
> >> number of features using ETHTOOL_GSSET_INFO and then work out the =
number
> >> of words/blocks using FEATURE_BITS_TO_BLOCKS().
> >
> >
> > Looking at
> > http://cgit.freedesktop.org/NetworkManager/NetworkManager/tree/src/=
platform/nm-linux-platform.c#n1025
> > there seems to be a couple of bugs in this area. This is certainly
> > abusing the exported API, but it does mean that NM breaks if you ev=
er
> > move NETIF_F_VLAN_CHALLENGED (like the 802.1ad patch did):
> >
> > ----
> > #define NETIF_F_VLAN_CHALLENGED (1 << 10)
> >
> > static gboolean
> > link_supports_vlans (NMPlatform *platform, int ifindex)
> > {
> >         auto_nl_object struct rtnl_link *rtnllink =3D link_get (pla=
tform,
> >         ifindex);
> >         const char *name =3D nm_platform_link_get_name (ifindex);
> >         struct {
> >                 struct ethtool_gfeatures features;
> >                 struct ethtool_get_features_block features_block;
> >         } edata =3D { .features =3D { .cmd =3D ETHTOOL_GFEATURES, .=
size =3D 1 } };
> >
> >         /* Only ARPHRD_ETHER links can possibly support VLANs. */
> >         if (!rtnllink || rtnl_link_get_arptype (rtnllink) !=3D ARPH=
RD_ETHER)
> >                 return FALSE;
> >
> >         if (!name || !ethtool_get (name, &edata))
> >                 return FALSE;
> >
> >         return !(edata.features.features[0].active &
> >         NETIF_F_VLAN_CHALLENGED);
> > }
> > ----
> >
> >
> > Not that I see how this particular bug matters unless you need VLAN
> > support in NM.  But there could be similar issues around.  I guess
> > avoiding unnecessary renumbering of the NETIF_F bits can save us so=
me
> > trouble.  Although you can certainly argue that those bits never we=
re
> > intended to be part of the API, and that using them like this is a =
user
> > application bug.
>=20
> This is certainly a bug in NM, and a fresh one: commit
> b636ea86b1c0a28b77eda311c84d3b2417cad22e from 2013-04-10 14:40:58
> (GMT). Userspace is expected to use ETHTOOL_GSTRINGS for
> ETH_SS_FEATURES and find a corresponding bit position by feature name
> ("vlan-challenged" in this case).
>=20
> Cc: commit's author.

Recorded the bug with NetworkManager bugzilla blocking the upcoming rel=
ease:

https://bugzilla.gnome.org/show_bug.cgi?id=3D699649

The code is experimental and is not used by NetworkManager even in the =
'master' branch except by nm-platform's automated tests. Once we fix it=
, you don't need to worry about it.

Thanks!

Pavel
