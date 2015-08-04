From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 11/18] netfilter: Fix memory leak in nf_register_net_hook
Date: Tue,  4 Aug 2015 12:02:41 +0200
Message-ID: <1438682568-8346-12-git-send-email-pablo@netfilter.org>
References: <1438682568-8346-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1438682568-8346-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Eric W. Biederman" <ebiederm@xmission.com>

In the rare case that when it is a attempted to use a per network device
netfilter hook and the network device does not exist the newly allocated
structure can leak.

Be a good citizen and free the newly allocated structure in the error
handling code.

Fixes: 085db2c04557 ("netfilter: Per network namespace netfilter hooks.")
Reported-by: kbuild@01.org
Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/core.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/core.c b/net/netfilter/core.c
index 6896cee..87d237d 100644
--- a/net/netfilter/core.c
+++ b/net/netfilter/core.c
@@ -96,8 +96,10 @@ int nf_register_net_hook(struct net *net, const struct nf_hook_ops *reg)
 	new->priority = reg->priority;
 
 	nf_hook_list = find_nf_hook_list(net, reg);
-	if (!nf_hook_list)
+	if (!nf_hook_list) {
+		kfree(new);
 		return -ENOENT;
+	}
 
 	mutex_lock(&nf_hook_mutex);
 	list_for_each_entry(elem, nf_hook_list, list) {
-- 
1.7.10.4

