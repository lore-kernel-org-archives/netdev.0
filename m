From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next] net: vrf: Add support for PREROUTING rules on vrf device
Date: Mon,  4 Jul 2016 18:47:41 -0700
Message-ID: <1467683261-9336-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:35849 "EHLO
	mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752420AbcGEBrs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jul 2016 21:47:48 -0400
Received: by mail-pf0-f169.google.com with SMTP id t190so65215924pfb.3
        for <netdev@vger.kernel.org>; Mon, 04 Jul 2016 18:47:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for PREROUTING rules with skb->dev set to the vrf device.
INPUT rules are already allowed. Provides symmetry with the output path
which allows POSTROUTING rules.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 drivers/net/vrf.c | 21 +++++++++++++++++++++
 1 file changed, 21 insertions(+)

diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index b3762822b653..1ce7420322ee 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -779,6 +779,25 @@ static int vrf_get_saddr(struct net_device *dev, struct flowi4 *fl4)
 	return rc;
 }
 
+static int vrf_rcv_finish(struct net *net, struct sock *sk, struct sk_buff *skb)
+{
+	return 0;
+}
+
+static struct sk_buff *vrf_rcv_nfhook(u8 pf, unsigned int hook,
+				      struct sk_buff *skb,
+				      struct net_device *dev)
+{
+	struct net *net = dev_net(dev);
+
+	nf_reset(skb);
+
+	if (NF_HOOK(pf, hook, net, NULL, skb, dev, NULL, vrf_rcv_finish) < 0)
+		skb = NULL;    /* kfree_skb(skb) handled by nf code */
+
+	return skb;
+}
+
 #if IS_ENABLED(CONFIG_IPV6)
 /* neighbor handling is done with actual device; do not want
  * to flip skb->dev for those ndisc packets. This really fails
@@ -899,6 +918,7 @@ static struct sk_buff *vrf_ip6_rcv(struct net_device *vrf_dev,
 	if (need_strict)
 		vrf_ip6_input_dst(skb, vrf_dev, orig_iif);
 
+	skb = vrf_rcv_nfhook(NFPROTO_IPV6, NF_INET_PRE_ROUTING, skb, vrf_dev);
 out:
 	return skb;
 }
@@ -929,6 +949,7 @@ static struct sk_buff *vrf_ip_rcv(struct net_device *vrf_dev,
 	dev_queue_xmit_nit(skb, vrf_dev);
 	skb_pull(skb, skb->mac_len);
 
+	skb = vrf_rcv_nfhook(NFPROTO_IPV4, NF_INET_PRE_ROUTING, skb, vrf_dev);
 out:
 	return skb;
 }
-- 
2.1.4
