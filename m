From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next 0/5] sctp: use transport hashtable to replace association's with rhashtable
Date: Wed, 30 Dec 2015 23:50:45 +0800
Message-ID: <cover.1451490447.git.lucien.xin@gmail.com>
Cc: mleitner@redhat.com, vyasevic@redhat.com, daniel@iogearbox.net,
	davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:36719 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751184AbbL3Pu5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Dec 2015 10:50:57 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

for telecom center, the usual case is that a server is connected by thousands
of clients. but if the server with only one enpoint(udp style) use the same
sport and dport to communicate with every clients, and every assoc in server
will be hashed in the same chain of global assoc hashtable due to currently we
choose dport and sport as the hash key.

when a packet is received, sctp_rcv try to find the assoc with sport and dport,
since that chain is too long to find it fast, it make the performance turn to
very low, some test data is as follow:

in server:
$./ss [start a udp style server there]
in client:
$./cc [start 2500 sockets to connect server with same port and different ip,
       and use one of them to send data to server]

===== test on net-next
-- perf top
server:
  55.73%  [kernel]             [k] sctp_assoc_is_match
   6.80%  [kernel]             [k] sctp_assoc_lookup_paddr
   4.81%  [kernel]             [k] sctp_v4_cmp_addr
   3.12%  [kernel]             [k] _raw_spin_unlock_irqrestore
   1.94%  [kernel]             [k] sctp_cmp_addr_exact

client:
  46.01%  [kernel]                    [k] sctp_endpoint_lookup_assoc
   5.55%  libc-2.17.so                [.] __libc_calloc
   5.39%  libc-2.17.so                [.] _int_free
   3.92%  libc-2.17.so                [.] _int_malloc
   3.23%  [kernel]                    [k] __memset

-- spent time
time is 487s, send pkt is 10000000

we need to change the way to calculate the hash key, to use lport +
rport + paddr as the hash key can avoid this issue.

besides, this patchset will use transport hashtable to replace
association hashtable to lookup with rhashtable api. get transport
first then get association by t->asoc. and also it will make tcp
style work better.

===== test with this patchset:
-- perf top
server:
  15.98%  [kernel]                 [k] _raw_spin_unlock_irqrestore
   9.92%  [kernel]                 [k] __pv_queued_spin_lock_slowpath
   7.22%  [kernel]                 [k] copy_user_generic_string
   2.38%  libpthread-2.17.so       [.] __recvmsg_nocancel
   1.88%  [kernel]                 [k] sctp_recvmsg

client:
  11.90%  [kernel]                   [k] sctp_hash_cmp
   8.52%  [kernel]                   [k] rht_deferred_worker
   4.94%  [kernel]                   [k] __pv_queued_spin_lock_slowpath
   3.95%  [kernel]                   [k] sctp_bind_addr_match
   2.49%  [kernel]                   [k] __memset

-- spent time
time is 22s, send pkt is 10000000

Xin Long (5):
  sctp: add the rhashtable apis for sctp global transport hashtable
  sctp: apply rhashtable api to send/recv path
  sctp: apply rhashtable api to sctp procfs
  sctp: drop the old assoc hashtable of sctp
  sctp: remove the local_bh_disable/enable in sctp_endpoint_lookup_assoc

 include/net/sctp/sctp.h    |  32 ++---
 include/net/sctp/structs.h |  10 +-
 net/sctp/associola.c       |   5 +
 net/sctp/endpointola.c     |  52 ++------
 net/sctp/input.c           | 187 +++++++++++++++++----------
 net/sctp/proc.c            | 316 +++++++++++++++++++++++++--------------------
 net/sctp/protocol.c        |  36 ++----
 net/sctp/sm_sideeffect.c   |   2 -
 net/sctp/socket.c          |   6 +-
 9 files changed, 331 insertions(+), 315 deletions(-)

-- 
2.1.0
