From: Peter Senna Tschudin <peter.senna@gmail.com>
Subject: [PATCH 7/20 V2] drivers/net/irda/mcs7780.c: fix error return code
Date: Fri,  5 Oct 2012 23:33:04 +0200
Message-ID: <1349472786-10921-3-git-send-email-peter.senna@gmail.com>
References: <1349472786-10921-1-git-send-email-peter.senna@gmail.com>
Cc: irda-users@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org,
	Peter Senna Tschudin <peter.senna@gmail.com>
To: samuel@sortiz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:49491 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757379Ab2JEVda (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Oct 2012 17:33:30 -0400
In-Reply-To: <1349472786-10921-1-git-send-email-peter.senna@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter Senna Tschudin <peter.senna@gmail.com>

The function mcs_probe() return 0 for success and negative value
for most of its internal tests failures. There is one exception
that is error case going to error2:. For this error case, the
function abort its success execution path, but returns non negative
value, making it difficult for a caller function to notice the error.

This patch fixes the error case that do not return negative value.

A simplified version of the semantic match that finds this problem is
as follows: (http://coccinelle.lip6.fr/)

// <smpl>
(
if@p1 (\(ret < 0\|ret != 0\))
 { ... return ret; }
|
ret@p1 = 0
)
... when != ret = e1
    when != &ret
*if(...)
{
  ... when != ret = e2
      when forall
 return ret;
}
// </smpl>

Signed-off-by: Peter Senna Tschudin <peter.senna@gmail.com>

---
Change from V1:
        Updated commit message. See:
        http://www.kernelhub.org/?p=2&msg=139319

 drivers/net/irda/mcs7780.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/irda/mcs7780.c b/drivers/net/irda/mcs7780.c
index 1a00b59..f07c340 100644
--- a/drivers/net/irda/mcs7780.c
+++ b/drivers/net/irda/mcs7780.c
@@ -920,8 +920,10 @@ static int mcs_probe(struct usb_interface *intf,
 
 	ndev->netdev_ops = &mcs_netdev_ops;
 
-	if (!intf->cur_altsetting)
+	if (!intf->cur_altsetting) {
+		ret = -ENOMEM;
 		goto error2;
+	}
 
 	ret = mcs_find_endpoints(mcs, intf->cur_altsetting->endpoint,
 				 intf->cur_altsetting->desc.bNumEndpoints);
