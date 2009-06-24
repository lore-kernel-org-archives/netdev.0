From: Jiri Olsa <jolsa@redhat.com>
Subject: Re: [RFC] tcp: race in receive part
Date: Wed, 24 Jun 2009 18:21:12 +0200
Message-ID: <20090624162112.GB5409@jolsa.lab.eng.brq.redhat.com>
References: <20090618102727.GC3782@jolsa.lab.eng.brq.redhat.com> <4A3A49F2.6060705@gmail.com> <20090623091257.GA4850@jolsa.lab.eng.brq.redhat.com> <4A40AF2A.3050509@gmail.com> <20090624102038.GA5409@jolsa.lab.eng.brq.redhat.com> <4A42082D.9060402@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	fbl@redhat.com, nhorman@redhat.com, davem@redhat.com,
	oleg@redhat.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:55223 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753002AbZFXQVR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Jun 2009 12:21:17 -0400
Content-Disposition: inline
In-Reply-To: <4A42082D.9060402@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 24, 2009 at 01:04:13PM +0200, Eric Dumazet wrote:
> Jiri Olsa a =C3=A9crit :
> > On Tue, Jun 23, 2009 at 12:32:10PM +0200, Eric Dumazet wrote:
> >> Jiri Olsa a =C3=A9crit :
> >>> Hi,
> >>>
> >>> thanks for an answer, and sorry for my late reply,
> >>> we needed the cust permission to disclose the debug data.
> >>>
> >> I see ! Now this is me with litle time as I am traveling right now=
=2E
> >>
> >>> On Thu, Jun 18, 2009 at 04:06:42PM +0200, Eric Dumazet wrote:
> >>>> Jiri Olsa a =C3=A9crit :
> >>>>> Hi,
> >>>>>
> >>>>> in RHEL4 we can see a race in the tcp layer. We were not able t=
o reproduce=20
> >>>>> this on the upstream kernel, but since the issue occurs very ra=
relly
> >>>>> (once per 8 days), we just might not be lucky.
> >>>>>
> >>>>> I'm affraid this might be a long email, I'll try to structure i=
t nicely.. :)
> >>>>>
> >>>> Thanks for your mail and detailed analysis
> >>>>
> >>>>> RACE DESCRIPTION
> >>>>> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> >>>>>
> >>>>> There's a nice pdf describing the issue (and sollution using lo=
cks) on
> >>>>> https://bugzilla.redhat.com/attachment.cgi?id=3D345014
> >>>> I could not reach this url unfortunatly=20
> >>>>
> >>>> --> "You are not authorized to access bug #494404. "
> >>> please try it now, the bug should be accessible now
> >>>
> >> Thanks, this doc is indeed nice :)
> >>
> >> But adding an write_lock()/write_unlock() in tcp_poll() was overki=
ll
> >> It had an sm_mb() implied because of the nesting of locks.
> >>
> >>>>> The race fires, when following code paths meet, and the tp->rcv=
_nxt and
> >>>>> __add_wait_queue updates stay in CPU caches.
> >>>>>
> >>>>> CPU1                         CPU2
> >>>>>
> >>>>>
> >>>>> sys_select                   receive packet
> >>>>>   ...                        ...
> >>>>>   __add_wait_queue           update tp->rcv_nxt
> >>>>>   ...                        ...
> >>>>>   tp->rcv_nxt check          sock_def_readable
> >>>>>   ...                        {
> >>>>>   schedule                      ...
> >>>>>                                 if (sk->sk_sleep && waitqueue_a=
ctive(sk->sk_sleep))
> >>>>>                                         wake_up_interruptible(s=
k->sk_sleep)
> >>>>>                                 ...
> >>>>>                              }
> >>>>>
> >>>>> If there were no cache the code would work ok, since the wait_q=
ueue and
> >>>>> rcv_nxt are opposit to each other.
> >>>>>
> >>>>> Meaning that once tp->rcv_nxt is updated by CPU2, the CPU1 eith=
er already
> >>>>> passed the tp->rcv_nxt check and sleeps, or will get the new va=
lue for
> >>>>> tp->rcv_nxt and will return with new data mask. =20
> >>>>> In both cases the process (CPU1) is being added to the wait que=
ue, so the
> >>>>> waitqueue_active (CPU2) call cannot miss and will wake up CPU1.
> >>>>>
> >>>>> The bad case is when the __add_wait_queue changes done by CPU1 =
stay in its
> >>>>> cache , and so does the tp->rcv_nxt update on CPU2 side.  The C=
PU1 will then
> >>>>> endup calling schedule and sleep forever if there are no more d=
ata on the
> >>>>> socket.
> >>>>>
> >>>>> Adding smp_mb() calls before sock_def_readable call and after _=
_add_wait_queue
> >>>>> should prevent the above bad scenario.
> >>>>>
> >>>>> The upstream patch is attached. It seems to prevent the issue.
> >>>>>
> >>>>>
> >>>>>
> >>>>> CPU BUGS
> >>>>> =3D=3D=3D=3D=3D=3D=3D=3D
> >>>>>
> >>>>> The customer has been able to reproduce this problem only on on=
e CPU model:
> >>>>> Xeon E5345*2. They didn't reproduce on XEON MV, for example.
> >>>> Is there an easy way to reproduce the problem ?
> >>> there's a reproducer attached to the bug
> >>>
> >>> https://enterprise.redhat.com/issue-tracker/?module=3Ddownload&fi=
d=3D201560&key=3Df6f87caf6ac2dc1eb1173257c8a5ef78
> >>>
> >>> it is basically the client/server program.=20
> >>> They're passing messages to each other. When a message is sent,
> >>> both of them expect message on the input before sending another m=
essage.
> >>>
> >>> Very rarely the code hits the place when the process which called=
 select
> >>> is not woken up by incomming data. Probably because of the memory=
 cache
> >>> incoherency. See backtrace in the=20
> >>>
> >>> https://bugzilla.redhat.com/show_bug.cgi?id=3D494404#c1
> >>>
> >>>
> >>>>> That CPU model happens to have 2 possible issues, that might ca=
use the issue:
> >>>>> (see errata http://www.intel.com/Assets/PDF/specupdate/315338.p=
df)
> >>>>>
> >>>>> AJ39 and AJ18. The first one can be workarounded by BIOS upgrad=
e,
> >>>>> the other one has following notes:
> >>>> AJ18 only matters on unaligned accesses, tcp code doesnt do this=
=2E
> >>>>
> >>>>>       Software should ensure at least one of the following is t=
rue when
> >>>>>       modifying shared data by multiple agents:
> >>>>>              =E2=80=A2 The shared data is aligned
> >>>>>              =E2=80=A2 Proper semaphores or barriers are used i=
n order to
> >>>>>                 prevent concurrent data accesses.
> >>>>>
> >>>>>
> >>>>>
> >>>>> RFC
> >>>>> =3D=3D=3D
> >>>>>
> >>>>> I'm aware that not having this issue reproduced on upstream low=
ers the odds
> >>>>> having this checked in. However AFAICS the issue is present. I'=
d appreciate
> >>>>> any comment/ideas.
> >>>>>
> >>>>>
> >>>>> thanks,
> >>>>> jirka
> >>>>>
> >>>>>
> >>>>> Signed-off-by: Jiri Olsa <jolsa@redhat.com>
> >>>>>
> >>>>> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
> >>>>> index 17b89c5..f5d9dbf 100644
> >>>>> --- a/net/ipv4/tcp.c
> >>>>> +++ b/net/ipv4/tcp.c
> >>>>> @@ -340,6 +340,11 @@ unsigned int tcp_poll(struct file *file, s=
truct socket *sock, poll_table *wait)
> >>>>>  	struct tcp_sock *tp =3D tcp_sk(sk);
> >>>>> =20
> >>>>>  	poll_wait(file, sk->sk_sleep, wait);
> >>>> poll_wait() calls add_wait_queue() which contains a=20
> >>>> spin_lock_irqsave()/spin_unlock_irqrestore() pair
> >>>>
> >>>> Documentation/memory-barriers.txt states in line 1123 :
> >>>>
> >>>> 	Memory operations issued after the LOCK will be completed after=
 the LOCK
> >>>> 	operation has completed.
> >>>>
> >>>> and line 1131 states :
> >>>>
> >>>> 	Memory operations issued before the UNLOCK will be completed be=
fore the
> >>>> 	UNLOCK operation has completed.
> >>>>
> >>>> So yes, there is no full smp_mb() in poll_wait()
> >>>>
> >>>>> +
> >>>>> +	/* Get in sync with tcp_data_queue, tcp_urg
> >>>>> +	   and tcp_rcv_established function. */
> >>>>> +	smp_mb();
> >>>> If this barrier is really necessary, I guess it should be done i=
n poll_wait() itself.
> >>>>
> >>>> Documentation/memory-barriers.txt misses some information about =
poll_wait()
> >>>>
> >>>>
> >>>>
> >>>>
> >>>>> +
> >>>>>  	if (sk->sk_state =3D=3D TCP_LISTEN)
> >>>>>  		return inet_csk_listen_poll(sk);
> >>>>> =20
> >>>>> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> >>>>> index 2bdb0da..0606e5e 100644
> >>>>> --- a/net/ipv4/tcp_input.c
> >>>>> +++ b/net/ipv4/tcp_input.c
> >>>>> @@ -4362,8 +4362,11 @@ queue_and_out:
> >>>>> =20
> >>>>>  		if (eaten > 0)
> >>>>>  			__kfree_skb(skb);
> >>>>> -		else if (!sock_flag(sk, SOCK_DEAD))
> >>>>> +		else if (!sock_flag(sk, SOCK_DEAD)) {
> >>>>> +			/* Get in sync with tcp_poll function. */
> >>>>> +			smp_mb();
> >>>>>  			sk->sk_data_ready(sk, 0);
> >>>>> +		}
> >>>>>  		return;
> >>>>>
> >>>> Oh well... if smp_mb() is needed, I believe it should be done
> >>>> right before "if (waitqueue_active(sk->sk_sleep) ... "
> >>>>
> >>>>  	read_lock(&sk->sk_callback_lock);
> >>>> +	smp_mb();
> >>>>  	if (sk->sk_sleep && waitqueue_active(sk->sk_sleep))
> >>>>  		wake_up_interruptible(sk->sk_sleep)
> >>>>
> >>>> It would match other parts in kernel (see fs/splice.c, fs/aio.c,=
 ...)
> >>>>
> >>>> Strange thing is that read_lock() on x86 is a full memory barrie=
r, as it uses
> >>>> "lock subl $0x1,(%eax)"
> >>>>
> >>>> Maybe we could define a smp_mb_after_read_lock()  (a compiler ba=
rrier() on x86)
> >>>>
> >>> First version of the patch was actually in this layer, see
> >>> https://bugzilla.redhat.com/attachment.cgi?id=3D345886
> >>>
> >>> I was adviced this could be to invasive (it was in waitqueue_acti=
ve actually),=20
> >>> so I moved the change to the TCP layer itself...=20
> >>>
> >>> As far as I understand the problem there's need for 2 barriers to=
 be
> >>> sure, the memory will have correct data. One in the codepath call=
ing the
> >>> select (tcp_poll), and in the other one updating the available da=
ta status=20
> >>> (sock_def_readable), am I missing smth?
> >>>
> >> Hmm, I am not saying your patch doesnt fix the problem, I am sayin=
g it
> >> is a partial fix of a general problem. We might have same problem(=
s) in other
> >> parts of network stack. This is a very serious issue.
> >>
> >> Point 1 :
> >>
> >> You added an smp_mb() call in tcp_poll(). This one looks fine to s=
olve
> >> the problem for tcp sockets. What about other protocols ? Do we ha=
ve
> >> same problem ?
> >=20
> > Looks like most of the protocols using the poll_wait. Also I assume
> > that most of them will probably have the same scenario as the one
> > described (CPU1 and CPU2 codepaths in the RACE DESCRIPTION).
> >=20
> > So I moved the poll smp_mb() call to the __pollwait function, plz
> > check the attached diff. This might be too invasive, so another
> > place could be probably polling callbacks themselfs like=20
> > datagram_poll (used very often by protocols), tcp_poll, udp_poll...
> >=20
> > I'm still looking which way would be more suitable, comments are ve=
ry
> > welcome :)
> >=20
> >> Point 2 :
> >>
> >> You added several smp_mb() calls in tcp input path. In my first
> >> reply, I said it was probably better to add smp_mb() in a single=20
> >> place, right before "if (waitqueue_active(sk->sk_sleep) ... ",
> >> but in all paths (input path & output path).
> >>
> >> Point 3 :
> >>
> >> The optimization we could do, defining
> >> a smp_mb_after_read_lock() that could be a nop on x86
> >>
> >> 	read_lock(&sk->sk_callback_lock); // "lock subl $0x1,(%eax)" on x=
86
> >> 	smp_mb_after_read_lock(); /* compiler barrier() on x86 */
> >> 	if (sk->sk_sleep && waitqueue_active(sk->sk_sleep))
> >>  		wake_up_interruptible(sk->sk_sleep);
> >>
> >> Am I missing something ?
> >>
> >> ;)
> >>
> >=20
> > not at all :) I'm the one behind..
> >=20
> > Anyway I made modifications based on Point 2) and 3) and the diff i=
s
> > attached, please check.
> >=20
> > thanks a lot,
> > jirka
> >=20
> >=20
> > diff --git a/arch/x86/include/asm/spinlock.h b/arch/x86/include/asm=
/spinlock.h
> > index b7e5db8..570c0ff 100644
> > --- a/arch/x86/include/asm/spinlock.h
> > +++ b/arch/x86/include/asm/spinlock.h
> > @@ -302,4 +302,7 @@ static inline void __raw_write_unlock(raw_rwloc=
k_t *rw)
> >  #define _raw_read_relax(lock)	cpu_relax()
> >  #define _raw_write_relax(lock)	cpu_relax()
> > =20
> > +/* The read_lock() on x86 is a full memory barrier. */
> > +#define smp_mb__after_read_lock() barrier()
> > +
> >  #endif /* _ASM_X86_SPINLOCK_H */
> > diff --git a/fs/select.c b/fs/select.c
> > index d870237..f9ebd45 100644
> > --- a/fs/select.c
> > +++ b/fs/select.c
> > @@ -219,6 +219,10 @@ static void __pollwait(struct file *filp, wait=
_queue_head_t *wait_address,
> >  	init_waitqueue_func_entry(&entry->wait, pollwake);
> >  	entry->wait.private =3D pwq;
> >  	add_wait_queue(wait_address, &entry->wait);
> > +
> > +	/* This memory barrier is paired with the smp_mb__after_read_lock
> > +	 * in the sock_def_readable. */
> > +	smp_mb();
> >  }
> > =20
> >  int poll_schedule_timeout(struct poll_wqueues *pwq, int state,
> > diff --git a/include/linux/spinlock.h b/include/linux/spinlock.h
> > index 252b245..dd28726 100644
> > --- a/include/linux/spinlock.h
> > +++ b/include/linux/spinlock.h
> > @@ -132,6 +132,11 @@ do {								\
> >  #endif /*__raw_spin_is_contended*/
> >  #endif
> > =20
> > +/* The read_lock does not imply full memory barrier. */
> > +#ifndef smp_mb__after_read_lock
> > +#define smp_mb__after_read_lock() smp_mb()
> > +#endif
> > +
> >  /**
> >   * spin_unlock_wait - wait until the spinlock gets unlocked
> >   * @lock: the spinlock in question.
> > diff --git a/net/core/sock.c b/net/core/sock.c
> > index b0ba569..11e414f 100644
> > --- a/net/core/sock.c
> > +++ b/net/core/sock.c
> > @@ -1732,6 +1732,7 @@ static void sock_def_error_report(struct sock=
 *sk)
> >  static void sock_def_readable(struct sock *sk, int len)
> >  {
> >  	read_lock(&sk->sk_callback_lock);
> > +	smp_mb__after_read_lock();
> >  	if (sk->sk_sleep && waitqueue_active(sk->sk_sleep))
> >  		wake_up_interruptible_sync_poll(sk->sk_sleep, POLLIN |
> >  						POLLRDNORM | POLLRDBAND);
>=20
> I suspect we need to change all places where we do :
>=20
>=20
> read_lock(&sk->sk_callback_lock);
> ...
> if (sk->sk_sleep && waitqueue_active(sk->sk_sleep))
>=20
> to :
>=20
> read_lock(&sk->sk_callback_lock);
> ...
> smp_mb__after_read_lock();
> if (sk->sk_sleep && waitqueue_active(sk->sk_sleep))
>=20
> I suggest you add a helper function like
>=20
> static inline int sk_has_sleeper(struct sock *sk)
> {
> 	/*
> 	 * some nice comment here why this barrier is needed
> 	 * (and where opposite one is located)
> 	 */
> 	smp_mb__after_read_lock();
> 	return sk->sk_sleep && waitqueue_active(sk->sk_sleep);
> }
>=20
> and use it in net/atm/common.c : vcc_def_wakeup() & vcc_write_space()
> net/dccp/output.c : dccp_write_space()
> net/core/stream.c : sk_stream_write_space()
> net/core/sock.c : sock_def_wakeup(), sock_def_error_report(),
> 		sock_def_readable(), sock_def_write_space()
> net/iucv/af_iucv.c : iucv_sock_wake_msglim()
>=20
> and several others as well in net tree... "find|grep" are your friend=
s :)
>=20
>=20
> Thanks

I made the modification, plz check the attached diff.

I found some places where the read_lock is not ahead of the check:
  "if (sk->sk_sleep && waitqueue_active(sk->sk_sleep))"

I'm not sure we dont want to address those as well; located in followin=
g
files:
        drivers/net/tun.c
        net/core/stream.c
        net/sctp/socket.c
        net/sunrpc/svcsock.c


thanks,
jirka


diff --git a/arch/x86/include/asm/spinlock.h b/arch/x86/include/asm/spi=
nlock.h
index b7e5db8..570c0ff 100644
--- a/arch/x86/include/asm/spinlock.h
+++ b/arch/x86/include/asm/spinlock.h
@@ -302,4 +302,7 @@ static inline void __raw_write_unlock(raw_rwlock_t =
*rw)
 #define _raw_read_relax(lock)	cpu_relax()
 #define _raw_write_relax(lock)	cpu_relax()
=20
+/* The read_lock() on x86 is a full memory barrier. */
+#define smp_mb__after_read_lock() barrier()
+
 #endif /* _ASM_X86_SPINLOCK_H */
diff --git a/fs/select.c b/fs/select.c
index d870237..cf5d80b 100644
--- a/fs/select.c
+++ b/fs/select.c
@@ -219,6 +219,10 @@ static void __pollwait(struct file *filp, wait_que=
ue_head_t *wait_address,
 	init_waitqueue_func_entry(&entry->wait, pollwake);
 	entry->wait.private =3D pwq;
 	add_wait_queue(wait_address, &entry->wait);
+
+	/* This memory barrier is paired with the smp_mb__after_read_lock
+	 * in the sk_has_sleeper. */
+	smp_mb();
 }
=20
 int poll_schedule_timeout(struct poll_wqueues *pwq, int state,
diff --git a/include/linux/spinlock.h b/include/linux/spinlock.h
index 252b245..dd28726 100644
--- a/include/linux/spinlock.h
+++ b/include/linux/spinlock.h
@@ -132,6 +132,11 @@ do {								\
 #endif /*__raw_spin_is_contended*/
 #endif
=20
+/* The read_lock does not imply full memory barrier. */
+#ifndef smp_mb__after_read_lock
+#define smp_mb__after_read_lock() smp_mb()
+#endif
+
 /**
  * spin_unlock_wait - wait until the spinlock gets unlocked
  * @lock: the spinlock in question.
diff --git a/include/net/sock.h b/include/net/sock.h
index 07133c5..a02a956 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1241,6 +1241,24 @@ static inline int sk_has_allocations(const struc=
t sock *sk)
 	return sk_wmem_alloc_get(sk) || sk_rmem_alloc_get(sk);
 }
=20
+/**
+ * sk_has_sleeper - check if there are any waiting processes
+ * @sk: socket
+ *
+ * Returns true if socket has waiting processes
+ */
+static inline int sk_has_sleeper(struct sock *sk)
+{
+	/*
+	 * We need to be sure we are in sync with the
+	 * add_wait_queue modifications to the wait queue.
+	 *
+	 * This memory barrier is paired in the __pollwait.
+	 */
+	smp_mb__after_read_lock();
+	return sk->sk_sleep && waitqueue_active(sk->sk_sleep);
+}
+
 /*
  * 	Queue a received datagram if it will fit. Stream and sequenced
  *	protocols can't normally use this as they need to fit buffers in
diff --git a/net/atm/common.c b/net/atm/common.c
index c1c9793..67a8642 100644
--- a/net/atm/common.c
+++ b/net/atm/common.c
@@ -92,7 +92,7 @@ static void vcc_sock_destruct(struct sock *sk)
 static void vcc_def_wakeup(struct sock *sk)
 {
 	read_lock(&sk->sk_callback_lock);
-	if (sk->sk_sleep && waitqueue_active(sk->sk_sleep))
+	if (sk_has_sleeper(sk))
 		wake_up(sk->sk_sleep);
 	read_unlock(&sk->sk_callback_lock);
 }
@@ -110,7 +110,7 @@ static void vcc_write_space(struct sock *sk)
 	read_lock(&sk->sk_callback_lock);
=20
 	if (vcc_writable(sk)) {
-		if (sk->sk_sleep && waitqueue_active(sk->sk_sleep))
+		if (sk_has_sleeper(sk))
 			wake_up_interruptible(sk->sk_sleep);
=20
 		sk_wake_async(sk, SOCK_WAKE_SPACE, POLL_OUT);
diff --git a/net/core/sock.c b/net/core/sock.c
index b0ba569..6354863 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1715,7 +1715,7 @@ EXPORT_SYMBOL(sock_no_sendpage);
 static void sock_def_wakeup(struct sock *sk)
 {
 	read_lock(&sk->sk_callback_lock);
-	if (sk->sk_sleep && waitqueue_active(sk->sk_sleep))
+	if (sk_has_sleeper(sk))
 		wake_up_interruptible_all(sk->sk_sleep);
 	read_unlock(&sk->sk_callback_lock);
 }
@@ -1723,7 +1723,7 @@ static void sock_def_wakeup(struct sock *sk)
 static void sock_def_error_report(struct sock *sk)
 {
 	read_lock(&sk->sk_callback_lock);
-	if (sk->sk_sleep && waitqueue_active(sk->sk_sleep))
+	if (sk_has_sleeper(sk))
 		wake_up_interruptible_poll(sk->sk_sleep, POLLERR);
 	sk_wake_async(sk, SOCK_WAKE_IO, POLL_ERR);
 	read_unlock(&sk->sk_callback_lock);
@@ -1732,7 +1732,7 @@ static void sock_def_error_report(struct sock *sk=
)
 static void sock_def_readable(struct sock *sk, int len)
 {
 	read_lock(&sk->sk_callback_lock);
-	if (sk->sk_sleep && waitqueue_active(sk->sk_sleep))
+	if (sk_has_sleeper(sk))
 		wake_up_interruptible_sync_poll(sk->sk_sleep, POLLIN |
 						POLLRDNORM | POLLRDBAND);
 	sk_wake_async(sk, SOCK_WAKE_WAITD, POLL_IN);
@@ -1747,7 +1747,7 @@ static void sock_def_write_space(struct sock *sk)
 	 * progress.  --DaveM
 	 */
 	if ((atomic_read(&sk->sk_wmem_alloc) << 1) <=3D sk->sk_sndbuf) {
-		if (sk->sk_sleep && waitqueue_active(sk->sk_sleep))
+		if (sk_has_sleeper(sk))
 			wake_up_interruptible_sync_poll(sk->sk_sleep, POLLOUT |
 						POLLWRNORM | POLLWRBAND);
=20
diff --git a/net/dccp/output.c b/net/dccp/output.c
index c0e88c1..c96119f 100644
--- a/net/dccp/output.c
+++ b/net/dccp/output.c
@@ -196,7 +196,7 @@ void dccp_write_space(struct sock *sk)
 {
 	read_lock(&sk->sk_callback_lock);
=20
-	if (sk->sk_sleep && waitqueue_active(sk->sk_sleep))
+	if (sk_has_sleeper(sk))
 		wake_up_interruptible(sk->sk_sleep);
 	/* Should agree with poll, otherwise some programs break */
 	if (sock_writeable(sk))
diff --git a/net/iucv/af_iucv.c b/net/iucv/af_iucv.c
index 6be5f92..ba0149d 100644
--- a/net/iucv/af_iucv.c
+++ b/net/iucv/af_iucv.c
@@ -306,7 +306,7 @@ static inline int iucv_below_msglim(struct sock *sk=
)
 static void iucv_sock_wake_msglim(struct sock *sk)
 {
 	read_lock(&sk->sk_callback_lock);
-	if (sk->sk_sleep && waitqueue_active(sk->sk_sleep))
+	if (sk_has_sleeper(sk))
 		wake_up_interruptible_all(sk->sk_sleep);
 	sk_wake_async(sk, SOCK_WAKE_SPACE, POLL_OUT);
 	read_unlock(&sk->sk_callback_lock);
diff --git a/net/rxrpc/af_rxrpc.c b/net/rxrpc/af_rxrpc.c
index eac5e7b..60e0e38 100644
--- a/net/rxrpc/af_rxrpc.c
+++ b/net/rxrpc/af_rxrpc.c
@@ -63,7 +63,7 @@ static void rxrpc_write_space(struct sock *sk)
 	_enter("%p", sk);
 	read_lock(&sk->sk_callback_lock);
 	if (rxrpc_writable(sk)) {
-		if (sk->sk_sleep && waitqueue_active(sk->sk_sleep))
+		if (sk_has_sleeper(sk))
 			wake_up_interruptible(sk->sk_sleep);
 		sk_wake_async(sk, SOCK_WAKE_SPACE, POLL_OUT);
 	}
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 36d4e44..143143a 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -315,7 +315,7 @@ static void unix_write_space(struct sock *sk)
 {
 	read_lock(&sk->sk_callback_lock);
 	if (unix_writable(sk)) {
-		if (sk->sk_sleep && waitqueue_active(sk->sk_sleep))
+		if (sk_has_sleeper(sk))
 			wake_up_interruptible_sync(sk->sk_sleep);
 		sk_wake_async(sk, SOCK_WAKE_SPACE, POLL_OUT);
 	}

