From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH v2 net-next 0/3] net: Add incoming CPU mask to sockets
Date: Tue, 26 May 2015 09:34:06 -0700
Message-ID: <1432658049-3400132-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:33711 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751888AbbEZQe0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2015 12:34:26 -0400
Received: from pps.filterd (m0004060 [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t4QGVOat004355
	for <netdev@vger.kernel.org>; Tue, 26 May 2015 09:34:23 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 1umty08cbp-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 26 May 2015 09:34:23 -0700
Received: from facebook.com (2401:db00:20:702e:face:0:23:0)	by
 mx-out.facebook.com (10.212.232.59) with ESMTP	id
 0fd1f8e403c511e5bcfc0002c991e86a-6bed03a0 for <netdev@vger.kernel.org>;	Tue,
 26 May 2015 09:34:21 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Added matching of CPU to a socket CPU mask. This is useful for TCP
listeners and unconnected UDP. This works with SO_REUSPORT to steer
packets to listener sockets based on CPU affinity. These patches
allow steering packets to listeners based on numa locality. This is
only useful for passive connections.

v2:
  - Add cache alignment for fields used in socket lookup in sock_common
  - Added UDP test results

Tested: 200 TCP_RR with --r 512,512 streams ran against an echo server
with that sets both SO_REUSEPORT and SO_INCOMING_CPU_MASK. In the
test case used taskset to pin an instance to a set of CPUs corresponding
to a numa node and set SO_INCOMING_CPU_MASK to the same set of CPUS.

CPU utilization is reported from the echo server side.

IPv4
  No INCOMING_CPU_MASK
    83.48% CPU utilization
    1627173 tps
    106/185/382 50/90/99% latencies
  With INCOMING_CPU_MASK
    77.61% CPU utilization
    1669853 tps
    103/181/378 50/90/99% latencies
IPv6
  No INCOMING_CPU_MASK
    84.82% CPU utilization
    1551730 tps
    111/195/392 50/90/99% latencies
  With INCOMING_CPU_MASK
    79.25% CPU utilization
    1571911 tps
    110/191/381 50/90/99% latencies

Tested: 200 UDP_RR with --r 512,512 streams ran against an echo server
with that sets both SO_REUSEPORT and SO_INCOMING_CPU_MASK. In the
test case used taskset to pin an instance to a set of CPUs corresponding
to a numa node and set SO_INCOMING_CPU_MASK to the same set of CPUS.

IPv4
  No INCOMING_CPU_MASK
    54.76% CPU utilization
    1603752.3 tps
    95/217/753 50/90/99% latencies
  With INCOMING_CPU_MASK
    53.25% CPU utilization
    1717618 tps
    117/221/502 50/90/99% latencies
IPv6
  No INCOMING_CPU_MASK
    61.62% CPU utilization
    1276757 tps
    125/279/629 50/90/99% latencies
  With INCOMING_CPU_MASK
    66.63% CPU utilization
    1314527 tps
    149/318/564 50/90/99% latencies

*** BLURB HERE ***

Tom Herbert (3):
  net: Add cache alignment in sock_common for socket lookup fields
  kernel: Make compat bitmap functions externally visible
  net: Add incoming CPU mask to sockets

 arch/alpha/include/uapi/asm/socket.h   |  2 +
 arch/avr32/include/uapi/asm/socket.h   |  2 +
 arch/cris/include/uapi/asm/socket.h    |  2 +
 arch/frv/include/uapi/asm/socket.h     |  2 +
 arch/ia64/include/uapi/asm/socket.h    |  2 +
 arch/m32r/include/uapi/asm/socket.h    |  2 +
 arch/mips/include/uapi/asm/socket.h    |  2 +
 arch/mn10300/include/uapi/asm/socket.h |  2 +
 arch/parisc/include/uapi/asm/socket.h  |  2 +
 arch/powerpc/include/uapi/asm/socket.h |  2 +
 arch/s390/include/uapi/asm/socket.h    |  2 +
 arch/sparc/include/uapi/asm/socket.h   |  2 +
 arch/xtensa/include/uapi/asm/socket.h  |  2 +
 include/linux/compat.h                 |  2 +
 include/net/sock.h                     | 39 ++++++++++++++++-
 include/uapi/asm-generic/socket.h      |  2 +
 kernel/compat.c                        |  7 ++-
 net/compat.c                           | 56 ++++++++++++++++++++++++
 net/core/sock.c                        | 80 ++++++++++++++++++++++++++++++++++
 net/ipv4/inet_hashtables.c             |  3 ++
 net/ipv4/udp.c                         |  6 +++
 net/ipv6/inet6_hashtables.c            |  3 ++
 net/ipv6/udp.c                         |  3 ++
 23 files changed, 224 insertions(+), 3 deletions(-)

-- 
1.8.1
