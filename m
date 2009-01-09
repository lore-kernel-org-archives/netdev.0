From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: ip xfrm policy semantics
Date: Fri, 09 Jan 2009 19:09:02 +0200
Message-ID: <496784AE.6000505@iki.fi>
References: <49675C3E.6010109@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f17.google.com ([209.85.219.17]:43863 "EHLO
	mail-ew0-f17.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751690AbZAIRJC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2009 12:09:02 -0500
Received: by ewy10 with SMTP id 10so10326729ewy.13
        for <netdev@vger.kernel.org>; Fri, 09 Jan 2009 09:09:00 -0800 (PST)
In-Reply-To: <49675C3E.6010109@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Timo Ter=E4s wrote:
> So what I want is that locally generated / received packages should
> be protected by the ipsec policy. But forwarded GRE packets (that are
> masqueraded) should not get any xfrm treatment.
>=20
> It looks like that if xfrm out policy still affects the forwarded pac=
kets.
> If I add an overriding policy for the PPTP server, things seem to wor=
k
> better. But I'd rather not do that as it's a bit hacky.
>=20
> I was not able to find any authoritative place how netfilter and xfrm=
 policies
> and routing interact. The only thing I found was [1], but that seems =
to be
> inaccurate. Anyone care to shed light on this part?
>=20
> [1] http://www.strongswan.org/docs/netfilter.pdf

Ok, I tried to find what the code does. Apparently the ip_forward() cal=
ls=20
xfrm4_route_forward() which ends up doing __xfrm_route_forward() fallin=
g
back to xfrm_lookup() which is fixed to use XFRM_POLICY_OUT. So 'out'
policy is always used; even for packets that are being forwarded.

Ok, now I tried adding:
  policy in  src pptp-server
  policy out dst pptp-server
  policy out dst internal-pptp-client

all with high priority and policy 'none'. Now it looks like the packets
from pptp-client go out to internet properly. The connection tracking
entries are recorded, but the reply packets from pptp-server do not
get back to internal-pptp-client. Apparently the 'none' policy prevents
NAT to work.

And yes, when there is no XFRM policies at all, the PPTP connection
works great.

Any ideas what would the proper way to patch XFRM to distinguish if
forwarded packets should be touched or not?

There's several things that differ:
- gre inner protocol
- gre key
- input interface
- forwarded/local

I'm thinking the easiest way out is to make XFRM GRE aware and add
an upper layer match (like icmp code; we could have gre key). But
I'm out of good ideas how to properly tie the policy to be my
local gre interface specific.

- Timo

