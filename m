From: Cosmin Ratiu <cratiu@ixiacom.com>
Subject: [PATCH] ipv6: Fix tcp_v6_send_response(): it didn't set skb transport header
Date: Thu, 3 Sep 2009 19:25:53 +0300
Message-ID: <200909031925.54197.cratiu@ixiacom.com>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_S4+nKuLOEDC3V0k"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:13057 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755974AbZICQYd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Sep 2009 12:24:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--Boundary-00=_S4+nKuLOEDC3V0k
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hello,

Here is a patch which fixes an issue observed when using TCP over IPv6 and AH 
from IPsec.

When a connection gets closed the 4-way method and the last ACK from the 
server gets dropped, the subsequent FINs from the client do not get ACKed 
because tcp_v6_send_response does not set the transport header pointer. This 
causes ah6_output to try to allocate a lot of memory, which typically fails, 
so the ACKs never make it out of the stack.

I have reproduced the problem on kernel 2.6.7, but after looking at the latest 
kernel it seems the problem is still there.

Cosmin.

Signed-off-by: Cosmin Ratiu <cratiu@ixiacom.com>
---
 net/ipv6/tcp_ipv6.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)



--Boundary-00=_S4+nKuLOEDC3V0k
Content-Type: text/x-patch;
  charset="utf-8";
  name="0001-ipv6-Fix-tcp_v6_send_response-it-didn-t-set-skb-trans.mbox"
Content-Transfer-Encoding: 8bit
Content-Disposition: inline;
	filename="0001-ipv6-Fix-tcp_v6_send_response-it-didn-t-set-skb-trans.mbox"

diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index d849dd5..776e911 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1003,6 +1003,7 @@ static void tcp_v6_send_response(struct sk_buff *skb, u32 seq, u32 ack, u32 win,
 	skb_reserve(buff, MAX_HEADER + sizeof(struct ipv6hdr) + tot_len);
 
 	t1 = (struct tcphdr *) skb_push(buff, tot_len);
+	skb_reset_transport_header(skb);
 
 	/* Swap the send and the receive. */
 	memset(t1, 0, sizeof(*t1));

--Boundary-00=_S4+nKuLOEDC3V0k--


