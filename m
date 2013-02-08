From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next] net: sctp: sctp_auth_make_key_vector: use sctp_auth_create_key
Date: Fri,  8 Feb 2013 10:22:58 +0100
Message-ID: <783e1129996c3f09c7da121f5dd91c8ac7ba5baa.1360314390.git.dborkman@redhat.com>
References: <cover.1360314390.git.dborkman@redhat.com>
Cc: linux-sctp@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:9735 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1946153Ab3BHJXB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Feb 2013 04:23:01 -0500
In-Reply-To: <cover.1360314390.git.dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In sctp_auth_make_key_vector, we allocate a temporary sctp_auth_bytes
structure with kmalloc instead of the sctp_auth_create_key allocator.
Change this to sctp_auth_create_key as it is the case everywhere else,
so that we also can properly free it via sctp_auth_key_put. This makes
it easier for future code changes in the structure and allocator itself,
since a single API is consistently used for this purpose. Also, by
using sctp_auth_create_key we're doing sanity checks over the arguments.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 net/sctp/auth.c | 8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/net/sctp/auth.c b/net/sctp/auth.c
index 94a12de..5ec7509 100644
--- a/net/sctp/auth.c
+++ b/net/sctp/auth.c
@@ -209,12 +209,10 @@ static struct sctp_auth_bytes *sctp_auth_make_key_vector(
 
 	len = random_len + hmacs_len + chunks_len;
 
-	new = kmalloc(sizeof(struct sctp_auth_bytes) + len, gfp);
+	new = sctp_auth_create_key(len, gfp);
 	if (!new)
 		return NULL;
 
-	new->len = len;
-
 	memcpy(new->data, random, random_len);
 	offset += random_len;
 
@@ -353,8 +351,8 @@ static struct sctp_auth_bytes *sctp_auth_asoc_create_secret(
 	secret = sctp_auth_asoc_set_secret(ep_key, first_vector, last_vector,
 					    gfp);
 out:
-	kfree(local_key_vector);
-	kfree(peer_key_vector);
+	sctp_auth_key_put(local_key_vector);
+	sctp_auth_key_put(peer_key_vector);
 
 	return secret;
 }
-- 
1.7.11.7
