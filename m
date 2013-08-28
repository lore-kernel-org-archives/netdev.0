From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: pull request (net): ipsec 2013-08-28
Date: Wed, 28 Aug 2013 13:04:47 +0200
Message-ID: <1377687895-5780-1-git-send-email-steffen.klassert@secunet.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:56707 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751743Ab3H1LFE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Aug 2013 07:05:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This pull request fixes some issues that arise when 6in4 or 4in6 tunnels
are used in combination with IPsec, all from Hannes Frederic Sowa and a
null pointer dereference when queueing packets to the policy hold queue.

1) We might access the local error handler of the wrong address family if
   6in4 or 4in6 tunnel is protected by ipsec. Fix this by addind a pointer
   to the correct local_error to xfrm_state_afinet.

2) Add a helper function to always refer to the correct interpretation
   of skb->sk.

3) Call skb_reset_inner_headers to record the position of the inner headers
   when adding a new one in various ipv6 tunnels. This is needed to identify
   the addresses where to send back errors in the xfrm layer.

4) Dereference inner ipv6 header if encapsulated to always call the
   right error handler.

5) Choose protocol family by skb protocol to not call the wrong
   xfrm{4,6}_local_error handler in case an ipv6 sockets is used
   in ipv4 mode.

6) Partly revert "xfrm: introduce helper for safe determination of mtu"
   because this introduced pmtu discovery problems.

7) Set skb->protocol on tcp, raw and ip6_append_data genereated skbs.
   We need this to get the correct mtu informations in xfrm.

8) Fix null pointer dereference in xdst_queue_output.

Please pull or let me know if there are problems.

Thanks!

The following changes since commit d9bf5f130946695063469749bfd190087b7fad39:

  tun: compare with 0 instead of total_len (2013-08-13 19:29:08 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/klassert/ipsec.git master

for you to fetch changes up to 302a50bc941010d7a67f288fd0db31981e4d722d:

  xfrm: Fix potential null pointer dereference in xdst_queue_output (2013-08-28 08:47:14 +0200)

----------------------------------------------------------------
Hannes Frederic Sowa (7):
      xfrm: make local error reporting more robust
      xfrm: introduce helper for safe determination of mtu
      ipv6: wire up skb->encapsulation
      ipv6: xfrm: dereference inner ipv6 header if encapsulated
      xfrm: choose protocol family by skb protocol
      xfrm: revert ipv4 mtu determination to dst_mtu
      ipv6: set skb->protocol on tcp, raw and ip6_append_data genereated skbs

Steffen Klassert (1):
      xfrm: Fix potential null pointer dereference in xdst_queue_output

 include/net/route.h     |    8 ++++++++
 include/net/xfrm.h      |    6 ++++++
 net/ipv4/ip_output.c    |    8 --------
 net/ipv4/xfrm4_output.c |   16 +++++++++++-----
 net/ipv4/xfrm4_state.c  |    1 +
 net/ipv6/ip6_gre.c      |    5 +++++
 net/ipv6/ip6_output.c   |    3 +++
 net/ipv6/ip6_tunnel.c   |    6 ++++++
 net/ipv6/raw.c          |    1 +
 net/ipv6/sit.c          |    5 +++++
 net/ipv6/xfrm6_output.c |   21 +++++++++++++++------
 net/ipv6/xfrm6_state.c  |    1 +
 net/xfrm/xfrm_output.c  |   21 +++++++++++++++++++++
 net/xfrm/xfrm_policy.c  |    9 +--------
 net/xfrm/xfrm_state.c   |    7 ++-----
 15 files changed, 86 insertions(+), 32 deletions(-)
