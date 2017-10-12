From: Girish Moodalbail <girish.moodalbail@oracle.com>
Subject: [RFC] Support for UNARP (RFC 1868)
Date: Wed, 11 Oct 2017 21:36:17 -0700
Message-ID: <1507782977-2443-1-git-send-email-girish.moodalbail@oracle.com>
To: netdev@vger.kernel.org, davem@davemloft.net, kuznet@ms2.inr.ac.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:46831 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750738AbdJLE5f (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2017 00:57:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for UNARP, as detailed in the IETF RFC 1868 (ARP Extension -
UNARP). The central idea here is for a node to announce that it is
leaving the network and that all the nodes on the L2 broadcast domain to
update their ARP tables accordingly (i.e., mark the neighbor entry state
to FAILED). Even though the ARP timers on nodes would eventually  mark
such entries as FAILED it will be more robust if those entries gets
marked FAILED sooner with the help from the host that is going away.

Besides providing a solution for an usecase, as captured in RFC, of an
IP address moving across a proxy server, this feature is even more
important for certain use cases in the Cloud. Imagine a tenant who is
bringing up and down VM instances for some workload of theirs. If these
instances are part of a small subnet, then the new VM instances may be
assigned the same IP address (since the subnet pool is small) but with a
different MAC address. So, if there is a client which has a stale
mapping of the IP address to the old MAC address, then that client will
fail to communicate with the new VM instance for some time.

Another usecase that comes to mind is that of the Live VM
Migration. Imagine a client that is communicating with a VM. Now, let us
migrate this VM to a destination machine. The IP address to MAC address
mapping for a VM doesn't change after the Live Migration. However, there
will be a small amount of time (till the VM sends gratuitous ARP from
the destination machine) during which packets from a client will be
forwarded to the source machine. This occurs because:

 - the ARP entry in the client is not invalidated yet and it continues
   to use the same MAC address and

 - the MAC address table of all of the intermediate switches between the
   client and the source machine are not updated yet for the MAC address
   move.

This issue of forwarding the packets to wrong target could be avoided by
sending UNARP packets from the source machine. This would invalidate the
ARP entry on the client and forces it to resolve the IP address again by
broadcasting an ARP request to the network. The VM on the destination
machine would then respond back with an ARP response. The ARP response
back from the VM should also clean up the MAC address table of the
intermediate switches.

The following changes implements the UNARP receive processing in the
kernel. Once the changes are in the kernel, arping(8) program can be
updated to send UNARP packets.

Any Thoughts/Comments?

Signed-off-by: Girish Moodalbail <girish.moodalbail@oracle.com>
---

Compile-tested only.

 net/ipv4/arp.c | 46 +++++++++++++++++++++++++++++++++++-----------
 1 file changed, 35 insertions(+), 11 deletions(-)

diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index 7c45b88..8cb9aa1 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -686,6 +686,7 @@ static int arp_process(struct net *net, struct sock *sk, struct sk_buff *skb)
 	struct neighbour *n;
 	struct dst_entry *reply_dst = NULL;
 	bool is_garp = false;
+	bool is_unarp;
 
 	/* arp_rcv below verifies the ARP header and verifies the device
 	 * is ARP'able.
@@ -695,6 +696,8 @@ static int arp_process(struct net *net, struct sock *sk, struct sk_buff *skb)
 		goto out_free_skb;
 
 	arp = arp_hdr(skb);
+	/* arp_rcv has already verified the header for the UNARP case */
+	is_unarp = arp->ar_hln == 0;
 
 	switch (dev_type) {
 	default:
@@ -741,8 +744,8 @@ static int arp_process(struct net *net, struct sock *sk, struct sk_buff *skb)
  *	Extract fields
  */
 	arp_ptr = (unsigned char *)(arp + 1);
-	sha	= arp_ptr;
-	arp_ptr += dev->addr_len;
+	sha = is_unarp ? NULL : arp_ptr;
+	arp_ptr += arp->ar_hln;
 	memcpy(&sip, arp_ptr, 4);
 	arp_ptr += 4;
 	switch (dev_type) {
@@ -751,8 +754,8 @@ static int arp_process(struct net *net, struct sock *sk, struct sk_buff *skb)
 		break;
 #endif
 	default:
-		tha = arp_ptr;
-		arp_ptr += dev->addr_len;
+		tha = is_unarp ? NULL : arp_ptr;
+		arp_ptr += arp->ar_hln;
 	}
 	memcpy(&tip, arp_ptr, 4);
 /*
@@ -874,7 +877,10 @@ static int arp_process(struct net *net, struct sock *sk, struct sk_buff *skb)
 		   It is possible, that this option should be enabled for some
 		   devices (strip is candidate)
 		 */
-		if (!n &&
+		/* If the packet is UNARP and we don't have the corresponding
+		 * neighbour entry, then there is nothing to do.
+		 */
+		if (!n && !is_unarp &&
 		    (is_garp ||
 		     (arp->ar_op == htons(ARPOP_REPLY) &&
 		      (addr_type == RTN_UNICAST ||
@@ -899,12 +905,15 @@ static int arp_process(struct net *net, struct sock *sk, struct sk_buff *skb)
 				      NEIGH_VAR(n->parms, LOCKTIME)) ||
 			   is_garp;
 
-		/* Broadcast replies and request packets
-		   do not assert neighbour reachability.
-		 */
-		if (arp->ar_op != htons(ARPOP_REPLY) ||
-		    skb->pkt_type != PACKET_HOST)
+		if (is_unarp) {
+			state = NUD_FAILED;
+		} else if (arp->ar_op != htons(ARPOP_REPLY) ||
+			   skb->pkt_type != PACKET_HOST) {
+			/* Broadcast replies and request packets
+			 * do not assert neighbour reachability.
+			 */
 			state = NUD_STALE;
+		}
 		neigh_update(n, sha, state,
 			     override ? NEIGH_UPDATE_F_OVERRIDE : 0, 0);
 		neigh_release(n);
@@ -936,6 +945,7 @@ static int arp_rcv(struct sk_buff *skb, struct net_device *dev,
 		   struct packet_type *pt, struct net_device *orig_dev)
 {
 	const struct arphdr *arp;
+	bool is_unarp = false;
 
 	/* do not tweak dropwatch on an ARP we will ignore */
 	if (dev->flags & IFF_NOARP ||
@@ -952,7 +962,21 @@ static int arp_rcv(struct sk_buff *skb, struct net_device *dev,
 		goto freeskb;
 
 	arp = arp_hdr(skb);
-	if (arp->ar_hln != dev->addr_len || arp->ar_pln != 4)
+	/* RFC 1868 (UNARP) allows zero-length hardware address in
+	 * ARPOP_REPLY and target protocol address will be set to
+	 * 255.255.255.255.
+	 */
+	if (unlikely(arp->ar_hln == 0)) {
+		unsigned char *arp_ptr;
+
+		arp_ptr = (unsigned char *)(arp + 1);
+		if (arp->ar_op != htons(ARPOP_REPLY) ||
+		    !ipv4_is_lbcast(*(__be32 *)(arp_ptr + 4)))
+			goto freeskb;
+		is_unarp = true;
+	}
+
+	if ((!is_unarp && arp->ar_hln != dev->addr_len) || arp->ar_pln != 4)
 		goto freeskb;
 
 	memset(NEIGH_CB(skb), 0, sizeof(struct neighbour_cb));
-- 
1.8.3.1
