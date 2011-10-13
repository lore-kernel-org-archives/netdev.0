From: sveniu@opera.com
Subject: Route flagged RTCF_REDIRECTED without ICMP redirs?
Date: Thu, 13 Oct 2011 18:50:15 +0000
Message-ID: <20111013185015.fa2abpjlpw8c0408@staff.opera.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=UTF-8;
	DelSp="Yes";
	format="flowed"
Content-Transfer-Encoding: 8BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.opera.com ([213.236.208.81]:54603 "EHLO smtp.opera.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751731Ab1JMTBh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2011 15:01:37 -0400
Received: from staff.opera.com (www-data@e3.opera.com [213.236.208.179])
	by smtp.opera.com (8.14.3/8.14.3/Debian-5+lenny1) with ESMTP id p9DIoF0K011407
	for <netdev@vger.kernel.org>; Thu, 13 Oct 2011 18:50:15 GMT
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

How can a route end up with being flagged with RTCF_REDIRECTED, and
point to the default gateway, even though it's explicitly set to route
to another node in the same subnet, in the rpdb and routing tables?
There is zero trace of icmp redirects, and all redirect sysctls have
been disabled, and the route cache flushed before every test.

The flag is only set in route.c:rt_init_metrics() and check_peer_redir(),
only if peer->redirect_learned.a4 is set. The only place I see that
being modified, is in route.c:ip_rt_redirect(), which I only see called
from icmp.c:icmp_redirect(). What gives?

This is using kernel version 3.0.

This is happening on a two-node LVS/ipvs setup, where the master node A
schedules packets to node B, and due to having to use NETMAP to handle
multiple overlapping source subnets, node B must send return packets back
to node A for correct translation back to the requestor.

However, node B (172.16.0.3) insists on sending packets straight to its
default gateway (172.16.0.1). Excessive logging in all netfilter tables
and chains, and tcpdump on all interfaces, doesn't show abnormal activity.
Node B's lvs/ipvs does not touch the packet at all.

Here's how it looks after node B has seen a packet, and has responded (by
wrongly sending the response to its default gateway):

# ip route show cache
10.0.0.2 from 172.16.0.3 via 172.16.0.1 dev bond0.310
   cache <redirected>  ipid 0x80e3 rtt 80ms rttvar 70ms cwnd 10

Entry in the rpdb:

# ip rule show
0:      from all lookup local
99:     from 172.16.0.3 to 10.0.0.0/24 lookup to_node1
32766:  from all lookup main
32767:  from all lookup default
(The rpdb really should have eval/match counters, btw!)

Corresponding routing table:

# ip route show table to_node1
default via 172.16.0.2 dev bond0.310

# ip route show
default via 172.16.0.1 dev bond0.310
172.16.0.0/24 dev bond0.310  proto kernel  scope link  src 172.16.0.3
172.16.1.0/24 dev bond0.311  proto kernel  scope link  src 172.16.1.3

Relevant sysctls have been configured on both node A and B:
net.ipv4.conf.*.shared_media = 0
net.ipv4.conf.*.accept_redirects = 0
net.ipv4.conf.*.secure_redirects = 0
net.ipv4.conf.*.send_redirects = 0
* = {all,default,devices}
(Same for ipv6 too, for good measure, although there's no ipv6 traffic.)

Tcpdump on all interfaces shows no traces of any icmp activity. The
'netstat -s' icmp redirect counter does not increase.

What am I missing?

best regards,
Sven Ulland
