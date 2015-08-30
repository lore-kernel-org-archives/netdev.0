From: Peter =?UTF-8?B?TsO4cmx1bmQ=?= <pch@ordbogen.com>
Subject: Re: [PATCH v2 net-next 0/3] ipv4: Hash-based multipath routing
Date: Sun, 30 Aug 2015 23:28:29 +0200
Message-ID: <20150830232829.7e598151@tyr>
References: <1440792050-2109-1-git-send-email-pch@ordbogen.com>
	<20150829.131429.360433621593751136.davem@davemloft.net>
	<20150829223115.523553db@tyr>
	<20150829.134628.1013990034021542524.davem@davemloft.net>
	<CALx6S35AUXFKfazU4bbpNL90r7P8i3wSFTB_0YDDRUgKg-3vqw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, linux-api@vger.kernel.org,
	Roopa Prabhu <roopa@cumulusnetworks.com>, sfeldma@gmail.com,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Thomas Graf <tgraf@suug.ch>, Jiri Benc <jbenc@redhat.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.ordbogen.com ([91.240.88.21]:34438 "EHLO mail.ordbogen.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751704AbbH3V2k convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Aug 2015 17:28:40 -0400
In-Reply-To: <CALx6S35AUXFKfazU4bbpNL90r7P8i3wSFTB_0YDDRUgKg-3vqw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 29 Aug 2015 13:59:08 -0700
Tom Herbert <tom@herbertland.com> wrote:

> On Sat, Aug 29, 2015 at 1:46 PM, David Miller <davem@davemloft.net>
> wrote:
> > From: Peter N=C3=B8rlund <pch@ordbogen.com>
> > Date: Sat, 29 Aug 2015 22:31:15 +0200
> >
> >> On Sat, 29 Aug 2015 13:14:29 -0700 (PDT)
> >> David Miller <davem@davemloft.net> wrote:
> >>
> >>> From: pch@ordbogen.com
> >>> Date: Fri, 28 Aug 2015 22:00:47 +0200
> >>>
> >>> > When the routing cache was removed in 3.6, the IPv4 multipath
> >>> > algorithm changed from more or less being destination-based int=
o
> >>> > being quasi-random per-packet scheduling. This increases the
> >>> > risk of out-of-order packets and makes it impossible to use
> >>> > multipath together with anycast services.
> >>>
> >>> Don't even try to be fancy.
> >>>
> >>> Simply kill the round-robin stuff off completely, and make hash
> >>> based routing the one and only mode, no special configuration
> >>> stuff necessary.
> >>
> >> I like the sound of that! Just to be clear - are you telling me to
> >> stick with L3 and skip the L4 part?
> >
> > For now it seems best to just do L3 and make ipv4 and ipv6 behave
> > the same.
>=20
> This might be simpler if we just go directly to L4 which should be
> better load balancing and what most switches are doing anyway. The
> hash comes from:
>=20
> 1) If a lookup includes an skb, we just need to call skb_get_hash.
> 2) If we have a socket and sk->sk_txhash is nonzero then use that.
> 3) Else compute a hash frome flowi. We don't have the exact functions
> for this, but they can be easily derived from __skb_get_hash_flowi4
> and __skb_get_hash_flowi6 (i.e. create general get_hash_flowi4 and
> get_hash_flowi6 and then call these from skb functions and multipath
> lookup).

It would definitely be simpler, and it would be nice to just fetch the
hash directly from the NIC - and for link aggregation it would probably
be fine. But with L4, we always need to consider fragmented packets,
which might cause some packets of a flow to be routed differently - and
with ECMP, the ramifications of suddenly choosing another path for a
flow are worse than for link aggregation. The latency through the
different paths may differ enough to cause out-or-order packets and bad
TCP performance as a consequence. Both Cisco and Juniper routers
defaults to L3 for ECMP - exactly for that reason, I believe. RFC 2991
also points out that ports probably shouldn't be used as part of the
flow key with ECMP.

With anycast it is even worse. Depending on how anycast is used,
changing path may destroy a TCP connection. And without special
treatment of ICMP, ICMP packets may hit another anycast node, causing
PMTU to fail. Cloudflare recognized this and solved it by letting a
user space daemon (pmtud) route ICMP packets through all paths, ensurin=
g
that the anycast node receives the ICMP. But a more efficient solution
is to handle the issue within the kernel.

It might be possible to do L4 on flows using PMTU, and while it
is possible to extract addresses and ports from the ICMP payload, you
can't rely the DF-bit in the ICMP payload, since it comes from the
opposite flow (Flow A->B use PMTU while B->A doesn't). I guess you
can technically reduce the number of possible paths to two, though.

I obviously prefer the default to be L3 with ICMP handling, since I
specifically plan to use ECMP together with anycast (albeit anycasted
load balancers which synchronizes states, although delayed), but I also
recognizes that anycast is a special case. Question is, it is so much a
special case that it belongs outside the vanilla kernel?

Regards,
 Peter N=C3=B8rlund

>=20
> Tom
>=20
> > --
> > To unsubscribe from this list: send the line "unsubscribe netdev" i=
n
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
