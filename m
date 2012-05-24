From: Simon Graham <simon.graham@citrix.com>
Subject: [PATCH] xen/netback: Calculate the number of SKB slots required
 correctly
Date: Thu, 24 May 2012 12:26:07 -0400
Message-ID: <1337876767-16041-1-git-send-email-simon.graham@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"adnan.misherfi@oracle.com" <adnan.misherfi@oracle.com>,
	Simon Graham <simon.graham@citrix.com>
To: Ian Campbell <Ian.Campbell@citrix.com>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:53881 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933453Ab2EXQ07 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 May 2012 12:26:59 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When calculating the number of slots required for a packet header, the code
was reserving too many slots if the header crossed a page boundary. Since
netbk_gop_skb copies the header to the start of the page, the count of
slots required for the header should be based solely on the header size.

This problem is easy to reproduce if a VIF is bridged to a USB 3G modem
device as the skb->data value always starts near the end of the first page.

Signed-off-by: Simon Graham <simon.graham@citrix.com>
---
 drivers/net/xen-netback/netback.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index 2596401..f4a6fca 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -325,8 +325,7 @@ unsigned int xen_netbk_count_skb_slots(struct xenvif *vif, struct sk_buff *skb)
 	unsigned int count;
 	int i, copy_off;
 
-	count = DIV_ROUND_UP(
-			offset_in_page(skb->data)+skb_headlen(skb), PAGE_SIZE);
+	count = DIV_ROUND_UP(skb_headlen(skb), PAGE_SIZE);
 
 	copy_off = skb_headlen(skb) % PAGE_SIZE;
 
-- 
1.7.9.1
