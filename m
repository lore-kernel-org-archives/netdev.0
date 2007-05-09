From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH 1/3] [SCTP] Prevent OOPS if hmac modules didn't load
Date: Wed,  9 May 2007 15:43:48 -0400
Message-ID: <11787398301465-git-send-email-vladislav.yasevich@hp.com>
References: <11787398302375-git-send-email-vladislav.yasevich@hp.com>
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net,
	Vlad Yasevich <vladislav.yasevich@hp.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel6.hp.com ([156.153.255.205]:39382 "EHLO atlrel6.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755348AbXEITn4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 May 2007 15:43:56 -0400
In-Reply-To: <11787398302375-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

SCTP was checking for NULL when trying to detect hmac
allocation failure where it should have been using IS_ERR.
Also, print a rate limited warning to the log telling the
user what happend.

Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 net/sctp/socket.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 64fb074..cc2ed54 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -5227,7 +5227,12 @@ int sctp_inet_listen(struct socket *sock, int backlog)
 	/* Allocate HMAC for generating cookie. */
 	if (sctp_hmac_alg) {
 		tfm = crypto_alloc_hash(sctp_hmac_alg, 0, CRYPTO_ALG_ASYNC);
-		if (!tfm) {
+		if (IS_ERR(tfm)) {
+			if (net_ratelimit()) {
+				printk(KERN_INFO
+				       "SCTP: failed to load transform for %s: %ld\n",
+					sctp_hmac_alg, PTR_ERR(tfm));
+			}
 			err = -ENOSYS;
 			goto out;
 		}
-- 
1.5.0.3.438.gc49b2

