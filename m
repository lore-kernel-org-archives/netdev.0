From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net: force dst_default_metrics to const section
Date: Tue, 07 Aug 2012 18:11:18 +0200
Message-ID: <1344355878.28967.113.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:33427 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751359Ab2HGQLW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Aug 2012 12:11:22 -0400
Received: by eeil10 with SMTP id l10so1245805eei.19
        for <netdev@vger.kernel.org>; Tue, 07 Aug 2012 09:11:21 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

While investigating on network performance problems, I found this little
gem :

$ nm -v vmlinux | grep -1 dst_default_metrics
ffffffff82736540 b busy.46605 
ffffffff82736560 B dst_default_metrics
ffffffff82736598 b dst_busy_list

Apparently, declaring a const array without initializer put it in
(writeable) bss section, in middle of possibly often dirtied cache
lines.

Since we really want dst_default_metrics be const to avoid any possible
false sharing and catch any buggy writes, I force a null initializer.

ffffffff818a4c20 R dst_default_metrics

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
For reference, dst_default_metrics was added in 2.6.39

 net/core/dst.c |   10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/net/core/dst.c b/net/core/dst.c
index 069d51d..4c538be 100644
--- a/net/core/dst.c
+++ b/net/core/dst.c
@@ -149,7 +149,15 @@ int dst_discard(struct sk_buff *skb)
 }
 EXPORT_SYMBOL(dst_discard);
 
-const u32 dst_default_metrics[RTAX_MAX];
+const u32 dst_default_metrics[RTAX_MAX] = {
+	/* This initializer is needed to force linker to place this variable
+	 * into const section. Otherwise it might end into bss section.
+	 * We really want to avoid false sharing on this variable, and catch
+	 * any writes on it.
+	 */
+	0
+};
+
 
 void *dst_alloc(struct dst_ops *ops, struct net_device *dev,
 		int initial_ref, int initial_obsolete, unsigned short flags)
