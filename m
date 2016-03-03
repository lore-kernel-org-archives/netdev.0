From: "=?UTF-8?q?Bendik=20R=C3=B8nning=20Opstad?=" <bro.devel@gmail.com>
Subject: [PATCH v6 net-next 0/2] tcp: Redundant Data Bundling (RDB)
Date: Thu,  3 Mar 2016 19:06:26 +0100
Message-ID: <1457028388-18226-1-git-send-email-bro.devel+kernel@gmail.com>
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
Received: from mail-lb0-f194.google.com ([209.85.217.194]:33409 "EHLO
	mail-lb0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758105AbcCCSGj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2016 13:06:39 -0500
Received: by mail-lb0-f194.google.com with SMTP id bc4so2586826lbc.0
        for <netdev@vger.kernel.org>; Thu, 03 Mar 2016 10:06:38 -0800 (PST)
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

Note: Current patch set depends on the patch "tcp: refactor struct tcp_=
skb_cb"
(http://patchwork.ozlabs.org/patch/510674)

These patches have also been tested with as set of packetdrill scripts
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

 Documentation/networking/ip-sysctl.txt |  23 ++++
 include/linux/skbuff.h                 |   1 +
 include/linux/tcp.h                    |   3 +-
 include/net/tcp.h                      |  36 ++++++
 include/uapi/linux/tcp.h               |   1 +
 net/core/skbuff.c                      |   2 +-
 net/ipv4/Makefile                      |   3 +-
 net/ipv4/sysctl_net_ipv4.c             |  34 +++++
 net/ipv4/tcp.c                         |  16 ++-
 net/ipv4/tcp_input.c                   |   3 +
 net/ipv4/tcp_output.c                  |  48 ++++---
 net/ipv4/tcp_rdb.c                     | 228 +++++++++++++++++++++++++=
++++++++
 12 files changed, 375 insertions(+), 23 deletions(-)
 create mode 100644 net/ipv4/tcp_rdb.c

--=20
1.9.1
