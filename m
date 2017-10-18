From: Gilad Ben-Yossef <gilad@benyossef.com>
Subject: [PATCH v10 06/20] crypto: introduce crypto wait for async op
Date: Wed, 18 Oct 2017 08:00:38 +0100
Message-ID: <1508310057-25369-7-git-send-email-gilad@benyossef.com>
References: <1508310057-25369-1-git-send-email-gilad@benyossef.com>
Cc: Ofir Drang <ofir.drang@arm.com>,
        Eric Biggers <ebiggers3@gmail.com>,
        Jonathan Cameron <Jonathan.Cameron@huawei.com>,
        linux-crypto@vger.kernel.org, linux-doc@vger.kernel.org,
        linux-kernel@vger.kernel.org, keyrings@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org,
        linux-mediatek@lists.infradead.org, linux-cifs@vger.kernel.org,
        samba-technical@lists.samba.org, linux-fscrypt@vger.kernel.org,
        netdev@vger.kernel.org, linux-ima-devel@lists.sourceforge.net,
        linux-ima-user@lists.sourceforge.net,
        linux-security-module@vger.kernel.org
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
        Steve French <sfrench@samba.org>,
        "Theodore Y. Ts'o" <tytso@mit.edu>,
        Jaegeuk Kim <jaegeuk@kernel.org>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Mimi Zohar <zohar@linux.vnet.ibm.com>,
        Dmitry Kasatkin <dmitry.ka
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1508310057-25369-1-git-send-email-gilad@benyossef.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Invoking a possibly async. crypto op and waiting for completion
while correctly handling backlog processing is a common task
in the crypto API implementation and outside users of it.

This patch adds a generic implementation for doing so in
preparation for using it across the board instead of hand
rolled versions.

Signed-off-by: Gilad Ben-Yossef <gilad@benyossef.com>
CC: Eric Biggers <ebiggers3@gmail.com>
CC: Jonathan Cameron <Jonathan.Cameron@huawei.com>
---
 crypto/api.c           | 13 +++++++++++++
 include/linux/crypto.h | 40 ++++++++++++++++++++++++++++++++++++++++
 2 files changed, 53 insertions(+)

diff --git a/crypto/api.c b/crypto/api.c
index 941cd4c..2a2479d 100644
--- a/crypto/api.c
+++ b/crypto/api.c
@@ -24,6 +24,7 @@
 #include <linux/sched/signal.h>
 #include <linux/slab.h>
 #include <linux/string.h>
+#include <linux/completion.h>
 #include "internal.h"
 
 LIST_HEAD(crypto_alg_list);
@@ -595,5 +596,17 @@ int crypto_has_alg(const char *name, u32 type, u32 mask)
 }
 EXPORT_SYMBOL_GPL(crypto_has_alg);
 
+void crypto_req_done(struct crypto_async_request *req, int err)
+{
+	struct crypto_wait *wait = req->data;
+
+	if (err == -EINPROGRESS)
+		return;
+
+	wait->err = err;
+	complete(&wait->completion);
+}
+EXPORT_SYMBOL_GPL(crypto_req_done);
+
 MODULE_DESCRIPTION("Cryptographic core API");
 MODULE_LICENSE("GPL");
diff --git a/include/linux/crypto.h b/include/linux/crypto.h
index 84da997..78508ca 100644
--- a/include/linux/crypto.h
+++ b/include/linux/crypto.h
@@ -24,6 +24,7 @@
 #include <linux/slab.h>
 #include <linux/string.h>
 #include <linux/uaccess.h>
+#include <linux/completion.h>
 
 /*
  * Autoloaded crypto modules should only use a prefixed name to avoid allowing
@@ -468,6 +469,45 @@ struct crypto_alg {
 } CRYPTO_MINALIGN_ATTR;
 
 /*
+ * A helper struct for waiting for completion of async crypto ops
+ */
+struct crypto_wait {
+	struct completion completion;
+	int err;
+};
+
+/*
+ * Macro for declaring a crypto op async wait object on stack
+ */
+#define DECLARE_CRYPTO_WAIT(_wait) \
+	struct crypto_wait _wait = { \
+		COMPLETION_INITIALIZER_ONSTACK((_wait).completion), 0 }
+
+/*
+ * Async ops completion helper functioons
+ */
+void crypto_req_done(struct crypto_async_request *req, int err);
+
+static inline int crypto_wait_req(int err, struct crypto_wait *wait)
+{
+	switch (err) {
+	case -EINPROGRESS:
+	case -EBUSY:
+		wait_for_completion(&wait->completion);
+		reinit_completion(&wait->completion);
+		err = wait->err;
+		break;
+	};
+
+	return err;
+}
+
+static inline void crypto_init_wait(struct crypto_wait *wait)
+{
+	init_completion(&wait->completion);
+}
+
+/*
  * Algorithm registration interface.
  */
 int crypto_register_alg(struct crypto_alg *alg);
-- 
2.7.4
