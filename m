From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [RFC] MASQUERADE / policy routing ("Route send us somewhere
 else")
Date: Tue, 31 Aug 2004 15:33:22 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0408311446240.4022-100000@l>
References: <20040831111508.GA2327@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@davemloft.net>, <laforge@netfilter.org>,
        <netfilter-devel@lists.netfilter.org>, <rusty@rustcorp.com.au>,
        <netdev@oss.sgi.com>, <kuznet@ms2.inr.ac.ru>
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040831111508.GA2327@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


	Hello,

On Tue, 31 Aug 2004, Herbert Xu wrote:

> On Tue, Aug 31, 2004 at 01:54:21PM +0300, Julian Anastasov wrote:
> >
> > 	Yes, 2.2 worked somehow, until some users wanted more
> > control from the routing. Now ip_fw_compat_masq.c has such call,
> > it can be fast in some setups with small number of IPs but may
> > be now there some setups using nfmark for selecting maddr from
> > ISP-specific routing tables. I'm not sure we can avoid the routing
> > and the cache pollution, we have to live with the old behavoir, not
> > the current one.
>
> You're right.  However, we can still do this without performing
> another routing lookup.  The information is already there in the
> fib rule.  We just didn't bother writing it down in the route for
> forwarded packets.

	I do not see where the public IP is, what you mean? As the
mpath route does not have preferred src IP (usually when many ISPs
are used) the kernel uses inet_select_addr to select one, in similar
way as you are trying to do. But the difference is that it is now
cached and by using nfmark we have more options not to reach this
mpath route on next lookups.

	One example: the GWs used in the nexthops can be internal
addresses, in such cases inet_select_addr gets the first local (scope
global) public IP address because the target IP is not always part
from the GW's subnet. You can not rely on any information present
in the mpath route and to assume anything about maddr without specific
lookup, additional one.

> So if we add a new field for the preferred source address to
> struct rtable then we can avoid the lookup.

	What is this? Sort of 'nexthop via GW1 dev eth0 snat MADDR1' ?
This is the same as to use SNAT target. Similar thing worked very
well in 2.2 kernels (nat XXX) but only for unipath routes.

> BTW, I'd still like to know the problem with the original oif key.

	The old way to provide oif as key adds one additional
cache entry per every normal input route. Another issue is that
providing oif key can hit wrong route in some setups - not the
first match which we usually hit with oif=0. But for the usual
cases it works.

> It's basically saying that if you can find the correct route using
> the other keys (daddr/tos/mark) then all is well, if you can't
> (dev != out) then we'll use the best address on the outgoing
> interface.

	ip_route_output + inet_select_addr in 50% of the cases
for mpath route with 2 NHs?

	inet_select_addr is ok to use only when nfmark is not used,
it is even used now for multipath routes in the usual case when
prefsrc is not defined. But with the routing you have more control
on what to select as maddr. So, I'm for the old way which can
work for more setups and against inet_select_addr which can break 
existing ones.

Regards

--
Julian Anastasov <ja@ssi.bg>
