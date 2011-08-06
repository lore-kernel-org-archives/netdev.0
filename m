From: Tejun Heo <tj@kernel.org>
Subject: [EXAMPLE CODE] Parasite thread injection and TCP connection hijacking
Date: Sat, 6 Aug 2011 14:12:47 +0200
Message-ID: <20110806121247.GC23937@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="9amGYk9869ThD9tj"
Cc: "James E.J. Bottomley" <JBottomley@parallels.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Matt Helsley <matthltc@us.ibm.com>,
	Pavel Emelyanov <xemul@parallels.com>,
	Nathan Lynch <ntl@pobox.com>,
	Oren Laadan <orenl@cs.columbia.edu>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	S
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:58292 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753882Ab1HFMMy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Aug 2011 08:12:54 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--9amGYk9869ThD9tj
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hello, guys.

So, here's transparent TCP connection hijacking (ie. checkpointing in
one process and restoring in another) which adds only relatively small
pieces to the kernel.  It's by no means complete but already works
rather reliably in my test setup even with heavy delay induced with
tc.

I wrote a rather long README describing how it's working, what's
missing which is appended at the end of this mail so if you're
interested in the details please go ahead and read.

Several ioctls are added to enable TCP connection CR, which adds
around 130 lines of code.  Note that the interface is ugly.  As said
above, it's proof-of-concept.  We'll need a bit more information
exported and knobs to turn and hopefully prettier interface.

As my knowledge of networking is fairly rudimentary, I only tried to
get the basics working.  e.g. I didn't try to store negotiated options
and re-establish them on restoration (ie. window scaling, mss, various
extra features), and am likely to have made wrong assumptions even on
the basics.  If you spot some, please shout.

The source is available in the following git branch (just git clone
from the URL)

  https://htejun@code.google.com/p/ptrace-parasite/

and can be browsed at

  http://code.google.com/p/ptrace-parasite/source/browse/

I'm attaching the tcp-ioctls.patch and the source tarball.

Thanks.

--
tejun


Parasite thread injection and TCP connection hijacking example code
===================================================================

This example code is for linux >= 3.1-rc1 on x86_64.

The goal is to demonstrate the followings.

* Transparent injection of a thread into the target process using new
  ptrace commands - PTRACE_SEIZE and INTERRUPT.

* Using the injected thread to capture a TCP connection and restoring
  it in another process.

Both are primarily to serve as the start point for mostly userland
checkpoint-restart implementation.  The latter is likely to be of
interest to virtual server farms and high availability too.

The code contained here is by no means ready for production.  It's
more of proof-of-concept; however, I'll try to document the missing
pieces here and in the comments.


Organization
============

The following files are for the executable 'parasite'.

 main.c		The bulk of the example program which seizes target
		process, inject parasite and sequence it to hijack TCP
		connection.

 parasite.c	Self contained code which is compiled as PIC and
		injected into target process.  Parasite thread
		executes this code.

 parasite.h	Included by both main.c and parasite.c.  Defines
		protocol used between the main program and injected
		parasite thread.

 syscall.h	Syscall interface used by parasite.c.

 setup-nfqueue	Helper script to setup iptables rules to send packets
		for a specified connection to nfqueue.  Don't mix with
		working firewall setup.  Invoked by the executable
		while hijacking TCP connection and assumed to be in
		the same directory.

 flush-nfqueue	Naive script to reverse setup-nfqueue.  It just clears
		INPUT and OUTPUT tables.  Again, don't mix with
		working firewall setup.  Invoked by the executable
		while hijacking TCP connection and assumed to be in
		the same directory.

Build procedure is a bit unusual.  parasite.c is compiled as PIC,
linked into raw binary parasite.bin using parasite.lds and hexdumped
into C array 'char parasite_blob[]' in parasite-blob.h.  main.c
includes this file and the final executable embeds the parasite blob
in it.

The followings are example programs to serve as host to inject
parasite into.

 simple-host.c	Simple pthread program.  Five threads print out
		heartbeat messages each second.  Has simple SIGUSR1/2
		handler for signal testing.

 net-host.c	TCP connection test program.  Depending on parameter,
		it either listens for connection or connects as
		directed.  Once connection is established, both
		parties keep sending incrementing uint64_t and verify
		that received data is incrementing uint64_t's.

		Has bandwidth throttling on the receiver side.  This
		ensures that both local rx and remote tx queues are
		populated.

		SIGUSR1 injects uint64_t which isn't part of the
		sequence which will be detected and reported by the
		remote side.  This can be used for verification and
		measuring send(2) to recv(2) latency.

		SIGUSR2 tests SIOCGOUTSEQS and SIOCPEEKOUTQ.  Just
		added to verify kernel features.

tcp-ioctls.patch is a patch to implement extra TCP ioctls for
connection hijacking.  This will be discussed further later.
Applicable to kernel 3.1-rc1.


Parasite thread injection
=========================

ptrace provides access to full process memory space and register
states, so it could always have manipulated the tracee however it
pleased including making it executing arbitrary code.  Unfortunately,
the previously existing commands depended on signals to interrupt the
tracee and interaction with job control was both poorly designed and
implemented.  This meant that although ptrace could be used to inject
arbitrary code into tracee, it couldn't do that without affecting
signal and job control states.

Broken parts of ptrace have been fixed and three new ptrace requests
are available from kernel 3.1 under development flag (which is
scheduled to be removed from 3.2) - PTRACE_SEIZE, INTERRUPT and
LISTEN.  These new requests allow transparent monitoring and
manipulation of tracee.  Note that transparency is not absolute in the
sense that ptrace operations would behave as signal delivery attempt
which can affect execution of certain system calls; however, userland
is already mandated to handle the condition regardless of ptrace and
albeit not absolute it still is complete in the scope defined by the
API.

Once all threads of the target process are seized, tracer can execute
arbitrary code using the following sequence.

1. PTRACE_SEIZE and INTERRUPT all threads belonging to the target
   process.  This is implemented in main.c::seize_process().  As noted
   in the source, the implementation isn't complete.  Proper
   implementation requires verification and retries in case thread
   creations and/or destructions race against seizing.

   Once INTERRUPT is issued, tracee either stops at job control trap
   or in exec path.  If tracee is about to exec, there isn't much to
   do anyway, so the example code simply aborts in such cases.

   From now on, all operations are assumed to be performed on one of
   the threads (any thread will do).

2. Decide where to inject the foreign code and save the original code
   with PTRACE_PEEKDATA.  Tracer can poke any mapped area regardless
   of protection flags but it can't add execution permission to the
   code, so it needs to choose memory area which already has X flag
   set.  The example code uses the page the %rip is in.

   To allow synchronization, the foreign code raises debug trap (int3)
   after execution finishes.

3. Inject the foreign code using PTRACE_POKEDATA.  The foreign code
   would usually have to be position independent and self-contained.

   Note that this page will be modified with PTRACE_POKEDATA is likely
   to trigger COW.  If a process is to be manipulated multiple times,
   it might be beneficial to use the same page every time.

4. Acquire and save the current register states using PTRACE_GETREGS
   and modify the register states for execution with PTRACE_SETREGS.
   Among others, %rip should point to the start address of the
   injected code and %orig_rax should be set to -1 to avoid
   end-of-syscall processing while returning to userland (register
   state will be restored later and end-of-syscall processing should
   happen after that).

5. Issue PTRACE_CONT to let the tracee return to userland and execute
   the injected code.  Tracer wait(2)s for tracee to enter stop state.
   Only two things can happen - signal delivery or end of execution
   notification via int3.

   Signal delivery either changes job control stop state, kills the
   process or schedules userland signal handler.  Nothing special to
   do about the first two.  For userland signal handler scheduling,
   issuing PTRACE_INTERRUPT before telling tracee to deliver signal
   with PTRACE_CONT makes tracee to re-trap after userland signal
   handler is scheduled without actually executing any userland code.
   Once scheduling is complete, retry from #4.

   After successful execution, tracee would be trapped indicating
   SIGTRAP delivery.  Squash it and put tracee back into job control
   trap by first issuing PTRACE_INTERRUPT followed by PTRACE_CONT.

   This step is implemented in execute_blob().

6. Restore saved registers and memory, and PTRACE_DETACH from all
   threads.

As arbitrary syscall can be issued using injected code, it isn't
difficult to inject larger chunk of code and create a parasite thread
on it.  The example code blocks all signals, uses mmap to allocate
memory, fill it with parasite_blob[], creates the parasite thread
using clone(2) and let it execute the injected code.


EXECUTION EXAMPLE

Running simple-host in a session first and parasite on another yields
the following outputs.  The alphabets in the first column are
referenced below to explain what's going on.

  # ./simple-host
  thread 01(1330): alive
  thread 02(1331): alive
  thread 03(1332): alive
  thread 04(1333): alive
  thread 00(1329): alive
A BLOB: hello, world!
B PARASITE STARTED
C PARASITE SAY: ah ah! mic test!
  thread 01(1330): alive
  thread 02(1331): alive
  thread 03(1332): alive
  thread 00(1329): alive
  ...

  # parasite `pidof simple-host`
  Seizing 1329
  Seizing 1330
  Seizing 1331
  Seizing 1332
  Seizing 1333
A executing test blob
  blocking all signals = 0, prev_sigmask 0
  executing mmap blob = 0x7f16f3024000
  executing clone blob = 1336
B executing parasite
C waiting for connection... connected
  executing munmap blob = 0
  restoring sigmask = 0, prev_sigmask 0xfffffffffffbfeef

On <A>, simple test code blob which says hi to world is injected into
the host and executed by one of the host threads to verify blob
execution works.

A series of blobs are executed afterwards to prepare for thread
injection.  The parasite thread is created in the host and released
for execution on <B>.  The first thing it does is printing out STARTED
message.

After that the injected thread connects back to the main 'parasite'
program using a TCP connection, at which point it's directed to print
out mic test message via SAY command.  This is happening on <C>.

After that, the prep steps are reversed and the target process is
released to continue normal execution.

Job control and USR signals directed at the target process should
behave as expected (sans the extra latency introduced by parasite) no
matter when they are generated.


TCP connection hijacking
========================

This part is much less complete and really a proof-of-concept.  The
goal is to show that TCP connection can be checkpointed in one process
and restored in another with only small additions to the networking
stack.  This also demonstrates that, with parasite threads, most
information is already available to checkpointer and adding mechanisms
to extract and manipulate more states can be done in very
non-obtrusive manner by extending existing API.  There's no new
security, locking or visibility boundary issues.

Note that CR in many cases wouldn't need this transparent snapshotting
of TCP connections.  For example, when CRing whole distributed HPC
workload, there's no reason to maintain TCP details which aren't
visible to applications at all.  Checkpointing threads injected to
both ends can simply drain the connection using recv(2) and restore
them by opening a new connection and repopulating the send buffer on
the other side with send(2).  DMTCP already uses this method to CR TCP
connections.

In general, unless the target connection is going to be terminated
from the target process and restored somewhere else immediately
(connection migration), there is little point in saving and restoring
TCP details including send and receive buffers as they become invalid
as soon as the target process exchanges further packets with the peer
after the checkpointing, and, if the peer is being checkpointed
together, draining and repopulating from each end point as described
above is far better and simpler.

With the above said, the basic states of a TCP connection can be
checkpointed and restarted with the following extra ioctls.  Note that
these ioctls should be considered as proof-of-concept.

 SIOCGINSEQ	Determine TCP sequence to be read on the next
		recv(2) - ie. tp->copied_seq.

 SIOCGOUTSEQS	Determine TCP sequences scheduled for transmission in
		reverse order.  ie. If the seq after SYN was 6, and
		20, 30 and 40 byte packets are in the tx queue without
		receiving any ack, it would return 96, 56, 26 and 6.

 SIOCSOUTSEQ	Set initial TCP sequence to use when establishing a
		connection.  Only valid on a not-yet-connected or
		listening socket.  The next connection established
		will start with the specified sequence.

 SIOCPEEKOUTQ	Peek the content of tx queue.

 SIOCFORCEOUTBD	Force packet separation on the next send(2).
		ie. data from the next send(2) won't be merged into
		the same packet with currently queued data.

A TCP connection can be snapshotted using the following sequence.

s1. Seize target process and inject a parasite thread.

s2. Acquire basic target socket information - IPs and ports.

s3. Block both incoming and outgoing packets belonging to the
    connection.

s4. Acquire rx queue information - the sequence number of the next
    byte to be read and the content of recv buffer.  The former is
    available through SIOCGINSEQ and the latter with recvmsg(2) w/
    MSG_PEEK.

s5. Acquire tx queue information - the sequence numbers of all pending
    packets and the content of send buffer.  The former is available
    through SIOCGOUTSEQS and the latter SIOCPEEKOUTQ.

None of the above steps has irreversible side effect and the
connection can be safely resumed.  To restore the connection, the
following steps can be used.

r1. Packets for the connection are still blocked from s3.  Create a
    way to intercept those packets and inject packets - nf_queue works
    for the former and raw socket for the latter.  It should drop all
    packets other than the ones injected via raw socket.

r2. Create a TCP socket, set outgoing sequence with SIOCSOUTSEQ so
    that it matches the sequence number at the head of the stored send
    queue, and initiate connection.

r3. Upon intercepting SYN, inject SYN/ACK with the sequence number
    matching the head of the stored rx queue.

r4. Upon intercepting ACK reply for SYN/ACK, repopulate the rx queue
    from the stored copy by injecting data packets and waiting for
    ACKs.

r5. Repopulate tx queue with send(2) with interleaving SIOCFORCEOUTBD
    calls to preserve the original packet boundaries.

r6. Connection is ready now.  Let the packets pass through.

The following points are worth mentioning regarding the above
sequences.

* As long as queue information is acquired after packets are blocked,
  there's no danger of data loss due to race condition on both rx and
  tx queues.  If data is received after rx queue is stored, the ack
  wouldn't reach the peer, so it will be retransmitted.  If ack is
  received after tx queue is stored, it just has extra data which will
  be acked and discarded again later.

* Both recv and send buffers need to be blown up before repopulating
  them with stored data.  SO_RCV/SNDBUFFORCE are used for this which
  disabled automatic buffer sizing.  It would be nice if there's a way
  to tell the TCP stack to resume auto resizing afterwards.

* Packet boundaries in tx queue need to be preserved, at least between
  the tx queue head and tp->snd_nxt.  This is because queue
  restoration can result in different packet division and if the peer
  already had received some of the packets before, stream can't be
  resumed with sequences falling inside existing packets.  Note that
  having more divisions is fine as long as the original boundaries are
  still there.

* Another subtlety with tx queue is that the TCP socket needs to
  think that all packets which were transmitted by the original
  connection are already transmitted before the packet barrier comes
  down - ie. its tp->snd_nxt needs to be the same as or after the
  original tp->snd_nxt; otherwise, it might end up ignoring ACKs
  stalling the connection.

  This currently is achieved by advertising maximum window on injected
  response packets so that the TCP socket sends out all queued data
  immediately.  If this isn't a guaranteed behavior, it would make
  sense to provide a way to manipulate tp->snd_nxt.

* The above sequence makes the new socket connect(2) but it would be
  better to reverse the direction to enable restoring server
  connections with N:1 port mapping.

Note that the implemented example code is incomplete in the following
aspects.

* No URG handling.  As OOB data can be acquired inline with other
  data.  Adding a mechanism to export URG offset from the tail of
  queue should be enough.

* Assumes ESTABLISHED.  Proof-of-concept! I get to be lazy! :P

* Doesn't handle options properly during connection negotiation.  I
  was being lazy but also at the same time am not a network expert and
  can't tell which ones should do what.  Needs more trained eyes here.

* Connection faking isn't robust at all.  Again, needs more work and
  some love from network gurus.

* No IPv6.


EXECUTION EXAMPLE

Incomplete as it may be, the example implementation actually works
rather reliably.  The parasite needs to be run as root as it uses
SO_RCV/SNDBUFFORCE and executes setup-nfqueue and flush-nfqueue
scripts which manipulate netfilter tables (don't run it on your
production machine with working firewall).  Also, it assumes that the
peer of the target TCP connection is on a remote machine and only
packets injected via raw socket pass through the loopback device.

Two instances of net-host keep talking to each other on 10.7.7.1 and
10.7.8.1 verifying received stream is sequence of incrementing
uint64_t's.  We want to hijack the socket from the net-host instance
on 10.7.8.1 and splice ourselves inside the connection so that the end
result looks like the following.

 net-host on 10.7.7.1 <---> parasite on 10.7.8.1 <---> net-host on 10.7.8.1

On 10.7.7.1,

  # ./net-host 9999 1024
A Connected to 10.7.8.2:40986
H signal 10 si_code=0
  inserting contaminant @0x22f682
G foreign data @0x2a7500 : 0xdeadbeefbeefdead

On 10.7.8.1,

  # ./net-host 10.7.7.1:9999 1024
A Connected to 10.7.7.1:9999
  BLOB: hello, world!
  PARASITE STARTED
B PARASITE SAY: ah ah! mic test!
H foreign data @0x22f682 : 0xdeadbeefbeefdead
G signal 10 si_code=0
  inserting contaminant @0x2a7500

On a different session on 10.7.8.1,

  # ls -l /proc/`pidof net-host`/fd
  total 0
  lrwx------ 1 root root 64 Aug  6 12:45 0 -> /dev/ttyS0
  lrwx------ 1 root root 64 Aug  6 12:45 1 -> /dev/ttyS0
  lrwx------ 1 root root 64 Aug  6 12:45 2 -> /dev/ttyS0
  lrwx------ 1 root root 64 Aug  6 12:45 3 -> socket:[12199]
A # ./parasite `pidof net-host` 3
  Seizing 1388
  Seizing 1389
  executing test blob
  blocking all signals = 0, prev_sigmask 0
  executing mmap blob = 0x7fa1e7caa000
  executing clone blob = 1397
  executing parasite
B waiting for connection... connected
  target socket: 10.7.8.2:40986 -> 10.7.7.1:9999 in 65392@0x185a3439 out 31856@0xb0e08180
C peeked socket buffer in 65392 out 26064
  executing munmap blob = 0
  restoring sigmask = 0, prev_sigmask 0xfffffffffffbfeef
D restoring connection, connecting...
  pkt: R->L S 185b33a9 A b0e02158 D 00000 a___ DROP
  pkt: R->L S 185b33a9 A b0e02158 D 00000 a___ DROP
  pkt: L->R S b0e02158 A 185b33a9 D 00000 a__r DROP
  pkt: L->R S b0e01baf A 00000000 D 00000 _s__ DROP DONE
  got SYN, replying with SYN/ACK
  pkt: R->L S 185a3438 A b0e01bb0 D 00000 as__ ACPT
  pkt: L->R S b0e01bb0 A 185a3439 D 00000 a___ DROP DONE
  connection established, repopulating rx/tx queues
E pkt: R->L S 185a3439 A b0e01bb0 D 01360 a___ ACPT
  pkt: L->R S b0e01bb0 A 185a3989 D 00000 a___ DROP DONE
  pkt: R->L S 185a3989 A b0e01bb0 D 01360 a___ ACPT
  pkt: L->R S b0e01bb0 A 185a3ed9 D 00000 a___ DROP DONE
  ...
  pkt: R->L S 185b3339 A b0e01bb0 D 00112 a___ ACPT
  pkt: L->R S b0e01bb0 A 185b33a9 D 00000 a___ DROP DONE
F snd: ---- S b0e01bb0 A -------- D 00000
  snd: ---- S b0e01bb0 A -------- D 01448
  ...
  snd: ---- S b0e07bd8 A -------- D 01448
G connection restored
  pkt: L->R S b0e01bb0 A 185b33a9 D 01448 a___ ACPT
  pkt: L->R S b0e02158 A 185b33a9 D 01448 a___ ACPT
  ...
  pkt: L->R S b0e04e98 A 185b33a9 D 01448 a___ ACPT
  pkt: R->L S 185b3629 A b0e02158 D 00000 a___ ACPT
  pkt: R->L S 185b3629 A b0e02700 D 00000 a___ ACPT
  ...
  pkt: R->L S 185b3629 A b0e05440 D 00000 a___ ACPT

On yet another session on 10.7.7.1,

H # killall -USR1 net-host

On yet another session on 10.7.8.1,

G # killall -USR1 net-host

<A> Two net-host instances are connected to each other sending and
    verifying each other's stream.  From /proc the socket fd is
    determined to be 3 and parasite is executed to hijack the socket.

<B> Upto this point, it's the same as the previous thread injection
    example.  Parasite thread is injected and test command is
    executed.

<C> Snapshot steps s3 - s5 are executed and the fd 3 is dupped over by
    a connection to the main program.  This means on 10.7.8.1, the
    connection doesn't exist anymore; however, 10.7.7.1 doesn't know
    this as packets belonging to the connection are being dropped.

<D> Restoration steps r1 - r3 are executed.

<E> rx queue is being repopulated.

<F> tx queue is being repopulated.

<G> Connection restored and the main parasite program now owns the
    original connection to net-host on 10.7.7.1 and a new connection
    to net-host on 10.7.8.1.  It pipes data between the two.

<H> Verify data is still flowing by triggering net-host on 10.7.7.1 to
    insert foreign data in the stream, which is soon received by
    net-host on 10.7.8.1.

<G> Vice-versa from 10.7.8.1 to 10.7.7.1.


NOTES

* As said above, the ioctls are only proof-of-concept.  We'll probably
  need more information exported and maybe a few more ways to
  manipulate the states.  As long as the state manipulations stay out
  of usual stream processing - ie. they only affect connection setup,
  I don't think the added complexity or maintenance overhead would be
  noticeable.

* Having socket inode # match in iptables would solve the packet
  matching problem.  Note that even on a busy system, this connection
  intervention shouldn't add much overhead.  While not snapshotting,
  no firewall rule is needed.  During snapshotting, only packets of
  the target connections are ipqueue'd and ipset can match many
  connections without much overhead.

* While writing, I had more things I wanted to talk about in this
  section but apparently forgot them. :( I'll add as they come back.

--9amGYk9869ThD9tj
Content-Type: application/x-gzip
Content-Disposition: attachment; filename="parasite-20110806.tar.gz"
Content-Transfer-Encoding: base64

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
AGgBAA==

--9amGYk9869ThD9tj
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="tcp-ioctls.patch"

 include/linux/sockios.h |    6 ++
 include/linux/tcp.h     |    2 
 net/ipv4/tcp.c          |  113 +++++++++++++++++++++++++++++++++++++++++++++++-
 net/ipv4/tcp_ipv4.c     |   16 ++++--
 4 files changed, 130 insertions(+), 7 deletions(-)

diff --git a/include/linux/sockios.h b/include/linux/sockios.h
index 7997a50..f5c3e41 100644
--- a/include/linux/sockios.h
+++ b/include/linux/sockios.h
@@ -127,6 +127,12 @@
 /* hardware time stamping: parameters in linux/net_tstamp.h */
 #define SIOCSHWTSTAMP   0x89b0
 
+#define SIOCGINSEQ	0x89b1		/* get copied_seq */
+#define SIOCGOUTSEQS	0x89b2		/* get seqs for pending tx pkts */
+#define SIOCSOUTSEQ	0x89b3		/* set write_seq */
+#define SIOCPEEKOUTQ	0x89b4		/* peek output queue */
+#define SIOCFORCEOUTBD	0x89b5		/* force output packet boundary */
+
 /* Device private ioctl calls */
 
 /*
diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 531ede8..c0945fe 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -365,6 +365,8 @@ struct tcp_sock {
 	u32	snd_up;		/* Urgent pointer		*/
 
 	u8	keepalive_probes; /* num of allowed keep alive probes	*/
+	u8	wseq_set    : 1;/* Write sequence set via setsockopt	*/
+	u8	force_outbd : 1;/* force packet boundary on next send	*/
 /*
  *      Options received (usually on last packet, some only on SYN packets).
  */
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 46febca..3389827 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -464,12 +464,118 @@ unsigned int tcp_poll(struct file *file, struct socket *sock, poll_table *wait)
 }
 EXPORT_SYMBOL(tcp_poll);
 
+static int tcp_get_out_seqs(struct sock *sk, u32 __user *p, int size)
+{
+	struct tcp_sock *tp = tcp_sk(sk);
+	struct sk_buff *skb;
+	int pos = 0, cnt = size / sizeof(u32);
+
+	if (pos < cnt && put_user(tp->write_seq, &p[pos++]))
+		return -EFAULT;
+
+	skb_queue_reverse_walk(&sk->sk_write_queue, skb) {
+		struct tcp_skb_cb *tcb = TCP_SKB_CB(skb);
+
+		if (pos < cnt && put_user(tcb->seq, &p[pos++]))
+			return -EFAULT;
+	}
+	return pos * sizeof(u32);
+}
+
+static int tcp_peek_outq(struct sock *sk, void __user *arg, int size)
+{
+	struct tcp_sock *tp = tcp_sk(sk);
+	struct iovec iov = { .iov_base = arg, .iov_len = size };
+	struct sk_buff *skb;
+	int copied = 0, err = 0;
+	int outq, skip;
+
+	lock_sock(sk);
+
+	/* XXX: why doesn't SIOCOUTQ[NSD] account for queued fin? */
+	outq = tp->write_seq - tp->snd_una;
+	skb = skb_peek_tail(&sk->sk_write_queue);
+	if (outq && skb)
+		outq -= tcp_hdr(skb)->fin;
+
+	skip = outq - min(size, outq);
+
+	skb_queue_walk(&sk->sk_write_queue, skb) {
+		int off = 0, todo;
+
+		if (skip) {
+			off = min_t(int, skip, skb->len);
+			skip -= off;
+		}
+
+		if (!(todo = skb->len - off))
+			continue;
+
+		if (WARN_ON_ONCE(iov.iov_len < todo)) {
+			err = -EINVAL;
+			break;
+		}
+
+		err = skb_copy_datagram_iovec(skb, off, &iov, todo);
+		if (err)
+			break;
+		copied += todo;
+	}
+
+	release_sock(sk);
+
+	return err ?: copied;
+}
+
 int tcp_ioctl(struct sock *sk, int cmd, unsigned long arg)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	int answ;
 
 	switch (cmd) {
+	case SIOCGOUTSEQS: {
+		s32 size;
+
+		if (get_user(size, (s32 __user *)arg))
+			return -EFAULT;
+		if (size < 0)
+			return -EINVAL;
+		return tcp_get_out_seqs(sk, (u32 __user *)arg, size);
+	}
+	case SIOCSOUTSEQ: {
+		u32 seq;
+
+		if (get_user(seq, (u32 __user *)arg))
+			return -EFAULT;
+
+		lock_sock(sk);
+		answ = -EISCONN;
+		if ((sk->sk_socket->state == SS_UNCONNECTED &&
+		     sk->sk_state == TCP_CLOSE) || sk->sk_state == TCP_LISTEN) {
+			tp->write_seq = seq;
+			tp->wseq_set = true;
+			answ = 0;
+		}
+		release_sock(sk);
+		return answ;
+	}
+	case SIOCPEEKOUTQ: {
+		u32 size;
+
+		if (get_user(size, (u32 __user *)arg))
+			return -EFAULT;
+		if ((int)size < size)
+			return -EINVAL;
+		return tcp_peek_outq(sk, (void __user *)arg, size);
+	}
+	case SIOCFORCEOUTBD:
+		lock_sock(sk);
+		tp->force_outbd = true;
+		release_sock(sk);
+		return 0;
+	}
+
+	switch (cmd) {
 	case SIOCINQ:
 		if (sk->sk_state == TCP_LISTEN)
 			return -EINVAL;
@@ -514,6 +620,9 @@ int tcp_ioctl(struct sock *sk, int cmd, unsigned long arg)
 		else
 			answ = tp->write_seq - tp->snd_nxt;
 		break;
+	case SIOCGINSEQ:
+		answ = tp->copied_seq;
+		break;
 	default:
 		return -ENOIOCTLCMD;
 	}
@@ -965,7 +1074,7 @@ int tcp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 				copy = max - skb->len;
 			}
 
-			if (copy <= 0) {
+			if (copy <= 0 || unlikely(tp->force_outbd)) {
 new_segment:
 				/* Allocate new segment. If the interface is SG,
 				 * allocate skb fitting to single page.
@@ -979,6 +1088,8 @@ new_segment:
 				if (!skb)
 					goto wait_for_memory;
 
+				tp->force_outbd = false;
+
 				/*
 				 * Check whether we can use HW checksum.
 				 */
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 955b8e6..579234c 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -201,7 +201,8 @@ int tcp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 		/* Reset inherited state */
 		tp->rx_opt.ts_recent	   = 0;
 		tp->rx_opt.ts_recent_stamp = 0;
-		tp->write_seq		   = 0;
+		if (!tp->wseq_set)
+			tp->write_seq      = 0;
 	}
 
 	if (tcp_death_row.sysctl_tw_recycle &&
@@ -252,12 +253,12 @@ int tcp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 	sk->sk_gso_type = SKB_GSO_TCPV4;
 	sk_setup_caps(sk, &rt->dst);
 
-	if (!tp->write_seq)
+	if (!tp->write_seq && !tp->wseq_set)
 		tp->write_seq = secure_tcp_sequence_number(inet->inet_saddr,
 							   inet->inet_daddr,
 							   inet->inet_sport,
 							   usin->sin_port);
-
+	tp->wseq_set = false;
 	inet->inet_id = tp->write_seq ^ jiffies;
 
 	err = tcp_connect(sk);
@@ -1252,7 +1253,7 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 		if (net_ratelimit())
 			syn_flood_warning(skb);
 #ifdef CONFIG_SYN_COOKIES
-		if (sysctl_tcp_syncookies) {
+		if (sysctl_tcp_syncookies && !tp->wseq_set) {
 			want_cookie = 1;
 		} else
 #endif
@@ -1334,7 +1335,10 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 	if (!want_cookie || tmp_opt.tstamp_ok)
 		TCP_ECN_create_request(req, tcp_hdr(skb));
 
-	if (want_cookie) {
+	if (unlikely(tp->wseq_set)) {
+		isn = tp->write_seq;
+		tp->wseq_set = false;
+	} else if (want_cookie) {
 		isn = cookie_v4_init_sequence(sk, skb, &req->mss);
 		req->cookie_ts = tmp_opt.tstamp_ok;
 	} else if (!isn) {
@@ -1526,7 +1530,7 @@ static struct sock *tcp_v4_hnd_req(struct sock *sk, struct sk_buff *skb)
 	}
 
 #ifdef CONFIG_SYN_COOKIES
-	if (!th->syn)
+	if (!th->syn && !tcp_sk(sk)->wseq_set)
 		sk = cookie_v4_check(sk, skb, &(IPCB(skb)->opt));
 #endif
 	return sk;

--9amGYk9869ThD9tj--
