From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net] ipv6: don't use CHECKSUM_PARTIAL on MSG_MORE/UDP_CORK sockets
Date: Tue, 20 Oct 2015 16:38:42 +0200
Message-ID: <1445351922-8463-1-git-send-email-hannes@stressinduktion.org>
Cc: sd@quesysnail.net, bcodding@redhat.com, vyasevich@gmail.com,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:59348 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751299AbbJTOjA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Oct 2015 10:39:00 -0400
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
	by mailout.nyi.internal (Postfix) with ESMTP id 9EFF820AC6
	for <netdev@vger.kernel.org>; Tue, 20 Oct 2015 10:38:49 -0400 (EDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

MSG_MORE might cause the packet to get fragmented in the end when
passed down to the flush function and the transhdrlen check alone is
not sufficient to protect against fragmentation. Instead check if the
socket user intends to add more data to the socket on the first packet.

This broke checksum calculation for UDPv6 for NFS protocols.

Fixes: 32dce968dd987 ("ipv6: Allow for partial checksums on non-ufo packets")
Cc: Vlad Yasevich <vyasevich@gmail.com>
Tested-by: Sabrina Dubroca <sd@quesysnail.net>
Tested-by: Benjamin Coddington <bcodding@redhat.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv6/ip6_output.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 61d403e..95c5780 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -1317,6 +1317,7 @@ emsgsize:
 	 * sums only work when transhdrlen is set.
 	 */
 	if (transhdrlen && sk->sk_protocol == IPPROTO_UDP &&
+	    !(flags & MSG_MORE) &&
 	    length + fragheaderlen < mtu &&
 	    rt->dst.dev->features & NETIF_F_V6_CSUM &&
 	    !exthdrlen)
-- 
2.4.3
