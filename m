From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: [PATCH tip/core/rcu 09/47] ipv4: Convert call_rcu() to kfree_rcu(), drop opt_kfree_rcu()
Date: Fri,  3 Feb 2012 17:44:44 -0800
Message-ID: <1328319922-30828-9-git-send-email-paulmck@linux.vnet.ibm.com>
References: <20120204014452.GA29811@linux.vnet.ibm.com>
 <1328319922-30828-1-git-send-email-paulmck@linux.vnet.ibm.com>
Cc: mingo@elte.hu, laijs@cn.fujitsu.com, dipankar@in.ibm.com,
	akpm@linux-foundation.org, mathieu.desnoyers@polymtl.ca,
	josh@joshtriplett.org, niv@us.ibm.com, tglx@linutronix.de,
	peterz@infradead.org, rostedt@goodmis.org, Valdis.Kletnieks@vt.edu,
	dhowells@redhat.com, eric.dumazet@gmail.com, darren@dvhart.com,
	fweisbec@gmail.com, patches@linaro.org,
	"Paul E. McKenney" <paul.mckenney@linaro.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1328319922-30828-1-git-send-email-paulmck@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Paul E. McKenney" <paul.mckenney@linaro.org>

Because opt_kfree_rcu() just calls kfree(), all call_rcu() uses of it
may be converted to kfree_rcu().  This permits opt_kfree_rcu() to
be eliminated.

Signed-off-by: Paul E. McKenney <paul.mckenney@linaro.org>
Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
Acked-by: David S. Miller <davem@davemloft.net>
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Cc: James Morris <jmorris@namei.org>
Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Cc: Patrick McHardy <kaber@trash.net>
Cc: netdev@vger.kernel.org
---
 net/ipv4/cipso_ipv4.c |   11 +++--------
 1 files changed, 3 insertions(+), 8 deletions(-)

diff --git a/net/ipv4/cipso_ipv4.c b/net/ipv4/cipso_ipv4.c
index 86f3b88..c48adc5 100644
--- a/net/ipv4/cipso_ipv4.c
+++ b/net/ipv4/cipso_ipv4.c
@@ -1857,11 +1857,6 @@ static int cipso_v4_genopt(unsigned char *buf, u32 buf_len,
 	return CIPSO_V4_HDR_LEN + ret_val;
 }
 
-static void opt_kfree_rcu(struct rcu_head *head)
-{
-	kfree(container_of(head, struct ip_options_rcu, rcu));
-}
-
 /**
  * cipso_v4_sock_setattr - Add a CIPSO option to a socket
  * @sk: the socket
@@ -1938,7 +1933,7 @@ int cipso_v4_sock_setattr(struct sock *sk,
 	}
 	rcu_assign_pointer(sk_inet->inet_opt, opt);
 	if (old)
-		call_rcu(&old->rcu, opt_kfree_rcu);
+		kfree_rcu(old, rcu);
 
 	return 0;
 
@@ -2005,7 +2000,7 @@ int cipso_v4_req_setattr(struct request_sock *req,
 	req_inet = inet_rsk(req);
 	opt = xchg(&req_inet->opt, opt);
 	if (opt)
-		call_rcu(&opt->rcu, opt_kfree_rcu);
+		kfree_rcu(opt, rcu);
 
 	return 0;
 
@@ -2075,7 +2070,7 @@ static int cipso_v4_delopt(struct ip_options_rcu **opt_ptr)
 		 * remove the entire option struct */
 		*opt_ptr = NULL;
 		hdr_delta = opt->opt.optlen;
-		call_rcu(&opt->rcu, opt_kfree_rcu);
+		kfree_rcu(opt, rcu);
 	}
 
 	return hdr_delta;
-- 
1.7.8
