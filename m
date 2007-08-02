From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: Re: [PATCH] SCTP: drop SACK if ctsn is not less than the next tsn
 of assoc
Date: Thu, 02 Aug 2007 16:57:44 +0800
Message-ID: <46B19C88.8070104@cn.fujitsu.com>
References: <18087.57737.908842.337891@zeus.sw.starentnetworks.com>		<46AEBE2B.1060702@cn.fujitsu.com>		<20070731113709.GA28333@hmsreliant.homelinux.net>	<1185902894.8234.5.camel@localhost.localdomain>	<46AFDC97.6080909@cn.fujitsu.com> <46AFFAB7.8050503@hp.com> <46B05EA9.4090507@cn.fujitsu.com> <46B08545.8030707@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Neil Horman <nhorman@tuxdriver.com>,
	lksctp-developers@lists.sourceforge.net,
	Sridhar Samudrala <sri@us.ibm.com>
To: Vlad Yasevich <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [222.73.24.84] ([222.73.24.84]:56836 "EHLO song.cn.fujitsu.com"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752338AbXHBI7O (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Aug 2007 04:59:14 -0400
In-Reply-To: <46B08545.8030707@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Vlad Yasevich wrote:
> This is a little better.
>
> One suggestion.  The new function you create is almost exactly like
> sctp_sf_violation_chunklen() with the exception of the error string.
> Can you extract the common parts into a single function so that
> we don't have duplication of code.
>
> Thanks
> -vlad
>
>
>   
>>>   
>>> This is an interesting case, but I am not sure that simply discarding
>>> the SACK is the right thing.
>>>
>>> The peer in this case is violating the protocol whereby he is trying to
>>> advance the cumulative tsn ack to a point beyond the max tsn currently
>>> sent. I would vote for terminating the association in this case since
>>> either the peer is a mis-behaved implementation, or the association is
>>> under attack.
>>>       
Patch has been modified base on comment.
Thanks.

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>

--- net/sctp/sm_statefuns.c.orig	2007-07-29 18:11:01.000000000 -0400
+++ net/sctp/sm_statefuns.c	2007-07-31 17:49:22.000000000 -0400
@@ -97,6 +97,13 @@
 					   const struct sctp_association *asoc,
 					   struct sctp_transport *transport);
 
+static sctp_disposition_t sctp_sf_abort_violation(
+				     const struct sctp_association *asoc,
+				     void *arg,
+				     sctp_cmd_seq_t *commands,
+				     const __u8 *payload,
+				     const size_t paylen);
+
 static sctp_disposition_t sctp_sf_violation_chunklen(
 				     const struct sctp_endpoint *ep,
 				     const struct sctp_association *asoc,
@@ -104,6 +111,13 @@
 				     void *arg,
 				     sctp_cmd_seq_t *commands);
 
+static sctp_disposition_t sctp_sf_violation_ctsn(
+				     const struct sctp_endpoint *ep,
+				     const struct sctp_association *asoc,
+				     const sctp_subtype_t type,
+				     void *arg,
+				     sctp_cmd_seq_t *commands);
+
 /* Small helper function that checks if the chunk length
  * is of the appropriate length.  The 'required_length' argument
  * is set to be the size of a specific chunk we are testing.
@@ -2880,6 +2894,13 @@
 		return SCTP_DISPOSITION_DISCARD;
 	}
 
+	/* If Cumulative TSN Ack beyond the max tsn currently
+	 * send, terminating the association and respond to the
+	 * sender with an ABORT.
+	 */
+	if (!TSN_lt(ctsn, asoc->next_tsn))
+		return sctp_sf_violation_ctsn(ep, asoc, type, arg, commands);
+
 	/* Return this SACK for further processing.  */
 	sctp_add_cmd_sf(commands, SCTP_CMD_PROCESS_SACK, SCTP_SACKH(sackh));
 
@@ -3691,40 +3712,21 @@
 	return SCTP_DISPOSITION_VIOLATION;
 }
 
-
 /*
- * Handle a protocol violation when the chunk length is invalid.
- * "Invalid" length is identified as smaller then the minimal length a
- * given chunk can be.  For example, a SACK chunk has invalid length
- * if it's length is set to be smaller then the size of sctp_sack_chunk_t.
- *
- * We inform the other end by sending an ABORT with a Protocol Violation
- * error code.
- *
- * Section: Not specified
- * Verification Tag:  Nothing to do
- * Inputs
- * (endpoint, asoc, chunk)
- *
- * Outputs
- * (reply_msg, msg_up, counters)
- *
- * Generate an  ABORT chunk and terminate the association.
+ * Common function to handle a protocol violation.
  */
-static sctp_disposition_t sctp_sf_violation_chunklen(
-				     const struct sctp_endpoint *ep,
+static sctp_disposition_t sctp_sf_abort_violation(
 				     const struct sctp_association *asoc,
-				     const sctp_subtype_t type,
 				     void *arg,
-				     sctp_cmd_seq_t *commands)
+				     sctp_cmd_seq_t *commands,
+				     const __u8 *payload,
+				     const size_t paylen)
 {
 	struct sctp_chunk *chunk =  arg;
 	struct sctp_chunk *abort = NULL;
-	char 		   err_str[]="The following chunk had invalid length:";
 
 	/* Make the abort chunk. */
-	abort = sctp_make_abort_violation(asoc, chunk, err_str,
-					  sizeof(err_str));
+	abort = sctp_make_abort_violation(asoc, chunk, payload, paylen);
 	if (!abort)
 		goto nomem;
 
@@ -3756,6 +3758,57 @@
 	return SCTP_DISPOSITION_NOMEM;
 }
 
+/*
+ * Handle a protocol violation when the chunk length is invalid.
+ * "Invalid" length is identified as smaller then the minimal length a
+ * given chunk can be.  For example, a SACK chunk has invalid length
+ * if it's length is set to be smaller then the size of sctp_sack_chunk_t.
+ *
+ * We inform the other end by sending an ABORT with a Protocol Violation
+ * error code.
+ *
+ * Section: Not specified
+ * Verification Tag:  Nothing to do
+ * Inputs
+ * (endpoint, asoc, chunk)
+ *
+ * Outputs
+ * (reply_msg, msg_up, counters)
+ *
+ * Generate an  ABORT chunk and terminate the association.
+ */
+static sctp_disposition_t sctp_sf_violation_chunklen(
+				     const struct sctp_endpoint *ep,
+				     const struct sctp_association *asoc,
+				     const sctp_subtype_t type,
+				     void *arg,
+				     sctp_cmd_seq_t *commands)
+{
+	char err_str[]="The following chunk had invalid length:";
+
+	return sctp_sf_abort_violation(asoc, arg, commands, err_str,
+					sizeof(err_str));
+}
+
+/* Handle a protocol violation when the peer trying to advance the
+ * cumulative tsn ack to a point beyond the max tsn currently sent.
+ *
+ * We inform the other end by sending an ABORT with a Protocol Violation
+ * error code.
+ */
+static sctp_disposition_t sctp_sf_violation_ctsn(
+				     const struct sctp_endpoint *ep,
+				     const struct sctp_association *asoc,
+				     const sctp_subtype_t type,
+				     void *arg,
+				     sctp_cmd_seq_t *commands)
+{
+	char err_str[]="The cumulative tsn ack beyond the max tsn currently sent:";
+
+	return sctp_sf_abort_violation(asoc, arg, commands, err_str,
+					sizeof(err_str));
+}
+
 /***************************************************************************
  * These are the state functions for handling primitive (Section 10) events.
  ***************************************************************************/


