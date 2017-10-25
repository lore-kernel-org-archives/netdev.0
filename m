From: Mika Westerberg <mika.westerberg@linux.intel.com>
Subject: [PATCH] thunderbolt: Drop sequence number check from tb_xdomain_match()
Date: Wed, 25 Oct 2017 12:27:34 +0300
Message-ID: <20171025092734.51299-1-mika.westerberg@linux.intel.com>
Cc: Andreas Noever <andreas.noever@gmail.com>,
        Michael Jamet <michael.jamet@intel.com>,
        Yehezkel Bernat <yehezkel.bernat@intel.com>,
        Dan Carpenter <dan.carpenter@oracle.com>,
        Amir Levy <amir.jer.levy@intel.com>,
        Mika Westerberg <mika.westerberg@linux.intel.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:20736 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932253AbdJYJ1j (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 25 Oct 2017 05:27:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 9a03c3d398c1 ("thunderbolt: Fix a couple right shifting to zero
bugs") revealed an issue that was previously hidden because we never
actually compared received XDomain message sequence numbers properly.
The idea with these sequence numbers is that the responding host uses
the same sequence number that was in the request packet which we can
then check at the requesting host.

However, testing against macOS it looks like it does not follow this but
instead uses some other logic. Windows driver on the other hand handles
it the same way than Linux.

In order to be able to talk to macOS again, fix this so that we drop the
whole sequence number check. This effectively works exactly the same
than it worked before the aforementioned commit. This also follows the
logic the original P2P networking code used.

Signed-off-by: Mika Westerberg <mika.westerberg@linux.intel.com>
---
This applies on top of net-next.git/master.

 drivers/thunderbolt/xdomain.c | 9 ---------
 1 file changed, 9 deletions(-)

diff --git a/drivers/thunderbolt/xdomain.c b/drivers/thunderbolt/xdomain.c
index ff8d91189e99..f25d88d4552b 100644
--- a/drivers/thunderbolt/xdomain.c
+++ b/drivers/thunderbolt/xdomain.c
@@ -56,7 +56,6 @@ static bool tb_xdomain_match(const struct tb_cfg_request *req,
 	case TB_CFG_PKG_XDOMAIN_RESP: {
 		const struct tb_xdp_header *res_hdr = pkg->buffer;
 		const struct tb_xdp_header *req_hdr = req->request;
-		u32 req_seq, res_seq;
 
 		if (pkg->frame.size < req->response_size / 4)
 			return false;
@@ -68,14 +67,6 @@ static bool tb_xdomain_match(const struct tb_cfg_request *req,
 		if ((res_hdr->xd_hdr.route_lo) != req_hdr->xd_hdr.route_lo)
 			return false;
 
-		/* Then check that the sequence number matches */
-		res_seq = res_hdr->xd_hdr.length_sn & TB_XDOMAIN_SN_MASK;
-		res_seq >>= TB_XDOMAIN_SN_SHIFT;
-		req_seq = req_hdr->xd_hdr.length_sn & TB_XDOMAIN_SN_MASK;
-		req_seq >>= TB_XDOMAIN_SN_SHIFT;
-		if (res_seq != req_seq)
-			return false;
-
 		/* Check that the XDomain protocol matches */
 		if (!uuid_equal(&res_hdr->uuid, &req_hdr->uuid))
 			return false;
-- 
2.14.2
