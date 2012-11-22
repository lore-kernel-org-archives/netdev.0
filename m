From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 6/9] ixgbe: fdb: only allow NUD_PERM fdb entries
Date: Thu, 22 Nov 2012 02:11:14 -0800
Message-ID: <1353579077-12097-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1353579077-12097-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: John Fastabend <john.r.fastabend@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:9910 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752232Ab2KVSfG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Nov 2012 13:35:06 -0500
In-Reply-To: <1353579077-12097-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>

There was a bitwise operation error in the fdb_add block
that was only allowing FDB types that were not permanent.

This was the opposite of the intent because the hardware
never ages out address these are the _only_ type of addrs
that should be allowed.

This was missed because until recently iproute2 did not
set any bit for this by default. And our test code to
manage FDB entries on embedded devices similarly did not
set these bits.

I am going to chalk this up as a bug and fix it now.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 4f67fdc..80e3cb7 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -6954,7 +6954,10 @@ static int ixgbe_ndo_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
 	if (!(adapter->flags & IXGBE_FLAG_SRIOV_ENABLED))
 		return -EOPNOTSUPP;
 
-	if (ndm->ndm_state & NUD_PERMANENT) {
+	/* Hardware does not support aging addresses so if a
+	 * ndm_state is given only allow permanent addresses
+	 */
+	if (ndm->ndm_state && !(ndm->ndm_state & NUD_PERMANENT)) {
 		pr_info("%s: FDB only supports static addresses\n",
 			ixgbe_driver_name);
 		return -EINVAL;
-- 
1.7.11.7
