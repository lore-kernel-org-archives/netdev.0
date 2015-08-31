From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next v2 0/4] tcp: receive-side per route dctcp handling
Date: Mon, 31 Aug 2015 15:58:43 +0200
Message-ID: <cover.1441027533.git.daniel@iogearbox.net>
Cc: fw@strlen.de, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:34935 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752085AbbHaN6x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Aug 2015 09:58:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Original cover letter:

  Currently, the following case doesn't use DCTCP, even if it should:

    - responder has f.e. cubic as system wide default
    - 'ip route congctl dctcp $src' was set

  Then, DCTCP is NOT used if a DCTCP sender attempts to connect from a
  host in the $src range: ECT(0) is set, but listen_sk is not dctcp, so
  we fail the INET_ECN_is_not_ect sanity check.

  We also have to examine the dst used for the SYN/ACK reply to make
  this case work.

  In order to minimize additional cost, store the 'ecn is must have'
  information is the dst_features field.

  The set targets -next instead of -net since this doesn't seem to be a
  serious bug and to give the change more soak time until it hits linus
  tree.

v1 -> v2:
 - Addressed Dave's feedback, not exposing any bits to user space
 - Added patch 3 to reject incorrect configurations
 - Rest as is, rebased and retested

Thanks!

Daniel Borkmann (3):
  net: fib6: reduce identation in ip6_convert_metrics
  fib, fib6: reject invalid feature bits
  tcp: use dctcp if enabled on the route to the initiator

Florian Westphal (1):
  net: fib: move metrics parsing to a helper

 include/net/dst.h              |  6 ++++
 include/net/tcp.h              |  2 +-
 include/uapi/linux/rtnetlink.h | 11 +++---
 net/core/rtnetlink.c           |  6 ++++
 net/ipv4/fib_semantics.c       | 77 ++++++++++++++++++++++++++----------------
 net/ipv4/tcp_cong.c            |  9 +++--
 net/ipv4/tcp_input.c           |  7 ++--
 net/ipv6/route.c               | 39 ++++++++++++---------
 8 files changed, 101 insertions(+), 56 deletions(-)

-- 
1.9.3
