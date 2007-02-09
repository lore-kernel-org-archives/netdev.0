From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [Bugme-new] [Bug 7974] New: BUG: scheduling while atomic: swapper/0x10000100/0
Date: Fri, 9 Feb 2007 23:35:20 +0100
Message-ID: <20070209223520.GA27634@electric-eye.fr.zoreil.com>
References: <200702091623.l19GNiUP006513@fire-2.osdl.org> <20070209133802.01286bbb.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	lpiccilli@gelre.com.br,
	"bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@bugzilla.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:60269 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1423353AbXBIWhm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Feb 2007 17:37:42 -0500
Content-Disposition: inline
In-Reply-To: <20070209133802.01286bbb.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Morton <akpm@linux-foundation.org> :
> 
> cond_resched() called from softirq, amongst other problems.

Seems too simple to be right. Btw calling dev_set_mac_address
may hurt some tg3:

-> tg3_set_mac_addr
   -> tg3_netif_stop (depending on the content of their sram): 
      -> netif_poll_disable
         -> schedule_timeout_interruptible

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index e76539a..a4bcfe2 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -673,7 +673,7 @@ void rtmsg_ifinfo(int type, struct net_device *dev, unsigned change)
 	struct sk_buff *skb;
 	int err = -ENOBUFS;
 
-	skb = nlmsg_new(if_nlmsg_size(0), GFP_KERNEL);
+	skb = nlmsg_new(if_nlmsg_size(0), GFP_ATOMIC);
 	if (skb == NULL)
 		goto errout;
 
@@ -681,7 +681,7 @@ void rtmsg_ifinfo(int type, struct net_device *dev, unsigned change)
 	/* failure implies BUG in if_nlmsg_size() */
 	BUG_ON(err < 0);
 
-	err = rtnl_notify(skb, 0, RTNLGRP_LINK, NULL, GFP_KERNEL);
+	err = rtnl_notify(skb, 0, RTNLGRP_LINK, NULL, GFP_ATOMIC);
 errout:
 	if (err < 0)
 		rtnl_set_sk_err(RTNLGRP_LINK, err);
