From: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>
Subject: Re: [PATCH 09/16] netvm: Allow skb allocation to use PFMEMALLOC
 reserves
Date: Tue, 26 Jun 2012 17:27:34 +0200
Message-ID: <20120626152734.GA6509@breakpoint.cc>
References: <1340375443-22455-1-git-send-email-mgorman@suse.de>
 <1340375443-22455-10-git-send-email-mgorman@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Linux-MM <linux-mm@kvack.org>,
	Linux-Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>, Neil Brown <neilb@suse.de>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Mike Christie <michaelc@cs.wisc.edu>,
	Eric B Munson <emunson@mgebm.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Mel Gorman <mgorman@suse.de>
Return-path: <owner-linux-mm@kvack.org>
Content-Disposition: inline
In-Reply-To: <1340375443-22455-10-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 22, 2012 at 03:30:36PM +0100, Mel Gorman wrote:
> diff --git a/net/core/sock.c b/net/core/sock.c
> index 5c9ca2b..159dccc 100644
> --- a/net/core/sock.c
> +++ b/net/core/sock.c
> @@ -271,6 +271,9 @@ __u32 sysctl_rmem_default __read_mostly = SK_RMEM_MAX;
>  int sysctl_optmem_max __read_mostly = sizeof(unsigned long)*(2*UIO_MAXIOV+512);
>  EXPORT_SYMBOL(sysctl_optmem_max);
>  
> +struct static_key memalloc_socks = STATIC_KEY_INIT_FALSE;
> +EXPORT_SYMBOL_GPL(memalloc_socks);
> +

This is used via sk_memalloc_socks() by SLAB.

>From 3da9ab9972845974da114c5a6624335e6371b2d5 Mon Sep 17 00:00:00 2001
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Date: Tue, 26 Jun 2012 17:18:20 +0200
Subject: [PATCH] export sk_memalloc_socks() only with CONFIG_NET

|mm/built-in.o: In function `atomic_read':
|include/asm/atomic.h:25: undefined reference to `memalloc_socks'
|include/asm/atomic.h:25: undefined reference to `memalloc_socks'
|include/asm/atomic.h:25: undefined reference to `memalloc_socks'
|include/asm/atomic.h:25: undefined reference to `memalloc_socks'
|include/asm/atomic.h:25: undefined reference to `memalloc_socks'
|mm/built-in.o:include/asm/atomic.h:25: more undefined references to `memalloc_socks' follow

Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---
 include/net/sock.h |    9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/include/net/sock.h b/include/net/sock.h
index db0c20c..767c443 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -659,11 +659,20 @@ static inline bool sock_flag(const struct sock *sk, enum sock_flags flag)
 	return test_bit(flag, &sk->sk_flags);
 }
 
+#ifdef CONFIG_NET
 extern struct static_key memalloc_socks;
 static inline int sk_memalloc_socks(void)
 {
 	return static_key_false(&memalloc_socks);
 }
+#else
+
+static inline int sk_memalloc_socks(void)
+{
+	return 0;
+}
+
+#endif
 
 static inline gfp_t sk_gfp_atomic(struct sock *sk, gfp_t gfp_mask)
 {
-- 
1.7.10

Sebastian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
