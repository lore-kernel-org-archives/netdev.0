From: Tom Herbert <therbert@google.com>
Subject: [PATCH 0/5]: soreuseport: Bind multiple sockets to the same port
Date: Tue, 22 Jan 2013 11:49:46 -0800 (PST)
Message-ID: <alpine.DEB.2.00.1301221142300.26333@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="296491395-684743121-1358884186=:26333"
Cc: netdev@markandruth.co.uk, eric.dumazet@gmail.com
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gg0-f202.google.com ([209.85.161.202]:54243 "EHLO
	mail-gg0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753876Ab3AVTtr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2013 14:49:47 -0500
Received: by mail-gg0-f202.google.com with SMTP id l4so295025ggi.3
        for <netdev@vger.kernel.org>; Tue, 22 Jan 2013 11:49:46 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--296491395-684743121-1358884186=:26333
Content-Type: TEXT/PLAIN; charset=ISO-8859-15
Content-Transfer-Encoding: 8BIT

This series implements so_reuseport (SO_REUSEPORT socket option) for
TCP and UDP.  For TCP, so_reuseport allows multiple listener sockets
to be bound to the same port.  In the case of UDP, so_reuseport allows
multiple sockets to bind to the same port.  To prevent port hijacking
all sockets bound to the same port using so_reuseport must have the
same uid.  Received packets are distributed to multiple sockets bound
to the same port using a 4-tuple hash.

The motivating case for so_resuseport in TCP would be something like
a web server binding to port 80 running with multiple threads, where
each thread might have it's own listener socket.  This could be done
as an alternative to other models: 1) have one listener thread which
dispatches completed connections to workers. 2) accept on a single
listener socket from multiple threads.  In case #1 the listener thread
can easily become the bottleneck with high connection turn-over rate.
In case #2, the proportion of connections accepted per thread tends
to be uneven under high connection load (assuming simple event loop:
while (1) { accept(); process() }, wakeup does not promote fairness
among the sockets.  We have seen the  disproportion to be as high
as 3:1 ratio between thread accepting most connections and the one
accepting the fewest.  With so_reusport the distribution is
uniform.

The TCP implementation has a problem in that the request sockets for a
listener are attached to a listener socket.  If a SYN is received, a
listener socket is chosen and request structure is created (SYN-RECV
state).  If the subsequent ack in 3WHS does not match the same port
by so_reusport, the connection state is not found (reset) and the
request structure is orphaned.  This scenario would occur when the
number of listener sockets bound to a port changes (new ones are
added, or old ones closed).  We are looking for a solution to this,
maybe allow multiple sockets to share the same request table...

The motivating case for so_reuseport in UDP would be something like a
DNS server.  An alternative would be to recv on the same socket from
multiple threads.  As in the case of TCP, the load across these threads
tends to be disproportionate and we also see a lot of contection on
the socket lock.  Note that SO_REUSEADDR already allows multiple UDP
sockets to bind to the same port, however there is no provision to
prevent hijacking and nothing to distribute packets across all the
sockets sharing the same bound port.  This patch does not change the
semantics of SO_REUSEADDR, but provides usable functionality of it
for unicast.
--296491395-684743121-1358884186=:26333--
