From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net 1/3] sched: cls_bpf: fix panic on filter replace
Date: Fri, 17 Jul 2015 22:38:43 +0200
Message-ID: <094e34b7e8d45a323c5cf18a366665654b3f3e45.1437163466.git.daniel@iogearbox.net>
References: <cover.1437163466.git.daniel@iogearbox.net>
Cc: ast@plumgrid.com, jiri@resnulli.us, jhs@mojatatu.com,
	edumazet@google.com, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:56595 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751964AbbGQUiy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jul 2015 16:38:54 -0400
In-Reply-To: <cover.1437163466.git.daniel@iogearbox.net>
In-Reply-To: <cover.1437163466.git.daniel@iogearbox.net>
References: <cover.1437163466.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following test case causes a NULL pointer dereference in cls_bpf:

  FOO="1,6 0 0 4294967295,"
  tc filter add dev foo parent 1: bpf bytecode "$FOO" flowid 1:1 action ok
  tc filter replace dev foo parent 1: pref 49152 handle 0x1 \
            bpf bytecode "$FOO" flowid 1:1 action drop

The problem is that commit 1f947bf151e9 ("net: sched: rcu'ify cls_bpf")
accidentally swapped the arguments of list_replace_rcu(), the old
element needs to be the first argument and the new element the second.

Fixes: 1f947bf151e9 ("net: sched: rcu'ify cls_bpf")
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 net/sched/cls_bpf.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sched/cls_bpf.c b/net/sched/cls_bpf.c
index c79ecfd..e5168f8 100644
--- a/net/sched/cls_bpf.c
+++ b/net/sched/cls_bpf.c
@@ -378,7 +378,7 @@ static int cls_bpf_change(struct net *net, struct sk_buff *in_skb,
 		goto errout;
 
 	if (oldprog) {
-		list_replace_rcu(&prog->link, &oldprog->link);
+		list_replace_rcu(&oldprog->link, &prog->link);
 		tcf_unbind_filter(tp, &oldprog->res);
 		call_rcu(&oldprog->rcu, __cls_bpf_delete_prog);
 	} else {
-- 
1.9.3
