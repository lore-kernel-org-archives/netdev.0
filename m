From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 3/4] xfrm: policy: check policy direction value
Date: Mon, 21 Aug 2017 08:08:02 +0200
Message-ID: <1503295683-19153-4-git-send-email-steffen.klassert@secunet.com>
References: <1503295683-19153-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:35478 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751077AbdHUGIL (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 21 Aug 2017 02:08:11 -0400
In-Reply-To: <1503295683-19153-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vladis Dronov <vdronov@redhat.com>

The 'dir' parameter in xfrm_migrate() is a user-controlled byte which is used
as an array index. This can lead to an out-of-bound access, kernel lockup and
DoS. Add a check for the 'dir' value.

This fixes CVE-2017-11600.

References: https://bugzilla.redhat.com/show_bug.cgi?id=1474928
Fixes: 80c9abaabf42 ("[XFRM]: Extension for dynamic update of endpoint address(es)")
Cc: <stable@vger.kernel.org> # v2.6.21-rc1
Reported-by: "bo Zhang" <zhangbo5891001@gmail.com>
Signed-off-by: Vladis Dronov <vdronov@redhat.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_policy.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index ff61d85..6f5a0dad 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -3308,9 +3308,15 @@ int xfrm_migrate(const struct xfrm_selector *sel, u8 dir, u8 type,
 	struct xfrm_state *x_new[XFRM_MAX_DEPTH];
 	struct xfrm_migrate *mp;
 
+	/* Stage 0 - sanity checks */
 	if ((err = xfrm_migrate_check(m, num_migrate)) < 0)
 		goto out;
 
+	if (dir >= XFRM_POLICY_MAX) {
+		err = -EINVAL;
+		goto out;
+	}
+
 	/* Stage 1 - find policy */
 	if ((pol = xfrm_migrate_policy_find(sel, dir, type, net)) == NULL) {
 		err = -ENOENT;
-- 
2.7.4
