From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 02/03: nfnetlink_log: fix silly refcount leak
Date: Fri, 26 Feb 2010 18:15:24 +0100 (MET)
Message-ID: <20100226171523.30040.96114.sendpatchset@x2.localnet>
References: <20100226171521.30040.76590.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59978 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965430Ab0BZRPZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2010 12:15:25 -0500
In-Reply-To: <20100226171521.30040.76590.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit a49c65037146bfb2fe300b8277b10b4479fea5fc
Author: Alexey Dobriyan <adobriyan@gmail.com>
Date:   Fri Feb 26 17:48:40 2010 +0100

    netfilter: nfnetlink_log: fix silly refcount leak
    
    Quick fix for memory/module refcount leak.
    Reference count of listener instance never reaches 0.
    
    Start/stop of ulogd2 is enough to trigger this bug!
    
    Now, refcounting there looks very fishy in particular this code:
    
     	if (!try_module_get(THIS_MODULE)) {
    		...
    
    and creation of listener instance with refcount 2,
    so it may very well be ripped and redone.  :-)
    
    Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/netfilter/nfnetlink_log.c b/net/netfilter/nfnetlink_log.c
index 285e902..d9b8fb8 100644
--- a/net/netfilter/nfnetlink_log.c
+++ b/net/netfilter/nfnetlink_log.c
@@ -768,7 +768,7 @@ nfulnl_recv_config(struct sock *ctnl, struct sk_buff *skb,
 			}
 
 			instance_destroy(inst);
-			goto out;
+			goto out_put;
 		default:
 			ret = -ENOTSUPP;
 			break;
