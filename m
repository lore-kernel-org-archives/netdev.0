From: Jiri Olsa <jolsa@redhat.com>
Subject: Re: [RFC] tcp: race in receive part
Date: Wed, 24 Jun 2009 12:20:38 +0200
Message-ID: <20090624102038.GA5409@jolsa.lab.eng.brq.redhat.com>
References: <20090618102727.GC3782@jolsa.lab.eng.brq.redhat.com> <4A3A49F2.6060705@gmail.com> <20090623091257.GA4850@jolsa.lab.eng.brq.redhat.com> <4A40AF2A.3050509@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	fbl@redhat.com, nhorman@redhat.com, davem@redhat.com,
	oleg@redhat.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752999AbZFXKUy@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4A40AF2A.3050509@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 23, 2009 at 12:32:10PM +0200, Eric Dumazet wrote:
> Jiri Olsa a =C3=A9crit :
> > Hi,
> >=20
> > thanks for an answer, and sorry for my late reply,
> > we needed the cust permission to disclose the debug data.
> >=20
>=20
> I see ! Now this is me with litle time as I am traveling right now.
>=20
> >=20
> > On Thu, Jun 18, 2009 at 04:06:42PM +0200, Eric Dumazet wrote:
> >> Jiri Olsa a =C3=A9crit :
> >>> Hi,
> >>>
> >>> in RHEL4 we can see a race in the tcp layer. We were not able to =
reproduce=20
> >>> this on the upstream kernel, but since the issue occurs very rare=
lly
> >>> (once per 8 days), we just might not be lucky.
> >>>
> >>> I'm affraid this might be a long email, I'll try to structure it =
nicely.. :)
> >>>
> >> Thanks for your mail and detailed analysis
> >>
> >>>
> >>> RACE DESCRIPTION
> >>> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> >>>
> >>> There's a nice pdf describing the issue (and sollution using lock=
s) on
> >>> https://bugzilla.redhat.com/attachment.cgi?id=3D345014
> >> I could not reach this url unfortunatly=20
> >>
> >> --> "You are not authorized to access bug #494404. "
> >=20
> > please try it now, the bug should be accessible now
> >=20
>=20
> Thanks, this doc is indeed nice :)
>=20
> But adding an write_lock()/write_unlock() in tcp_poll() was overkill
> It had an sm_mb() implied because of the nesting of locks.
>=20
> >>>
> >>> The race fires, when following code paths meet, and the tp->rcv_n=
xt and
> >>> __add_wait_queue updates stay in CPU caches.
> >>>
> >>> CPU1                         CPU2
> >>>
> >>>
> >>> sys_select                   receive packet
> >>>   ...                        ...
> >>>   __add_wait_queue           update tp->rcv_nxt
> >>>   ...                        ...
> >>>   tp->rcv_nxt check          sock_def_readable
> >>>   ...                        {
> >>>   schedule                      ...
> >>>                                 if (sk->sk_sleep && waitqueue_act=
ive(sk->sk_sleep))
> >>>                                         wake_up_interruptible(sk-=
>sk_sleep)
> >>>                                 ...
> >>>                              }
> >>>
> >>> If there were no cache the code would work ok, since the wait_que=
ue and
> >>> rcv_nxt are opposit to each other.
> >>>
> >>> Meaning that once tp->rcv_nxt is updated by CPU2, the CPU1 either=
 already
> >>> passed the tp->rcv_nxt check and sleeps, or will get the new valu=
e for
> >>> tp->rcv_nxt and will return with new data mask. =20
> >>> In both cases the process (CPU1) is being added to the wait queue=
, so the
> >>> waitqueue_active (CPU2) call cannot miss and will wake up CPU1.
> >>>
> >>> The bad case is when the __add_wait_queue changes done by CPU1 st=
ay in its
> >>> cache , and so does the tp->rcv_nxt update on CPU2 side.  The CPU=
1 will then
> >>> endup calling schedule and sleep forever if there are no more dat=
a on the
> >>> socket.
> >>>
> >>> Adding smp_mb() calls before sock_def_readable call and after __a=
dd_wait_queue
> >>> should prevent the above bad scenario.
> >>>
> >>> The upstream patch is attached. It seems to prevent the issue.
> >>>
> >>>
> >>>
> >>> CPU BUGS
> >>> =3D=3D=3D=3D=3D=3D=3D=3D
> >>>
> >>> The customer has been able to reproduce this problem only on one =
CPU model:
> >>> Xeon E5345*2. They didn't reproduce on XEON MV, for example.
> >> Is there an easy way to reproduce the problem ?
> >=20
> > there's a reproducer attached to the bug
> >=20
> > https://enterprise.redhat.com/issue-tracker/?module=3Ddownload&fid=3D=
201560&key=3Df6f87caf6ac2dc1eb1173257c8a5ef78
> >=20
> > it is basically the client/server program.=20
> > They're passing messages to each other. When a message is sent,
> > both of them expect message on the input before sending another mes=
sage.
> >=20
> > Very rarely the code hits the place when the process which called s=
elect
> > is not woken up by incomming data. Probably because of the memory c=
ache
> > incoherency. See backtrace in the=20
> >=20
> > https://bugzilla.redhat.com/show_bug.cgi?id=3D494404#c1
> >=20
> >=20
> >>> That CPU model happens to have 2 possible issues, that might caus=
e the issue:
> >>> (see errata http://www.intel.com/Assets/PDF/specupdate/315338.pdf=
)
> >>>
> >>> AJ39 and AJ18. The first one can be workarounded by BIOS upgrade,
> >>> the other one has following notes:
> >> AJ18 only matters on unaligned accesses, tcp code doesnt do this.
> >>
> >>>       Software should ensure at least one of the following is tru=
e when
> >>>       modifying shared data by multiple agents:
> >>>              =E2=80=A2 The shared data is aligned
> >>>              =E2=80=A2 Proper semaphores or barriers are used in =
order to
> >>>                 prevent concurrent data accesses.
> >>>
> >>>
> >>>
> >>> RFC
> >>> =3D=3D=3D
> >>>
> >>> I'm aware that not having this issue reproduced on upstream lower=
s the odds
> >>> having this checked in. However AFAICS the issue is present. I'd =
appreciate
> >>> any comment/ideas.
> >>>
> >>>
> >>> thanks,
> >>> jirka
> >>>
> >>>
> >>> Signed-off-by: Jiri Olsa <jolsa@redhat.com>
> >>>
> >>> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
> >>> index 17b89c5..f5d9dbf 100644
> >>> --- a/net/ipv4/tcp.c
> >>> +++ b/net/ipv4/tcp.c
> >>> @@ -340,6 +340,11 @@ unsigned int tcp_poll(struct file *file, str=
uct socket *sock, poll_table *wait)
> >>>  	struct tcp_sock *tp =3D tcp_sk(sk);
> >>> =20
> >>>  	poll_wait(file, sk->sk_sleep, wait);
> >> poll_wait() calls add_wait_queue() which contains a=20
> >> spin_lock_irqsave()/spin_unlock_irqrestore() pair
> >>
> >> Documentation/memory-barriers.txt states in line 1123 :
> >>
> >> 	Memory operations issued after the LOCK will be completed after t=
he LOCK
> >> 	operation has completed.
> >>
> >> and line 1131 states :
> >>
> >> 	Memory operations issued before the UNLOCK will be completed befo=
re the
> >> 	UNLOCK operation has completed.
> >>
> >> So yes, there is no full smp_mb() in poll_wait()
> >>
> >>> +
> >>> +	/* Get in sync with tcp_data_queue, tcp_urg
> >>> +	   and tcp_rcv_established function. */
> >>> +	smp_mb();
> >> If this barrier is really necessary, I guess it should be done in =
poll_wait() itself.
> >>
> >> Documentation/memory-barriers.txt misses some information about po=
ll_wait()
> >>
> >>
> >>
> >>
> >>> +
> >>>  	if (sk->sk_state =3D=3D TCP_LISTEN)
> >>>  		return inet_csk_listen_poll(sk);
> >>> =20
> >>> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> >>> index 2bdb0da..0606e5e 100644
> >>> --- a/net/ipv4/tcp_input.c
> >>> +++ b/net/ipv4/tcp_input.c
> >>> @@ -4362,8 +4362,11 @@ queue_and_out:
> >>> =20
> >>>  		if (eaten > 0)
> >>>  			__kfree_skb(skb);
> >>> -		else if (!sock_flag(sk, SOCK_DEAD))
> >>> +		else if (!sock_flag(sk, SOCK_DEAD)) {
> >>> +			/* Get in sync with tcp_poll function. */
> >>> +			smp_mb();
> >>>  			sk->sk_data_ready(sk, 0);
> >>> +		}
> >>>  		return;
> >>>
> >> Oh well... if smp_mb() is needed, I believe it should be done
> >> right before "if (waitqueue_active(sk->sk_sleep) ... "
> >>
> >>  	read_lock(&sk->sk_callback_lock);
> >> +	smp_mb();
> >>  	if (sk->sk_sleep && waitqueue_active(sk->sk_sleep))
> >>  		wake_up_interruptible(sk->sk_sleep)
> >>
> >> It would match other parts in kernel (see fs/splice.c, fs/aio.c, .=
=2E.)
> >>
> >> Strange thing is that read_lock() on x86 is a full memory barrier,=
 as it uses
> >> "lock subl $0x1,(%eax)"
> >>
> >> Maybe we could define a smp_mb_after_read_lock()  (a compiler barr=
ier() on x86)
> >>
> >=20
> > First version of the patch was actually in this layer, see
> > https://bugzilla.redhat.com/attachment.cgi?id=3D345886
> >=20
> > I was adviced this could be to invasive (it was in waitqueue_active=
 actually),=20
> > so I moved the change to the TCP layer itself...=20
> >=20
> > As far as I understand the problem there's need for 2 barriers to b=
e
> > sure, the memory will have correct data. One in the codepath callin=
g the
> > select (tcp_poll), and in the other one updating the available data=
 status=20
> > (sock_def_readable), am I missing smth?
> >=20
>=20
> Hmm, I am not saying your patch doesnt fix the problem, I am saying i=
t
> is a partial fix of a general problem. We might have same problem(s) =
in other
> parts of network stack. This is a very serious issue.
>=20
> Point 1 :
>=20
> You added an smp_mb() call in tcp_poll(). This one looks fine to solv=
e
> the problem for tcp sockets. What about other protocols ? Do we have
> same problem ?

Looks like most of the protocols using the poll_wait. Also I assume
that most of them will probably have the same scenario as the one
described (CPU1 and CPU2 codepaths in the RACE DESCRIPTION).

So I moved the poll smp_mb() call to the __pollwait function, plz
check the attached diff. This might be too invasive, so another
place could be probably polling callbacks themselfs like=20
datagram_poll (used very often by protocols), tcp_poll, udp_poll...

I'm still looking which way would be more suitable, comments are very
welcome :)

>=20
> Point 2 :
>=20
> You added several smp_mb() calls in tcp input path. In my first
> reply, I said it was probably better to add smp_mb() in a single=20
> place, right before "if (waitqueue_active(sk->sk_sleep) ... ",
> but in all paths (input path & output path).
>=20
> Point 3 :
>=20
> The optimization we could do, defining
> a smp_mb_after_read_lock() that could be a nop on x86
>=20
> 	read_lock(&sk->sk_callback_lock); // "lock subl $0x1,(%eax)" on x86
> 	smp_mb_after_read_lock(); /* compiler barrier() on x86 */
> 	if (sk->sk_sleep && waitqueue_active(sk->sk_sleep))
>  		wake_up_interruptible(sk->sk_sleep);
>=20
> Am I missing something ?
>=20
> ;)
>=20

not at all :) I'm the one behind..

Anyway I made modifications based on Point 2) and 3) and the diff is
attached, please check.

thanks a lot,
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
index d870237..f9ebd45 100644
--- a/fs/select.c
+++ b/fs/select.c
@@ -219,6 +219,10 @@ static void __pollwait(struct file *filp, wait_que=
ue_head_t *wait_address,
 	init_waitqueue_func_entry(&entry->wait, pollwake);
 	entry->wait.private =3D pwq;
 	add_wait_queue(wait_address, &entry->wait);
+
+	/* This memory barrier is paired with the smp_mb__after_read_lock
+	 * in the sock_def_readable. */
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
diff --git a/net/core/sock.c b/net/core/sock.c
index b0ba569..11e414f 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1732,6 +1732,7 @@ static void sock_def_error_report(struct sock *sk=
)
 static void sock_def_readable(struct sock *sk, int len)
 {
 	read_lock(&sk->sk_callback_lock);
+	smp_mb__after_read_lock();
 	if (sk->sk_sleep && waitqueue_active(sk->sk_sleep))
 		wake_up_interruptible_sync_poll(sk->sk_sleep, POLLIN |
 						POLLRDNORM | POLLRDBAND);
