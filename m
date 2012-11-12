From: Saurabh <saurabh.mohan@vyatta.com>
Subject: [PATCH] ipv4/ip_vti.c: VTI fix post-decryption forwarding
Date: Mon, 12 Nov 2012 14:17:31 -0800
Message-ID: <20121112221731.GA2772@debian-saurabh-64.vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:35984 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752462Ab2KLWR3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Nov 2012 17:17:29 -0500
Received: from localhost (localhost.localdomain [127.0.0.1])
	by mail.vyatta.com (Postfix) with ESMTP id A908214101B5
	for <netdev@vger.kernel.org>; Mon, 12 Nov 2012 14:17:28 -0800 (PST)
Received: from mail.vyatta.com ([127.0.0.1])
	by localhost (mail.vyatta.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id A5e+bhR3Flqn for <netdev@vger.kernel.org>;
	Mon, 12 Nov 2012 14:17:27 -0800 (PST)
Received: from localhost (eng-dhcp-109.vyatta.com [10.3.0.109])
	by mail.vyatta.com (Postfix) with ESMTP id A5A211410476
	for <netdev@vger.kernel.org>; Mon, 12 Nov 2012 14:17:27 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



With the latest kernel there are two things that must be done post decryption
 so that the packet are forwarded.
 1. Remove the mark from the packet. This will cause the packet to not match
 the ipsec-policy again. However doing this causes the post-decryption check to
 fail also and the packet will get dropped. (cat /proc/net/xfrm_stat).
 2. Remove the sp association in the skbuff so that no policy check is done on
 the packet for VTI tunnels.

Due to #2 above we must now do a security-policy check in the vti rcv path
prior to resetting the mark in the skbuff.

Signed-off-by: Saurabh Mohan <saurabh.mohan@vyatta.com>
Reported-by: Ruben Herold <ruben@puettmann.net>

---
diff --git a/net/ipv4/ip_vti.c b/net/ipv4/ip_vti.c
index 1831092..858fddf 100644
--- a/net/ipv4/ip_vti.c
+++ b/net/ipv4/ip_vti.c
@@ -338,12 +338,17 @@ static int vti_rcv(struct sk_buff *skb)
 	if (tunnel != NULL) {
 		struct pcpu_tstats *tstats;
 
+		if (!xfrm4_policy_check(NULL, XFRM_POLICY_IN, skb))
+			return -1;
+
 		tstats = this_cpu_ptr(tunnel->dev->tstats);
 		u64_stats_update_begin(&tstats->syncp);
 		tstats->rx_packets++;
 		tstats->rx_bytes += skb->len;
 		u64_stats_update_end(&tstats->syncp);
 
+		skb->mark = 0;
+		secpath_reset(skb);
 		skb->dev = tunnel->dev;
 		return 1;
 	}
