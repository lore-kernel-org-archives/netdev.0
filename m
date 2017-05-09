From: gfree.wind@vip.163.com
Subject: [PATCH net] driver: vrf: Fix one possible use-after-free issue
Date: Tue,  9 May 2017 16:54:29 +0800
Message-ID: <1494320069-39638-1-git-send-email-gfree.wind@vip.163.com>
Cc: Gao Feng <gfree.wind@vip.163.com>
To: dsa@cumulusnetworks.com, shm@cumulusnetworks.com,
        davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from m181-177.vip.163.com ([123.58.177.181]:56041 "EHLO
        m181-177.vip.163.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751229AbdEIJAT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 9 May 2017 05:00:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao Feng <gfree.wind@vip.163.com>

The current codes only deal with the case that the skb is dropped, it
may meet one use-after-free issue when NF_HOOK returns 0 that means
the skb is stolen by one netfilter rule or hook.

When one netfilter rule or hook stoles the skb and return NF_STOLEN,
it means the skb is taken by the rule, and other modules should not
touch this skb ever. Maybe the skb is queued or freed directly by the
rule.

Now uses the nf_hook instead of NF_HOOK to get the result of netfilter,
and check the return value of nf_hook. Only when its value equals 1, it
means the skb could go ahead. Or reset the skb as NULL.

BTW, because vrf_rcv_finish is empty function, so needn't invoke it
even though nf_hook returns 1.

Signed-off-by: Gao Feng <gfree.wind@vip.163.com>
---
 drivers/net/vrf.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index ceda586..8960f44 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -998,7 +998,7 @@ static struct sk_buff *vrf_rcv_nfhook(u8 pf, unsigned int hook,
 {
 	struct net *net = dev_net(dev);
 
-	if (NF_HOOK(pf, hook, net, NULL, skb, dev, NULL, vrf_rcv_finish) < 0)
+	if (nf_hook(pf, hook, net, NULL, skb, dev, NULL, vrf_rcv_finish) != 1)
 		skb = NULL;    /* kfree_skb(skb) handled by nf code */
 
 	return skb;
-- 
1.9.1
