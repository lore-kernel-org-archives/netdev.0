From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next] IPv6: add option to use anycast addresses as source addresses in icmp error messages
Date: Wed, 15 Jan 2014 12:44:31 +0100
Message-ID: <20140115114431.GB19945@order.stressinduktion.org>
References: <1389779163.69122.YahooMailBasic@web125504.mail.ne1.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Bill Fink <billfink@mindspring.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki Yoshifuji <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: =?utf-8?Q?Fran=C3=A7ois-Xavier?= Le Bail <fx.lebail@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:38957 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751344AbaAOLod (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jan 2014 06:44:33 -0500
Content-Disposition: inline
In-Reply-To: <1389779163.69122.YahooMailBasic@web125504.mail.ne1.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

On Wed, Jan 15, 2014 at 01:46:03AM -0800, Fran=C3=A7ois-Xavier Le Bail =
wrote:
> On Tue, Jan 14, 2014 at 02:13:44PM +0100, Hannes Frederic Sowa wrote:
> > > On Mon, Jan 13, 2014 at 06:22:44PM +0100, Francois-Xavier Le Bail=
 wrote:
> > > > - Add "anycast_src_icmp_error" sysctl to control the use of any=
cast addresses
> > > >=C2=A0=C2=A0=C2=A0as source addresses for ICMPv6 error messages.=
 This sysctl is false by
> > > >=C2=A0=C2=A0=C2=A0default to preserve existing behavior.
> > > > - Use it in icmp6_send().
> > > >=20
> > > > Suggested-by: Bill Fink <billfink@mindspring.com>
> > > > Signed-off-by: Francois-Xavier Le Bail <fx.lebail@yahoo.com>
> > >=20
> > > Regarding the anycast patches, I contacted someone from IETF.
> > >=20
> > > The number of sysctls needed to get introduced to have all the fl=
exibility
> > > regarding source address selection and don't break backward compa=
tibility
> > > concerns me a bit.
> > >=20
> > > Especially on end hosts, where those switches will be important, =
I think we
> > > really have to think about sensible defaults without breaking cur=
rent
> > > software.
> > >=20
> > > I currently consider a per-address flag, if those anycast address=
es
> > > should be available in source address selection (also with an enh=
ancement to
> > > current IPV6_JOIN_ANYCAST logic).
> >=20
> > Francois, we should really think about this. Also if we should just
> > make the pre-defined subnet address just a normal anycast address i=
n the
> > long-term (which just happens to get automatically added to an inte=
rface
> > if forwarding is enabled) and bundle all the source address selecti=
on
> > logic on the per-address state.
>=20
> Please submit patches with your solution, so that we can have a basis
> for discussion.

I won't have time for that in the next weeks and this is not on the top=
 of my
TODO list, I fear :/ (I see what I can do).

Basically one would have to first start with address configuration supp=
ort for
IPv6 and then add a flag to ifa_flags (damn is IPv6 getting complex) so=
 one
could say

ip -6 a c fe80:: dev eth0 anycast anycast_pref

One easy thing would be to add this flag to the routing entries, but we=
 may
run into problems with limited flag-store-space there, too:

So something would be possible

bool ipv6_use_anycast_addr(struct rt6_info *rt)
{
	if ((rt->rt6i_flags & (RTF_ANYCAST|RTF_ANYCAST_PREF) =3D=3D (RTF_ANYCA=
ST|RTF_ANYCAST_PREF))
		return true;
	return false;
}

It seems you may eat a bit in the bit space of the generic RTF_ flags a=
nd use
flags to 32k (so adding in front of RTF_DEFAULT).

We could also link this flag to conditionally emit TCP-RSTs and ICMP er=
ror
messages with help of this flag.

Actually I don't like the solution with the rt6i_flags that much, I
would rather have this only in ifacaddr6 only. But lookup times will be
slower then.  Don't know yet.

So we would have to tackle this problem from the other direction first =
and
implement proper anycast management via iproute first and then alter th=
e
source address selection policies if we would go with something like th=
at.

Maybe anycast_pref is a bad name, anycast_reply or anycast_use_src woul=
d be
better.

> > If that would be the case, we could revert
> > 509aba3b0d366b7f16a9a2eebac1156b25f5f622 ("IPv6: add the option to =
use
> > anycast addresses as source addresses in echo reply") and thus woul=
d
> > eliminate one sysctl.
>=20
> If your solution achieve the same goal without this sysctl, I agree w=
ith you.

I think it does, what do you think?

> > It would be fine if we can make this decision before David merges w=
ith
> > Linus.=C2=A0 I guess we can still do this decision while in -rc pha=
se. But
> > as soon as the knob is in a released version of linux we can never =
take
> > it back (I really don't like sysctls).
>=20
> Sure.

Greetings,

  Hannes
