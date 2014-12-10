From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next RESEND 1/2] tipc: fix RCU sparse error
Date: Wed, 10 Dec 2014 16:46:06 +0800
Message-ID: <1418201167-9591-2-git-send-email-ying.xue@windriver.com>
References: <1418201167-9591-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <eric.dumazet@gmail.com>,
	<jon.maloy@ericsson.com>, <erik.hugne@ericsson.com>,
	<netdev@vger.kernel.org>, <kbuild-all@01.org>,
	<linux-kernel@vger.kernel.org>
To: <paulmck@linux.vnet.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1418201167-9591-1-git-send-email-ying.xue@windriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The commit 97ede29e80ee ("tipc: convert name table read-write lock to
RCU") involves the following sparse when using

  make ARCH=x86_64 allmodconfig
  make C=1 CF=-D__CHECK_ENDIAN__

net/tipc/name_table.c:1136:17: sparse: incompatible types in comparison expression (different address spaces)
net/tipc/name_table.c:1136:17: sparse: incompatible types in comparison expression (different address spaces)

To silence above spare complaint, an RCU annotation should be added
to "next" pointer of hlist_node structure through hlist_next_rcu()
macro when iterating over a hlist with hlist_for_each_entry_from_rcu().

By the way, this commit also simplifies the way of dereferencing
the first element of a hlist_head list by replacing
hlist_for_each_entry_rcu() with hlist_entry_safe().

Reported-by: Kbuild test robot <kbuild-all@01.org>
Cc: Kbuild test robot <kbuild-all@01.org>
Signed-off-by: Ying Xue <ying.xue@windriver.com>
---
 include/linux/rculist.h |    4 ++--
 net/tipc/name_table.c   |    6 +++---
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/include/linux/rculist.h b/include/linux/rculist.h
index aa79b3c..866d9c9 100644
--- a/include/linux/rculist.h
+++ b/include/linux/rculist.h
@@ -549,8 +549,8 @@ static inline void hlist_add_behind_rcu(struct hlist_node *n,
  */
 #define hlist_for_each_entry_from_rcu(pos, member)			\
 	for (; pos;							\
-	     pos = hlist_entry_safe(rcu_dereference((pos)->member.next),\
-			typeof(*(pos)), member))
+	     pos = hlist_entry_safe(rcu_dereference_raw(hlist_next_rcu( \
+			&(pos)->member)), typeof(*(pos)), member))
 
 #endif	/* __KERNEL__ */
 #endif
diff --git a/net/tipc/name_table.c b/net/tipc/name_table.c
index c8df022..fa4341f 100644
--- a/net/tipc/name_table.c
+++ b/net/tipc/name_table.c
@@ -1110,7 +1110,7 @@ static int __tipc_nl_seq_list(struct tipc_nl_msg *msg, u32 *last_type,
 			      u32 *last_lower, u32 *last_publ)
 {
 	struct hlist_head *seq_head;
-	struct name_seq *seq = NULL;
+	struct name_seq *seq;
 	int err;
 	int i;
 
@@ -1127,8 +1127,8 @@ static int __tipc_nl_seq_list(struct tipc_nl_msg *msg, u32 *last_type,
 			if (!seq)
 				return -EPIPE;
 		} else {
-			hlist_for_each_entry_rcu(seq, seq_head, ns_list)
-				break;
+			seq = hlist_entry_safe(rcu_dereference_raw(
+			hlist_first_rcu(seq_head)), struct name_seq, ns_list);
 			if (!seq)
 				continue;
 		}
-- 
1.7.9.5
