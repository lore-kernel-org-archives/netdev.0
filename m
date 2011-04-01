From: Florian Adamsky <florian-netdev@adamsky.it>
Subject: Duplicated Acknowledgments
Date: Fri, 1 Apr 2011 08:20:49 +0200
Message-ID: <20110401082049.03c59625@asmara>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static.109.81.47.78.clients.your-server.de ([78.47.81.109]:48022
	"EHLO haktar.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754142Ab1DAG03 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Apr 2011 02:26:29 -0400
Received: from asmara (p4FE8F073.dip.t-dialin.net [79.232.240.115])
	(using TLSv1 with cipher DHE-RSA-AES128-SHA (128/128 bits))
	(No client certificate requested)
	(Authenticated sender: cit)
	by haktar.org (Postfix) with ESMTPSA id DF30B258EBAC
	for <netdev@vger.kernel.org>; Fri,  1 Apr 2011 08:20:50 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Kernel-Hackers,

I'm a security researcher and want to try out the opt-ack and lazy
opt-ack attack with different congestion avoidance systems and under
different environments. At first I want to dedicate myself to the lazy
opt-ack attack. For those of you how are not familiar with it: the
attacker has an modified TCP/IP stack which doesn't send any duplicated
acknowledgements. If the receiver is in slow start and doesn't get any
duplicated ack, he will introduce more and more packets into the
network. [1]

I'm not a kernel hacker but I know a litte bit of C. So I found the
function "tcp_send_dupack()". Additionally I wrote a sysctl for it to
activate and deactivate this behaviour. After trying this out I don't
get the expected results. I start to analyze my pcap file with tcptrace
and it says the attacker sends 22 duplicated acks. Attached you'll find
my changes on the code I made. I want to be absolutely sure that I
don't miss anything, so is there any other place in the source I have
to modify?

Thank you very much in advance. Btw I know that window updates are
looking like duplicated acks, I only want to be sure that the kernel is
not sending any duplicated acks.

Best wishes,
Florian

[1] http://www.cs.umd.edu/~capveg/optack/optack-extended.pdf


--- /home/cit/linux-source-2.6.35/include/net/tcp.h	2011-03-01
15:40:39.000000000 +0100 +++ include/net/tcp.h	2011-03-25
22:57:08.403570245 +0100 @@ -205,6 +205,7 @@
 extern int sysctl_tcp_timestamps;
 extern int sysctl_tcp_window_scaling;
 extern int sysctl_tcp_sack;
+extern int sysctl_tcp_send_dupack;
 extern int sysctl_tcp_fin_timeout;
 extern int sysctl_tcp_keepalive_time;
 extern int sysctl_tcp_keepalive_probes;
       
--- /home/cit/linux-source-2.6.35/net/ipv4/sysctl_net_ipv4.c
2010-08-02 00:11:14.000000000 +0200 +++
net/ipv4/sysctl_net_ipv4.c	2011-03-25 22:44:32.687914571 +0100
@@ -141,6 +141,13 @@ .mode		= 0644,
 		.proc_handler	= proc_dointvec
 	},
+        {
+                .procname       = "tcp_send_dupack",
+                .data           = &sysctl_tcp_send_dupack,
+                .maxlen         = sizeof(int),
+                .mode           = 0644,
+                .proc_handler   = proc_dointvec
+        },
 	{
 		.procname	= "tcp_retrans_collapse",
 		.data		= &sysctl_tcp_retrans_collapse,

--- /home/cit/linux-source-2.6.35/net/ipv4/tcp_input.c
2011-03-01 15:40:39.000000000 +0100 +++ net/ipv4/tcp_input.c
2011-03-25 22:16:21.045352995 +0100 @@ -76,6 +76,7 @@
 int sysctl_tcp_timestamps __read_mostly = 1;
 int sysctl_tcp_window_scaling __read_mostly = 1;
 int sysctl_tcp_sack __read_mostly = 1;
+int sysctl_tcp_send_dupack __read_mostly = 1;
 int sysctl_tcp_fack __read_mostly = 1;
 int sysctl_tcp_reordering __read_mostly = TCP_FASTRETRANS_THRESH;
 int sysctl_tcp_ecn __read_mostly = 2;
@@ -5154,7 +5155,8 @@
 	    tcp_paws_discard(sk, skb)) {
 		if (!th->rst) {
 			NET_INC_STATS_BH(sock_net(sk),
LINUX_MIB_PAWSESTABREJECTED);
-			tcp_send_dupack(sk, skb);
+			if (sysctl_tcp_send_dupack)
+				tcp_send_dupack(sk, skb);
 			goto discard;
 		}
 		/* Reset is accepted even if it did not pass PAWS. */
@@ -5169,7 +5171,8 @@
 		 * bit is set, if so drop the segment and return)".
 		 */
 		if (!th->rst)
-			tcp_send_dupack(sk, skb);
+			if (sysctl_tcp_send_dupack)
+				tcp_send_dupack(sk, skb);
 		goto discard;
 	}
