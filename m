From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: [PATCH net-next] sctp: fix GSO for IPv6
Date: Fri, 15 Jul 2016 16:40:02 -0300
Message-ID: <cc3fc851d2ff9abfe104807381cc21280648410d.1468609983.git.marcelo.leitner@gmail.com>
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Vlad Yasevich <vyasevich@gmail.com>, linux-sctp@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48775 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751359AbcGOTkN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Jul 2016 15:40:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 90017accff61 ("sctp: Add GSO support") didn't register SCTP GSO
offloading for IPv6 and yet didn't put any restrictions on generating
GSO packets while in IPv6, which causes all IPv6 GSO'ed packets to be
silently dropped.

The fix is to properly register the offload this time.

Fixes: 90017accff61 ("sctp: Add GSO support")
Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
---
I guess sctp multi-homing outsmarted myself during testing, ugh.

 net/sctp/offload.c | 23 ++++++++++++++++++++++-
 1 file changed, 22 insertions(+), 1 deletion(-)

diff --git a/net/sctp/offload.c b/net/sctp/offload.c
index a37887b373a75524a54a1443f7df2d45ecf6cef7..7e869d0cca69826ee3e892e389bacdc9a58a1637 100644
--- a/net/sctp/offload.c
+++ b/net/sctp/offload.c
@@ -92,7 +92,28 @@ static const struct net_offload sctp_offload = {
 	},
 };
 
+static const struct net_offload sctp6_offload = {
+	.callbacks = {
+		.gso_segment = sctp_gso_segment,
+	},
+};
+
 int __init sctp_offload_init(void)
 {
-	return inet_add_offload(&sctp_offload, IPPROTO_SCTP);
+	int ret;
+
+	ret = inet_add_offload(&sctp_offload, IPPROTO_SCTP);
+	if (ret)
+		goto out;
+
+	ret = inet6_add_offload(&sctp6_offload, IPPROTO_SCTP);
+	if (ret)
+		goto ipv4;
+
+	return ret;
+
+ipv4:
+	inet_del_offload(&sctp_offload, IPPROTO_SCTP);
+out:
+	return ret;
 }
-- 
2.7.4
