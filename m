From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 3/5] bpf: bpf_lock on kallsysms doesn't need to be irqsave
Date: Thu, 27 Apr 2017 01:39:33 +0200
Message-ID: <3342650e0503eb54688fedb3d015c4d212a36f95.1493249192.git.daniel@iogearbox.net>
References: <cover.1493249192.git.daniel@iogearbox.net>
Cc: ast@fb.com, netdev@vger.kernel.org,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:57406 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754578AbdDZXk5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2017 19:40:57 -0400
In-Reply-To: <cover.1493249192.git.daniel@iogearbox.net>
In-Reply-To: <cover.1493249192.git.daniel@iogearbox.net>
References: <cover.1493249192.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>

Hannes rightfully spotted that the bpf_lock doesn't need to be
irqsave variant. We never perform any such updates where this
would be necessary (neither right now nor in future), therefore
relax this further.

Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 kernel/bpf/core.c | 12 ++++--------
 1 file changed, 4 insertions(+), 8 deletions(-)

diff --git a/kernel/bpf/core.c b/kernel/bpf/core.c
index b4f1cb0..6f81e0f 100644
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
1.9.3
