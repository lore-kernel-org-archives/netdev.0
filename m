From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next 14/14] sctp: remove the typedef sctp_auth_chunk_t
Date: Thu,  3 Aug 2017 15:42:22 +0800
Message-ID: <374643eb449c9ec7392926d06fa3aade318b7cba.1501745729.git.lucien.xin@gmail.com>
References: <cover.1501745729.git.lucien.xin@gmail.com>
 <8149f8b0a190eb047abfe48a7fa79ba74e4e4544.1501745729.git.lucien.xin@gmail.com>
 <457c0c30e478f1ead75d3606e17519ca23daddfc.1501745729.git.lucien.xin@gmail.com>
 <ef0bf503017711311e9fc167c4b5bfd9de885d04.1501745729.git.lucien.xin@gmail.com>
 <61746e2a2efa75634ab632cf264ad902aa3f9685.1501745729.git.lucien.xin@gmail.com>
 <91fc6fd265b6623a2244f17a9e5581962a2183d0.1501745729.git.lucien.xin@gmail.com>
 <bc49ca93eba1ba96461674afe5fadc441f8d288a.1501745729.git.lucien.xin@gmail.com>
 <a5a3e5ce57d84377d2426a010f92d2afb5ca346d.1501745729.git.lucien.xin@gmail.com>
 <cd4fd6410dd3ee98ea8462b2b9eb8af3b39d536a.1501745729.git.lucien.xin@gmail.com>
 <4117cc15ad262c164f9725e4dee1f9d0b13dd992.1501745729.git.lucien.xin@gmail.com>
 <9ee006c5a40a15372502d1e2458b8f9f568ceb2e.1501745729.git.lucien.xin@gmail.com>
 <5374e7c1ae3374fc375f56b48893aa5c3c0208bf.1501745729.git.lucien.xin@gmail.com>
 <9e2aee0b88d26c3a5c041864d46fb0ebde965e11.1501745729.git.lucien.xin@gmail.com>
 <99eaf082a43fa5cd141ad9e25b9a7de3f33d69b7.1501745729.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:38142 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751245AbdHCHoo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2017 03:44:44 -0400
In-Reply-To: <99eaf082a43fa5cd141ad9e25b9a7de3f33d69b7.1501745729.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1501745729.git.lucien.xin@gmail.com>
References: <cover.1501745729.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to remove the typedef sctp_auth_chunk_t, and
replace with struct sctp_auth_chunk in the places where it's
using this typedef.

It is also to use sizeof(variable) instead of sizeof(type).

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/linux/sctp.h    | 4 ++--
 net/sctp/chunk.c        | 2 +-
 net/sctp/sm_statefuns.c | 9 +++++----
 3 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/include/linux/sctp.h b/include/linux/sctp.h
index b7603f5..82b171e 100644
--- a/include/linux/sctp.h
+++ b/include/linux/sctp.h
@@ -699,10 +699,10 @@ struct sctp_authhdr {
 	__u8   hmac[0];
 };
 
-typedef struct sctp_auth_chunk {
+struct sctp_auth_chunk {
 	struct sctp_chunkhdr chunk_hdr;
 	struct sctp_authhdr auth_hdr;
-} sctp_auth_chunk_t;
+};
 
 struct sctp_infox {
 	struct sctp_info *sctpinfo;
diff --git a/net/sctp/chunk.c b/net/sctp/chunk.c
index 681b181..3afac27 100644
--- a/net/sctp/chunk.c
+++ b/net/sctp/chunk.c
@@ -201,7 +201,7 @@ struct sctp_datamsg *sctp_datamsg_from_user(struct sctp_association *asoc,
 		struct sctp_hmac *hmac_desc = sctp_auth_asoc_get_hmac(asoc);
 
 		if (hmac_desc)
-			max_data -= SCTP_PAD4(sizeof(sctp_auth_chunk_t) +
+			max_data -= SCTP_PAD4(sizeof(struct sctp_auth_chunk) +
 					      hmac_desc->hmac_len);
 	}
 
diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index 9c235bb..8af90a5 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -4093,7 +4093,7 @@ static sctp_ierror_t sctp_sf_authenticate(struct net *net,
 	/* Pull in the auth header, so we can do some more verification */
 	auth_hdr = (struct sctp_authhdr *)chunk->skb->data;
 	chunk->subh.auth_hdr = auth_hdr;
-	skb_pull(chunk->skb, sizeof(struct sctp_authhdr));
+	skb_pull(chunk->skb, sizeof(*auth_hdr));
 
 	/* Make sure that we support the HMAC algorithm from the auth
 	 * chunk.
@@ -4112,7 +4112,8 @@ static sctp_ierror_t sctp_sf_authenticate(struct net *net,
 	/* Make sure that the length of the signature matches what
 	 * we expect.
 	 */
-	sig_len = ntohs(chunk->chunk_hdr->length) - sizeof(sctp_auth_chunk_t);
+	sig_len = ntohs(chunk->chunk_hdr->length) -
+		  sizeof(struct sctp_auth_chunk);
 	hmac = sctp_auth_get_hmac(ntohs(auth_hdr->hmac_id));
 	if (sig_len != hmac->hmac_len)
 		return SCTP_IERROR_PROTO_VIOLATION;
@@ -4134,8 +4135,8 @@ static sctp_ierror_t sctp_sf_authenticate(struct net *net,
 	memset(digest, 0, sig_len);
 
 	sctp_auth_calculate_hmac(asoc, chunk->skb,
-				(struct sctp_auth_chunk *)chunk->chunk_hdr,
-				GFP_ATOMIC);
+				 (struct sctp_auth_chunk *)chunk->chunk_hdr,
+				 GFP_ATOMIC);
 
 	/* Discard the packet if the digests do not match */
 	if (memcmp(save_digest, digest, sig_len)) {
-- 
2.1.0
