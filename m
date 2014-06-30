From: Edward Allcutt <edward.allcutt@openmarket.com>
Subject: [PATCH] ipv4: icmp: Fix pMTU handling for rare case
Date: Mon, 30 Jun 2014 16:16:02 +0100
Message-ID: <1404141362-21015-1-git-send-email-edward.allcutt@openmarket.com>
Cc: linux-kernel@vger.kernel.org,
	Edward Allcutt <edward.allcutt@openmarket.com>
To: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Some older router implementations still send Fragmentation Needed
errors with the Next-Hop MTU field set to zero. This is explicitly
described as an eventuality that hosts must deal with by the
standard (RFC 1191) since older standards specified that those
bits must be zero.

Linux had a generic (for all of IPv4) implementation of the algorithm
described in the RFC for searching a list of MTU plateaus for a good
value. Commit 46517008e116 ("ipv4: Kill ip_rt_frag_needed().")
removed this as part of the changes to remove the routing cache.
Subsequently any Fragmentation Needed packet with a zero Next-Hop
MTU has been discarded without being passed to the per-protocol
handlers or notifying userspace for raw sockets.

When there is a router which does not implement RFC 1191 on an
MTU limited path then this results in stalled connections since
large packets are discarded and the local protocols are not
notified so they never attempt to lower the pMTU.

One example I have seen is an OpenBSD router terminating IPSec
tunnels. It's worth pointing out that this case is distinct from
the BSD 4.2 bug which incorrectly calculated the Next-Hop MTU
since the commit in question dismissed that as a valid concern.

All of the per-protocols handlers implement the simple approach from
RFC 1191 of immediately falling back to the minimum value. Although
this is sub-optimal it is vastly preferable to connections hanging
indefinitely.

Remove the Next-Hop MTU != 0 check and allow such packets
to follow the normal path.

Fixes: 46517008e116 ("ipv4: Kill ip_rt_frag_needed().")
Signed-off-by: Edward Allcutt <edward.allcutt@openmarket.com>

diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index 79c3d94..42b7bcf 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -739,8 +739,6 @@ static void icmp_unreach(struct sk_buff *skb)
 				/* fall through */
 			case 0:
 				info = ntohs(icmph->un.frag.mtu);
-				if (!info)
-					goto out;
 			}
 			break;
 		case ICMP_SR_FAILED:
-- 
2.0.0
