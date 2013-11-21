From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH 2/2] net: add BUG_ON if kernel advertises msg_namelen > sizeof(struct sockaddr_storage)
Date: Thu, 21 Nov 2013 03:14:34 +0100
Message-ID: <20131121021434.GA1012@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: eric.dumazet@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:56119 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755355Ab3KUCOf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Nov 2013 21:14:35 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In that case it is probable that kernel code overwrote part of the
stack. So we should bail out loudly here.

The BUG_ON may be removed in future if we are sure all protocols are
conformant.

Suggested-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
In the long term I want to add BUILD_BUG_ONs to catch these. I currently don't
know how to add them so they don't get missed by future new implementations.

Maybe a coccinelle check is better suited for this job.

I would suggest it for stable, too. Maybe after it cooked a bit on net
and in a RC.

 net/socket.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/socket.c b/net/socket.c
index fc28556..0b18693 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -221,12 +221,13 @@ static int move_addr_to_user(struct sockaddr_storage *kaddr, int klen,
 	int err;
 	int len;
 
+	BUG_ON(klen > sizeof(struct sockaddr_storage));
 	err = get_user(len, ulen);
 	if (err)
 		return err;
 	if (len > klen)
 		len = klen;
-	if (len < 0 || len > sizeof(struct sockaddr_storage))
+	if (len < 0)
 		return -EINVAL;
 	if (len) {
 		if (audit_sockaddr(klen, kaddr))
-- 
1.8.3.1
