From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH 4/4] [SCTP]: Update AUTH structures to match declarations in draft-16.
Date: Thu, 28 Feb 2008 16:52:41 -0500
Message-ID: <1204235561-19993-5-git-send-email-vladislav.yasevich@hp.com>
References: <1204235561-19993-1-git-send-email-vladislav.yasevich@hp.com>
Cc: davem@davemloft.net, lksctp-developers@lists.sourceforge.net,
	Vlad Yasevich <vladislav.yasevich@hp.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0015.houston.hp.com ([15.201.24.18]:25440 "EHLO
	g4t0015.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755206AbYB1VwU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Feb 2008 16:52:20 -0500
In-Reply-To: <1204235561-19993-1-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The new SCTP socket api (draft 16) updates the AUTH API structures.
We never exported these since we knew they would change.
Update the rest to match the draft.

Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 include/net/sctp/user.h |   10 ++++++----
 net/sctp/auth.c         |    4 ++--
 net/sctp/socket.c       |    6 +++++-
 3 files changed, 13 insertions(+), 7 deletions(-)

diff --git a/include/net/sctp/user.h b/include/net/sctp/user.h
index 9462d6a..9619b9d 100644
--- a/include/net/sctp/user.h
+++ b/include/net/sctp/user.h
@@ -411,6 +411,7 @@ struct sctp_event_subscribe {
 	__u8 sctp_shutdown_event;
 	__u8 sctp_partial_delivery_event;
 	__u8 sctp_adaptation_layer_event;
+	__u8 sctp_authentication_event;
 };
 
 /*
@@ -587,7 +588,7 @@ struct sctp_authchunk {
  * endpoint requires the peer to use.
 */
 struct sctp_hmacalgo {
-	__u16		shmac_num_idents;
+	__u32		shmac_num_idents;
 	__u16		shmac_idents[];
 };
 
@@ -600,7 +601,7 @@ struct sctp_hmacalgo {
 struct sctp_authkey {
 	sctp_assoc_t	sca_assoc_id;
 	__u16		sca_keynumber;
-	__u16		sca_keylen;
+	__u16		sca_keylength;
 	__u8		sca_key[];
 };
 
@@ -693,8 +694,9 @@ struct sctp_status {
  * the peer requires to be received authenticated only.
  */
 struct sctp_authchunks {
-	sctp_assoc_t            gauth_assoc_id;
-	uint8_t                 gauth_chunks[];
+	sctp_assoc_t	gauth_assoc_id;
+	__u32		gauth_number_of_chunks;
+	uint8_t		gauth_chunks[];
 };
 
 /*
diff --git a/net/sctp/auth.c b/net/sctp/auth.c
index 8bb79f2..675a5c3 100644
--- a/net/sctp/auth.c
+++ b/net/sctp/auth.c
@@ -838,11 +838,11 @@ int sctp_auth_set_key(struct sctp_endpoint *ep,
 	}
 
 	/* Create a new key data based on the info passed in */
-	key = sctp_auth_create_key(auth_key->sca_keylen, GFP_KERNEL);
+	key = sctp_auth_create_key(auth_key->sca_keylength, GFP_KERNEL);
 	if (!key)
 		goto nomem;
 
-	memcpy(key->data, &auth_key->sca_key[0], auth_key->sca_keylen);
+	memcpy(key->data, &auth_key->sca_key[0], auth_key->sca_keylength);
 
 	/* If we are replacing, remove the old keys data from the
 	 * key id.  If we are adding new key id, add it to the
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 848df21..9398926 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -1964,7 +1964,7 @@ static int sctp_setsockopt_disable_fragments(struct sock *sk,
 static int sctp_setsockopt_events(struct sock *sk, char __user *optval,
 					int optlen)
 {
-	if (optlen != sizeof(struct sctp_event_subscribe))
+	if (optlen > sizeof(struct sctp_event_subscribe))
 		return -EINVAL;
 	if (copy_from_user(&sctp_sk(sk)->subscribe, optval, optlen))
 		return -EFAULT;
@@ -5094,6 +5094,8 @@ static int sctp_getsockopt_peer_auth_chunks(struct sock *sk, int len,
 	len = num_chunks;
 	if (put_user(len, optlen))
 		return -EFAULT;
+	if (put_user(num_chunks, &p->gauth_number_of_chunks))
+		return -EFAULT;
 	if (copy_to_user(to, ch->chunks, len))
 		return -EFAULT;
 
@@ -5133,6 +5135,8 @@ static int sctp_getsockopt_local_auth_chunks(struct sock *sk, int len,
 	len = num_chunks;
 	if (put_user(len, optlen))
 		return -EFAULT;
+	if (put_user(num_chunks, &p->gauth_number_of_chunks))
+		return -EFAULT;
 	if (copy_to_user(to, ch->chunks, len))
 		return -EFAULT;
 
-- 
1.5.3.5

