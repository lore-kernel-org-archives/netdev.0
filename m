From: Phil Sutter <phil@nwl.cc>
Subject: sending VLAN packets via packet_mmap
Date: Thu, 30 Sep 2010 21:24:14 +0200
Message-ID: <20100930192414.GD26509@orbit.nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johann Baudy <johann.baudy@gnu-log.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([91.121.169.95]:44853 "EHLO orbit.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752230Ab0I3Ta4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Sep 2010 15:30:56 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

support for VLAN tags in af_packet.c seems to be incomplete. While it's
possible to receive a full packet using SOCK_RAW, sending one will fail
due to size constraints. tpacket_snd() does not account for the
additional four bytes.

There are a few possible solutions to this problem. When searching for
the most appropriate one, I've been looking at tpacket_rcv() which
simply writes the whole frame out, setting tpacket2_hdr.tp_vlan_tci on
the go. So from a user's point of view, information is redundantly
available.

The actual problem in tpacket_snd() is this:

| reserve = dev->hard_header_len;
| [...]
| if (size_max > dev->mtu + reserve)
| 	size_max = dev->mtu + reserve;

I guess the check is there to avoid skb overflows on malicious data
input. Is this correct? Are there other reasons for it's existence?

As af_packet.c has no knowledge about VLANs (other than a call to
vlan_tx_tag_get()), I guess avoiding expensive parsing of the inserted
data for the VLAN tag should be appropriate. Nevertheless the check from
above needs to account for the additional VLAN_HLEN when the tag exists.

So a rather trivial solution would be to drop the check completely
(given no other constraints, of course), thereby giving the user a
little more ability to break things. Alternatively, one could require
that tpacket2_hdr.tp_vlan_tci be set (at least non-zero) to identify
packets containing a VLAN tag and allow the additional size (probably
mostly consistent to the logic inside tpacket_rcv()).

A third solution could be like the second one, but not accepting
prebuilt packets including VLAN header at all and using
tpacket2_hdr.tp_vlan_tci together with vlan_put_tag() to instead insert
it from inside the kernel.

Hopefully I didn't overlook something crucial. Feel free to flame me if
that's the case! :)

Greetings, Phil
