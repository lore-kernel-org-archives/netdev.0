From: fgao@ikuai8.com
Subject: [PATCH 2/2] pptp: Reset call_id as 0 to avoid one useless lookup at next time
Date: Thu, 18 Aug 2016 13:07:59 +0800
Message-ID: <1471496879-6423-1-git-send-email-fgao@ikuai8.com>
Cc: gfree.wind@gmail.com, Gao Feng <fgao@ikuai8.com>
To: xeb@mail.ru, philipp@redfish-solutions.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from SMTPBG1.QQ.COM ([183.60.61.196]:39956 "EHLO smtpbg1.qq.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750720AbcHRFIS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Aug 2016 01:08:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao Feng <fgao@ikuai8.com>

When pptp fails to get valid callid, the global call_id is set as
MAX_CALLID. Then it must fail to get callid at next time, when
invoke find_next_zero_bit from call_id+1. Because the call_id+1
exceeds the limit "MAX_CALLID".
So reset call_id as 0 when fail to get valid callid. And add one
variable to check if need the second lookup.

Signed-off-by: Gao Feng <fgao@ikuai8.com>
---
 v1: Initial patch

 drivers/net/ppp/pptp.c | 19 +++++++++++++++----
 1 file changed, 15 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ppp/pptp.c b/drivers/net/ppp/pptp.c
index 48c3701..9afef3c 100644
--- a/drivers/net/ppp/pptp.c
+++ b/drivers/net/ppp/pptp.c
@@ -103,12 +103,21 @@ static int add_chan(struct pppox_sock *sock,
 	static int call_id;
 
 	spin_lock(&chan_lock);
-	if (!sa->call_id)	{
+	if (!sa->call_id) {
+		bool from_start = (call_id == 0);
+
 		call_id = find_next_zero_bit(callid_bitmap, MAX_CALLID, call_id + 1);
 		if (call_id == MAX_CALLID) {
-			call_id = find_next_zero_bit(callid_bitmap, MAX_CALLID, 1);
-			if (call_id == MAX_CALLID)
+			if (unlikely(from_start)) {
+				call_id = 0;
 				goto out_err;
+			} else {
+				call_id = find_next_zero_bit(callid_bitmap, MAX_CALLID, 1);
+				if (call_id == MAX_CALLID) {
+					call_id = 0;
+					goto out_err;
+				}
+			}
 		}
 		sa->call_id = call_id;
 	} else if (test_bit(sa->call_id, callid_bitmap)) {
@@ -656,8 +665,10 @@ static int __init pptp_init_module(void)
 	pr_info("PPTP driver version " PPTP_DRIVER_VERSION "\n");
 
 	callid_sock = vzalloc((MAX_CALLID + 1) * sizeof(void *));
-	if (!callid_sock)
+	if (!callid_sock) {
+		pr_err("PPTP: can't alloc callid_sock mem");
 		return -ENOMEM;
+	}
 
 	err = gre_add_protocol(&gre_pptp_protocol, GREPROTO_PPTP);
 	if (err) {
-- 
1.9.1
