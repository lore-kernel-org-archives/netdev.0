From: "=?UTF-8?q?Bendik=20R=C3=B8nning=20Opstad?=" <bro.devel@gmail.com>
Subject: [PATCH v3 net-next 0/2] tcp: Redundant Data Bundling (RDB)
Date: Tue,  2 Feb 2016 20:23:13 +0100
Message-ID: <1454440995-18457-1-git-send-email-bro.devel+kernel@gmail.com>
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
	Kenneth Klette Jonassen <kennetkl@ifi.uio.no>,
	=?UTF-8?q?Bendik=20R=C3=B8nning=20Opstad?=
	<bro.devel+kernel@gmail.com>
To: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f194.google.com ([209.85.217.194]:35717 "EHLO
	mail-lb0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753395AbcBBTYI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2016 14:24:08 -0500
Received: by mail-lb0-f194.google.com with SMTP id dx9so7111434lbc.2
        for <netdev@vger.kernel.org>; Tue, 02 Feb 2016 11:24:06 -0800 (PST)
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

 Documentation/networking/ip-sysctl.txt |  23 +++
 include/linux/skbuff.h                 |   1 +
 include/linux/tcp.h                    |   3 +-
 include/net/tcp.h                      |  35 +++++
 include/uapi/linux/tcp.h               |   1 +
 net/core/skbuff.c                      |   3 +-
 net/ipv4/Makefile                      |   3 +-
 net/ipv4/sysctl_net_ipv4.c             |  35 +++++
 net/ipv4/tcp.c                         |  16 +-
 net/ipv4/tcp_input.c                   |   3 +
 net/ipv4/tcp_output.c                  |  11 +-
 net/ipv4/tcp_rdb.c                     | 273 +++++++++++++++++++++++++=
++++++++
 12 files changed, 399 insertions(+), 8 deletions(-)
 create mode 100644 net/ipv4/tcp_rdb.c

--=20
1.9.1
