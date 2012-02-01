From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: [PATCH RFC tip/core/rcu 10/41] ipv4: Convert call_rcu() to kfree_rcu()
Date: Wed,  1 Feb 2012 11:41:28 -0800
Message-ID: <1328125319-5205-10-git-send-email-paulmck@linux.vnet.ibm.com>
References: <20120201194131.GA10028@linux.vnet.ibm.com>
 <1328125319-5205-1-git-send-email-paulmck@linux.vnet.ibm.com>
Cc: mingo@elte.hu, laijs@cn.fujitsu.com, dipankar@in.ibm.com,
	akpm@linux-foundation.org, mathieu.desnoyers@polymtl.ca,
	josh@joshtriplett.org, niv@us.ibm.com, tglx@linutronix.de,
	peterz@infradead.org, rostedt@goodmis.org, Valdis.Kletnieks@vt.edu,
	dhowells@redhat.com, eric.dumazet@gmail.com, darren@dvhart.com,
	fweisbec@gmail.com, patches@linaro.org,
	"Paul E. McKenney" <paul.mckenney@linaro.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1328125319-5205-1-git-send-email-paulmck@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Paul E. McKenney" <paul.mckenney@linaro.org>

The call_rcu() in do_ip_setsockopt() invokes opt_kfree_rcu(), which just
calls kfree().  So convert the call_rcu() to kfree_rcu(), which allows
opt_kfree_rcu() to be eliminated.

Signed-off-by: Paul E. McKenney <paul.mckenney@linaro.org>
Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Cc: James Morris <jmorris@namei.org>
Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Cc: Patrick McHardy <kaber@trash.net>
Cc: netdev@vger.kernel.org
---
 net/ipv4/ip_sockglue.c |    7 +------
 1 files changed, 1 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index 8aa87c1..5343d9a 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -445,11 +445,6 @@ out:
 }
 
 
-static void opt_kfree_rcu(struct rcu_head *head)
-{
-	kfree(container_of(head, struct ip_options_rcu, rcu));
-}
-
 /*
  *	Socket option code for IP. This is the end of the line after any
  *	TCP,UDP etc options on an IP socket.
@@ -525,7 +520,7 @@ static int do_ip_setsockopt(struct sock *sk, int level,
 		}
 		rcu_assign_pointer(inet->inet_opt, opt);
 		if (old)
-			call_rcu(&old->rcu, opt_kfree_rcu);
+			kfree_rcu(old, rcu);
 		break;
 	}
 	case IP_PKTINFO:
-- 
1.7.8
