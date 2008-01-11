From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] [UDP]: add udp_mem, udp_rmem_min and udp_wmem_min
Date: Thu, 10 Jan 2008 22:00:15 -0800 (PST)
Message-ID: <20080110.220015.118987509.davem@davemloft.net>
References: <4778AE48.1040701@cosmosbay.com>
	<20071231.041342.101160102.davem@davemloft.net>
	<4778FFE2.9090008@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: haoki@redhat.com, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org, tyasui@redhat.com, mhiramat@redhat.com,
	satoshi.oshima.fk@hitachi.com, billfink@mindspring.com,
	andi@firstfloor.org, johnpol@2ka.mipt.ru,
	shemminger@linux-foundation.org, yoshfuji@linux-ipv6.org,
	yumiko.sugita.yf@hitachi.com
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47620
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750760AbYAKGAQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jan 2008 01:00:16 -0500
In-Reply-To: <4778FFE2.9090008@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Mon, 31 Dec 2007 15:42:42 +0100

> Maybe we need to introduce some mechanism to let sk_forward between 0 and 
> SK_MEM_QUANTUM (inclusive).
> 
> static inline void sk_mem_reclaim_overpage(struct sock *sk)
> {
>          if (sk->sk_forward_alloc > SK_MEM_QUANTUM) {
>                  __sk_mem_reclaim(sk);
> 		}
> }
> 
> and use sk_mem_reclaim_overpage() instead of sk_mem_reclaim() in 
> tcp_delack_timer() ?

This makes a lot of sense to me, it is definitely doing the wrong
thing here for the load you describe.

I've applied the following to net-2.6.25 and I am definitely
willing to put this into 2.6.24 and -stable if you think that's
worthwhile too.

[TCP]: Do not purge sk_forward_alloc entirely in tcp_delack_timer().

Otherwise we beat heavily on the global tcp_memory atomics
when all of the sockets in the system are slowly sending
perioding packet clumps.

Noticed and suggested by Eric Dumazet.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/sock.h   |    8 ++++++++
 net/ipv4/tcp_timer.c |    2 +-
 2 files changed, 9 insertions(+), 1 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 89e04e4..d24b826 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -759,6 +759,14 @@ static inline void sk_mem_reclaim(struct sock *sk)
 		__sk_mem_reclaim(sk);
 }
 
+static inline void sk_mem_reclaim_partial(struct sock *sk)
+{
+	if (!sk_has_account(sk))
+		return;
+	if (sk->sk_forward_alloc > SK_MEM_QUANTUM)
+		__sk_mem_reclaim(sk);
+}
+
 static inline void sk_mem_charge(struct sock *sk, int size)
 {
 	if (!sk_has_account(sk))
diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index 17931be..803d758 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -186,7 +186,7 @@ static void tcp_delack_timer(unsigned long data)
 		goto out_unlock;
 	}
 
-	sk_mem_reclaim(sk);
+	sk_mem_reclaim_partial(sk);
 
 	if (sk->sk_state == TCP_CLOSE || !(icsk->icsk_ack.pending & ICSK_ACK_TIMER))
 		goto out;
-- 
1.5.4.rc2.84.gf85fd

