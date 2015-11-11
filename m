From: Julian Anastasov <ja@ssi.bg>
Subject: Re: ipv4: ip unreachable with SO_BINDTODEVICE socket
Date: Thu, 12 Nov 2015 00:54:23 +0200 (EET)
Message-ID: <alpine.LFD.2.11.1511112252001.1699@ja.home.ssi.bg>
References: <87egfxjd9o.fsf@pingu.sky.yk.fujitsu.co.jp>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Kouya Shimura <kouya@jp.fujitsu.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87egfxjd9o.fsf@pingu.sky.yk.fujitsu.co.jp>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


	Hello,

On Wed, 11 Nov 2015, Kouya Shimura wrote:

> Hi
> 
> When both server and client are on the same machine and each their
> socket option is set to SO_BINDTODEVICE, sometimes a packet doesn't
> reach to the server.
> 
> The reproducible test program is attached. (modify "IF_ADDR=, IP_ADDR=,
> PORT=" lines appropriately).  Please try 'taskset -c 1 python test.py'
> since per cpu data (rt_cache) affects results.  Also 'tcpdump -i lo'
> is helpful for testing.  you can see "ICMP udp port unreachable".
> 
> In this test program, a packet doesn't pass through the bound
> interface but 'lo' interface. So, it might be granted that local
> communication with SO_BINDTODEVICE socket fails. However, dnsmasq and
> dhcp_release commands rely on it (Actually I've found this issue on
> the OpenStack envirionment) and the test program works well on
> linux-2.6.32 but doesn't work on linux-3.10.0 and 4.3.0.
> 
> I'd like to know whether this is a kernel bug or the specification of
> SO_BINDTODEVICE.

	My man page does not indicate that SO_BINDTODEVICE
should be relaxed for traffic from loopback but for old
kernels it was really working in this way due to caching
of different orig_oif values and even for mcast/bcast
because ip_mc_output() does not use "lo" for loopback.

> The attached patch fixes this issue, but no confidence this is a
> right modification.

> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index 85f184e..546cabe 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -2027,7 +2027,7 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
>                         prth = raw_cpu_ptr(nh->nh_pcpu_rth_output);
>                 }
>                 rth = rcu_dereference(*prth);
> -               if (rt_cache_valid(rth)) {
> +               if (rt_cache_valid(rth) && rth->rt_iif == orig_oif) {
>                         dst_hold(&rth->dst);
>                         return rth;
>                 }

	So, if the cache contains same orig_oif we will
use it and if it is different we will replace the cache.
While traffics use same orig_oif we will not have
frequent rt_cache_route() calls that replace the cache.

	Patch looks ok to me but I'm not sure if we should
worry for the unicast traffic. If we want frequent
updates only for loopback then the check could be:

if (rt_cache_valid(rth) &&
    (!(flags & RTCF_LOCAL) || rth->rt_iif == orig_oif)) {

	Or the following, it should better cache mcast because 
mcast does not use/need the rt_iif check:

if (rt_cache_valid(rth) &&
    (type != RTN_LOCAL || rth->rt_iif == orig_oif)) {

Regards

--
Julian Anastasov <ja@ssi.bg>
