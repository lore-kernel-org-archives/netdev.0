From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH net] net: fix wrong mac_len calculation for vlans
Date: Wed, 28 May 2014 17:24:04 +0200
Message-ID: <1401290644-19439-1-git-send-email-nikolay@redhat.com>
Cc: Nikolay Aleksandrov <nikolay@redhat.com>,
	Vlad Yasevich <vyasevic@redhat.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Daniel Borkman <dborkman@redhat.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48553 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752140AbaE1PYO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 May 2014 11:24:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After 1e785f48d29a ("net: Start with correct mac_len in
skb_network_protocol") skb->mac_len is used as a start of the
calculation in skb_network_protocol() but that is not always correct. If
skb->protocol == 8021Q/AD, usually the vlan header is already inserted
in the skb (i.e. vlan reorder hdr == 0). Usually when the packet enters
dev_hard_xmit it has mac_len == 0 so we take 2 bytes from the
destination mac address (skb->data + VLAN_HLEN) as a type in
skb_network_protocol() and return vlan_depth == 4. In the case where TSO is
off, then the mac_len is set but it's == 18 (ETH_HLEN + VLAN_HLEN), so
skb_network_protocol() returns a type from inside the packet and
offset == 22. Also make vlan_depth unsigned as suggested before.

Here are few netperf tests + debug printk's to illustrate:
cat netperf.tso-on.reorder-on.bugged
- Vlan -> device (reorder on, default, this case is okay)
MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to
192.168.3.1 () port 0 AF_INET
Recv   Send    Send
Socket Socket  Message  Elapsed
Size   Size    Size     Time     Throughput
bytes  bytes   bytes    secs.    10^6bits/sec

 87380  16384  16384    10.00    7111.54
[   81.605435] skb->len 65226 skb->gso_size 1448 skb->proto 0x800
skb->mac_len 0 vlan_depth 0 type 0x800

- Vlan -> device (reorder off, bad)
cat netperf.tso-on.reorder-off.bugged
MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to
192.168.3.1 () port 0 AF_INET
Recv   Send    Send
Socket Socket  Message  Elapsed
Size   Size    Size     Time     Throughput
bytes  bytes   bytes    secs.    10^6bits/sec

 87380  16384  16384    10.00     241.35
[  204.578332] skb->len 1518 skb->gso_size 0 skb->proto 0x8100
skb->mac_len 0 vlan_depth 4 type 0x5301
0x5301 are the last two bytes of the destination mac.

And if we stop TSO, we may get even the following:
[   83.343156] skb->len 2966 skb->gso_size 1448 skb->proto 0x8100
skb->mac_len 18 vlan_depth 22 type 0xb84
Because mac_len already accounts for VLAN_HLEN.

After the fix:
cat netperf.tso-on.reorder-off.fixed
MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to
192.168.3.1 () port 0 AF_INET
Recv   Send    Send
Socket Socket  Message  Elapsed
Size   Size    Size     Time     Throughput
bytes  bytes   bytes    secs.    10^6bits/sec

 87380  16384  16384    10.01    5001.46
[   81.888489] skb->len 65230 skb->gso_size 1448 skb->proto 0x8100
skb->mac_len 0 vlan_depth 18 type 0x800

CC: Vlad Yasevich <vyasevic@redhat.com>
CC: Eric Dumazet <eric.dumazet@gmail.com>
CC: Daniel Borkman <dborkman@redhat.com>
CC: David S. Miller <davem@davemloft.net>

Fixes:1e785f48d29a ("net: Start with correct mac_len in
skb_network_protocol")
Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
Note: A good side-effect of this patch is that in the mac_len > 0
case we'll directly look in the last vlan header in the while loop later
(mac_len - VLAN_HLEN), so it should take only a single iteration.
Also I'm working on getting mac_len always correct for net-next, so we can
get rid of this later. My plan currently is to make dev_hard_header()
adjust mac_len according to the return value from create(), but I'll have
to look into if that's enough and if it's feasible. Any suggestions on this
are very welcome.

 net/core/dev.c | 16 +++++++++++++++-
 1 file changed, 15 insertions(+), 1 deletion(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 9abc503b19b7..94167fc660b1 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2283,8 +2283,8 @@ EXPORT_SYMBOL(skb_checksum_help);
 
 __be16 skb_network_protocol(struct sk_buff *skb, int *depth)
 {
+	unsigned int vlan_depth = skb->mac_len;
 	__be16 type = skb->protocol;
-	int vlan_depth = skb->mac_len;
 
 	/* Tunnel gso handlers can set protocol to ethernet. */
 	if (type == htons(ETH_P_TEB)) {
@@ -2297,6 +2297,20 @@ __be16 skb_network_protocol(struct sk_buff *skb, int *depth)
 		type = eth->h_proto;
 	}
 
+	/* if skb->protocol is 802.1Q/AD then the header should already be
+	 * present at mac_len - VLAN_HLEN (if mac_len > 0), or at
+	 * ETH_HLEN otherwise
+	 */
+	if (type == htons(ETH_P_8021Q) || type == htons(ETH_P_8021AD)) {
+		if (vlan_depth) {
+			if (unlikely(WARN_ON(vlan_depth < VLAN_HLEN)))
+				return 0;
+			vlan_depth -= VLAN_HLEN;
+		} else {
+			vlan_depth = ETH_HLEN;
+		}
+	}
+
 	while (type == htons(ETH_P_8021Q) || type == htons(ETH_P_8021AD)) {
 		struct vlan_hdr *vh;
 
-- 
1.8.5.3
