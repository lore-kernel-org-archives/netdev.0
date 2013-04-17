From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 04/14] netlink: don't orphan skb in netlink_trim()
Date: Wed, 17 Apr 2013 18:46:59 +0200
Message-ID: <1366217229-22705-5-git-send-email-kaber@trash.net>
References: <1366217229-22705-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:60954 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S936065Ab3DQQrZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Apr 2013 12:47:25 -0400
In-Reply-To: <1366217229-22705-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Netlink doesn't account skbs to the sending socket, so the there's no
need to orphan the skb before trimming it.

Removing the skb_orphan() call is required for mmap'ed netlink, which uses
a netlink specific skb destructor that must not be invoked before the
final freeing of the skb.

Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/netlink/af_netlink.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 978a61f..26779c2 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -851,7 +851,7 @@ static struct sk_buff *netlink_trim(struct sk_buff *skb, gfp_t allocation)
 {
 	int delta;
 
-	skb_orphan(skb);
+	WARN_ON(skb->sk != NULL);
 
 	delta = skb->end - skb->tail;
 	if (delta * 2 < skb->truesize)
-- 
1.8.1.4
