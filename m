From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 0/5] netfilter: SYNPROXY target v3
Date: Tue, 27 Aug 2013 08:50:11 +0200
Message-ID: <1377586216-7024-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	mph@one.com, jesper.brouer@gmail.com, as@one.com
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following patches contain the latest version of the SYNPROXY target.

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

Usage is as follows:

iptables -t raw -A PREROUTING -i eth0 -p tcp --dport 80 --syn -j NOTRACK
iptables -A INPUT -i eth0 -p tcp --dport 80 -m state UNTRACKED,INVALID \
        -j SYNPROXY --sack-perm --timestamp --mss 1480 --wscale 7 --ecn

echo 0 > /proc/sys/net/netfilter/nf_conntrack_tcp_loose

The second rule catches untracked packets and directs them to the target.
The purpose of disabling loose tracking is to have the final ACK from the
client not be picked up by conntrack, so it won't create a new conntrack
entry and will be marked INVALID and also get directed to the target.

We did some extensive testing on Monday and it verified all retransmit
bugs have been fixed. With 1.4Mpps SYNs the load on a 16 way Xeon L6530
2.13 Ghz machine was between 3% and 6%.

There's one single change since v2:

Reopened TCP connections while the conntrack is in CLOSE state weren't
handled properly. The sequence number and timestamp adjustments need
to be reset in this case. Another counter has been introduced for this.

>From my POV, these patches are ready for merging now.

Please apply.
