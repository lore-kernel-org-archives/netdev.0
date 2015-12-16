From: <zyjzyj2000@gmail.com>
Subject: [PATCH 1/1] net: sctp: dynamically enable or disable pf state
Date: Wed, 16 Dec 2015 13:55:04 +0800
Message-ID: <1450245304-29848-2-git-send-email-zyjzyj2000@gmail.com>
References: <566ED0D9.8040200@gmail.com>
 <1450245304-29848-1-git-send-email-zyjzyj2000@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <vyasevich@gmail.com>, <nhorman@tuxdriver.com>,
	<linux-sctp@vger.kernel.org>, <netdev@vger.kernel.org>,
	<alexandre.dietsch@windriver.com>,
	<stefan.costandache@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:51615 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751289AbbLPFzU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Dec 2015 00:55:20 -0500
In-Reply-To: <1450245304-29848-1-git-send-email-zyjzyj2000@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhu Yanjun <zyjzyj2000@gmail.com>

As we all know, the value of pf_retrans >= max_retrans_path can
disable pf state. The variables of pf_retrans and max_retrans_path
can be changed by the userspace application.

Sometimes the user expects to disable pf state while the 2
variables are changed to enable pf state. So it is necessary to
introduce a new variable to disable pf state.

According to the suggestions from Vlad Yasevich, extra1 and extra2
are removed. The initialization of pf_enable is added.

Acked-by: Vlad Yasevich <vyasevich@gmail.com>
Signed-off-by: Zhu Yanjun <zyjzyj2000@gmail.com>
---
 Documentation/networking/ip-sysctl.txt |   23 ++++++++++++++++++++++-
 include/net/netns/sctp.h               |    7 +++++++
 net/sctp/protocol.c                    |    3 +++
 net/sctp/sm_sideeffect.c               |    5 ++++-
 net/sctp/sysctl.c                      |    7 +++++++
 5 files changed, 43 insertions(+), 2 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index 2ea4c45..f43ead3 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -1723,6 +1723,25 @@ addip_enable - BOOLEAN
 
 	Default: 0
 
+pf_enable - INTEGER
+	Enable or disable pf (pf is short for potentially failed) state. A value
+	of pf_retrans > path_max_retrans also disables pf state. That is, one of
+	both pf_enable and pf_retrans > path_max_retrans can disable pf state.
+	Since pf_retrans and path_max_retrans can be changed by userspace
+	application, sometimes user expects to disable pf state by the value of
+	pf_retrans > path_max_retrans, but occasionally the value of pf_retrans
+	or path_max_retrans is changed by the user application, this pf state is
+	enabled. As such, it is necessary to add this to dynamically enable
+	and disable pf state. See:
+	https://datatracker.ietf.org/doc/draft-ietf-tsvwg-sctp-failover for
+	details.
+
+	1: Enable pf.
+
+	0: Disable pf.
+
+	Default: 1
+
 addip_noauth_enable - BOOLEAN
 	Dynamic Address Reconfiguration (ADD-IP) requires the use of
 	authentication to protect the operations of adding or removing new
@@ -1799,7 +1818,9 @@ pf_retrans - INTEGER
 	having to reduce path_max_retrans to a very low value.  See:
 	http://www.ietf.org/id/draft-nishida-tsvwg-sctp-failover-05.txt
 	for details.  Note also that a value of pf_retrans > path_max_retrans
-	disables this feature
+	disables this feature. Since both pf_retrans and path_max_retrans can
+	be changed by userspace application, a variable pf_enable is used to
+	disable pf state.
 
 	Default: 0
 
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
index 3d9ea9a..cfbf49b 100644
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
