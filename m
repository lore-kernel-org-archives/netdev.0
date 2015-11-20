From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next 0/6] kcm: Kernel Connection Multiplexor (KCM)
Date: Fri, 20 Nov 2015 13:21:54 -0800
Message-ID: <1448054520-1464587-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>, <davewatson@fb.com>,
	<alexei.starovoitov@gmail.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:60726 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760406AbbKTVWM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Nov 2015 16:22:12 -0500
Received: from pps.filterd (m0044008.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.15.0.59/8.15.0.59) with SMTP id tAKLIbCQ028177
	for <netdev@vger.kernel.org>; Fri, 20 Nov 2015 13:22:11 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 1y9us1bn2m-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 20 Nov 2015 13:22:11 -0800
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.223.101.97) with ESMTP	id
 c268dce68fcc11e5bc8d24be0595f910-165fb230 for <netdev@vger.kernel.org>;	Fri,
 20 Nov 2015 13:22:10 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kernel Connection Multiplexor (KCM) is a facility that provides a
message based interface over TCP for generic application protocols.
The motivation for this is based on the observation that although
TCP is byte stream transport protocol with no concept of message
boundaries, a common use case is to implement a framed application
layer protocol running over TCP. To date, most TCP stacks offer
byte stream API for applications, which places the burden of message
delineation, message I/O operation atomicity, and load balancing
in the application. With KCM an application can efficiently send
and receive application protocol messages over TCP using a
datagram interface.

In order to delineate message in a TCP stream for receive in KCM, the
kernel implements a message parser. For this we chose to employ BPF
which is applied to the TCP stream. BPF code parses application layer
messages and returns a message length. Nearly all binary application
protocols are parsable in this manner, so KCM should be applicable
across a wide range of applications. Other than message length
determination in receive, KCM does not require any other application
specific awareness. KCM does not implement any other application
protocol semantics-- these are are provided in userspace or could be
implemented in a kernel module layered above KCM.

KCM implements an NxM multiplexor in the kernel as diagrammed below:

+------------+   +------------+   +------------+   +------------+
| KCM socket |   | KCM socket |   | KCM socket |   | KCM socket |
+------------+   +------------+   +------------+   +------------+
      |                 |               |                |
      +-----------+     |               |     +----------+
                  |     |               |     |
               +----------------------------------+
               |           Multiplexor            |
               +----------------------------------+
                 |   |           |           |  |
       +---------+   |           |           |  ------------+
       |             |           |           |              |
+----------+  +----------+  +----------+  +----------+ +----------+
|  Psock   |  |  Psock   |  |  Psock   |  |  Psock   | |  Psock   |
+----------+  +----------+  +----------+  +----------+ +----------+
      |              |           |            |             |
+----------+  +----------+  +----------+  +----------+ +----------+
| TCP sock |  | TCP sock |  | TCP sock |  | TCP sock | | TCP sock |
+----------+  +----------+  +----------+  +----------+ +----------+

The KCM sockets provide the datagram interface to applications,
Psocks are the state for each attached TCP connection (i.e. where
message delineation is performed on receive).

A description of the APIs and design can be found in the included
Documentation/networking/kcm.txt.

In this patch set:

  - Add MSG_BATCH flag. This is used in sendmsg msg_hdr flags to
    indicate that more messages will be sent on the socket. The stack
    may batch messages up if it is beneficial for transmission.
  - In sendmmsg, set MSG_BATCH in all sub messages except for the last
    one.
  - In order to allow sendmmsg to contain multiple messages with
    SOCK_SEQPAKET we allow each msg_hdr in the sendmmsg to set MSG_EOR.
  - Add KCM module
    - This supports SOCK_DGRAM and SOCK_SEQPACKET.
  - KCM documentation

Testing:

Dave Watson has integrated KCM into Thrift and we intend to put these
changes into open source. Example of this is in:

https://github.com/djwatson/fbthrift/commit/
dd7e0f9cf4e80912fdb90f6cd394db24e61a14cc

Some initial KCM Thrift benchmark numbers (comment from Dave)

Thrift by default ties a single connection to a single thread.  KCM is
instead able to load balance multiple connections across multiple epoll
loops easily.

A test sending ~5k bytes of data to a kcm thrift server, dropping the
bytes on recv:

QPS     Latency / std dev Latency
  without KCM
    70336     209/123
  with KCM
    70353     191/124

A test sending a small request, then doing work in the epoll thread,
before serving more requests:

QPS     Latency / std dev Latency
without KCM
    14282     559/602
with KCM
    23192     344/234

At the high end, there's definitely some additional kernel overhead:

Cranking the pipelining way up, with lots of small requests

QPS     Latency / std dev Latency
without KCM
   1863429     127/119
with KCM
   1337713     192/241

---

So for a "realistic" workload, KCM performs pretty well (second case).
Under extreme conditions of highest tps we still have some work to do.
In its nature a multiplexor will spread work between CPUs which is
logically good for load balancing but coan conflict with the goal
promoting affinity. Batching messages on both send and receive are
the means to recoup performance.

Future support:

 - Integration with TLS (TLS-in-kernel is a separate initiative).
 - Page operations/splice support
 - Unconnected KCM sockets. Will be able to attach sockets to different
   destinations, AF_KCM addresses with be used in sendmsg and recvmsg
   to indicate destination
 - Explore more utility in performing BPF inline with a TCP data stream
   (setting SO_MARK, rxhash for messages being sent received on
   KCM sockets).
 - Performance work
   - Diagnose performance issues under high message load

FAQ (Questions posted on LWN)

Q: Why do this in the kernel?

A: Because the kernel is good at scheduling threads and steering packets
   to threads. KCM fits well into this model since it allows the unit
   of work for scheduling and steering to be the application layer
   messages themselves. KCM should be thought of as generic application
   protocol acceleration. It to the philosophy that the kernel provides
   generic and extensible interfaces.
   
Q: How can adding code in the path yield better performance?

A: It is true that for just sending receiving a single message there
   would be some performance loss since the code path is longer (for
   instance comparing netperf to KCM). But for real production
   applications performance takes on many dynamics. Parallelism, context
   switching, affinity, granularity of locking, and load balancing are
   all relevant. The theory of KCM is that by an application-centric
   interface, the kernel can provide better support for these
   performance characteristics.

Q: Why not use an existing message-oriented protocol such as RUDP,
   DCCP, SCTP, RDS, and others?

A: Because that would entail using a completely new transport protocol.
   Deploying a new protocol at scale is either a huge undertaking or
   fundamentally infeasible. This is true in either the Internet and in
   the data center due in a large part to protocol ossification.
   Besides, KCM we want KCM to work existing, well deployed application
   protocols that we couldn't change even if we wanted to (e.g. http/2).

   KCM simply defines a new interface method, it does not redefine any
   aspect of the transport protocol nor application protocol, nor set
   any new requirements on these. Neither does KCM attempt to implement
   any application protocol logic other than message deliniation in the
   stream. These are fundamental requirement of KCM.

Q: How does this affect TCP?

A: It doesn't, not in the slightest. The use of KCM can be one-sided,
   KCM has no effect on the wire.

Q: Why force TCP into doing something it's not designed for?

A: TCP is defined as transport protocol and there is no standard that
   says the API into TCP must be stream based sockets, or for that
   matter sockets at all (or even that TCP needs to be implemented in a
   kernel). KCM is not inconsistent with the design of TCP just because
   to makes an message based interface over TCP, if it were then every
   application protocol sending messages over TCP would also be! :-)

Q: What about the problem of a connections with very slow rate of
   incoming data? As a result your application can get storms of very
   short reads. And it actually happens a lot with connection from
   mobile devices and it is a problem for servers handling a lot of
   connections.

A: The storm of short reads will occur regardless of whether KCM is used
   or not. KCM does have one advantage in this scenario though, it will
   only wake up the application when a full message has been received,
   not for each packet that makes up part of a bigger messages. If a
   bunch of small messages are received, the application can receive
   messages in batches using recvmmsg.

Q: Why not just use DPDK, or at least provide KCM like functionality in
   DPDK?

A: DPDK, or more generally OS bypass presumably with a TCP stack in
   userland, presents a different model of load balancing than that of
   KCM (and the kernel). KCM implements load balancing of messages
   across the threads of an application, whereas DPDK load balances
   based on queues which are more static and coarse-grained since
   multiple connections are bound to queues. DPDK works best when
   processing of packets is silo'ed in a thread on the CPU processing
   a queue, and packet processing (for both the stack and application)
   is fairly uniform. KCM works well for applications where the amount
   of work to process messages varies an application work is commonly
   delegated to worker threads often on different CPUs.
 
   The message based interface over TCP is something that could be
   provide by a DPDK or OS bypass library.

Q: I'm not quite seeing this for HTTP. Maybe for HTTP/2, I guess, or web
   sockets?

A: Yes. KCM is most appropriate for message based protocols over TCP
   where is easy to deduce the message length (e.g. a length field)
   and the protocol implements its own message ordering semantics.
   Fortunately this encompasses many modern protocols.

Tom Herbert (6):
  rcu: Add list_next_or_null_rcu
  net: Make sock_alloc exportable
  net: Add MSG_BATCH flag
  kcm: Kernel Connection Multiplexor module
  kcm: Add statistics and proc interfaces
  kcm: Add description in Documentation

 Documentation/networking/kcm.txt |  273 +++++
 include/linux/net.h              |    1 +
 include/linux/rculist.h          |   21 +
 include/linux/socket.h           |    7 +-
 include/net/kcm.h                |  223 +++++
 include/uapi/linux/kcm.h         |   27 +
 net/Kconfig                      |    1 +
 net/Makefile                     |    1 +
 net/kcm/Kconfig                  |   10 +
 net/kcm/Makefile                 |    3 +
 net/kcm/kcmproc.c                |  422 ++++++++
 net/kcm/kcmsock.c                | 2040 ++++++++++++++++++++++++++++++++++++++
 net/socket.c                     |   20 +-
 13 files changed, 3043 insertions(+), 6 deletions(-)
 create mode 100644 Documentation/networking/kcm.txt
 create mode 100644 include/net/kcm.h
 create mode 100644 include/uapi/linux/kcm.h
 create mode 100644 net/kcm/Kconfig
 create mode 100644 net/kcm/Makefile
 create mode 100644 net/kcm/kcmproc.c
 create mode 100644 net/kcm/kcmsock.c

-- 
2.4.6
