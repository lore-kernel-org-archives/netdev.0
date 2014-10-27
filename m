From: Tom Herbert <therbert@google.com>
Subject: [PATCH net-next 1/2] udp: Record RPS flow in socket operations
Date: Mon, 27 Oct 2014 11:01:14 -0700
Message-ID: <1414432875-23795-1-git-send-email-therbert@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:59776 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751718AbaJ0SCJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Oct 2014 14:02:09 -0400
Received: by mail-pd0-f169.google.com with SMTP id y10so1769132pdj.28
        for <netdev@vger.kernel.org>; Mon, 27 Oct 2014 11:02:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add calls to sock_rps_record_flow for udp_sendmsg, udp_sendpage
and udp_recvmsg. This enables RFS for connected UDP sockets.

Tested:
  Ran netperf UDP_RR with 200 flows, with and without UDP RSS enabled

Before fix:
  No RSS
    Client (connected UDP)
      36.87% CPU utilization
    Server (unconnected UDP)
      33.64% CPU utilization
    256/440/687 90/95/99% latencies
    727273 tps

  UDP RSS
    Client
      79.59% CPU utilization
    Server
      78.83% CPU utilization
    116/159/226 90/95/99% latencies
    1.60974e+06 tps

After fix:
  No RSS
    Client
      44.38% CPU utilization
    Server
      50.46% CPU utilization
    192/245/343 90/95/99% latencies
    1.01413e+06

  UDP RSS
    Client
      79.98% CPU utilization
    Server
      80.35% CPU utilization
    113/158/230 90/95/99% latencies
    1.60622e+06 tps

Signed-off-by: Tom Herbert <therbert@google.com>
---
 net/ipv4/udp.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index cd0db54..9a0d346 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -881,6 +881,8 @@ int udp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	struct sk_buff *skb;
 	struct ip_options_data opt_copy;
 
+	sock_rps_record_flow(sk);
+
 	if (len > 0xFFFF)
 		return -EMSGSIZE;
 
@@ -1113,6 +1115,8 @@ int udp_sendpage(struct sock *sk, struct page *page, int offset,
 	struct udp_sock *up = udp_sk(sk);
 	int ret;
 
+	sock_rps_record_flow(sk);
+
 	if (flags & MSG_SENDPAGE_NOTLAST)
 		flags |= MSG_MORE;
 
@@ -1253,6 +1257,8 @@ int udp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	int is_udplite = IS_UDPLITE(sk);
 	bool slow;
 
+	sock_rps_record_flow(sk);
+
 	if (flags & MSG_ERRQUEUE)
 		return ip_recv_error(sk, msg, len, addr_len);
 
-- 
2.1.0.rc2.206.gedb03e5
