From: "Jeremy Jackson" <jerj@coplanar.net>
Subject: Unwanted aliasing of UDP checksum failed error counter
Date: Tue, 26 Oct 2010 15:53:27 -0400
Message-ID: <8545971aec0612a0bca2801107d9493b.squirrel@imap.coplanar.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sputnik.coplanar.net ([70.47.139.1]:36484 "EHLO
	sputnik.coplanar.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760185Ab0JZUBi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Oct 2010 16:01:38 -0400
Received: from imap.coplanar.net (localhost [127.0.0.1])
	by sputnik.coplanar.net (8.14.3/8.14.3/Debian-9ubuntu1) with ESMTP id o9QJrRpe028325
	for <netdev@vger.kernel.org>; Tue, 26 Oct 2010 15:53:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Trying to find source of packet loss on an 8node compute cluster, we find:
(not in this example, but on the real cluster)

in /proc/sys/net/snmp
Udp: InDatagrams NoPorts InErrors OutDatagrams RcvbufErrors SndbufErrors
Udp: 976460 1750 0 986795 0 0

InErrors *and* RcvbufErrors both go up with full socket buffer, this has
made troubleshooting our application more difficult.  We were chasing UDP
checksum problems, until we checked linux source code, and found aliasing.

Is this done for assembly code efficiency?  Any reason ENOMEM (ie socket
buffer full) can't avoid aliasing to UDP checksum failed errors?

in linux-source-2.6.32/net/ipv4/udp.c:__udp_queue_rcv_skb()
....
                /* Note that an ENOMEM error is charged twice */
                if (rc == -ENOMEM) {
                        UDP_INC_STATS_BH(sock_net(sk), UDP_MIB_RCVBUFERRORS,
                                         is_udplite);
                        atomic_inc(&sk->sk_drops);
                }
                goto drop;
...
drop:
        UDP_INC_STATS_BH(sock_net(sk), UDP_MIB_INERRORS, is_udplite);


