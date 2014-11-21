From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH 0/3] [RFC] net: implement SMC-R solution
Date: Fri, 21 Nov 2014 21:08:01 +0100
Message-ID: <1416600484-55631-1-git-send-email-ubraun@linux.vnet.ibm.com>
Cc: linux-s390@vger.kernel.org, davem@davemloft.net,
	utz.bacher@de.ibm.com, ogerlitz@mellanox.com, monis@mellanox.com,
	fowlerja@us.ibm.com, heiko.carstens@de.ibm.com,
	frank.blaschka@de.ibm.com, ursula.braun@de.ibm.com,
	ubraun@linux.vnet.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp17.uk.ibm.com ([195.75.94.113]:37995 "EHLO
	e06smtp17.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752300AbaKUUIP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2014 15:08:15 -0500
Received: from /spool/local
	by e06smtp17.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
	Fri, 21 Nov 2014 20:08:13 -0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ursula.braun@de.ibm.com>

A connection using SMC-R starts out setting up a connection using the
TCP/IP protocol [2]. Thus an internal smc-managed TCP socket is established,
whose traffic flows across an interface belonging to the same Converged
Ethernet fabric, defined by a so-called "pnet table" [1].

As part of the connection setup, flags indicating the support
for SMC-R will be used to negotiate SMC-R usage. If any of the two parties
involved does not support SMC-R, the connection will fall back to plain TCP/IP
usage. If both parties support SMC-R, the TCP/IP connection will be used to
exchange the necessary connection data for setup of an Infiniband (IB)
connection in the so-called {\em rendezvous handshake}.

The code implements also the link management of the SMC-R protocol forming link
groups for each remote host and provide for
- dynamic addition of further RoCE Host Channel Adapters (HCAs) to form a
  so-called link group
- seamless failover, moving existing connections from a failed HCA
  to the remaining HCAs in a link group
- load balancing of connections across the links in a link group

SMC-R design defines memory areas for data transport through RDMA called
RDMA Memory Buffer (RMB) split up into several RMB Elements (RMBEs) assigned to
single connections. This initial Linux implementation requires real contiguous
storage for these RMBs and uses a separate RMB with just 1 RMBE for every
connection. Its size is derived from:
- a system wide default minimum SMC receive buffer size (tailorable by
  /proc/net/smc/rcvbuf
- if given, the socket specific SETSOCKOPT SO_RCVBUF configuration
- the size of the tcp socket receive buffer determined from the system wide tcp
  socket receive buffer configuration
- the amount of available contiguous storage
In the Linux implementation an equivalent concept exists for the socket send
buffers [1].

The patch provided does not yet cover:
- IPv6 support
- Tracing
- Statistic hooks
These items are on our list of things to do.

References:
[1] SMC-R Overview and Reference Materials:
    http://www-01.ibm.com/software/network/commserver/SMCR/ 
[2] SMC-R Informational RFC:
    http://datatracker.ietf.org/doc/draft-fox-tcpm-shared-memory-rdma-05/

Prerequiste for proper VLAN handling is this recent patch in
drivers/infiniband/core/verbs.c:
	https://patchwork.kernel.org/patch/5335641/

Signed-off-by: Ursula Braun <ubraun@linux.vnet.ibm.com>

Ursula Braun (3):
  [RFC] tcp: introduce TCP experimental option for SMC
  [RFC] net: introduce socket family constants
  [RFC] smc: introduce socket family AF_SMC

 fs/splice.c                |    1 +
 include/linux/socket.h     |    5 +-
 include/linux/tcp.h        |    5 +-
 include/net/request_sock.h |    3 +-
 include/net/tcp.h          |    4 +
 net/Kconfig                |    1 +
 net/Makefile               |    1 +
 net/ipv4/tcp_input.c       |   41 +-
 net/ipv4/tcp_minisocks.c   |    4 +
 net/ipv4/tcp_output.c      |   26 +
 net/smc/Kconfig            |    9 +
 net/smc/Makefile           |    3 +
 net/smc/af_smc.c           | 2905 +++++++++++++++++++++++++++++++++++++++++
 net/smc/af_smc.h           |  669 ++++++++++
 net/smc/smc_core.c         | 3112 ++++++++++++++++++++++++++++++++++++++++++++
 net/smc/smc_llc.c          | 1472 +++++++++++++++++++++
 net/smc/smc_llc.h          |  192 +++
 net/smc/smc_proc.c         |  829 ++++++++++++
 18 files changed, 9266 insertions(+), 16 deletions(-)
 create mode 100644 net/smc/Kconfig
 create mode 100644 net/smc/Makefile
 create mode 100644 net/smc/af_smc.c
 create mode 100644 net/smc/af_smc.h
 create mode 100644 net/smc/smc_core.c
 create mode 100644 net/smc/smc_llc.c
 create mode 100644 net/smc/smc_llc.h
 create mode 100644 net/smc/smc_proc.c

-- 
1.8.5.5
