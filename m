From: "Marco Berizzi" <pupilla@hotmail.com>
Subject: Re: ipsec tunnel policy vs routing table
Date: Thu, 27 Jul 2006 16:06:44 +0200
Message-ID: <BAY103-F281E5B6AC611062170572AB2580@phx.gbl>
References: <E1G63xV-0004LN-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bay0-omc3-s38.bay0.hotmail.com ([65.54.246.238]:12982 "EHLO
	bay0-omc3-s38.bay0.hotmail.com") by vger.kernel.org with ESMTP
	id S1751329AbWG0OGs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Jul 2006 10:06:48 -0400
In-Reply-To: <E1G63xV-0004LN-00@gondolin.me.apana.org.au>
To: herbert@gondor.apana.org.au
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:

>Marco Berizzi <pupilla@hotmail.com> wrote:
> >
> > 172.16.0.0/23 dev eth2  proto kernel  scope link  src 172.16.1.1
> > 10.180.0.0/16 via 172.16.1.253 dev eth2
> > 10.0.0.0/8 via pub_ip dev eth0
> > 127.0.0.0/8 dev lo  scope link
> >
> > I have noticed that packets for 10.180.0.0/16 network
> > are eaten by the ipsec tunnel because the policy allow
> > them. Is there a way to deliver packets for 10.180.0.0
> > network to the 172.16.1.253 router (because the route
> > to 10.180.0.0 is more specific than 10.0.0.0/8)?
>
>You need an IPsec pass action.  With Openswan you can do it with
>something like
>
>conn pass
>	left=%defaultroute
>	# This should be the leftsubnet of your 10.0.0.0/8 connection.
>	leftsubnet=0.0.0.0/0
>	# This field doesn't really matter.
>	right=172.16.1.253
>	rightsubnet=10.180.0.0/16
>         type=passthrough
>         authby=never
>         auto=route

Thanks for the tip Herbert.
Ok I have inserted this section in openswan init
file (ipsec.conf)

conn pass
	left=172.16.1.1
	leftsubnet=172.16.0.0/23
	right=172.16.1.253
	rightsubnet=10.180.0./16
	type=passthrough
	authby=never
	auto=route

After running 'ipsec auto --add pass && ipsec auto
--route pass' openswan has eaten my static route
inserted by hand:
route add -net 10.180.0.0/16 gw 172.16.1.253
Here is 'ip r s' output after 'ipsec auto --route
pass':
172.16.0.0/23 dev eth2  proto kernel  scope link  src 172.16.1.1
10.180.0.0/16 dev eth2  scope link

All if fine now. It isn't even needed anymore to
insert the static route now, as it is placed by
openswan. My question is how linux understand that
it should send packets for 10.180.0.0/24 to the
172.16.1.253 router.


