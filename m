From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [RFC PATCH 12/13] ipv4: Pull GSO registration out of inet_init()
Date: Tue, 13 Nov 2012 20:24:13 -0500
Message-ID: <1352856254-29667-13-git-send-email-vyasevic@redhat.com>
References: <1352856254-29667-1-git-send-email-vyasevic@redhat.com>
Cc: eric.dumazet@gmail.com, davem@davemloft.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39485 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932407Ab2KNBYg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Nov 2012 20:24:36 -0500
In-Reply-To: <1352856254-29667-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since GSO/GRO support is now separated, make IPv4 GSO a
stand-alone init call and not part of inet_init().

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 net/ipv4/af_inet.c |   34 ++++++++++++++++++++--------------
 1 files changed, 20 insertions(+), 14 deletions(-)

diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 66f63ce..fd34b8c 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1665,11 +1665,6 @@ static int ipv4_proc_init(void);
  *	IP protocol layer initialiser
  */
 
-static struct packet_type ip_packet_type __read_mostly = {
-	.type = cpu_to_be16(ETH_P_IP),
-	.func = ip_rcv,
-};
-
 static struct packet_offload ip_packet_offload __read_mostly = {
 	.type = cpu_to_be16(ETH_P_IP),
 	.gso_send_check = inet_gso_send_check,
@@ -1678,6 +1673,26 @@ static struct packet_offload ip_packet_offload __read_mostly = {
 	.gro_complete = inet_gro_complete,
 };
 
+static void __init ipv4_offload_init(void)
+{
+	/*
+	 * Add offloads
+	 */
+	if (inet_add_offload(&udp_offload, IPPROTO_UDP) < 0)
+		pr_crit("%s: Cannot add UDP protocol offload\n", __func__);
+	if (inet_add_offload(&tcp_offload, IPPROTO_TCP) < 0)
+		pr_crit("%s: Cannot add TCP protocol offlaod\n", __func__);
+
+	dev_add_offload(&ip_packet_offload);
+}
+
+fs_initcall(ipv4_offload_init);
+
+static struct packet_type ip_packet_type __read_mostly = {
+	.type = cpu_to_be16(ETH_P_IP),
+	.func = ip_rcv,
+};
+
 static int __init inet_init(void)
 {
 	struct sk_buff *dummy_skb;
@@ -1720,14 +1735,6 @@ static int __init inet_init(void)
 	tcp_prot.sysctl_mem = init_net.ipv4.sysctl_tcp_mem;
 
 	/*
-	 * Add offloads
-	 */
-	if (inet_add_offload(&udp_offload, IPPROTO_UDP) < 0)
-		pr_crit("%s: Cannot add UDP protocol offload\n", __func__);
-	if (inet_add_offload(&tcp_offload, IPPROTO_TCP) < 0)
-		pr_crit("%s: Cannot add TCP protocol offlaod\n", __func__);
-
-	/*
 	 *	Add all the base protocols.
 	 */
 
@@ -1799,7 +1806,6 @@ static int __init inet_init(void)
 
 	ipfrag_init();
 
-	dev_add_offload(&ip_packet_offload);
 	dev_add_pack(&ip_packet_type);
 
 	rc = 0;
-- 
1.7.7.6
