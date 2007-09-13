From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH for 2.6.24] SCTP: Implete the Supported Extensions Parameter
Date: Thu, 13 Sep 2007 14:39:59 -0400
Message-ID: <1189708799108-git-send-email-vladislav.yasevich@hp.com>
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net,
	Vlad Yasevich <vladislav.yasevich@hp.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel6.hp.com ([156.153.255.205]:41053 "EHLO atlrel6.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752239AbXIMSkQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Sep 2007 14:40:16 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

SCTP Supported Extenions parameter is specified in Section 4.2.7
of the ADD-IP draft (soon to be RFC).  The parameter is
encoded as:

      0                   1                   2                   3
      0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     |     Parameter Type = 0x8008   |      Parameter Length         |
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     | CHUNK TYPE 1  |  CHUNK TYPE 2 |  CHUNK TYPE 3 |  CHUNK TYPE 4 |
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     |                             ....                              |
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     | CHUNK TYPE N  |      PAD      |      PAD      |      PAD      |
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+

It contains the list of chunks that a particular SCTP extension
usues.  Current extensions supported are Partial Reliability
(FWD-TSN) and ADD-IP (ASCONF and ASCONF-ACK).

When implementing new extensions (AUTH, PKT-DROP, etc..), new
chunks need to be added to this parameter.  Parameter processing
would be modified to negotiate support for these features.

Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 include/linux/sctp.h       |    9 ++++
 include/net/sctp/structs.h |    1 +
 net/sctp/sm_make_chunk.c   |   91 +++++++++++++++++++++++++++++++++++++++++++-
 3 files changed, 99 insertions(+), 2 deletions(-)

diff --git a/include/linux/sctp.h b/include/linux/sctp.h
index d70df61..f4d717b 100644
--- a/include/linux/sctp.h
+++ b/include/linux/sctp.h
@@ -180,6 +180,9 @@ typedef enum {
 	SCTP_PARAM_SUPPORTED_ADDRESS_TYPES	= __constant_htons(12),
 	SCTP_PARAM_ECN_CAPABLE			= __constant_htons(0x8000),
 
+	/* Add-IP: Supported Extensions, Section 4.2 */
+	SCTP_PARAM_SUPPORTED_EXT	= __constant_htons(0x8008),
+
 	/* PR-SCTP Sec 3.1 */
 	SCTP_PARAM_FWD_TSN_SUPPORT	= __constant_htons(0xc000),
 
@@ -296,6 +299,12 @@ typedef struct sctp_adaptation_ind_param {
 	__be32 adaptation_ind;
 } __attribute__((packed)) sctp_adaptation_ind_param_t;
 
+/* ADDIP Section 4.2.7 Supported Extensions Parameter */
+typedef struct sctp_supported_ext_param {
+	struct sctp_paramhdr param_hdr;
+	__u8 chunks[0];
+} __attribute__((packed)) sctp_supported_ext_param_t;
+
 /* RFC 2960.  Section 3.3.3 Initiation Acknowledgement (INIT ACK) (2):
  *   The INIT ACK chunk is used to acknowledge the initiation of an SCTP
  *   association.
diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index c0d5848..46d215b 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -435,6 +435,7 @@ union sctp_params {
 	struct sctp_ipv6addr_param *v6;
 	union sctp_addr_param *addr;
 	struct sctp_adaptation_ind_param *aind;
+	struct sctp_supported_ext_param *ext;
 };
 
 /* RFC 2960.  Section 3.3.5 Heartbeat.
diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index 79856c9..3d8f85f 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -179,6 +179,9 @@ struct sctp_chunk *sctp_make_init(const struct sctp_association *asoc,
 	sctp_supported_addrs_param_t sat;
 	__be16 types[2];
 	sctp_adaptation_ind_param_t aiparam;
+	sctp_supported_ext_param_t ext_param;
+	int num_ext = 0;
+	__u8 extensions[3];
 
 	/* RFC 2960 3.3.2 Initiation (INIT) (1)
 	 *
@@ -202,11 +205,31 @@ struct sctp_chunk *sctp_make_init(const struct sctp_association *asoc,
 
 	chunksize = sizeof(init) + addrs_len + SCTP_SAT_LEN(num_types);
 	chunksize += sizeof(ecap_param);
-	if (sctp_prsctp_enable)
+	if (sctp_prsctp_enable) {
 		chunksize += sizeof(prsctp_param);
+		extensions[num_ext] = SCTP_CID_FWD_TSN;
+		num_ext += 1;
+	}
+	/* ADDIP: Section 4.2.7:
+	 *  An implementation supporting this extension [ADDIP] MUST list
+	 *  the ASCONF,the ASCONF-ACK, and the AUTH  chunks in its INIT and
+	 *  INIT-ACK parameters.
+	 *  XXX: We don't support AUTH just yet, so don't list it.  AUTH
+	 *  support should add it.
+	 */
+	if (sctp_addip_enable) {
+		extensions[num_ext] = SCTP_CID_ASCONF;
+		extensions[num_ext+1] = SCTP_CID_ASCONF_ACK;
+		num_ext += 2;
+	}
+
 	chunksize += sizeof(aiparam);
 	chunksize += vparam_len;
 
+	/* If we have any extensions to report, account for that */
+	if (num_ext)
+		chunksize += sizeof(sctp_supported_ext_param_t) + num_ext;
+
 	/* RFC 2960 3.3.2 Initiation (INIT) (1)
 	 *
 	 * Note 3: An INIT chunk MUST NOT contain more than one Host
@@ -241,12 +264,27 @@ struct sctp_chunk *sctp_make_init(const struct sctp_association *asoc,
 	sctp_addto_chunk(retval, num_types * sizeof(__u16), &types);
 
 	sctp_addto_chunk(retval, sizeof(ecap_param), &ecap_param);
+
+	/* Add the supported extensions paramter.  Be nice and add this
+	 * fist before addiding the parameters for the extensions themselves
+	 */
+	if (num_ext) {
+		ext_param.param_hdr.type = SCTP_PARAM_SUPPORTED_EXT;
+		ext_param.param_hdr.length =
+			    htons(sizeof(sctp_supported_ext_param_t) + num_ext);
+		sctp_addto_chunk(retval, sizeof(sctp_supported_ext_param_t),
+				&ext_param);
+		sctp_addto_chunk(retval, num_ext, extensions);
+	}
+
 	if (sctp_prsctp_enable)
 		sctp_addto_chunk(retval, sizeof(prsctp_param), &prsctp_param);
+
 	aiparam.param_hdr.type = SCTP_PARAM_ADAPTATION_LAYER_IND;
 	aiparam.param_hdr.length = htons(sizeof(aiparam));
 	aiparam.adaptation_ind = htonl(sp->adaptation_ind);
 	sctp_addto_chunk(retval, sizeof(aiparam), &aiparam);
+
 nodata:
 	kfree(addrs.v);
 	return retval;
@@ -264,6 +302,9 @@ struct sctp_chunk *sctp_make_init_ack(const struct sctp_association *asoc,
 	int cookie_len;
 	size_t chunksize;
 	sctp_adaptation_ind_param_t aiparam;
+	sctp_supported_ext_param_t ext_param;
+	int num_ext = 0;
+	__u8 extensions[3];
 
 	retval = NULL;
 
@@ -294,9 +335,19 @@ struct sctp_chunk *sctp_make_init_ack(const struct sctp_association *asoc,
 		chunksize += sizeof(ecap_param);
 
 	/* Tell peer that we'll do PR-SCTP only if peer advertised.  */
-	if (asoc->peer.prsctp_capable)
+	if (asoc->peer.prsctp_capable) {
 		chunksize += sizeof(prsctp_param);
+		extensions[num_ext] = SCTP_CID_FWD_TSN;
+		num_ext += 1;
+	}
 
+	if (sctp_addip_enable) {
+		extensions[num_ext] = SCTP_CID_ASCONF;
+		extensions[num_ext+1] = SCTP_CID_ASCONF_ACK;
+		num_ext += 2;
+	}
+
+	chunksize += sizeof(ext_param) + num_ext;
 	chunksize += sizeof(aiparam);
 
 	/* Now allocate and fill out the chunk.  */
@@ -314,6 +365,14 @@ struct sctp_chunk *sctp_make_init_ack(const struct sctp_association *asoc,
 	sctp_addto_chunk(retval, cookie_len, cookie);
 	if (asoc->peer.ecn_capable)
 		sctp_addto_chunk(retval, sizeof(ecap_param), &ecap_param);
+	if (num_ext) {
+		ext_param.param_hdr.type = SCTP_PARAM_SUPPORTED_EXT;
+		ext_param.param_hdr.length =
+			    htons(sizeof(sctp_supported_ext_param_t) + num_ext);
+		sctp_addto_chunk(retval, sizeof(sctp_supported_ext_param_t),
+				 &ext_param);
+		sctp_addto_chunk(retval, num_ext, extensions);
+	}
 	if (asoc->peer.prsctp_capable)
 		sctp_addto_chunk(retval, sizeof(prsctp_param), &prsctp_param);
 
@@ -1663,6 +1722,28 @@ static int sctp_process_hn_param(const struct sctp_association *asoc,
 	return 0;
 }
 
+static void sctp_process_ext_param(struct sctp_association *asoc,
+				    union sctp_params param)
+{
+	__u16 num_ext = ntohs(param.p->length) - sizeof(sctp_paramhdr_t);
+	int i;
+
+	for (i = 0; i < num_ext; i++) {
+		switch (param.ext->chunks[i]) {
+		    case SCTP_CID_FWD_TSN:
+			    if (sctp_prsctp_enable &&
+				!asoc->peer.prsctp_capable)
+				    asoc->peer.prsctp_capable = 1;
+			    break;
+		    case SCTP_CID_ASCONF:
+		    case SCTP_CID_ASCONF_ACK:
+			    /* don't need to do anything for ASCONF */
+		    default:
+			    break;
+		}
+	}
+}
+
 /* RFC 3.2.1 & the Implementers Guide 2.2.
  *
  * The Parameter Types are encoded such that the
@@ -1779,11 +1860,13 @@ static int sctp_verify_param(const struct sctp_association *asoc,
 	case SCTP_PARAM_UNRECOGNIZED_PARAMETERS:
 	case SCTP_PARAM_ECN_CAPABLE:
 	case SCTP_PARAM_ADAPTATION_LAYER_IND:
+	case SCTP_PARAM_SUPPORTED_EXT:
 		break;
 
 	case SCTP_PARAM_HOST_NAME_ADDRESS:
 		/* Tell the peer, we won't support this param.  */
 		return sctp_process_hn_param(asoc, param, chunk, err_chunk);
+
 	case SCTP_PARAM_FWD_TSN_SUPPORT:
 		if (sctp_prsctp_enable)
 			break;
@@ -2128,6 +2211,10 @@ static int sctp_process_param(struct sctp_association *asoc,
 		asoc->peer.adaptation_ind = param.aind->adaptation_ind;
 		break;
 
+	case SCTP_PARAM_SUPPORTED_EXT:
+		sctp_process_ext_param(asoc, param);
+		break;
+
 	case SCTP_PARAM_FWD_TSN_SUPPORT:
 		if (sctp_prsctp_enable) {
 			asoc->peer.prsctp_capable = 1;
-- 
1.5.2.4

