From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH RFC net-next 0/7] net: dst_confirm replacement
Date: Sun, 18 Dec 2016 22:56:29 +0200
Message-ID: <1482094596-26046-1-git-send-email-ja@ssi.bg>
Cc: linux-sctp@vger.kernel.org, YueHaibing <yuehaibing@huawei.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:46910 "EHLO ja.ssi.bg"
        rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753715AbcLRU5o (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 18 Dec 2016 15:57:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	This patchset addresses the problem of neighbour
confirmation where received replies from one nexthop
can cause confirmation of different nexthop when using
the same dst. Thanks to YueHaibing <yuehaibing@huawei.com>
for tracking the dst->pending_confirm problem.

	Sockets can obtain cached output route. Such
routes can be to known nexthop (rt_gateway=IP) or to be
used simultaneously for different nexthop IPs by different
subnet prefixes (nh->nh_scope = RT_SCOPE_HOST, rt_gateway=0).

	At first look, there are more problems:

- dst_confirm() sets flag on dst and not on dst->path,
as result, indication is lost when XFRM is used

- DNAT can change the nexthop, so the really used nexthop is
not confirmed

	So, the following solution is to avoid using
dst->pending_confirm.

	The current dst_confirm() usage is as follows:

Protocols confirming dst on received packets:
- TCP (1 dst per socket)
- SCTP (1 dst per transport)
- CXGB*

Protocols supporting sendmsg with MSG_CONFIRM [ | MSG_PROBE ] to
confirm neighbour:
- UDP IPv4/IPv6
- ICMPv4 PING
- RAW IPv4/IPv6
- L2TP/IPv6

MSG_CONFIRM for other purposes (fix not needed):
- CAN

Sending without locking the socket:
- UDP (when no cork)
- RAW (when hdrincl=1)

Redirects from old to new GW:
- rt6_do_redirect


	The patchset includes the following changes:

1. sock: add sk_dst_pending_confirm flag

- used only by TCP with patch 4 to remember the received
indication in sk->sk_dst_pending_confirm

2. net: add dst_pending_confirm flag to skbuff

- skb->dst_pending_confirm will be used by all protocols
in following patches

3. sctp: add dst_pending_confirm flag

- SCTP uses per-transport dsts and can not use
sk->sk_dst_pending_confirm like TCP

4. tcp: replace dst_confirm with sk_dst_confirm

5. net: add confirm_neigh method to dst_ops

- IPv4 and IPv6 provision for slow neigh lookups for MSG_PROBE users.
I decided to use neigh lookup only for this case because on
MSG_PROBE the skb may pass MTU checks but it does not reach
the neigh confirmation code. This patch will be used from patch 6.

- xfrm_confirm_neigh: support is incomplete here, only routes with
known nexthops (gateway) are supported because the tunnel address
is slow to obtain. Or there is solution to this problem?

6. net: use dst_confirm_neigh for UDP, RAW, ICMP, L2TP

- dst_confirm conversion for UDP, RAW, ICMP and L2TP/IPv6

- these protocols use MSG_CONFIRM propagated by ip*_append_data
to skb->dst_pending_confirm. sk->sk_dst_pending_confirm is not
used because some sending paths do not lock the socket. For
MSG_PROBE we use the slow lookup (dst_confirm_neigh).

- there are also 2 cases that need the slow lookup:
__ip6_rt_update_pmtu and rt6_do_redirect. I hope
&ipv6_hdr(skb)->saddr is the correct nexthop address to use here.

7. net: pending_confirm is not used anymore

- I failed to understand the CXGB* code, I see dst_confirm()
calls but I'm not sure dst_neigh_output() was called. For now
I just removed the dst->pending_confirm flag and left all
dst_confirm() calls there. Any better idea?

- Now may be old function neigh_output() should be restored
instead of dst_neigh_output?


Julian Anastasov (7):
  sock: add sk_dst_pending_confirm flag
  net: add dst_pending_confirm flag to skbuff
  sctp: add dst_pending_confirm flag
  tcp: replace dst_confirm with sk_dst_confirm
  net: add confirm_neigh method to dst_ops
  net: use dst_confirm_neigh for UDP, RAW, ICMP, L2TP
  net: pending_confirm is not used anymore

 drivers/net/vrf.c          |  5 ++++-
 include/linux/skbuff.h     |  4 +++-
 include/net/arp.h          | 16 ++++++++++++++++
 include/net/dst.h          | 21 +++++++++------------
 include/net/dst_ops.h      |  2 ++
 include/net/ndisc.h        | 17 +++++++++++++++++
 include/net/sctp/sctp.h    |  6 ++----
 include/net/sctp/structs.h |  4 ++++
 include/net/sock.h         | 28 +++++++++++++++++++++++++++-
 net/core/dst.c             |  1 -
 net/core/sock.c            |  2 ++
 net/ipv4/ip_output.c       | 11 ++++++++++-
 net/ipv4/ping.c            |  3 ++-
 net/ipv4/raw.c             |  6 +++++-
 net/ipv4/route.c           | 19 +++++++++++++++++++
 net/ipv4/tcp_input.c       | 12 +++---------
 net/ipv4/tcp_metrics.c     |  7 ++-----
 net/ipv4/tcp_output.c      |  2 ++
 net/ipv4/udp.c             |  3 ++-
 net/ipv6/ip6_output.c      |  7 +++++++
 net/ipv6/raw.c             |  6 +++++-
 net/ipv6/route.c           | 43 ++++++++++++++++++++++++++++++-------------
 net/ipv6/udp.c             |  3 ++-
 net/l2tp/l2tp_ip6.c        |  3 ++-
 net/sctp/associola.c       |  3 +--
 net/sctp/output.c          | 10 +++++++++-
 net/sctp/outqueue.c        |  2 +-
 net/sctp/sm_make_chunk.c   |  6 ++----
 net/sctp/sm_sideeffect.c   |  2 +-
 net/sctp/socket.c          |  4 ++--
 net/sctp/transport.c       | 18 +++++++++++++++++-
 net/xfrm/xfrm_policy.c     | 16 ++++++++++++++++
 32 files changed, 226 insertions(+), 66 deletions(-)

-- 
1.9.3
