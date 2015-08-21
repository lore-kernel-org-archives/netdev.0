From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH V4 net-next 0/2] net: implement SMC-R solution
Date: Fri, 21 Aug 2015 13:30:27 +0200
Message-ID: <1440156629-35691-1-git-send-email-ubraun@linux.vnet.ibm.com>
References: <20150726.161530.2192841818929026804.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: utz.bacher@de.ibm.com, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org, schwidefsky@de.ibm.com,
	heiko.carstens@de.ibm.com, ursula.braun@de.ibm.com,
	ubraun@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp12.uk.ibm.com ([195.75.94.108]:49799 "EHLO
	e06smtp12.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752604AbbHULak (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Aug 2015 07:30:40 -0400
Received: from /spool/local
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
	Fri, 21 Aug 2015 12:30:38 +0100
In-Reply-To: <20150726.161530.2192841818929026804.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Ursula Braun <ursula.braun@de.ibm.com>

Dave,

this is V4 of my SMC-R patches:
Since you are asking for a solution "100% in our own separate module
with our own can of worms", we have to give up the transparent detectio=
n
whether a communication peer can do SMC-R or not (this has been the
purpose of the rejected TCP hooks). Instead, we want just the new
self-contained SMC-R socket family added to the kernel.
By the way, since August 2015 the SMC-R Informational RFC is no longer
a draft, but published as RFC7609.

V4 changes:
1. Remove tcp patches supporting TCP experimental options
2. Remove references to tcp_sock syn_smc flag in smc-code, since TCP
   experimental options are not supported by the Linux-tcp.
3. clc_wait_msg() simplified

V3 changes:
1. Avoid adding of new space for smc-related bits in the tcp structures=
=2E
2. Make the smc feature to be nearly zero cost using Static Keys / jump
   labels
3. Increase / decrease smc static key in the smc-code
4. Make sure the next-to-last patch does not break the build
5. Additional pnet table checking

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
protocol as specified in the informational RFC7609 [2]. It has been
published in August 2015. Another implementation of this protocol is
available since 2013 with IBM z/OS Version 2 Release 1.=20

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
Without the rejected TCP Experimental Options the following aspects are
restricted; alternate solutions are in discussion.=20
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
s.
The rendezvous process occurs now in 1 phase only:=20
1. TCP/IP 3-way exchange with TCP experimental options is skipped.
2. SMC-R 3-way exchange:
   It is assumed both partners indicate SMC-R capability. Then at the
   completion of the 3-way TCP handshake the SMC-R layers in each peer =
take
   control of the TCP connection and exchange their RDMA credentials. I=
f
   this 3-way exchange completes successfully the connection continues =
using
   SMC-R. If the exchange is not successful the connections falls back =
to
   standard TCP/IP.=20

References:
[1] SMC-R Overview and Reference Materials:
    http://www-01.ibm.com/software/network/commserver/SMCR/=20
[2] SMC-R Informational RFC:
    https://tools.ietf.org/rfc/rfc7609
[3] Linux SMC-R Overview and Performance Summary
    (archs x86 and s390):
    http://www-01.ibm.com/software/network/commserver/SMCR/=20

The patch series is prepared to apply to net-next and consists of these
parts:
1. net:             definitions to establish new socket family
2. net/smc:         new socket family

In the future, SMC-R will be enhanced to cover:
- alternate SMC-capability detection
- IPv6 support
- Tracing
- Statistics support

shortlog:

Ursula Braun (2):
  net: introduce socket family constants
  smc: introduce socket family AF_SMC

--=20
2.3.8
