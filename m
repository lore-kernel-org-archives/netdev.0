From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH V3 net-next 00/15] net/smc: Shared Memory Communications - RDMA
Date: Thu, 24 Nov 2016 16:06:30 +0100
Message-ID: <20161124150645.90881-1-ubraun@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
        schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
        utz.bacher@de.ibm.com, ubraun@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:38450 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S966033AbcKXPG6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Nov 2016 10:06:58 -0500
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uAOF3hTA006710
        for <netdev@vger.kernel.org>; Thu, 24 Nov 2016 10:06:57 -0500
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
        by mx0a-001b2d01.pphosted.com with ESMTP id 26wy1mgsjh-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 24 Nov 2016 10:06:57 -0500
Received: from localhost
        by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
        Thu, 24 Nov 2016 15:06:53 -0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Dave,

here is now V3 of the SMC-R patches having processed your feedback from end
of September. The most important change is the replacement of procfs by a
netlink solution in patch 15 similar to sock_diag and inet_diag.
New checkpatch warnings are resolved.

V3 changes:
Patch 05: Remove unneeded DEFINE_WAIT
Patch 06: Improve synchronization of link group creation
Patch 07: Rename peer_rmbe_len into peer_rmbe_size to be more consistent
Patch 09: Avoid calls of ib_get_memory_region with IB_ACCESS_LOCAL_WRITE,
          use new default local_dma_lkey from protection domain as lkey
          instead.
          Remove no longer needed function smc_ib_dereg_memory_region().
Patch 14: Switch to state ACTIVE only if still in state INIT.
          Return 0 for recvmsg invoked in a socket closing state.
          Allow getname call in state APPCLOSEWAIT1
          Do not trigger destruction of a socket-in-error queued in accept
          queue.
          During cleanup of accept queue, make sure sockets are destructed,
          and sockets in fallback mode are handled appropriately.
          When freeing sndbufs/rmbs, remove them from their list and free
          the entry.
          Use add_wait_queue() and remove_wait_queue() in close wait
          functions.
          If actively closing a socket in state for PEERFINCLOSEWAIT, keep
          this state.
          If passively closing a socket while bytes are to be received, move
          to state APPCLOSEWAIT1.
          If actively aborting a socket, skip sending the close_abort flag,
          since RDMA communication is no longer possible.
          When terminating a link group, do not schedule link group freeing a
          2nd time, since already done when unregistering the last remaining
          connection.
Patch 15: Introduce smc_diag module for monitoring SMC protocol sockets.
          This replaces the old patch 0015 dealing with procfs.

V2 changes:
Patch 0002: Add SMC versions for family key strings in net/core/sock.c.
Patch 0006: initialize rb_tree.
Patch 0007: Get rid of unneeded use of xchg() in smc_sndbuf_unuse() and
            smc_rmb_unuse().
Patch 0008: Correct error checking logic for ib_function calls.
            Define struct smc_link field wr_tx_id as atomic_long_t.
            Use "do_div" instead of "%" to be architecture-independent.
Patch 0009: Correct error checking logic for ib_function calls.
Patch 0011: Remove xchg() calls in cursor handling. Use atomic64_t for cursor
            overlays on 64-bit architectures. If not available, use plain u64
            and add locking for cursor reading and writing.
            Implement smc_curs_add() without modulo operator "%".
Patch 0012: Remove xchg() calls in cursor handling.
            Implement smc_tx_rdma_writes() without module operator "%".
Patch 0013: Remove xchg() calls in cursor handling.
Patch 0014: Return type bool in smc_wr_tx_has_pending().
            Remove unneeded semicolon in smc_close_shutdown_write().
            Call smc_close_active() in non-fallback case only.
            Get rid of duplicate schedule of sock_put_work().
            Take nested sock_lock in smc_listen_work().
            Start close stream_wait in case of prepared sends only.
Patch 0015: Remove unneeded socket ref_count in smc_proc_seq_show().
            Take lock before list_empty check in smc_proc_sock_list_del().

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
  smc: netlink interface for SMC sockets

 MAINTAINERS                   |    7 +
 include/linux/socket.h        |    7 +-
 include/net/smc.h             |   20 +
 include/net/sock.h            |    4 +
 include/uapi/linux/netlink.h  |    1 +
 include/uapi/linux/smc_diag.h |   85 +++
 net/Kconfig                   |    1 +
 net/Makefile                  |    1 +
 net/core/sock.c               |   13 +-
 net/ipv4/tcp_ipv4.c           |    1 +
 net/ipv4/tcp_timer.c          |    1 +
 net/ipv6/tcp_ipv6.c           |    1 +
 net/smc/Kconfig               |   20 +
 net/smc/Makefile              |    4 +
 net/smc/af_smc.c              | 1417 +++++++++++++++++++++++++++++++++++++++++
 net/smc/smc.h                 |  272 ++++++++
 net/smc/smc_cdc.c             |  302 +++++++++
 net/smc/smc_cdc.h             |  218 +++++++
 net/smc/smc_clc.c             |  281 ++++++++
 net/smc/smc_clc.h             |  116 ++++
 net/smc/smc_close.c           |  442 +++++++++++++
 net/smc/smc_close.h           |   28 +
 net/smc/smc_core.c            |  675 ++++++++++++++++++++
 net/smc/smc_core.h            |  179 ++++++
 net/smc/smc_diag.c            |  215 +++++++
 net/smc/smc_ib.c              |  479 ++++++++++++++
 net/smc/smc_ib.h              |   69 ++
 net/smc/smc_llc.c             |  158 +++++
 net/smc/smc_llc.h             |   63 ++
 net/smc/smc_pnet.c            |  611 ++++++++++++++++++
 net/smc/smc_pnet.h            |   27 +
 net/smc/smc_rx.c              |  217 +++++++
 net/smc/smc_rx.h              |   23 +
 net/smc/smc_tx.c              |  483 ++++++++++++++
 net/smc/smc_tx.h              |   35 +
 net/smc/smc_wr.c              |  614 ++++++++++++++++++
 net/smc/smc_wr.h              |  106 +++
 37 files changed, 7187 insertions(+), 9 deletions(-)
 create mode 100644 include/net/smc.h
 create mode 100644 include/uapi/linux/smc_diag.h
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
 create mode 100644 net/smc/smc_diag.c
 create mode 100644 net/smc/smc_ib.c
 create mode 100644 net/smc/smc_ib.h
 create mode 100644 net/smc/smc_llc.c
 create mode 100644 net/smc/smc_llc.h
 create mode 100644 net/smc/smc_pnet.c
 create mode 100644 net/smc/smc_pnet.h
 create mode 100644 net/smc/smc_rx.c
 create mode 100644 net/smc/smc_rx.h
 create mode 100644 net/smc/smc_tx.c
 create mode 100644 net/smc/smc_tx.h
 create mode 100644 net/smc/smc_wr.c
 create mode 100644 net/smc/smc_wr.h

-- 
2.8.4
