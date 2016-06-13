From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH net-next 00/17] RDS: multiple connection paths for scaling
Date: Mon, 13 Jun 2016 09:44:25 -0700
Message-ID: <cover.1465829626.git.sowmini.varadhan@oracle.com>
Cc: davem@davemloft.net, rds-devel@oss.oracle.com,
	ajaykumar.hotchandani@oracle.com, santosh.shilimkar@oracle.com,
	sowmini.varadhan@oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:25875 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965097AbcFMQpO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 12:45:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Today RDS-over-TCP is implemented by demux-ing multiple PF_RDS sockets
between any 2 endpoints (where endpoint == [IP address, port]) over a
single TCP socket between the 2 IP addresses involved. This has the
limitation that it ends up funneling multiple RDS flows over a single
TCP flow, thus the rds/tcp connection is
   (a) upper-bounded to the single-flow bandwidth,
   (b) suffers from head-of-line blocking for the RDS sockets. 

Better throughput (for a fixed small packet size, MTU) can be achieved
by having multiple TCP/IP flows per rds/tcp connection, i.e., multipathed
RDS (mprds).  Each such TCP/IP flow constitutes a path for the rds/tcp
connection. RDS sockets will be attached to a path based on some hash
(e.g., of local address and RDS port number) and packets for that RDS
socket will be sent over the attached path using TCP to segment/reassemble
RDS datagrams on that path.

The table below, generated using a prototype that implements mprds,
shows that this is significant for scaling to 40G.  Packet sizes
used were: 8K byte req, 256 byte resp. MTU: 1500.  The parameters for
RDS-concurrency used below are described in the rds-stress(1) man page-
the number listed is proportional to the number of threads at which max
throughput was attained.

  -------------------------------------------------------------------
     RDS-concurrency   Num of       tx+rx K/s (iops)       throughput
     (-t N -d N)       TCP paths
  -------------------------------------------------------------------
        16             1             600K -  700K            4 Gbps
        28             8            5000K - 6000K           32 Gbps
  -------------------------------------------------------------------

FAQ: what is the relation between mprds and mptcp?
  mprds is orthogonal to mptcp. Whereas mptcp creates
  sub-flows for a single TCP connection, mprds parallelizes tx/rx
  at the RDS layer. MPRDS with N paths will allow N datagrams to
  be sent in parallel; each path will continue to send one
  datagram at a time, with sender and receiver keeping track of
  the retransmit and dgram-assembly state based on the RDS header.
  If desired, mptcp can additionally be used to speed up each TCP
  path. That acceleration is orthogonal to the parallelization benefits
  of mprds.

This patch series lays down the foundational data-structures to support
mprds in the kernel. It implements the changes to split up the
rds_connection structure into a common (to all paths) part,
and a per-path rds_conn_path. All I/O workqs are driven from
the rds_conn_path. 

Note that this patchset does not (yet) actually enable multipathing
for any of the transports; all transports will continue to use a 
single path with the refactored data-structures. A subsequent patchset
will  add the changes to the rds-tcp module to actually use mprds
in rds-tcp.

Sowmini Varadhan (17):
  RDS: split out connection specific state from rds_connection to
    rds_conn_path
  RDS: add t_mp_capable bit to be set by MP capable transports
  RDS: recv path gets the conn_path from rds_incoming for MP capable
    transports
  RDS: rds_inc_path_init() helper function for MP capable transports
  RDS: Add rds_send_path_reset()
  RDS: Add rds_send_path_drop_acked()
  RDS: Remove stale function rds_send_get_message()
  RDS: Make rds_send_queue_rm() rds_conn_path aware
  RDS: Pass rds_conn_path to rds_send_xmit()
  RDS: Extract rds_conn_path from i_conn_path in rds_send_drop_to() for
    MP-capable transports
  RDS: Make rds_send_pong() take a rds_conn_path argument
  RDS: Add rds_conn_path_connect_if_down() for MP-aware callers
  RDS: update rds-info related functions to traverse multiple
    conn_paths
  RDS: Add rds_conn_path_error()
  RDS: Initialize all RDS_MPATH_WORKERS in __rds_conn_create
  RDS: Update rds_conn_shutdown to work with rds_conn_path
  RDS: Update rds_conn_destroy to be MP capable

 net/rds/cong.c            |    3 +-
 net/rds/connection.c      |  329 +++++++++++++++++++++++++++++++-------------
 net/rds/ib.c              |    1 +
 net/rds/ib_cm.c           |    3 +-
 net/rds/ib_rdma.c         |    1 +
 net/rds/ib_recv.c         |    1 +
 net/rds/ib_send.c         |    1 +
 net/rds/loop.c            |    1 +
 net/rds/rdma_transport.c  |    1 +
 net/rds/rds.h             |  152 ++++++++++++++-------
 net/rds/rds_single_path.h |   30 ++++
 net/rds/recv.c            |   27 +++-
 net/rds/send.c            |  293 ++++++++++++++++++++--------------------
 net/rds/tcp.c             |    3 +-
 net/rds/tcp_connect.c     |    4 +-
 net/rds/tcp_listen.c      |   11 +-
 net/rds/tcp_recv.c        |    1 +
 net/rds/tcp_send.c        |    1 +
 net/rds/threads.c         |   95 ++++++++------
 19 files changed, 611 insertions(+), 347 deletions(-)
 create mode 100644 net/rds/rds_single_path.h
