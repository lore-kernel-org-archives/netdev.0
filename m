From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next 11/27] sctp: add reconf_enable in asoc ep and netns
Date: Sun,  1 Jan 2017 19:20:28 +0800
Message-ID: <1e4560205cff3c10868d5614b62a3db14e87ccf0.1483269426.git.lucien.xin@gmail.com>
References: <cover.1483269426.git.lucien.xin@gmail.com>
 <684ad8ddd79f23844883dede4c34360ce744dfc3.1483269426.git.lucien.xin@gmail.com>
 <c752879a5af358c08da949b391416452f1322c43.1483269426.git.lucien.xin@gmail.com>
 <be8a2770ddc2381266050c9f168add9802b90a49.1483269426.git.lucien.xin@gmail.com>
 <fc046afdda34c9b262ce57400c4256b14fd1a0fb.1483269426.git.lucien.xin@gmail.com>
 <d4f1b2a4fa19457e9867b0a1f84764a7a509459a.1483269426.git.lucien.xin@gmail.com>
 <31abc54d31ef0714322f137bff43458014d7c276.1483269426.git.lucien.xin@gmail.com>
 <58860816816d6d51b062235fd54dae6540a4797a.1483269426.git.lucien.xin@gmail.com>
 <229608faf7af54c0bf908694ca8349205bbf6eab.1483269426.git.lucien.xin@gmail.com>
 <c4f16844620cd3a2aa76596df9eaadf1505fc8e6.1483269426.git.lucien.xin@gmail.com>
 <1d0b270084289945c4b42ae36d0556648a3f9b64.1483269426.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:34644 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932079AbdAALWU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 1 Jan 2017 06:22:20 -0500
In-Reply-To: <1d0b270084289945c4b42ae36d0556648a3f9b64.1483269426.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1483269426.git.lucien.xin@gmail.com>
References: <cover.1483269426.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to add reconf_enable field in all of asoc ep and netns
to indicate if they support stream reset.

When initializing, asoc reconf_enable get the default value from ep
reconf_enable which is from netns netns reconf_enable by default.

It is also to add reconf_capable in asoc peer part to know if peer
supports reconf_enable, the value is set if ext params have reconf
chunk support when processing init chunk, just as rfc6525 section
5.1.1 demands.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/net/netns/sctp.h   |  3 +++
 include/net/sctp/structs.h |  7 +++++--
 net/sctp/associola.c       |  1 +
 net/sctp/endpointola.c     |  1 +
 net/sctp/sm_make_chunk.c   | 15 +++++++++++++++
 net/sctp/sysctl.c          |  7 +++++++
 6 files changed, 32 insertions(+), 2 deletions(-)

diff --git a/include/net/netns/sctp.h b/include/net/netns/sctp.h
index c501d67..b7871d0 100644
--- a/include/net/netns/sctp.h
+++ b/include/net/netns/sctp.h
@@ -118,6 +118,9 @@ struct netns_sctp {
 	/* Flag to indicate if PR-SCTP is enabled. */
 	int prsctp_enable;
 
+	/* Flag to indicate if PR-CONFIG is enabled. */
+	int reconf_enable;
+
 	/* Flag to idicate if SCTP-AUTH is enabled */
 	int auth_enable;
 
diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index bb18990..7c46398 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -1251,7 +1251,8 @@ struct sctp_endpoint {
 	struct list_head endpoint_shared_keys;
 	__u16 active_key_id;
 	__u8  auth_enable:1,
-	      prsctp_enable:1;
+	      prsctp_enable:1,
+	      reconf_enable:1;
 };
 
 /* Recover the outter endpoint structure. */
@@ -1497,6 +1498,7 @@ struct sctp_association {
 			hostname_address:1, /* Peer understands DNS addresses? */
 			asconf_capable:1,   /* Does peer support ADDIP? */
 			prsctp_capable:1,   /* Can peer do PR-SCTP? */
+			reconf_capable:1,   /* Can peer do RE-CONFIG? */
 			auth_capable:1;     /* Is peer doing SCTP-AUTH? */
 
 		/* sack_needed : This flag indicates if the next received
@@ -1853,7 +1855,8 @@ struct sctp_association {
 
 	__u8 need_ecne:1,	/* Need to send an ECNE Chunk? */
 	     temp:1,		/* Is it a temporary association? */
-	     prsctp_enable:1;
+	     prsctp_enable:1,
+	     reconf_enable:1;
 
 	/* stream arrays */
 	struct sctp_stream_out *streamout;
diff --git a/net/sctp/associola.c b/net/sctp/associola.c
index 7acfdad..ab43cb6 100644
--- a/net/sctp/associola.c
+++ b/net/sctp/associola.c
@@ -270,6 +270,7 @@ static struct sctp_association *sctp_association_init(struct sctp_association *a
 
 	asoc->active_key_id = ep->active_key_id;
 	asoc->prsctp_enable = ep->prsctp_enable;
+	asoc->reconf_enable = ep->reconf_enable;
 
 	/* Save the hmacs and chunks list into this association */
 	if (ep->auth_hmacs_list)
diff --git a/net/sctp/endpointola.c b/net/sctp/endpointola.c
index 410ddc1..8c58923 100644
--- a/net/sctp/endpointola.c
+++ b/net/sctp/endpointola.c
@@ -164,6 +164,7 @@ static struct sctp_endpoint *sctp_endpoint_init(struct sctp_endpoint *ep,
 	ep->auth_hmacs_list = auth_hmacs;
 	ep->auth_chunk_list = auth_chunks;
 	ep->prsctp_enable = net->sctp.prsctp_enable;
+	ep->reconf_enable = net->sctp.reconf_enable;
 
 	return ep;
 
diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index 102e816..f1efba6 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -270,6 +270,11 @@ struct sctp_chunk *sctp_make_init(const struct sctp_association *asoc,
 		num_ext += 2;
 	}
 
+	if (asoc->reconf_enable) {
+		extensions[num_ext] = SCTP_CID_RECONF;
+		num_ext += 1;
+	}
+
 	if (sp->adaptation_ind)
 		chunksize += sizeof(aiparam);
 
@@ -434,6 +439,11 @@ struct sctp_chunk *sctp_make_init_ack(const struct sctp_association *asoc,
 		num_ext += 2;
 	}
 
+	if (asoc->peer.reconf_capable) {
+		extensions[num_ext] = SCTP_CID_RECONF;
+		num_ext += 1;
+	}
+
 	if (sp->adaptation_ind)
 		chunksize += sizeof(aiparam);
 
@@ -2010,6 +2020,11 @@ static void sctp_process_ext_param(struct sctp_association *asoc,
 
 	for (i = 0; i < num_ext; i++) {
 		switch (param.ext->chunks[i]) {
+		case SCTP_CID_RECONF:
+			if (asoc->reconf_enable &&
+			    !asoc->peer.reconf_capable)
+				asoc->peer.reconf_capable = 1;
+			break;
 		case SCTP_CID_FWD_TSN:
 			if (asoc->prsctp_enable && !asoc->peer.prsctp_capable)
 				asoc->peer.prsctp_capable = 1;
diff --git a/net/sctp/sysctl.c b/net/sctp/sysctl.c
index daf8554..0e732f6 100644
--- a/net/sctp/sysctl.c
+++ b/net/sctp/sysctl.c
@@ -275,6 +275,13 @@ static struct ctl_table sctp_net_table[] = {
 		.proc_handler	= proc_dointvec,
 	},
 	{
+		.procname	= "reconf_enable",
+		.data		= &init_net.sctp.reconf_enable,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
+	{
 		.procname	= "auth_enable",
 		.data		= &init_net.sctp.auth_enable,
 		.maxlen		= sizeof(int),
-- 
2.1.0
