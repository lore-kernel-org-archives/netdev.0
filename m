From: Mike Galbraith <efault@gmx.de>
Subject: Re: [rfc/rft][patch] should use scheduler sync hint in
 tcp_prequeue()?
Date: Wed, 03 Mar 2010 15:46:50 +0100
Message-ID: <1267627610.6264.21.camel@marge.simson.net>
References: <1267522901.25906.101.camel@marge.simson.net>
	 <1267529273.2964.111.camel@edumazet-laptop>
	 <20100303.060529.195713861.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, mingo@elte.hu
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100303.060529.195713861.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2010-03-03 at 06:05 -0800, David Miller wrote:

> It definitely looks like an oversight to me and we should add
> be using wake_up_interruptible_sync_poll() in tcp_prequeue()
> as above.
> 
> Ingo?

Implied ack from network maintainer implies ship it to me.

net: add scheduler sync hint to tcp_prequeue().

Decreases the odds wakee will suffer from frequent cache misses.

Signed-off-by: Mike Galbraith <efault@gmx.de>
Cc: David Miller <davem@davemloft.net>
LKML-Reference: <new-submission>

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 34f5cc2..ba3fc64 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -939,7 +939,7 @@ static inline int tcp_prequeue(struct sock *sk, struct sk_buff *skb)
 
 		tp->ucopy.memory = 0;
 	} else if (skb_queue_len(&tp->ucopy.prequeue) == 1) {
-		wake_up_interruptible_poll(sk->sk_sleep,
+		wake_up_interruptible_sync_poll(sk->sk_sleep,
 					   POLLIN | POLLRDNORM | POLLRDBAND);
 		if (!inet_csk_ack_scheduled(sk))
 			inet_csk_reset_xmit_timer(sk, ICSK_TIME_DACK,
