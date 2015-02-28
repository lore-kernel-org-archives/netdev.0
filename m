From: Tom Herbert <therbert@google.com>
Subject: [PATCH net-next 0/6] net: Strengthen TX and RX hashes
Date: Fri, 27 Feb 2015 19:11:43 -0800
Message-ID: <1425093109-1077-1-git-send-email-therbert@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f179.google.com ([209.85.213.179]:44289 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750752AbbB1DMi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2015 22:12:38 -0500
Received: by igdh15 with SMTP id h15so5347179igd.3
        for <netdev@vger.kernel.org>; Fri, 27 Feb 2015 19:12:37 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Both the TX and RX hashes associated with skb->hash are mostly 4-tuple
hashes. This is potentially problematic. For instance one could
concieve of a DOS attack against a TCP connection using UDP with same
4-tuple.  Most switches already use at least a 5-tuple hash, NICs
probably should also (for instance Toeplitz hash for UDP could include
UDP protocol number). This patch set implements 5-tuple hashes in the
stack.

For transmit, we simply initialize sk_hash to a random value instead of
performing any actual hash computation. A random value should provide
full 32-bits of entropy and ensure that connected sockets have a
different hash value regardless of protocol, 4-tuple, network namespace,
etc. sock_init_txhash was created to provide this.  This also can be
called for any family not just IP.

For receive, we add a new field in flow_keys called hash_extra. When
doing the jhash this value is XORed into the destination address field.
In flow_dissector, the IP protocol is placed in this field so that we
get a 5-tuple hash.

Also, in flow_dissector, we add support for including VLAN ID and GRE
keyid in the hash (via hash_extra). We implement support for extracting
a hash from MPLS entropy labels (RFC 6790).

Tom Herbert (6):
  net: initialize sk_txhash using random value
  flow_dissector: Include ip_proto in hash computation
  flow_dissector: Add hash_extra field to flow_keys struct
  flow_dissector: Include VLAN ID in hash computation
  flow_dissector: Include GRE keyid in hash computation
  flow_dissector: Include MPLS entropy label in hash computation

 include/net/flow_keys.h   |  1 +
 include/net/ip.h          | 13 -------------
 include/net/ipv6.h        | 14 --------------
 include/net/sch_generic.h |  2 +-
 include/net/sock.h        |  6 ++++++
 include/uapi/linux/in.h   |  2 ++
 include/uapi/linux/mpls.h |  3 +++
 net/core/flow_dissector.c | 44 ++++++++++++++++++++++++++++++++++++++++++--
 net/ipv4/datagram.c       |  2 +-
 net/ipv4/tcp_ipv4.c       |  4 ++--
 net/ipv6/datagram.c       |  2 +-
 net/ipv6/tcp_ipv6.c       |  4 ++--
 12 files changed, 61 insertions(+), 36 deletions(-)

-- 
2.2.0.rc0.207.ga3a616c
