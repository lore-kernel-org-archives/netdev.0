From: "=?UTF-8?q?Bendik=20R=C3=B8nning=20Opstad?=" <bro.devel@gmail.com>
Subject: [PATCH v7 net-next 0/2] tcp: Redundant Data Bundling (RDB)
Date: Wed, 22 Jun 2016 16:56:08 +0200
Message-ID: <1466607370-24514-1-git-send-email-bro.devel+kernel@gmail.com>
References: <1445633413-3532-1-git-send-email-bro.devel+kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Yuchung Cheng <ycheng@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Neal Cardwell <ncardwell@google.com>,
	Andreas Petlund <apetlund@simula.no>,
	Carsten Griwodz <griff@simula.no>,
	=?UTF-8?q?P=C3=A5l=20Halvorsen?= <paalh@simula.no>,
	Jonas Markussen <jonassm@ifi.uio.no>,
	Kristian Evensen <kristian.evensen@gmail.com>,
	Kenneth Klette Jonassen <kennetkl@ifi.uio.no>
To: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f48.google.com ([209.85.215.48]:34521 "EHLO
	mail-lf0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751577AbcFVO4Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jun 2016 10:56:16 -0400
Received: by mail-lf0-f48.google.com with SMTP id h129so76406549lfh.1
        for <netdev@vger.kernel.org>; Wed, 22 Jun 2016 07:56:15 -0700 (PDT)
In-Reply-To: <1445633413-3532-1-git-send-email-bro.devel+kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Redundant Data Bundling (RDB) is a mechanism for TCP aimed at reducing
the latency for applications sending time-dependent data.
Latency-sensitive applications or services, such as online games and
remote desktop, produce traffic with thin-stream characteristics,
characterized by small packets and a relatively high ITT. By bundling
already sent data in packets with new data, RDB alleviates head-of-line
blocking by reducing the need to retransmit data segments when packets
are lost. RDB is a continuation on the work on latency improvements for
TCP in Linux, previously resulting in two thin-stream mechanisms in the
Linux kernel
(https://github.com/torvalds/linux/blob/master/Documentation/networking=
/tcp-thin.txt).

The RDB implementation has been thoroughly tested, and shows
significant latency reductions when packet loss occurs[1]. The tests
show that, by imposing restrictions on the bundling rate, it can be
made not to negatively affect competing traffic in an unfair manner.

These patches have also been tested with a set of packetdrill scripts
located at
https://github.com/bendikro/packetdrill/tree/master/gtests/net/packetdr=
ill/tests/linux/rdb
(The tests require patching packetdrill with a new socket option:
https://github.com/bendikro/packetdrill/commit/9916b6c53e33dd04329d29b7=
d8baf703b2c2ac1b)

Detailed info about the RDB mechanism can be found at
http://mlab.no/blog/2015/10/redundant-data-bundling-in-tcp, as well as
in the paper "Latency and Fairness Trade-Off for Thin Streams using
Redundant Data Bundling in TCP"[2].

[1] http://home.ifi.uio.no/paalh/students/BendikOpstad.pdf
[2] http://home.ifi.uio.no/bendiko/rdb_fairness_tradeoff.pdf


Changes:

v7 (PATCH):
 * tcp-Add-Redundant-Data-Bundling-RDB:
   * Changed sysctl_tcp_rdb to accept three values (Thanks Yuchung):
     - 0: Disable system wide (RDB cannot be enabled with TCP_RDB socke=
t option)
     - 1: Allow enabling RDB with TCP_RDB socket option.
     - 2: Enable RDB by default on all TCP sockets and allow to modify =
with TCP_RDB
   * Added sysctl tcp_rdb_wait_congestion to control if RDB by default =
should
     wait for congestion before bundling. (Ref. comment by Eric on loss=
less conns)
   * Changed socket options to modify per-socket RDB settings:
     - Added flags to TCP_RDB to allow bundling without waiting for los=
s with
       TCP_RDB_BUNDLE_IMMEDIATE.
     - Added socket option TCP_RDB_MAX_BYTES: Set max bytes per RDB pac=
ket.
     - Added socket option TCP_RDB_MAX_PACKETS: Set max packets allowed=
 to be
       bundled by RDB.
   * Added SNMP counter LINUX_MIB_TCPRDBLOSSREPAIRS to count the occure=
nces
     where RDB repaired a loss (Thanks Eric).
   * Bundle on FIN packets (Thanks Yuchung).
   * Updated docs in Documentation/networking/{ip-sysctl.txt,tcp-thin.t=
xt}
   * Removed flags parameter from tcp_rdb_ack_event()
   * Changed sysctl knobs to using network namespace.

 * tcp-Add-DPIFL-thin-stream-detection-mechanism:
   * Changed sysctl knobs to using network namespace

v6 (PATCH):
 * tcp-Add-Redundant-Data-Bundling-RDB:
   * Renamed rdb_ack_event() to tcp_rdb_ack_event() (Thanks DaveM)
   * Minor doc changes

 * tcp-Add-DPIFL-thin-stream-detection-mechanism:
   * Minor doc changes

v5 (PATCH):
 * tcp-Add-Redundant-Data-Bundling-RDB:
   * Removed two unnecessary EXPORT_SYMOBOLs (Thanks Eric)
   * Renamed skb_append_data() to tcp_skb_append_data() (Thanks Eric)
   * Fixed bugs in additions to ipv4_table (sysctl_net_ipv4.c)
   * Merged the two if tests for max payload of RDB packet in
     rdb_can_bundle_test()
   * Renamed rdb_check_rtx_queue_loss() to rdb_detect_loss()
     and restructured to reduce indentation.
   * Improved docs
   * Revised commit message to be more detailed.

 * tcp-Add-DPIFL-thin-stream-detection-mechanism:
   * Fixed bug in additions to ipv4_table (sysctl_net_ipv4.c)

v4 (PATCH):
 * tcp-Add-Redundant-Data-Bundling-RDB:
   * Moved skb_append_data() to tcp_output.c and call this
     function from tcp_collapse_retrans() as well.
   * Merged functionality of create_rdb_skb() into
     tcp_transmit_rdb_skb()
   * Removed one parameter from rdb_can_bundle_test()

v3 (PATCH):
 * tcp-Add-Redundant-Data-Bundling-RDB:
   * Changed name of sysctl variable from tcp_rdb_max_skbs to
     tcp_rdb_max_packets after comment from Eric Dumazet about
     not exposing internal (kernel) names like skb.
   * Formatting and function docs fixes

v2 (RFC/PATCH):
 * tcp-Add-DPIFL-thin-stream-detection-mechanism:
   * Change calculation in tcp_stream_is_thin_dpifl based on
     feedback from Eric Dumazet.

 * tcp-Add-Redundant-Data-Bundling-RDB:
   * Removed setting nonagle in do_tcp_setsockopt (TCP_RDB)
     to reduce complexity as commented by Neal Cardwell.
   * Cleaned up loss detection code in rdb_check_rtx_queue_loss

v1 (RFC/PATCH)


Bendik R=C3=B8nning Opstad (2):
  tcp: Add DPIFL thin stream detection mechanism
  tcp: Add Redundant Data Bundling (RDB)

 Documentation/networking/ip-sysctl.txt |  43 ++++++
 Documentation/networking/tcp-thin.txt  | 188 ++++++++++++++++++++-----=
-
 include/linux/skbuff.h                 |   1 +
 include/linux/tcp.h                    |  11 +-
 include/net/netns/ipv4.h               |   6 +
 include/net/tcp.h                      |  33 +++++
 include/uapi/linux/snmp.h              |   1 +
 include/uapi/linux/tcp.h               |  10 ++
 net/core/skbuff.c                      |   2 +-
 net/ipv4/Makefile                      |   3 +-
 net/ipv4/proc.c                        |   1 +
 net/ipv4/sysctl_net_ipv4.c             |  43 ++++++
 net/ipv4/tcp.c                         |  42 +++++-
 net/ipv4/tcp_input.c                   |   3 +
 net/ipv4/tcp_ipv4.c                    |   6 +
 net/ipv4/tcp_output.c                  |  49 ++++---
 net/ipv4/tcp_rdb.c                     | 240 +++++++++++++++++++++++++=
++++++++
 17 files changed, 619 insertions(+), 63 deletions(-)
 create mode 100644 net/ipv4/tcp_rdb.c

--=20
2.1.4
