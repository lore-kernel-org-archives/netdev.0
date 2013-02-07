From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net 1/2] net: sctp: sctp_auth_make_key_vector: fix undefined ref-count behaviour
Date: Thu,  7 Feb 2013 11:55:36 +0100
Message-ID: <5eff11271160e84c7fc2d97b81161b1ae7be4a6e.1360231701.git.dborkman@redhat.com>
References: <cover.1360231701.git.dborkman@redhat.com>
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org
To: vyasevich@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59041 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757949Ab3BGKzl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Feb 2013 05:55:41 -0500
In-Reply-To: <cover.1360231701.git.dborkman@redhat.com>
In-Reply-To: <cover.1360231701.git.dborkman@redhat.com>
References: <cover.1360231701.git.dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In sctp_auth_make_key_vector(), a sctp_auth_bytes structure is being
allocated, but without setting its object reference count, thus it's
initialized with a random value from the memory, which can lead to
i) premature free's of this object when being put (with possible
subsequent kernel panics), or ii) memory leaks when refcount has a
high value.

Fix this by using the appropriate sctp_auth_create_key() allocator,
which performs sanity checks, sets length and the refcount, as similar
done in sctp_auth_asoc_set_secret() and others. This bug seems to be
present since 2007 (1f485649f529: Implement SCTP-AUTH internals).

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 net/sctp/auth.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/net/sctp/auth.c b/net/sctp/auth.c
index 159b9bc..55f1b06 100644
--- a/net/sctp/auth.c
+++ b/net/sctp/auth.c
@@ -205,12 +205,10 @@ static struct sctp_auth_bytes *sctp_auth_make_key_vector(
         if (chunks)
 		len += ntohs(chunks->param_hdr.length);
 
-	new = kmalloc(sizeof(struct sctp_auth_bytes) + len, gfp);
+	new = sctp_auth_create_key(len, gfp);
 	if (!new)
 		return NULL;
 
-	new->len = len;
-
 	memcpy(new->data, random, ntohs(random->param_hdr.length));
 	offset += ntohs(random->param_hdr.length);
 
-- 
1.7.11.7
