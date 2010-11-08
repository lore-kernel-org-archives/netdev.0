From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH] rds: Fix rds message leak in rds_message_map_pages
Date: Mon, 08 Nov 2010 19:20:50 +0300
Message-ID: <4CD82362.9070402@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: rds-devel@oss.oracle.com,
	Linux Netdev List <netdev@vger.kernel.org>
To: Andy Grover <andy.grover@oracle.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:35388 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752481Ab0KHQVE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Nov 2010 11:21:04 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The sgs allocation error path leaks the allocated message.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/net/rds/message.c b/net/rds/message.c
index 848cff4..1fd3d29 100644
--- a/net/rds/message.c
+++ b/net/rds/message.c
@@ -249,8 +249,10 @@ struct rds_message *rds_message_map_pages(unsigned long *page_addrs, unsigned in
 	rm->m_inc.i_hdr.h_len = cpu_to_be32(total_len);
 	rm->data.op_nents = ceil(total_len, PAGE_SIZE);
 	rm->data.op_sg = rds_message_alloc_sgs(rm, num_sgs);
-	if (!rm->data.op_sg)
+	if (!rm->data.op_sg) {
+		rds_message_put(rm);
 		return ERR_PTR(-ENOMEM);
+	}
 
 	for (i = 0; i < rm->data.op_nents; ++i) {
 		sg_set_page(&rm->data.op_sg[i],
