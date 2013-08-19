From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: [RFC 0/2] Account for duplicate ACKs with invalid SACK-blocks
Date: Mon, 19 Aug 2013 21:29:26 +0200
Message-ID: <1376940568-16512-1-git-send-email-christoph.paasch@uclouvain.be>
References: <1376935800.4226.71.camel@edumazet-glaptop>
Cc: netdev@vger.kernel.org, Phil Oester <kernel@linuxace.com>,
	Corey Hickey <bugfood-ml@fatooh.org>,
	Benjamin Hesmans <benjamin.hesmans@uclouvain.be>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:59657 "EHLO
	smtp6.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750908Ab3HST3r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Aug 2013 15:29:47 -0400
In-Reply-To: <1376935800.4226.71.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There exist sequence-number rewriting middleboxes, who do not modify the 
sequence-number in the SACK-blocks.
Duplicate acknowledgments with these (invalid) SACK-blocks will not be
accounted in sacked_out, and thus no fast-retransmit will trigger.
So, the only way to recover from a packet-loss is through an RTO,
effectively killing the performance of TCP in this case.

Performance-results can be seen here:
http://tools.ietf.org/agenda/87/slides/slides-87-tcpm-11.pdf

Another solution might be to simply disable SACK, as soon as an invalid
SACK-block has been received (as suggested by Phil Oester). This however
might be too aggressive.

Christoph Paasch (2):
  Use acked_out for reno-style ack acounting instead of sacked_out
  Account acked_out in sack, if the sack is invalid

 include/linux/tcp.h      |   1 +
 include/net/tcp.h        |  17 +++++---
 net/ipv4/tcp_input.c     | 103 ++++++++++++++++++++++++++++++++---------------
 net/ipv4/tcp_minisocks.c |   1 +
 net/ipv4/tcp_output.c    |   6 +--
 net/ipv4/tcp_timer.c     |   2 +-
 6 files changed, 89 insertions(+), 41 deletions(-)

-- 
1.8.1.2
