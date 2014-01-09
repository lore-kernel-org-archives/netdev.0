From: hannes@stressinduktion.org
Subject: [PATCH net-next v4 0/3] path mtu hardening patches
Date: Thu,  9 Jan 2014 10:01:14 +0100
Message-ID: <1389258077-23282-1-git-send-email-hannes@stressinduktion.org>
Cc: eric.dumazet@gmail.com, davem@davemloft.net,
	johnwheffner@gmail.com, steffen.klassert@secunet.com,
	fweimer@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:50538 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753033AbaAIJB3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jan 2014 04:01:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all!

After a lot of back and forth I want to propose these changes regarding
path mtu hardening and give an outline why I think this is the best way
how to proceed:

This set contains the following patches:
* ipv4: introduce ip_dst_mtu_maybe_forward and protect forwarding path against pmtu spoofing
* ipv6: introduce ip6_dst_mtu_forward and protect forwarding path with it
* ipv4: introduce hardened ip_no_pmtu_disc mode

The first one switches the forwarding path of IPv4 to use the interface
mtu by default and ignore a possible discovered path mtu. It provides
a sysctl to switch back to the original behavior (see discussion below).

The second patch does the same thing unconditionally for IPv6. I don't
provide a knob for IPv6 to switch to original behavior (please see
below).

The third patch introduces a hardened pmtu mode, where only pmtu
information are accepted where the protocol is able to do more stringent
checks on the icmp piggyback payload (please see the patch commit msg
for further details).

Why is this change necessary?

First of all, RFC 1191 4. Router specification says:
"When a router is unable to forward a datagram because it exceeds the
 MTU of the next-hop network and its Don't Fragment bit is set, the
 router is required to return an ICMP Destination Unreachable message
 to the source of the datagram, with the Code indicating
 "fragmentation needed and DF set". ..."

For some time now fragmentation has been considered problematic, e.g.:
* http://www.hpl.hp.com/techreports/Compaq-DEC/WRL-87-3.pdf
* http://tools.ietf.org/search/rfc4963

Most of them seem to agree that fragmentation should be avoided because
of efficiency, data corruption or security concerns.

Recently it was shown possible that correctly guessing IP ids could lead
to data injection on DNS packets:
<https://sites.google.com/site/hayashulman/files/fragmentation-poisoning.pdf>

While we can try to completly stop fragmentation on the end host
(this is e.g. implemented via IP_PMTUDISC_INTERFACE), we cannot stop
fragmentation completly on the forwarding path. On the end host the
application has to deal with MTUs and has to choose fallback methods
if fragmentation could be an attack vector. This is already the case for
most DNS software, where a maximum UDP packet size can be configured. But
until recently they had no control over local fragmentation and could
thus emit fragmented packets.

On the forwarding path we can just try to delay the fragmentation to
the last hop where this is really necessary. Current kernel already does
that but only because routers don't receive feedback of path mtus, these are
only send back to the end host system. But it is possible to maliciously
insert path mtu inforamtion via ICMP packets which have an icmp echo_reply
payload, because we cannot validate those notifications against local
sockets. DHCP clients which establish an any-bound RAW-socket could also
start processing unwanted fragmentation-needed packets.

Why does IPv4 has a knob to revert to old behavior while IPv6 doesn't?

IPv4 does fragmentation on the path while IPv6 does always respond with
packet-too-big errors. The interface MTU will always be greater than
the path MTU information. So we would discard packets we could actually
forward because of malicious information. After this change we would
let the hop, which really could not forward the packet, notify the host
of this problem.

IPv4 allowes fragmentation mid-path. In case someone does use a software
which tries to discover such paths and assumes that the kernel is handling
the discovered pmtu information automatically. This should be an extremly
rare case, but because I could not exclude the possibility this knob is
provided. Also this software could insert non-locked mtu information
into the kernel. We cannot distinguish that from path mtu information
currently. Premature fragmentation could solve some problems in wrongly
configured networks, thus this switch is provided.

One frag-needed packet could reduce the path mtu down to 522 bytes
(route/min_pmtu).

Misc:

IPv6 neighbor discovery could advertise mtu information for an
interface. These information update the ipv6-specific interface mtu and
thus get used by the forwarding path.

Tunnel and xfrm output path will still honour path mtu and also respond
with Packet-too-Big or fragmentation-needed errors if needed.

Changelog for all patches:
# ipv4: introduce ip_dst_mtu_maybe_forward and protect forwarding path against pmtu spoofing
v2)
* enabled ip_forward_use_pmtu by default
* reworded
v3)
* disabled ip_forward_use_pmtu by default
* reworded
v4)
* renamed ip_dst_mtu_secure to ip_dst_mtu_maybe_forward
* updated changelog accordingly
* removed unneeded !!(... & ...) double negations

# ipv6: introduce ip6_dst_mtu_forward and protect forwarding path with it
v2)
* by default we honour pmtu information
3)
* only honor interface mtu
* rewritten and simplified
* no knob to fall back to old mode any more

# ipv4: introduce hardened ip_no_pmtu_disc mode
v2)
* reworded Documentation

Diffstat:
 Documentation/networking/ip-sysctl.txt | 26 +++++++++++++++++++++++++-
 include/net/ip.h                       | 33 +++++++++++++++++++++++++++++++++
 include/net/netns/ipv4.h               |  1 +
 include/net/protocol.h                 |  7 ++++++-
 include/net/route.h                    | 19 +++----------------
 net/dccp/ipv4.c                        |  1 +
 net/ipv4/af_inet.c                     |  1 +
 net/ipv4/icmp.c                        | 28 ++++++++++++++++++++++++----
 net/ipv4/ip_forward.c                  |  7 +++++--
 net/ipv4/ip_output.c                   |  8 +++++---
 net/ipv4/route.c                       |  3 ---
 net/ipv4/sysctl_net_ipv4.c             |  7 +++++++
 net/ipv6/ip6_output.c                  | 23 ++++++++++++++++++++++-
 net/sctp/protocol.c                    |  1 +
 14 files changed, 134 insertions(+), 31 deletions(-)

Thanks,

  Hannes
