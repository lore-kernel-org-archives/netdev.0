From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next] ipv4: introduce new IP_MTU_DISCOVER mode IP_PMTUDISC_INTERFACE
Date: Tue, 29 Oct 2013 13:04:25 +0100
Message-ID: <20131029120424.GD26185@order.stressinduktion.org>
References: <20131026201158.GI15744@order.stressinduktion.org> <20131029.000844.1092862708536984032.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, fweimer@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:35862 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752686Ab3J2ME0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Oct 2013 08:04:26 -0400
Content-Disposition: inline
In-Reply-To: <20131029.000844.1092862708536984032.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 29, 2013 at 12:08:44AM -0400, David Miller wrote:
> From: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Date: Sat, 26 Oct 2013 22:11:58 +0200
> 
> > Sockets marked with IP_PMTUDISC_INTERFACE won't do path mtu discovery,
> > their sockets won't accept and install new path mtu information and they
> > will always use the interface mtu for outgoing packets. It is guaranteed
> > that the packet is not fragmented locally. But we won't set the DF-Flag
> > on the outgoing frames.
> > 
> > Florian Weimer had the idea to use this flag to ensure DNS servers are
> > never generating outgoing fragments. They may well be fragmented on the
> > path, but the server never stores or usees path mtu values, which could
> > well be forged in an attack.
> > 
> > (The root of the problem with path MTU discovery is that there is
> > no reliable way to authenticate ICMP Fragmentation Needed But DF Set
> > messages because they are sent from intermediate routers with their
> > source addresses, and the IMCP payload will not always contain sufficient
> > information to identify a flow.)
> 
> I do not like this reasoning.  You have several more acceptable paths to take
> to resolve this problem:

So, I hope I can convince you to merge this patch. ;-)

I really tried hard to find alternatives or even a way to enable
the protection automatically given that at least unbound does apply
IP_PMTUDISC_DONT to its sockets already. These are the reasons why I
came up with the new IP_PMTUDISC_INTERFACE value:

> 1) "I don't trust path MTU information at all"
> 
>    Just turn it off globally, end of story.  It has the same effect as your
>    new per-application mode.

I think you are referring to ipv4/ip_no_pmtu_disc?

This setting actually worsens the situation:

0.000 `echo 1 > /proc/sys/net/ipv4/ip_no_pmtu_disc`
0.500 `ethtool -K tun0 ufo off`

/* check current mtu with connected socket */
1.000 socket(..., SOCK_DGRAM, IPPROTO_UDP) = 3
1.000 connect(3, ..., ...) = 0
1.000 getsockopt(3, IPPROTO_IP, IP_MTU, [1500], [4]) = 0
1.000 close(3) = 0

/* inject frag_needed to unconnected socket */
2.000 socket(..., SOCK_DGRAM, IPPROTO_UDP) = 3
2.000 setsockopt(3, IPPROTO_IP, IP_MTU_DISCOVER, [IP_PMTUDISC_DONT], 4) = 0
2.000 sendto(3, ..., 1000, 0, ..., ...) = 1000
2.000 > udp (1000)
/* this simulates a forged icmp packet which tries to lower the mtu */
2.100 < [udp (1000)] icmp unreachable frag_needed mtu 1400

2.5 sendto(3, ..., 1000, 0, ..., ...) = 1000
/* first fragment splitted at 522 bytes */
2.5 > udp(522)
/* didn't find a way to match for the second fragment - so error out here
 * comment out this check to check for the mtu a IP_PMTUDISC_DONT socket now has
 *
 * it really is used, otherwise we would not have seen this fragment
 */

3.000 close(3) = 0

/* verify mtu again */
3.000 socket(..., SOCK_DGRAM, IPPROTO_UDP) = 3
3.000 connect(3, ..., ...) = 0
/* we actually have 522 as the minimal mtu - so error out here */
3.000 getsockopt(3, IPPROTO_IP, IP_MTU, [1400], [4]) = 0
3.000 close(3) = 0

5.000 `echo 0 > /proc/sys/net/ipv4/ip_no_pmtu_disc`

Given this packetdrill snippet we see it is actually very
counterproductive to tell people to globally disable pmtu discovery as
it will certainly generate more fragments.

The reason for this is, that __ip_rt_update_pmtu is called with zero mtu
and will get clamped to min_pmtu. It is possible to tell people to also
increase min_pmtu but I don't want to take the risk of breaking other
applications on a DNS server given how the current semantics are.

If we receive a pmtu event on a TCP or DCCP socket we actually
check for the pmtudisc setting and won't apply it if it is set to
IP_PMTUDISC_DONT. This is not checked on UDP and RAW sockets and it was
very hard to think about the consequences to introduce such checks now
(at least for me).

Adding a new sysctl would be a viable option but it is harder to use
by DNS server implementations and could be fiddled with by users or
scripts etc.  I dislike a globel (or even per namespace) setting. Also
Fedora e.g. installs an unbound server on Desktops if one installs
the dnssec-trigger package.  Maybe we will see more DNS servers on
workstations where we don't want to globally disable pmtu.

> 2) "I don't trust path MTU information unless the full socket ID is available
>     in the ICMP packets quoted headers"
> 
>    Then simply implement a policy as such and submit it to me.

We don't trust the MTU information in any case for that socket.

It seems easy to inject wrong path mtu information on a socket which will
be installed as a globel fnhe for 600 seconds. This is a very viable
target if an attacker is able to do cache poisoning afterwards. There
is not much protection even if we match the full socket ID on an
UDP socket. As this socket is more exposed to attacks we drop the mtu
information there. Of course, other ports could also install wrong pmtu
information causing packets being fragmented so we always use the path
mtu and don't fragment locally.  Dropping the pmtu information on these
sockets just makes it more symmetrical and causes less stress on the fnhe
hash tables if people do these attacks (they could well be running these
attacks in parallel). If the DNS port is the only one reachable externally
we won't do any pmtu processing on that server from untrusted peers, which is
a nice side effect.

All that said, I hope dns servers provide a setting to apply this option
on sockets and fail to start up if it could not be applied. So an
administrator is not in some sense of false hope that this protection
is enabled when running on an older kernel. This could only be done if we
provide a new value for IP_MTU_DISCOVER.

Greetings,

  Hannes
