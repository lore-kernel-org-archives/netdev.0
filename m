From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCHv4 net-next 4/6] sctp: add reconf_enable in asoc ep and netns
Date: Wed, 18 Jan 2017 00:44:45 +0800
Message-ID: <d016227bd6d957ee304bb9a7454a7e378801c6cf.1484670664.git.lucien.xin@gmail.com>
References: <cover.1484670664.git.lucien.xin@gmail.com>
 <eff824eb34c55a83e35334597e6d510a5dde3ce6.1484670664.git.lucien.xin@gmail.com>
 <1a1ff083ca37b6de6bacf038ae5d0367f0112edd.1484670664.git.lucien.xin@gmail.com>
 <9c7e8c3427aa17874b192a06175800c333a54438.1484670664.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        Vlad Yasevich <vyasevich@gmail.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:34236 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750996AbdAQQpi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2017 11:45:38 -0500
In-Reply-To: <9c7e8c3427aa17874b192a06175800c333a54438.1484670664.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1484670664.git.lucien.xin@gmail.com>
References: <cover.1484670664.git.lucien.xin@gmail.com>
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
 net/sctp/protocol.c        |  3 +++
 net/sctp/sm_make_chunk.c   | 15 +++++++++++++++
 6 files changed, 28 insertions(+), 2 deletions(-)

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
index 463b4d6..ee037ef 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -1255,7 +1255,8 @@ struct sctp_endpoint {
 	struct list_head endpoint_shared_keys;
 	__u16 active_key_id;
 	__u8  auth_enable:1,
-	      prsctp_enable:1;
+	      prsctp_enable:1,
+	      reconf_enable:1;
 };
 
 /* Recover the outter endpoint structure. */
@@ -1508,6 +1509,7 @@ struct sctp_association {
 			hostname_address:1, /* Peer understands DNS addresses? */
 			asconf_capable:1,   /* Does peer support ADDIP? */
 			prsctp_capable:1,   /* Can peer do PR-SCTP? */
+			reconf_capable:1,   /* Can peer do RE-CONFIG? */
 			auth_capable:1;     /* Is peer doing SCTP-AUTH? */
 
 		/* sack_needed : This flag indicates if the next received
@@ -1867,7 +1869,8 @@ struct sctp_association {
 
 	__u8 need_ecne:1,	/* Need to send an ECNE Chunk? */
 	     temp:1,		/* Is it a temporary association? */
-	     prsctp_enable:1;
+	     prsctp_enable:1,
+	     reconf_enable:1;
 
 	__u32 strreset_outseq; /* Update after receiving response */
 	__u32 strreset_inseq; /* Update after receiving request */
diff --git a/net/sctp/associola.c b/net/sctp/associola.c
index fc33540..68b99ad 100644
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
 
diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index f9c3c37..8227bbb 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -1258,6 +1258,9 @@ static int __net_init sctp_defaults_init(struct net *net)
 	/* Enable PR-SCTP by default. */
 	net->sctp.prsctp_enable = 1;
 
+	/* Disable RECONF by default. */
+	net->sctp.reconf_enable = 0;
+
 	/* Disable AUTH by default. */
 	net->sctp.auth_enable = 0;
 
diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index 172385c..c4a0a9c 100644
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
 
@@ -2012,6 +2022,11 @@ static void sctp_process_ext_param(struct sctp_association *asoc,
 
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
-- 
2.1.0
