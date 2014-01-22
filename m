From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next] IPv6: enable TCP to use an anycast address
Date: Wed, 22 Jan 2014 22:59:30 +0100
Message-ID: <20140122215930.GE7269@order.stressinduktion.org>
References: <1390401156.61208.YahooMailBasic@web125501.mail.ne1.yahoo.com> <CAMrnHh5od13Ydo12Dt4OTa3nw+5om5LYO53iu9nQYqWeBxMPAw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?utf-8?Q?Fran=C3=A7ois-Xavier?= Le Bail <fx.lebail@yahoo.com>,
	netdev@vger.kernel.org, David Stevens <dlstevens@us.ibm.com>,
	David Miller <davem@davemloft.net>,
	Hideaki Yoshifuji <yoshfuji@linux-ipv6.org>
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:58964 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751379AbaAVV7b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jan 2014 16:59:31 -0500
Content-Disposition: inline
In-Reply-To: <CAMrnHh5od13Ydo12Dt4OTa3nw+5om5LYO53iu9nQYqWeBxMPAw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

On Thu, Jan 23, 2014 at 01:11:52AM +0400, Alexey Kuznetsov wrote:
> On Wed, Jan 22, 2014 at 6:32 PM, Fran=C3=A7ois-Xavier Le Bail
> <fx.lebail@yahoo.com> wrote:
> >> Actually, I was alerted by reset processing in your patch, it cann=
ot be right.
> >
> > Perhaps, I missed something.
>=20
> Perhaps, I missed something. According to my old knowledge, tcp canno=
t
> be used with anycasts
> by many reasons and I have no idea what could change to the moment.
>=20
> F.e. what do you do when a segment arrives on listening socket w/o
> connection associated?
> If you sent reset, you could reset someone's valid connection (I mean
> this, saying "it cannot be right").
> If you do not, you violate protocol, those resets are required to
> clean up stale states.

When using anycast addresses with routing protocols, like e.g. anycast
bgp one cannot make the distinction in the kernel at all. Operators
currently depend on the BGP being stable enough so that the anycast
destination towards one server remains stable during the whole connecti=
on.

In case a flap happens, of course, packets can end up at a different se=
rver
and will get a RST. I guess this currently works well enough for anycas=
t
network operators. Most DNS server use this model currently and DNS dep=
ends on
UDP and TCP being reachable for name resolution.

But this change does affect anycast IPv6 only in one subnet. If an anyc=
ast
address is allocated in the kernel, neighbour discovery logic tries as
hard to stick to one particular neighbour in the current subnet by alwa=
ys
sending neighbour advertisments with non-override flag. So in case we
need to reprobe the hardware address for the anycast neighbour, we will
get multiple answers and will pick that one which does not override the
current address. In case the anycast server really disappears from the
network, we could end up in a situation where the TCP packet gets send
to the wrong server which could result in a RST. IMHO this is acceptabl=
e,
but I may be wrong here. What is your opinion on that?

> >> Do not you think this must not be enabled for common use? At least
> >> some separate sysctl disabled by default.
> >
> > We could indeed use a sysctl, disabled by default.
> >
> > But my goal was to enable anycast address usage transparently, if p=
ossible.
>=20
> IMHO it is logically impossible. That's why my first question was
> about a document which
> allowed anycasts with TCP. (BTW I found your answer unconvincing, at =
least.)
> Traditional anycasting used to be stateless and it was impossible to
> use with TCP
> because unsynchronized TCP connections would be unavoidable.
> AFAIK only suggestion from ancient RFC1546 could cure this problem,
> but it is very tricky and implies client knows that destination is an=
ycast.
>=20
> Actually, I do not even understand how the idea of use of anycast wit=
h TCP
> emerged. The only situation I can imagine: the router is expected to
> do full scale
> connection tracking and to bind connections to anycast destinations t=
o
> correct nodes.
> (And the same moment you understand that the notion of anycast is
> completely lost
> in this picture: the same thing is done by load balancers in IPv4 for
> unicast addresses
> for ages) I still have no idea how it is going to work when both
> client and servers bound
> to anycasts are on the same link.
>=20
> So, it looks like you need this sysctl to announce: "someone cares
> about proper routing
> on this network and tcp should work". It looks obvious this mode
> cannot be enabled by default.

IMHO it would be ok if a tcp socket binds to an anycast address, becaus=
e the
administrator or software can check either for the pre-defined ones (th=
e
subnet router anycast address) or the application allocated an anycast =
via
setsockopt specifically (the address could also be requested by another
process and the tcp socket could bind to it by accident, that might be =
a
problem. If we want to protect from this scenario we must add a new sys=
ctl
knob.).

We don't use anycast addresses for normal source address selection, so =
if the
application does not specifically set the anycast address it will alway=
s use a
unicast one.

Greetings,

  Hannes
