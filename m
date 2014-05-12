From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] ipv6: update Destination Cache entries when gateway turn
 into host
Date: Mon, 12 May 2014 03:13:52 -0700
Message-ID: <1399889632.5495.116325721.7AF2C83C@webmail.messagingengine.com>
References: <536C4A74.2050103@cn.fujitsu.com>
 <1399856097.16759.116198185.2A93B8D8@webmail.messagingengine.com>
 <53703AFF.2040208@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Duan Jiong <duanj.fnst@cn.fujitsu.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from new2-smtp.messagingengine.com ([66.111.4.224]:59394 "EHLO
	new2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752740AbaELKNy convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 May 2014 06:13:54 -0400
In-Reply-To: <53703AFF.2040208@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, May 11, 2014, at 20:07, Duan Jiong wrote:
> =E4=BA=8E 2014=E5=B9=B405=E6=9C=8812=E6=97=A5 08:54, Hannes Frederic =
Sowa =E5=86=99=E9=81=93:
> > On Thu, May 8, 2014, at 20:24, Duan Jiong wrote:
> >>
> >> RFC 4861 states in 7.2.5:
> >>
> >> 	The IsRouter flag in the cache entry MUST be set based on the
> >>          Router flag in the received advertisement.  In those case=
s
> >>          where the IsRouter flag changes from TRUE to FALSE as a r=
esult
> >>          of this update, the node MUST remove that router from the
> >>          Default Router List and update the Destination Cache entr=
ies
> >>          for all destinations using that neighbor as a router as
> >>          specified in Section 7.3.3.  This is needed to detect whe=
n a
> >>          node that is used as a router stops forwarding packets du=
e to
> >>          being configured as a host.
> >>
> >> Currently, when dealing with NA Message which IsRouter flag change=
s from
> >> TRUE to FALSE, the kernel only removes router from the Default Rou=
ter List,
> >> and don't update the Destination Cache entries.
> >>
> >> Now in order to update those Destination Cache entries, i introduc=
e
> >> function rt6_clean_tohost().
> >>
> >> [...]
> >>
> >> +/*remove routers and update dst entries when gateway turn into ho=
st.*/
> >> +static int fib6_clean_tohost(struct rt6_info *rt, void *arg)
> >> +{
> >> +	struct in6_addr *gateway =3D (struct in6_addr *)arg;
> >> +
> >> +	if (((rt->rt6i_flags & (RTF_ADDRCONF | RTF_DEFAULT | RTF_GATEWAY=
))
> >> +	    =3D=3D (RTF_ADDRCONF | RTF_DEFAULT | RTF_GATEWAY))
> >> +	    && ipv6_addr_equal(gateway, &rt->rt6i_gateway)) {
> >> +		return -1;
> >> +	} else if (((rt->rt6i_flags & (RTF_GATEWAY | RTF_CACHE))
> >> +		      =3D=3D (RTF_GATEWAY | RTF_CACHE))
> >> +		    && ipv6_addr_equal(gateway, &rt->rt6i_gateway)) {
> >> +		rt->rt6i_flags |=3D RTF_REJECT;
> >> +		rt->dst.error =3D -ENETUNREACH;
> >> +	}
> >> +	return 0;
> >> +}
> >=20
> > I am not so happy with that but have not tried that.
> >=20
> > The Destination Cache you quote from the RFC (if you follow 7.3.3.)=
 actually refers to the neighbouring
> > subsystem, where we would need to generate subsequent errors in cas=
e we try to forward a packet
> > through a this particular router.
> >=20
> > The reason why I am not that happy is, that the semantics when neig=
hbour nodes are cleared is well
> > defined but we don't have that semantics when those rt6_nodes get c=
leared up. E.g. consider a router which just temporarily switches forwa=
rding off and on.
> >=20
> > I guess we need to inspect NTF_ROUTER flag in the output path someh=
ow. :/
>=20
> Why we need to inspect NTF_ROUTER flag?
> In my opinion, the problem is that we can't use the neighbour node as=
 next hop.

I agree. I don't see a problem with returning -1 from the function but =
with the case
where you originate errors from the routing table by setting rt->dst.er=
ror. These
entries have a lifetime governed by the gc.

Greetings,

  Hannes
