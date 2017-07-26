From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net] dccp: fix a memleak for dccp_feat_init err process
Date: Wed, 26 Jul 2017 14:20:15 +0800
Message-ID: <62b8165447ec57830c1199af42a3490d896fbc26.1501050015.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net
To: network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:35835 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751756AbdGZGUW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Jul 2017 02:20:22 -0400
Received: by mail-pg0-f66.google.com with SMTP id d193so16442525pgc.2
        for <netdev@vger.kernel.org>; Tue, 25 Jul 2017 23:20:22 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In dccp_feat_init, when ccid_get_builtin_ccids failsto alloc
memory for rx.val, it should free tx.val before returning an
error.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 net/dccp/feat.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/net/dccp/feat.c b/net/dccp/feat.c
index 1704948..f227f00 100644
--- a/net/dccp/feat.c
+++ b/net/dccp/feat.c
@@ -1471,9 +1471,12 @@ int dccp_feat_init(struct sock *sk)
 	 * singleton values (which always leads to failure).
 	 * These settings can still (later) be overridden via sockopts.
 	 */
-	if (ccid_get_builtin_ccids(&tx.val, &tx.len) ||
-	    ccid_get_builtin_ccids(&rx.val, &rx.len))
+	if (ccid_get_builtin_ccids(&tx.val, &tx.len))
 		return -ENOBUFS;
+	if (ccid_get_builtin_ccids(&rx.val, &rx.len)) {
+		kfree(tx.val);
+		return -ENOBUFS;
+	}
 
 	if (!dccp_feat_prefer(sysctl_dccp_tx_ccid, tx.val, tx.len) ||
 	    !dccp_feat_prefer(sysctl_dccp_rx_ccid, rx.val, rx.len))
-- 
2.1.0
