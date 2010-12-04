From: Tom Herbert <therbert@google.com>
Subject: [PATCH] tcp: Replace time wait bucket msg by counter.
Date: Sat, 4 Dec 2010 13:35:38 -0800 (PST)
Message-ID: <alpine.DEB.2.00.1012041331220.6278@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.35]:22103 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755802Ab0LDVfo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Dec 2010 16:35:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rather than printing the message to the log, use a mib counter to keep
track of the count of occurences of time wait bucket overflow.  Reduces
spam in logs.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/linux/snmp.h     |    1 +
 net/ipv4/proc.c          |    1 +
 net/ipv4/tcp_minisocks.c |    2 +-
 3 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/include/linux/snmp.h b/include/linux/snmp.h
index ebb0c80..12b2b18 100644
--- a/include/linux/snmp.h
+++ b/include/linux/snmp.h
@@ -230,6 +230,7 @@ enum
 	LINUX_MIB_TCPMINTTLDROP, /* RFC 5082 */
 	LINUX_MIB_TCPDEFERACCEPTDROP,
 	LINUX_MIB_IPRPFILTER, /* IP Reverse Path Filter (rp_filter) */
+	LINUX_MIB_TCPTIMEWAITOVERFLOW,		/* TCPTimeWaitOverflow */
 	__LINUX_MIB_MAX
 };
 
diff --git a/net/ipv4/proc.c b/net/ipv4/proc.c
index 1b48eb1..b14ec7d 100644
--- a/net/ipv4/proc.c
+++ b/net/ipv4/proc.c
@@ -253,6 +253,7 @@ static const struct snmp_mib snmp4_net_list[] = {
 	SNMP_MIB_ITEM("TCPMinTTLDrop", LINUX_MIB_TCPMINTTLDROP),
 	SNMP_MIB_ITEM("TCPDeferAcceptDrop", LINUX_MIB_TCPDEFERACCEPTDROP),
 	SNMP_MIB_ITEM("IPReversePathFilter", LINUX_MIB_IPRPFILTER),
+	SNMP_MIB_ITEM("TCPTimeWaitOverflow", LINUX_MIB_TCPTIMEWAITOVERFLOW),
 	SNMP_MIB_SENTINEL
 };
 
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 43cf901..3052a2b 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -347,7 +347,7 @@ void tcp_time_wait(struct sock *sk, int state, int timeo)
 		 * socket up.  We've got bigger problems than
 		 * non-graceful socket closings.
 		 */
-		LIMIT_NETDEBUG(KERN_INFO "TCP: time wait bucket table overflow\n");
+		NET_INC_STATS(sock_net(sk), LINUX_MIB_TCPTIMEWAITOVERFLOW);
 	}
 
 	tcp_update_metrics(sk);
-- 
1.7.3.1

