From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next] sched, bpf: let stack handle !IFF_UP devs on bpf_clone_redirect
Date: Wed, 23 Sep 2015 22:20:15 +0200
Message-ID: <a03c9b9daa9f779937fce9f6050a05a2dfeaaeec.1443039304.git.daniel@iogearbox.net>
Cc: ast@plumgrid.com, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:41102 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754480AbbIWUUT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2015 16:20:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Similarly as already the case in bpf_redirect()/skb_do_redirect()
pair, let the stack deal with devs that are !IFF_UP.

dev_forward_skb() as well as dev_queue_xmit() will free the skb
and increment drop counter internally in such cases, so we can
spare the condition in bpf_clone_redirect().

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 net/core/filter.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/net/core/filter.c b/net/core/filter.c
index da3f3d9..96bd962 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -1404,9 +1404,6 @@ static u64 bpf_clone_redirect(u64 r1, u64 ifindex, u64 flags, u64 r4, u64 r5)
 	if (unlikely(!dev))
 		return -EINVAL;
 
-	if (unlikely(!(dev->flags & IFF_UP)))
-		return -EINVAL;
-
 	skb2 = skb_clone(skb, GFP_ATOMIC);
 	if (unlikely(!skb2))
 		return -ENOMEM;
-- 
1.9.3
