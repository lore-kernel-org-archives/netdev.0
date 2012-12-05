From: Paul Chavent <Paul.Chavent@onera.fr>
Subject: [PATCH] net: fixup tx time stamping for uml vde driver.
Date: Wed,  5 Dec 2012 15:20:53 +0100
Message-ID: <1354717253-8737-1-git-send-email-paul.chavent@onera.fr>
Cc: Paul Chavent <Paul.Chavent@onera.fr>
To: jdike@addtoit.com, richard@nod.at,
	user-mode-linux-devel@lists.sourceforge.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from briaree.onecert.fr ([134.212.190.4]:36700 "EHLO
	briaree.onecert.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752120Ab2LEOX6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2012 09:23:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Call skb_tx_timestamp after write completion.

Signed-off-by: Paul Chavent <paul.chavent@onera.fr>
---
 arch/um/drivers/vde_kern.c | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/arch/um/drivers/vde_kern.c b/arch/um/drivers/vde_kern.c
index 6a365fa..38fea2f 100644
--- a/arch/um/drivers/vde_kern.c
+++ b/arch/um/drivers/vde_kern.c
@@ -52,9 +52,13 @@ static int vde_write(int fd, struct sk_buff *skb, struct uml_net_private *lp)
 {
 	struct vde_data *pri = (struct vde_data *) &lp->user;
 
-	if (pri->conn != NULL)
-		return vde_user_write((void *)pri->conn, skb->data,
-				      skb->len);
+	if (pri->conn != NULL) {
+		int count;
+		count = vde_user_write((void *)pri->conn, skb->data,
+				       skb->len);
+		skb_tx_timestamp(skb);
+		return count;
+	}
 
 	printk(KERN_ERR "vde_write - we have no VDECONN to write to");
 	return -EBADF;
-- 
1.7.12.1
