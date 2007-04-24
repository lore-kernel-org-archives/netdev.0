From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [RFC] bridge: if no STP then forward all BPDU's
Date: Tue, 24 Apr 2007 16:12:26 -0700
Message-ID: <20070424161226.0372f5e8@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([65.172.181.25]:55950 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754642AbXDXXOv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Apr 2007 19:14:51 -0400
Received: from shell0.pdx.osdl.net (fw.osdl.org [65.172.181.6])
	by smtp1.linux-foundation.org (8.13.5.20060308/8.13.5/Debian-3ubuntu1.1) with ESMTP id l3ONEngi017013
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Tue, 24 Apr 2007 16:14:50 -0700
Received: from dxpl.pdx.osdl.net (dxpl.pdx.osdl.net [10.8.0.74])
	by shell0.pdx.osdl.net (8.13.1/8.11.6) with ESMTP id l3ONEnun021928
	for <netdev@vger.kernel.org>; Tue, 24 Apr 2007 16:14:49 -0700
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The bridge code by default captures all spanning tree packets and
doesn't forward them. I propose that this might not be a good idea.

If a bridge is not running STP, then it has no way to detect a cycle
in the network (by itself). But if some other machine is running STP,
then if STP BPDU's get forwarded to the STP can detect the cycle
(and turn off that link).  

              +------------+ <-BPDU-  +--------+
              | transparent|==========| STP    |
              |  bridge    |==========| bridge |=== ...
              +------------+ -BPDU->  +--------+
 

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
---
 net/bridge/br_input.c |   12 ++++++++++--
 1 file changed, 10 insertions(+), 2 deletions(-)

--- bridge-2.6.22.orig/net/bridge/br_input.c
+++ bridge-2.6.22/net/bridge/br_input.c
@@ -131,8 +131,16 @@ struct sk_buff *br_handle_frame(struct n
 	if (!is_valid_ether_addr(eth_hdr(skb)->h_source))
 		goto drop;
 
-	if (unlikely(is_link_local(dest))) {
-		skb->pkt_type = PACKET_HOST;
+	/*
+	 * If STP is running, then trap all link-local (802.1x) frames
+	 * process through normal receive path.
+	 *
+	 * For safety, if not running STP then act as a completely transparent
+	 * device. This means that if STP is running on another machine, it
+	 * can still detect cycles.
+	 */
+	if (p->br->stp_enabled != BR_NO_STP && is_link_local(dest)) {
+		/* skb->pkt_type should already be PACKET_MULTICAST */
 
 		return (NF_HOOK(PF_BRIDGE, NF_BR_LOCAL_IN, skb, skb->dev,
 				NULL, br_handle_local_finish) == 0) ? skb : NULL;
