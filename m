From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCHv2 net-next 0/6] sctp: support sctp_diag in kernel
Date: Sat,  9 Apr 2016 12:53:08 +0800
Message-ID: <cover.1460177331.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	Vlad Yasevich <vyasevich@gmail.com>, daniel@iogearbox.net,
	davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:33224 "EHLO
	mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750826AbcDIExU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Apr 2016 00:53:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset will add sctp_diag module to implement diag interface on
sctp in kernel.

For a listening sctp endpoint, we will just dump it's ep info.
For a sctp connection, we will the assoc info and it's ep info.

The ss dump will looks like:

[iproute2]# ./misc/ss --sctp  -n -l
State      Recv-Q Send-Q   Local Address:Port       Peer Address:Port
LISTEN     0      128      172.16.254.254:8888      *:*
LISTEN     0      5        127.0.0.1:1234           *:*
LISTEN     0      5        127.0.0.1:1234           *:*
  - ESTAB  0      0        127.0.0.1%lo:1234        127.0.0.1:4321
LISTEN     0      128      172.16.254.254:8888      *:*
  - ESTAB  0      0        172.16.254.254%eth1:8888 172.16.253.253:8888
  - ESTAB  0      0        172.16.254.254%eth1:8888 172.16.1.1:8888
  - ESTAB  0      0        172.16.254.254%eth1:8888 172.16.1.2:8888
  - ESTAB  0      0        172.16.254.254%eth1:8888 172.16.2.1:8888
  - ESTAB  0      0        172.16.254.254%eth1:8888 172.16.2.2:8888
  - ESTAB  0      0        172.16.254.254%eth1:8888 172.16.3.1:8888
  - ESTAB  0      0        172.16.254.254%eth1:8888 172.16.3.2:8888
LISTEN     0      0        127.0.0.1:4321           *:*
  - ESTAB  0      0        127.0.0.1%lo:4321        127.0.0.1:1234

The entries with '- ESTAB' are the assocs, some of them may belong to
the same endpoint. So we will dump the parent endpoint first, like the
entry with 'LISTEN'. then dump the assocs. ep and assocs entries will
be dumped in right order so that ss can show them in tree format easily.

Besides, this patchset also simplifies sctp proc codes, cause it has
some similar codes with sctp diag in sctp transport traversal.

v1->v2:
  1. inet_diag_get_handler needs to return it as const.
  2. merge 5/7 into 2/7 of v1.

Xin Long (6):
  sctp: add sctp_info dump api for sctp_diag
  sctp: export some apis or variables for sctp_diag and reuse some for
    proc
  sctp: export some functions for sctp_diag in inet_diag
  sctp: add the sctp_diag.c file
  sctp: merge the seq_start/next/exits in remaddrs and assocs
  sctp: fix some rhashtable functions using in sctp proc/diag

 include/linux/sctp.h           |  65 +++++
 include/net/sctp/sctp.h        |  16 ++
 include/uapi/linux/inet_diag.h |   2 +
 net/ipv4/inet_diag.c           |   9 +-
 net/sctp/Kconfig               |   4 +
 net/sctp/Makefile              |   1 +
 net/sctp/proc.c                | 104 ++------
 net/sctp/sctp_diag.c           | 581 +++++++++++++++++++++++++++++++++++++++++
 net/sctp/socket.c              | 215 +++++++++++++++
 9 files changed, 911 insertions(+), 86 deletions(-)
 create mode 100644 net/sctp/sctp_diag.c

-- 
2.1.0
