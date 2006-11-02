From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATCH] warning in SCTP
Date: Thu, 02 Nov 2006 11:09:26 -0500
Message-ID: <454A1836.9010709@hp.com>
References: <Pine.SOC.4.61.0611020925530.1919@math.ut.ee> <20061102.001643.30183952.davem@davemloft.net> <20061102.003953.55508453.davem@davemloft.net> <Pine.SOC.4.61.0611021119560.1919@math.ut.ee>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060100060102060606070704"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	sri@us.ibm.com, lksctp-developers@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel9.hp.com ([156.153.255.214]:31179 "EHLO atlrel9.hp.com")
	by vger.kernel.org with ESMTP id S1751476AbWKBQJ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Nov 2006 11:09:28 -0500
To: Meelis Roos <mroos@linux.ee>
In-Reply-To: <Pine.SOC.4.61.0611021119560.1919@math.ut.ee>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------060100060102060606070704
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Meelis Roos wrote:
>> Actually, I'm backing this one out, it creates new warnings because
>> callers of this function pass in a "const" pointer.
> 
> Yes, it now seems it's not so simple. Marking it non-const there would
> mark the it non-const in the whole family of sctp_state_fn_t and I'm not
> sure that's the best thing to do. I guess the maintainer has better
> bases for deciding what to do about it.
> 

An alternate solution would be to make the digest a pointer, allocate
it in sctp_endpoint_init() and free it in sctp_endpoint_destroy().

I guess I should have originally done it this way...


  CC [M]  net/sctp/sm_make_chunk.o
net/sctp/sm_make_chunk.c: In function 'sctp_unpack_cookie':
net/sctp/sm_make_chunk.c:1358: warning: initialization discards qualifiers from pointer target type

The reason is that sctp_unpack_cookie() takes a const struct sctp_endpoint and modifies the digest in it
(digest being embedded in the struct, not a pointer).  Make digest a pointer to fix this warning.

Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com> 




--------------060100060102060606070704
Content-Type: text/x-patch;
 name="digest.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="digest.diff"

diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index c6d93bb..5596f5d 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -1270,7 +1270,7 @@ struct sctp_endpoint {
  	 * 	    this here so we pre-allocate this once and can re-use
  	 * 	    on every receive.
  	 */
- 	__u8 digest[SCTP_SIGNATURE_SIZE];
+ 	__u8 *digest;
  
 	/* sendbuf acct. policy.	*/
 	__u32 sndbuf_policy;
diff --git a/net/sctp/endpointola.c b/net/sctp/endpointola.c
index 35c49ff..4576933 100644
--- a/net/sctp/endpointola.c
+++ b/net/sctp/endpointola.c
@@ -72,6 +72,10 @@ static struct sctp_endpoint *sctp_endpoi
 {
 	memset(ep, 0, sizeof(struct sctp_endpoint));
 
+	ep->digest = kzalloc(SCTP_SIGNATURE_SIZE, gfp);
+	if (!ep->digest)
+		return NULL;
+
 	/* Initialize the base structure. */
 	/* What type of endpoint are we?  */
 	ep->base.type = SCTP_EP_TYPE_SOCKET;
@@ -175,6 +180,9 @@ static void sctp_endpoint_destroy(struct
 	/* Free up the HMAC transform. */
 	crypto_free_hash(sctp_sk(ep->base.sk)->hmac);
 
+	/* Free the digest buffer */
+	kfree(ep->digest);
+
 	/* Cleanup. */
 	sctp_inq_free(&ep->base.inqueue);
 	sctp_bind_addr_free(&ep->base.bind_addr);

--------------060100060102060606070704--
