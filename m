From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] NFC: llcp: integer underflow in nfc_llcp_set_remote_gb()
Date: Thu, 31 Jan 2013 11:16:46 +0300
Message-ID: <20130131081645.GA14812@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Aloisio Almeida Jr <aloisio.almeida@openbossa.org>,
	Samuel Ortiz <sameo@linux.intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	"John W. Linville" <linville@tuxdriver.com>,
	Thierry Escande <thierry.escande@linux.intel.com>,
	Szymon Janc <szymon.janc@tieto.com>,
	linux-wireless@vger.kernel.org, linux-nfc@ml01.01.org,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Lauro Ramos Venancio <lauro.venancio@openbossa.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:30426 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754148Ab3AaIRc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2013 03:17:32 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If gb_len is less than 3 it would cause an integer underflow and
possibly memory corruption in nfc_llcp_parse_gb_tlv().

I removed the old test for gb_len == 0.  I also removed the test for
->remote_gb == NULL.  It's not possible for ->remote_gb to be NULL and
we have already dereferenced ->remote_gb_len so it's too late to test.

The old test return -ENODEV but my test returns -EINVAL.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/net/nfc/llcp/llcp.c b/net/nfc/llcp/llcp.c
index 85bc75c..746f5a2 100644
--- a/net/nfc/llcp/llcp.c
+++ b/net/nfc/llcp/llcp.c
@@ -549,14 +549,13 @@ int nfc_llcp_set_remote_gb(struct nfc_dev *dev, u8 *gb, u8 gb_len)
 		pr_err("No LLCP device\n");
 		return -ENODEV;
 	}
+	if (gb_len < 3)
+		return -EINVAL;
 
 	memset(local->remote_gb, 0, NFC_MAX_GT_LEN);
 	memcpy(local->remote_gb, gb, gb_len);
 	local->remote_gb_len = gb_len;
 
-	if (local->remote_gb == NULL || local->remote_gb_len == 0)
-		return -ENODEV;
-
 	if (memcmp(local->remote_gb, llcp_magic, 3)) {
 		pr_err("MAC does not support LLCP\n");
 		return -EINVAL;
