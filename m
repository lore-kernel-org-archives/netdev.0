From: roy.qing.li@gmail.com
Subject: [PATCH] xfrm: check if packet is overdue on asynchronous code path
Date: Fri, 11 Jan 2013 16:12:45 +0800
Message-ID: <1357891965-8047-1-git-send-email-roy.qing.li@gmail.com>
Cc: steffen.klassert@secunet.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f41.google.com ([209.85.210.41]:44525 "EHLO
	mail-da0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753427Ab3AKIMw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jan 2013 03:12:52 -0500
Received: by mail-da0-f41.google.com with SMTP id e20so667448dak.28
        for <netdev@vger.kernel.org>; Fri, 11 Jan 2013 00:12:51 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

Currently checking is only done on synchronous code path,
we should do the same checking on asynchronous code path.

Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
---
 net/xfrm/xfrm_input.c |    6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/net/xfrm/xfrm_input.c b/net/xfrm/xfrm_input.c
index ab2bb42..d034324 100644
--- a/net/xfrm/xfrm_input.c
+++ b/net/xfrm/xfrm_input.c
@@ -199,6 +199,12 @@ int xfrm_input(struct sk_buff *skb, int nexthdr, __be32 spi, int encap_type)
 
 resume:
 		spin_lock(&x->lock);
+
+		if (async && xfrm_state_check_expire(x)) {
+			XFRM_INC_STATS(net, LINUX_MIB_XFRMINSTATEEXPIRED);
+			goto drop_unlock;
+		}
+
 		if (nexthdr <= 0) {
 			if (nexthdr == -EBADMSG) {
 				xfrm_audit_state_icvfail(x, skb,
-- 
1.7.10.4
