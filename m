From: David Marchand <david.marchand@pace.com>
Subject: Re: [RFC] Move in6_dev_hold under CONFIG_IPV6_PRIVACY
Date: Thu, 30 Aug 2012 18:52:00 +0200
Message-ID: <503F9A30.6030100@pace.com>
References: <503F3589.5070804@pace.com> <1346340321.2586.24.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from cluster-b.mailcontrol.com ([85.115.56.190]:48701 "EHLO
	cluster-b.mailcontrol.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754330Ab2H3QwS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Aug 2012 12:52:18 -0400
Received: from rly18b.srv.mailcontrol.com (localhost.localdomain [127.0.0.1])
	by rly18b.srv.mailcontrol.com (MailControl) with ESMTP id q7UGq8c5008374
	for <netdev@vger.kernel.org>; Thu, 30 Aug 2012 17:52:13 +0100
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by rly18b.srv.mailcontrol.com (MailControl) id q7UGq79V008053
	for <netdev@vger.kernel.org>; Thu, 30 Aug 2012 17:52:07 +0100
In-Reply-To: <1346340321.2586.24.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 30/08/2012 17:25, Eric Dumazet wrote:
> Your patch was mangled by your email client, and its always safer to
> test a patch...

Sorry about that, I am not used to sending patch (tried again, I hope it is fine this time ...).

I did try my patch in my setup, and did not notice any problem at the moment.
I sent this patch as a rfc, mainly because I want to know if my analysis is correct (and if not, understand why).


> Dont trust the comment, its a bit misleading.
>
> Comment intent was to say :
>
> /* One reference from device.  We must do this before
>  * we eventually invoke __ipv6_regen_rndid().
>  */
>

Mmm, ok.
But if CONFIG_IPV6_PRIVACY is not selected, then I can't find where the associated in6_dev_put is done for this in6_dev_hold.
Besides, __ipv6_regen_rndid is a "CONFIG_IPV6_PRIVACY-only" stuff.



diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 6bc85f7..263fcf3 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -393,11 +393,6 @@ static struct inet6_dev *ipv6_add_dev(struct net_device *dev)
 		return NULL;
 	}

-	/* One reference from device.  We must do this before
-	 * we invoke __ipv6_regen_rndid().
-	 */
-	in6_dev_hold(ndev);
-
 	if (dev->flags & (IFF_NOARP | IFF_LOOPBACK))
 		ndev->cnf.accept_dad = -1;

@@ -410,6 +405,12 @@ static struct inet6_dev *ipv6_add_dev(struct net_device *dev)

 #ifdef CONFIG_IPV6_PRIVACY
 	INIT_LIST_HEAD(&ndev->tempaddr_list);
+
+	/* One reference from device.  We must do this before
+	 * we invoke ipv6_regen_rndid().
+	 */
+	in6_dev_hold(ndev);
+
 	setup_timer(&ndev->regen_timer, ipv6_regen_rndid, (unsigned long)ndev);
 	if ((dev->flags&IFF_LOOPBACK) ||
 	    dev->type == ARPHRD_TUNNEL ||




-- 
David Marchand




This message has been scanned for viruses by BlackSpider MailControl. - www.blackspider.com
