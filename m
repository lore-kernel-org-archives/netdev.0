From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: [PATCH net-next v2 0/5] Make tcp-metrics source-address aware
Date: Wed,  8 Jan 2014 16:05:54 +0100
Message-ID: <1389193559-16756-1-git-send-email-christoph.paasch@uclouvain.be>
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Yuchung Cheng <ycheng@google.com>, Julian Anastasov <ja@ssi.bg>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f53.google.com ([74.125.82.53]:49838 "EHLO
	mail-wg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754985AbaAHPGN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jan 2014 10:06:13 -0500
Received: by mail-wg0-f53.google.com with SMTP id k14so1538104wgh.8
        for <netdev@vger.kernel.org>; Wed, 08 Jan 2014 07:06:12 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently tcp-metrics only stores per-destination addresses. This brings
problems, when a host has multiple interfaces (e.g., a smartphone having
WiFi/3G):

For example, a host contacting a server over WiFi will store the tcp-metrics
per destination IP. If then the host contacts the same server over 3G, the
same tcp-metrics will be used, although the path-characteristics are completly
different (e.g., the ssthresh is probably not the same).

In case of TFO this is not a problem, as the server will provide us a new cookie
once he saw our SYN+DATA with an incorrect cookie.
It may be (in case of carrier-grade NAT), that we keep the same public IP but
have a different private IP. Thus, we better reuse the old cookie even if our
source-IP has changed. However, this scenario is probably very uncommon, as 
carriers try to provide the same src-IP to the clients behind their CGN.

Patches 1 + 2 add the source-IP to the tcp metrics.

Patches 3 to 5 modify the netlink-api to support the source-IP. From now on,
when using the command "ip tcp_metrics delete address ADDRESS" all entries
which match this destination IP will be deleted.

Today's iproute2 will complain when doing "ip tcp_metrics flush PREFIX" if
several entries are present for the same destination-IP but with different
source-IPs:

root@client:~/test# ip tcp_metrics
10.2.1.2 age 3.640sec rtt 16250us rttvar 15000us cwnd 10
10.2.1.2 age 4.030sec rtt 18750us rttvar 15000us cwnd 10
root@client:~/test# ip tcp_metrics flush 10.2.1.2/16
Failed to send flush request
: No such process


Follow-up patches will modify iproute2 to handle this correctly and allow
specifying the source-IP in the get/del commands.


v2: Added the patch that allows to selectively get/del of tcp-metrics based
    on src-IP and moved the patch that adds the new netlink attribute before
    the other patches.

Christoph Paasch (5):
  tcp: metrics: rename tcpm_addr to tcpm_daddr
  tcp: metrics: Add source-address to tcp-metrics
  tcp: metrics: New netlink attribute for src IP and dumped in netlink
    reply
  tcp: metrics: Delete all entries matching a certain destination
  tcp: metrics: Allow selective get/del of tcp-metrics based on src IP

 include/uapi/linux/tcp_metrics.h |   2 +
 net/ipv4/tcp_metrics.c           | 151 ++++++++++++++++++++++++++-------------
 2 files changed, 105 insertions(+), 48 deletions(-)

-- 
1.8.3.2
