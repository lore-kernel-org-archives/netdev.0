From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the net-next tree
Date: Tue, 10 Jan 2017 10:59:27 +1100
Message-ID: <20170110105927.29edcec0@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
        Ursula Braun <ubraun@linux.vnet.ibm.com>,
        Utz Bacher <utz.bacher@de.ibm.com>
To: David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>,
        Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([103.22.144.67]:58073 "EHLO ozlabs.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1764454AbdAIX73 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 9 Jan 2017 18:59:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

After merging the net-next tree, today's linux-next build (x86_64
allmodconfig) failed like this:

net/smc/af_smc.c: In function 'smc_splice_read':
net/smc/af_smc.c:1258:39: error: passing argument 1 of 'smc->clcsock->ops->splice_read' from incompatible pointer type [-Werror=incompatible-pointer-types]
   rc = smc->clcsock->ops->splice_read(smc->clcsock, ppos,
                                       ^
net/smc/af_smc.c:1258:39: note: expected 'struct file *' but argument is of type 'struct socket *'
net/smc/af_smc.c: At top level:
net/smc/af_smc.c:1288:17: error: initialization from incompatible pointer type [-Werror=incompatible-pointer-types]
  .splice_read = smc_splice_read,   
                 ^
net/smc/af_smc.c:1288:17: note: (near initialization for 'smc_sock_ops.splice_read')

Caused by commit

  ac7138746e14 ("smc: establish new socket family")

interacting with commit

  15a8f657c71d ("switch socket ->splice_read() to struct file *")

from the vfs tree.

I applied the following merge fix patch which could well be incorrect ...

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Tue, 10 Jan 2017 10:52:38 +1100
Subject: [PATCH] smc: merge fix for "switch socket ->splice_read() to struct file *"

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 net/smc/af_smc.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/smc/af_smc.c b/net/smc/af_smc.c
index 5d4208ad029e..4875e65f0c4a 100644
--- a/net/smc/af_smc.c
+++ b/net/smc/af_smc.c
@@ -1242,10 +1242,11 @@ static ssize_t smc_sendpage(struct socket *sock, struct page *page,
 	return rc;
 }
 
-static ssize_t smc_splice_read(struct socket *sock, loff_t *ppos,
+static ssize_t smc_splice_read(struct file *file, loff_t *ppos,
 			       struct pipe_inode_info *pipe, size_t len,
 				    unsigned int flags)
 {
+	struct socket *sock = file->private_data;
 	struct sock *sk = sock->sk;
 	struct smc_sock *smc;
 	int rc = -ENOTCONN;
@@ -1255,7 +1256,7 @@ static ssize_t smc_splice_read(struct socket *sock, loff_t *ppos,
 	if ((sk->sk_state != SMC_ACTIVE) && (sk->sk_state != SMC_CLOSED))
 		goto out;
 	if (smc->use_fallback) {
-		rc = smc->clcsock->ops->splice_read(smc->clcsock, ppos,
+		rc = smc->clcsock->ops->splice_read(file, ppos,
 						    pipe, len, flags);
 	} else {
 		rc = -EOPNOTSUPP;
-- 
2.10.2

-- 
Cheers,
Stephen Rothwell
