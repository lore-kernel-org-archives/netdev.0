From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [PATCH 1/2 v2 net-next] thunderbolt: Fix a couple right shifting to
 zero bugs
Date: Tue, 17 Oct 2017 15:32:17 +0300
Message-ID: <20171017123217.p3ctmptbrm75ys46@mwanda>
References: <20171013112959.sc2pwazrpk7fxbtw@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Jamet <michael.jamet@intel.com>,
        Mika Westerberg <mika.westerberg@linux.intel.com>,
        Yehezkel Bernat <yehezkel.bernat@intel.com>,
        netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Andreas Noever <andreas.noever@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:26967 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752832AbdJQMcf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2017 08:32:35 -0400
Content-Disposition: inline
In-Reply-To: <20171013112959.sc2pwazrpk7fxbtw@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The problematic code looks like this:

	res_seq = res_hdr->xd_hdr.length_sn & TB_XDOMAIN_SN_MASK;
	res_seq >>= TB_XDOMAIN_SN_SHIFT;

TB_XDOMAIN_SN_SHIFT is 27, and right shifting a u8 27 bits is always
going to result in zero.  The fix is to declare these variables as u32.

Fixes: d1ff70241a27 ("thunderbolt: Add support for XDomain discovery protocol")
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
---
v2: I accidentally sent this through the wrong list, so I'm resending to
    netdev.  Also Mika asked me to split it up because the Fixes tags
    are different for these patches.

diff --git a/drivers/thunderbolt/xdomain.c b/drivers/thunderbolt/xdomain.c
index 138027537d29..ff8d91189e99 100644
--- a/drivers/thunderbolt/xdomain.c
+++ b/drivers/thunderbolt/xdomain.c
@@ -56,7 +56,7 @@ static bool tb_xdomain_match(const struct tb_cfg_request *req,
 	case TB_CFG_PKG_XDOMAIN_RESP: {
 		const struct tb_xdp_header *res_hdr = pkg->buffer;
 		const struct tb_xdp_header *req_hdr = req->request;
-		u8 req_seq, res_seq;
+		u32 req_seq, res_seq;
 
 		if (pkg->frame.size < req->response_size / 4)
 			return false;
@@ -476,7 +476,7 @@ static void tb_xdp_handle_request(struct work_struct *work)
 	struct tb_ctl *ctl = tb->ctl;
 	const uuid_t *uuid;
 	int ret = 0;
-	u8 sequence;
+	u32 sequence;
 	u64 route;
 
 	route = ((u64)xhdr->route_hi << 32 | xhdr->route_lo) & ~BIT_ULL(63);
