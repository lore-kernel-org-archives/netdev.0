From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH net-next 1/3] uapi: add MACsec bits
Date: Wed, 09 Mar 2016 12:34:23 +0100
Message-ID: <1457523263.2042.19.camel@sipsolutions.net>
References: <cover.1456937772.git.sd@queasysnail.net>
	 <08d3b90c1577276ccbb8ae1794f8c9842df5222d.1456937772.git.sd@queasysnail.net>
	 <1457466768.24270.24.camel@sipsolutions.net>
	 <20160309105142.GA32207@bistromath.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Florian Westphal <fw@strlen.de>,
	Paolo Abeni <pabeni@redhat.com>, stephen@networkplumber.org
To: Sabrina Dubroca <sd@queasysnail.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:48760 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752422AbcCILe2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Mar 2016 06:34:28 -0500
In-Reply-To: <20160309105142.GA32207@bistromath.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-03-09 at 11:51 +0100, Sabrina Dubroca wrote:

> > > +#define DEFAULT_CIPHER_NAME "GCM-AES-128"
> > > +#define DEFAULT_CIPHER_ID=C2=A0=C2=A0=C2=A00x0080020001000001ULL
> > > +#define DEFAULT_CIPHER_ALT=C2=A0=C2=A00x0080C20001000001ULL
> >=20
> > > +enum macsec_attrs {
> > [...]
> > > +	MACSEC_ATTR_CIPHER_SUITE,
> >=20
> > should that be the ID, the alternate ID, or the string?
>=20
> uh, the string is never actually used, I could get rid of it.

Heh, ok. I was actually wondering about the string but didn't look up
where/if it was used :)

> > > +	MACSEC_ATTR_ICV_LEN,
> > > +	MACSEC_TXSA_LIST,
> > > +	MACSEC_RXSC_LIST,
> > > +	MACSEC_TXSC_STATS,
> > > +	MACSEC_SECY_STATS,
> > > +	MACSEC_ATTR_PROTECT,
> >=20
> > This seems a bit inconsistent, MACSEC_ATTR_* vs. MACSEC_*?
>=20
> Only the MACSEC_ATTR_* can be set, the others are just for dumping.

Makes sense too.

I tend to prefer the names having a consistent prefix to indicate the
enum they're used in, which indicates the nesting level in nl80211 etc.
and makes it easier to figure out in the code that they're used
correctly (since accidentally mixing enums will give no warnings), but
that's just personal preference I guess.

> > > +enum macsec_sa_list_attrs {
> > > +	MACSEC_SA_LIST_UNSPEC,
> > > +	MACSEC_SA,
> > > +	__MACSEC_ATTR_SA_LIST_MAX,
> > > +	MACSEC_ATTR_SA_LIST_MAX =3D __MACSEC_ATTR_SA_LIST_MAX - 1,
> > > +};
> >=20
> > Again, without documentation, it seems odd to have an enum with
> > just a
> > single useful entry? If you just wanted an array you don't need
> > this at
> > all? The netlink nesting properties could be specified somewhere.
>=20
> Yes, in dump_secy(), I nest the TXSA_LIST, and then each SA
> underneath
> it.=C2=A0=C2=A0I'm not sure how that would work without the list.=C2=A0=
=C2=A0Can you have
> an array without the dummy level of nesting?


So, if I understand correctly, your message would be
[
=C2=A0 =C2=A0..., /* e.g. IFINDEX, perhaps */
=C2=A0 =C2=A0TXSA_LIST -> [
=C2=A0 =C2=A0 =C2=A0 =C2=A0MACSEC_SA -> [
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0MACSEC_ATTR_SA_AN -> ...,
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0MACSEC_ATTR_SA_PN -> ...
=C2=A0 =C2=A0 =C2=A0 =C2=A0],
=C2=A0 =C2=A0 =C2=A0 =C2=A0MACSEC_SA -> [...],
=C2=A0 =C2=A0 =C2=A0 =C2=A0MACSEC_SA -> [...],
=C2=A0 =C2=A0 =C2=A0 =C2=A0...
=C2=A0 =C2=A0],
]

right? That seems pretty odd to me, usually the same nesting level in
netlink shouldn't contain the same attribute multiple times, as I
understand it.

I *think* the way we do this in nl80211 is more customary, it would be
like this in your case (without defining the sa_list_attrs enum):

[
=C2=A0 =C2=A0..., /* e.g. IFINDEX, perhaps */
=C2=A0 =C2=A0TXSA_LIST -> [
=C2=A0 =C2=A0 =C2=A0 =C2=A01 -> [
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0MACSEC_ATTR_SA_AN -> ...,
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0MACSEC_ATTR_SA_PN -> ...
=C2=A0 =C2=A0 =C2=A0 =C2=A0],
=C2=A0 =C2=A0 =C2=A0 =C2=A02 -> [...],
=C2=A0 =C2=A0 =C2=A0 =C2=A03 -> [...],
=C2=A0 =C2=A0 =C2=A0 =C2=A0...
=C2=A0 =C2=A0],
]

See, for example,=C2=A0nl80211_send_wowlan_patterns() which nests like =
this:

[
=C2=A0 =C2=A0=C2=A0NL80211_WOWLAN_TRIG_PKT_PATTERN -> [
=C2=A0 =C2=A0 =C2=A0 =C2=A0 1 -> [
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=C2=A0NL80211_PKTPAT_MASK -> .=
=2E.,
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=C2=A0NL80211_PKTPAT_PATTERN -=
> ...,
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=C2=A0NL80211_PKTPAT_OFFSET ->=
 ...,
=C2=A0 =C2=A0 =C2=A0 =C2=A0 ],
=C2=A0 =C2=A0 =C2=A0 =C2=A0 2 -> [...],
=C2=A0 =C2=A0 =C2=A0 =C2=A0 ...
=C2=A0 =C2=A0 ]
]

> These stats are defined by the standard, but marked optional.
> A hardware device that doesn't implement some stat could just ignore
> it and export 0.

=46air enough. I tend to think there could be a difference between
knowing the value was 0 and knowing it wasn't provided, particularly
for the "exceptions" that you'd hope are mostly 0 under good operating
conditions, but I don't have a strong opinion about these or,
obviously, any idea about whether hardware might not be able to provide
them.

johannes
