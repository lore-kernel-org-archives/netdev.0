From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next 6/7] sctp: Push struct net down into sctp_verify_ext_param
Date: Tue, 07 Aug 2012 10:29:08 -0700
Message-ID: <87fw7ybogr.fsf_-_@xmission.com>
References: <1344115837-6150-1-git-send-email-jan.ariyasu@hp.com>
	<87mx27rig7.fsf@xmission.com> <87zk67q31q.fsf_-_@xmission.com>
	<87ipcud3ld.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Vlad Yasevich <vyasevich@gmail.com>, linux-sctp@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jan Ariyasu <jan.ariyasu@hp.com>,
	Jan Ariyasu <jan.ariyasu@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Thomas Graf <tgraf@infradead.org>, Xi Wang <xi.wang@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87ipcud3ld.fsf_-_@xmission.com> (Eric W. Biederman's message of
	"Tue, 07 Aug 2012 10:17:02 -0700")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Add struct net as a parameter to sctp_verify_param so it can be passed
to sctp_verify_ext_param where struct net will be needed when the sctp
tunables become per net tunables.

Add struct net as a parameter to sctp_verify_init so struct net can be
passed to sctp_verify_param.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 include/net/sctp/structs.h |    6 +++---
 net/sctp/sm_make_chunk.c   |   11 ++++++-----
 net/sctp/sm_statefuns.c    |    6 +++---
 3 files changed, 12 insertions(+), 11 deletions(-)

diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index b0882f3..18052b4 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -1410,9 +1410,9 @@ struct sctp_endpoint *sctp_endpoint_is_match(struct sctp_endpoint *,
 int sctp_has_association(struct net *net, const union sctp_addr *laddr,
 			 const union sctp_addr *paddr);
 
-int sctp_verify_init(const struct sctp_association *asoc, sctp_cid_t,
-		     sctp_init_chunk_t *peer_init, struct sctp_chunk *chunk,
-		     struct sctp_chunk **err_chunk);
+int sctp_verify_init(struct net *net, const struct sctp_association *asoc,
+		     sctp_cid_t, sctp_init_chunk_t *peer_init,
+		     struct sctp_chunk *chunk, struct sctp_chunk **err_chunk);
 int sctp_process_init(struct sctp_association *, struct sctp_chunk *chunk,
 		      const union sctp_addr *peer,
 		      sctp_init_chunk_t *init, gfp_t gfp);
diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index fb12835..a4b096f 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -1940,7 +1940,7 @@ static int sctp_process_hn_param(const struct sctp_association *asoc,
 	return 0;
 }
 
-static int sctp_verify_ext_param(union sctp_params param)
+static int sctp_verify_ext_param(struct net *net, union sctp_params param)
 {
 	__u16 num_ext = ntohs(param.p->length) - sizeof(sctp_paramhdr_t);
 	int have_auth = 0;
@@ -2081,7 +2081,8 @@ static sctp_ierror_t sctp_process_unk_param(const struct sctp_association *asoc,
  *	SCTP_IERROR_ERROR - stop processing, trigger an ERROR
  * 	SCTP_IERROR_NO_ERROR - continue with the chunk
  */
-static sctp_ierror_t sctp_verify_param(const struct sctp_association *asoc,
+static sctp_ierror_t sctp_verify_param(struct net *net,
+					const struct sctp_association *asoc,
 					union sctp_params param,
 					sctp_cid_t cid,
 					struct sctp_chunk *chunk,
@@ -2110,7 +2111,7 @@ static sctp_ierror_t sctp_verify_param(const struct sctp_association *asoc,
 		break;
 
 	case SCTP_PARAM_SUPPORTED_EXT:
-		if (!sctp_verify_ext_param(param))
+		if (!sctp_verify_ext_param(net, param))
 			return SCTP_IERROR_ABORT;
 		break;
 
@@ -2198,7 +2199,7 @@ fallthrough:
 }
 
 /* Verify the INIT packet before we process it.  */
-int sctp_verify_init(const struct sctp_association *asoc,
+int sctp_verify_init(struct net *net, const struct sctp_association *asoc,
 		     sctp_cid_t cid,
 		     sctp_init_chunk_t *peer_init,
 		     struct sctp_chunk *chunk,
@@ -2245,7 +2246,7 @@ int sctp_verify_init(const struct sctp_association *asoc,
 	/* Verify all the variable length parameters */
 	sctp_walk_params(param, peer_init, init_hdr.params) {
 
-		result = sctp_verify_param(asoc, param, cid, chunk, errp);
+		result = sctp_verify_param(net, asoc, param, cid, chunk, errp);
 		switch (result) {
 		    case SCTP_IERROR_ABORT:
 		    case SCTP_IERROR_NOMEM:
diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index 3e5ca61..3722af2 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -364,7 +364,7 @@ sctp_disposition_t sctp_sf_do_5_1B_init(struct net *net,
 
 	/* Verify the INIT chunk before processing it. */
 	err_chunk = NULL;
-	if (!sctp_verify_init(asoc, chunk->chunk_hdr->type,
+	if (!sctp_verify_init(net, asoc, chunk->chunk_hdr->type,
 			      (sctp_init_chunk_t *)chunk->chunk_hdr, chunk,
 			      &err_chunk)) {
 		/* This chunk contains fatal error. It is to be discarded.
@@ -531,7 +531,7 @@ sctp_disposition_t sctp_sf_do_5_1C_ack(struct net *net,
 
 	/* Verify the INIT chunk before processing it. */
 	err_chunk = NULL;
-	if (!sctp_verify_init(asoc, chunk->chunk_hdr->type,
+	if (!sctp_verify_init(net, asoc, chunk->chunk_hdr->type,
 			      (sctp_init_chunk_t *)chunk->chunk_hdr, chunk,
 			      &err_chunk)) {
 
@@ -1429,7 +1429,7 @@ static sctp_disposition_t sctp_sf_do_unexpected_init(
 
 	/* Verify the INIT chunk before processing it. */
 	err_chunk = NULL;
-	if (!sctp_verify_init(asoc, chunk->chunk_hdr->type,
+	if (!sctp_verify_init(net, asoc, chunk->chunk_hdr->type,
 			      (sctp_init_chunk_t *)chunk->chunk_hdr, chunk,
 			      &err_chunk)) {
 		/* This chunk contains fatal error. It is to be discarded.
-- 
1.7.5.4
