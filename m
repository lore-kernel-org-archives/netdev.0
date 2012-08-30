From: David Marchand <david.marchand@pace.com>
Subject: [RFC] Move in6_dev_hold under CONFIG_IPV6_PRIVACY
Date: Thu, 30 Aug 2012 11:42:33 +0200
Message-ID: <503F3589.5070804@pace.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cluster-b.mailcontrol.com ([85.115.56.190]:44984 "EHLO
	cluster-b.mailcontrol.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751022Ab2H3Kcd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Aug 2012 06:32:33 -0400
Received: from salexc1.pace.internal (194-60-90-host-12.pace.co.uk [194.60.90.12])
	by rly36b.srv.mailcontrol.com (MailControl) with ESMTP id q7U9gYJl026844
	for <netdev@vger.kernel.org>; Thu, 30 Aug 2012 10:42:34 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I am currently looking at a problem with in6 interface refcnt on a 
really old kernel and I have just noticed something I find suspicious in 
all kernels until now.

The comment at net/ipv6/addrconf.c:396 suggests that the call to 
in6_dev_hold is only for ipv6_regen_rndid.
As a consequence, if CONFIG_IPV6_PRIVACY is not set, then this 
in6_dev_hold will leak a refcnt.

Can someone look at this ?
I did not test this patch, yet it looks reasonable to me.

Thank you.


$ git diff
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 6bc85f7..263fcf3 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -393,11 +393,6 @@ static struct inet6_dev *ipv6_add_dev(struct 
net_device *dev)
                 return NULL;
         }

-       /* One reference from device.  We must do this before
-        * we invoke __ipv6_regen_rndid().
-        */
-       in6_dev_hold(ndev);
-
         if (dev->flags & (IFF_NOARP | IFF_LOOPBACK))
                 ndev->cnf.accept_dad = -1;

@@ -410,6 +405,12 @@ static struct inet6_dev *ipv6_add_dev(struct 
net_device *dev)

  #ifdef CONFIG_IPV6_PRIVACY
         INIT_LIST_HEAD(&ndev->tempaddr_list);
+
+       /* One reference from device.  We must do this before
+        * we invoke ipv6_regen_rndid().
+        */
+       in6_dev_hold(ndev);
+
         setup_timer(&ndev->regen_timer, ipv6_regen_rndid, (unsigned 
long)ndev);
         if ((dev->flags&IFF_LOOPBACK) ||
             dev->type == ARPHRD_TUNNEL ||



-- 
David Marchand


This message has been scanned for viruses by BlackSpider MailControl. - www.blackspider.com
