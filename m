From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next] net: tcp_probe: allow more advanced ingress filtering by mark
Date: Fri, 23 Aug 2013 16:16:33 +0200
Message-ID: <1377267393-24604-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1450 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755013Ab3HWOQh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Aug 2013 10:16:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, the tcp_probe snooper can either filter packets by a given
port (handed to the module via module parameter e.g. port=80) or lets
all TCP traffic pass (port=0, default). When a port is specified, the
port number is tested against the sk's source/destination port. Thus,
if one of them matches, the information will be further processed for
the log.

As this is quite limited, allow for more advanced filtering possibilities
which can facilitate debugging/analysis with the help of the tcp_probe
snooper. Therefore, similarly as added to BPF machine in commit 7e75f93e
("pkt_sched: ingress socket filter by mark"), add the possibility to
use skb->mark as a filter.

If the mark is not being used otherwise, this allows ingress filtering
by flow (e.g. in order to track updates from only a single flow, or a
subset of all flows for a given port) and other things such as dynamic
logging and reconfiguration without removing/re-inserting the tcp_probe
module, etc. Simple example:

  insmod net/ipv4/tcp_probe.ko fwmark=8888 full=1
  ...
  iptables -A INPUT -i eth4 -t mangle -p tcp --dport 22 \
           --sport 60952 -j MARK --set-mark 8888
  [... sampling interval ...]
  iptables -D INPUT -i eth4 -t mangle -p tcp --dport 22 \
           --sport 60952 -j MARK --set-mark 8888

The current option to filter by a given port is still being preserved. A
similar approach could be done for the sctp_probe module as a follow-up.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 net/ipv4/tcp_probe.c | 15 +++++++++++----
 1 file changed, 11 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/tcp_probe.c b/net/ipv4/tcp_probe.c
index 301a3ef..622a437 100644
--- a/net/ipv4/tcp_probe.c
+++ b/net/ipv4/tcp_probe.c
@@ -46,6 +46,10 @@ static unsigned int bufsize __read_mostly = 4096;
 MODULE_PARM_DESC(bufsize, "Log buffer size in packets (4096)");
 module_param(bufsize, uint, 0);
 
+static unsigned int fwmark __read_mostly = 0;
+MODULE_PARM_DESC(fwmark, "skb mark to match (0=no mark)");
+module_param(fwmark, uint, 0);
+
 static int full __read_mostly;
 MODULE_PARM_DESC(full, "Full log (1=every ack packet received,  0=only cwnd changes)");
 module_param(full, int, 0);
@@ -124,9 +128,11 @@ static int jtcp_rcv_established(struct sock *sk, struct sk_buff *skb,
 	const struct tcp_sock *tp = tcp_sk(sk);
 	const struct inet_sock *inet = inet_sk(sk);
 
-	/* Only update if port matches */
-	if ((port == 0 || ntohs(inet->inet_dport) == port ||
-	     ntohs(inet->inet_sport) == port) &&
+	/* Only update if port or skb mark matches */
+	if (((port == 0 && fwmark == 0) ||
+	     ntohs(inet->inet_dport) == port ||
+	     ntohs(inet->inet_sport) == port ||
+	     (fwmark > 0 && skb->mark == fwmark)) &&
 	    (full || tp->snd_cwnd != tcp_probe.lastcwnd)) {
 
 		spin_lock(&tcp_probe.lock);
@@ -284,7 +290,8 @@ static __init int tcpprobe_init(void)
 	if (ret)
 		goto err1;
 
-	pr_info("probe registered (port=%d) bufsize=%u\n", port, bufsize);
+	pr_info("probe registered (port=%d/fwmark=%u) bufsize=%u\n",
+		port, fwmark, bufsize);
 	return 0;
  err1:
 	remove_proc_entry(procname, init_net.proc_net);
-- 
1.7.11.7
