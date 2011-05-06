From: David Miller <davem@davemloft.net>
Subject: ip_queue_xmit() used illegally
Date: Fri, 06 May 2011 12:26:56 -0700 (PDT)
Message-ID: <20110506.122656.189696988.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vladislav.yasevich@hp.com, yjwei@cn.fujitsu.com,
	jchapman@katalix.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56365
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755049Ab1EFT12 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 May 2011 15:27:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Several users of ip_queue_xmit() use it illegally.

I've only audited L2TP and SCTP so far, and they both cannot use
ip_queue_xmit() with the way they operate currently.

The issue surrounds how the socket binding is maintained in
inet->inet_daddr, inet->inet_saddr etc.

TCP does things right, in that ip_queue_xmit() is only invoked with
inet->inet_daddr and inet->inet_saddr having fully resolved, final,
fully connected values.

This is an absolute requirement because if the socket's route
invalidates (which happens completely asynchronously) it's going to
lookup a new route using whatever is stored in
inet->inet_{daddr,saddr} and then use those addresses to build the
packet.  Even if ->inet_{saddr,daddr} are both zero this will still
emit a packet (bonus points if you know what addresses will be picked,
no peeking at route.c :-).

SCTP stores it's binding information using transports and assosciations
and does not fill in the ->inet_{daddr,saddr} values.

It tries to work around this route issue by checking dst->obsolete
directly in sctp_packet_transmit(), which just makes the race smaller
and does not eliminate it.  ip_queue_xmit() can still end up with
__sk_dst_check() returning NULL and then we end up emitting a
potentially bogus packet.

L2TP supports more of a datagram type socket semantic than a stream
one, it allows unconnected modes of operation.  And for this reason
it also cannot use ip_queue_xmit() legally.

After a quick cursory scan it seem like DCCP is OK.

I think SCTP could potentially be fixed by simply filling in the
inet->inet_{daddr,saddr} values when it makes an internal binding
of the transport via sctp_transport_route().

L2TP on the other hand will need to use another interface to send ipv4
packets because it allows disconnected operation.
