From: Michal Kubecek <mkubecek@suse.cz>
Subject: UDP checksum handling in UFO packets from raw sockets
Date: Fri, 16 Jan 2015 07:52:16 +0100
Message-ID: <20150116065216.GB28055@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:34766 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751155AbbAPGwS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Jan 2015 01:52:18 -0500
Received: from relay1.suse.de (charybdis-ext.suse.de [195.135.220.254])
	by mx2.suse.de (Postfix) with ESMTP id 4344FAD34
	for <netdev@vger.kernel.org>; Fri, 16 Jan 2015 06:52:17 +0000 (UTC)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I'm working on an issue with sending over-MTU UDP datagrams from a raw
socket via a virtio_net interface. The problem is quite clear:
ip_ufo_append_data() sets skb->ip_summed to CHECKSUM_PARTIAL
unconditionally but skb->csum_start and skb->csum_offset are never set
properly as it is normally done in udp_send_skb() which these packets
never pass through.

There are few possible solutions but I realized I have no idea which
behaviour would be the correct one (documentation is either missing or
unclear).

1. Make sure that for UFO packets csum_start and csum_offset are always
set even if they come from a raw socket. Pro: consistent with UFO
packets from regular UDP sockets, easy. Con: if sender sets the checksum
field to zero or sets SO_NO_CHECK, we ignore his wish (one could even
argue that we shouldn't touch higher layer headers at all for raw
sockets). It would be also inconsistent between UFO and non-UFO packets.

2. Always preserve UDP checksum set by userspace and set ip_summed to
CHECKSUM_NONE. Pro: we preserve the UDP datagram as provided by
userspace application which seems to be the logic behind raw sockets.
Con: this would require an exception in skb_gso_segment() which
currently issues a WARN as it doesn't expect packets other than
CHECKSUM_PARTIAL.

3. Do (2) if checksum field is zero ("no checksum" according to RFC 768)
or socket has SO_NO_CHECK option, (1) otherwise. Both pros and cons are
combination of those of (1) and (2).

4. Don't allow UFO for UDP packets from raw sockets. Pro: very easy,
consistency between "short" and "long" datagrams. Con: inefficient (but
using raw sockets to generate UDP traffic is unusual and rare).

I suppose the key question is: what are we supposed to do with the UDP
checksum? Should we always preserve it (user expects us to send the
datagram they created), always recalculate (we do so for IPv4 checksum
for raw sockets with IP_HDRINCL option) or something between
(recalculate unless it's zero or SO_NO_CHECK is set)? I would be
thankful for any ideas or references to documents saying what it should
work like.

                                                        Michal Kubecek
