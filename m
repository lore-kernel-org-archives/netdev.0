From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 07/17] net: convert sock.sk_refcnt from
 atomic_t to refcount_t
Date: Mon, 20 Mar 2017 09:18:55 -0700
Message-ID: <1490026735.16816.58.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1489767196.28631.305.camel@edumazet-glaptop3.roam.corp.google.com>
	<20170318164759.GA23837@gondor.apana.org.au>
	<20170318.182121.439615057765380575.davem@davemloft.net>
	<20170320103937.lq7nfnutupr3gkn7@hirez.programming.kicks-ass.net>
	<20170320131629.GA26405@gondor.apana.org.au>
	<20170320132357.acygo3umw6fiwb4p@hirez.programming.kicks-ass.net>
	<20170320132713.GA26954@gondor.apana.org.au>
	<20170320134017.h3c2jrsnd4guuyu7@hirez.programming.kicks-ass.net>
	<1490021461.16816.52.camel@edumazet-glaptop3.roam.corp.google.com>
	<1490021946.16816.54.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: keescook@chromium.org, kaber@trash.net, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
	jmorris@namei.org, ishkamiel@gmail.com, kuznet@ms2.inr.ac.ru,
	akpm@linux-foundation.org, dwindsor@gmail.com,
	David Miller <davem@davemloft.net>, elena.reshetova@intel.com,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1490021946.16816.54.camel@edumazet-glaptop3.roam.corp.google.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Mon, 2017-03-20 at 07:59 -0700, Eric Dumazet wrote:
> On Mon, 2017-03-20 at 07:51 -0700, Eric Dumazet wrote:
> 
> > atomic_cmpxchg() on PowerPC is horribly more expensive because of the
> > added two SYNC instructions.
> 
> Although I just saw that refcount was using atomic_cmpxchg_relaxed()
> 
> Time to find some documentation (probably missing) or get some specs for
> this thing.

Interesting.

UDP ipv4 xmit path gets a ~25 % improvement on PPC with this patch.

( 20 concurrent netperf -t UDP_STREAM  : 2.45 Mpps -> 3.07 Mpps )

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 8471dd116771462d149e1da2807e446b69b74bcc..9f14aebf0ae1f5f366cfff0fbf58c48603916bc7 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -497,14 +497,14 @@ u32 ip_idents_reserve(u32 hash, int segs)
 	u32 now = (u32)jiffies;
 	u32 new, delta = 0;
 
-	if (old != now && cmpxchg(p_tstamp, old, now) == old)
+	if (old != now && cmpxchg_relaxed(p_tstamp, old, now) == old)
 		delta = prandom_u32_max(now - old);
 
 	/* Do not use atomic_add_return() as it makes UBSAN unhappy */
 	do {
 		old = (u32)atomic_read(p_id);
 		new = old + delta + segs;
-	} while (atomic_cmpxchg(p_id, old, new) != old);
+	} while (atomic_cmpxchg_relaxed(p_id, old, new) != old);
 
 	return new - segs;
 }
