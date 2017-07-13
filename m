From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [PATCH net] libceph: osdmap: Fix some NULL dereferences
Date: Thu, 13 Jul 2017 10:45:17 +0300
Message-ID: <20170713074517.io64uezw3qf6oush@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Yan, Zheng" <zyan@redhat.com>, Sage Weil <sage@redhat.com>,
        "David S. Miller" <davem@davemloft.net>,
        ceph-devel@vger.kernel.org, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org
To: Ilya Dryomov <idryomov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:27687 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751128AbdGMHpf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Jul 2017 03:45:35 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are hidden gotos in the ceph_decode_* macros.  We need to set the
"err" variable on these error paths otherwise we end up returning
ERR_PTR(0) which is NULL.  It causes NULL dereferences in the callers.

Fixes: 278b1d709c6a ("libceph: ceph_decode_skip_* helpers")
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/net/ceph/osdmap.c b/net/ceph/osdmap.c
index 864789c5974e..c7521a847ef7 100644
--- a/net/ceph/osdmap.c
+++ b/net/ceph/osdmap.c
@@ -510,6 +510,7 @@ static struct crush_map *crush_decode(void *pbyval, void *end)
 		}
 	}
 
+	err = -EINVAL;
 	ceph_decode_skip_map(p, end, 32, string, bad); /* type_map */
 	ceph_decode_skip_map(p, end, 32, string, bad); /* name_map */
 	ceph_decode_skip_map(p, end, 32, string, bad); /* rule_name_map */
@@ -1825,9 +1826,9 @@ struct ceph_osdmap *osdmap_apply_incremental(void **p, void *end,
 	if (struct_v >= 3) {
 		/* new_erasure_code_profiles */
 		ceph_decode_skip_map_of_map(p, end, string, string, string,
-					    bad);
+					    e_inval);
 		/* old_erasure_code_profiles */
-		ceph_decode_skip_set(p, end, string, bad);
+		ceph_decode_skip_set(p, end, string, e_inval);
 	}
 
 	if (struct_v >= 4) {
