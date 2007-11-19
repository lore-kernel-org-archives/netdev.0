From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH][PKTGEN] Fix double unlock of xfrm_state->lock
Date: Mon, 19 Nov 2007 12:47:00 +0300
Message-ID: <47415B94.1010002@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:43214 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752512AbXKSJrq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Nov 2007 04:47:46 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The pktgen_output_ipsec() function can unlock this lock twice
due to merged error and plain paths. Remove one of the calls
to spin_unlock.

Other possible solution would be to place "return 0" right 
after the first unlock, but at this place the err is known 
to be 0, so these solutions are the same except for this one
makes the code shorter.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index de33f36..285ec3e 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -2463,8 +2463,6 @@ static int pktgen_output_ipsec(struct sk_buff *skb, struct pktgen_dev *pkt_dev)
 
 	x->curlft.bytes +=skb->len;
 	x->curlft.packets++;
-	spin_unlock(&x->lock);
-
 error:
 	spin_unlock(&x->lock);
 	return err;
