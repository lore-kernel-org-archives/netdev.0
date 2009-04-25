From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH] net: Avoid extra wakeups of threads blocked in wait_for_packet()
Date: Sat, 25 Apr 2009 17:47:23 +0200
Message-ID: <49F3308B.1030507@cosmosbay.com>
References: <alpine.DEB.1.10.0904241554100.29995@qirst.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Christoph Lameter <cl@linux.com>, jesse.brandeburg@intel.com,
	netdev@vger.kernel.org, haoki@redhat.com, mchan@broadcom.com,
	Davide Libenzi <davidel@xmailserver.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:58066 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753075AbZDYPtg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Apr 2009 11:49:36 -0400
In-Reply-To: <alpine.DEB.1.10.0904241554100.29995@qirst.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


In 2.6.25 we added UDP mem accounting.

This unfortunatly added a penalty when a frame is transmitted, since
we have at TX completion time to call sock_wfree() to perform necessary
memory accounting. This calls sock_def_write_space() and utimately
scheduler if any thread is waiting on the socket.
Thread(s) waiting for an incoming frame was scheduled, then had to sleep
again as event was meaningless.

(All threads waiting on a socket are using same sk_sleep anchor)

This adds lot of extra wakeups and increases latencies, as noted
by Christoph Lameter, and slows down softirq handler.

Reference : http://marc.info/?l=linux-netdev&m=124060437012283&w=2 

Fortunatly, Davide Libenzi recently added concept of keyed wakeups
into kernel, and particularly for sockets (see commit
37e5540b3c9d838eb20f2ca8ea2eb8072271e403 
epoll keyed wakeups: make sockets use keyed wakeups)

Davide goal was to optimize epoll, but this new wakeup infrastructure
can help non epoll users as well, if they care to setup an appropriate
handler.

This patch introduces new DEFINE_WAIT_FUNC() helper and uses it
in wait_for_packet(), so that only relevant event can wakeup a thread
blocked in this function.

Trace of function calls from bnx2 TX completion bnx2_poll_work() is :
__kfree_skb()
 skb_release_head_state()
  sock_wfree()
   sock_def_write_space()
    __wake_up_sync_key()
     __wake_up_common()
      receiver_wake_function() : Stops here since thread is waiting for an INPUT


Reported-by: Christoph Lameter <cl@linux.com>
Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
---
 include/linux/wait.h |    6 ++++--
 net/core/datagram.c  |   14 +++++++++++++-
 2 files changed, 17 insertions(+), 3 deletions(-)

diff --git a/include/linux/wait.h b/include/linux/wait.h
index 5d631c1..bc02463 100644
--- a/include/linux/wait.h
+++ b/include/linux/wait.h
@@ -440,13 +440,15 @@ void abort_exclusive_wait(wait_queue_head_t *q, wait_queue_t *wait,
 int autoremove_wake_function(wait_queue_t *wait, unsigned mode, int sync, void *key);
 int wake_bit_function(wait_queue_t *wait, unsigned mode, int sync, void *key);
 
-#define DEFINE_WAIT(name)						\
+#define DEFINE_WAIT_FUNC(name, function)				\
 	wait_queue_t name = {						\
 		.private	= current,				\
-		.func		= autoremove_wake_function,		\
+		.func		= function,				\
 		.task_list	= LIST_HEAD_INIT((name).task_list),	\
 	}
 
+#define DEFINE_WAIT(name) DEFINE_WAIT_FUNC(name, autoremove_wake_function)
+
 #define DEFINE_WAIT_BIT(name, word, bit)				\
 	struct wait_bit_queue name = {					\
 		.key = __WAIT_BIT_KEY_INITIALIZER(word, bit),		\
diff --git a/net/core/datagram.c b/net/core/datagram.c
index d0de644..b7960a3 100644
--- a/net/core/datagram.c
+++ b/net/core/datagram.c
@@ -64,13 +64,25 @@ static inline int connection_based(struct sock *sk)
 	return sk->sk_type == SOCK_SEQPACKET || sk->sk_type == SOCK_STREAM;
 }
 
+static int receiver_wake_function(wait_queue_t *wait, unsigned mode, int sync,
+				  void *key)
+{
+	unsigned long bits = (unsigned long)key;
+
+	/*
+	 * Avoid a wakeup if event not interesting for us
+	 */
+	if (bits && !(bits & (POLLIN | POLLERR)))
+		return 0;
+	return autoremove_wake_function(wait, mode, sync, key);
+}
 /*
  * Wait for a packet..
  */
 static int wait_for_packet(struct sock *sk, int *err, long *timeo_p)
 {
 	int error;
-	DEFINE_WAIT(wait);
+	DEFINE_WAIT_FUNC(wait, receiver_wake_function);
 
 	prepare_to_wait_exclusive(sk->sk_sleep, &wait, TASK_INTERRUPTIBLE);
 
