From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: [PATCH 0/4] Make tcp-metrics source-address aware
Date: Sun, 15 Dec 2013 13:10:40 +0100
Message-ID: <1387109444-1104-1-git-send-email-christoph.paasch@uclouvain.be>
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Julian Anastasov <ja@ssi.bg>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:39002 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754028Ab3LOMLE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Dec 2013 07:11:04 -0500
Received: by mail-ee0-f46.google.com with SMTP id d49so1642198eek.5
        for <netdev@vger.kernel.org>; Sun, 15 Dec 2013 04:11:02 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently tcp-metrics only stores per-destination addresses. This brings
problems, when a host has multiple interfaces (e.g., a smartphone having
WiFi/3G):

For example, a host contacting a server over WiFi will store the tcp-metrics
per destination IP. If then the host contacts the same server over 3G, the 
same tcp-metrics will be used, although the path-characteristics are completly
different (e.g., the ssthresh is probably not the same).

The same holds for the fast-open cookie. The server will generate a cookie
based on our source-address. So, if we contact the same server with another
source-IP we should request a new cookie.

This patchset makes tcp-metrics source-address aware (Patch 1 and 2).

Patches 3 and 4 handle the interface to "ip tcp_metrics". When deleting a
metric based on the destination-IP, all entries will be removed (Patch 3).
Further, a new attribute is added, so that the source-IP can be exposed to
"ip tcp_metrics" (Patch 4).

Note:
"ip tcp_metrics show ADDRESS" will only display the first element among
the entries for the specified destination-IP. It probably would be better to
show all entries for the specified IP. However, I do not see how to achieve 
this without fundamentally changing the netlink-API for the tcp-metrics.

Suggestions are very welcome.


Christoph Paasch (4):
  tcp: metrics: rename tcpm_addr to tcpm_daddr
  tcp: metrics: Add source-address to tcp-metrics
  tcp: metrics: Delete all entries matching a certain destination
  tcp: metrics: Dump info of the source-address in netlink-reply

 include/uapi/linux/tcp_metrics.h |   2 +
 net/ipv4/tcp_metrics.c           | 111 ++++++++++++++++++++++++---------------
 2 files changed, 71 insertions(+), 42 deletions(-)

-- 
1.8.3.2
