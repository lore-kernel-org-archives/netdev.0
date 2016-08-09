From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH RESEND net-next 00/15] net/smc: Shared Memory Communications - RDMA
Date: Tue,  9 Aug 2016 12:12:45 +0200
Message-ID: <1470737580-43012-1-git-send-email-ubraun@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
	utz.bacher@de.ibm.com, ubraun@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:56747 "EHLO
	mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932164AbcHIKNL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Aug 2016 06:13:11 -0400
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u79A4S0S134232
	for <netdev@vger.kernel.org>; Tue, 9 Aug 2016 06:13:10 -0400
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0a-001b2d01.pphosted.com with ESMTP id 24nb6yhmh5-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 09 Aug 2016 06:13:10 -0400
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
	Tue, 9 Aug 2016 11:13:07 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ursula.braun@de.ibm.com>


Dave,

since our SMC-R patches still show up in state "Change Requested" on patchwork:
https://patchwork.ozlabs.org/project/netdev/list/?submitter=2266&state=*&page=1
even though we came up with your requested change in the cover letter,
we assume we should resend the whole patch series. Thus here is once more the
whole patch SMC-R patch series (updated cover letter, same code as posted
2016-06-03, just a few hunks resolved to adapt to the latest net-next kernel
version).

These patches are the initial part of the implementation of the
"Shared Memory Communications-RDMA" (SMC-R) protocol as defined in
RFC7609 [1]. While SMC-R does not aim to replace TCP,
it taps a wealth of existing data center TCP socket applications
to become more efficient without the need for rewriting them.
SMC-R uses RDMA over Converged Ethernet (RoCE) to save CPU consumption.
For instance, when running 10 parallel connections with uperf, we measured
a decrease of 60% in CPU consumption with SMC-R compared to TCP/IP
(with throughput and latency comparable;
measured on x86_64 with the same RoCE card and port).

SMC-R does not require an RDMA communication manager (RDMA CM).

SMC-R inherits TCP qualities such as reliable connections, host-based
firewall packet filtering (on connection establishment) and unmodified
application of communication encryption such as TLS (transport layer
security) or SSL (secure sockets layer). Since original TCP is used to
establish SMC-R connections, load balancers and packet inspection based
on TCP/IP connection establishment continue to work for SMC-R.

On the other hand, using SMC-R implies:
- either involving a preload library when invoking the unchanged TCP-application
  or slightly modifying the source by simply changing the socket family in
  the socket() call
- accepting extra overhead and latency in connection establishment due to
  SMC Connection Layer Control (CLC) handshake
- explicit coupling of RoCE ports with Ethernet ports
- not routable as currently built on RoCE V1
- bypassing of packet-based networking features
    - filtering (netfilter)
    - sniffing (libpcap, packet sockets, (E)BPF)
    - traffic control (scheduling, shaping)
- bypassing of IP-header based socket options
- bypassing of memory buffer (pressure) management
- unusable together with IPsec


Overview of the SMC-R Protocol described in informational RFC 7609

SMC-R is an open protocol that provides RDMA capabilities over RoCE
transparently for applications exploiting TCP sockets.
A new socket protocol family PF_SMC is introduced.
There are no changes required to applications using the sockets API for TCP
stream sockets other than the specification of the new socket family AF_SMC.
Unmodified applications can be used by means of a dynamic preload shared
library which rewrites the socket API call
socket(AF_INET, SOCK_STREAM, IPPROTO_TCP) into
socket(AF_SMC,  SOCK_STREAM, IPPROTO_TCP).
SMC-R re-uses the address family AF_INET for all addressing purposes around
struct sockaddr.


SMC-R system architecture layers:

+=============================================================================+
|                                      | unmodified TCP application           |
| native SMC application               +--------------------------------------+
|                                      | dynamic preload shared library       |
+=============================================================================+
|                                 SMC socket                                  |
+-----------------------------------------------------------------------------+
|                    | TCP socket (for connection establishment and fallback) |
| IB verbs           +--------------------------------------------------------+
|                    | IP                                                     |
+--------------------+--------------------------------------------------------+
| RoCE device driver | some network device driver                             |
+=============================================================================+


Terms:

A link group is determined by an ordered peer pair of TCP client and TCP server
(IP addresses and subnet). Reversed client server roles cause an own link group.
A link is a logical point-to-point connection based on an
infiniband reliable connected queue pair (RC-QP) between two RoCE ports
(MACs and GIDs) of a peer pair.
A link group can have 1..8 links for failover and load balancing.
This initial Linux implementation always has 1 link per link group.
Each link group on a peer can have 1..255 remote memory buffers (RMBs).
If more RMBs are needed, a peer can open another link group
(this initial Linux implementation) or fall back to TCP.
Each RMB has its own particular size and its own (R)DMA mapping and credentials
(rtoken consisting of rkey and RDMA "virtual address").
This initial Linux implementation uses physically contiguous memory for RMBs
but we are working towards scattered memory because of memory fragmentation.
Each RMB has 1..255 RMB elements (RMBEs) of equal size
to provide multiplexing of connections within an RMB.
An RMBE is the RDMA Write destination organized as wrapping ring buffer
for data transmit of a particular connection in one direction
(duplex by means of mirror symmetry as with TCP).
This initial Linux implementation always has 1 RMBE per RMB
and thus an individual RMB for each connection.


SMC-R connection establishment with subsequent data transfer:

   CLIENT                                                   SERVER

TCP three-way handshake:
                         regular TCP SYN
      -------------------------------------------------------->
                       regular TCP SYN ACK
      <--------------------------------------------------------
                         regular TCP ACK
      -------------------------------------------------------->

SMC Connection Layer Control (CLC) handshake
exchanges RDMA credentials between peers:
             via above TCP connection: SMC CLC Proposal
      -------------------------------------------------------->
              via above TCP connection: SMC CLC Accept
      <--------------------------------------------------------
             via above TCP connection: SMC CLC Confirm
      -------------------------------------------------------->

SMC Link Layer Control (LLC) (only once per link, i.e. 1st conn. of link group):
                 RoCE RC-QP: SMC LLC Confirm Link
      <========================================================
             RoCE RC-QP: SMC LLC Confirm Link response
      ========================================================>

SMC data transmission (incl. SMC Connection Data Control (CDC) message):
                       RoCE RC-QP: RDMA Write
      ========================================================>
             RoCE RC-QP: SMC CDC message (flow control)
      ========================================================>
                          ...

                       RoCE RC-QP: RDMA Write
      <========================================================
             RoCE RC-QP: SMC CDC message (flow control)
      <========================================================
                          ...


Data flow within an established connection:

+----------------------------------------------------------------------------
|            SENDER
| sendmsg()
|    |
|    | produces into sndbuf [sender's process context]
|    v
| +--------+
| | sndbuf | [ring buffer]
| +--------+
|    |
|    | consumes from sndbuf and produces into receiver's RMBE [any context]
|    | by sending RDMA Write followed by SMC CDC message over RoCE RC-QP
|    |
+----|-----------------------------------------------------------------------
     |
+----|-----------------------------------------------------------------------
|    v       RECEIVER
| +------+
| | RMBE | [ring buffer, can have size different from sender's sndbuf]
| |      | [RMBE represents rcvbuf, no further de-coupling as on sender side]
| +------+
|    |
|    | consumes from RMBE [receiver's process context]
|    v
| recvmsg()
+----------------------------------------------------------------------------


Flow control ("cursor" updates) by means of SMC CDC messages:

               SENDER                            RECEIVER

        sends updates via CDC-------------+   sends updates via CDC
        on consuming from sndbuf          |   on consuming from RMBE
        and producing into RMBE           |   by means of recvmsg()
                                          |            |
                                          |            |
      +-----------------------------------|------------+
      |                                   |
   +--v-------------------------+      +--v-----------------------+
   | receiver's consumer cursor |      | sender's producer cursor----+
   +----------------|-----------+      +--------------------------+  |
                    |                                                |
                    |                        receiver's RMBE         |
                    |                  +--------------------------+  |
                    |                  |                          |  |
                    +--------------------------------+            |  |
                                       |             |            |  |
                                       |             v            |  |
                                       |             +------------|  |
                                       |-------------+////////////|  |
                                       |//RDMA data written by////|  |
                                       |////sender that is////////|  |
                                       |/available to be consumed/|  |
                                       |///////// +---------------|  |
                                       |----------+^              |  |
                                       |           |              |  |
                                       |           +-----------------+
                                       |                          |
                                       +--------------------------+

Sending updates of the producer cursor is immediate for low latency;
something like Nagle's algorithm (absence of TCP_NODELAY) is optional and
currently not part of this initial Linux implementation.
Sending updates of the consumer cursor is conditional to avoid the
silly window syndrome.


Normal connection termination:

Normal connection termination starts transitioning from socket state
ACTIVE via either "Active Close" or "Passive Close".

shutdown rdwr               +-----------------+
or close,   +-------------->|  INIT / CLOSED  |<-------------+
send PeerCon|nClosed        +-----------------+              | PeerConnClosed
            |                       |                        | received
            |            connection | established            |
            |                       V                        |
    +----------------+     +-----------------+     +----------------+
    |AppFinCloseWait |     |     ACTIVE      |     |PeerFinCloseWait|
    +----------------+     +-----------------+     +----------------+
            |                   |         |                   |
            |     Active Close: |         |Passive Close:     |
            |     close or      |         |PeerConnClosed or  |
            |     shutdown wr or|         |PeerDoneWriting    |
            |     shutdown rdwr |         |received           |
            |                   V         V                   |
 PeerConnClo|sed    +--------------+   +-------------+        | close or
 received   +--<----|PeerCloseWait1|   |AppCloseWait1|--->----+ shutdown rdwr,
            |       +--------------+   +-------------+        | send
            |  PeerDoneWri|ting                | shutdown wr, | PeerConnClosed
            |  received   |            send Pee|rDoneWriting  |
            |             V                    V              |
            |       +--------------+   +-------------+        |
            +--<----|PeerCloseWait2|   |AppCloseWait2|--->----+
                    +--------------+   +-------------+

In state CLOSED, the socket can be destructed only, once the application has
issued a close().

Abnormal connection termination:

                            +-----------------+
            +-------------->|  INIT / CLOSED  |<-------------+
            |               +-----------------+              |
            |                                                |
            |           +-----------------------+            |
            |           |     Any state         |            |
 PeerConnAbo|rt         | (before setting       |            | send
 received   |           |  PeerConnClosed       |            | PeerConnAbort
            |           |  indicator in         |            |
            |           |  peer's RMBE)         |            |
            |           +-----------------------+            |
            |                   |         |                  |
            |     Active Abort: |         | Passive Abort:   |
            |     problem,      |         | PeerConnAbort    |
            |     send          |         | received,        |
            |     PeerConnAbort,|         | ECONNRESET       |
            |     ECONNABORTED  |         |                  |
            |                   V         V                  |
            |       +--------------+   +--------------+      |
            +-------|PeerAbortWait |   | ProcessAbort |------+
                    +--------------+   +--------------+


Implementation notes beyond RFC 7609:

A PNET table in sysfs provides the mapping between network device names and
RoCE Infiniband device names for the transparent switch of data communication.
A PNET table can contain an arbitrary number of PNETIDs.
Each PNETID contains exactly one (Ethernet) network device name
and one or more RoCE Infiniband device names.
Each device name can only exist in at most one PNETID (no overlapping).
This initial Linux implementation allows at most one RoCE Infiniband device
name per PNETID.
After a new TCP connection is established, the network device name
used for egress traffic with the TCP connection's local source IP address
is used as key to lookup the unique PNETID, and the RoCE Infiniband device
of this PNETID is used to switch data communication from TCP to RDMA
during SMC CLC handshake.


Problem determination:

A protocol dissector is available with upstream wireshark for formatting
SMC-R related RoCE LAN traffic.
[https://code.wireshark.org/review/gitweb?p=wireshark.git;a=blob;f=epan/dissectors/packet-smcr.c]


We are working on enhancing the Linux implementation to cover:

- Improve default socket closing asynchronicity
- Address corner cases with many parallel connections
- Tracing
- Integrated load balancing and fail-over within a link group
- Splice and sendpage support
- IPv6 addressing support
- Keepalive, Cork
- Namespaces support
- Urgent data
- More socket options
- Diagnostics
- Statistics support
- SNMP support


References:

[1] SMC-R Informational RFC: http://www.rfc-editor.org/info/rfc7609

Thomas Richter (1):
  smc: establish pnet table management

Ursula Braun (14):
  net: introduce keepalive function in struct proto
  smc: establish new socket family
  smc: introduce SMC as an IB-client
  smc: CLC handshake (incl. preparation steps)
  smc: connection and link group creation
  smc: remote memory buffers (RMBs)
  smc: work request (WR) base for use by LLC and CDC
  smc: initialize IB transport incl. PD, MR, QP, CQ, event, WR
  smc: link layer control (LLC)
  smc: connection data control (CDC)
  smc: send data (through RDMA)
  smc: receive data from RMBE
  smc: socket closing and linkgroup cleanup
  smc: proc-fs interface for smc connections

 MAINTAINERS            |    7 +
 include/linux/socket.h |    7 +-
 include/net/sock.h     |    1 +
 net/Kconfig            |    1 +
 net/Makefile           |    1 +
 net/core/sock.c        |    7 +-
 net/ipv4/tcp_ipv4.c    |    1 +
 net/ipv4/tcp_timer.c   |    1 +
 net/ipv6/tcp_ipv6.c    |    1 +
 net/smc/Kconfig        |   11 +
 net/smc/Makefile       |    3 +
 net/smc/af_smc.c       | 1379 ++++++++++++++++++++++++++++++++++++++++++++++++
 net/smc/smc.h          |  261 +++++++++
 net/smc/smc_cdc.c      |  295 +++++++++++
 net/smc/smc_cdc.h      |  176 ++++++
 net/smc/smc_clc.c      |  276 ++++++++++
 net/smc/smc_clc.h      |  113 ++++
 net/smc/smc_close.c    |  434 +++++++++++++++
 net/smc/smc_close.h    |   27 +
 net/smc/smc_core.c     |  700 ++++++++++++++++++++++++
 net/smc/smc_core.h     |  177 +++++++
 net/smc/smc_ib.c       |  477 +++++++++++++++++
 net/smc/smc_ib.h       |   67 +++
 net/smc/smc_llc.c      |  158 ++++++
 net/smc/smc_llc.h      |   63 +++
 net/smc/smc_pnet.c     |  611 +++++++++++++++++++++
 net/smc/smc_pnet.h     |   26 +
 net/smc/smc_proc.c     |  251 +++++++++
 net/smc/smc_proc.h     |   19 +
 net/smc/smc_rx.c       |  212 ++++++++
 net/smc/smc_rx.h       |   22 +
 net/smc/smc_tx.c       |  461 ++++++++++++++++
 net/smc/smc_tx.h       |   35 ++
 net/smc/smc_wr.c       |  608 +++++++++++++++++++++
 net/smc/smc_wr.h       |   95 ++++
 35 files changed, 6978 insertions(+), 6 deletions(-)
 create mode 100644 net/smc/Kconfig
 create mode 100644 net/smc/Makefile
 create mode 100644 net/smc/af_smc.c
 create mode 100644 net/smc/smc.h
 create mode 100644 net/smc/smc_cdc.c
 create mode 100644 net/smc/smc_cdc.h
 create mode 100644 net/smc/smc_clc.c
 create mode 100644 net/smc/smc_clc.h
 create mode 100644 net/smc/smc_close.c
 create mode 100644 net/smc/smc_close.h
 create mode 100644 net/smc/smc_core.c
 create mode 100644 net/smc/smc_core.h
 create mode 100644 net/smc/smc_ib.c
 create mode 100644 net/smc/smc_ib.h
 create mode 100644 net/smc/smc_llc.c
 create mode 100644 net/smc/smc_llc.h
 create mode 100644 net/smc/smc_pnet.c
 create mode 100644 net/smc/smc_pnet.h
 create mode 100644 net/smc/smc_proc.c
 create mode 100644 net/smc/smc_proc.h
 create mode 100644 net/smc/smc_rx.c
 create mode 100644 net/smc/smc_rx.h
 create mode 100644 net/smc/smc_tx.c
 create mode 100644 net/smc/smc_tx.h
 create mode 100644 net/smc/smc_wr.c
 create mode 100644 net/smc/smc_wr.h

-- 
2.6.6
