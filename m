From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATCH]: sctp: Fix skb_over_panic resulting from multiple invalid
 parameter errors (CVE-2010-1173)
Date: Wed, 28 Apr 2010 14:27:11 -0400
Message-ID: <4BD87DFF.6080502@hp.com>
References: <20100428134748.GA4818@hmsreliant.think-freely.org> <4BD83F85.8090308@hp.com> <20100428142147.GB4818@hmsreliant.think-freely.org> <4BD8481E.3010509@hp.com> <4BD875C5.9000907@hp.com> <20100428181645.GD4818@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090900050902060108080606"
Cc: sri@us.ibm.com, linux-sctp@vger.kernel.org, eteo@redhat.com,
	netdev@vger.kernel.org, davem@davemloft.net, security@kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0014.houston.hp.com ([15.201.24.17]:8042 "EHLO
	g4t0014.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756233Ab0D1S1P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Apr 2010 14:27:15 -0400
In-Reply-To: <20100428181645.GD4818@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------090900050902060108080606
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit



Neil Horman wrote:
> On Wed, Apr 28, 2010 at 01:52:05PM -0400, Vlad Yasevich wrote:
>>
>> Vlad Yasevich wrote:
>>> Neil Horman wrote:
>>>> On Wed, Apr 28, 2010 at 10:00:37AM -0400, Vlad Yasevich wrote:
>>>>> I have this patch and a few others already queued.
>>>>>
>>>>> I was planning on sending these today for stable.
>>>>>
>>>>> Here is the full list of stable patches I have:
>>>>>
>>>>> sctp: Fix oops when sending queued ASCONF chunks
>>>>> sctp: fix to calc the INIT/INIT-ACK chunk length correctly is set
>>>>> sctp: per_cpu variables should be in bh_disabled section
>>>>> sctp: fix potential reference of a freed pointer
>>>>> sctp: avoid irq lock inversion while call sk->sk_data_ready()
>>>>>
>>>>> -vlad
>>>>>
>>>> Are you sure?  this oops looks _very_ simmilar to the INIT/INIT-ACK length
>>>> calculation oops described above, but is in fact different, and requires this
>>>> patch, from what I can see.  The right fix might be in the ASCONF chunk patch
>>>> you list above, but I don't see that in your tree at the moment, so I can't be
>>>> sure.
>>> As I said, I totally goofed when reading the description and I apologize.
>>> However, I do one comment regarding the patch.
>>>
>>> If the bad packet is REALLY long (I mean close to 65K IP limit), then
>>> we'll end up allocating a supper huge skb in this case and potentially exceed
>>> the IP length limitation.  Section 11.4 of rfc 4960 allows us to omit some
>>> errors and limit the size of the packet.
>>>
>>> I would recommend limiting this to MTU worth of potentiall errors.  This is
>>> on top of what the INIT-ACK is going to carry, so at most we'll sent 2 MTUs
>>> worth.  That's still a potential by amplification attack, but it's somewhat
>>> mitigated.
>>>
>>> Of course now we have to handle the case of checking for space before adding
>>> an error cause. :)
>>>
>> Hi Neil
>>
>> I am also not crazy about the pre-allocation scheme.  In the case where you have
>> say 100 parameters that are all 'skip' parameters, you'd end up pre-allocating a
>> huge buffer for absolutely nothing.
>>
> Would have been nice if you'd made your opinion known 4 hours ago when I was
> testing version 2 of this. :)
> 

sorry, fighting a head cold and need drugs to think clearly... ;)


>> This is another point toward a fixed error chunk size and let parameter
>> processing allocate it when it reaches a parameter that needs an error.
>>
> Hmm, ok, what would you say to a pathmtu sized chunk allocation in parameter
> processing that drops errors beyond its capacity
> Neil

Here is my quick take on this.  Haven't tested it at all.

-vlad

--------------090900050902060108080606
Content-Type: text/plain;
 name="neil"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="neil"

diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index 0fd5b4c..74d8d21 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -1959,8 +1959,10 @@ static void sctp_process_ext_param(struct sctp_association *asoc,
 static sctp_ierror_t sctp_process_unk_param(const struct sctp_association *asoc,
 					    union sctp_params param,
 					    struct sctp_chunk *chunk,
-					    struct sctp_chunk **errp)
+					    struct sctp_chunk **errp,
+					    unsigned int param_cnt)
 {
+	unsigned int needed_bytes;
 	int retval = SCTP_IERROR_NO_ERROR;
 
 	switch (param.p->type & SCTP_PARAM_ACTION_MASK) {
@@ -1976,11 +1978,41 @@ static sctp_ierror_t sctp_process_unk_param(const struct sctp_association *asoc,
 		/* Make an ERROR chunk, preparing enough room for
 		 * returning multiple unknown parameters.
 		 */
-		if (NULL == *errp)
-			*errp = sctp_make_op_error_space(asoc, chunk,
-					ntohs(chunk->chunk_hdr->length));
+		if (NULL == *errp) {
+			unsigned int len;
+
+			/* Reserver space for the worst possible case
+			 * at this time.  We count incomming chunk length
+			 * since error parameters carry the bad parameter
+			 * inself, plus have space for error headers for
+			 * the remaining number of parameters.
+			 */
+			len = ntohs(chunk->chunk_hdr->length);
+			len += sizeof(sctp_errhdr_t) * param_cnt;
+
+			/* We need to prevent amplification attacks that
+			 * result from sending 65K init chunks with all bad
+			 * params maliciously, so lets limit our error response
+			 * to 1 MTU worth of errors, but at least 1500 bytes
+			 * in case our pathmtu hasn't been updated yet.
+			 */
+			len = min(len, asoc ? asoc->pathmtu :
+						SCTP_DEFAULT_MAXSEGMENT);
+			*errp = sctp_make_op_error_space(asoc, chunk, len);
+		}
 
 		if (*errp) {
+			needed_bytes = sizeof(sctp_errhdr_t) +
+				       WORD_ROUND(ntohs(param.p->length));
+
+			if (skb_tailroom((*errp)->skb) < needed_bytes)
+				/*
+				 * If we're over our packet size here, don't add
+				 * the error, this is allowed by section 11.4 of
+				 * RFC 4960
+				 */
+				break;
+
 			sctp_init_cause(*errp, SCTP_ERROR_UNKNOWN_PARAM,
 					WORD_ROUND(ntohs(param.p->length)));
 			sctp_addto_chunk(*errp,
@@ -2013,7 +2045,8 @@ static sctp_ierror_t sctp_verify_param(const struct sctp_association *asoc,
 					union sctp_params param,
 					sctp_cid_t cid,
 					struct sctp_chunk *chunk,
-					struct sctp_chunk **err_chunk)
+					struct sctp_chunk **err_chunk,
+					unsigned int param_cnt)
 {
 	struct sctp_hmac_algo_param *hmacs;
 	int retval = SCTP_IERROR_NO_ERROR;
@@ -2119,7 +2152,8 @@ fallthrough:
 	default:
 		SCTP_DEBUG_PRINTK("Unrecognized param: %d for chunk %d.\n",
 				ntohs(param.p->type), cid);
-		retval = sctp_process_unk_param(asoc, param, chunk, err_chunk);
+		retval = sctp_process_unk_param(asoc, param, chunk, err_chunk,
+						param_cnt);
 		break;
 	}
 	return retval;
@@ -2135,6 +2169,7 @@ int sctp_verify_init(const struct sctp_association *asoc,
 	union sctp_params param;
 	int has_cookie = 0;
 	int result;
+	unsigned int param_cnt = 0;
 
 	/* Verify stream values are non-zero. */
 	if ((0 == peer_init->init_hdr.num_outbound_streams) ||
@@ -2150,6 +2185,7 @@ int sctp_verify_init(const struct sctp_association *asoc,
 
 		if (SCTP_PARAM_STATE_COOKIE == param.p->type)
 			has_cookie = 1;
+		param_cnt++;
 
 	} /* for (loop through all parameters) */
 
@@ -2173,7 +2209,8 @@ int sctp_verify_init(const struct sctp_association *asoc,
 	/* Verify all the variable length parameters */
 	sctp_walk_params(param, peer_init, init_hdr.params) {
 
-		result = sctp_verify_param(asoc, param, cid, chunk, errp);
+		result = sctp_verify_param(asoc, param, cid, chunk, errp,
+					   param_cnt);
 		switch (result) {
 		    case SCTP_IERROR_ABORT:
 		    case SCTP_IERROR_NOMEM:
@@ -2184,6 +2221,7 @@ int sctp_verify_init(const struct sctp_association *asoc,
 		    default:
 				break;
 		}
+		param_cnt--;
 
 	} /* for (loop through all parameters) */
 

--------------090900050902060108080606--
