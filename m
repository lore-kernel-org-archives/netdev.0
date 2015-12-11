From: <zyjzyj2000@gmail.com>
Subject: [PATCH 1/1] net: sctp: dynamically enable or disable pf state
Date: Fri, 11 Dec 2015 17:05:32 +0800
Message-ID: <1449824732-22362-1-git-send-email-zyjzyj2000@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <vyasevich@gmail.com>, <nhorman@tuxdriver.com>,
	<linux-sctp@vger.kernel.org>, <netdev@vger.kernel.org>,
	<alexandre.dietsch@windriver.com>,
	<stefan.costandache@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail5.windriver.com ([192.103.53.11]:32944 "EHLO mail5.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751805AbbLKJFc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Dec 2015 04:05:32 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhu Yanjun <zyjzyj2000@gmail.com>

As we all know, the vale of pf_retrans >= max_retrans_path can
disable pf state. The variables of pf_retrans and max_retrans_path
can be changed by the user space application.

Sometimes the user expects to disable pf state while the 2
variables are changed to enable pf state. So it is necessary to
introduce a new variable to disable pf state.

Signed-off-by: Zhu Yanjun <zyjzyj2000@gmail.com>
---
 Documentation/networking/ip-sysctl.txt |   17 +++++++++++++++++
 include/net/netns/sctp.h               |    7 +++++++
 net/sctp/sm_sideeffect.c               |    5 ++++-
 net/sctp/sysctl.c                      |    9 +++++++++
 4 files changed, 37 insertions(+), 1 deletion(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index f647900..7195c24 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -1723,6 +1723,23 @@ addip_enable - BOOLEAN
 
 	Default: 0
 
+pf_enable - INTEGER
+	Enable or disable pf state. A value of pf_retrans > path_max_retrans
+	also disables pf state. That is, one of both pf_enable and
+	pf_retrans > path_max_retrans can disable pf state. Since pf_retrans
+	and path_max_retrans can be changed by userspace application, sometimes
+	user expects to disable pf state by the value of
+	pf_retrans > path_max_retrans, but ocassionally the value of pf_retrans
+	or path_max_retrans is changed by the user application, this pf state is
+	enabled. As such, it is necessary to add this to dynamically enable
+	and disable pf state.
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
diff --git a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
index 6098d4c..50309ed 100644
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
index 26d50c5..0a4f402 100644
--- a/net/sctp/sysctl.c
+++ b/net/sctp/sysctl.c
@@ -308,6 +308,15 @@ static struct ctl_table sctp_net_table[] = {
 		.extra1		= &max_autoclose_min,
 		.extra2		= &max_autoclose_max,
 	},
+	{
+		.procname	= "pf_enable",
+		.data		= &init_net.sctp.pf_enable,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+		.extra1		= &one,
+		.extra2		= &int_max
+	},
 
 	{ /* sentinel */ }
 };
-- 
1.7.9.5
