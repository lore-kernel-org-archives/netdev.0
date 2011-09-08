From: "Yan, Zheng " <yanzheng@21cn.com>
Subject: Re: possible routing table cache bug for mtu/advmss attributes in
 Linux 3.0.4
Date: Thu, 8 Sep 2011 22:42:20 +0800
Message-ID: <CAAM7YA=t=s5EEVFte84oqWaKfqyoNhX_NsE5xWUKJ53u-+Es=g@mail.gmail.com>
References: <20110901214643.GA16989@aldebaran.gro-tsen.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Netdev Mailing-List <netdev@vger.kernel.org>
To: David Madore <david+ml@madore.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:59287 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751458Ab1IHOmW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Sep 2011 10:42:22 -0400
Received: by eyx24 with SMTP id 24so559047eyx.19
        for <netdev@vger.kernel.org>; Thu, 08 Sep 2011 07:42:21 -0700 (PDT)
In-Reply-To: <20110901214643.GA16989@aldebaran.gro-tsen.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 2, 2011 at 5:46 AM, David Madore <david+ml@madore.org> wrot=
e:
> Hi,
>
> I believe I've found a bug in the routing cache (perhaps only for
> IPv6) in Linux 3.0.4. =A0Since I'm uncertain about the diagnosis, I'm
> posting here for guidance as to how to proceed.
>
> In a nutshell, the problem is this: my (manually entered) routing
> tables specify an explicit MTU/MSS for certain IPv6 routes, and after
> upgrading from 2.6.38.7 to 3.0.4, I found that this MTU/MSS setting i=
s
> sometimes ignored. =A0More precisely, it seems that connecting to a h=
ost
> through the route in question causes a routing cache entry to be
> created, and it is when this cache entry expires that the route
> forgets the MTU/MSS setting. =A0(It may also be relevant that in my c=
ase
> the route belongs to a routing table other than "main".)
>
> In more details: my routing tables contains the following:
>
> vega david ~ $ sudo ip -6 rule show
> 0: =A0 =A0 =A0from all lookup local
> 32766: =A0from all lookup main
> 40000: =A0from 2002::/16 lookup 2002
> 40100: =A0from all lookup 2001
> vega david ~ $ sudo ip -6 route show table 2001
> 2002::/16 via ::192.88.99.1 dev tun6to4 =A0metric 512 =A0mtu 1466 adv=
mss 1406
> 2000::/3 dev ppp0 =A0metric 64 =A0mtu 1466 advmss 1406
>
> Initially, trying to get the route to 2001:41d0:1:a431::1 correctly
> returns route with the mtu and advmss values I entered:
>
> vega david ~ $ sudo ip route get 2001:41d0:1:a431::1
> 2001:41d0:1:a431::1 from :: via 2001:41d0:1:a431::1 dev ppp0 =A0src 2=
001:7a8:78ae::1 =A0metric 0
> =A0 =A0cache =A0mtu 1466 advmss 1406
>
> Now I start an ssh connection to 2001:41d0:1:a431::1, close it
> immediately, and fetch the route again:
>
> vega david ~ $ sudo ip route get 2001:41d0:1:a431::1
> 2001:41d0:1:a431::1 from :: via 2001:41d0:1:a431::1 dev ppp0 =A0src 2=
001:7a8:78ae::1 =A0metric 0
> =A0 =A0cache =A0mtu 1466 rtt 37ms rttvar 37ms cwnd 10 advmss 1406
>
> This is still correct. =A0But if I wait a few seconds (doing nothing)
> for these data to expire, they seems to take the mtu and advmss value=
s
> away with them:
>
> vega david ~ $ sudo ip route get 2001:41d0:1:a431::1
> 2001:41d0:1:a431::1 from :: via 2001:41d0:1:a431::1 dev ppp0 =A0src 2=
001:7a8:78ae::1 =A0metric 0
> =A0 =A0cache
>
> (note the empty "cache" line and the absence of mtu/advmss settings).
>
> This is not just wrongly reported: the route really is wrong, and
> opening a TCP connection at this stage will use a wrong MSS (and
> freeze on large packets, because my Internet provider is worthless,
> but that's another story). =A0At some point the route seems to return=
 to
> normal, but I couldn't figure out what causes this exactly.
>
> In case it's uesful, my kernel config is on <URL:
> http://www.madore.org/~david/.tmp/config-3.0.4-vega
> =A0>.
>

Would you please try patch http://marc.info/?l=3Dlinux-netdev&m=3D13152=
9445904858

Thanks

> Any thoughts?
>
> --
> =A0 =A0 David A. Madore
> =A0 ( http://www.madore.org/~david/ )
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.
