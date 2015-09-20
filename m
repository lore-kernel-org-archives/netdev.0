From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH RFC 0/3] kcm: Kernel Connection Multiplexor (KCM)
Date: Sun, 20 Sep 2015 15:29:18 -0700
Message-ID: <1442788161-2626305-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:47002 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751876AbbITWbB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Sep 2015 18:31:01 -0400
Received: from pps.filterd (m0044010 [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t8KMTu3C006939
	for <netdev@vger.kernel.org>; Sun, 20 Sep 2015 15:31:00 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 1x1xv1sfqs-2
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Sun, 20 Sep 2015 15:31:00 -0700
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.212.232.63) with ESMTP	id
 43e92aa25fe711e5975c0002c992ebde-78dfd240 for <netdev@vger.kernel.org>;	Sun,
 20 Sep 2015 15:30:58 -0700
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

Testing:

For testing I have been developing kcmperf and super_kcmperf which
should allow functional verification and some baseline comparisons
with netperf using TCP. For the test results listed below, one
instance of kcmperf is run which creates a trivial MUX with one KCM
socket and one attached TCP connection.

netperf TCP_RR
   - 1 instance, 1 byte RR size
     34219 tps

   - 1 instance, 1000000 byte RR size
     464 tps

   - 200 instances, 1 byte RR size
     1721552 tps
     86.86% CPU utilization

   - 200 instances, 1000000 byte RR size
     1165
     7.16% CPU utilization

kcmperf
   - 1 instance, byte RR size
     32679 tps

   - 1 instance, byte RR size
     412 tps

   - 200 instances, 1 byte RR size
     1420454 tps
     80.02% CPU utilization 

   - 200 instances, 1000000 byte RR size
     1130 tps
     10.08% CPU utilization

Future support:

The implementation provided here should be thought of as a first cut,
for which the goal is to establish a robust base implementation. There
are many avenues for extending this basic implementation and improving
upon this:

 - Sample application support
 - SOCK_SEQPACKET support
 - Integration with TLS (TLS-in-kernel is a separate intiative).
 - Page operations/splice support
 - sendmmsg, recvmmsg support
 - Unconnected KCM sockets. Will be able to attach sockets to different
   destinations, AF_KCM addresses with be used in sendmsg and recvmsg
   to indicate destination
 - Explore more utility in performing BPF inline with a TCP data stream
   (setting SO_MARK, rxhash for messages being sent received on
   KCM sockets).
 - Performance work
   - Reduce locking (MUX lock is currently a bottleneck).
   - KCM socket to TCP socket affinity
   - Small message coalescing, direct calls to TCP send functions

Tom Herbert (3):
  rcu: Add list_next_or_null_rcu
  kcm: Kernel Connection Multiplexor module
  kcm: Add statistics and proc interfaces

 Documentation/networking/kcm.txt |  173 ++++
 include/linux/rculist.h          |   21 +
 include/linux/socket.h           |    6 +-
 include/net/kcm.h                |  211 +++++
 include/uapi/linux/errqueue.h    |    1 +
 include/uapi/linux/kcm.h         |   26 +
 net/Kconfig                      |    1 +
 net/Makefile                     |    1 +
 net/kcm/Kconfig                  |   10 +
 net/kcm/Makefile                 |    3 +
 net/kcm/kcmproc.c                |  415 ++++++++++
 net/kcm/kcmsock.c                | 1629 ++++++++++++++++++++++++++++++++++++++
 12 files changed, 2496 insertions(+), 1 deletion(-)
 create mode 100644 Documentation/networking/kcm.txt
 create mode 100644 include/net/kcm.h
 create mode 100644 include/uapi/linux/kcm.h
 create mode 100644 net/kcm/Kconfig
 create mode 100644 net/kcm/Makefile
 create mode 100644 net/kcm/kcmproc.c
 create mode 100644 net/kcm/kcmsock.c

-- 
1.8.1
