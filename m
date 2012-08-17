From: Michael Wang <wangyun@linux.vnet.ibm.com>
Subject: [PATCH 3/3] netfilter: replace list_for_each_continue_rcu with new
 interface
Date: Fri, 17 Aug 2012 12:33:39 +0800
Message-ID: <502DC9A3.2070703@linux.vnet.ibm.com>
References: <502CB939.3050008@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, kaber@trash.net,
	pablo@netfilter.org,
	"paulmck@linux.vnet.ibm.com" <paulmck@linux.vnet.ibm.com>
To: LKML <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	netfilter@vger.kernel.org, coreteam@netfilter.org,
	netfilter-devel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <502CB939.3050008@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michael Wang <wangyun@linux.vnet.ibm.com>

This patch replaces list_for_each_continue_rcu() with
list_for_each_entry_continue_rcu() to allow removing
list_for_each_continue_rcu().

Signed-off-by: Michael Wang <wangyun@linux.vnet.ibm.com>
---
 net/netfilter/core.c |   11 +++++++----
 1 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/net/netfilter/core.c b/net/netfilter/core.c
index e19f365..50225bd 100644
--- a/net/netfilter/core.c
+++ b/net/netfilter/core.c
@@ -131,14 +131,14 @@ unsigned int nf_iterate(struct list_head *head,
 			int hook_thresh)
 {
 	unsigned int verdict;
+	struct nf_hook_ops *elem = list_entry_rcu(*i,
+						struct nf_hook_ops, list);

 	/*
 	 * The caller must not block between calls to this
 	 * function because of risk of continuing from deleted element.
 	 */
-	list_for_each_continue_rcu(*i, head) {
-		struct nf_hook_ops *elem = (struct nf_hook_ops *)*i;
-
+	list_for_each_entry_continue_rcu(elem, head, list) {
 		if (hook_thresh > elem->priority)
 			continue;

@@ -155,11 +155,14 @@ repeat:
 				continue;
 			}
 #endif
-			if (verdict != NF_REPEAT)
+			if (verdict != NF_REPEAT) {
+				*i = &elem->list;
 				return verdict;
+			}
 			goto repeat;
 		}
 	}
+	*i = &elem->list;
 	return NF_ACCEPT;
 }

-- 
1.7.4.1
