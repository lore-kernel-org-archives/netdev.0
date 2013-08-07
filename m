From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH RFC 0/5] netfilter: implement netfilter SYN proxy
Date: Wed,  7 Aug 2013 19:42:46 +0200
Message-ID: <1375897371-18430-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	mph@one.com, jesper.brouer@gmail.com, as@one.com
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:46884 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932071Ab3HGRm6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Aug 2013 13:42:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following patches against nf-next.git implement a SYN proxy for
netfilter. The series applies on top of the patches I sent last week
and is split into five patches:

- a patch to split out sequence number adjustment from NAT and make it
  usable from other netfilter subsystems. This is used to translate
  sequence numbers from the server to the client once the full connection
  has been established.

  This patch contains a bit of churn, but the core is to simply move the
  code to a new file and move the sequence number adjustment data into a
  ct extend.

- a patch to extract the TCP stack independant parts of syncookie generation
  and validation and make the usable from netfilter

- the SYN proxy core and IPv4 SYNPROXY target. See below for more details.

- a similar patch to the second one for IPv6

- an IPv6 version of the SYNPROXY target


The SYNPROXY operates by marking the initial SYN from the client as UNTRACKED
and directing it to the SYNPROXY target. The target responds with a SYN/ACK
containing a cookie and encodes options such as window scaling factor, SACK
perm etc. into the timestamp, if timestamps are used (similar to TCP). The
window size is set to zero. The response is also sent as untracked packet.

When the final ACK is received the cookie is validated, the original options
extracted and a SYN to the original destination is generated. The SYN to the
original destination uses the avertised window from the final ACK and the
options from the initial SYN packet. The SYN is not sent as untracked, so
from a connection tracking POV it will look like the original packet from
the client and instantiate a new connection. When the server responds with
a SYN/ACK a final ACK for the server is generated and a window update with
the window size announced by the server is sent to the client. At this
point the connection is handed of to conntrack and the only thing the
target is still involved in is timestamp translation through the registerd
hooks.

Since the SYN proxy can't know the options the server supports, they have
to be specified as parameters to the SYNPROXY target. The assumption is that
these options are constant as long as you don't change settings on the
server. Since the SYN proxy can't know the initial sequence number and
timestamp values the server will use, both have to be translated in the
direction server->client. Sequence number translation is done using the
standard sequence number translation mechanisms originally only used for
NAT, timestamps are translated in a hook registered by the SYNPROXY target.

Martin Topholm made some performance measurements with an earlier version
(that should still be valid, the only difference was that the core and IPv4
parts were in the same file) and measured a load of about 7% on a 8 way
system with 2 million SYNs per second, which without the target basically
killed the server (Martin, please correct me if I'm wrong).

The iptables patches will follow in a seperate thread, testing can be done
by:

iptables -t raw -A PREROUTING -i eth0 -p tcp --dport 80 --syn -j NOTRACK
iptables -A INPUT -i eth0 -p tcp --dport 80 -m state UNTRACKED,INVALID \
	-j SYNPROXY --sack-perm --timestamp --mss 1480 --wscale 7 --ecn

echo 0 > /proc/sys/net/netfilter/nf_conntrack_tcp_loose

The second rule catches untracked packets and directs them to the target.
The purpose of disabling loose tracking is to have the final ACK from the
client not be picked up by conntrack, so it won't create a new conntrack
entry and will be marked INVALID and also get directed to the target.

Unfortunately I couldn't come up with a nicer way to catch just the
first SYN and final ACK from the client and not have any more packets
hit the target, but even though it doesn't look to nice, it works well.

Comments welcome.
