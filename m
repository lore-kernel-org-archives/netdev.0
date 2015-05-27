From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp/dccp: warn user for preferred
 ip_local_port_range
Date: Wed, 27 May 2015 11:34:37 -0700
Message-ID: <1432751677.4060.423.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f172.google.com ([209.85.223.172]:36209 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751597AbbE0Sej (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2015 14:34:39 -0400
Received: by iepj10 with SMTP id j10so20417030iep.3
        for <netdev@vger.kernel.org>; Wed, 27 May 2015 11:34:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

After commit 07f4c90062f8f ("tcp/dccp: try to not exhaust
ip_local_port_range in connect()") it is advised to have an even number
of ports described in /proc/sys/net/ipv4/ip_local_port_range

This means start/end values should have a different parity.

Let's warn sysadmins of this, so that they can update their settings
if they want to.

Suggested-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/netns/ipv4.h   |    1 +
 net/ipv4/sysctl_net_ipv4.c |    6 ++++++
 2 files changed, 7 insertions(+)

diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index 6848b8bb2e6319ac9ddd90dd45b39eb01c6c9ff8..c68926b4899c36e77c38b6244dfb8d126685b905 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -19,6 +19,7 @@ struct sock;
 struct local_ports {
 	seqlock_t	lock;
 	int		range[2];
+	bool		warned;
 };
 
 struct ping_group_range {
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index e64892769607a6089e10d5c9e63dc3564c983341..708861046c6131736d8931ecfca421a629146a50 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -45,7 +45,13 @@ static int ip_ping_group_range_max[] = { GID_T_MAX, GID_T_MAX };
 /* Update system visible IP port range */
 static void set_local_port_range(struct net *net, int range[2])
 {
+	bool same_parity = !((range[0] ^ range[1]) & 1);
+
 	write_seqlock(&net->ipv4.ip_local_ports.lock);
+	if (same_parity && !net->ipv4.ip_local_ports.warned) {
+		net->ipv4.ip_local_ports.warned = true;
+		pr_err_ratelimited("ip_local_port_range: prefer different parity for start/end values.\n");
+	}
 	net->ipv4.ip_local_ports.range[0] = range[0];
 	net->ipv4.ip_local_ports.range[1] = range[1];
 	write_sequnlock(&net->ipv4.ip_local_ports.lock);
