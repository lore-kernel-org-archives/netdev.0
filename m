From: Stephen Hemminger <shemminger@vyatta.com>
Subject: GTSM and TCP accept problem
Date: Sat, 14 Aug 2010 21:46:34 -0400
Message-ID: <20100814214634.24a87715@s6510>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:42855 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756710Ab0HOBqk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 14 Aug 2010 21:46:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The implementation of Generalized TTL Security has a problem
on the TCP accept side. Since there can be different number of
hops for each peer, the listener ends up doing

   socket
   bind
   set TTL to 255
   listen
   while (nfd = accept(peer)) {
     info = lookup(peer)
     set MINTTL to 255 - info->ttl_hops


The problem is that a rogue peer can still do three way
handshake causing the accept to succeed. But the rogue will
leave a stuck connection that will then have to timeout.

The only ways I have come up to deal with this are:
   * have short timeout on initial data (recycle faster)
   * push peer;MINTTL table down into kernel (per socket)
   * have BGP do this through iptables which is a non-starter
     for a general application that needs to run on BSD, and
     would mess up existing firewall rules.

Ideas welcome..
