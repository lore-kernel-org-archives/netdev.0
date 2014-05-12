From: David Newall <davidn@davidnewall.com>
Subject: Re: Bad checksum on bridge with IP options
Date: Mon, 12 May 2014 22:53:19 +0930
Message-ID: <5370CB47.4010400@davidnewall.com>
References: <536F8C0F.4090206@davidnewall.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hawking.rebel.net.au ([203.20.69.83]:58951 "EHLO
	hawking.rebel.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756632AbaELNXX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 May 2014 09:23:23 -0400
In-Reply-To: <536F8C0F.4090206@davidnewall.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've got a patch which fixes the faulty checksums, and now ping works 
with RR or TS set.  I'm not quite sure, though, that it fixes the right 
thing.  I wonder if the problem is less that the checksum becomes wrong, 
and more that the route and timestamps ought not to be changed by the 
bridge interface.

Anyway, for discussion, here's the patch:

--- br_netfilter.c.orig	2014-05-12 22:10:59.809988125 +0930
+++ br_netfilter.c	2014-05-12 22:27:46.769299379 +0930
@@ -261,8 +261,10 @@
  static int br_parse_ip_options(struct sk_buff *skb)
  {
  	struct ip_options *opt;
-	const struct iphdr *iph;
+	struct iphdr *iph;
  	struct net_device *dev = skb->dev;
+	__sum16 oldsum;
+	int err;
  	u32 len;
  
  	if (!pskb_may_pull(skb, sizeof(struct iphdr)))
@@ -298,8 +300,15 @@
  	if (iph->ihl == 5)
  		return 0;
  
+	oldsum = iph->check;
  	opt->optlen = iph->ihl*4 - sizeof(struct iphdr);
-	if (ip_options_compile(dev_net(dev), opt, skb))
+	err = ip_options_compile(dev_net(dev), opt, skb);
+	ip_send_check(iph);
+	if (iph->check != oldsum)
+		LIMIT_NETDEBUG(KERN_ERR
+			pr_fmt("br_parse_ip_options: bad sum %x replaced by %x\n"),
+			                       oldsum, iph->check);
+	if (err)
  		goto inhdr_error;
  
  	/* Check correct handling of SRR option */
