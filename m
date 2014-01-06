From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next v2 3/3] ipv4: introduce hardened ip_no_pmtu_disc mode
Date: Mon, 6 Jan 2014 09:48:36 +0100
Message-ID: <20140106084836.GA5843@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: eric.dumazet@gmail.com, davem@davemloft.net,
	johnwheffner@gmail.com, fweimer@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:41555 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753427AbaAFIsi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jan 2014 03:48:38 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This new ip_no_pmtu_disc mode only allowes fragmentation-needed errors
to be honored by protocols which do more stringent validation on the
ICMP's packet payload. This knob is useful for people who e.g. want to
run an unmodified DNS server in a namespace where they need to use pmtu
for TCP connections (as they are used for zone transfers or fallback
for requests) but don't want to use possibly spoofed UDP pmtu information.

Currently the whitelisted protocols are TCP, SCTP and DCCP as they check
if the returned packet is in the window or if the association is valid.

Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: David Miller <davem@davemloft.net>
Cc: John Heffner <johnwheffner@gmail.com>
Suggested-by: Florian Weimer <fweimer@redhat.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
v2)
* reworded Documentation

 Documentation/networking/ip-sysctl.txt | 13 ++++++++++++-
 include/net/protocol.h                 |  7 ++++++-
 net/dccp/ipv4.c                        |  1 +
 net/ipv4/af_inet.c                     |  1 +
 net/ipv4/icmp.c                        | 28 ++++++++++++++++++++++++----
 net/sctp/protocol.c                    |  1 +
 6 files changed, 45 insertions(+), 6 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index 2d164a3..3b230c5 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -26,7 +26,18 @@ ip_no_pmtu_disc - INTEGER
 	discarded. Outgoing frames are handled the same as in mode 1,
 	implicitly setting IP_PMTUDISC_DONT on every created socket.
 
-	Possible values: 0-2
+	Mode 3 is a hardend pmtu discover mode. The kernel will only
+	accept fragmentation-needed errors if the underlying protocol
+	can verify them besides a plain socket lookup. Current
+	protocols for which pmtu events will be honored are TCP, SCTP
+	and DCCP as they verify e.g. the sequence number or the
+	association. This mode should not be enabled globally but is
+	only intended to secure e.g. name servers in namespaces where
+	TCP path mtu must still work but path MTU information of other
+	protocols should be discarded. If enabled globally this mode
+	could break other protocols.
+
+	Possible values: 0-3
 	Default: FALSE
 
 min_pmtu - INTEGER
diff --git a/include/net/protocol.h b/include/net/protocol.h
index fbf7676..0e5f866 100644
--- a/include/net/protocol.h
+++ b/include/net/protocol.h
@@ -43,7 +43,12 @@ struct net_protocol {
 	int			(*handler)(struct sk_buff *skb);
 	void			(*err_handler)(struct sk_buff *skb, u32 info);
 	unsigned int		no_policy:1,
-				netns_ok:1;
+				netns_ok:1,
+				/* does the protocol do more stringent
+				 * icmp tag validation than simple
+				 * socket lookup?
+				 */
+				icmp_strict_tag_validation:1;
 };
 
 #if IS_ENABLED(CONFIG_IPV6)
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index 88299c2..22b5d81 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -989,6 +989,7 @@ static const struct net_protocol dccp_v4_protocol = {
 	.err_handler	= dccp_v4_err,
 	.no_policy	= 1,
 	.netns_ok	= 1,
+	.icmp_strict_tag_validation = 1,
 };
 
 static const struct proto_ops inet_dccp_ops = {
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index b8bc1a3..be1f553 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1539,6 +1539,7 @@ static const struct net_protocol tcp_protocol = {
 	.err_handler	=	tcp_v4_err,
 	.no_policy	=	1,
 	.netns_ok	=	1,
+	.icmp_strict_tag_validation = 1,
 };
 
 static const struct net_protocol udp_protocol = {
diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index fb3c563..0134663 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -668,6 +668,16 @@ static void icmp_socket_deliver(struct sk_buff *skb, u32 info)
 	rcu_read_unlock();
 }
 
+static bool icmp_tag_validation(int proto)
+{
+	bool ok;
+
+	rcu_read_lock();
+	ok = rcu_dereference(inet_protos[proto])->icmp_strict_tag_validation;
+	rcu_read_unlock();
+	return ok;
+}
+
 /*
  *	Handle ICMP_DEST_UNREACH, ICMP_TIME_EXCEED, ICMP_QUENCH, and
  *	ICMP_PARAMETERPROB.
@@ -705,12 +715,22 @@ static void icmp_unreach(struct sk_buff *skb)
 		case ICMP_PORT_UNREACH:
 			break;
 		case ICMP_FRAG_NEEDED:
-			if (net->ipv4.sysctl_ip_no_pmtu_disc == 2) {
-				goto out;
-			} else if (net->ipv4.sysctl_ip_no_pmtu_disc) {
+			/* for documentation of the ip_no_pmtu_disc
+			 * values please see
+			 * Documentation/networking/ip-sysctl.txt
+			 */
+			switch (net->ipv4.sysctl_ip_no_pmtu_disc) {
+			default:
 				LIMIT_NETDEBUG(KERN_INFO pr_fmt("%pI4: fragmentation needed and DF set\n"),
 					       &iph->daddr);
-			} else {
+				break;
+			case 2:
+				goto out;
+			case 3:
+				if (!icmp_tag_validation(iph->protocol))
+					goto out;
+				/* fall through */
+			case 0:
 				info = ntohs(icmph->un.frag.mtu);
 				if (!info)
 					goto out;
diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index 34b7726..7c16108 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -1030,6 +1030,7 @@ static const struct net_protocol sctp_protocol = {
 	.err_handler = sctp_v4_err,
 	.no_policy   = 1,
 	.netns_ok    = 1,
+	.icmp_strict_tag_validation = 1,
 };
 
 /* IPv4 address related functions.  */
-- 
1.8.4.2
