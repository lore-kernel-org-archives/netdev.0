From: Debabrata Banerjee <dbavatar@gmail.com>
Subject: Re: [patch net] ipv6: do not create neighbor entries for local delivery
Date: Thu, 8 Aug 2013 14:45:40 -0400
Message-ID: <CAATkVEzJgb+J-TAkTZCUbxLPj=b=wbOmsKbgNNimEfNaC8d0Aw@mail.gmail.com>
References: <20130130082608.GA1604@minipsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"jmorris@namei.org" <jmorris@namei.org>,
	"yoshfuji@linux-ipv6.org" <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	"Banerjee, Debabrata" <dbanerje@akamai.com>,
	Joshua Hunt <johunt@akamai.com>
To: Jiri Pirko <jiri@resnulli.us>, mleitner@redhat.com,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qe0-f43.google.com ([209.85.128.43]:52958 "EHLO
	mail-qe0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966141Ab3HHSpl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Aug 2013 14:45:41 -0400
Received: by mail-qe0-f43.google.com with SMTP id k5so1924186qej.30
        for <netdev@vger.kernel.org>; Thu, 08 Aug 2013 11:45:40 -0700 (PDT)
In-Reply-To: <20130130082608.GA1604@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 30, 2013 at 3:26 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> From: Marcelo Ricardo Leitner <mleitner@redhat.com>
>
> They will be created at output, if ever needed. This avoids creating
> empty neighbor entries when TPROXYing/Forwarding packets for addresses
> that are not even directly reachable.
>
> Note that IPv4 already handles it this way. No neighbor entries are
> created for local input.
>
> Tested by myself and customer.
>
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> Signed-off-by: Marcelo Ricardo Leitner <mleitner@redhat.com>
> ---
>  net/ipv6/route.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> index e229a3b..363d8b7 100644
> --- a/net/ipv6/route.c
> +++ b/net/ipv6/route.c
> @@ -928,7 +928,7 @@ restart:
>         dst_hold(&rt->dst);
>         read_unlock_bh(&table->tb6_lock);
>
> -       if (!rt->n && !(rt->rt6i_flags & RTF_NONEXTHOP))
> +       if (!rt->n && !(rt->rt6i_flags & (RTF_NONEXTHOP | RTF_LOCAL)))
>                 nrt = rt6_alloc_cow(rt, &fl6->daddr, &fl6->saddr);
>         else if (!(rt->dst.flags & DST_HOST))
>                 nrt = rt6_alloc_clone(rt, &fl6->daddr);



I'm not sure this patch is doing the right thing. It seems to break
IPv6 loopback functionality, it is no longer equivalent to IPv4, as
stated above. It doesn't just stop neighbor creation but it stops
cached route creation. Seems like a scary change for a stable tree.
See below:

$ ip -4 route show local
local 127.0.0.0/8 dev lo  proto kernel  scope host  src 127.0.0.1

This local route enables us to use the whole loopback network, any
address inside 127.0.0.0/8 will work.

$ ping -c1 127.0.0.9
PING 127.0.0.9 (127.0.0.9) 56(84) bytes of data.
64 bytes from 127.0.0.9: icmp_seq=1 ttl=64 time=0.012 ms

--- 127.0.0.9 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 0.012/0.012/0.012/0.000 ms

This also used to work equivalently for IPv6 local loopback routes:

$ ip -6 route add local 2001:::/64 dev lo
$ ping6 -c1 2001::9
PING 2001::9(2001::9) 56 data bytes
64 bytes from 2001::9: icmp_seq=1 ttl=64 time=0.010 ms

--- 2001::9 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 0.010/0.010/0.010/0.000 ms

However with this patch, this is very broken:

$ ip -6 route add local 2001::/64 dev lo
$ ping6 -c1 2001::9
PING 2001::9(2001::9) 56 data bytes
ping: sendmsg: Invalid argument

--- 2001::9 ping statistics ---
1 packets transmitted, 0 received, 100% packet loss, time 0ms

Thanks,
Debabrata
