From: David Woodhouse <dwmw2@infradead.org>
Subject: [PATCH 08/17] br2684: don't send frames on not-ready vcc
Date: Fri, 30 Nov 2012 00:35:27 +0000
Message-ID: <1354235736-26833-9-git-send-email-dwmw2@infradead.org>
References: <1354235736-26833-1-git-send-email-dwmw2@infradead.org>
Cc: chas@cmf.nrl.navy.mil, krzysiek@podlesie.net,
	David Woodhouse <dwmw2@infradead.org>,
	David Woodhouse <David.Woodhouse@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 173-166-109-252-newengland.hfc.comcastbusiness.net ([173.166.109.252]:47046
	"EHLO bombadil.infradead.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755202Ab2K3Agl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Nov 2012 19:36:41 -0500
In-Reply-To: <1354235736-26833-1-git-send-email-dwmw2@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Avoid submitting packets to a vcc which is being closed. Things go badly
wrong when the ->pop method gets later called after everything's been
torn down.

Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>
Acked-by: Krzysztof Mazur <krzysiek@podlesie.net>
---
 net/atm/br2684.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/net/atm/br2684.c b/net/atm/br2684.c
index 8eb6fbe..c483021 100644
--- a/net/atm/br2684.c
+++ b/net/atm/br2684.c
@@ -249,6 +249,12 @@ static int br2684_xmit_vcc(struct sk_buff *skb, struct net_device *dev,
 	skb_debug(skb);
 
 	ATM_SKB(skb)->vcc = atmvcc = brvcc->atmvcc;
+	if (test_bit(ATM_VF_RELEASED, &atmvcc->flags) ||
+	    test_bit(ATM_VF_CLOSE, &atmvcc->flags) ||
+	    !test_bit(ATM_VF_READY, &atmvcc->flags)) {
+		dev_kfree_skb(skb);
+		return 0;
+	}
 	pr_debug("atm_skb(%p)->vcc(%p)->dev(%p)\n", skb, atmvcc, atmvcc->dev);
 	atomic_add(skb->truesize, &sk_atm(atmvcc)->sk_wmem_alloc);
 	ATM_SKB(skb)->atm_options = atmvcc->atm_options;
-- 
1.8.0
