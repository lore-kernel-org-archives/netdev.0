From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [RFC PATCH 0/2] Faster/parallel SYN handling to mitigate SYN floods
Date: Mon, 28 May 2012 13:52:16 +0200
Message-ID: <20120528115102.12068.79994.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Florian Westphal <fw@strlen.de>, opurdila@ixiacom.com,
	Hans Schillstrom <hans.schillstrom@ericsson.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org,
	Christoph Paasch <christoph.paasch@uclouvain.be>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Martin Topholm <mph@hoth.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 0304ds2-fs.1.fullrate.dk ([89.150.128.48]:14370 "EHLO
	firesoul.localdomain" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752994Ab2E1L7M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 May 2012 07:59:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series is a RFC (Request For Comments) for implementing
a faster and parallel handling of TCP SYN connections, to mitigate SYN
flood attacks.  This is against DaveM's net (f0d1b3c2bc), as net-next
is closed, as DaveM has mentioned numerous times ;-)

Only IPv4 TCP is handled here. The IPv6 TCP code also need to be
updated, but I'll deal with that part after we have agreed on a
solution for IPv4 TCP.

 Patch 1/2: Is a cleanup, where I split out the SYN cookie handling
  from tcp_v4_conn_request() into tcp_v4_syn_conn_limit().

 Patch 2/2: Move tcp_v4_syn_conn_limit() outside bh_lock_sock() in
  tcp_v4_rcv().  I would like some input on, (1) if this safe without
  the lock, (2) if we need to do some sock lookup, before calling
  tcp_v4_syn_conn_limit() (Christoph Paasch
  <christoph.paasch@uclouvain.be> mentioned something about SYN
  retransmissions)

---

Jesper Dangaard Brouer (2):
      tcp: Early SYN limit and SYN cookie handling to mitigate SYN floods
      tcp: extract syncookie part of tcp_v4_conn_request()


 net/ipv4/tcp_ipv4.c |  131 ++++++++++++++++++++++++++++++++++++++++++---------
 1 files changed, 107 insertions(+), 24 deletions(-)
