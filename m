From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: [RFC] endianness bugs in net/batman-adv/
Date: Fri, 13 Apr 2012 20:46:29 +0100
Message-ID: <20120413194629.GP6589@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: b.a.t.m.a.n@lists.open-mesh.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:48063 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756075Ab2DMTqa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Apr 2012 15:46:30 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	Let's start with net/batman-adv/translation-table.c:send_tt_request(). 
Its tt_crc argument gets stored into skb as-is and skb goes on the wire.
OK, so it's fixed-endian, right?

	That sucker comes straight from the (only) caller - tt_update_orig().
There it gets compared with ->tt_crc of struct orig_node instances.  Fine,
except that just prior to that comparison we assign to ->tt_crc the return
value of tt_global_crc().  Which is built on crc16_byte() and clearly
returns a host-endian value.  Additionally, orig_node ->tt_crc is getting
compared to tt_request->tt_data in send_other_tt_response(), which ultimately
comes from recv_tt_query() where it's flipped from net-endian to host-endian.

	It gets even funnier - we have 3 structures with ->tt_crc in them;
one is struct orig_node (see above), another is struct batman_ogv_packet and
then there's the weirdest one - struct bat_priv.  Where ->tt_crc is
atomic_t, of all things.  With exactly two things ever done to it:
        batman_ogm_packet->tt_crc = htons((uint16_t)
                                                atomic_read(&bat_priv->tt_crc));
in bat_iv_ogm_schedule() and
        atomic_set(&bat_priv->tt_crc, tt_local_crc(bat_priv));
in prepare_packet_buffer().  What the hell does that have to do with atomic_t?
At least that one is definitely host-endian all along (tt_local_crc() is
the same kind of built-on-crc16_byte() thing).

	And then there's batman_ogv_packet, where we flip the damn field
from net-endian to host-endian and back.  That's where the argument of
tt_update_orig() comes from, AFAICS always in host-endian form.

	IOW, unless I'm misreading that code we have
bat_priv ->tt_crc: host-endian, no need to make it atomic_t
orig_node ->tt_crc: host-endian
tt_update_orig()/send_tt_request() tt_crc argument: host-endian
the value put into the packet in send_tt_request(): broken; should be
net-endian, in reality it's host-endian.  Missing htons() at the very
least.

	Could somebody familiar with that code comment on that?
