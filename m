From: <zyjzyj2000@gmail.com>
Subject: [V2 PATCH 1/1] net: sctp: dynamically enable or disable pf state
Date: Mon, 14 Dec 2015 14:22:19 +0800
Message-ID: <1450074139-3923-1-git-send-email-zyjzyj2000@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <vyasevich@gmail.com>, <nhorman@tuxdriver.com>,
	<linux-sctp@vger.kernel.org>, <netdev@vger.kernel.org>,
	<alexandre.dietsch@windriver.com>,
	<stefan.costandache@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:63109 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752372AbbLNGWg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Dec 2015 01:22:36 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhu Yanjun <zyjzyj2000@gmail.com>

As we all know, the value of pf_retrans >= max_retrans_path can
disable pf state. The variables of pf_retrans and max_retrans_path
can be changed by the user space application.

Sometimes the user expects to disable pf state while the 2
variables are changed to enable pf state. So it is necessary to
introduce a new variable to disable pf state.

According to the suggestions from Vlad Yasevich, extra1 and extra2
are removed. The initialization of pf_enable is added.

Signed-off-by: Zhu Yanjun <zyjzyj2000@gmail.com>
---
 include/net/netns/sctp.h |    7 +++++++
 net/sctp/protocol.c      |    3 +++
 net/sctp/sm_sideeffect.c |    5 ++++-
 net/sctp/sysctl.c        |    7 +++++++
 4 files changed, 21 insertions(+), 1 deletion(-)

diff --git a/include/net/netns/sctp.h b/include/net/netns/sctp.h
index 8ba379f..c501d67 100644
--- a/include/net/netns/sctp.h
+++ b/include/net/netns/sctp.h
@@ -89,6 +89,13 @@ struct netns_sctp {
 	int pf_retrans;
 
 	/*
+	 * Disable Potentially-Failed feature, the feature is enabled by default
+	 * pf_enable	-  0  : disable pf
+	 *		- >0  : enable pf
+	 */
+	int pf_enable;
+
+	/*
 	 * Policy for preforming sctp/socket accounting
 	 * 0   - do socket level accounting, all assocs share sk_sndbuf
 	 * 1   - do sctp accounting, each asoc may use sk_sndbuf bytes
diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index 4d9912f..571a631 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -1223,6 +1223,9 @@ static int __net_init sctp_defaults_init(struct net *net)
 	/* Max.Burst		    - 4 */
 	net->sctp.max_burst			= SCTP_DEFAULT_MAX_BURST;
 
+	/* Enable pf state by default */
+	net->sctp.pf_enable = 1;
+
 	/* Association.Max.Retrans  - 10 attempts
 	 * Path.Max.Retrans         - 5  attempts (per destination address)
 	 * Max.Init.Retransmits     - 8  attempts
diff --git a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
index 6098d4c..05cd164 100644
--- a/net/sctp/sm_sideeffect.c
+++ b/net/sctp/sm_sideeffect.c
@@ -477,6 +477,8 @@ static void sctp_do_8_2_transport_strike(sctp_cmd_seq_t *commands,
 					 struct sctp_transport *transport,
 					 int is_hb)
 {
+	struct net *net = sock_net(asoc->base.sk);
+
 	/* The check for association's overall error counter exceeding the
 	 * threshold is done in the state function.
 	 */
@@ -503,7 +505,8 @@ static void sctp_do_8_2_transport_strike(sctp_cmd_seq_t *commands,
 	 * is SCTP_ACTIVE, then mark this transport as Partially Failed,
 	 * see SCTP Quick Failover Draft, section 5.1
 	 */
-	if ((transport->state == SCTP_ACTIVE) &&
+	if (net->sctp.pf_enable &&
+	   (transport->state == SCTP_ACTIVE) &&
 	   (asoc->pf_retrans < transport->pathmaxrxt) &&
 	   (transport->error_count > asoc->pf_retrans)) {
 
diff --git a/net/sctp/sysctl.c b/net/sctp/sysctl.c
index 26d50c5..ccbfc93 100644
--- a/net/sctp/sysctl.c
+++ b/net/sctp/sysctl.c
@@ -308,6 +308,13 @@ static struct ctl_table sctp_net_table[] = {
 		.extra1		= &max_autoclose_min,
 		.extra2		= &max_autoclose_max,
 	},
+	{
+		.procname	= "pf_enable",
+		.data		= &init_net.sctp.pf_enable,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
 
 	{ /* sentinel */ }
 };
-- 
1.7.9.5
