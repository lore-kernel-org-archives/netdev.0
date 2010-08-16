From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [LOCKDEP BUG][2.6.36-rc1] xt_info_wrlock?
Date: Mon, 16 Aug 2010 22:04:56 +0200
Message-ID: <1281989096.1926.1952.camel@laptop>
References: <1281978469.3268.55.camel@gandalf.stny.rr.com>
	 <1281979893.2524.54.camel@edumazet-laptop>
	 <1281981301.3268.110.camel@gandalf.stny.rr.com>
	 <20100816.124400.42792595.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: rostedt@goodmis.org, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kaber@trash.net, mingo@elte.hu
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100816.124400.42792595.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2010-08-16 at 12:44 -0700, David Miller wrote:
> He's only accessing the per-cpu counter locks of other cpus.
> 
> The per-cpu lock is only locally accessed by a cpu in software
> interrupt context.
> 
> That is why his transformation is legal.
> 
> Lockdep simply hasn't been informed of this invariant and has
> to assume the worst. 

Something like the below will keep lockdep coverage, still going back to
RCU sounds like the best option.

---
 include/linux/netfilter/x_tables.h |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/include/linux/netfilter/x_tables.h b/include/linux/netfilter/x_tables.h
index 24e5d01..a195feb 100644
--- a/include/linux/netfilter/x_tables.h
+++ b/include/linux/netfilter/x_tables.h
@@ -511,12 +511,21 @@ static inline void xt_info_rdunlock_bh(void)
  */
 static inline void xt_info_wrlock(unsigned int cpu)
 {
+#ifdef CONFIG_PROVE_LOCKING
+	/*
+	 * XXX foo
+	 */
+	local_bh_disable();
+#endif
 	spin_lock(&per_cpu(xt_info_locks, cpu).lock);
 }
 
 static inline void xt_info_wrunlock(unsigned int cpu)
 {
 	spin_unlock(&per_cpu(xt_info_locks, cpu).lock);
+#ifdef CONFIG_PROVE_LOCKING
+	local_bh_enable();
+#endif
 }
 
 /*
