From: marcelo.leitner@gmail.com
Subject: Re: [PATCH v3 0/2] sctp: delay calls to sk_data_ready() as much as
 possible
Date: Thu, 28 Apr 2016 17:46:59 -0300
Message-ID: <20160428204659.GA2276@localhost.localdomain>
References: <20160413.230532.676746231426161126.davem@davemloft.net>
 <20160414130324.GA6806@hmsreliant.think-freely.org>
 <570FCCC1.6090504@gmail.com>
 <20160414.145916.2286519059284215039.davem@davemloft.net>
 <20160414200351.GA4632@hmsreliant.think-freely.org>
 <20160414201900.GK15005@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	vyasevich@gmail.com, linux-sctp@vger.kernel.org,
	David.Laight@ACULAB.COM, jkbs@redhat.com
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58775 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753718AbcD1UrD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Apr 2016 16:47:03 -0400
Content-Disposition: inline
In-Reply-To: <20160414201900.GK15005@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 14, 2016 at 05:19:00PM -0300, marcelo.leitner@gmail.com wrote:
> On Thu, Apr 14, 2016 at 04:03:51PM -0400, Neil Horman wrote:
> > On Thu, Apr 14, 2016 at 02:59:16PM -0400, David Miller wrote:
> > > From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
> > > Date: Thu, 14 Apr 2016 14:00:49 -0300
> > > 
> > > > Em 14-04-2016 10:03, Neil Horman escreveu:
> > > >> On Wed, Apr 13, 2016 at 11:05:32PM -0400, David Miller wrote:
> > > >>> From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
> > > >>> Date: Fri,  8 Apr 2016 16:41:26 -0300
> > > >>>
> > > >>>> 1st patch is a preparation for the 2nd. The idea is to not call
> > > >>>> ->sk_data_ready() for every data chunk processed while processing
> > > >>>> packets but only once before releasing the socket.
> > > >>>>
> > > >>>> v2: patchset re-checked, small changelog fixes
> > > >>>> v3: on patch 2, make use of local vars to make it more readable
> > > >>>
> > > >>> Applied to net-next, but isn't this reduced overhead coming at the
> > > >>> expense of latency?  What if that lower latency is important to the
> > > >>> application and/or consumer?
> > > >> Thats a fair point, but I'd make the counter argument that, as it
> > > >> currently
> > > >> stands, any latency introduced (or removed), is an artifact of our
> > > >> implementation rather than a designed feature of it.  That is to say,
> > > >> we make no
> > > >> guarantees at the application level regarding how long it takes to
> > > >> signal data
> > > >> readines from the time we get data off the wire, so I would rather see
> > > >> our
> > > >> throughput raised if we can, as thats been sctp's more pressing
> > > >> achilles heel.
> > > >>
> > > >>
> > > >> Thats not to say I'd like to enable lower latency, but I'd rather have
> > > >> this now,
> > > >> and start pondering how to design that in.  Perhaps we can convert the
> > > >> pending
> > > >> flag to a counter to count the number of events we enqueue, and call
> > > >> sk_data_ready every  time we reach a sysctl defined threshold.
> > > > 
> > > > That and also that there is no chance of the application reading the
> > > > first chunks before all current ToDo's are performed by either the bh
> > > > or backlog handlers for that packet. Socket lock won't be cycled in
> > > > between chunks so the application is going to wait all the processing
> > > > one way or another.
> > > 
> > > But it takes time to signal the wakeup to the remote cpu the process
> > > was running on, schedule out the current process on that cpu (if it
> > > has in fact lost it's timeslice), and then finally look at the socket
> > > queue.
> > > 
> > > Of course this is all assuming the process was sleeping in the first
> > > place, either in recv or more likely poll.
> > > 
> > > I really think signalling early helps performance.
> > > 
> > 
> > Early, yes, often, not so much :).  Perhaps what would be adventageous would be
> > to signal at the start of a set of enqueues, rather than at the end.  That would
> > be equivalent in terms of not signaling more than needed, but would eliminate
> > the signaling on every chunk.   Perhaps what you could do Marcelo would be to
> > change the sense of the signal_ready flag to be a has_signaled flag.  e.g. call
> > sk_data_ready in ulp_event_tail like we used to, but only if the has_signaled
> > flag isn't set, then set the flag, and clear it at the end of the command
> > interpreter.
> > 
> > That would be a best of both worlds solution, as long as theres no chance of
> > race with user space reading from the socket before we were done enqueuing (i.e.
> > you have to guarantee that the socket lock stays held, which I think we do).
> 
> That is my feeling too. Will work on it. Thanks :-)

I did the change and tested it on real machines set all for performance.
I couldn't spot any difference between both implementations.

Set RSS and queue irq affinity for a cpu and taskset netperf and another
app I wrote to run on another cpu. It hits socket backlog quite often
but still do direct processing every now and then.

With current state, netperf, scenario above. Results of perf sched
record for the CPUs in use, reported by perf sched latency:

  Task                  |   Runtime ms  | Switches | Average delay ms |
  Maximum delay ms | Maximum delay at       |
  netserver:3205        |   9999.490 ms |       10 | avg:    0.003 ms |
  max:    0.004 ms | max at:  69087.753356 s

another run
  netserver:3483        |   9999.412 ms |       15 | avg:    0.003 ms |
  max:    0.004 ms | max at:  69194.749814 s

With the patch below, same test:
  netserver:2643        |  10000.110 ms |       14 | avg:    0.003 ms |
  max:    0.004 ms | max at:    172.006315 s

another run:
  netserver:2698        |  10000.049 ms |       15 | avg:    0.003 ms |
  max:    0.004 ms | max at:    368.061672 s

I'll be happy to do more tests if you have any suggestions on how/what
to test.

---8<---
 
 include/net/sctp/structs.h |  2 +-
 net/sctp/sm_sideeffect.c   |  7 +++----
 net/sctp/ulpqueue.c        | 25 ++++++++++++++++---------
 3 files changed, 20 insertions(+), 14 deletions(-)

diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index 558bae3cbe0d5107d52c8cb31b324cfd5479def0..16b013a6191cf1c416e4dd1aeb1707a8569ea49b 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -218,7 +218,7 @@ struct sctp_sock {
 		frag_interleave:1,
 		recvrcvinfo:1,
 		recvnxtinfo:1,
-		pending_data_ready:1;
+		data_ready_signalled:1;
 
 	atomic_t pd_mode;
 	/* Receive to here while partial delivery is in effect. */
diff --git a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
index e8f0112f9b28472c39c4c91dcb28576373c858e7..aa37122593684d8501fdca15983fbd8620fabe07 100644
--- a/net/sctp/sm_sideeffect.c
+++ b/net/sctp/sm_sideeffect.c
@@ -1741,10 +1741,9 @@ out:
 	} else if (local_cork)
 		error = sctp_outq_uncork(&asoc->outqueue, gfp);
 
-	if (sp->pending_data_ready) {
-		sk->sk_data_ready(sk);
-		sp->pending_data_ready = 0;
-	}
+	if (sp->data_ready_signalled)
+		sp->data_ready_signalled = 0;
+
 	return error;
 nomem:
 	error = -ENOMEM;
diff --git a/net/sctp/ulpqueue.c b/net/sctp/ulpqueue.c
index ec12a8920e5fd7a0f26d19f1695bc2feeae41518..ec166d2bd2d95d9aa69369da2ead9437da4ce8ed 100644
--- a/net/sctp/ulpqueue.c
+++ b/net/sctp/ulpqueue.c
@@ -194,6 +194,7 @@ static int sctp_ulpq_clear_pd(struct sctp_ulpq *ulpq)
 int sctp_ulpq_tail_event(struct sctp_ulpq *ulpq, struct sctp_ulpevent *event)
 {
 	struct sock *sk = ulpq->asoc->base.sk;
+	struct sctp_sock *sp = sctp_sk(sk);
 	struct sk_buff_head *queue, *skb_list;
 	struct sk_buff *skb = sctp_event2skb(event);
 	int clear_pd = 0;
@@ -211,7 +212,7 @@ int sctp_ulpq_tail_event(struct sctp_ulpq *ulpq, struct sctp_ulpevent *event)
 		sk_incoming_cpu_update(sk);
 	}
 	/* Check if the user wishes to receive this event.  */
-	if (!sctp_ulpevent_is_enabled(event, &sctp_sk(sk)->subscribe))
+	if (!sctp_ulpevent_is_enabled(event, &sp->subscribe))
 		goto out_free;
 
 	/* If we are in partial delivery mode, post to the lobby until
@@ -219,7 +220,7 @@ int sctp_ulpq_tail_event(struct sctp_ulpq *ulpq, struct sctp_ulpevent *event)
 	 * the association the cause of the partial delivery.
 	 */
 
-	if (atomic_read(&sctp_sk(sk)->pd_mode) == 0) {
+	if (atomic_read(&sp->pd_mode) == 0) {
 		queue = &sk->sk_receive_queue;
 	} else {
 		if (ulpq->pd_mode) {
@@ -231,7 +232,7 @@ int sctp_ulpq_tail_event(struct sctp_ulpq *ulpq, struct sctp_ulpevent *event)
 			if ((event->msg_flags & MSG_NOTIFICATION) ||
 			    (SCTP_DATA_NOT_FRAG ==
 				    (event->msg_flags & SCTP_DATA_FRAG_MASK)))
-				queue = &sctp_sk(sk)->pd_lobby;
+				queue = &sp->pd_lobby;
 			else {
 				clear_pd = event->msg_flags & MSG_EOR;
 				queue = &sk->sk_receive_queue;
@@ -242,10 +243,10 @@ int sctp_ulpq_tail_event(struct sctp_ulpq *ulpq, struct sctp_ulpevent *event)
 			 * can queue this to the receive queue instead
 			 * of the lobby.
 			 */
-			if (sctp_sk(sk)->frag_interleave)
+			if (sp->frag_interleave)
 				queue = &sk->sk_receive_queue;
 			else
-				queue = &sctp_sk(sk)->pd_lobby;
+				queue = &sp->pd_lobby;
 		}
 	}
 
@@ -264,8 +265,10 @@ int sctp_ulpq_tail_event(struct sctp_ulpq *ulpq, struct sctp_ulpevent *event)
 	if (clear_pd)
 		sctp_ulpq_clear_pd(ulpq);
 
-	if (queue == &sk->sk_receive_queue)
-		sctp_sk(sk)->pending_data_ready = 1;
+	if (queue == &sk->sk_receive_queue && !sp->data_ready_signalled) {
+		sp->data_ready_signalled = 1;
+		sk->sk_data_ready(sk);
+	}
 	return 1;
 
 out_free:
@@ -1126,11 +1129,13 @@ void sctp_ulpq_abort_pd(struct sctp_ulpq *ulpq, gfp_t gfp)
 {
 	struct sctp_ulpevent *ev = NULL;
 	struct sock *sk;
+	struct sctp_sock *sp;
 
 	if (!ulpq->pd_mode)
 		return;
 
 	sk = ulpq->asoc->base.sk;
+	sp = sctp_sk(sk);
 	if (sctp_ulpevent_type_enabled(SCTP_PARTIAL_DELIVERY_EVENT,
 				       &sctp_sk(sk)->subscribe))
 		ev = sctp_ulpevent_make_pdapi(ulpq->asoc,
@@ -1140,6 +1145,8 @@ void sctp_ulpq_abort_pd(struct sctp_ulpq *ulpq, gfp_t gfp)
 		__skb_queue_tail(&sk->sk_receive_queue, sctp_event2skb(ev));
 
 	/* If there is data waiting, send it up the socket now. */
-	if (sctp_ulpq_clear_pd(ulpq) || ev)
-		sctp_sk(sk)->pending_data_ready = 1;
+	if ((sctp_ulpq_clear_pd(ulpq) || ev) && !sp->data_ready_signalled) {
+		sp->data_ready_signalled = 1;
+		sk->sk_data_ready(sk);
+	}
 }
-- 
2.5.0
