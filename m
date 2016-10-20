From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net] net: saving irq context for peernet2id()
Date: Wed, 19 Oct 2016 23:52:32 -0700
Message-ID: <1476946352-15770-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: sds@tycho.nsa.gov, e@eladraz.com, paul@paul-moore.com,
        Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:33097 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754931AbcJTGw6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2016 02:52:58 -0400
Received: by mail-pf0-f194.google.com with SMTP id i85so4660874pfa.0
        for <netdev@vger.kernel.org>; Wed, 19 Oct 2016 23:52:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A kernel warning inside __local_bh_enable_ip() was reported by people
running SELinux, this is caused due to some SELinux functions
(indirectly) call peernet2id() with IRQ disabled in process context,
when we re-enable BH with IRQ disabled kernel complains. Shut up this
warning by saving IRQ context in peernet2id(), BH is still implicitly
disabled.

Fixes: bc51dddf98c9 ("netns: avoid disabling irq for netns id")
Reported-by: Stephen Smalley <sds@tycho.nsa.gov>
Reported-by: Elad Raz <e@eladraz.com>
Tested-by: Paul Moore <paul@paul-moore.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/core/net_namespace.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index 989434f..17b52a2 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -230,11 +230,16 @@ int peernet2id_alloc(struct net *net, struct net *peer)
 /* This function returns, if assigned, the id of a peer netns. */
 int peernet2id(struct net *net, struct net *peer)
 {
+	unsigned long flags;
 	int id;
 
-	spin_lock_bh(&net->nsid_lock);
+	/* This is ugly, technically we only need to disable BH, however some
+	 * callers (indirectly) call this with IRQ disabled, which implies
+	 * that we should save the IRQ context here.
+	 */
+	spin_lock_irqsave(&net->nsid_lock, flags);
 	id = __peernet2id(net, peer);
-	spin_unlock_bh(&net->nsid_lock);
+	spin_unlock_irqrestore(&net->nsid_lock, flags);
 	return id;
 }
 EXPORT_SYMBOL(peernet2id);
-- 
2.1.0
