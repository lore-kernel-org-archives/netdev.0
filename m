From: Shawn Landden <shawn@churchofgit.com>
Subject: [PATCH] update consumers of MSG_MORE to recognize MSG_SENDPAGE_NOTLAST
Date: Sun, 24 Nov 2013 18:08:59 -0800
Message-ID: <1385345339-2184-1-git-send-email-shawn@churchofgit.com>
References: <1385342706.10637.125.camel@edumazet-glaptop2.roam.corp.google.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-fsdevel@vger.kernel.org, viro@zeniv.linux.org.uk,
	linux-crypto@vger.kernel.org, netdev@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Tom Herbert <therbert@google.com>,
	"David S. Miller" <davem@davemloft.net>, stable@vger.kernel.org,
	Shawn Landden <shawn@churchofgit.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <1385342706.10637.125.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit 35f9c09fe (tcp: tcp_sendpages() should call tcp_push() once)
added an internal flag MSG_SENDPAGE_NOTLAST, similar to
MSG_MORE.

algif_hash and algif_skcipher used MSG_MORE from tcp_sendpages()
and need to see the new flag as identical to MSG_MORE.

This fixes sendfile() on AF_ALG.

Cc: Tom Herbert <therbert@google.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: David S. Miller <davem@davemloft.net>
Cc: <stable@vger.kernel.org> # 3.4.x + 3.2.x
Reported-and-tested-by: Shawn Landden <shawnlandden@gmail.com>
Original-patch: Richard Weinberger <richard@nod.at>
Signed-off-by: Shawn Landden <shawn@churchofgit.com>
---
 crypto/algif_hash.c     | 3 +++
 crypto/algif_skcipher.c | 3 +++
 2 files changed, 6 insertions(+)

diff --git a/crypto/algif_hash.c b/crypto/algif_hash.c
index ef5356c..8502462 100644
--- a/crypto/algif_hash.c
+++ b/crypto/algif_hash.c
@@ -114,6 +114,9 @@ static ssize_t hash_sendpage(struct socket *sock, struct page *page,
 	struct hash_ctx *ctx = ask->private;
 	int err;
 
+	if (flags & MSG_SENDPAGE_NOTLAST)
+		flags |= MSG_MORE;
+
 	lock_sock(sk);
 	sg_init_table(ctx->sgl.sg, 1);
 	sg_set_page(ctx->sgl.sg, page, size, offset);
diff --git a/crypto/algif_skcipher.c b/crypto/algif_skcipher.c
index 6a6dfc0..a19c027 100644
--- a/crypto/algif_skcipher.c
+++ b/crypto/algif_skcipher.c
@@ -378,6 +378,9 @@ static ssize_t skcipher_sendpage(struct socket *sock, struct page *page,
 	struct skcipher_sg_list *sgl;
 	int err = -EINVAL;
 
+	if (flags & MSG_SENDPAGE_NOTLAST)
+		flags |= MSG_MORE;
+
 	lock_sock(sk);
 	if (!ctx->more && ctx->used)
 		goto unlock;
-- 
1.8.4.4
