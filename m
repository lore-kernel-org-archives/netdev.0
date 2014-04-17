From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net] net: sctp: cache auth_enable per endpoint
Date: Thu, 17 Apr 2014 17:26:50 +0200
Message-ID: <1397748410-1983-1-git-send-email-dborkman@redhat.com>
Cc: kumba@gentoo.org, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org, Vlad Yasevich <vyasevic@redhat.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:9536 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751394AbaDQP04 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Apr 2014 11:26:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vyasevic@redhat.com>

Currently, it is possible to create an SCTP socket, then switch
auth_enable via sysctl setting to 1 and crash the system on connect:

Oops[#1]:
CPU: 0 PID: 0 Comm: swapper Not tainted 3.14.1-mipsgit-20140415 #1
task: ffffffff8056ce80 ti: ffffffff8055c000 task.ti: ffffffff8055c000
[...]
Call Trace:
[<ffffffff8043c4e8>] sctp_auth_asoc_set_default_hmac+0x68/0x80
[<ffffffff8042b300>] sctp_process_init+0x5e0/0x8a4
[<ffffffff8042188c>] sctp_sf_do_5_1B_init+0x234/0x34c
[<ffffffff804228c8>] sctp_do_sm+0xb4/0x1e8
[<ffffffff80425a08>] sctp_endpoint_bh_rcv+0x1c4/0x214
[<ffffffff8043af68>] sctp_rcv+0x588/0x630
[<ffffffff8043e8e8>] sctp6_rcv+0x10/0x24
[<ffffffff803acb50>] ip6_input+0x2c0/0x440
[<ffffffff8030fc00>] __netif_receive_skb_core+0x4a8/0x564
[<ffffffff80310650>] process_backlog+0xb4/0x18c
[<ffffffff80313cbc>] net_rx_action+0x12c/0x210
[<ffffffff80034254>] __do_softirq+0x17c/0x2ac
[<ffffffff800345e0>] irq_exit+0x54/0xb0
[<ffffffff800075a4>] ret_from_irq+0x0/0x4
[<ffffffff800090ec>] rm7k_wait_irqoff+0x24/0x48
[<ffffffff8005e388>] cpu_startup_entry+0xc0/0x148
[<ffffffff805a88b0>] start_kernel+0x37c/0x398
Code: dd0900b8  000330f8  0126302d <dcc60000> 50c0fff1  0047182a  a48306a0
03e00008  00000000
---[ end trace b530b0551467f2fd ]---
Kernel panic - not syncing: Fatal exception in interrupt

What happens while auth_enable=0 in that case is, that
ep->auth_hmacs is initialized to NULL in sctp_auth_init_hmacs()
when endpoint is being created.

After that point, if an admin switches over to auth_enable=1,
the machine can crash due to NULL pointer dereference during
reception of an INIT chunk. When we enter sctp_process_init()
via sctp_sf_do_5_1B_init() in order to respond to an INIT chunk,
the INIT verification succeeds and while we walk and process
all INIT params via sctp_process_param() we find that
net->sctp.auth_enable is set, therefore do not fall through,
but invoke sctp_auth_asoc_set_default_hmac() instead, and thus,
dereference what we have set to NULL during endpoint
initialization phase.

The fix is to make auth_enable immutable by caching its value
during endpoint initialization, so that its original value is
being carried along until destruction. The bug seems to originate
from the very first days.

Fix in joint work with Daniel Borkmann.

Reported-by: Joshua Kinard <kumba@gentoo.org>
Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 Joshua, we did various tests, looks good on our side with this patch,
 please also try it if it fixes the issue on your side and add your
 Tested-by tag, thanks a bunch!

 include/net/sctp/structs.h |  4 +++-
 net/sctp/auth.c            | 17 ++++++---------
 net/sctp/endpointola.c     |  3 ++-
 net/sctp/sm_make_chunk.c   | 32 ++++++++++++++-------------
 net/sctp/sm_statefuns.c    |  6 +++---
 net/sctp/socket.c          | 54 ++++++++++++++++++++++------------------------
 net/sctp/sysctl.c          | 36 ++++++++++++++++++++++++++++++-
 7 files changed, 92 insertions(+), 60 deletions(-)

diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index d992ca3..0dfcc92 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -1241,6 +1241,7 @@ struct sctp_endpoint {
 	/* SCTP-AUTH: endpoint shared keys */
 	struct list_head endpoint_shared_keys;
 	__u16 active_key_id;
+	__u8  auth_enable;
 };
 
 /* Recover the outter endpoint structure. */
@@ -1269,7 +1270,8 @@ struct sctp_endpoint *sctp_endpoint_is_match(struct sctp_endpoint *,
 int sctp_has_association(struct net *net, const union sctp_addr *laddr,
 			 const union sctp_addr *paddr);
 
-int sctp_verify_init(struct net *net, const struct sctp_association *asoc,
+int sctp_verify_init(struct net *net, const struct sctp_endpoint *ep,
+		     const struct sctp_association *asoc,
 		     sctp_cid_t, sctp_init_chunk_t *peer_init,
 		     struct sctp_chunk *chunk, struct sctp_chunk **err_chunk);
 int sctp_process_init(struct sctp_association *, struct sctp_chunk *chunk,
diff --git a/net/sctp/auth.c b/net/sctp/auth.c
index 683c7d1..0e85291 100644
--- a/net/sctp/auth.c
+++ b/net/sctp/auth.c
@@ -386,14 +386,13 @@ nomem:
  */
 int sctp_auth_asoc_init_active_key(struct sctp_association *asoc, gfp_t gfp)
 {
-	struct net *net = sock_net(asoc->base.sk);
 	struct sctp_auth_bytes	*secret;
 	struct sctp_shared_key *ep_key;
 
 	/* If we don't support AUTH, or peer is not capable
 	 * we don't need to do anything.
 	 */
-	if (!net->sctp.auth_enable || !asoc->peer.auth_capable)
+	if (!asoc->ep->auth_enable || !asoc->peer.auth_capable)
 		return 0;
 
 	/* If the key_id is non-zero and we couldn't find an
@@ -440,16 +439,16 @@ struct sctp_shared_key *sctp_auth_get_shkey(
  */
 int sctp_auth_init_hmacs(struct sctp_endpoint *ep, gfp_t gfp)
 {
-	struct net *net = sock_net(ep->base.sk);
 	struct crypto_hash *tfm = NULL;
 	__u16   id;
 
-	/* if the transforms are already allocted, we are done */
-	if (!net->sctp.auth_enable) {
+	/* If AUTH extension is disabled, we are done */
+	if (!ep->auth_enable) {
 		ep->auth_hmacs = NULL;
 		return 0;
 	}
 
+	/* If the transforms are already allocated, we are done */
 	if (ep->auth_hmacs)
 		return 0;
 
@@ -665,12 +664,10 @@ static int __sctp_auth_cid(sctp_cid_t chunk, struct sctp_chunks_param *param)
 /* Check if peer requested that this chunk is authenticated */
 int sctp_auth_send_cid(sctp_cid_t chunk, const struct sctp_association *asoc)
 {
-	struct net  *net;
 	if (!asoc)
 		return 0;
 
-	net = sock_net(asoc->base.sk);
-	if (!net->sctp.auth_enable || !asoc->peer.auth_capable)
+	if (!asoc->ep->auth_enable || !asoc->peer.auth_capable)
 		return 0;
 
 	return __sctp_auth_cid(chunk, asoc->peer.peer_chunks);
@@ -679,12 +676,10 @@ int sctp_auth_send_cid(sctp_cid_t chunk, const struct sctp_association *asoc)
 /* Check if we requested that peer authenticate this chunk. */
 int sctp_auth_recv_cid(sctp_cid_t chunk, const struct sctp_association *asoc)
 {
-	struct net *net;
 	if (!asoc)
 		return 0;
 
-	net = sock_net(asoc->base.sk);
-	if (!net->sctp.auth_enable)
+	if (!asoc->ep->auth_enable)
 		return 0;
 
 	return __sctp_auth_cid(chunk,
diff --git a/net/sctp/endpointola.c b/net/sctp/endpointola.c
index 8e5fdea..3d9f429 100644
--- a/net/sctp/endpointola.c
+++ b/net/sctp/endpointola.c
@@ -68,7 +68,8 @@ static struct sctp_endpoint *sctp_endpoint_init(struct sctp_endpoint *ep,
 	if (!ep->digest)
 		return NULL;
 
-	if (net->sctp.auth_enable) {
+	ep->auth_enable = net->sctp.auth_enable;
+	if (ep->auth_enable) {
 		/* Allocate space for HMACS and CHUNKS authentication
 		 * variables.  There are arrays that we encode directly
 		 * into parameters to make the rest of the operations easier.
diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index 3a1767e..fee5552 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -219,6 +219,7 @@ struct sctp_chunk *sctp_make_init(const struct sctp_association *asoc,
 			     gfp_t gfp, int vparam_len)
 {
 	struct net *net = sock_net(asoc->base.sk);
+	struct sctp_endpoint *ep = asoc->ep;
 	sctp_inithdr_t init;
 	union sctp_params addrs;
 	size_t chunksize;
@@ -278,7 +279,7 @@ struct sctp_chunk *sctp_make_init(const struct sctp_association *asoc,
 	chunksize += vparam_len;
 
 	/* Account for AUTH related parameters */
-	if (net->sctp.auth_enable) {
+	if (ep->auth_enable) {
 		/* Add random parameter length*/
 		chunksize += sizeof(asoc->c.auth_random);
 
@@ -363,7 +364,7 @@ struct sctp_chunk *sctp_make_init(const struct sctp_association *asoc,
 	}
 
 	/* Add SCTP-AUTH chunks to the parameter list */
-	if (net->sctp.auth_enable) {
+	if (ep->auth_enable) {
 		sctp_addto_chunk(retval, sizeof(asoc->c.auth_random),
 				 asoc->c.auth_random);
 		if (auth_hmacs)
@@ -2010,7 +2011,7 @@ static void sctp_process_ext_param(struct sctp_association *asoc,
 			/* if the peer reports AUTH, assume that he
 			 * supports AUTH.
 			 */
-			if (net->sctp.auth_enable)
+			if (asoc->ep->auth_enable)
 				asoc->peer.auth_capable = 1;
 			break;
 		case SCTP_CID_ASCONF:
@@ -2102,6 +2103,7 @@ static sctp_ierror_t sctp_process_unk_param(const struct sctp_association *asoc,
  * 	SCTP_IERROR_NO_ERROR - continue with the chunk
  */
 static sctp_ierror_t sctp_verify_param(struct net *net,
+					const struct sctp_endpoint *ep,
 					const struct sctp_association *asoc,
 					union sctp_params param,
 					sctp_cid_t cid,
@@ -2152,7 +2154,7 @@ static sctp_ierror_t sctp_verify_param(struct net *net,
 		goto fallthrough;
 
 	case SCTP_PARAM_RANDOM:
-		if (!net->sctp.auth_enable)
+		if (!ep->auth_enable)
 			goto fallthrough;
 
 		/* SCTP-AUTH: Secion 6.1
@@ -2169,7 +2171,7 @@ static sctp_ierror_t sctp_verify_param(struct net *net,
 		break;
 
 	case SCTP_PARAM_CHUNKS:
-		if (!net->sctp.auth_enable)
+		if (!ep->auth_enable)
 			goto fallthrough;
 
 		/* SCTP-AUTH: Section 3.2
@@ -2185,7 +2187,7 @@ static sctp_ierror_t sctp_verify_param(struct net *net,
 		break;
 
 	case SCTP_PARAM_HMAC_ALGO:
-		if (!net->sctp.auth_enable)
+		if (!ep->auth_enable)
 			goto fallthrough;
 
 		hmacs = (struct sctp_hmac_algo_param *)param.p;
@@ -2220,10 +2222,9 @@ fallthrough:
 }
 
 /* Verify the INIT packet before we process it.  */
-int sctp_verify_init(struct net *net, const struct sctp_association *asoc,
-		     sctp_cid_t cid,
-		     sctp_init_chunk_t *peer_init,
-		     struct sctp_chunk *chunk,
+int sctp_verify_init(struct net *net, const struct sctp_endpoint *ep,
+		     const struct sctp_association *asoc, sctp_cid_t cid,
+		     sctp_init_chunk_t *peer_init, struct sctp_chunk *chunk,
 		     struct sctp_chunk **errp)
 {
 	union sctp_params param;
@@ -2264,8 +2265,8 @@ int sctp_verify_init(struct net *net, const struct sctp_association *asoc,
 
 	/* Verify all the variable length parameters */
 	sctp_walk_params(param, peer_init, init_hdr.params) {
-
-		result = sctp_verify_param(net, asoc, param, cid, chunk, errp);
+		result = sctp_verify_param(net, ep, asoc, param, cid,
+					   chunk, errp);
 		switch (result) {
 		case SCTP_IERROR_ABORT:
 		case SCTP_IERROR_NOMEM:
@@ -2497,6 +2498,7 @@ static int sctp_process_param(struct sctp_association *asoc,
 	struct sctp_af *af;
 	union sctp_addr_param *addr_param;
 	struct sctp_transport *t;
+	struct sctp_endpoint *ep = asoc->ep;
 
 	/* We maintain all INIT parameters in network byte order all the
 	 * time.  This allows us to not worry about whether the parameters
@@ -2636,7 +2638,7 @@ do_addr_param:
 		goto fall_through;
 
 	case SCTP_PARAM_RANDOM:
-		if (!net->sctp.auth_enable)
+		if (!ep->auth_enable)
 			goto fall_through;
 
 		/* Save peer's random parameter */
@@ -2649,7 +2651,7 @@ do_addr_param:
 		break;
 
 	case SCTP_PARAM_HMAC_ALGO:
-		if (!net->sctp.auth_enable)
+		if (!ep->auth_enable)
 			goto fall_through;
 
 		/* Save peer's HMAC list */
@@ -2665,7 +2667,7 @@ do_addr_param:
 		break;
 
 	case SCTP_PARAM_CHUNKS:
-		if (!net->sctp.auth_enable)
+		if (!ep->auth_enable)
 			goto fall_through;
 
 		asoc->peer.peer_chunks = kmemdup(param.p,
diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index ae9fbeb..5170a1f 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -357,7 +357,7 @@ sctp_disposition_t sctp_sf_do_5_1B_init(struct net *net,
 
 	/* Verify the INIT chunk before processing it. */
 	err_chunk = NULL;
-	if (!sctp_verify_init(net, asoc, chunk->chunk_hdr->type,
+	if (!sctp_verify_init(net, ep, asoc, chunk->chunk_hdr->type,
 			      (sctp_init_chunk_t *)chunk->chunk_hdr, chunk,
 			      &err_chunk)) {
 		/* This chunk contains fatal error. It is to be discarded.
@@ -524,7 +524,7 @@ sctp_disposition_t sctp_sf_do_5_1C_ack(struct net *net,
 
 	/* Verify the INIT chunk before processing it. */
 	err_chunk = NULL;
-	if (!sctp_verify_init(net, asoc, chunk->chunk_hdr->type,
+	if (!sctp_verify_init(net, ep, asoc, chunk->chunk_hdr->type,
 			      (sctp_init_chunk_t *)chunk->chunk_hdr, chunk,
 			      &err_chunk)) {
 
@@ -1430,7 +1430,7 @@ static sctp_disposition_t sctp_sf_do_unexpected_init(
 
 	/* Verify the INIT chunk before processing it. */
 	err_chunk = NULL;
-	if (!sctp_verify_init(net, asoc, chunk->chunk_hdr->type,
+	if (!sctp_verify_init(net, ep, asoc, chunk->chunk_hdr->type,
 			      (sctp_init_chunk_t *)chunk->chunk_hdr, chunk,
 			      &err_chunk)) {
 		/* This chunk contains fatal error. It is to be discarded.
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index ff20e2d..fee06b9 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -3321,10 +3321,10 @@ static int sctp_setsockopt_auth_chunk(struct sock *sk,
 				      char __user *optval,
 				      unsigned int optlen)
 {
-	struct net *net = sock_net(sk);
+	struct sctp_endpoint *ep = sctp_sk(sk)->ep;
 	struct sctp_authchunk val;
 
-	if (!net->sctp.auth_enable)
+	if (!ep->auth_enable)
 		return -EACCES;
 
 	if (optlen != sizeof(struct sctp_authchunk))
@@ -3341,7 +3341,7 @@ static int sctp_setsockopt_auth_chunk(struct sock *sk,
 	}
 
 	/* add this chunk id to the endpoint */
-	return sctp_auth_ep_add_chunkid(sctp_sk(sk)->ep, val.sauth_chunk);
+	return sctp_auth_ep_add_chunkid(ep, val.sauth_chunk);
 }
 
 /*
@@ -3354,12 +3354,12 @@ static int sctp_setsockopt_hmac_ident(struct sock *sk,
 				      char __user *optval,
 				      unsigned int optlen)
 {
-	struct net *net = sock_net(sk);
+	struct sctp_endpoint *ep = sctp_sk(sk)->ep;
 	struct sctp_hmacalgo *hmacs;
 	u32 idents;
 	int err;
 
-	if (!net->sctp.auth_enable)
+	if (!ep->auth_enable)
 		return -EACCES;
 
 	if (optlen < sizeof(struct sctp_hmacalgo))
@@ -3376,7 +3376,7 @@ static int sctp_setsockopt_hmac_ident(struct sock *sk,
 		goto out;
 	}
 
-	err = sctp_auth_ep_set_hmacs(sctp_sk(sk)->ep, hmacs);
+	err = sctp_auth_ep_set_hmacs(ep, hmacs);
 out:
 	kfree(hmacs);
 	return err;
@@ -3392,12 +3392,12 @@ static int sctp_setsockopt_auth_key(struct sock *sk,
 				    char __user *optval,
 				    unsigned int optlen)
 {
-	struct net *net = sock_net(sk);
+	struct sctp_endpoint *ep = sctp_sk(sk)->ep;
 	struct sctp_authkey *authkey;
 	struct sctp_association *asoc;
 	int ret;
 
-	if (!net->sctp.auth_enable)
+	if (!ep->auth_enable)
 		return -EACCES;
 
 	if (optlen <= sizeof(struct sctp_authkey))
@@ -3418,7 +3418,7 @@ static int sctp_setsockopt_auth_key(struct sock *sk,
 		goto out;
 	}
 
-	ret = sctp_auth_set_key(sctp_sk(sk)->ep, asoc, authkey);
+	ret = sctp_auth_set_key(ep, asoc, authkey);
 out:
 	kzfree(authkey);
 	return ret;
@@ -3434,11 +3434,11 @@ static int sctp_setsockopt_active_key(struct sock *sk,
 				      char __user *optval,
 				      unsigned int optlen)
 {
-	struct net *net = sock_net(sk);
+	struct sctp_endpoint *ep = sctp_sk(sk)->ep;
 	struct sctp_authkeyid val;
 	struct sctp_association *asoc;
 
-	if (!net->sctp.auth_enable)
+	if (!ep->auth_enable)
 		return -EACCES;
 
 	if (optlen != sizeof(struct sctp_authkeyid))
@@ -3450,8 +3450,7 @@ static int sctp_setsockopt_active_key(struct sock *sk,
 	if (!asoc && val.scact_assoc_id && sctp_style(sk, UDP))
 		return -EINVAL;
 
-	return sctp_auth_set_active_key(sctp_sk(sk)->ep, asoc,
-					val.scact_keynumber);
+	return sctp_auth_set_active_key(ep, asoc, val.scact_keynumber);
 }
 
 /*
@@ -3463,11 +3462,11 @@ static int sctp_setsockopt_del_key(struct sock *sk,
 				   char __user *optval,
 				   unsigned int optlen)
 {
-	struct net *net = sock_net(sk);
+	struct sctp_endpoint *ep = sctp_sk(sk)->ep;
 	struct sctp_authkeyid val;
 	struct sctp_association *asoc;
 
-	if (!net->sctp.auth_enable)
+	if (!ep->auth_enable)
 		return -EACCES;
 
 	if (optlen != sizeof(struct sctp_authkeyid))
@@ -3479,8 +3478,7 @@ static int sctp_setsockopt_del_key(struct sock *sk,
 	if (!asoc && val.scact_assoc_id && sctp_style(sk, UDP))
 		return -EINVAL;
 
-	return sctp_auth_del_key_id(sctp_sk(sk)->ep, asoc,
-				    val.scact_keynumber);
+	return sctp_auth_del_key_id(ep, asoc, val.scact_keynumber);
 
 }
 
@@ -5387,16 +5385,16 @@ static int sctp_getsockopt_maxburst(struct sock *sk, int len,
 static int sctp_getsockopt_hmac_ident(struct sock *sk, int len,
 				    char __user *optval, int __user *optlen)
 {
-	struct net *net = sock_net(sk);
+	struct sctp_endpoint *ep = sctp_sk(sk)->ep;
 	struct sctp_hmacalgo  __user *p = (void __user *)optval;
 	struct sctp_hmac_algo_param *hmacs;
 	__u16 data_len = 0;
 	u32 num_idents;
 
-	if (!net->sctp.auth_enable)
+	if (!ep->auth_enable)
 		return -EACCES;
 
-	hmacs = sctp_sk(sk)->ep->auth_hmacs_list;
+	hmacs = ep->auth_hmacs_list;
 	data_len = ntohs(hmacs->param_hdr.length) - sizeof(sctp_paramhdr_t);
 
 	if (len < sizeof(struct sctp_hmacalgo) + data_len)
@@ -5417,11 +5415,11 @@ static int sctp_getsockopt_hmac_ident(struct sock *sk, int len,
 static int sctp_getsockopt_active_key(struct sock *sk, int len,
 				    char __user *optval, int __user *optlen)
 {
-	struct net *net = sock_net(sk);
+	struct sctp_endpoint *ep = sctp_sk(sk)->ep;
 	struct sctp_authkeyid val;
 	struct sctp_association *asoc;
 
-	if (!net->sctp.auth_enable)
+	if (!ep->auth_enable)
 		return -EACCES;
 
 	if (len < sizeof(struct sctp_authkeyid))
@@ -5436,7 +5434,7 @@ static int sctp_getsockopt_active_key(struct sock *sk, int len,
 	if (asoc)
 		val.scact_keynumber = asoc->active_key_id;
 	else
-		val.scact_keynumber = sctp_sk(sk)->ep->active_key_id;
+		val.scact_keynumber = ep->active_key_id;
 
 	len = sizeof(struct sctp_authkeyid);
 	if (put_user(len, optlen))
@@ -5450,7 +5448,7 @@ static int sctp_getsockopt_active_key(struct sock *sk, int len,
 static int sctp_getsockopt_peer_auth_chunks(struct sock *sk, int len,
 				    char __user *optval, int __user *optlen)
 {
-	struct net *net = sock_net(sk);
+	struct sctp_endpoint *ep = sctp_sk(sk)->ep;
 	struct sctp_authchunks __user *p = (void __user *)optval;
 	struct sctp_authchunks val;
 	struct sctp_association *asoc;
@@ -5458,7 +5456,7 @@ static int sctp_getsockopt_peer_auth_chunks(struct sock *sk, int len,
 	u32    num_chunks = 0;
 	char __user *to;
 
-	if (!net->sctp.auth_enable)
+	if (!ep->auth_enable)
 		return -EACCES;
 
 	if (len < sizeof(struct sctp_authchunks))
@@ -5495,7 +5493,7 @@ num:
 static int sctp_getsockopt_local_auth_chunks(struct sock *sk, int len,
 				    char __user *optval, int __user *optlen)
 {
-	struct net *net = sock_net(sk);
+	struct sctp_endpoint *ep = sctp_sk(sk)->ep;
 	struct sctp_authchunks __user *p = (void __user *)optval;
 	struct sctp_authchunks val;
 	struct sctp_association *asoc;
@@ -5503,7 +5501,7 @@ static int sctp_getsockopt_local_auth_chunks(struct sock *sk, int len,
 	u32    num_chunks = 0;
 	char __user *to;
 
-	if (!net->sctp.auth_enable)
+	if (!ep->auth_enable)
 		return -EACCES;
 
 	if (len < sizeof(struct sctp_authchunks))
@@ -5520,7 +5518,7 @@ static int sctp_getsockopt_local_auth_chunks(struct sock *sk, int len,
 	if (asoc)
 		ch = (struct sctp_chunks_param *)asoc->c.auth_chunks;
 	else
-		ch = sctp_sk(sk)->ep->auth_chunk_list;
+		ch = ep->auth_chunk_list;
 
 	if (!ch)
 		goto num;
diff --git a/net/sctp/sysctl.c b/net/sctp/sysctl.c
index 35c8923..c82fdc1 100644
--- a/net/sctp/sysctl.c
+++ b/net/sctp/sysctl.c
@@ -64,6 +64,9 @@ static int proc_sctp_do_rto_min(struct ctl_table *ctl, int write,
 static int proc_sctp_do_rto_max(struct ctl_table *ctl, int write,
 				void __user *buffer, size_t *lenp,
 				loff_t *ppos);
+static int proc_sctp_do_auth(struct ctl_table *ctl, int write,
+			     void __user *buffer, size_t *lenp,
+			     loff_t *ppos);
 
 static struct ctl_table sctp_table[] = {
 	{
@@ -266,7 +269,7 @@ static struct ctl_table sctp_net_table[] = {
 		.data		= &init_net.sctp.auth_enable,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= proc_dointvec,
+		.proc_handler	= proc_sctp_do_auth,
 	},
 	{
 		.procname	= "addr_scope_policy",
@@ -400,6 +403,37 @@ static int proc_sctp_do_rto_max(struct ctl_table *ctl, int write,
 	return ret;
 }
 
+static int proc_sctp_do_auth(struct ctl_table *ctl, int write,
+			     void __user *buffer, size_t *lenp,
+			     loff_t *ppos)
+{
+	struct net *net = current->nsproxy->net_ns;
+	struct ctl_table tbl;
+	int new_value, ret;
+
+	memset(&tbl, 0, sizeof(struct ctl_table));
+	tbl.maxlen = sizeof(unsigned int);
+
+	if (write)
+		tbl.data = &new_value;
+	else
+		tbl.data = &net->sctp.auth_enable;
+
+	ret = proc_dointvec(&tbl, write, buffer, lenp, ppos);
+
+	if (write) {
+		struct sock *sk = net->sctp.ctl_sock;
+
+		net->sctp.auth_enable = new_value;
+		/* Update the value in the control socket */
+		lock_sock(sk);
+		sctp_sk(sk)->ep->auth_enable = new_value;
+		release_sock(sk);
+	}
+
+	return ret;
+}
+
 int sctp_sysctl_net_register(struct net *net)
 {
 	struct ctl_table *table = sctp_net_table;
-- 
1.7.11.7
