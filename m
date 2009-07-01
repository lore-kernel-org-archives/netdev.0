From: Jiri Olsa <jolsa@redhat.com>
Subject: Re: [PATCHv3 1/2] net: adding memory barrier to the poll and
	receive callbacks
Date: Wed, 1 Jul 2009 10:09:47 +0200
Message-ID: <20090701080946.GB4769@jolsa.lab.eng.brq.redhat.com>
References: <20090630125240.GB4406@jolsa.lab.eng.brq.redhat.com> <20090630125425.GC4406@jolsa.lab.eng.brq.redhat.com> <alpine.DEB.1.10.0906301210210.3968@makko.or.mcafeemobile.com> <20090701065724.GA2852@jolsa.lab.eng.brq.redhat.com> <alpine.DEB.1.10.0907010002010.8492@makko.or.mcafeemobile.com> <20090701073001.GA4769@jolsa.lab.eng.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	fbl@redhat.com, nhorman@redhat.com, davem@redhat.com,
	htejun@gmail.com, jarkao2@gmail.com, oleg@redhat.com,
	eric.dumazet@gmail.com
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:53069 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753826AbZGAIJv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Jul 2009 04:09:51 -0400
Content-Disposition: inline
In-Reply-To: <20090701073001.GA4769@jolsa.lab.eng.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 01, 2009 at 09:30:01AM +0200, Jiri Olsa wrote:
> On Wed, Jul 01, 2009 at 12:04:56AM -0700, Davide Libenzi wrote:
> > On Wed, 1 Jul 2009, Jiri Olsa wrote:
> > 
> > > On Tue, Jun 30, 2009 at 12:13:40PM -0700, Davide Libenzi wrote:
> > > > On Tue, 30 Jun 2009, Jiri Olsa wrote:
> > > > 
> > > > > Adding memory barrier after the poll_wait function, paired with
> > > > > receive callbacks. Adding fuctions sock_poll_wait and sock_has_sleeper
> > > > > to wrap the memory barrier.
> > > > > 
> > > > > Without the memory barrier, following race can happen.
> > > > > The race fires, when following code paths meet, and the tp->rcv_nxt 
> > > > > and __add_wait_queue updates stay in CPU caches.
> > > > > 
> > > > > 
> > > > > CPU1                         CPU2
> > > > > 
> > > > > sys_select                   receive packet
> > > > >   ...                        ...
> > > > >   __add_wait_queue           update tp->rcv_nxt
> > > > >   ...                        ...
> > > > >   tp->rcv_nxt check          sock_def_readable
> > > > >   ...                        {
> > > > >   schedule                      ...
> > > > >                                 if (sk->sk_sleep && waitqueue_active(sk->sk_sleep))
> > > > >                                         wake_up_interruptible(sk->sk_sleep)
> > > > >                                 ...
> > > > >                              }
> > > > > 
> > > > > If there was no cache the code would work ok, since the wait_queue and
> > > > > rcv_nxt are opposit to each other.
> > > > > 
> > > > > Meaning that once tp->rcv_nxt is updated by CPU2, the CPU1 either already
> > > > > passed the tp->rcv_nxt check and sleeps, or will get the new value for
> > > > > tp->rcv_nxt and will return with new data mask.
> > > > > In both cases the process (CPU1) is being added to the wait queue, so the
> > > > > waitqueue_active (CPU2) call cannot miss and will wake up CPU1.
> > > > > 
> > > > > The bad case is when the __add_wait_queue changes done by CPU1 stay in its
> > > > > cache, and so does the tp->rcv_nxt update on CPU2 side.  The CPU1 will then
> > > > > endup calling schedule and sleep forever if there are no more data on the
> > > > > socket.
> > > > 
> > > > > +static inline int sk_has_sleeper(struct sock *sk)
> > > > > +{
> > > > > +	/*
> > > > > +	 * We need to be sure we are in sync with the
> > > > > +	 * add_wait_queue modifications to the wait queue.
> > > > > +	 *
> > > > > +	 * This memory barrier is paired in the sock_poll_wait.
> > > > > +	 */
> > > > > +	smp_mb();
> > > > > +	return sk->sk_sleep && waitqueue_active(sk->sk_sleep);
> > > > > +}
> > > > 
> > > > Jiri, since this is a pretty tricky condition, would you mind to have a 
> > > > reduced version of the patch comment added to the source code?
> > > > Patch comments are not really useful when you're trying to make sense of 
> > > > some code ;)
> > > > 
> > > 
> > > well, to be honest I thought it was already reduced :) however I have
> > > no problem to make it shorter.. any suggestions? 
> > > 
> > > "This memory barrier protects the add_wait_queue modifications.
> > > It is paired in the sock_poll_wait."
> > > 
> > > or do you want only the 
> > > 
> > > "This memory barrier is paired in the sock_poll_wait."
> > 
> > Heh, no, not that comment :)
> > You detailed very clearly why the MB machinery is needed in your email 
> > body, but the comment in the source code is pretty vague.
> > So when I was talking about comment reduction, I meant using a reduced 
> > version of the comment in the email body, into the proper place in the 
> > source code.
> > 
> 
> uf, good :) 
> I'll see what I can do, I'll resend
> 
> jirka
> 

ok, how about this

diff --git a/include/net/sock.h b/include/net/sock.h
index 352f06b..d6ea5d5 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h

[snip]
 
+/**
+ * sk_has_sleeper - check if there are any waiting processes
+ * @sk: socket
+ *
+ * Returns true if socket has waiting processes
+ *
+ * The purpose of the sk_has_sleeper and sock_poll_wait is to wrap the memory
+ * barrier calls. They were added due to the race found within the tcp code. The
+ * fix is generic for other protocols as well.
+ *
+ * Consider following tcp code paths:
+ *
+ * CPU1                  CPU2
+ *
+ * sys_select            receive packet
+ *   ...                 ...
+ *   __add_wait_queue    update tp->rcv_nxt
+ *   ...                 ...
+ *   tp->rcv_nxt check   sock_def_readable
+ *   ...                 {
+ *   schedule               ...
+ *                          if (sk->sk_sleep && waitqueue_active(sk->sk_sleep))
+ *                              wake_up_interruptible(sk->sk_sleep)
+ *                          ...
+ *                       }
+ *
+ * The race for tcp fires when the __add_wait_queue changes done by CPU1 stay
+ * in its cache, and so does the tp->rcv_nxt update on CPU2 side.  The CPU1
+ * could then endup calling schedule and sleep forever if there are no more
+ * data on the socket.
+ */
+static inline int sk_has_sleeper(struct sock *sk)
+{
+	/*
+	 * We need to be sure we are in sync with the
+	 * add_wait_queue modifications to the wait queue.
+	 *
+	 * This memory barrier is paired in the sock_poll_wait.
+	 */
+	smp_mb();
+	return sk->sk_sleep && waitqueue_active(sk->sk_sleep);
+}
+
+/**
+ * sock_poll_wait - place memory barrier behind the poll_wait call.
+ * @filp:           file
+ * @wait_address:   socket wait queue
+ * @p:              poll_table
+ *
+ * See the comments in the sk_has_sleeper function.
+ */
+static inline void sock_poll_wait(struct file *filp,
+		wait_queue_head_t *wait_address, poll_table *p)
+{
+	if (p && wait_address) {
+		poll_wait(filp, wait_address, p);
+		/*
+		 * We need to be sure we are in sync with the

[snip]


jirka

> > 
> > - Davide
> > 
> > 
