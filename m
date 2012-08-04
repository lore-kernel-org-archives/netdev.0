From: Jan Ariyasu <jan.ariyasu@gmail.com>
Subject: [PATCH 12/13] SCTP: Enable chunk-auth verification (RFC4895).
Date: Sat,  4 Aug 2012 15:34:32 -0600
Message-ID: <1344116072-6563-1-git-send-email-jan.ariyasu@hp.com>
Cc: Jan Ariyasu <jan.ariyasu@hp.com>
To: Vlad Yasevich <vyasevich@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch replaces the global parameter sctp_auth_enable with
the per-namespace parameter stored in struct net.

Signed-off-by: Jan Ariyasu <jan.ariyasu@hp.com>
---
 net/sctp/endpointola.c   |    4 +++-
 net/sctp/sm_statetable.c |   11 +++++++----
 net/sctp/socket.c        |   32 ++++++++++++++++++++++++--------
 3 files changed, 34 insertions(+), 13 deletions(-)

diff --git a/net/sctp/endpointola.c b/net/sctp/endpointola.c
index 750df47..5fa20a1 100644
--- a/net/sctp/endpointola.c
+++ b/net/sctp/endpointola.c
@@ -70,12 +70,14 @@ static struct sctp_endpoint *sctp_endpoint_init(struct sctp_endpoint *ep,
 	struct sctp_shared_key *null_key;
 	int err;
 	struct net *net = sock_net(sk);
+	struct sctp_net_params *net_params =
+		sctp_get_params(net);
 
 	ep->digest = kzalloc(SCTP_SIGNATURE_SIZE, gfp);
 	if (!ep->digest)
 		return NULL;
 
-	if (sctp_auth_enable) {
+	if (net_params->auth_enable) {
 		/* Allocate space for HMACS and CHUNKS authentication
 		 * variables.  There are arrays that we encode directly
 		 * into parameters to make the rest of the operations easier.
diff --git a/net/sctp/sm_statetable.c b/net/sctp/sm_statetable.c
index c249e59..5177130 100644
--- a/net/sctp/sm_statetable.c
+++ b/net/sctp/sm_statetable.c
@@ -59,7 +59,8 @@ other_event_table[SCTP_NUM_OTHER_TYPES][SCTP_STATE_NUM_STATES];
 static const sctp_sm_table_entry_t
 timeout_event_table[SCTP_NUM_TIMEOUT_TYPES][SCTP_STATE_NUM_STATES];
 
-static const sctp_sm_table_entry_t *sctp_chunk_event_lookup(sctp_cid_t cid,
+static const sctp_sm_table_entry_t *sctp_chunk_event_lookup(struct net *net,
+							    sctp_cid_t cid,
 							    sctp_state_t state);
 
 
@@ -89,7 +90,7 @@ const sctp_sm_table_entry_t *sctp_sm_lookup_event(struct net *net,
 {
 	switch (event_type) {
 	case SCTP_EVENT_T_CHUNK:
-		return sctp_chunk_event_lookup(event_subtype.chunk, state);
+		return sctp_chunk_event_lookup(net, event_subtype.chunk, state);
 	case SCTP_EVENT_T_TIMEOUT:
 		return DO_LOOKUP(SCTP_EVENT_TIMEOUT_MAX, timeout,
 				 timeout_event_table);
@@ -907,9 +908,11 @@ static const sctp_sm_table_entry_t timeout_event_table[SCTP_NUM_TIMEOUT_TYPES][S
 	TYPE_SCTP_EVENT_TIMEOUT_AUTOCLOSE,
 };
 
-static const sctp_sm_table_entry_t *sctp_chunk_event_lookup(sctp_cid_t cid,
+static const sctp_sm_table_entry_t *sctp_chunk_event_lookup(struct net *net,
+							    sctp_cid_t cid,
 							    sctp_state_t state)
 {
+	struct sctp_net_params *net_params = sctp_get_params(net);
 	if (state > SCTP_STATE_MAX)
 		return &bug;
 
@@ -929,7 +932,7 @@ static const sctp_sm_table_entry_t *sctp_chunk_event_lookup(sctp_cid_t cid,
 			return &addip_chunk_event_table[1][state];
 	}
 
-	if (sctp_auth_enable) {
+	if (net_params->auth_enable) {
 		if (cid == SCTP_CID_AUTH)
 			return &auth_chunk_event_table[0][state];
 	}
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 9712ea5..e8148a0 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -3300,8 +3300,10 @@ static int sctp_setsockopt_auth_chunk(struct sock *sk,
 				      unsigned int optlen)
 {
 	struct sctp_authchunk val;
+	struct sctp_net_params *net_params =
+		sctp_get_params(sock_net(sk));
 
-	if (!sctp_auth_enable)
+	if (!net_params->auth_enable)
 		return -EACCES;
 
 	if (optlen != sizeof(struct sctp_authchunk))
@@ -3334,8 +3336,10 @@ static int sctp_setsockopt_hmac_ident(struct sock *sk,
 	struct sctp_hmacalgo *hmacs;
 	u32 idents;
 	int err;
+	struct sctp_net_params *net_params =
+		sctp_get_params(sock_net(sk));
 
-	if (!sctp_auth_enable)
+	if (!net_params->auth_enable)
 		return -EACCES;
 
 	if (optlen < sizeof(struct sctp_hmacalgo))
@@ -3371,8 +3375,10 @@ static int sctp_setsockopt_auth_key(struct sock *sk,
 	struct sctp_authkey *authkey;
 	struct sctp_association *asoc;
 	int ret;
+	struct sctp_net_params *net_params =
+		sctp_get_params(sock_net(sk));
 
-	if (!sctp_auth_enable)
+	if (!net_params->auth_enable)
 		return -EACCES;
 
 	if (optlen <= sizeof(struct sctp_authkey))
@@ -3442,8 +3448,10 @@ static int sctp_setsockopt_del_key(struct sock *sk,
 {
 	struct sctp_authkeyid val;
 	struct sctp_association *asoc;
+	struct sctp_net_params *net_params =
+		sctp_get_params(sock_net(sk));
 
-	if (!sctp_auth_enable)
+	if (!net_params->auth_enable)
 		return -EACCES;
 
 	if (optlen != sizeof(struct sctp_authkeyid))
@@ -5326,8 +5334,10 @@ static int sctp_getsockopt_hmac_ident(struct sock *sk, int len,
 	struct sctp_hmac_algo_param *hmacs;
 	__u16 data_len = 0;
 	u32 num_idents;
+	struct sctp_net_params *net_params =
+		sctp_get_params(sock_net(sk));
 
-	if (!sctp_auth_enable)
+	if (!net_params->auth_enable)
 		return -EACCES;
 
 	hmacs = sctp_sk(sk)->ep->auth_hmacs_list;
@@ -5353,8 +5363,10 @@ static int sctp_getsockopt_active_key(struct sock *sk, int len,
 {
 	struct sctp_authkeyid val;
 	struct sctp_association *asoc;
+	struct sctp_net_params *net_params =
+		sctp_get_params(sock_net(sk));
 
-	if (!sctp_auth_enable)
+	if (!net_params->auth_enable)
 		return -EACCES;
 
 	if (len < sizeof(struct sctp_authkeyid))
@@ -5389,8 +5401,10 @@ static int sctp_getsockopt_peer_auth_chunks(struct sock *sk, int len,
 	struct sctp_chunks_param *ch;
 	u32    num_chunks = 0;
 	char __user *to;
+	struct sctp_net_params *net_params =
+		sctp_get_params(sock_net(sk));
 
-	if (!sctp_auth_enable)
+	if (!net_params->auth_enable)
 		return -EACCES;
 
 	if (len < sizeof(struct sctp_authchunks))
@@ -5432,8 +5446,10 @@ static int sctp_getsockopt_local_auth_chunks(struct sock *sk, int len,
 	struct sctp_chunks_param *ch;
 	u32    num_chunks = 0;
 	char __user *to;
+	struct sctp_net_params *net_params =
+		sctp_get_params(sock_net(sk));
 
-	if (!sctp_auth_enable)
+	if (!net_params->auth_enable)
 		return -EACCES;
 
 	if (len < sizeof(struct sctp_authchunks))
-- 
1.7.9.5
