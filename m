From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] ipv6: Do route updating for redirect in ndisc layer
Date: Thu, 12 Sep 2013 01:17:21 +0200
Message-ID: <20130911231721.GA24195@order.stressinduktion.org>
References: <522D7444.20505@cn.fujitsu.com> <20130910225023.GB4794@order.stressinduktion.org> <52301603.7030906@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org, dborkman@redhat.com,
	vyasevich@gmail.com
To: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:52076 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757700Ab3IKXRX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Sep 2013 19:17:23 -0400
Content-Disposition: inline
In-Reply-To: <52301603.7030906@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[added Cc to Daniel and Vlad because of ipv6/sctp/redirect problem]

On Wed, Sep 11, 2013 at 03:04:35PM +0800, Duan Jiong wrote:
> =E4=BA=8E 2013=E5=B9=B409=E6=9C=8811=E6=97=A5 06:50, Hannes Frederic =
Sowa =E5=86=99=E9=81=93:
> > On Mon, Sep 09, 2013 at 03:09:56PM +0800, Duan Jiong wrote:
> >> diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
> >> index 5c71501..61fe8e5 100644
> >> --- a/net/ipv6/tcp_ipv6.c
> >> +++ b/net/ipv6/tcp_ipv6.c
> >> @@ -382,14 +382,6 @@ static void tcp_v6_err(struct sk_buff *skb, s=
truct inet6_skb_parm *opt,
> >> =20
> >>  	np =3D inet6_sk(sk);
> >> =20
> >> -	if (type =3D=3D NDISC_REDIRECT) {
> >> -		struct dst_entry *dst =3D __sk_dst_check(sk, np->dst_cookie);
> >> -
> >> -		if (dst)
> >> -			dst->ops->redirect(dst, sk, skb);
> >> -		goto out;
> >> -	}
> >> -
> >=20
> > You dropped the "goto out" here in case of an NDISC_REDIRECT, so th=
is sends an
> > EPROTO further up the socket layer. Was this intended?
> >=20
>=20
> I'm sorry, i didn't notice the variable err was assigned to EPROTO.
> I only thought that message should be sent to the socket layer, becau=
se
> i found that in function sctp_v6_err().
>=20
> In addition, the rfc 4443 said the Redirect Message is not the ICMPv6=
 Error
> Message, so i think we shouldn't call those err_handler function, in =
other
> words we shouldn't call the icmpv6_notify().
>=20
> How do you think of this?

Hm, thats hard.

=46irst of, when the kernel started publishing these errors it had a
contract with user-space we cannot break now. This includes all error
handling functions which call ipv6_icmp_error. So we only have to care
about INET6_PROTO_FINAL protocols, bbecause they mostly operate in sock=
et
space (in this case these are the raw and the udp protocol and currentl=
y
sctp). Especially I do think it is important to report the redirects
to raw sockets. The other non-final protocols only need to be notified
for mtu reduction currently. Maybe we could stop notifying non-final
protocols for redirects, but I don't think this will improve things.

Also we cannot know if the router sending the redirect discarded the
original packet or if it forwarded it just notifying us of a better rou=
te,
so we don't know if an actual error happend. So I would do the same thi=
ng
as IPv4 sockets, set sk_err to zero and queue up the icmp packet on the
socket's error queue (for udp and raw).

Regarding notifying tcp sockets about the redirect seems wrong. It woul=
d
generate a poll notification and I do think it could even tear down
the whole connection.  I guess sctp should also stop updating sk_err
on redirects.  But let's Cc Daniel and Vlad about this. My guess is tha=
t
sctp could go into some error recovery mode because of this which would
be wrong.

So, for this patch I would leave the logic as is and not change anythin=
g
at the error reporting. Maybe Daniel and Vlad could check if we should
suppress redirect information for ipv6 in sctp, too? But this should
go into another patch.  Regarding the EPROTO problem in raw and udp,
let's see if all the problems go away if we update icmpv6_err_convert
to set *err to 0.

Greetings,

  Hannes
