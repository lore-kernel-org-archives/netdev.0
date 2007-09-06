From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: [TOMOYO 15/15] LSM expansion for TOMOYO Linux.
Date: Thu, 6 Sep 2007 22:04:01 +0900
Message-ID: <200709062204.DFH97819.JLOHVOOSFMtFQF@I-love.SAKURA.ne.jp>
References: <46CED214.6050505@gmail.com>
	<200709040753.32204.paul.moore@hp.com>
	<200709042302.CDE26023.MJOOLQVFFOtHSF@I-love.SAKURA.ne.jp>
	<200709051006.28429.paul.moore@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org,
	linux-security-module@vger.kernel.org, chrisw@sous-sol.org,
	netdev@vger.kernel.org
To: paul.moore@hp.com
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <200709051006.28429.paul.moore@hp.com>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

Thank you very much for your time, Paul.
Yes, you understood what I wanted to do.

TOMOYO Linux's approach:

(1) It uses userspace intervention to allow/reject
    connections and/or packets based on the application's domain.
    Since existent hooks can't be used for this purpose,
    I inserted a new hook post_recv_datagram() at skb_recv_datagram()
    and I modified socket_post_accept() to return error so that
    I can drop/disconnect based on the application's domain.

    I think skb_recv_datagram() is the only place that can remove
    a message picked up with MSG_PEEK flags from the receive queue.
    To remove a message picked up with MSG_PEEK flags, I noticed that
    I have to do skb_kill_datagram()-like operation so that
    "the head message that must not be delivered to the caller" won't prevent
    picking up of "the non-head message that should be delivered to the caller"
    when the caller repeats only recv(MSG_PEEK) requests.
    Since skb_recv_datagram() can be called from interrupt context,
    I have to use spin_lock_irqsave() instead for spin_lock_bh(), am I right?

/* from net/core/datagram.c */
@@ -178,6 +179,27 @@ struct sk_buff *skb_recv_datagram(struct
 		} else
 			skb = skb_dequeue(&sk->sk_receive_queue);
 
+		error = security_post_recv_datagram(sk, skb, flags);
+		if (error) {
+			unsigned long cpu_flags;
+
+			if (!(flags & MSG_PEEK))
+				goto no_peek;
+
+			spin_lock_irqsave(&sk->sk_receive_queue.lock,
+					  cpu_flags);
+			if (skb == skb_peek(&sk->sk_receive_queue)) {
+				__skb_unlink(skb,
+					     &sk->sk_receive_queue);
+				atomic_dec(&skb->users);
+			}
+			spin_unlock_irqrestore(&sk->sk_receive_queue.lock,
+					       cpu_flags);
+no_peek:
+			skb_free_datagram(sk, skb);
+			goto no_packet;
+		}
+
 		if (skb)
 			return skb;



    By the way, why can't socket_post_accept() fail?
    Someone may wish to do memory allocation at socket_post_accept().
    socket_accept() is too early for memory allocation because
    there is no chance to free allocated memory
    when sock->ops->accept() failed.
    I think socket_post_accept() should be able to fail.

(2) It allows the administrator judge interactively
    using a userspace agent.
    Thus, the new hook has to be inserted at blockable location,
    Since skb_recv_datagram() can be called from interrupt context,
    I do nothing in post_recv_datagram() if called from interrupt context.

+static int tmy_post_recv_datagram(struct sock *sk,
+				  struct sk_buff *skb,
+				  unsigned int flags)
+{
+	int error = 0;
+	const unsigned int type = sk->sk_type;
+
+	/* skb_recv_datagram() didn't dequeue. */
+	if (!skb)
+		return 0;
+
+	/* skb_recv_datagram() can be called from interrupt context. */
+	if (in_interrupt())
+		return 0;
+	/* I don't check if called by kernel process. */
+	if (segment_eq(get_fs(), KERNEL_DS))
+		return 0;
+
+	if (type != SOCK_DGRAM && type != SOCK_RAW)
+		return 0;
...(sniped)...
+}



Regards.
