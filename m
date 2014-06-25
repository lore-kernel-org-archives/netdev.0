From: Octavian Purdila <octavian.purdila@intel.com>
Subject: [net-next v2 00/13] remove code duplication in tcp_v[46]_conn_request
Date: Wed, 25 Jun 2014 17:09:49 +0300
Message-ID: <1403705402-14388-1-git-send-email-octavian.purdila@intel.com>
Cc: Octavian Purdila <octavian.purdila@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:45741 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754206AbaFYOK2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Jun 2014 10:10:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series unifies the TCPv4 and TCPv6 connection request flow
in a single new function (tcp_conn_request).

The first 3 patches are small cleanups and fixes found during the code
merge process.

The next patches add new methods in tcp_request_sock_ops to abstract
the IPv4/IPv6 operations and keep the TCP connection request flow
common.

To identify potential performance issues this patch has been tested
by measuring the connection per second rate with nginx and a httperf
like client (to allow for concurrent connection requests - 256 CC were
used during testing) using the loopback interface. A dual-core i5 Ivy
Bridge processor was used and each process was bounded to a different
core to make results consistent.

Results for IPv4, unit is connections per second, higher is better, 20
measurements have been collected:

		before		after
min		27917		27962
max		28262		28366
avg		28094.1		28212.75
stdev		87.35		97.26

Results for IPv6, unit is connections per second, higher is better, 20
measurements have been collected:

		before		after
min		24813		24877
max		25029		25119
avg		24935.5		25017
stdev		64.13		62.93


Changes since v1:

 * add benchmarking datapoints

 * fix a few issues in the last patch (IPv6 related)


Octavian Purdila (13):
  tcp: cookie_v4_init_sequence: skb should be const
  tcp: tcp_v[46]_conn_request: fix snt_synack initialization
  net: remove inet6_reqsk_alloc
  tcp: add init_req method to tcp_request_sock_ops
  tcp: add init_cookie_seq method to tcp_request_sock_ops
  tcp: add route_req method to tcp_request_sock_ops
  tcp: move around a few calls in tcp_v6_conn_request
  tcp: add init_seq method to tcp_request_sock_ops
  tcp: add send_synack method to tcp_request_sock_ops
  tcp: unify tcp_v4_rtx_synack and tcp_v6_rtx_synack
  tcp: add mss_clamp to tcp_request_sock_ops
  tcp: add queue_add_hash to tcp_request_sock_ops
  tcp: add tcp_conn_request

 include/linux/ipv6.h    |  10 ---
 include/linux/tcp.h     |   3 -
 include/net/inet_sock.h |   6 +-
 include/net/tcp.h       |  54 +++++++++----
 net/dccp/ipv6.c         |   2 +-
 net/ipv4/syncookies.c   |   3 +-
 net/ipv4/tcp_input.c    | 148 ++++++++++++++++++++++++++++++++++
 net/ipv4/tcp_ipv4.c     | 188 ++++++++++---------------------------------
 net/ipv4/tcp_output.c   |  15 ++++
 net/ipv6/syncookies.c   |   2 +-
 net/ipv6/tcp_ipv6.c     | 206 +++++++++++++-----------------------------------
 11 files changed, 306 insertions(+), 331 deletions(-)

-- 
1.8.3.2
