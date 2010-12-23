From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net-next 7/9] cnic: Call cm_connect_complete()
 immediately on error
Date: Thu, 23 Dec 2010 09:43:02 -0800
Message-ID: <1293126184-13097-8-git-send-email-mchan@broadcom.com>
References: <1293126184-13097-1-git-send-email-mchan@broadcom.com>
 <1293126184-13097-2-git-send-email-mchan@broadcom.com>
 <1293126184-13097-3-git-send-email-mchan@broadcom.com>
 <1293126184-13097-4-git-send-email-mchan@broadcom.com>
 <1293126184-13097-5-git-send-email-mchan@broadcom.com>
 <1293126184-13097-6-git-send-email-mchan@broadcom.com>
 <1293126184-13097-7-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2731 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753428Ab0LWSkf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Dec 2010 13:40:35 -0500
In-Reply-To: <1293126184-13097-7-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eddie Wai <waie@broadcom.com>

If we get a path_resp error from userspace, call cm_connect_complete()
immediately with error so that bnx2i can react to the error faster.

Signed-off-by: Eddie Wai <waie@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/cnic.c |   16 ++++++++++++++--
 1 files changed, 14 insertions(+), 2 deletions(-)

diff --git a/drivers/net/cnic.c b/drivers/net/cnic.c
index 1240dea..36c1578 100644
--- a/drivers/net/cnic.c
+++ b/drivers/net/cnic.c
@@ -322,6 +322,8 @@ static int cnic_send_nlmsg(struct cnic_local *cp, u32 type,
 	return 0;
 }
 
+static void cnic_cm_upcall(struct cnic_local *, struct cnic_sock *, u8);
+
 static int cnic_iscsi_nl_msg_recv(struct cnic_dev *dev, u32 msg_type,
 				  char *buf, u16 len)
 {
@@ -351,7 +353,9 @@ static int cnic_iscsi_nl_msg_recv(struct cnic_dev *dev, u32 msg_type,
 		}
 		csk = &cp->csk_tbl[l5_cid];
 		csk_hold(csk);
-		if (cnic_in_use(csk)) {
+		if (cnic_in_use(csk) &&
+		    test_bit(SK_F_CONNECT_START, &csk->flags)) {
+
 			memcpy(csk->ha, path_resp->mac_addr, 6);
 			if (test_bit(SK_F_IPV6, &csk->flags))
 				memcpy(&csk->src_ip[0], &path_resp->src.v6_addr,
@@ -359,8 +363,16 @@ static int cnic_iscsi_nl_msg_recv(struct cnic_dev *dev, u32 msg_type,
 			else
 				memcpy(&csk->src_ip[0], &path_resp->src.v4_addr,
 				       sizeof(struct in_addr));
-			if (is_valid_ether_addr(csk->ha))
+
+			if (is_valid_ether_addr(csk->ha)) {
 				cnic_cm_set_pg(csk);
+			} else if (!test_bit(SK_F_OFFLD_SCHED, &csk->flags) &&
+				!test_bit(SK_F_OFFLD_COMPLETE, &csk->flags)) {
+
+				cnic_cm_upcall(cp, csk,
+					L4_KCQE_OPCODE_VALUE_CONNECT_COMPLETE);
+				clear_bit(SK_F_CONNECT_START, &csk->flags);
+			}
 		}
 		csk_put(csk);
 		rcu_read_unlock();
-- 
1.6.4.GIT


