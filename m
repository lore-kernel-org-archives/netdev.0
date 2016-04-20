From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH net-next v5] rtnetlink: add new RTM_GETSTATS message to
 dump link stats
Date: Wed, 20 Apr 2016 15:17:08 +0200
Message-ID: <1461158228.2176.18.camel@sipsolutions.net>
References: <20160418.214851.122286645854721047.davem@davemloft.net>
	 <20160418.235207.395468709808133833.davem@davemloft.net>
	 <1461060543.2766.20.camel@sipsolutions.net>
	 <20160419.142324.1774057494079734967.davem@davemloft.net>
	 <1461094901.2766.26.camel@sipsolutions.net>
	 <5716E123.8040002@cumulusnetworks.com>
	 <1461137540.2176.5.camel@sipsolutions.net>
	 <20160420144828.5537dce7@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Ahern <dsa@cumulusnetworks.com>,
	David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	roopa@cumulusnetworks.com, netdev@vger.kernel.org,
	jhs@mojatatu.com, tgraf@suug.ch, nicolas.dichtel@6wind.com,
	egrumbach@gmail.com
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:56606 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753796AbcDTNRQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Apr 2016 09:17:16 -0400
In-Reply-To: <20160420144828.5537dce7@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-04-20 at 14:48 +0200, Jiri Benc wrote:
> On Wed, 20 Apr 2016 09:32:20 +0200, Johannes Berg wrote:
> >=20
> > 2) Use the new attribute flag with some required attribute for
> > =C2=A0 =C2=A0existing commands, so that older kernel will not find =
the
> > required
> > =C2=A0 =C2=A0attribute and will reject the operation entirely.
> > =C2=A0 =C2=A0May or may not fall back to trying the operation again=
 without
> > the
> > =C2=A0 =C2=A0flag.
> This is basically what I submitted half a year ago. See:
> http://thread.gmane.org/gmane.linux.network/382850
>=20

That looks like a *huge* patchset though - whereas my proposal really
required only what Emmanuel sent in this thread. It did make some
assumptions, for example that any attribute lower than the "maxtype"
argument to nla_parse() was understood. [1]

Looks like you have this on a per-message basis. I thought it was
better on an attribute basis because that's really where the issue is.

You can still detect it with the per-attribute flag approach as I
described in (2) - if, for your lwtunnel example, you could specify the
flag on the=C2=A0RTA_ENCAP attribute, without which no lwtunnel can be
created (if I understand the code correctly.)

johannes



[1] for example, if I have three attributes:
enum attrs {__unused, A, B, C};

and the policy

policy =3D {
	[A] =3D { .type =3D NLA_U32 },
	[C] =3D { .type =3D NLA_U8 },
}

and then do

nla_parse(tb, 3, msg, msg_len, &policy)

it would assume that "B" is valid. Since this policy is equivalent to
the policy with
	[B] =3D { .type =3D NLA_BINARY }

(minimum length 0) we could also reject anything that has type=3Dlen=3D=
0 in
the policy, if the=C2=A0NLA_F_NET_MUST_PARSE flag is set in the nla_typ=
e.

This would likely be the right approach for most netlink families,
since they usually don't have holes that they actually care about -
I've yet to see any attribute that's not specified at all in the policy
but used anyway, normally you want some level of checking, and indicate
that by using { .type =3D NLA_BINARY } - but other things are possible.

johannes
