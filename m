From: Mika Liljeberg <mika.liljeberg@welho.com>
Subject: Re: 2.4.21+ - IPv6 over IPv4 tunneling b0rked
Date: 11 Jul 2003 16:38:32 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1057930712.895.32.camel@hades>
References: <Pine.LNX.4.44.0307111446250.27865-100000@netcore.fi>
	 <1057925366.896.24.camel@hades>  <3F0EB227.50403@kolumbus.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: quoted-printable
Cc: Pekka Savola <pekkas@netcore.fi>, Andre Tomt <andre@tomt.net>,
   linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Mika =?ISO-8859-1?Q?Penttil=E4?= <mika.penttila@kolumbus.fi>
In-Reply-To: <3F0EB227.50403@kolumbus.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2003-07-11 at 15:48, Mika Penttil=E4 wrote:
> It turns out to be the (otherwise valid) check for  IFF_LOOPBACK for=20
> gateway's address in ip6_route_add() that gives EINVAL for prefix::, an=
d=20
> has nothing to do with iid being 0, just a coinsidence....

Not sure. Seems to me that ipv6_addr_type() flags the gateway address as
anycast. In ip6_route_addr() [2.5.74] we have:

        if (rtmsg->rtmsg_flags & RTF_GATEWAY) {
                struct in6_addr *gw_addr;
                int gwa_type;

                gw_addr =3D &rtmsg->rtmsg_gateway;
                ipv6_addr_copy(&rt->rt6i_gateway, &rtmsg->rtmsg_gateway);
                gwa_type =3D ipv6_addr_type(gw_addr);

                if (gwa_type !=3D (IPV6_ADDR_LINKLOCAL|IPV6_ADDR_UNICAST)=
) {
                        struct rt6_info *grt;

                        /* IPv6 strictly inhibits using not link-local
                           addresses as nexthop address.
                           Otherwise, router will not able to send redire=
cts.
                           It is very good, but in some (rare!) curcumsta=
nces
                           (SIT, PtP, NBMA NOARP links) it is handy to al=
low
                           some exceptions. --ANK
                         */
                        err =3D -EINVAL;
                        if (!(gwa_type&IPV6_ADDR_UNICAST))
                                goto out;

Looks like it would bail out here, unless I read the code wrong. How abou=
t:

                        if (!(gwa_type&(IPV6_ADDR_UNICAST|IPV6_ADDR_ANYCA=
ST)))
                                goto out;

	MikaL
