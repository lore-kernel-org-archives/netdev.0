From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] poll: Avoid extra wakeups in select/poll
Date: Tue, 28 Apr 2009 22:33:01 +0200
Message-ID: <49F767FD.2040205@cosmosbay.com>
References: <alpine.DEB.1.10.0904241554100.29995@qirst.com> <49F3308B.1030507@cosmosbay.com> <20090426.020411.157511269.davem@davemloft.net> <49F43B8F.2050907@cosmosbay.com> <87ab60rh8t.fsf@basil.nowhere.org> <49F71B63.8010503@cosmosbay.com> <alpine.DEB.1.10.0904281501300.13862@qirst.com> <49F76174.6060009@cosmosbay.com> <alpine.DEB.1.10.0904281612560.13862@qirst.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux kernel <linux-kernel@vger.kernel.org>,
	Andi Kleen <andi@firstfloor.org>,
	David Miller <davem@davemloft.net>, jesse.brandeburg@intel.com,
	netdev@vger.kernel.org, haoki@redhat.com, mchan@broadcom.com,
	davidel@xmailserver.org, Ingo Molnar <mingo@elte.hu>
To: Christoph Lameter <cl@linux.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753316AbZD1Uel@vger.kernel.org>
In-Reply-To: <alpine.DEB.1.10.0904281612560.13862@qirst.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Christoph Lameter a =E9crit :
> On Tue, 28 Apr 2009, Eric Dumazet wrote:
>=20
>> Part about recvfrom() wakeup avoidance is in David net-2.6 tree, and=
 saves 2 us on udpping here.
>>
>> Is it what you call git2p1 ?
>=20
> No that is just the prior version of the poll/select improvements.
>=20
> Which patch are you referring to?
>=20
>=20

The one that did improved your udpping 'bench' :)

http://git2.kernel.org/?p=3Dlinux/kernel/git/davem/net-2.6.git;a=3Dcomm=
itdiff;h=3Dbf368e4e70cd4e0f880923c44e95a4273d725ab4

[PATCH] net: Avoid extra wakeups of threads blocked in wait_for_packet(=
)

In 2.6.25 we added UDP mem accounting.

This unfortunatly added a penalty when a frame is transmitted, since
we have at TX completion time to call sock_wfree() to perform necessary
memory accounting. This calls sock_def_write_space() and utimately
scheduler if any thread is waiting on the socket.
Thread(s) waiting for an incoming frame was scheduled, then had to slee=
p
again as event was meaningless.

(All threads waiting on a socket are using same sk_sleep anchor)

This adds lot of extra wakeups and increases latencies, as noted
by Christoph Lameter, and slows down softirq handler.

Reference : http://marc.info/?l=3Dlinux-netdev&m=3D124060437012283&w=3D=
2=20

=46ortunatly, Davide Libenzi recently added concept of keyed wakeups
into kernel, and particularly for sockets (see commit
37e5540b3c9d838eb20f2ca8ea2eb8072271e403=20
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
      receiver_wake_function() : Stops here since thread is waiting for=
 an INPUT


Reported-by: Christoph Lameter <cl@linux.com>
Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/linux/wait.h |    6 ++++--
 net/core/datagram.c  |   14 +++++++++++++-
 2 files changed, 17 insertions(+), 3 deletions(-)

diff --git a/include/linux/wait.h b/include/linux/wait.h
index 5d631c1..bc02463 100644
--- a/include/linux/wait.h
+++ b/include/linux/wait.h
@@ -440,13 +440,15 @@ void abort_exclusive_wait(wait_queue_head_t *q, w=
ait_queue_t *wait,
 int autoremove_wake_function(wait_queue_t *wait, unsigned mode, int sy=
nc, void *key);
 int wake_bit_function(wait_queue_t *wait, unsigned mode, int sync, voi=
d *key);
=20
-#define DEFINE_WAIT(name)						\
+#define DEFINE_WAIT_FUNC(name, function)				\
 	wait_queue_t name =3D {						\
 		.private	=3D current,				\
-		.func		=3D autoremove_wake_function,		\
+		.func		=3D function,				\
 		.task_list	=3D LIST_HEAD_INIT((name).task_list),	\
 	}
=20
+#define DEFINE_WAIT(name) DEFINE_WAIT_FUNC(name, autoremove_wake_funct=
ion)
+
 #define DEFINE_WAIT_BIT(name, word, bit)				\
 	struct wait_bit_queue name =3D {					\
 		.key =3D __WAIT_BIT_KEY_INITIALIZER(word, bit),		\
diff --git a/net/core/datagram.c b/net/core/datagram.c
index d0de644..b7960a3 100644
--- a/net/core/datagram.c
+++ b/net/core/datagram.c
@@ -64,13 +64,25 @@ static inline int connection_based(struct sock *sk)
 	return sk->sk_type =3D=3D SOCK_SEQPACKET || sk->sk_type =3D=3D SOCK_S=
TREAM;
 }
=20
+static int receiver_wake_function(wait_queue_t *wait, unsigned mode, i=
nt sync,
+				  void *key)
+{
+	unsigned long bits =3D (unsigned long)key;
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
=20
 	prepare_to_wait_exclusive(sk->sk_sleep, &wait, TASK_INTERRUPTIBLE);
=20
