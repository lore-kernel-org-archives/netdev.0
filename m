From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 1/2] bpf: don't enable preemption twice in smap_do_verdict
Date: Thu, 17 Aug 2017 17:22:36 +0200
Message-ID: <d90eed71c2a723edd75f19fb1b921fec74d8a514.1502983087.git.daniel@iogearbox.net>
References: <cover.1502983087.git.daniel@iogearbox.net>
Cc: john.fastabend@gmail.com, ast@fb.com, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:60884 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753113AbdHQPWm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Aug 2017 11:22:42 -0400
In-Reply-To: <cover.1502983087.git.daniel@iogearbox.net>
In-Reply-To: <cover.1502983087.git.daniel@iogearbox.net>
References: <cover.1502983087.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In smap_do_verdict(), the fall-through branch leads to call
preempt_enable() twice for the SK_REDIRECT, which creates an
imbalance. Only enable it for all remaining cases again.

Fixes: 174a79ff9515 ("bpf: sockmap with sk redirect support")
Reported-by: Alexei Starovoitov <ast@kernel.org>
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 kernel/bpf/sockmap.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/kernel/bpf/sockmap.c b/kernel/bpf/sockmap.c
index f7e5e6c..39de541 100644
--- a/kernel/bpf/sockmap.c
+++ b/kernel/bpf/sockmap.c
@@ -135,7 +135,8 @@ static void smap_do_verdict(struct smap_psock *psock, struct sk_buff *skb)
 	/* Fall through and free skb otherwise */
 	case SK_DROP:
 	default:
-		preempt_enable();
+		if (rc != SK_REDIRECT)
+			preempt_enable();
 		kfree_skb(skb);
 	}
 }
-- 
1.9.3
