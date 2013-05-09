From: Pavel Simerda <psimerda@redhat.com>
Subject: Re: [GIT] Networking
Date: Thu, 9 May 2013 05:02:21 -0400 (EDT)
Message-ID: <1222107388.5643197.1368090141553.JavaMail.root@redhat.com>
References: <20130502.041625.412316202038784117.davem@davemloft.net> <20130502083619.GA22010@macbook.localnet> <87d2t9bvj1.fsf@nemi.mork.no> <20130502.051727.949429506738234701.davem@davemloft.net> <1367490491.5106.137.camel@deadeye.wl.decadent.org.uk> <87zjwda9bl.fsf@nemi.mork.no> <CAHXqBF+S3mSbktoDzuHkzvEQkfxa6-2R-sYpqVsZBzMDTjUifQ@mail.gmail.com> <1925922763.4087858.1367624135286.JavaMail.root@redhat.com>
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
In-Reply-To: <1925922763.4087858.1367624135286.JavaMail.root@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

----- Original Message -----
> From: "Pavel Simerda" <psimerda@redhat.com>
> To: "Micha=C5=82 Miros=C5=82aw" <mirqus@gmail.com>
> Cc: "Bj=C3=B8rn Mork" <bjorn@mork.no>, "Ben Hutchings" <bhutchings@so=
larflare.com>, "David Miller" <davem@davemloft.net>,
> kaber@trash.net, torvalds@linux-foundation.org, hayeswang@realtek.com=
, akpm@linux-foundation.org,
> netdev@vger.kernel.org, linux-kernel@vger.kernel.org, "Dan Williams" =
<dcbw@redhat.com>, "Jiri Pirko"
> <jpirko@redhat.com>
> Sent: Saturday, May 4, 2013 1:35:35 AM
> Subject: Re: [GIT] Networking
>=20
> ----- Original Message -----
> > From: "Micha=C5=82 Miros=C5=82aw" <mirqus@gmail.com>
> > To: "Bj=C3=B8rn Mork" <bjorn@mork.no>, "Pavel =C5=A0imerda" <psimer=
da@redhat.com>
> > Cc: "Ben Hutchings" <bhutchings@solarflare.com>, "David Miller"
> > <davem@davemloft.net>, kaber@trash.net,
> > torvalds@linux-foundation.org, hayeswang@realtek.com,
> > akpm@linux-foundation.org, netdev@vger.kernel.org,
> > linux-kernel@vger.kernel.org
> > Sent: Thursday, May 2, 2013 6:22:47 PM
> > Subject: Re: [GIT] Networking
> >=20
> > 2013/5/2 Bj=C3=B8rn Mork <bjorn@mork.no>:
> > > Ben Hutchings <bhutchings@solarflare.com> writes:
> > >> On Thu, 2013-05-02 at 05:17 -0400, David Miller wrote:
> > >>> From: Bj=C3=B8rn Mork <bjorn@mork.no>
> > >>> Date: Thu, 02 May 2013 11:06:42 +0200
> > >>>
> > >>> > Adding the new netdev features will make it go from 1 to 2:
> > >>>
> > >>> We already had more than 31 feature bits before Patrick's
> > >>> changes, and I'm pretty sure this was the case when we added
> > >>> that ethtool API.
> > >>
> > >> It wasn't, but this should be OK.  Userland is supposed to query=
 the
> > >> number of features using ETHTOOL_GSSET_INFO and then work out th=
e number
> > >> of words/blocks using FEATURE_BITS_TO_BLOCKS().
> > >
> > >
> > > Looking at
> > > http://cgit.freedesktop.org/NetworkManager/NetworkManager/tree/sr=
c/platform/nm-linux-platform.c#n1025
> > > there seems to be a couple of bugs in this area. This is certainl=
y
> > > abusing the exported API, but it does mean that NM breaks if you =
ever
> > > move NETIF_F_VLAN_CHALLENGED (like the 802.1ad patch did):
> > >
> > > ----
> > > #define NETIF_F_VLAN_CHALLENGED (1 << 10)
> > >
> > > static gboolean
> > > link_supports_vlans (NMPlatform *platform, int ifindex)
> > > {
> > >         auto_nl_object struct rtnl_link *rtnllink =3D link_get (p=
latform,
> > >         ifindex);
> > >         const char *name =3D nm_platform_link_get_name (ifindex);
> > >         struct {
> > >                 struct ethtool_gfeatures features;
> > >                 struct ethtool_get_features_block features_block;
> > >         } edata =3D { .features =3D { .cmd =3D ETHTOOL_GFEATURES,=
 .size =3D 1 }
> > >         };
> > >
> > >         /* Only ARPHRD_ETHER links can possibly support VLANs. */
> > >         if (!rtnllink || rtnl_link_get_arptype (rtnllink) !=3D
> > >         ARPHRD_ETHER)
> > >                 return FALSE;
> > >
> > >         if (!name || !ethtool_get (name, &edata))
> > >                 return FALSE;
> > >
> > >         return !(edata.features.features[0].active &
> > >         NETIF_F_VLAN_CHALLENGED);
> > > }
> > > ----
> > >
> > >
> > > Not that I see how this particular bug matters unless you need VL=
AN
> > > support in NM.  But there could be similar issues around.  I gues=
s
> > > avoiding unnecessary renumbering of the NETIF_F bits can save us =
some
> > > trouble.  Although you can certainly argue that those bits never =
were
> > > intended to be part of the API, and that using them like this is =
a user
> > > application bug.
> >=20
> > This is certainly a bug in NM, and a fresh one: commit
> > b636ea86b1c0a28b77eda311c84d3b2417cad22e from 2013-04-10 14:40:58
> > (GMT). Userspace is expected to use ETHTOOL_GSTRINGS for
> > ETH_SS_FEATURES and find a corresponding bit position by feature na=
me
> > ("vlan-challenged" in this case).
> >=20
> > Cc: commit's author.
>=20
> Recorded the bug with NetworkManager bugzilla blocking the upcoming r=
elease:
>=20
> https://bugzilla.gnome.org/show_bug.cgi?id=3D699649
>=20
> The code is experimental and is not used by NetworkManager even in th=
e
> 'master' branch except by nm-platform's automated tests. Once we fix =
it, you
> don't need to worry about it.
>=20
> Thanks!
>=20
> Pavel

=46ixed in NetworkManager master:

commit 7aefd5b5f4547c294092753b5cc355c95763134a
Author: Dan Winship <danw@gnome.org>
Date:   Mon May 6 12:10:01 2013 -0400
=20
    platform: fix use of ethtool
  =20
    The bits in the result of ETHTOOL_GFEATURES are not in any defined
    order; you need to use ETHTOOL_GSTRINGS to get the names associated
    with each bit to find what each one does. Fix
    NMPlatformLinux:link_supports_vlans() to do this.
  =20
    https://bugzilla.gnome.org/show_bug.cgi?id=3D699649
=20
diff --git a/src/platform/nm-linux-platform.c b/src/platform/nm-linux-p=
latform.c
index 699c107..eeaeb2e 100644
--- a/src/platform/nm-linux-platform.c
+++ b/src/platform/nm-linux-platform.c
@@ -1024,6 +1024,40 @@ ethtool_get (const char *name, gpointer edata)
        return TRUE;
 }
=20
+static int
+ethtool_get_stringset_index (const char *ifname, int stringset_id, con=
st char *string)
+{
+       auto_g_free struct ethtool_sset_info *info;
+       auto_g_free struct ethtool_gstrings *strings;
+       guint32 len, i;
+
+       info =3D g_malloc0 (sizeof (*info) + sizeof (guint32));
+       info->cmd =3D ETHTOOL_GSSET_INFO;
+       info->reserved =3D 0;
+       info->sset_mask =3D 1ULL << stringset_id;
+
+       if (!ethtool_get (ifname, info))
+               return -1;
+       if (!info->sset_mask)
+               return -1;
+
+       len =3D info->data[0];
+
+       strings =3D g_malloc0 (sizeof (*strings) + len * ETH_GSTRING_LE=
N);
+       strings->cmd =3D ETHTOOL_GSTRINGS;
+       strings->string_set =3D stringset_id;
+       strings->len =3D len;
+       if (!ethtool_get (ifname, strings))
+               return -1;
+
+       for (i =3D 0; i < len; i++) {
+               if (!strcmp ((char *) &strings->data[i * ETH_GSTRING_LE=
N], string))
+                       return i;
+       }
+
+       return -1;
+}
+
 static gboolean
 link_supports_carrier_detect (NMPlatform *platform, int ifindex)
 {
@@ -1041,26 +1075,39 @@ link_supports_carrier_detect (NMPlatform *platf=
orm, int ifindex)
        return name && ethtool_get (name, &edata);
 }
=20
-#define NETIF_F_VLAN_CHALLENGED (1 << 10)
-
 static gboolean
 link_supports_vlans (NMPlatform *platform, int ifindex)
 {
        auto_nl_object struct rtnl_link *rtnllink =3D link_get (platfor=
m, ifindex);
        const char *name =3D nm_platform_link_get_name (ifindex);
-       struct {
-               struct ethtool_gfeatures features;
-               struct ethtool_get_features_block features_block;
-       } edata =3D { .features =3D { .cmd =3D ETHTOOL_GFEATURES, .size=
 =3D 1 } };
+       auto_g_free struct ethtool_gfeatures *features;
+       int index, block, bit, size;
=20
        /* Only ARPHRD_ETHER links can possibly support VLANs. */
        if (!rtnllink || rtnl_link_get_arptype (rtnllink) !=3D ARPHRD_E=
THER)
                return FALSE;
=20
-       if (!name || !ethtool_get (name, &edata))
+       if (!name)
+               return FALSE;
+
+       index =3D ethtool_get_stringset_index (name, ETH_SS_FEATURES, "=
vlan-challenged");
+       if (index =3D=3D -1) {
+               debug ("vlan-challenged ethtool feature does not exist?=
");
+               return FALSE;
+       }
+
+       block =3D index /  32;
+       bit =3D index % 32;
+       size =3D block + 1;
+
+       features =3D g_malloc0 (sizeof (*features) + size * sizeof (str=
uct ethtool_get_features_block));
+       features->cmd =3D ETHTOOL_GFEATURES;
+       features->size =3D size;
+
+       if (!ethtool_get (name, features))
                return FALSE;
=20
-       return !(edata.features.features[0].active & NETIF_F_VLAN_CHALL=
ENGED);
+       return !(features->features[block].active & (1 << bit));
 }
=20
 static gboolean
