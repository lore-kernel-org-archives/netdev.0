From: Roman Gushchin <klamm@yandex-team.ru>
Subject: [PATCH] rcu: fix a race in hlist_nulls_for_each_entry_rcu macro
Date: Tue, 21 May 2013 13:05:48 +0400
Message-ID: <519B38EC.90401@yandex-team.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: zhmurov@yandex-team.ru, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Dipankar Sarma <dipankar@in.ibm.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi, all!

This is a fix for a problem described here:
https://lkml.org/lkml/2013/4/16/371 .
---

Some network functions (udp4_lib_lookup2(), for instance) use the
hlist_nulls_for_each_entry_rcu macro in a way that assumes restarting
of a loop. In this case, it is strictly necessary to reread the head->first
value from the memory before each scan.
Without additional hints, gcc caches this value in a register. In this case,
if a cached node is moved to another chain during the scan, we can loop
forever getting wrong nulls values and restarting the loop uninterruptedly.

Signed-off-by: Roman Gushchin <klamm@yandex-team.ru>
Reported-by: Boris Zhmurov <zhmurov@yandex-team.ru>
---
  include/linux/rculist_nulls.h | 5 +++--
  1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/include/linux/rculist_nulls.h b/include/linux/rculist_nulls.h
index 2ae1371..efd51bf 100644
--- a/include/linux/rculist_nulls.h
+++ b/include/linux/rculist_nulls.h
@@ -37,8 +37,9 @@ static inline void hlist_nulls_del_init_rcu(struct 
hlist_nulls_node *n)
  	}
  }

-#define hlist_nulls_first_rcu(head) \
-	(*((struct hlist_nulls_node __rcu __force **)&(head)->first))
+#define hlist_nulls_first_rcu(head)			\
+	(*((struct hlist_nulls_node __rcu __force **)	\
+	   &((volatile typeof(*head) *)head)->first))

  #define hlist_nulls_next_rcu(node) \
  	(*((struct hlist_nulls_node __rcu __force **)&(node)->next))
-- 
1.8.1.2
