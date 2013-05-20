From: Matthew Rosato <mjrosato@linux.vnet.ibm.com>
Subject: [PATCH] net_sched: check skb_transport_header_was_set() in qdisc_pkt_len_init()
Date: Mon, 20 May 2013 14:47:30 -0400
Message-ID: <1369075650-21005-1-git-send-email-mjrosato@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e39.co.us.ibm.com ([32.97.110.160]:57110 "EHLO
	e39.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755949Ab3ETSrt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 May 2013 14:47:49 -0400
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <mjrosato@linux.vnet.ibm.com>;
	Mon, 20 May 2013 12:47:48 -0600
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 9AF351FF006B
	for <netdev@vger.kernel.org>; Mon, 20 May 2013 12:42:34 -0600 (MDT)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r4KIlWZn382368
	for <netdev@vger.kernel.org>; Mon, 20 May 2013 12:47:32 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r4KIlVN3024456
	for <netdev@vger.kernel.org>; Mon, 20 May 2013 12:47:32 -0600
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 1def9238d4aa2 (net_sched: more precise pkt_len computation) does
not check to see if skb_transport_header is valid prior to using it in
qdisc_pkt_len_init(), which can lead to a kernel panic if
skb_transport_header is not valid but gso_size is nonzero.  This patch
adds a check for skb_transport_header_was_set().

I managed to hit this scenario by driving a burst of traffic from a
qemu guest through a macvtap interface, causing a panic in the host kernel.

Signed-off-by: Matthew Rosato <mjrosato@linux.vnet.ibm.com>
---
 net/core/dev.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index fc1e289..5d0d3af 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2596,7 +2596,7 @@ static void qdisc_pkt_len_init(struct sk_buff *skb)
 	/* To get more precise estimation of bytes sent on wire,
 	 * we add to pkt_len the headers size of all segments
 	 */
-	if (shinfo->gso_size)  {
+	if (shinfo->gso_size && skb_transport_header_was_set(skb))  {
 		unsigned int hdr_len;
 		u16 gso_segs = shinfo->gso_segs;
 
-- 
1.7.9.5
