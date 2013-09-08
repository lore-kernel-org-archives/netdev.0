From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v4] ipv6:introduce function to find route for redirect
Date: Sun, 8 Sep 2013 20:00:52 +0200
Message-ID: <20130908180052.GB21070@order.stressinduktion.org>
References: <52242CE1.5050501@cn.fujitsu.com> <20130902195056.GA5451@order.stressinduktion.org> <5225758F.8080604@cn.fujitsu.com> <20130903191729.GA28889@order.stressinduktion.org> <52272233.20307@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:44946 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753834Ab3IHSAy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Sep 2013 14:00:54 -0400
Content-Disposition: inline
In-Reply-To: <52272233.20307@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 04, 2013 at 08:06:11PM +0800, Duan Jiong wrote:
> =E4=BA=8E 2013=E5=B9=B409=E6=9C=8804=E6=97=A5 03:17, Hannes Frederic =
Sowa =E5=86=99=E9=81=93:
> > On Tue, Sep 03, 2013 at 01:37:19PM +0800, Duan Jiong wrote:
> >>> Btw. I still think it should be possible to eliminate
> >>> ip6_redirect_no_header:
> >>>
> >>> We could always use ip6_redirect_no_header and use the data of th=
e redirected
> >>> header option just for finding the socket to be notified. We can =
do the whole
> >>> verification and route updating in ndisc layer and then just call=
 into icmpv6
> >>> layer if upper protocols need a notification of the redirect. But=
 that should
> >>> go into another patch. ;)
> >>>
> >>
> >> I think this is good, but i have a question below:
> >>
> >>   if the socket type is connection-based, the dst information is s=
tored in related
> >> sock struct, so there is no need to look up the route for redirect=
 in ip6_redirect
> >> or ip6_redirect_no_header, in this case, we do the verification an=
d route=20
> >> updating in the upper protocols' err_handler is better.=20
> >>
> >> How do you think of this?
> >=20
> > This should not be a problem, because every cached dst should be va=
lidated
> > with ip6_dst_check before it is used. It uses the fib6_node serial =
number
> > which is incremented for all fib6_nodes on the path to the new inst=
alled
> > node by fib6_add_1. So we are safe here.
> >=20
> > Btw. this is the same logic redirects get currently picked up, too.
> >=20
>=20
> Thanks for you answer, but i still have some questions on dealing wit=
h redirect
> in ip4ip6_err() and ipip6_err(), and i need some time to learn more a=
bout them.
> So i only send one patch to fix the bug.

Coverity discovered that the redirect code in ip6_tunnel.c is logically
dead, which is correct:

    639         }
    640         if (rel_type =3D=3D ICMP_REDIRECT)
    641                 skb_dst(skb2)->ops->redirect(skb_dst(skb2), NUL=
L, skb2);
    642=20
    643         icmp_send(skb2, rel_type, rel_code, htonl(rel_info));

rel_type will never be ICMP_REDIRECT in line 640 because of the updates
to rel_type in ip6_tnl_err.

My guess is that we need to move the call to ->redirect to ip6_tnl_err
and afterwards set rel_msg to 0 or we factor out the calls to ->redirec=
t
into the ndisc layer.

I hope this clears up some confusion you had in ip6ip6_err.

Greetings,

  Hannes
