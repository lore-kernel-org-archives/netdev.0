From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH] net: ipv6: check route protocol when deleting routes
Date: Mon, 24 Apr 2017 18:48:57 +0900
Message-ID: <CAKD1Yr3cv+zZgZdjLMt7oac9kKAjFcht+j+JskFD_RsR61LRtA@mail.gmail.com>
References: <20161216083059.251368-1-grawity@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        lkml <linux-kernel@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Joel Scherpelz <jscherpelz@google.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>,
        Greg KH <gregkh@google.com>
To: =?UTF-8?Q?Mantas_Mikul=C4=97nas?= <grawity@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161216083059.251368-1-grawity@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Dec 16, 2016 at 5:30 PM, Mantas Mikul=C4=97nas <grawity@gmail.com> =
wrote:
> The protocol field is checked when deleting IPv4 routes, but ignored for
> IPv6, which causes problems with routing daemons accidentally deleting
> externally set routes (observed by multiple bird6 users).
>
> This can be verified using `ip -6 route del <prefix> proto something`.

I think this change might have broken userspace deleting routes that
were created by RAs. This is because the rtm_protocol returned to
userspace is actually synthesized only at route dump time by
rt6_fill_node:

        else if (rt->rt6i_flags & RTF_ADDRCONF) {
                if (rt->rt6i_flags & (RTF_DEFAULT | RTF_ROUTEINFO))
                        rtm->rtm_protocol =3D RTPROT_RA;
                else
                        rtm->rtm_protocol =3D RTPROT_KERNEL;
        }

but rt6_add_dflt_router and rt6_add_route_info add the route with a
protocol of 0, and 0 is silently upgraded to RTPROT_BOOT by
ip6_route_info_create.

        if (cfg->fc_protocol =3D=3D RTPROT_UNSPEC)
                cfg->fc_protocol =3D RTPROT_BOOT;
        rt->rt6i_protocol =3D cfg->fc_protocol;

So an app that was previously trying to delete routes looking at
rtm_proto, and issuing a delete with whatever rtm_proto was returned
by netlink, will result in this check failing because its passed-in
protocol (RTPROT_RA or RTPROT_KERNEL) will not match the actual FIB
value, which is RTPROT_BOOT.

I can't easily test on a vanilla kernel, but on a system running a
slightly modified 4.4.63, I see the code fail like this:

# ip -6 route show
2001:db8:64::/64 dev nettest100  proto kernel  metric 256  expires 291sec
fe80::/64 dev nettest100  proto kernel  metric 256
default via fe80::6400 dev nettest100  proto ra  metric 1024  expires 291se=
c
# ip -6 route flush
Failed to send flush request: No such process
# ip -6 route show
default via fe80::6400 dev nettest100  proto ra  metric 1024  expires 286se=
c

If so, it seems unfortunate to have brought this into -stable.

For non-stable kernels, it seems that the proper fix would be:

1. Ensure that when an RA creates a route, it properly sets
rtm_protocol at time of route creation.
2. When we dump routes to userspace, we don't overwrite the rtm_protocol.

I can try to write that up, but I'm not sure why the code doesn't do
this already. Perhaps there's a good reason for it. Yoshifuji, Hannes,
any thoughts?
