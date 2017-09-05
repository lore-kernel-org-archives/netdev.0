Return-Path: <netdev-owner@vger.kernel.org>
Received: from foss.arm.com ([217.140.101.70]:38928 "EHLO foss.arm.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750891AbdIEMjf (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 5 Sep 2017 08:39:35 -0400
From: Gilad Ben-Yossef <gilad@benyossef.com>
To: Herbert Xu <herbert@gondor.apana.org.au>,
        "David S. Miller" <davem@davemloft.net>,
        Jonathan Corbet <corbet@lwn.net>,
        David Howells <dhowells@redhat.com>,
        Tom Lendacky <thomas.lendacky@amd.com>,
        Gary Hook <gary.hook@amd.com>,
        Boris Brezillon <boris.brezillon@free-electrons.com>,
        Arnaud Ebalard <arno@natisbad.org>,
        Matthias Brugger <matthias.bgg@gmail.com>,
        Alasdair Kergon <agk@redhat.com>,
        Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com,
        Shaohua Li <shli@kernel.org>, Steve French <sfrench@samba.org>,
        "Theodore Y. Ts'o" <tytso@mit.edu>,
        Jaegeuk Kim <jaegeuk@kernel.org>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Mimi Zohar <zohar@linux.vnet.ibm.com>,
        Dmitry Kasatkin <dmitry.kasatkin@gmail.com>,
        James Morris <james.l.morris@oracle.com>,
        "Serge E. Hallyn" <serge@hallyn.com>, linux-crypto@vger.kernel.org,
        linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
        keyrings@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        linux-mediatek@lists.infradead.org, linux-raid@vger.kernel.org,
        linux-cifs@vger.kernel.org, samba-technical@lists.samba.org,
        linux-fscrypt@vger.kernel.org, netdev@vger.kernel.org,
        linux-ima-devel@lists.sourceforge.net,
        linux-ima-user@lists.sourceforge.net,
        linux-security-module@vger.kernel.org
Cc: Ofir Drang <ofir.drang@arm.com>
Subject: [PATCH v8 01/20] crypto: change transient busy return code to -EAGAIN
Date: Tue,  5 Sep 2017 15:38:40 +0300
Message-Id: <1504615144-29770-2-git-send-email-gilad@benyossef.com>
In-Reply-To: <1504615144-29770-1-git-send-email-gilad@benyossef.com>
References: <1504615144-29770-1-git-send-email-gilad@benyossef.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The crypto API was using the -EBUSY return value to indicate
both a hard failure to submit a crypto operation into a
transformation provider when the latter was busy and the backlog
mechanism was not enabled as well as a notification that the
operation was queued into the backlog when the backlog mechanism
was enabled.

Having the same return code indicate two very different conditions
depending on a flag is both error prone and requires extra runtime
check like the following to discern between the cases:

	if (err == -EINPROGRESS ||
	    (err == -EBUSY && (ahash_request_flags(req) &
			       CRYPTO_TFM_REQ_MAY_BACKLOG)))

This patch changes the return code used to indicate a crypto op
failed due to the transformation provider being transiently busy
to -EAGAIN.

Signed-off-by: Gilad Ben-Yossef <gilad@benyossef.com>
---
 crypto/algapi.c     |  6 ++++--
 crypto/algif_hash.c | 20 +++++++++++++++++---
 crypto/cryptd.c     |  4 +---
 3 files changed, 22 insertions(+), 8 deletions(-)

diff --git a/crypto/algapi.c b/crypto/algapi.c
index aa699ff..916bee3 100644
--- a/crypto/algapi.c
+++ b/crypto/algapi.c
@@ -897,9 +897,11 @@ int crypto_enqueue_request(struct crypto_queue *queue,
 	int err = -EINPROGRESS;
 
 	if (unlikely(queue->qlen >= queue->max_qlen)) {
-		err = -EBUSY;
-		if (!(request->flags & CRYPTO_TFM_REQ_MAY_BACKLOG))
+		if (!(request->flags & CRYPTO_TFM_REQ_MAY_BACKLOG)) {
+			err = -EAGAIN;
 			goto out;
+		}
+		err = -EBUSY;
 		if (queue->backlog == &queue->list)
 			queue->backlog = &request->list;
 	}
diff --git a/crypto/algif_hash.c b/crypto/algif_hash.c
index 5e92bd2..3b3c154 100644
--- a/crypto/algif_hash.c
+++ b/crypto/algif_hash.c
@@ -39,6 +39,20 @@ struct algif_hash_tfm {
 	bool has_key;
 };
 
+/* Previous versions of crypto_* ops used to return -EBUSY
+ * rather than -EAGAIN to indicate being tied up. The in
+ * kernel API changed but we don't want to break the user
+ * space API. As only the hash user interface exposed this
+ * error ever to the user, do the translation here.
+ */
+static inline int crypto_user_err(int err)
+{
+	if (err == -EAGAIN)
+		return -EBUSY;
+
+	return err;
+}
+
 static int hash_alloc_result(struct sock *sk, struct hash_ctx *ctx)
 {
 	unsigned ds;
@@ -136,7 +150,7 @@ static int hash_sendmsg(struct socket *sock, struct msghdr *msg,
 unlock:
 	release_sock(sk);
 
-	return err ?: copied;
+	return err ? crypto_user_err(err) : copied;
 }
 
 static ssize_t hash_sendpage(struct socket *sock, struct page *page,
@@ -188,7 +202,7 @@ static ssize_t hash_sendpage(struct socket *sock, struct page *page,
 unlock:
 	release_sock(sk);
 
-	return err ?: size;
+	return err ? crypto_user_err(err) : size;
 }
 
 static int hash_recvmsg(struct socket *sock, struct msghdr *msg, size_t len,
@@ -236,7 +250,7 @@ static int hash_recvmsg(struct socket *sock, struct msghdr *msg, size_t len,
 	hash_free_result(sk, ctx);
 	release_sock(sk);
 
-	return err ?: len;
+	return err ? crypto_user_err(err) : len;
 }
 
 static int hash_accept(struct socket *sock, struct socket *newsock, int flags,
diff --git a/crypto/cryptd.c b/crypto/cryptd.c
index 0508c48..d1dbdce 100644
--- a/crypto/cryptd.c
+++ b/crypto/cryptd.c
@@ -137,16 +137,14 @@ static int cryptd_enqueue_request(struct cryptd_queue *queue,
 	int cpu, err;
 	struct cryptd_cpu_queue *cpu_queue;
 	atomic_t *refcnt;
-	bool may_backlog;
 
 	cpu = get_cpu();
 	cpu_queue = this_cpu_ptr(queue->cpu_queue);
 	err = crypto_enqueue_request(&cpu_queue->queue, request);
 
 	refcnt = crypto_tfm_ctx(request->tfm);
-	may_backlog = request->flags & CRYPTO_TFM_REQ_MAY_BACKLOG;
 
-	if (err == -EBUSY && !may_backlog)
+	if (err == -EAGAIN)
 		goto out_put_cpu;
 
 	queue_work_on(cpu, kcrypto_wq, &cpu_queue->work);
-- 
2.1.4
