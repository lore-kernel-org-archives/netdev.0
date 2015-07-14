From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH V2 net-next 0/3] net: implement SMC-R solution
Date: Tue, 14 Jul 2015 14:42:32 +0200
Message-ID: <1436877755-23431-1-git-send-email-ubraun@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: utz.bacher@de.ibm.com, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org, schwidefsky@de.ibm.com,
	heiko.carstens@de.ibm.com, ursula.braun@de.ibm.com,
	ubraun@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp17.uk.ibm.com ([195.75.94.113]:38213 "EHLO
	e06smtp17.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752036AbbGNMmo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jul 2015 08:42:44 -0400
Received: from /spool/local
	by e06smtp17.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
	Tue, 14 Jul 2015 13:42:42 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Ursula Braun <ursula.braun@de.ibm.com>

Eric,

this is V2 of my SMC-R patches, containing especially a new version of =
the
required tcp changes. As you suggested, SMC-specific hooks in the TCP-c=
ode
are built only for CONFIG_AFSMC. And I come up with helpers in include =
files
to avoid spreading net #ifdef in C files.

V2 changes:
1. activate tcp changes for CONFIG_AFSMC only (as suggested by Eric Dum=
azet)
2. add additional hook in net/core/sock.c
3. fix bitfield endianness problem

Thanks,
        Ursula

In 2013, IBM introduced an optimized communications solution for the
IBM zEnterprise EC12 and BC12 (s390 in Linux terminology) that is
comprised of the IBM 10GbE RoCE Express feature with Shared Memory
Communications-RDMA (SMC-R) protocol [1].
SMC-R is designed for the enterprise data center environment and is an =
open
protocol as specified in the informational RFC [2]. The final draft
submitted by IBM has been approved for publication and is in the final
editorial stage. Another implementation of this protocol is available s=
ince
2013 with IBM z/OS Version 2 Release 1.=20

SMC-R provides a =E2=80=9Csockets over RDMA=E2=80=9D solution that leve=
rages industry
standard RDMA over Converged Ethernet (RoCE) technology.

IBM has developed a Linux implementation of the SMC-R standard. A new
socket protocol family AF_SMC is introduced. A preload library can be u=
sed
to enable TCP-based applications to use SMC-R without changes.=20

Key aspects of SMC-R are:=20
1. Provides optimized performance compared to standard TCP/IP over Ethe=
rnet
   within the data center for both request/response (latency) and strea=
ming
   workloads (CPU savings) [3].=20
   Initial benchmarks on Linux on x86 processors have shown latency
   reduction of up to 52% with a throughput gain of 111% using SMC-R vs=
 TCP
   for request/response message patterns (10 concurrent TCP connections
   with 16KB    messages) and CPU savings of up to 69% for streaming da=
ta
   patterns (single TCP connection with 20MB of data in one direction).
   [1] is currently updated to contain more detailed information on Lin=
ux
   and performance.
2. In order to preserve the traditional network administrative model th=
e
   SMC-R protocol ties into the existing IP addresses and uses TCP's
   handshake to establish connections. This allows existing management
   tools and security infrastructure to control the creation of SMC
   connections.
3. The SMC-R protocol logically bonds multiple RoCE adapters together
   providing    redundancy with transparent fail-over for improved high
   availability, increased bandwidth and load balancing across multiple
   RDMA-capable devices.
4. Due to its handshake protocol, SMC-R is compatible with (transparent=
 to)
   existing TCP connection load balancers that are commonly used in the
   enterprise data center environment for multi-tier application worklo=
ads.
5. SMC-R's handshake protocol allows for transparent fallback to TCP/IP=
,
   should one of the peers not be capable of the protocol.

Additional SMC-R overview and reference materials are available [1]. =20

The SMC-R =E2=80=9Crendezvous" protocol eliminates the need for RDMA-CM=
 and the
exchange occurs through an initial TCP connection. Building on a TCP
connection to establish an SMC-R connection solves many key requirement=
s,
including #4 and #5 above.
The rendezvous process occurs in 2 phases:=20
1. TCP/IP 3-way exchange:
   Initiated when both client and server indicate SMC-R capability by
   including TCP experimental options on the TCP/IP 3-way handshake (sy=
n
   flows) as described in RFC6994 [4]. The ExID assigned by IANA is
   0xE2D4C3D9 [5].=20
2. SMC-R 3-way exchange:
   When both partners indicate SMC-R capability then at the completion =
of
   the 3-way TCP handshake the SMC-R layers in each peer take control o=
f
   the TCP connection and exchange their RDMA credentials. If this 3-wa=
y
   exchange    completes successfully the connection continues using SM=
C-R.
   If the exchange is not successful the connections falls back to stan=
dard
   TCP/IP.=20

References:
[1] SMC-R Overview and Reference Materials:
    http://www-01.ibm.com/software/network/commserver/SMCR/=20
[2] SMC-R Informational RFC:
    http://tools.ietf.org/html/draft-fox-tcpm-shared-memory-rdma-07
[3] Linux SMC-R Overview and Performance Summary
    (archs x86 and s390):
    http://www-01.ibm.com/software/network/commserver/SMCR/=20
[4] Shared Use of TCP Experimental Options RFC 6994:
    https://tools.ietf.org/rfc/rfc6994.txt   =20
[5] IANA ExID SMCR:=20
    http://www.iana.org/assignments/tcp-parameters/tcp-parameters.xhtml=
#tcp-exids

The patch series is prepared to apply to net-next and consists of these
parts:
1. net/ipv4/tcp: TCP experimental option
2. net: definitions to establish new socket family
3. net/smc: new socket family

In the future, SMC-R will be enhanced to cover:
- IPv6 support
- Tracing
- Statistics support

Ursula Braun (3):
  tcp: introduce TCP experimental option for SMC
  net: introduce socket family constants
  smc: introduce socket family AF_SMC

 include/linux/socket.h     |    4 +-
 include/linux/tcp.h        |   16 +-
 include/net/request_sock.h |    3 +-
 include/net/smc.h          |   13 +
 include/net/tcp.h          |  145 ++
 net/Kconfig                |    1 +
 net/Makefile               |    1 +
 net/core/sock.c            |   15 +-
 net/ipv4/tcp_input.c       |    8 +
 net/ipv4/tcp_minisocks.c   |    3 +
 net/ipv4/tcp_output.c      |   23 +-
 net/smc/Kconfig            |    9 +
 net/smc/Makefile           |    3 +
 net/smc/af_smc.c           | 3142 ++++++++++++++++++++++++++++++++++++=
++++++
 net/smc/af_smc.h           |  706 ++++++++++
 net/smc/smc_core.c         | 3291 ++++++++++++++++++++++++++++++++++++=
++++++++
 net/smc/smc_llc.c          | 1597 +++++++++++++++++++++
 net/smc/smc_llc.h          |  192 +++
 net/smc/smc_proc.c         |  884 ++++++++++++
 19 files changed, 10034 insertions(+), 22 deletions(-)
 create mode 100644 include/net/smc.h
 create mode 100644 net/smc/Kconfig
 create mode 100644 net/smc/Makefile
 create mode 100644 net/smc/af_smc.c
 create mode 100644 net/smc/af_smc.h
 create mode 100644 net/smc/smc_core.c
 create mode 100644 net/smc/smc_llc.c
 create mode 100644 net/smc/smc_llc.h
 create mode 100644 net/smc/smc_proc.c

--=20
2.3.8
