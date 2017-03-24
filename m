From: Alexander Duyck <alexander.duyck-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [net-next PATCH v3 4/8] net: Change return type of sk_busy_loop
 from bool to void
Date: Fri, 24 Mar 2017 10:08:12 -0700
Message-ID: <20170324170812.15226.97497.stgit@localhost.localdomain>
References: <20170324164902.15226.48358.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: sridhar.samudrala-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org,
        davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170324164902.15226.48358.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Alexander Duyck <alexander.h.duyck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>

>From what I can tell there is only a couple spots where we are actually
checking the return value of sk_busy_loop. As there are only a few
consumers of that data, and the data being checked for can be replaced
with a check for !skb_queue_empty() we might as well just pull the code
out of sk_busy_loop and place it in the spots that actually need it.

Signed-off-by: Alexander Duyck <alexander.h.duyck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Acked-by: Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
---
 include/net/busy_poll.h |    5 ++---
 net/core/datagram.c     |    8 ++++++--
 net/core/dev.c          |   25 +++++++++++--------------
 net/sctp/socket.c       |    9 ++++++---
 4 files changed, 25 insertions(+), 22 deletions(-)

diff --git a/include/net/busy_poll.h b/include/net/busy_poll.h
index b82d6ba70a14..c55760f4820f 100644
--- a/include/net/busy_poll.h
+++ b/include/net/busy_poll.h
@@ -74,7 +74,7 @@ static inline bool busy_loop_timeout(unsigned long end_time)
 	return time_after(now, end_time);
 }
 
-bool sk_busy_loop(struct sock *sk, int nonblock);
+void sk_busy_loop(struct sock *sk, int nonblock);
 
 #else /* CONFIG_NET_RX_BUSY_POLL */
 static inline unsigned long net_busy_loop_on(void)
@@ -97,9 +97,8 @@ static inline bool busy_loop_timeout(unsigned long end_time)
 	return true;
 }
 
-static inline bool sk_busy_loop(struct sock *sk, int nonblock)
+static inline void sk_busy_loop(struct sock *sk, int nonblock)
 {
-	return false;
 }
 
 #endif /* CONFIG_NET_RX_BUSY_POLL */
diff --git a/net/core/datagram.c b/net/core/datagram.c
index ea633342ab0d..4608aa245410 100644
--- a/net/core/datagram.c
+++ b/net/core/datagram.c
@@ -256,8 +256,12 @@ struct sk_buff *__skb_try_recv_datagram(struct sock *sk, unsigned int flags,
 		}
 
 		spin_unlock_irqrestore(&queue->lock, cpu_flags);
-	} while (sk_can_busy_loop(sk) &&
-		 sk_busy_loop(sk, flags & MSG_DONTWAIT));
+
+		if (!sk_can_busy_loop(sk))
+			break;
+
+		sk_busy_loop(sk, flags & MSG_DONTWAIT);
+	} while (!skb_queue_empty(&sk->sk_receive_queue));
 
 	error = -EAGAIN;
 
diff --git a/net/core/dev.c b/net/core/dev.c
index ab337bf5bbf4..af70eb6ba682 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5060,21 +5060,19 @@ static void busy_poll_stop(struct napi_struct *napi, void *have_poll_lock)
 		do_softirq();
 }
 
-bool sk_busy_loop(struct sock *sk, int nonblock)
+void sk_busy_loop(struct sock *sk, int nonblock)
 {
 	unsigned long end_time = !nonblock ? sk_busy_loop_end_time(sk) : 0;
 	int (*napi_poll)(struct napi_struct *napi, int budget);
 	void *have_poll_lock = NULL;
 	struct napi_struct *napi;
 	unsigned int napi_id;
-	int rc;
 
 restart:
 	napi_id = READ_ONCE(sk->sk_napi_id);
 	if (napi_id < MIN_NAPI_ID)
-		return 0;
+		return;
 
-	rc = false;
 	napi_poll = NULL;
 
 	rcu_read_lock();
@@ -5085,7 +5083,8 @@ bool sk_busy_loop(struct sock *sk, int nonblock)
 
 	preempt_disable();
 	for (;;) {
-		rc = 0;
+		int work = 0;
+
 		local_bh_disable();
 		if (!napi_poll) {
 			unsigned long val = READ_ONCE(napi->state);
@@ -5103,12 +5102,12 @@ bool sk_busy_loop(struct sock *sk, int nonblock)
 			have_poll_lock = netpoll_poll_lock(napi);
 			napi_poll = napi->poll;
 		}
-		rc = napi_poll(napi, BUSY_POLL_BUDGET);
-		trace_napi_poll(napi, rc, BUSY_POLL_BUDGET);
+		work = napi_poll(napi, BUSY_POLL_BUDGET);
+		trace_napi_poll(napi, work, BUSY_POLL_BUDGET);
 count:
-		if (rc > 0)
+		if (work > 0)
 			__NET_ADD_STATS(sock_net(sk),
-					LINUX_MIB_BUSYPOLLRXPACKETS, rc);
+					LINUX_MIB_BUSYPOLLRXPACKETS, work);
 		local_bh_enable();
 
 		if (nonblock || !skb_queue_empty(&sk->sk_receive_queue) ||
@@ -5121,9 +5120,9 @@ bool sk_busy_loop(struct sock *sk, int nonblock)
 			preempt_enable();
 			rcu_read_unlock();
 			cond_resched();
-			rc = !skb_queue_empty(&sk->sk_receive_queue);
-			if (rc || busy_loop_timeout(end_time))
-				return rc;
+			if (!skb_queue_empty(&sk->sk_receive_queue) ||
+			    busy_loop_timeout(end_time))
+				return;
 			goto restart;
 		}
 		cpu_relax();
@@ -5131,10 +5130,8 @@ bool sk_busy_loop(struct sock *sk, int nonblock)
 	if (napi_poll)
 		busy_poll_stop(napi, have_poll_lock);
 	preempt_enable();
-	rc = !skb_queue_empty(&sk->sk_receive_queue);
 out:
 	rcu_read_unlock();
-	return rc;
 }
 EXPORT_SYMBOL(sk_busy_loop);
 
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 72cc3ecf6516..ccc08fc39722 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -7518,9 +7518,12 @@ struct sk_buff *sctp_skb_recv_datagram(struct sock *sk, int flags,
 		if (sk->sk_shutdown & RCV_SHUTDOWN)
 			break;
 
-		if (sk_can_busy_loop(sk) &&
-		    sk_busy_loop(sk, noblock))
-			continue;
+		if (sk_can_busy_loop(sk)) {
+			sk_busy_loop(sk, noblock);
+
+			if (!skb_queue_empty(&sk->sk_receive_queue))
+				continue;
+		}
 
 		/* User doesn't want to wait.  */
 		error = -EAGAIN;
