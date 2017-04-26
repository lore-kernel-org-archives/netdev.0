From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next 1/6] bpf: bpf_lock needs only block bottom half
Date: Wed, 26 Apr 2017 20:24:14 +0200
Message-ID: <20170426182419.14574-2-hannes@stressinduktion.org>
References: <20170426182419.14574-1-hannes@stressinduktion.org>
Cc: ast@kernel.org, daniel@iogearbox.com, jbenc@redhat.com,
        aconole@bytheb.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:36995 "EHLO
        out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S933328AbdDZSYr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2017 14:24:47 -0400
In-Reply-To: <20170426182419.14574-1-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We never modify bpf programs from hardirqs ever.

Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 kernel/bpf/core.c | 12 ++++--------
 1 file changed, 4 insertions(+), 8 deletions(-)

diff --git a/kernel/bpf/core.c b/kernel/bpf/core.c
index b4f1cb0c5ac710..6f81e0f5a0faa2 100644
--- a/kernel/bpf/core.c
+++ b/kernel/bpf/core.c
@@ -394,27 +394,23 @@ static bool bpf_prog_kallsyms_verify_off(const struct bpf_prog *fp)
 
 void bpf_prog_kallsyms_add(struct bpf_prog *fp)
 {
-	unsigned long flags;
-
 	if (!bpf_prog_kallsyms_candidate(fp) ||
 	    !capable(CAP_SYS_ADMIN))
 		return;
 
-	spin_lock_irqsave(&bpf_lock, flags);
+	spin_lock_bh(&bpf_lock);
 	bpf_prog_ksym_node_add(fp->aux);
-	spin_unlock_irqrestore(&bpf_lock, flags);
+	spin_unlock_bh(&bpf_lock);
 }
 
 void bpf_prog_kallsyms_del(struct bpf_prog *fp)
 {
-	unsigned long flags;
-
 	if (!bpf_prog_kallsyms_candidate(fp))
 		return;
 
-	spin_lock_irqsave(&bpf_lock, flags);
+	spin_lock_bh(&bpf_lock);
 	bpf_prog_ksym_node_del(fp->aux);
-	spin_unlock_irqrestore(&bpf_lock, flags);
+	spin_unlock_bh(&bpf_lock);
 }
 
 static struct bpf_prog *bpf_prog_kallsyms_find(unsigned long addr)
-- 
2.9.3
