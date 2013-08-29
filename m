From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next] net: sctp: probe: allow more advanced ingress filtering by mark
Date: Thu, 29 Aug 2013 18:54:49 +0200
Message-ID: <1377795289-1914-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:16097 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755077Ab3H2Qyx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Aug 2013 12:54:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a follow-up commit for commit b1dcdc68b1f4 ("net: tcp_probe:
allow more advanced ingress filtering by mark") that allows for
advanced SCTP probe module filtering based on skb mark (for a more
detailed description and advantages using mark, refer to b1dcdc68b1f4).
The current option to filter by a given port is still being preserved.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 Tested with various marked flows.

 net/sctp/probe.c | 18 +++++++++++++-----
 1 file changed, 13 insertions(+), 5 deletions(-)

diff --git a/net/sctp/probe.c b/net/sctp/probe.c
index cd72ae5..0118178 100644
--- a/net/sctp/probe.c
+++ b/net/sctp/probe.c
@@ -46,6 +46,10 @@ static int port __read_mostly = 0;
 MODULE_PARM_DESC(port, "Port to match (0=all)");
 module_param(port, int, 0);
 
+static unsigned int fwmark __read_mostly = 0;
+MODULE_PARM_DESC(fwmark, "skb mark to match (0=no mark)");
+module_param(fwmark, uint, 0);
+
 static int bufsize __read_mostly = 64 * 1024;
 MODULE_PARM_DESC(bufsize, "Log buffer size (default 64k)");
 module_param(bufsize, int, 0);
@@ -129,15 +133,19 @@ static sctp_disposition_t jsctp_sf_eat_sack(struct net *net,
 					    void *arg,
 					    sctp_cmd_seq_t *commands)
 {
+	struct sctp_chunk *chunk = arg;
+	struct sk_buff *skb = chunk->skb;
 	struct sctp_transport *sp;
 	static __u32 lcwnd = 0;
 	struct timespec now;
 
 	sp = asoc->peer.primary_path;
 
-	if ((full || sp->cwnd != lcwnd) &&
-	    (!port || asoc->peer.port == port ||
-	     ep->base.bind_addr.port == port)) {
+	if (((port == 0 && fwmark == 0) ||
+	     asoc->peer.port == port ||
+	     ep->base.bind_addr.port == port ||
+	     (fwmark > 0 && skb->mark == fwmark)) &&
+	    (full || sp->cwnd != lcwnd)) {
 		lcwnd = sp->cwnd;
 
 		getnstimeofday(&now);
@@ -198,8 +206,8 @@ static __init int sctpprobe_init(void)
 	if (ret)
 		goto remove_proc;
 
-	pr_info("probe registered (port=%d)\n", port);
-
+	pr_info("probe registered (port=%d/fwmark=%u) bufsize=%u\n",
+		port, fwmark, bufsize);
 	return 0;
 
 remove_proc:
-- 
1.7.11.7
