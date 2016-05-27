From: Michal Kubecek <mkubecek@suse.cz>
Subject: [PATCH net-next] net: disable fragment reassembly if high_thresh is
 zero
Date: Fri, 27 May 2016 17:53:52 +0200
Message-ID: <20160602203318.1CF6FA0E60@unicorn.suse.cz>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:48447 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753028AbcFBUdW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Jun 2016 16:33:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Before commit 6d7b857d541e ("net: use lib/percpu_counter API for
fragmentation mem accounting"), setting the reassembly high threshold
to 0 prevented fragment reassembly as first fragment would be always
evicted before second could be added to the queue. While inefficient,
some users apparently relied on this method.

Since the commit mentioned above, a percpu counter is used for
reassembly memory accounting and high batch size avoids taking slow path
in most common scenarios. As a result, a whole full sized packet can be
reassembled without the percpu counter's main counter changing its value
so that even with high_thresh set to 0, fragmented packets can be still
reassembled and processed.

Add explicit check preventing reassembly if high threshold is zero.

Signed-off-by: Michal Kubecek <mkubecek@suse.cz>
---
 net/ipv4/inet_fragment.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/inet_fragment.c b/net/ipv4/inet_fragment.c
index 3a88b0c73797..b5e9317eaf9e 100644
--- a/net/ipv4/inet_fragment.c
+++ b/net/ipv4/inet_fragment.c
@@ -355,7 +355,7 @@ static struct inet_frag_queue *inet_frag_alloc(struct netns_frags *nf,
 {
 	struct inet_frag_queue *q;
 
-	if (frag_mem_limit(nf) > nf->high_thresh) {
+	if (!nf->high_thresh || frag_mem_limit(nf) > nf->high_thresh) {
 		inet_frag_schedule_worker(f);
 		return NULL;
 	}
-- 
2.8.3
