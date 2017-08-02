From: Vladis Dronov <vdronov@redhat.com>
Subject: [PATCH] xfrm: policy: check policy direction value
Date: Wed,  2 Aug 2017 19:50:14 +0200
Message-ID: <20170802175014.20582-1-vdronov@redhat.com>
Cc: Vladis Dronov <vdronov@redhat.com>
To: Steffen Klassert <steffen.klassert@secunet.com>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, stable@vger.kernel.org
Return-path: <stable-owner@vger.kernel.org>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The 'dir' parameter in xfrm_migrate() is a user-controlled byte which is used
as an array index. This can lead to an out-of-bound access, kernel lockup and
DoS. Add a check for the 'dir' value.

This fixes CVE-2017-11600.

References: https://bugzilla.redhat.com/show_bug.cgi?id=1474928
Fixes: 80c9abaabf42 ("[XFRM]: Extension for dynamic update of endpoint address(es)")
Cc: <stable@vger.kernel.org> # v2.6.21-rc1
Reported-by: "bo Zhang" <zhangbo5891001@gmail.com>
Signed-off-by: Vladis Dronov <vdronov@redhat.com>
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
2.9.4
