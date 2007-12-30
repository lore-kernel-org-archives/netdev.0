From: Hideo AOKI <haoki@redhat.com>
Subject: [PATCH 4/4] [SCTP]: using new interface
Date: Sun, 30 Dec 2007 03:54:26 -0500
Message-ID: <47775CC2.3040501@redhat.com>
References: <47775B25.7020401@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Takahiro Yasui <tyasui@redhat.com>,
	Masami Hiramatsu <mhiramat@redhat.com>,
	Satoshi Oshima <satoshi.oshima.fk@hitachi.com>,
	billfink@mindspring.com, Andi Kleen <andi@firstfloor.org>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	yoshfuji@linux-ipv6.org,
	Yumiko Sugita <yumiko.sugita.yf@hitachi.com>, haoki@redhat.com
To: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	vladislav.yasevich@hp.com, netdev <netdev@vger.kernel.org>,
	lksctp-developers@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:34982 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752988AbXL3I7p (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 30 Dec 2007 03:59:45 -0500
In-Reply-To: <47775B25.7020401@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch replaces present memory accounting calls with new interface
in SCTP.

Cc: Satoshi Oshima <satoshi.oshima.fk@hitachi.com>
Cc: Masami Hiramatsu <mhiramat@redhat.com>
signed-off-by: Takahiro Yasui <tyasui@redhat.com>
signed-off-by: Hideo Aoki <haoki@redhat.com>
---

 include/net/sctp/sctp.h |    3 +--
 net/sctp/protocol.c     |    2 +-
 net/sctp/sm_statefuns.c |    2 +-
 net/sctp/socket.c       |   11 ++++++-----
 net/sctp/ulpevent.c     |    2 +-
 net/sctp/ulpqueue.c     |    2 +-
 6 files changed, 11 insertions(+), 11 deletions(-)

diff -pruN net-2.6.25-t12t19m-p3/include/net/sctp/sctp.h net-2.6.25-t12t19m-p4/include/net/sctp/sctp.h
--- net-2.6.25-t12t19m-p3/include/net/sctp/sctp.h	2007-12-27 10:18:58.000000000 -0500
+++ net-2.6.25-t12t19m-p4/include/net/sctp/sctp.h	2007-12-29 20:59:06.000000000 -0500
@@ -463,8 +463,7 @@ static inline void sctp_skb_set_owner_r(
 	skb->destructor = sctp_sock_rfree;
 	atomic_add(event->rmem_len, &sk->sk_rmem_alloc);
 	/*
-	 * This mimics the behavior of
-	 * sk_stream_set_owner_r
+	 * This mimics the behavior of skb_set_owner_r
 	 */
 	sk->sk_forward_alloc -= event->rmem_len;
 }
diff -pruN net-2.6.25-t12t19m-p3/net/sctp/protocol.c net-2.6.25-t12t19m-p4/net/sctp/protocol.c
--- net-2.6.25-t12t19m-p3/net/sctp/protocol.c	2007-12-27 10:19:02.000000000 -0500
+++ net-2.6.25-t12t19m-p4/net/sctp/protocol.c	2007-12-29 20:59:06.000000000 -0500
@@ -1109,7 +1109,7 @@ SCTP_STATIC __init int sctp_init(void)
 	sysctl_sctp_rmem[1] = (1500 *(sizeof(struct sk_buff) + 1));
 	sysctl_sctp_rmem[2] = max(sysctl_sctp_rmem[1], max_share);

-	sysctl_sctp_wmem[0] = SK_STREAM_MEM_QUANTUM;
+	sysctl_sctp_wmem[0] = SK_MEM_QUANTUM;
 	sysctl_sctp_wmem[1] = 16*1024;
 	sysctl_sctp_wmem[2] = max(64*1024, max_share);

diff -pruN net-2.6.25-t12t19m-p3/net/sctp/sm_statefuns.c net-2.6.25-t12t19m-p4/net/sctp/sm_statefuns.c
--- net-2.6.25-t12t19m-p3/net/sctp/sm_statefuns.c	2007-12-27 10:19:02.000000000 -0500
+++ net-2.6.25-t12t19m-p4/net/sctp/sm_statefuns.c	2007-12-29 20:59:06.000000000 -0500
@@ -5866,7 +5866,7 @@ static int sctp_eat_data(const struct sc
 	/*
 	 * Also try to renege to limit our memory usage in the event that
 	 * we are under memory pressure
-	 * If we can't renege, don't worry about it, the sk_stream_rmem_schedule
+	 * If we can't renege, don't worry about it, the sk_rmem_schedule
 	 * in sctp_ulpevent_make_rcvmsg will drop the frame if we grow our
 	 * memory usage too much
 	 */
diff -pruN net-2.6.25-t12t19m-p3/net/sctp/socket.c net-2.6.25-t12t19m-p4/net/sctp/socket.c
--- net-2.6.25-t12t19m-p3/net/sctp/socket.c	2007-12-27 10:19:02.000000000 -0500
+++ net-2.6.25-t12t19m-p4/net/sctp/socket.c	2007-12-29 20:59:06.000000000 -0500
@@ -174,7 +174,8 @@ static inline void sctp_set_owner_w(stru
 				sizeof(struct sctp_chunk);

 	atomic_add(sizeof(struct sctp_chunk), &sk->sk_wmem_alloc);
-	sk_charge_skb(sk, chunk->skb);
+	sk->sk_wmem_queued += chunk->skb->truesize;
+	sk_mem_charge(sk, chunk->skb->truesize);
 }

 /* Verify that this is a valid address. */
@@ -6035,10 +6036,10 @@ static void sctp_wfree(struct sk_buff *s
 	atomic_sub(sizeof(struct sctp_chunk), &sk->sk_wmem_alloc);

 	/*
-	 * This undoes what is done via sk_charge_skb
+	 * This undoes what is done via sctp_set_owner_w and sk_mem_charge
 	 */
 	sk->sk_wmem_queued   -= skb->truesize;
-	sk->sk_forward_alloc += skb->truesize;
+	sk_mem_uncharge(sk, skb->truesize);

 	sock_wfree(skb);
 	__sctp_write_space(asoc);
@@ -6059,9 +6060,9 @@ void sctp_sock_rfree(struct sk_buff *skb
 	atomic_sub(event->rmem_len, &sk->sk_rmem_alloc);

 	/*
-	 * Mimic the behavior of sk_stream_rfree
+	 * Mimic the behavior of sock_rfree
 	 */
-	sk->sk_forward_alloc += event->rmem_len;
+	sk_mem_uncharge(sk, event->rmem_len);
 }


diff -pruN net-2.6.25-t12t19m-p3/net/sctp/ulpevent.c net-2.6.25-t12t19m-p4/net/sctp/ulpevent.c
--- net-2.6.25-t12t19m-p3/net/sctp/ulpevent.c	2007-12-27 10:19:02.000000000 -0500
+++ net-2.6.25-t12t19m-p4/net/sctp/ulpevent.c	2007-12-29 20:59:06.000000000 -0500
@@ -700,7 +700,7 @@ struct sctp_ulpevent *sctp_ulpevent_make
 	if (rx_count >= asoc->base.sk->sk_rcvbuf) {

 		if ((asoc->base.sk->sk_userlocks & SOCK_RCVBUF_LOCK) ||
-		   (!sk_stream_rmem_schedule(asoc->base.sk, chunk->skb)))
+		    (!sk_rmem_schedule(asoc->base.sk, chunk->skb->truesize)))
 			goto fail;
 	}

diff -pruN net-2.6.25-t12t19m-p3/net/sctp/ulpqueue.c net-2.6.25-t12t19m-p4/net/sctp/ulpqueue.c
--- net-2.6.25-t12t19m-p3/net/sctp/ulpqueue.c	2007-12-27 10:19:02.000000000 -0500
+++ net-2.6.25-t12t19m-p4/net/sctp/ulpqueue.c	2007-12-29 20:59:06.000000000 -0500
@@ -1046,7 +1046,7 @@ void sctp_ulpq_renege(struct sctp_ulpq *
 		sctp_ulpq_partial_delivery(ulpq, chunk, gfp);
 	}

-	sk_stream_mem_reclaim(asoc->base.sk);
+	sk_mem_reclaim(asoc->base.sk);
 	return;
 }

-- 
Hitachi Computer Products (America) Inc.
