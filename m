From: gfree.wind@vip.163.com
Subject: [PATCH net v2] driver: vrf: Fix one possible use-after-free issue
Date: Tue,  9 May 2017 18:27:33 +0800
Message-ID: <1494325653-39885-1-git-send-email-gfree.wind@vip.163.com>
Cc: Gao Feng <gfree.wind@vip.163.com>
To: dsa@cumulusnetworks.com, shm@cumulusnetworks.com,
        davem@davemloft.net, fw@strlen.de, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-177180.vip.163.com ([123.58.177.180]:58964 "EHLO
        mail-177180.vip.163.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751587AbdEIK2c (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 9 May 2017 06:28:32 -0400
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
even though nf_hook returns 1. But we need to modify vrf_rcv_finish
to deal with the NF_STOLEN case.

There are two cases when skb is stolen.
1. The skb is stolen and freed directly.
   There is nothing we need to do, and vrf_rcv_finish isn't invoked.
2. The skb is queued and reinjected again.
   The vrf_rcv_finish would be invoked as okfn, so need to free the
   skb in it.

Signed-off-by: Gao Feng <gfree.wind@vip.163.com>
---
 v2: Free the skb in vrf_rcv_finish, per Florian
 v1: initial version

 drivers/net/vrf.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index ceda586..db88249 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -989,6 +989,7 @@ static u32 vrf_fib_table(const struct net_device *dev)
 
 static int vrf_rcv_finish(struct net *net, struct sock *sk, struct sk_buff *skb)
 {
+	kfree_skb(skb);
 	return 0;
 }
 
@@ -998,7 +999,7 @@ static struct sk_buff *vrf_rcv_nfhook(u8 pf, unsigned int hook,
 {
 	struct net *net = dev_net(dev);
 
-	if (NF_HOOK(pf, hook, net, NULL, skb, dev, NULL, vrf_rcv_finish) < 0)
+	if (nf_hook(pf, hook, net, NULL, skb, dev, NULL, vrf_rcv_finish) != 1)
 		skb = NULL;    /* kfree_skb(skb) handled by nf code */
 
 	return skb;
-- 
1.9.1
