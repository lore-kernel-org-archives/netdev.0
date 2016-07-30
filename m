From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net] sctp: fix the issue sctp requeue auth chunk incorrectly
Date: Sat, 30 Jul 2016 13:58:35 +0800
Message-ID: <af1555c524101278be2e5b07ff78a1eaacc0f7bb.1469858315.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net,
	Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	Vlad Yasevich <vyasevich@gmail.com>, daniel@iogearbox.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f67.google.com ([209.85.220.67]:34316 "EHLO
	mail-pa0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750747AbcG3F6l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Jul 2016 01:58:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sctp needs to queue auth chunk back when we know that we are going
to generate another segment. But commit f1533cce60d1 ("sctp: fix
panic when sending auth chunks") requeues the last chunk processed
which is probably not the auth chunk.

It causes panic when calculating the MAC in sctp_auth_calculate_hmac(),
as the incorrect offset of the auth chunk in skb->data.

This fix is to requeue it by using packet->auth.

Fixes: f1533cce60d1 ("sctp: fix panic when sending auth chunks")
Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 net/sctp/output.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/sctp/output.c b/net/sctp/output.c
index 7425f6c..1f1682b 100644
--- a/net/sctp/output.c
+++ b/net/sctp/output.c
@@ -610,7 +610,8 @@ int sctp_packet_transmit(struct sctp_packet *packet, gfp_t gfp)
 				/* We will generate more packets, so re-queue
 				 * auth chunk.
 				 */
-				list_add(&chunk->list, &packet->chunk_list);
+				list_add(&packet->auth->list,
+					 &packet->chunk_list);
 			} else {
 				sctp_chunk_free(packet->auth);
 				packet->auth = NULL;
-- 
2.1.0
