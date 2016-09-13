From: Tobias Regnery <tobias.regnery@gmail.com>
Subject: [PATCH net-next] alx: fix error handling in __alx_open
Date: Tue, 13 Sep 2016 12:06:57 +0200
Message-ID: <1473761217-18905-1-git-send-email-tobias.regnery@gmail.com>
Cc: davem@davemloft.net, Tobias Regnery <tobias.regnery@gmail.com>
To: netdev@vger.kernel.org, jcliburn@gmail.com, chris.snook@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:35730 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756243AbcIMKHQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Sep 2016 06:07:16 -0400
Received: by mail-wm0-f66.google.com with SMTP id c131so2210611wmh.2
        for <netdev@vger.kernel.org>; Tue, 13 Sep 2016 03:07:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In commit 9ee7b683ea63 we moved the enablement of msi interrupts earlier in
alx_init_intr. If there is an error in alx_alloc_rings, __alx_open returns
with an error but msi (or msi-x) interrupts stays enabled. Add a new error
label to disable msi (or msi-x) interrupts.

Fixes: 9ee7b683ea63 ("alx: refactor msi enablement and disablement")
Signed-off-by: Tobias Regnery <tobias.regnery@gmail.com>
---
 drivers/net/ethernet/atheros/alx/main.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/atheros/alx/main.c b/drivers/net/ethernet/atheros/alx/main.c
index 9887cee434dd..c0f84b73574d 100644
--- a/drivers/net/ethernet/atheros/alx/main.c
+++ b/drivers/net/ethernet/atheros/alx/main.c
@@ -1028,7 +1028,7 @@ static int __alx_open(struct alx_priv *alx, bool resume)
 
 	err = alx_alloc_rings(alx);
 	if (err)
-		return err;
+		goto out_disable_adv_intr;
 
 	alx_configure(alx);
 
@@ -1049,6 +1049,8 @@ static int __alx_open(struct alx_priv *alx, bool resume)
 
 out_free_rings:
 	alx_free_rings(alx);
+out_disable_adv_intr:
+	alx_disable_advanced_intr(alx);
 	return err;
 }
 
-- 
2.7.4
