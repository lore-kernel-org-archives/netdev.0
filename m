From: Guillaume Nault <g.nault@alphalink.fr>
Subject: [PATCH net-next] ppp: clarify parsing of user supplied data in
 ppp_set_compress()
Date: Tue, 23 Feb 2016 13:59:43 +0100
Message-ID: <4765fab0f32c4a2391828b8c418592f4a5bcede6.1456232225.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Paul Mackerras <paulus@samba.org>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:43717 "EHLO
	zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751549AbcBWNIh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Feb 2016 08:08:37 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  * Split big conditional statement.
  * Check (data.length <= CCP_MAX_OPTION_LENGTH) only once.
  * Don't read ccp_option[1] if not initialised.

Reading uninitialised ccp_option[1] was harmless, because this could
only happen when data.length was 0 or 1. So even then, we couldn't pass
the (ccp_option[1] < 2 || ccp_option[1] > data.length) test anyway.

Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>
---
 drivers/net/ppp/ppp_generic.c | 12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ppp/ppp_generic.c b/drivers/net/ppp/ppp_generic.c
index fc8ad00..04f4eb3 100644
--- a/drivers/net/ppp/ppp_generic.c
+++ b/drivers/net/ppp/ppp_generic.c
@@ -2429,13 +2429,15 @@ ppp_set_compress(struct ppp *ppp, unsigned long arg)
 	unsigned char ccp_option[CCP_MAX_OPTION_LENGTH];
 
 	err = -EFAULT;
-	if (copy_from_user(&data, (void __user *) arg, sizeof(data)) ||
-	    (data.length <= CCP_MAX_OPTION_LENGTH &&
-	     copy_from_user(ccp_option, (void __user *) data.ptr, data.length)))
+	if (copy_from_user(&data, (void __user *) arg, sizeof(data)))
 		goto out;
+	if (data.length > CCP_MAX_OPTION_LENGTH)
+		goto out;
+	if (copy_from_user(ccp_option, (void __user *) data.ptr, data.length))
+		goto out;
+
 	err = -EINVAL;
-	if (data.length > CCP_MAX_OPTION_LENGTH ||
-	    ccp_option[1] < 2 || ccp_option[1] > data.length)
+	if (data.length < 2 || ccp_option[1] < 2 || ccp_option[1] > data.length)
 		goto out;
 
 	cp = try_then_request_module(
-- 
2.7.0
