From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH] sctp: add verification checks to SCTP_AUTH_KEY option
Date: Mon, 25 Aug 2008 16:25:32 -0400
Message-ID: <12196959323990-git-send-email-vladislav.yasevich@hp.com>
References: <20080825164440.GA504@kernel.sg>
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	security@kernel.org, eteo@redhat.com,
	Vlad Yasevich <vladislav.yasevich@hp.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0007.atlanta.hp.com ([15.192.0.44]:8825 "EHLO
	g5t0007.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752028AbYHYUZe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2008 16:25:34 -0400
In-Reply-To: <20080825164440.GA504@kernel.sg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The structure used for SCTP_AUTH_KEY option contains a
length that needs to be verfied to prevent buffer overflow
conditions.  Spoted by Eugene Teo <eteo@redhat.com>.

Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 net/sctp/auth.c   |    4 ++++
 net/sctp/socket.c |    5 +++++
 2 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/net/sctp/auth.c b/net/sctp/auth.c
index 675a5c3..1fcb4cf 100644
--- a/net/sctp/auth.c
+++ b/net/sctp/auth.c
@@ -80,6 +80,10 @@ static struct sctp_auth_bytes *sctp_auth_create_key(__u32 key_len, gfp_t gfp)
 {
 	struct sctp_auth_bytes *key;
 
+	/* Verify that we are not going to overflow INT_MAX */
+	if ((INT_MAX - key_len) < sizeof(struct sctp_auth_bytes))
+		return NULL;
+
 	/* Allocate the shared key */
 	key = kmalloc(sizeof(struct sctp_auth_bytes) + key_len, gfp);
 	if (!key)
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index bb5c9ef..afa952e 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -3144,6 +3144,11 @@ static int sctp_setsockopt_auth_key(struct sock *sk,
 		goto out;
 	}
 
+	if (authkey->sca_keylength > optlen) {
+		ret = -EINVAL;
+		goto out;
+	}
+
 	asoc = sctp_id2assoc(sk, authkey->sca_assoc_id);
 	if (!asoc && authkey->sca_assoc_id && sctp_style(sk, UDP)) {
 		ret = -EINVAL;
-- 
1.5.2.5

