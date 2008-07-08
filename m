From: Patrick McHardy <kaber@trash.net>
Subject: [RFC PATCH 00/04]: VLAN vs. packet socket inconsistencies
Date: Tue, 08 Jul 2008 12:14:51 +0200
Message-ID: <48733E1B.8010501@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:54873 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752496AbYGHKO4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jul 2008 06:14:56 -0400
Received: from [192.168.0.100] (unknown [78.42.204.165])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by stinky.trash.net (Postfix) with ESMTP id 163A2948D9
	for <netdev@vger.kernel.org>; Tue,  8 Jul 2008 12:14:54 +0200 (MEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are currently a number of inconsistencies when using
VLANs with VLAN acceleration and packet sockets:

1) With hardware tagging, outgoing packets are visible without
    the VLAN header, while with software tagging the full VLAN
    header is visible

2) With hardware stripping, incoming packets for locally configured
    VLANs appear on the VLAN device without being visible on the
    underlying device. Packets for unknown VLANs are not visible
    at all. Without hardware stripping, all VLAN packets are visible
    on the underlying device.

3) With hardware filtering, some drivers disable filtering in
    promiscous mode, some don't. The consensus of some discussions
    on netdev about this was that promiscous mode should disable
    all hardware filters, but keep HW acceleration enabled.

These patches fix point 1) and 2). Point 3) needs changes to the
drivers and will be fixed separetly.

The first patch moves the VLAN tag from the cb to a new skb
member, which is necessary to avoid clashes between VLANs and
qdiscs/packet sockets use of the cb. This means on TX, packet
sockets can get the tag from the skb.

The second patch uses the new skb field to store the VLAN TCI of
stripped VLAN packets on RX and deliver them to packet sockets.

The third patch adds the VLAN TCI to the packet auxdata and delivers
it to userspace, where it can be used to reconstruct the original
packet.

The fourth patch modifies libpcap to reconstruct the original
packet. There might be a better way to do this, but it was
useful for testing.

There are mainly two remaining problems with this approach:

- socket filters for VLAN headers don't work properly since they
   expect the VLAN header to be present. Since with the approach
   taken by these patches, userspace has to have knowledge about
   VLAN acceleration anyway, it seems OK to simply add a filter
   instruction to filter on skb->vlan_tci and have userspace
   construct its filters accordingly.

- packet socket auxdata is only available for non-mmaped sockets.
   For mmaped sockets the only place to store the data is in
   struct tpacket_hdr, but that would break compatibility. Not sure
   what to do about this case.

Comments welcome.

