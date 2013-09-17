From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH  v3 0/6] ipv6: Do route updating for redirect in ndisc layer
Date: Tue, 17 Sep 2013 15:52:32 +0200
Message-ID: <20130917135232.GG13408@order.stressinduktion.org>
References: <5236EFEB.60106@cn.fujitsu.com> <5236F808.9050605@redhat.com> <523710CC.1090404@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Daniel Borkmann <dborkman@redhat.com>,
	Duan Jiong <duanj.fnst@cn.fujitsu.com>, davem@davemloft.net,
	netdev@vger.kernel.org,
	"linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>
To: Duan Jiong <djduanjiong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:34320 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752888Ab3IQNwd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Sep 2013 09:52:33 -0400
Content-Disposition: inline
In-Reply-To: <523710CC.1090404@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 16, 2013 at 10:08:12PM +0800, Duan Jiong wrote:
> =E4=BA=8E 2013/9/16 20:22, Daniel Borkmann =E5=86=99=E9=81=93:
> > On 09/16/2013 01:47 PM, Duan Jiong wrote:
> >> From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
> >>
> >> the ip6_redirect() could be replaced with
> >> ip6_redirect_no_header(), we could always use ip6_redirect()
> >> for route updating in ndisc layer and use the data of the
> >> redirected header option just for finding the socket to be
> >> notified and then notify user in protocols' err_handler.
> > If I get this right, it seems to me that this patchset actually con=
sists of two
> > different kind of changes:
> >
> > 1) Not notifying user space on ICMP redirects (net material)
> > 2) Simplify code for updating route in ndisc layer instead of error=
 handlers (net-next)
> >
> > Also, you do the *actual* change in the very last patch, which mean=
s that from
> > patch 1 to 5 we're in an inconsistent and buggy state unless we als=
o apply patch
> > number 6. It should actually be the other way around, that you firs=
t do the actual
> > change and then migrate users (also commit messages are quite terse=
).
>=20
> I make the patch set on net tree, not on net-next. Maybe those
> things should be done in two patch sets.

I have thought about going the other direction. Just make it one patch
and update the whole logic atomically in the git tree. So we won't have
any partial logic updates in the tree.

Please also rebase your series onto net from today, because Daniel's
patch regarding updating sk->sk_err in sctp went in yesterday.

> > Moreover, just looking at the SCTP part (sctp_err_lookup() function=
) ...
> >
> > /* RFC 4960, Appendix C. ICMP Handling
> >  *
> >  * ICMP6) An implementation MUST validate that the Verification Tag
> >  * contained in the ICMP message matches the Verification Tag of
> >  * the peer.  If the Verification Tag is not 0 and does NOT
> >  * match, discard the ICMP message.  If it is 0 and the ICMP
> >  * message contains enough bytes to verify that the chunk type is
> >  * an INIT chunk and that the Initiate Tag matches the tag of the
> >  * peer, continue with ICMP7.  If the ICMP message is too short
> >  * or the chunk type or the Initiate Tag does not match, silently
> >  * discard the packet.
> >  */
> > =20
> > ... it seems to me that we would simply ignore such RFC requirement=
s with
> > your patch for the sctp_v6_err() part.
> >
> > Care to elaborate? ;-)
>=20
> Sorry, i didn't notice that.
>=20
> According to the RFC requirements, it suggests that we can't update
> route for redirect in ndisc layer before calling into sctp_err_lookup=
(),
> because we must verify the ICMP Message. Now maybe we update route fo=
r
> redirect in ndisc layer is wrong.
>=20
> Do you have any idea?

IMO updating of routes in ndisc layer is fine. We already accept redire=
cts
(and also change routes) for sctp connections where the redirect packet=
 does
not contain any tag. Also it is debatable if redirects are counted as
icmp packets or merely just belong to the kind of neighbour discovery
packets which just use icmp framing (and so the sctp rfc would not say
anything about them).

As Daniel already said, it would be better to update the commit message
to clarify the reasons why this is ok (with some pointers to RFCs).

Greetings,

  Hannes
