From: Sabrina Dubroca <sd@queasysnail.net>
Subject: Re: [PATCH net-next 1/3] uapi: add MACsec bits
Date: Thu, 10 Mar 2016 10:55:31 +0100
Message-ID: <20160310095531.GA6640@bistromath.redhat.com>
References: <cover.1456937772.git.sd@queasysnail.net>
 <08d3b90c1577276ccbb8ae1794f8c9842df5222d.1456937772.git.sd@queasysnail.net>
 <1457466768.24270.24.camel@sipsolutions.net>
 <20160309105142.GA32207@bistromath.redhat.com>
 <1457523263.2042.19.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Florian Westphal <fw@strlen.de>,
	Paolo Abeni <pabeni@redhat.com>, stephen@networkplumber.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35172 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935231AbcCJJzh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Mar 2016 04:55:37 -0500
Content-Disposition: inline
In-Reply-To: <1457523263.2042.19.camel@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Johannes,

2016-03-09, 12:34:23 +0100, Johannes Berg wrote:
> On Wed, 2016-03-09 at 11:51 +0100, Sabrina Dubroca wrote:
> > > > +	MACSEC_ATTR_ICV_LEN,
> > > > +	MACSEC_TXSA_LIST,
> > > > +	MACSEC_RXSC_LIST,
> > > > +	MACSEC_TXSC_STATS,
> > > > +	MACSEC_SECY_STATS,
> > > > +	MACSEC_ATTR_PROTECT,
> > >=20
> > > This seems a bit inconsistent, MACSEC_ATTR_* vs. MACSEC_*?
> >=20
> > Only the MACSEC_ATTR_* can be set, the others are just for dumping.
>=20
> Makes sense too.
>=20
> I tend to prefer the names having a consistent prefix to indicate the
> enum they're used in, which indicates the nesting level in nl80211 et=
c.
> and makes it easier to figure out in the code that they're used
> correctly (since accidentally mixing enums will give no warnings), bu=
t
> that's just personal preference I guess.

I see.  I like the verification aspect, I'm adapting the enums now.


> > > > +enum macsec_sa_list_attrs {
> > > > +	MACSEC_SA_LIST_UNSPEC,
> > > > +	MACSEC_SA,
> > > > +	__MACSEC_ATTR_SA_LIST_MAX,
> > > > +	MACSEC_ATTR_SA_LIST_MAX =3D __MACSEC_ATTR_SA_LIST_MAX - 1,
> > > > +};
> > >=20
> > > Again, without documentation, it seems odd to have an enum with
> > > just a
> > > single useful entry? If you just wanted an array you don't need
> > > this at
> > > all? The netlink nesting properties could be specified somewhere.
> >=20
> > Yes, in dump_secy(), I nest the TXSA_LIST, and then each SA
> > underneath
> > it.=C2=A0=C2=A0I'm not sure how that would work without the list.=C2=
=A0=C2=A0Can you have
> > an array without the dummy level of nesting?
>=20
>=20
> So, if I understand correctly, your message would be
> [
> =C2=A0 =C2=A0..., /* e.g. IFINDEX, perhaps */
> =C2=A0 =C2=A0TXSA_LIST -> [
> =C2=A0 =C2=A0 =C2=A0 =C2=A0MACSEC_SA -> [
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0MACSEC_ATTR_SA_AN -> ...,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0MACSEC_ATTR_SA_PN -> ...
> =C2=A0 =C2=A0 =C2=A0 =C2=A0],
> =C2=A0 =C2=A0 =C2=A0 =C2=A0MACSEC_SA -> [...],
> =C2=A0 =C2=A0 =C2=A0 =C2=A0MACSEC_SA -> [...],
> =C2=A0 =C2=A0 =C2=A0 =C2=A0...
> =C2=A0 =C2=A0],
> ]
>=20
> right? That seems pretty odd to me, usually the same nesting level in
> netlink shouldn't contain the same attribute multiple times, as I
> understand it.

Well, it worked ;)


> I *think* the way we do this in nl80211 is more customary, it would b=
e
> like this in your case (without defining the sa_list_attrs enum):
>=20
> [
> =C2=A0 =C2=A0..., /* e.g. IFINDEX, perhaps */
> =C2=A0 =C2=A0TXSA_LIST -> [
> =C2=A0 =C2=A0 =C2=A0 =C2=A01 -> [
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0MACSEC_ATTR_SA_AN -> ...,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0MACSEC_ATTR_SA_PN -> ...
> =C2=A0 =C2=A0 =C2=A0 =C2=A0],
> =C2=A0 =C2=A0 =C2=A0 =C2=A02 -> [...],
> =C2=A0 =C2=A0 =C2=A0 =C2=A03 -> [...],
> =C2=A0 =C2=A0 =C2=A0 =C2=A0...
> =C2=A0 =C2=A0],
> ]
>=20
> See, for example,=C2=A0nl80211_send_wowlan_patterns() which nests lik=
e this:
>=20
> [
> =C2=A0 =C2=A0=C2=A0NL80211_WOWLAN_TRIG_PKT_PATTERN -> [
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 1 -> [
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=C2=A0NL80211_PKTPAT_MASK ->=
 ...,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=C2=A0NL80211_PKTPAT_PATTERN=
 -> ...,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=C2=A0NL80211_PKTPAT_OFFSET =
-> ...,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 ],
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 2 -> [...],
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 ...
> =C2=A0 =C2=A0 ]
> ]

Ah, ok.  I'm using this now, no more dummy enum.  And thanks for the po=
inter!


> > These stats are defined by the standard, but marked optional.
> > A hardware device that doesn't implement some stat could just ignor=
e
> > it and export 0.
>=20
> Fair enough. I tend to think there could be a difference between
> knowing the value was 0 and knowing it wasn't provided, particularly
> for the "exceptions" that you'd hope are mostly 0 under good operatin=
g
> conditions, but I don't have a strong opinion about these or,
> obviously, any idea about whether hardware might not be able to provi=
de
> them.

Hmm, yeah, that makes sense.  I'll think about it a bit more, maybe I
will change that before I resubmit.  The separate attributes would
also help a bit in case we need to add more stats.


Thanks,

--=20
Sabrina
