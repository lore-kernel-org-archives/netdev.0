From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH iproute2 net-next-3.11] ip: add support of link flag IFF_NOPROC
Date: Thu,  3 Oct 2013 15:30:19 +0200
Message-ID: <1380807019-4653-1-git-send-email-nicolas.dichtel@6wind.com>
References: <1380806905-4461-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:49928 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754437Ab3JCNaY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Oct 2013 09:30:24 -0400
In-Reply-To: <1380806905-4461-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When this flag is specified, /proc/sys/net/ipv[4|6]/[conf|neigh]/<dev> and
/proc/net/dev_snmp6/<dev> directories are not created.

This flag cannot be removed.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 include/linux/if.h    | 2 ++
 ip/ipaddress.c        | 1 +
 ip/iplink.c           | 3 +++
 man/man8/ip-link.8.in | 8 ++++++++
 4 files changed, 14 insertions(+)

diff --git a/include/linux/if.h b/include/linux/if.h
index 7f261c08e816..5b8a5ebff599 100644
--- a/include/linux/if.h
+++ b/include/linux/if.h
@@ -53,6 +53,8 @@
 
 #define IFF_ECHO	0x40000		/* echo sent packets		*/
 
+#define IFF_NOPROC	0x80000		/* no proc/sysctl directories	*/
+
 #define IFF_VOLATILE	(IFF_LOOPBACK|IFF_POINTOPOINT|IFF_BROADCAST|IFF_ECHO|\
 		IFF_MASTER|IFF_SLAVE|IFF_RUNNING|IFF_LOWER_UP|IFF_DORMANT)
 
diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 1c3e4da0d0da..b2e35028c844 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -116,6 +116,7 @@ static void print_link_flags(FILE *fp, unsigned flags, unsigned mdown)
 	_PF(LOWER_UP);
 	_PF(DORMANT);
 	_PF(ECHO);
+	_PF(NOPROC);
 #undef _PF
 	if (flags)
 		fprintf(fp, "%x", flags);
diff --git a/ip/iplink.c b/ip/iplink.c
index ada9d4255ba2..253ed1cc3f6f 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -50,6 +50,7 @@ void iplink_usage(void)
 		fprintf(stderr, "                   [ mtu MTU ]\n");
 		fprintf(stderr, "                   [ numtxqueues QUEUE_COUNT ]\n");
 		fprintf(stderr, "                   [ numrxqueues QUEUE_COUNT ]\n");
+		fprintf(stderr, "                   [ noproc ]\n");
 		fprintf(stderr, "                   type TYPE [ ARGS ]\n");
 		fprintf(stderr, "       ip link delete DEV type TYPE [ ARGS ]\n");
 		fprintf(stderr, "\n");
@@ -480,6 +481,8 @@ int iplink_parse(int argc, char **argv, struct iplink_req *req,
 				invarg("Invalid \"numrxqueues\" value\n", *argv);
 			addattr_l(&req->n, sizeof(*req), IFLA_NUM_RX_QUEUES,
 				  &numrxqueues, 4);
+		} else if (matches(*argv, "noproc") == 0) {
+			req->i.ifi_flags |= IFF_NOPROC;
 		} else {
 			if (strcmp(*argv, "dev") == 0) {
 				NEXT_ARG();
diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
index 76f92ddbd82c..b16d1a1f8a41 100644
--- a/man/man8/ip-link.8.in
+++ b/man/man8/ip-link.8.in
@@ -45,6 +45,8 @@ ip-link \- network device configuration
 .RB "[ " numrxqueues
 .IR QUEUE_COUNT " ]"
 .br
+.RB "[ " noproc " ]"
+.br
 .BR type " TYPE"
 .RI "[ " ARGS " ]"
 
@@ -197,6 +199,12 @@ specifies the number of transmit queues for new device.
 specifies the number of receive queues for new device.
 
 .TP
+.BI noproc
+specifies to no create iface related directories under /proc
+(/proc/sys/net/ipv[4|6]/[conf|neigh]/<dev> and
+/proc/net/dev_snmp6/<dev>)
+
+.TP
 VXLAN Type Support
 For a link of type 
 .I VXLAN
-- 
1.8.2.1
