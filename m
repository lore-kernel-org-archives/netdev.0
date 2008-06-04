From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH 6/6] [SCTP]: Fix ECN markings for IPv6
Date: Wed,  4 Jun 2008 14:25:51 -0400
Message-ID: <1212603951-24932-7-git-send-email-vladislav.yasevich@hp.com>
References: <1212603951-24932-1-git-send-email-vladislav.yasevich@hp.com>
Cc: linux-sctp@vger.kernel.org, davem@davemloft.net,
	Vlad Yasevich <vladislav.yasevich@hp.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0014.houston.hp.com ([15.201.24.17]:15326 "EHLO
	g4t0014.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756354AbYFDS0D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jun 2008 14:26:03 -0400
In-Reply-To: <1212603951-24932-1-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit e9df2e8fd8fbc95c57dbd1d33dada66c4627b44c
([IPV6]: Use appropriate sock tclass setting for routing lookup.) also
changed the way that ECN capable transports mark this capability in IPv6.
As a result, SCTP was not marking ECN capablity because the traffic class
was never set.  This patch brings back the markings for IPv6 traffic.

Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 include/net/sctp/structs.h |    1 +
 net/sctp/ipv6.c            |    6 ++++++
 net/sctp/output.c          |    2 +-
 net/sctp/protocol.c        |    6 ++++++
 4 files changed, 14 insertions(+), 1 deletions(-)

diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index 1014c77..2fb05b8 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -587,6 +587,7 @@ struct sctp_af {
 	int		(*is_ce)	(const struct sk_buff *sk);
 	void		(*seq_dump_addr)(struct seq_file *seq,
 					 union sctp_addr *addr);
+	void		(*ecn_capable)(struct sock *sk);
 	__u16		net_header_len;
 	int		sockaddr_len;
 	sa_family_t	sa_family;
diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
index e45e44c..6244367 100644
--- a/net/sctp/ipv6.c
+++ b/net/sctp/ipv6.c
@@ -726,6 +726,11 @@ static void sctp_v6_seq_dump_addr(struct seq_file *seq, union sctp_addr *addr)
 	seq_printf(seq, NIP6_FMT " ", NIP6(addr->v6.sin6_addr));
 }
 
+static void sctp_v6_ecn_capable(struct sock *sk)
+{
+	inet6_sk(sk)->tclass |= INET_ECN_ECT_0;
+}
+
 /* Initialize a PF_INET6 socket msg_name. */
 static void sctp_inet6_msgname(char *msgname, int *addr_len)
 {
@@ -996,6 +1001,7 @@ static struct sctp_af sctp_af_inet6 = {
 	.skb_iif	   = sctp_v6_skb_iif,
 	.is_ce		   = sctp_v6_is_ce,
 	.seq_dump_addr	   = sctp_v6_seq_dump_addr,
+	.ecn_capable	   = sctp_v6_ecn_capable,
 	.net_header_len	   = sizeof(struct ipv6hdr),
 	.sockaddr_len	   = sizeof(struct sockaddr_in6),
 #ifdef CONFIG_COMPAT
diff --git a/net/sctp/output.c b/net/sctp/output.c
index cf4f9fb..6d45bae 100644
--- a/net/sctp/output.c
+++ b/net/sctp/output.c
@@ -548,7 +548,7 @@ int sctp_packet_transmit(struct sctp_packet *packet)
 	 * Note: The works for IPv6 layer checks this bit too later
 	 * in transmission.  See IP6_ECN_flow_xmit().
 	 */
-	INET_ECN_xmit(nskb->sk);
+	(*tp->af_specific->ecn_capable)(nskb->sk);
 
 	/* Set up the IP options.  */
 	/* BUG: not implemented
diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index 040e489..481baf1 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -616,6 +616,11 @@ static void sctp_v4_seq_dump_addr(struct seq_file *seq, union sctp_addr *addr)
 	seq_printf(seq, "%d.%d.%d.%d ", NIPQUAD(addr->v4.sin_addr));
 }
 
+static void sctp_v4_ecn_capable(struct sock *sk)
+{
+	INET_ECN_xmit(sk);
+}
+
 /* Event handler for inet address addition/deletion events.
  * The sctp_local_addr_list needs to be protocted by a spin lock since
  * multiple notifiers (say IPv4 and IPv6) may be running at the same
@@ -934,6 +939,7 @@ static struct sctp_af sctp_af_inet = {
 	.skb_iif	   = sctp_v4_skb_iif,
 	.is_ce		   = sctp_v4_is_ce,
 	.seq_dump_addr	   = sctp_v4_seq_dump_addr,
+	.ecn_capable	   = sctp_v4_ecn_capable,
 	.net_header_len	   = sizeof(struct iphdr),
 	.sockaddr_len	   = sizeof(struct sockaddr_in),
 #ifdef CONFIG_COMPAT
-- 
1.5.3.5

