From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH v2] net: set default_ethtool_ops in register_netdevice
Date: Thu, 10 Jan 2013 12:41:43 +0100
Message-ID: <1357818103.17902.3.camel@jlt4.sipsolutions.net>
References: <20130109.235738.467651533138068641.davem@davemloft.net>
	 <20130110083641.GA5637@redhat.com>
	 <20130110.020729.1358020934840866117.davem@davemloft.net>
	 <20130110.021202.232771737304117743.davem@davemloft.net>
	 (sfid-20130110_111209_245287_89F0DC06)
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: sgruszka-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org,
	greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org, bjorn-yOkvZcmFvRU@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org,
	mirqus-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20130110.021202.232771737304117743.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> (sfid-20130110_111209_245287_89F0DC06)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 2013-01-10 at 02:12 -0800, David Miller wrote:

> >> On Wed, Jan 09, 2013 at 11:57:38PM -0800, David Miller wrote:
> >>> From: Stanislaw Gruszka <sgruszka-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> >>> Date: Tue, 8 Jan 2013 16:38:51 +0100
> >>>=20
> >>> > Since:
> >>> >=20
> >>> > commit 2c60db037034d27f8c636403355d52872da92f81
> >>> > Author: Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
> >>> > Date:   Sun Sep 16 09:17:26 2012 +0000
> >>> >=20
> >>> >     net: provide a default dev->ethtool_ops
> >>> >=20
> >>> > wireless core does not correctly assign ethtool_ops. In order t=
o fix
> >>> > the problem, move assignement of default_ethtool_ops to
> >>> > register_netdevice(). This is safe because both register_netdev=
ice()
> >>> > and dev_ethtool() are protected by RTNL lock.
> >>> >=20
> >>> > Patch is besed on hint of Micha=C5=82 Miros=C5=82aw.
> >>> >=20
> >>> > Signed-off-by: Stanislaw Gruszka <sgruszka-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> >>> > Cc: stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org # 3.7+
> >>> > ---
> >>> > v1 -> v2: change order of default_ethtool_ops initialization to=
 avoid
> >>> > the problem. Change the subject accordingly.
> >>>=20
> >>> I don't understand this.  Why is the assignment of default_ethtoo=
l_ops
> >>> at netdev allocation time not working?  Is wireless really not us=
ing
> >>> alloc_netdev*()?
> >>=20
> >> It does. This is done on individual cfg80211 drivers , i.e. on mac=
80211
> >> or full mac drivers. After alloc_netdev*() call, some cfg80211 dri=
vers
> >> provide they own ethtool_ops, but some do not. For them, wireless =
core
> >> provide generic cfg80211_ethtool_ops, which is assigned in
> >> NETDEV_REGISTER notify call:=20
> >>=20
> >>      if (!dev->ethtool_ops)
> >>              dev->ethtool_ops =3D &cfg80211_ethtool_ops;
> >>=20
> >> But after Eric's commit, dev->ethtool_ops is no longer NULL (on cf=
g80211
> >> drivers without custom ethtool_ops), but points to &default_ethtoo=
l_ops.
> >=20
> > The whole idea is to remove these kinds of NULL tests against
> > dev->ethtool_ops, thus creating the invariant that given any netdev
> > one must never be able to see a non-NULL value there.
>=20
> Of course I meant that we should never see a NULL value in
> dev->ethtool_ops.
>=20
> I would suggest fixing this by making the wireless core express it's
> intentions, that it wants to use a different default ethtool ops, to
> the netdev allocation layer.
>=20
> You have two way to do this:
>=20
> 1) Add default_ethtool_ops argument to alloc_netdev*().
>=20
> 2) Add a "netdev_set_default_ethtool_ops(netdev, ops)"

Neither of these work as (I think) you think they would :-)

The core wireless code doesn't allocate/register the netdev itself, the
driver does. It has to follow some constraints, but the wireless core
then hooks into the netdev notifier chain to be informed. While in the
notifier chain, it attempts to set ethtool ops, but they've long been
set already to the defaults. So that means the second way you suggested
won't work at that point any more, short of having the wireless core
code export its ethtool ops and drivers setting them.

Now arguably the wireless core code could provide its own
alloc_netdev*() wrappers, but is that really worth it? There are a lot
of possibilities there that we'd have to wrap.

johannes


--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
