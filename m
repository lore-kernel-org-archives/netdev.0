From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net 2/3] sched: cls_flower: fix panic on filter replace
Date: Fri, 17 Jul 2015 22:38:44 +0200
Message-ID: <65e84800671280bdf16ea28f71ecef3d5fcecccc.1437163466.git.daniel@iogearbox.net>
References: <cover.1437163466.git.daniel@iogearbox.net>
Cc: ast@plumgrid.com, jiri@resnulli.us, jhs@mojatatu.com,
	edumazet@google.com, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:56597 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751702AbbGQUiz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jul 2015 16:38:55 -0400
In-Reply-To: <cover.1437163466.git.daniel@iogearbox.net>
In-Reply-To: <cover.1437163466.git.daniel@iogearbox.net>
References: <cover.1437163466.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following test case causes a NULL pointer dereference in cls_flower:

  tc filter add dev foo parent 1: flower eth_type ipv4 action ok flowid 1:1
  tc filter replace dev foo parent 1: pref 49152 handle 0x1 \
            flower eth_type ipv6 action ok flowid 1:1

The problem is that commit 77b9900ef53a ("tc: introduce Flower classifier")
accidentally swapped the arguments of list_replace_rcu(), the old
element needs to be the first argument and the new element the second.

Fixes: 77b9900ef53a ("tc: introduce Flower classifier")
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 net/sched/cls_flower.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sched/cls_flower.c b/net/sched/cls_flower.c
index 9d37ccd..2f3d03f 100644
--- a/net/sched/cls_flower.c
+++ b/net/sched/cls_flower.c
@@ -499,7 +499,7 @@ static int fl_change(struct net *net, struct sk_buff *in_skb,
 	*arg = (unsigned long) fnew;
 
 	if (fold) {
-		list_replace_rcu(&fnew->list, &fold->list);
+		list_replace_rcu(&fold->list, &fnew->list);
 		tcf_unbind_filter(tp, &fold->res);
 		call_rcu(&fold->rcu, fl_destroy_filter);
 	} else {
-- 
1.9.3
