Return-Path: <netdev-owner@vger.kernel.org>
Received: from foss.arm.com ([217.140.101.70]:38974 "EHLO foss.arm.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751538AbdIEMju (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 5 Sep 2017 08:39:50 -0400
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
Subject: [PATCH v8 02/20] crypto: ccp: use -EAGAIN for transient busy indication
Date: Tue,  5 Sep 2017 15:38:41 +0300
Message-Id: <1504615144-29770-3-git-send-email-gilad@benyossef.com>
In-Reply-To: <1504615144-29770-1-git-send-email-gilad@benyossef.com>
References: <1504615144-29770-1-git-send-email-gilad@benyossef.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace -EBUSY with -EAGAIN when reporting transient busy
indication in the absence of backlog.

Signed-off-by: Gilad Ben-Yossef <gilad@benyossef.com>
Reviewed-by: Gary R Hook <gary.hook@amd.com>

---

Please squash this patch with the previous one when merging upstream.
---
 drivers/crypto/ccp/ccp-crypto-main.c | 8 +++-----
 drivers/crypto/ccp/ccp-dev.c         | 7 +++++--
 2 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/drivers/crypto/ccp/ccp-crypto-main.c b/drivers/crypto/ccp/ccp-crypto-main.c
index 35a9de7..403ff0a 100644
--- a/drivers/crypto/ccp/ccp-crypto-main.c
+++ b/drivers/crypto/ccp/ccp-crypto-main.c
@@ -222,9 +222,10 @@ static int ccp_crypto_enqueue_cmd(struct ccp_crypto_cmd *crypto_cmd)
 
 	/* Check if the cmd can/should be queued */
 	if (req_queue.cmd_count >= CCP_CRYPTO_MAX_QLEN) {
-		ret = -EBUSY;
-		if (!(crypto_cmd->cmd->flags & CCP_CMD_MAY_BACKLOG))
+		if (!(crypto_cmd->cmd->flags & CCP_CMD_MAY_BACKLOG)) {
+			ret = -EAGAIN;
 			goto e_lock;
+		}
 	}
 
 	/* Look for an entry with the same tfm.  If there is a cmd
@@ -243,9 +244,6 @@ static int ccp_crypto_enqueue_cmd(struct ccp_crypto_cmd *crypto_cmd)
 		ret = ccp_enqueue_cmd(crypto_cmd->cmd);
 		if (!ccp_crypto_success(ret))
 			goto e_lock;	/* Error, don't queue it */
-		if ((ret == -EBUSY) &&
-		    !(crypto_cmd->cmd->flags & CCP_CMD_MAY_BACKLOG))
-			goto e_lock;	/* Not backlogging, don't queue it */
 	}
 
 	if (req_queue.cmd_count >= CCP_CRYPTO_MAX_QLEN) {
diff --git a/drivers/crypto/ccp/ccp-dev.c b/drivers/crypto/ccp/ccp-dev.c
index 4e029b1..3d637e3 100644
--- a/drivers/crypto/ccp/ccp-dev.c
+++ b/drivers/crypto/ccp/ccp-dev.c
@@ -292,9 +292,12 @@ int ccp_enqueue_cmd(struct ccp_cmd *cmd)
 	i = ccp->cmd_q_count;
 
 	if (ccp->cmd_count >= MAX_CMD_QLEN) {
-		ret = -EBUSY;
-		if (cmd->flags & CCP_CMD_MAY_BACKLOG)
+		if (cmd->flags & CCP_CMD_MAY_BACKLOG) {
+			ret = -EBUSY;
 			list_add_tail(&cmd->entry, &ccp->backlog);
+		} else {
+			ret = -EAGAIN;
+		}
 	} else {
 		ret = -EINPROGRESS;
 		ccp->cmd_count++;
-- 
2.1.4
