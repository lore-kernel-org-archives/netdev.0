From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH net-next 1/4] sctp: Allow to disable SCTP checksums via module parameter
Date: Fri, 13 Feb 2009 13:33:41 -0500
Message-ID: <1234550024-30915-2-git-send-email-vladislav.yasevich@hp.com>
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	Lucas Nussbaum <lucas.nussbaum@ens-lyon.fr>,
	Vlad Yasevich <vladislav.yasevich@hp.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0015.houston.hp.com ([15.201.24.18]:23509 "EHLO
	g4t0015.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752638AbZBMSds (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Feb 2009 13:33:48 -0500
In-Reply-To: <>
References: <>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lucas Nussbaum <lucas.nussbaum@ens-lyon.fr>

This is a new version of my patch, now using a module parameter instead
of a sysctl, so that the option is harder to find. Please note that,
once the module is loaded, it is still possible to change the value of
the parameter in /sys/module/sctp/parameters/, which is useful if you
want to do performance comparisons without rebooting.

Computation of SCTP checksums significantly affects the performance of
SCTP. For example, using two dual-Opteron 246 connected using a Gbe
network, it was not possible to achieve more than ~730 Mbps, compared to
941 Mbps after disabling SCTP checksums.
Unfortunately, SCTP checksum offloading in NICs is not commonly
available (yet).

By default, checksums are still enabled, of course.

Signed-off-by: Lucas Nussbaum <lucas.nussbaum@ens-lyon.fr>
Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 include/net/sctp/structs.h |    5 +++++
 net/sctp/input.c           |    3 ++-
 net/sctp/output.c          |    2 +-
 net/sctp/protocol.c        |    2 ++
 4 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index 9661d7b..9f70d54 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -218,6 +218,10 @@ extern struct sctp_globals {
 
 	/* Flag to idicate if SCTP-AUTH is enabled */
 	int auth_enable;
+
+	/* Flag to indicate whether computing and verifying checksum
+	 * is disabled. */
+        int checksum_disable;
 } sctp_globals;
 
 #define sctp_rto_initial		(sctp_globals.rto_initial)
@@ -252,6 +256,7 @@ extern struct sctp_globals {
 #define sctp_addip_noauth		(sctp_globals.addip_noauth_enable)
 #define sctp_prsctp_enable		(sctp_globals.prsctp_enable)
 #define sctp_auth_enable		(sctp_globals.auth_enable)
+#define sctp_checksum_disable		(sctp_globals.checksum_disable)
 
 /* SCTP Socket type: UDP or TCP style. */
 typedef enum {
diff --git a/net/sctp/input.c b/net/sctp/input.c
index 2e4a864..693fd08 100644
--- a/net/sctp/input.c
+++ b/net/sctp/input.c
@@ -142,7 +142,8 @@ int sctp_rcv(struct sk_buff *skb)
 	__skb_pull(skb, skb_transport_offset(skb));
 	if (skb->len < sizeof(struct sctphdr))
 		goto discard_it;
-	if (!skb_csum_unnecessary(skb) && sctp_rcv_checksum(skb) < 0)
+	if (!sctp_checksum_disable && !skb_csum_unnecessary(skb) &&
+		  sctp_rcv_checksum(skb) < 0)
 		goto discard_it;
 
 	skb_pull(skb, sizeof(struct sctphdr));
diff --git a/net/sctp/output.c b/net/sctp/output.c
index 47bfba6..2d65b7a 100644
--- a/net/sctp/output.c
+++ b/net/sctp/output.c
@@ -531,7 +531,7 @@ int sctp_packet_transmit(struct sctp_packet *packet)
 	 * Note: Adler-32 is no longer applicable, as has been replaced
 	 * by CRC32-C as described in <draft-ietf-tsvwg-sctpcsum-02.txt>.
 	 */
-	if (!(dst->dev->features & NETIF_F_NO_CSUM)) {
+	if (!sctp_checksum_disable && !(dst->dev->features & NETIF_F_NO_CSUM)) {
 		crc32 = sctp_start_cksum((__u8 *)sh, cksum_buf_len);
 		crc32 = sctp_end_cksum(crc32);
 	} else
diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index b78e3be..cc0b592 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -1411,4 +1411,6 @@ MODULE_ALIAS("net-pf-" __stringify(PF_INET) "-proto-132");
 MODULE_ALIAS("net-pf-" __stringify(PF_INET6) "-proto-132");
 MODULE_AUTHOR("Linux Kernel SCTP developers <lksctp-developers@lists.sourceforge.net>");
 MODULE_DESCRIPTION("Support for the SCTP protocol (RFC2960)");
+module_param_named(no_checksums, sctp_checksum_disable, bool, 0644);
+MODULE_PARM_DESC(no_checksums, "Disable checksums computing and verification");
 MODULE_LICENSE("GPL");
-- 
1.5.4.3

