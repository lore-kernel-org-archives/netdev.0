From: Fan Du <fan.du@windriver.com>
Subject: [PATCH net-next] sctp: Namespacify checksum_disable
Date: Mon, 14 Oct 2013 16:32:25 +0800
Message-ID: <1381739545-674-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: <vyasevich@gmail.com>, <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:61636 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751673Ab3JNIcn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Oct 2013 04:32:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SCTP CRC32-C checksum computing and verifying should be namespace-sensible,
as each, e.g. tenant instance might need different checksum configuration for
its requirement. So this patch enhance SCTP with this feature.

Signed-off-by: Fan Du <fan.du@windriver.com>
---
 include/net/netns/sctp.h   |    5 +++++
 include/net/sctp/structs.h |    3 ---
 net/sctp/input.c           |    2 +-
 net/sctp/output.c          |    4 +++-
 net/sctp/protocol.c        |    5 +++--
 net/sctp/sysctl.c          |    7 +++++++
 6 files changed, 19 insertions(+), 7 deletions(-)

diff --git a/include/net/netns/sctp.h b/include/net/netns/sctp.h
index 3573a81..704adb3 100644
--- a/include/net/netns/sctp.h
+++ b/include/net/netns/sctp.h
@@ -129,6 +129,11 @@ struct netns_sctp {
 
 	/* Threshold for autoclose timeout, in seconds. */
 	unsigned long max_autoclose;
+
+	/* Set to 1 to disable CRC32-C checksum computing and verifying.
+	 * Default to 0 to enable this feature.
+	 */
+	int checksum_disable;
 };
 
 #endif /* __NETNS_SCTP_H__ */
diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index 2174d8d..820895e 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -134,9 +134,6 @@ extern struct sctp_globals {
 	__u16 max_instreams;
 	__u16 max_outstreams;
 
-	/* Flag to indicate whether computing and verifying checksum
-	 * is disabled. */
-        bool checksum_disable;
 } sctp_globals;
 
 #define sctp_max_instreams		(sctp_globals.max_instreams)
diff --git a/net/sctp/input.c b/net/sctp/input.c
index 98b69bb..9db2a65 100644
--- a/net/sctp/input.c
+++ b/net/sctp/input.c
@@ -134,7 +134,7 @@ int sctp_rcv(struct sk_buff *skb)
 	__skb_pull(skb, skb_transport_offset(skb));
 	if (skb->len < sizeof(struct sctphdr))
 		goto discard_it;
-	if (!sctp_checksum_disable && !skb_csum_unnecessary(skb) &&
+	if (!net->sctp.checksum_disable && !skb_csum_unnecessary(skb) &&
 		  sctp_rcv_checksum(net, skb) < 0)
 		goto discard_it;
 
diff --git a/net/sctp/output.c b/net/sctp/output.c
index 6de6402..5d0a45e 100644
--- a/net/sctp/output.c
+++ b/net/sctp/output.c
@@ -395,6 +395,7 @@ int sctp_packet_transmit(struct sctp_packet *packet)
 	struct sk_buff *nskb;
 	struct sctp_chunk *chunk, *tmp;
 	struct sock *sk;
+	struct net *net;
 	int err = 0;
 	int padding;		/* How much padding do we need?  */
 	__u8 has_data = 0;
@@ -411,6 +412,7 @@ int sctp_packet_transmit(struct sctp_packet *packet)
 	/* Set up convenience variables... */
 	chunk = list_entry(packet->chunk_list.next, struct sctp_chunk, list);
 	sk = chunk->skb->sk;
+	net = sock_net(sk);
 
 	/* Allocate the new skb.  */
 	nskb = alloc_skb(packet->size + LL_MAX_HEADER, GFP_ATOMIC);
@@ -545,7 +547,7 @@ int sctp_packet_transmit(struct sctp_packet *packet)
 	 * Note: Adler-32 is no longer applicable, as has been replaced
 	 * by CRC32-C as described in <draft-ietf-tsvwg-sctpcsum-02.txt>.
 	 */
-	if (!sctp_checksum_disable) {
+	if (!net->sctp.checksum_disable) {
 		if ((!(dst->dev->features & NETIF_F_SCTP_CSUM)) ||
 			is_xfrm_armed(dst)) {
 
diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index 5e17092..b3c51ce 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -1239,6 +1239,9 @@ static int __net_init sctp_net_init(struct net *net)
 	/* Initialize maximum autoclose timeout. */
 	net->sctp.max_autoclose		= INT_MAX / HZ;
 
+	/* Enable checksum by default. */
+	net->sctp.checksum_disable = 0;
+
 	status = sctp_sysctl_net_register(net);
 	if (status)
 		goto err_sysctl_register;
@@ -1543,6 +1546,4 @@ MODULE_ALIAS("net-pf-" __stringify(PF_INET) "-proto-132");
 MODULE_ALIAS("net-pf-" __stringify(PF_INET6) "-proto-132");
 MODULE_AUTHOR("Linux Kernel SCTP developers <linux-sctp@vger.kernel.org>");
 MODULE_DESCRIPTION("Support for the SCTP protocol (RFC2960)");
-module_param_named(no_checksums, sctp_checksum_disable, bool, 0644);
-MODULE_PARM_DESC(no_checksums, "Disable checksums computing and verification");
 MODULE_LICENSE("GPL");
diff --git a/net/sctp/sysctl.c b/net/sctp/sysctl.c
index 6b36561..d6a6cca 100644
--- a/net/sctp/sysctl.c
+++ b/net/sctp/sysctl.c
@@ -290,6 +290,13 @@ static struct ctl_table sctp_net_table[] = {
 		.extra1		= &max_autoclose_min,
 		.extra2		= &max_autoclose_max,
 	},
+	{
+		.procname	= "checksum_disable",
+		.data		= &init_net.sctp.checksum_disable,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
 
 	{ /* sentinel */ }
 };
-- 
1.7.9.5
